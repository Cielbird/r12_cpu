library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;

-- r12 cpu
entity cpu_top is
    port (
        clk : in std_logic
    );
end cpu_top;

architecture rtl of cpu_top is
begin
    process(clk)
    begin
    if rising_edge(clk) then
        -- cnt <= cnt + 1;
    end if;
    end process;

end rtl;
