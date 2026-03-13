library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

entity tb_controller is
end tb_controller;

architecture testbench of tb_controller is
    constant clk_period : time := 10 ns;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal halt : std_logic := '0';


    signal done : boolean := false;

    component controller_top is
        generic (
            instr_init_file : string := "";
            data_init_file : string := ""
        );
        port (
            clk_in : in std_logic;
            reset : in std_logic;
            halt : out std_logic;

            data_we : out std_logic;
            data_re : out std_logic;
            data_addr_bus : out address_type;
            data_bus : out word_type;
            data_ready : out std_logic
        );
    end component;

    -- for testing the data result
    component memory_controller is
        generic (
            init_file : string
        );
        port (
            clk : in std_logic;
            we : in std_logic;
            re : in std_logic;
            addr_in : in address_type;
            data_bus : inout word_type;
            ready : out std_logic
        );
    end component;

    signal data_we : std_logic;
    signal data_re : std_logic;
    signal data_read_ready : std_logic;
    signal data_addr : address_type;
    signal data_bus : word_type;

    signal expected_addr : address_type;
    signal expected_data : word_type;

begin
    uut : controller_top
    generic map(
        instr_init_file => "IO_performance",
        data_init_file => "data"
    )
    port map(
        clk_in => clk,
        reset => reset,
        halt => halt,
        data_we => data_we,
        data_re => data_re,
        data_addr_bus => data_addr,
        data_bus => data_bus,
        data_ready => data_read_ready
    );

    expected_memory : memory_controller
    generic map (
        init_file => "expected_data"
    )
    port map (
        clk => clk,
        we => '0',
        re => '1',
        addr_in => expected_addr,
        data_bus => expected_data,
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
    begin

        -- wait until halt='1';

        done <= true;
        wait;
    end process;

end testbench;
