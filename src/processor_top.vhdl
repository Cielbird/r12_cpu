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
        instr_addr : out ram_address;
        instr_data : in ram_data;
        -- data bus - read/write
        data_we : out std_logic; -- "data write enable"
        data_re : out std_logic; -- "data read enable"
        data_addr : out ram_address;
        data_bus : inout ram_data
    );
end processor_top;

architecture rtl of processor_top is
    signal pc : ram_address := (others => '0');
    signal instr : ram_data := (others => '0');

    -- register bank signals
    signal rs1_to_regs : std_logic_vector(1 downto 0); -- "address" in reg bank for rs1/rs
    signal rs2_to_regs : std_logic_vector(1 downto 0); -- "address" in reg bank for rs2
    signal rd_to_regs : std_logic_vector(1 downto 0); -- "address" in reg bank for rd
    signal rd_val_to_regs : word_type;
    signal registers_we : std_logic;

    -- after decoding
    signal rs1_val : word_type; -- value from register rs1
    signal rs2_val : word_type; -- value from register rs2
    signal imm_val : word_type; -- imm value from instruction
    --  signals to alu
    signal alu_enable : std_logic;
    signal alu_op : alu_op_type;
    signal alu_in_a : word_type;
    signal alu_in_b : word_type;
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
begin
    alu_instance : alu port map(
        clk => clk,
        enable => alu_enable,
        op => alu_op,
        a => alu_in_a,
        b => alu_in_b,
        d_out => alu_out
    );


    registers : register_bank 
        port map(
            clk => clk,
            rs1 => rs1_to_regs,
            rs2 => rs2_to_regs,
            rs1_val_out => rs1_val,
            rs2_val_out => rs2_val,
            we => registers_we,
            rd => rd_to_regs,
            rd_val_in => rd_val_to_regs
        );

    

    process (clk, reset)
    begin
        if reset = '1' then
            -- TODO
        elsif rising_edge(clk) then
            -- TODO
        end if;
    end process;



    -- TODO
    
end rtl;
