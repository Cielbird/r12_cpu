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
        reset : in std_logic;

        we : in std_logic; -- "write enable"
        re : in std_logic; -- "read enable"
        addr_in : in address_type;
        data_in : in word_type;
        data_out : out word_type := (others => '0');
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

    signal memory_data : memory_type := init_memory;

begin
    process (clk, reset, we, data_in)
    begin
        ready <= '1'; -- this one is always ready
        if reset='1' then
            data_out <= to_word(x"000");
        else
            if rising_edge(clk) then
                if we = '1' then
                    memory_data(to_integer(unsigned(addr_in))) <= data_in; -- adresses are word-space
                end if;
            end if;

            -- reading is 0-tick, async
            if re = '1' then
                data_out <= memory_data(to_integer(unsigned(addr_in)));
            end if;
        end if;
    end process;
end ideal;
