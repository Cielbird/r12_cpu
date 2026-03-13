library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.processor_pkg.all;

package ram_pkg is
    type memory_type is array (0 to 2 ** ADDR_WIDTH - 1) of word_type;

    -- utility to initialize RAM with data
    impure function init_memory_from_file(filename : string) return memory_type;
end package ram_pkg;

package body ram_pkg is
    impure function init_memory_from_file(filename : string) return memory_type is
        file f         : text open read_mode is filename;
        variable l     : line;
        variable data  : memory_type := (others => (others => '0'));
        variable idx   : integer := 0;
        variable c     : character;
        variable good  : boolean;

        constant WORD_HEX_LEN : integer := word_type'length / 4;

        -- read one hex character from line, return -1 if not hex
        impure function hex_digit_val(ch : character) return integer is
        begin
            case ch is
                when '0' to '9' => return character'pos(ch) - character'pos('0');
                when 'a' to 'f' => return character'pos(ch) - character'pos('a') + 10;
                when 'A' to 'F' => return character'pos(ch) - character'pos('A') + 10;
                when others     => return -1;
            end case;
        end function;

        -- parse a hex token string into an integer
        impure function parse_hex_int(s : string) return integer is
            variable result : integer := 0;
        begin
            for i in s'range loop
                result := result * 16 + hex_digit_val(s(i));
            end loop;
            return result;
        end function;
        
        -- parse a decimal token string into an integer
        impure function parse_decimal_int(s : string) return integer is
            variable result : integer := 0;
        begin
            for i in s'range loop
                assert s(i) >= '0' and s(i) <= '9'
                    report "non-decimal digit in RLE count: " & s
                    severity failure;
                result := result * 10 + (character'pos(s(i)) - character'pos('0'));
            end loop;
            return result;
        end function;

        -- parse a hex token string into word_type (zero-padded)
        impure function parse_hex_word(s : string) return word_type is
            variable padded   : string(1 to WORD_HEX_LEN) := (others => '0');
            variable tmp_line : line;
            variable result   : word_type;
        begin
            assert s'length <= WORD_HEX_LEN
                report "hex token '" & s & "' too wide for word_type"
                severity failure;
            padded(WORD_HEX_LEN - s'length + 1 to WORD_HEX_LEN) := s;
            write(tmp_line, padded);
            hread(tmp_line, result);
            return result;
        end function;

        -- write a single word to memory, advance index
        procedure write_word(val : word_type) is
        begin
            if idx < memory_type'length then
                data(idx) := val;
                idx := idx + 1;
            else
                -- report "init file has more words than memory_type'length, truncating"
                --     severity warning;
            end if;
        end procedure;

        -- process a single token (may be "val" or "count*val")
        procedure process_token(token : string) is
            variable star : integer := 0;
            variable count : integer;
            variable val   : word_type;
        begin
            -- find '*' if present
            for i in token'range loop
                if token(i) = '*' then
                    star := i;
                    exit;
                end if;
            end loop;

            if star = 0 then
                -- plain value
                write_word(parse_hex_word(token));
            else
                -- run-length: count*value
                count := parse_decimal_int(token(token'left to star - 1)); -- decimal!
                val   := parse_hex_word(token(star + 1 to token'right)); -- hex
                for i in 1 to count loop
                    write_word(val);
                end loop;
            end if;
        end procedure;

        variable token     : string(1 to 32) := (others => ' ');
        variable token_len : integer := 0;

        procedure flush_token is
        begin
            if token_len > 0 then
                process_token(token(1 to token_len));
                token_len := 0;
                token     := (others => ' ');
            end if;
        end procedure;

    begin
        report "parsing file " & filename severity note;
        -- skip header "v2.0 raw"
        readline(f, l);
        assert l'length >= 8
            report "unexpected header in memory file" severity failure;

        -- parse remaining lines character by character
        while not endfile(f) loop
            readline(f, l);
            next when l'length = 0;  -- skip empty lines

            while l'length > 0 loop
                read(l, c, good);
                exit when not good;
                if c = ' ' or c = HT then  -- HT = horizontal tab
                    flush_token;
                else
                    token_len := token_len + 1;
                    token(token_len) := c;
                end if;
            end loop;
            flush_token;  -- end of line also flushes
        end loop;

        file_close(f);
        return data;
    end function;
end package body;
