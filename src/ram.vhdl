library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.processor_pkg.all;
use work.ram_pkg.all;

entity memory_controller is
    port (
        clk : in std_logic;

        we : in std_logic; -- "write enable"
        re : in std_logic; -- "read enable"
        addr_in : in ram_address;
        data_bus : inout ram_data;
        ready : out std_logic -- read data ready
        -- no "write ready" signal !
    );
end memory_controller;

-- memory controller for simulation (0 tick read/write)
architecture ideal of memory_controller is
    -- TODO add variable delay in clock cycles with shift buffer
    signal memory_data : ram_type := (others => (others => '0'));

begin
    process (clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                memory_data(to_integer(unsigned(addr_in))) <= data_bus;
            elsif re = '1' then
                data_bus <= memory_data(to_integer(unsigned(addr_in)));
                ready <= '1'; -- always 1 in ideal memory controller
            end if;
        end if;
    end process;

end ideal;

-- signal ram : ram_type := init_ram_from_file("program.hex");
