library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


package ram_pkg is
    constant ADDR_WIDTH : integer := 10;  -- 1024 words
    constant DATA_WIDTH : integer := 12;   -- 12-bit data
    type ram_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

    -- utility to initialize RAM with data
    impure function init_ram_from_file(filename : string) return ram_type;
end package ram_pkg;

package body ram_pkg is
    impure function init_ram_from_file(filename : string) return ram_type is
        file ram_file : text open read_mode is filename;
        variable ram_line : line;
        variable ram_data : ram_type;
    begin
        for i in ram_type'range loop
            if not endfile(ram_file) then
                readline(ram_file, ram_line);
                hread(ram_line, ram_data(i));
            else
                ram_data(i) := (others => '0');
            end if;
        end loop;
        return ram_data;
    end function;
end package body;
