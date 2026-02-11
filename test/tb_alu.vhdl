library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;

entity tb_alu is
end tb_alu;

architecture testbench of tb_alu is
    constant clk_period : time := 10 ns;

    signal clk : std_logic := '0';
    signal op : r12_alu_op := ALU_ADD;
    signal a : unsigned12 := to_unsigned(0, 12);
    signal b : unsigned12 := to_unsigned(0, 12);
    signal d_out : unsigned12;

    signal done : boolean := false;
    
begin
    uut: entity work.alu
        port map (
            clk => clk,
            op => op,
            a => a,
            b => b,
            d_out => d_out
        );
    
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
    
    stim_process: process
        procedure test_case_alu(constant case_op : r12_alu_op;
                                constant case_a : integer;
                                constant case_b : integer;
                                constant case_output : integer) is
        begin
            op <= case_op;
            a <= to_unsigned(case_a, 12);
            b <= to_unsigned(case_b, 12);
            wait for clk_period;
            wait for clk_period;
            assert d_out = to_unsigned(case_output, 12)
                report r12_alu_op'image(op) & " test failed: expected " & integer'image(case_output) & ", got " & integer'image(to_integer(d_out))
                severity error;
        end procedure test_case_alu;
    begin
        -- test ALU_ADD
        test_case_alu(ALU_ADD, 100, 50, 150);
        -- Test ALU_ADD overflow
        test_case_alu(ALU_ADD, 4095, 1, 0);
        -- Test ALU_ADD zero
        test_case_alu(ALU_ADD, 0, 0, 0);

        -- test ALU_SUB
        test_case_alu(ALU_SUB, 100, 20, 80);
        -- overflow
        test_case_alu(ALU_SUB, 0, 1, 4095);
        -- zero
        test_case_alu(ALU_SUB, 0, 0, 0);
        
        -- test ALU_MUL
        test_case_alu(ALU_MUL, 3, 42, 126);
        -- overflow
        test_case_alu(ALU_MUL, 10, 2024, 3856);
        -- zero
        test_case_alu(ALU_MUL, 0, 0, 0);
        
        -- test ALU_AND
        test_case_alu(ALU_AND, 3, 42, 2);
        
        -- test ALU_OR
        test_case_alu(ALU_OR, 3, 42, 43);
        
        -- test ALU_NOT
        test_case_alu(ALU_NOT, 3, 0, 4092); -- b is ignored
        
        -- test ALU_DIV
        test_case_alu(ALU_DIV, 150, 6, 25);
        -- div by 0
        test_case_alu(ALU_DIV, 150, 0, 4095);
        -- with remainder
        test_case_alu(ALU_DIV, 150, 7, 21); -- rounds down
        
        -- test ALU_MOD
        test_case_alu(ALU_MOD, 42, 3, 0);
        -- div by 0
        test_case_alu(ALU_MOD, 42, 0, 0);
        
        -- test ALU_SLL
        test_case_alu(ALU_SLL, 42, 3, 336);
        
        -- test ALU_SRL
        test_case_alu(ALU_SRL, 336, 3, 42);
        
        report "All ALU tests done!";
        done <= true;
        wait;
    end process;
    
end testbench;
