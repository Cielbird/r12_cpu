library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;

-- r12 cpu
entity alu is
    port (
        clk : in std_logic;
        op : in r12_alu_op;
        a : in unsigned12;
        b : in unsigned12;
        d_out : out unsigned12
    );
end alu;

architecture rtl of alu is
begin
    process(clk)
    begin
    if rising_edge(clk) then
        case op is
            when ALU_ADD =>
                d_out <= a + b;
            when others =>
                null; -- TODO implement other operations
        end case;
    end if;
    end process;

end rtl;


