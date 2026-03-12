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
        instr_addr : out address_type;
        instr_data : in word_type;
        -- data bus - read/write
        data_we : out std_logic; -- "data write enable"
        data_re : out std_logic; -- "data read enable"
        data_addr : out address_type;
        data_bus : inout word_type;
        data_read_ready : in std_logic
    );
end processor_top;

architecture rtl of processor_top is
    signal pc : address_type := (others => '0');
    signal instr : word_type := (others => '0');

    signal pc_we : std_logic := '0'; -- program counter write enable
    signal stall_flag : std_logic := '0';

    -- decode stage
    signal ID_pc : address_type;
    signal ID_instr : word_type := (others => '0');
    signal ID_rs1_used : std_logic := '0';
    signal ID_rs2_used : std_logic := '0';
    signal ID_rs1 : std_logic_vector(1 downto 0); -- "address" in reg bank for rs1/rs
    signal ID_rs2 : std_logic_vector(1 downto 0); -- "address" in reg bank for rs2

    signal ID_rs1_val : word_type; -- value from register rs1
    signal ID_rs2_val : word_type; -- value from register rs2

    -- execute stage
    signal EX_pc : address_type;
    signal EX_pc_out : address_type; -- PC after branching logic
    signal EX_branch_taken : std_logic := '0';
    signal EX_branch_unit_result : word_type;
    signal EX_is_branch : std_logic;
    signal EX_instr : word_type := (others => '0');
    signal EX_rd_used : std_logic := '0';
    signal EX_instr_is_ld : std_logic := '0';
    signal EX_rd : std_logic_vector(1 downto 0); -- "address" in reg bank for rd
    signal EX_rs1_val : word_type; -- value from register rs1, at EX stage
    signal EX_rs2_val : word_type; -- value from register rs2, at EX stage

    -- mem writeback stage
    signal MEM_pc : address_type;
    signal MEM_instr : word_type;
    signal MEM_instr_is_sd : std_logic;
    signal MEM_instr_is_ld : std_logic;
    signal MEM_branch_taken : std_logic := '0';
    signal MEM_result : word_type;
    signal MEM_write_data : word_type;

    -- register bank signals
    signal rd_to_regs : std_logic_vector(1 downto 0); -- "address" in reg bank for rd
    signal rd_val_to_regs : word_type;
    signal registers_we : std_logic;

    -- after decoding
    signal imm_val : word_type; -- imm value from instruction
    --  signals to alu
    signal alu_enable : std_logic;
    signal alu_op : alu_op_type;
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
            instr_is_sd : out std_logic;
            instr_is_ld : out std_logic;
            instr_bz_or_bnz : out std_logic;
            instr_is_branch : out std_logic;
            is_nop : out std_logic;
            rs1_used : out std_logic;
            rs2_used : out std_logic;
            rd_used : out std_logic;
            rs1 : out std_logic_vector(1 downto 0);
            rs2 : out std_logic_vector(1 downto 0);
            rd : out std_logic_vector(1 downto 0)
        );
    end component;

    component branch_unit is
        port (
            instruction : in word_type;
            PC_in : in address_type;
            A : in word_type;
            is_branch : out std_logic;
            branch_taken : out std_logic;
            result : out word_type;
            PC_out : out address_type
        );
    end component;
begin

    pc_we <= '1' when data_read_ready = '1' and stall_flag = '0' else
        '0';

    stall_flag <= '1' when (((ID_rs1_used = '1' and EX_rd_used = '1' and (ID_rs1 = EX_rd))
        or (ID_rs2_used = '1' and EX_rd_used = '1' and (ID_rs2 = EX_rd)))
        and EX_instr_is_ld = '1') else
        '0';

    -- instruction fetch stage (IF)
    process (clk, reset)
    begin
        if reset = '1' then
            ID_pc <= (others => '0');
            ID_instr <= (others => '0');
        elsif rising_edge(clk) then
            if pc_we then
                if MEM_branch_taken = '1' then
                    ID_pc <= address_type(MEM_instr);
                    ID_instr <= (others => '0');
                else
                    ID_pc <= pc + 1;
                    ID_instr <= instr_data;
                end if;
            end if;
        end if;
    end process;

    -- instruction decode stage (ID)
    ID_instr_logic : instr_logic
    port map(
        instruction => ID_instr,
        instr_is_sd => open,
        instr_is_ld => open,
        instr_bz_or_bnz => open,
        instr_is_branch => open,
        is_nop => open,
        rs1_used => ID_rs1_used,
        rs2_used => ID_rs2_used,
        rd_used => open,
        rs1 => ID_rs1,
        rs2 => ID_rs2,
        rd => open
    );

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
                else
                    EX_instr <= ID_instr;
                end if;
            end if;
        end if;
    end process;

    -- execute stage (EX)
    EX_instr_logic : instr_logic
    port map(
        instruction => EX_instr,
        instr_is_sd => open,
        instr_is_ld => EX_instr_is_ld,
        instr_bz_or_bnz => open,
        instr_is_branch => EX_is_branch,
        is_nop => open,
        rs1_used => open,
        rs2_used => open,
        rd_used => open,
        rs1 => open,
        rs2 => open,
        rd => EX_rd
    );

    bu1 : branch_unit
    port map(
        instruction => EX_instr,
        PC_in => EX_pc,
        A => EX_rs1_val,
        branch_taken => EX_branch_taken,
        result => EX_branch_unit_result,
        PC_out => EX_pc_out
    );

    alu1 : alu
    port map(
        clk => clk,
        enable => alu_enable,
        op => alu_op,
        a => EX_rs1_val, -- TODO implement forwarding
        b => EX_rs2_val,
        d_out => alu_out
    );

    process (clk, reset)
    begin
        if reset = '1' then
            MEM_pc <= (others => '0');
            MEM_branch_taken <= '0';
        elsif rising_edge(clk) then
            if data_read_ready = '1' then
                MEM_pc <= EX_pc;
                if MEM_branch_taken = '1' then
                    MEM_instr <= (others => '0');
                else
                    MEM_instr <= EX_instr;
                end if;

                MEM_write_data <= EX_rs2_val;
                MEM_branch_taken <= EX_branch_taken;

                if EX_is_branch = '1' then
                    MEM_result <= EX_branch_unit_result;
                else
                    MEM_result <= alu_out;
                end if;

            end if;
        end if;
    end process;

    -- memory access stage (MEM)
    MEM_instr_logic : instr_logic
    port map(
        instruction => MEM_instr,
        instr_is_sd => MEM_instr_is_sd,
        instr_is_ld => MEM_instr_is_ld,
        instr_is_branch => open,
        is_nop => open,
        rs1_used => open,
        rs2_used => open,
        rd_used => open,
        rs1 => open,
        rs2 => open,
        rd => open
    );
    data_we <= '1' when MEM_instr_is_sd else
        '0';
    data_re <= '1' when MEM_instr_is_ld else
        '0';
    data_addr <= MEM_result;
    data_bus <= MEM_write_data when MEM_instr_is_sd else
        (others => 'Z');

    process (clk, reset)
    begin
        if reset = '1' then
            WB_instr <= (others => '0');
            WB_result <= (others => '0');
            WB_load <= (others => '0');
        elsif rising_edge(clk) then
            if data_read_ready = '1' then
                WB_instr <= MEM_instr;
                WB_result <= MEM_result;
                WB_load <= data_bus; -- data from RAM

                if EX_is_branch = '1' then
                    MEM_result <= EX_branch_unit_result;
                else
                    MEM_result <= alu_out;
                end if;

            end if;
        end if;
    end process;
    -- register writeback stage (WB)
    WB_instr_logic : instr_logic
    port map(
        instruction => WB_instr,
        instr_is_sd => open,
        instr_is_ld => WB_instr_is_ld,
        instr_is_branch => open,
        is_nop => open,
        rs1_used => open,
        rs2_used => open,
        rd_used => open,
        rs1 => open,
        rs2 => open,
        rd => WB_rd
    );

    registers : register_bank
    port map(
        clk => clk,
        rs1 => ID_rs1,
        rs2 => ID_rs2,
        rs1_val_out => ID_rs1_val,
        rs2_val_out => ID_rs2_val,
        we => registers_we,
        rd => rd_to_regs,
        rd_val_in => rd_val_to_regs
    );

    rd_to_regs <= WB_rd;
    rd_val_to_regs <= WB_load when WB_instr_is_ld else
        WB_result;

    registers_we <= '1' when -- writeback by default
        (WB_instr_is_sd = '0' and -- sd doesn't write to registers
        WB_instr_bz_or_bnz = '0' and -- bz and bnz don't write to registers
        not WB_instr = (others => '0')) else -- nop doesn't write to registers
        '0';
end rtl;
