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

        -- instructions bus - read-only
        instr_addr : out ram_address;
        instr_data : in ram_data;
        -- data bus - read/write
        data_we : out std_logic; -- high=write, low=read
        data_addr : out ram_address;
        data_bus : inout ram_data
    );
end processor_top;

architecture rtl of processor_top is
    signal pc : ram_address := (others => '0');
    signal instr : ram_data := (others => '0');
    signal instr_op : instr_op_type;


    component alu is
        port (
            clk : in std_logic;
            op : in alu_op_type;
            a : in word_type;
            b : in word_type;
            d_out : out word_type
        );
    end component;

    --  signals to alu
    signal alu_op : alu_op_type;
    signal alu_in_a : word_type;
    signal alu_in_b : word_type;
    signal alu_out : word_type;
begin
    alu_instance : alu port map(
        clk => clk,
        op => alu_op,
        a => alu_in_a,
        b => alu_in_b,
        d_out => alu_out
    );

    instr_op <= data_to_instr_op(instr);
    alu_op <= instr_op_to_alu_op(instr_op);

    process (clk)
    begin
        if rising_edge(clk) then
            instr <= instr_data;
            instr_addr <= pc;
            pc <= std_logic_vector(unsigned(pc) + 1);
        end if;
    end process;

end rtl;
