library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.processor_pkg.all;

package ram_pkg is
    type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of ram_data;

    -- utility to initialize RAM with data
    impure function init_ram_from_file(filename : string) return ram_type;
end package ram_pkg;

package body ram_pkg is
    impure function init_ram_from_file(filename : string) return ram_type is
        file ram_file : text open read_mode is filename;
        variable ram_line : line;
        variable data : ram_type;
    begin
        for i in ram_type'range loop
            if not endfile(ram_file) then
                readline(ram_file, ram_line);
                hread(ram_line, data(i));
            else
                data(i) := (others => '0');
            end if;
        end loop;
        return data;
    end function;
end package body;
