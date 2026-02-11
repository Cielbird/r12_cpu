library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.processor_pkg.all;
use work.ram_pkg.all;

entity dual_port_ram is
    port (
        clk : in std_logic;

        -- port a : instructions port - read-only
        addr_a : in ram_address;
        data_a : out ram_data;

        -- port b : data port - read/write
        we_b : in std_logic; -- high=write, low=read
        addr_b : in ram_address;
        data_b : inout ram_data
    );
end dual_port_ram;

architecture behavioral of dual_port_ram is
    signal data : ram_type := (others => (others => '0'));

begin
    process (clk)
    begin
        if rising_edge(clk) then
            -- port a: read-only (instruction fetch)
            data_a <= data(to_integer(unsigned(addr_a)));

            -- port b : read/write
            if we_b = '1' then
                data(to_integer(unsigned(addr_b))) <= data_b;
            else
                data_b <= data(to_integer(unsigned(addr_b)));
            end if;
        end if;
    end process;

end behavioral;

-- signal ram : ram_type := init_ram_from_file("program.hex");
