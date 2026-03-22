library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;
use work.ram_pkg.all;

-- r12 cpu
entity processor_top is
    port (
        clk : in std_logic;
        reset : in std_logic;

        -- instructions bus - read-only
        instr_addr : out address_type := (others => '0');
        instr_data : in word_type;
        -- data bus - read/write
        data_we : out std_logic := '0'; -- "data write enable"
        data_re : out std_logic := '0'; -- "data read enable"
        data_addr : out address_type := (others => '0');
        data_in : in word_type;
        data_out : out word_type := (others => '0');
        data_read_ready : in std_logic
    );
end processor_top;

architecture rtl of processor_top is
    signal pc : address_type := (others => '0');
    signal pc_we : std_logic := '0'; -- program counter write enable
    signal stall_flag : std_logic := '0';

    -- 1 when data isn't ready from memory and stalling necessary. 0 otherwise
    signal data_reading_flag : std_logic := '0';

    -- fetch stage (IF)
    signal IF_instr : word_type := (others => '0');

    -- decode stage
    signal ID_pc : address_type := (others => '0');
    signal ID_instr : word_type := (others => '0');
    signal ID_instr_info : instruction_info;
    signal ID_rs1_val : word_type := (others => '0'); -- value from register rs1
    signal ID_rs2_val : word_type := (others => '0'); -- value from register rs2

    -- execute stage (EX)
    signal EX_pc : address_type;
    signal EX_instr : word_type := (others => '0');
    signal EX_instr_info : instruction_info;
    signal EX_pc_out : address_type; -- PC after branching logic
    signal EX_branch_taken : std_logic := '0';
    signal EX_branch_unit_result : word_type := (others => '0');
    signal EX_rs1_val : word_type := (others => '0'); -- value from register rs1, at EX stage
    signal EX_rs2_val : word_type := (others => '0'); -- value from register rs2, at EX stage
    signal EX_fw_rs1_val : word_type;
    signal EX_fw_rs2_val : word_type;
    signal forward_a_from_mem : std_logic;
    signal forward_b_from_mem : std_logic;
    signal forward_a_from_wb : std_logic;
    signal forward_b_from_wb : std_logic;

    -- mem access stage (MEM)
    signal MEM_pc : address_type;
    signal MEM_instr : word_type := (others => '0');
    signal MEM_instr_info : instruction_info;
    signal MEM_branch_taken : std_logic := '0';
    signal MEM_result : word_type;
    signal MEM_write_data : word_type;

    -- register writeback stage (WB)
    signal WB_instr : word_type;
    signal WB_instr_info : instruction_info;
    signal WB_alu_result: word_type;
    signal WB_load : word_type;

    -- register bank signals
    signal rd_to_regs : std_logic_vector(1 downto 0); -- "address" in reg bank for rd
    signal WB_result : word_type;
    signal registers_we : std_logic;

    -- after decoding
    signal imm_val : word_type; -- imm value from instruction
    --  signals to alu
    signal alu_enable : std_logic;
    signal alu_op : alu_op_type;
    signal alu_a_in : word_type;
    signal alu_b_in : word_type;
    signal alu_out : word_type;

    component alu is
        port (
            clk : in std_logic;
            enable : in std_logic;
            op : in alu_op_type;
            a : in word_type;
            b : in word_type;
            d_out : out word_type
        );
    end component;

    component register_bank is
        port (
            clk : in std_logic;
            rs1 : in std_logic_vector(1 downto 0);
            rs2 : in std_logic_vector(1 downto 0);
            rs1_val_out : out word_type;
            rs2_val_out : out word_type;
            we : in std_logic;
            rd : in std_logic_vector(1 downto 0);
            rd_val_in : in word_type
        );
    end component;

    component instr_logic is
        port (
            instruction : in word_type;
            info : out instruction_info
        );
    end component;

    component branch_unit is
        port (
            instruction : in word_type;
            PC_in : in address_type;
            rs1_val : in word_type;
            instr_imm : in signed(11 downto 0);
            branch_taken : out std_logic;
            result : out word_type;
            PC_out : out address_type
        );
    end component;

    component forwarding_unit is
        port (
            EX_instr_info : in instruction_info;
            MEM_instr_info : in instruction_info;
            WB_instr_info : in instruction_info;
            forward_a_from_mem : out std_logic;
            forward_b_from_mem : out std_logic;
            forward_a_from_wb : out std_logic;
            forward_b_from_wb : out std_logic
        );
    end component;
begin


    stall_flag <= '1' when (((ID_instr_info.is_rs1_used = '1' and EX_instr_info.is_rd_used = '1' and (ID_instr_info.rs1 = EX_instr_info.rd))
        or (ID_instr_info.is_rs2_used = '1' and EX_instr_info.is_rd_used = '1' and (ID_instr_info.rs2 = EX_instr_info.rd)))
        and EX_instr_info.is_ld = '1') else
        '0';

    -- instruction fetch stage (IF)
    pc_we <= '1' when data_read_ready = '1' and stall_flag = '0' else
        '0';
    IF_instr <= instr_data;
    process (clk, reset)
    begin
        if reset = '1' then
            ID_pc <= (others => '0');
            ID_instr <= (others => '0');
        elsif rising_edge(clk) then
            if pc_we then
                if MEM_branch_taken = '1' then
                    ID_pc <= MEM_pc;
                    ID_instr <= (others => '0');
                else
                    ID_pc <= ID_pc + 1;
                    ID_instr <= instr_data;
                end if;
            end if;
        end if;
    end process;

    -- instruction decode stage (ID)
    ID_instr_logic : instr_logic
    port map(
        instruction => ID_instr,
        info => ID_instr_info
    );

    instr_addr <= ID_pc;

    process (clk, reset)
    begin
        if reset = '1' then
            EX_pc <= (others => '0');
            EX_instr <= (others => '0');
        elsif rising_edge(clk) then
            if data_read_ready = '1' then
                EX_pc <= ID_pc;
                EX_rs1_val <= ID_rs1_val;
                EX_rs2_val <= ID_rs2_val;

                if (MEM_branch_taken = '1' or stall_flag = '1') then
                    EX_instr <= (others => '0');
                    EX_instr_info <= NOP_INSTR_INFO;
                else
                    EX_instr <= ID_instr;
                    EX_instr_info <= ID_instr_info;
                end if;
            end if;
        end if;
    end process;

    -- execute stage (EX)
    bu1 : branch_unit
    port map(
        instruction => EX_instr,
        PC_in => EX_pc,
        rs1_val => EX_fw_rs1_val,
        instr_imm => EX_instr_info.imm,
        branch_taken => EX_branch_taken,
        result => EX_branch_unit_result,
        PC_out => EX_pc_out
    );

    -- ALU control
    alu_enable <= '1';
    with EX_instr_info.opcode select alu_op <=
    ALU_ADD when OP_NOP,
    ALU_ADD when OP_ADD,
    ALU_SUB when OP_SUB,
    ALU_MUL when OP_MULT,
    ALU_DIV when OP_DIV,
    ALU_MOD when OP_MOD,
    ALU_AND when OP_AND,
    ALU_OR when OP_OR,
    ALU_XOR when OP_XOR,
    ALU_NOT when OP_NOT,
    ALU_ADD when OP_ADDI,
    ALU_SUB when OP_SUBI,
    ALU_MUL when OP_MULTI,
    ALU_DIV when OP_DIVI,
    ALU_MOD when OP_MODI,
    ALU_SLL when OP_SHLI,
    ALU_SRL when OP_SHRI,
    ALU_ADD when OP_LD,
    ALU_ADD when OP_SD,
    ALU_ADD when OP_JAL,
    ALU_ADD when OP_JALR,
    ALU_ADD when OP_BZ,
    ALU_ADD when OP_BNZ;
    -- forwarding logic
    fu1 : forwarding_unit
    port map(
        EX_instr_info => EX_instr_info,
        MEM_instr_info => MEM_instr_info,
        WB_instr_info => WB_instr_info,
        forward_a_from_mem => forward_a_from_mem,
        forward_b_from_mem => forward_b_from_mem,
        forward_a_from_wb => forward_a_from_wb,
        forward_b_from_wb => forward_b_from_wb
    );

    -- forwarded value : may come from another stage
    EX_fw_rs1_val <= MEM_result when forward_a_from_mem else -- forward from mem takes priority
        WB_result when forward_a_from_wb else
        EX_rs1_val;
    EX_fw_rs2_val <= MEM_result when forward_b_from_mem else -- same with rs2
        WB_result when forward_b_from_wb else
        EX_rs2_val;

    -- jal, bnz, or bz use PC for alu input A
    alu_a_in <= EX_fw_rs1_val when to_integer(unsigned(EX_instr(11 downto 8))) < 13 else
        word_type(EX_pc); -- TODO maybe offset needed

    alu_b_in <= EX_fw_rs2_val when to_integer(unsigned(EX_instr(11 downto 8))) <= 2 else
        word_type(EX_instr_info.imm);

    alu1 : alu
    port map(
        clk => clk,
        enable => alu_enable,
        op => alu_op,
        a => alu_a_in,
        b => alu_b_in,
        d_out => alu_out
    );

    process (clk, reset)
    begin
        if reset = '1' then
            MEM_pc <= (others => '0');
            MEM_branch_taken <= '0';
            MEM_write_data <= to_word(x"000");
        elsif rising_edge(clk) then
            if data_read_ready = '1' then
                MEM_pc <= EX_pc_out;
                if MEM_branch_taken = '1' then
                    MEM_instr <= (others => '0');
                    MEM_instr_info <= NOP_INSTR_INFO;
                else
                    MEM_instr <= EX_instr;
                    MEM_instr_info <= EX_instr_info;
                end if;

                MEM_write_data <= EX_fw_rs2_val;
                MEM_branch_taken <= EX_branch_taken;

                if EX_instr_info.is_branch = '1' then
                    MEM_result <= EX_branch_unit_result;
                else
                    MEM_result <= alu_out;
                end if;
            end if;
        end if;
    end process;

    -- memory access stage (MEM)
    data_we <= '1' when MEM_instr_info.is_sd = '1' else
        '0';
    data_re <= '1' when MEM_instr_info.is_ld = '1' else
        '0';
    data_addr <= address_type(MEM_result);
    data_out <= MEM_write_data; -- data to RAM

    process (clk, reset)
    begin
        if reset = '1' then
            WB_instr <= (others => '0');
            WB_instr_info <= NOP_INSTR_INFO;

            WB_alu_result<= (others => '0');
            WB_load <= (others => '0');
        elsif rising_edge(clk) then
            if data_read_ready = '1' then
                WB_instr <= MEM_instr;
                WB_instr_info <= MEM_instr_info;

                WB_alu_result <= MEM_result;
                WB_load <= data_in; -- data from RAM
            end if;
        end if;
    end process;

    -- register writeback stage (WB)
    registers : register_bank
    port map(
        clk => clk,
        rs1 => ID_instr_info.rs1,
        rs2 => ID_instr_info.rs2,
        rs1_val_out => ID_rs1_val,
        rs2_val_out => ID_rs2_val,
        we => registers_we,
        rd => rd_to_regs,
        rd_val_in => WB_result
    );

    rd_to_regs <= WB_instr_info.rd;
    WB_result <= WB_load when WB_instr_info.is_ld else WB_alu_result;

    registers_we <= '1' when -- writeback by default
        (WB_instr_info.is_sd = '0' and -- sd doesn't write to registers
        WB_instr_info.is_bz_or_bnz = '0' and -- bz and bnz don't write to registers
        WB_instr_info.is_nop='0') else -- nop doesn't write to registers
        '0';
end rtl;
