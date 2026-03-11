library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.processor_pkg.all;

entity tb_registers is
end tb_registers;

architecture testbench of tb_registers is
    constant clk_period : time := 10 ns;
    signal clk : std_logic := '0';
    signal rs1 : std_logic_vector(1 downto 0) := "00";
    signal rs2 : std_logic_vector(1 downto 0) := "00";
    signal rs1_val_out : word_type := (others => '0');
    signal rs2_val_out : word_type := (others => '0');
    signal we : std_logic := '0';
    signal rd : std_logic_vector(1 downto 0) := "00";
    signal rd_val_in : word_type := (others => '0');
    signal done : boolean := false;
begin
    uut : entity work.register_bank
        port map(
            clk => clk,
            rs1 => rs1,
            rs2 => rs2,
            rs1_val_out => rs1_val_out,
            rs2_val_out => rs2_val_out,
            we => we,
            rd => rd,
            rd_val_in => rd_val_in
        );

    clk_process : process
    begin
        while not done loop
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    stim_process : process
        type val_array is array (0 to 3) of word_type;
        constant test_values : val_array := (
            "101010101010",
            "111111000000",
            "000011110000",
            "000000111111"
        );
        constant more_test_values : val_array := (
            "000011010000",
            "111011000000",
            "101010111110",
            "001000111011"
        );
    begin
        -- write some values
        we <= '1';
        for i in 0 to 3 loop
            rd <= std_logic_vector(to_unsigned(i, 2));
            rd_val_in <= test_values(i);
            wait for clk_period;
        end loop;

        we <= '0';
        wait for clk_period;

        -- test read with rs1 on each reg
        for i in 0 to 3 loop
            rs1 <= std_logic_vector(to_unsigned(i, 2));
            wait for clk_period;
            assert rs1_val_out = test_values(i)
            report "RS1 register read test failed: reg " & integer'image(i) &
                " expected " & integer'image(to_integer(unsigned(test_values(i)))) &
                ", got " & integer'image(to_integer(unsigned(rs1_val_out)))
                severity error;
        end loop;

        -- test read with rs2 on each reg
        for i in 0 to 3 loop
            rs2 <= std_logic_vector(to_unsigned(i, 2));
            wait for clk_period;
            assert rs2_val_out = test_values(i)
            report "RS2 register read test failed: reg " & integer'image(i) &
                " expected " & integer'image(to_integer(unsigned(test_values(i)))) &
                ", got " & integer'image(to_integer(unsigned(rs2_val_out)))
                severity error;
        end loop;

        -- write more some values
        we <= '1';
        for i in 0 to 3 loop
            rd <= std_logic_vector(to_unsigned(i, 2));
            rd_val_in <= more_test_values(i);
            wait for clk_period;
        end loop;

        we <= '0';
        wait for clk_period;

        -- test read with rs1 on each reg
        for i in 0 to 3 loop
            rs1 <= std_logic_vector(to_unsigned(i, 2));
            wait for clk_period;
            assert rs1_val_out = more_test_values(i)
            report "RS1 register read test failed: reg " & integer'image(i) &
                " expected " & integer'image(to_integer(unsigned(more_test_values(i)))) &
                ", got " & integer'image(to_integer(unsigned(rs1_val_out)))
                severity error;
        end loop;

        -- test read with rs2 on each reg
        for i in 0 to 3 loop
            rs2 <= std_logic_vector(to_unsigned(i, 2));
            wait for clk_period;
            assert rs2_val_out = more_test_values(i)
            report "RS2 register read test failed: reg " & integer'image(i) &
                " expected " & integer'image(to_integer(unsigned(more_test_values(i)))) &
                ", got " & integer'image(to_integer(unsigned(rs2_val_out)))
                severity error;
        end loop;

        report "All register bank tests done!";
        done <= true;
        wait;
    end process;
end testbench;
