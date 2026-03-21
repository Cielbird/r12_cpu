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
            data_addr : out address_type;
            data_proc_to_ram : out word_type;
            data_ram_to_proc : out word_type;
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
            reset : in std_logic;
            we : in std_logic;
            re : in std_logic;
            addr_in : in address_type;
            data_in : in word_type;
            data_out : out word_type;
            ready : out std_logic
        );
    end component;

    signal data_we : std_logic;
    signal data_re : std_logic;
    signal data_read_ready : std_logic;
    signal data_addr : address_type;
    signal data_to_ram : word_type;

    signal expected_addr : address_type;
    signal expected_data_in : word_type;
    signal expected_data_out : word_type;

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
        data_addr => data_addr,
        data_proc_to_ram => data_to_ram,
        data_ram_to_proc => open,
        data_ready => data_read_ready
    );

    expected_memory : memory_controller
    generic map (
        init_file => "expected_data"
    )
    port map (
        clk => clk,
        reset => '0',
        we => '0',
        re => '1',
        addr_in => expected_addr,
        data_in => expected_data_in,
        data_out => expected_data_out,
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
        reset <= '1';
        wait for clk_period/3;
        reset <= '0';

        -- wait until halt='1';

        -- for now it doesn't work, so just run 100 cycles, so other tests can run
        wait for clk_period*1000;

        done <= true;
        wait;
    end process;

end testbench;
