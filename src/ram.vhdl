library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.processor_pkg.all;
use work.ram_pkg.all;

entity memory_controller is
    generic (
        init_file : string := ""  -- empty = zero-initialized
    );
    port (
        clk : in std_logic;

        we : in std_logic; -- "write enable"
        re : in std_logic; -- "read enable"
        addr_in : in address_type;
        data_bus : inout word_type := (others => 'Z');
        ready : out std_logic := '0' -- read data ready
        -- no "write ready" signal !
    );
end memory_controller;

-- memory controller for simulation (0 tick read/write)
architecture ideal of memory_controller is
    -- TODO add variable delay in clock cycles with shift buffer
    
    impure function init_memory return memory_type is
    begin
        if init_file = "" then
            return (others => (others => '0'));
        else
            return init_memory_from_file(init_file);
        end if;
    end function;

    signal read_data : word_type := (others => '0');
    signal memory_data : memory_type := init_memory;

begin
    process (clk)
    begin
        if rising_edge(clk) then
            if re = '1' then
                read_data <= memory_data(to_integer(unsigned(addr_in)));
                ready <= '1';
            elsif ready = '1' then
                ready <= '0'; -- data is output on one clock signal
            elsif we = '1' then
                memory_data(to_integer(unsigned(addr_in))) <= data_bus; -- TODO are adresses word level or byte level ? aligment ?
            end if;
        end if;
    end process;

    -- release bus when not reading
    data_bus <= read_data when ready = '1' else (others => 'Z');

end ideal;

-- signal ram : memory_type := init_memory_from_file("program.hex");
