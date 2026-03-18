library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

entity tb_memory is
end tb_memory;

architecture testbench of tb_memory is
    constant clk_period : time := 10 ns;

    signal clk : std_logic := '0';

    signal done : boolean := false;
    
    component memory_controller is
        generic (
            init_file : string
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            we : in std_logic;
            re : in std_logic;
            addr_in : in address_type;
            data_in : in word_type;
            data_out : out word_type;
            ready : out std_logic
        );
    end component;

    signal data_addr : address_type;
    signal data_out : word_type;

begin
    uut : memory_controller
    generic map (
        init_file => "data"
    )
    port map (
        clk => clk,
        reset => '0',
        we => '0',
        re => '1',
        addr_in => data_addr,
        data_in => x"000",
        data_out => data_out,
        ready => open -- suppose instant read
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
        variable expected : word_type;
    begin

        data_addr <= to_address(0);
        wait for clk_period;
        expected := to_word(x"000");

        if data_out /= expected then
            report "Failed test : got=" & to_hstring(data_out) & " expected=" & to_hstring(expected)
                severity error;
        end if;

        report "All memory tests done !"
            severity note;
        done <= true;
        wait;
    end process;

end testbench;
