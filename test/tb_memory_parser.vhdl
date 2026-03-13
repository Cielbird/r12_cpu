library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;
library work;
use work.processor_pkg.all;
use work.ram_pkg.all;

-- Tests the init_memory_from_file function which is pretty heafty
entity tb_memory_parser is
end entity;

architecture sim of tb_memory_parser is
    signal done : boolean;
    
    -- helper to compare and report
    procedure check_word(
        mem : memory_type;
        addr : integer;
        expected : word_type;
        label_str : string
    ) is
    begin
        if mem(addr) /= expected then
            report "FAIL [" & label_str & "] addr=" & integer'image(addr) & " got=" & to_hstring(mem(addr)) & " expected=" & to_hstring(expected) severity error;
        else
            -- report "PASS [" & label_str & "] addr=" & integer'image(addr) & " = " & to_hstring(mem(addr)) severity note;
        end if;
    end procedure;

    procedure check_range(
        mem : memory_type;
        from_addr : integer;
        to_addr : integer;
        expected : word_type;
        label_str : string
    ) is
        variable pass : boolean := true;
    begin
        for i in from_addr to to_addr loop
            if mem(i) /= expected then
                report "FAIL [" & label_str & "] addr=" & integer'image(i) & " got=" & to_hstring(mem(i)) & " expected=" & to_hstring(expected) severity error;
                pass := false;
            end if;
        end loop;
        if pass then
            -- report "PASS [" & label_str & "] range " & integer'image(from_addr) & " to " & integer'image(to_addr) & " all = " & to_hstring(expected) severity note;
        end if;
    end procedure;

begin

    process
        variable mem : memory_type;
    begin

        mem := init_memory_from_file("data");

        -- from your example file:
        -- line 1: 0 0 0 458 fff 10 7 1
        check_word(mem, 0, to_word(x"000"), "addr0 = 0");
        check_word(mem, 1, to_word(x"000"), "addr1 = 0");
        check_word(mem, 2, to_word(x"000"), "addr2 = 0");
        check_word(mem, 3, to_word(x"458"), "addr3 = 458");
        check_word(mem, 4, to_word(x"fff"), "addr4 = fff");
        check_word(mem, 5, to_word(x"010"), "addr5 = 10");
        check_word(mem, 6, to_word(x"007"), "addr6 = 7");
        check_word(mem, 7, to_word(x"001"), "addr7 = 1");

        -- line 2: 2 3 4 5 6 7 8 9
        check_word(mem, 8, to_word(x"002"), "addr8 = 2");
        check_word(mem, 9, to_word(x"003"), "addr9 = 3");
        check_word(mem, 15, to_word(x"009"), "addr15 = 9");

        -- spot check middle of sequential run
        check_word(mem, 16, to_word(x"00a"), "addr16 = a");
        check_word(mem, 20, to_word(x"00e"), "addr20 = e");

        -- last non-RLE value before the run: 458
        -- your file ends with "3983*0 458"
        -- so find where sequential values end and RLE begins
        -- sequential values 0..last go from addr 0 upward
        -- "3983*0" fills a big block with 0, then "458" is the last word
        check_word(mem, memory_type'length - 1, to_word(x"458"), "last addr = 458");

        -- check the zero-filled RLE region
        -- 3983*0 starts after all sequential values
        -- adjust these addresses to match your actual memory size
        check_range(mem, memory_type'length - 1 - 3983, memory_type'length - 2, to_word(x"000"), "RLE zero block");

        report "Memory file parse test done!";
        done <= true;
        wait;
    end process;

end sim;
