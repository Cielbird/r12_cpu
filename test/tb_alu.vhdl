library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;

entity tb_alu is
end tb_alu;

architecture testbench of tb_alu is
    -- Clock period
    constant clk_period : time := 10 ns;
    
    -- Signals
    signal clk : std_logic := '0';
    signal op : r12_alu_op := ALU_ADD;
    signal a : unsigned12 := to_unsigned(0, 12);
    signal b : unsigned12 := to_unsigned(0, 12);
    signal d_out : unsigned12;
    
    -- Control signal
    signal done : boolean := false;
    
begin
    -- Instantiate ALU
    uut: entity work.alu
        port map (
            clk => clk,
            op => op,
            a => a,
            b => b,
            d_out => d_out
        );
    
    -- Clock generation
    clk_process: process
    begin
        while not done loop
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    
    -- Test stimulus
    stim_process: process
    begin
        -- Test ALU_ADD
        op <= ALU_ADD;
        a <= to_unsigned(100, 12);
        b <= to_unsigned(50, 12);
        wait for clk_period;
        wait for clk_period;
        assert d_out = to_unsigned(150, 12)
            report "ADD test failed: expected 150, got " & integer'image(to_integer(d_out))
            severity error;
        
        -- Test overflow
        a <= to_unsigned(4095, 12);  -- Max 12-bit value
        b <= to_unsigned(1, 12);
        wait for clk_period;
        wait for clk_period;
        assert d_out = to_unsigned(0, 12)
            report "ADD overflow test failed"
            severity error;
        
        -- Test zero
        a <= to_unsigned(0, 12);
        b <= to_unsigned(0, 12);
        wait for clk_period;
        wait for clk_period;
        assert d_out = to_unsigned(0, 12)
            report "ADD zero test failed"
            severity error;
        
        -- Add more tests for other operations when implemented
        
        report "All tests passed!";
        done <= true;
        wait;
    end process;
    
end testbench;
