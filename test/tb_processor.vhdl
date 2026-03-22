library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;
use work.ram_pkg.all;

entity tb_processor is
end tb_processor;

architecture testbench of tb_processor is
    constant clk_period : time := 10 ns;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal halt : std_logic := '0';

    signal done : boolean := false;

    component processor_top is
        port (
            clk : in std_logic;
            reset : in std_logic;
            instr_addr : out address_type := (others => '0');
            instr_data : in word_type;
            data_we : out std_logic := '0';
            data_re : out std_logic := '0';
            data_addr : out address_type := (others => '0');
            data_in : in word_type;
            data_out : out word_type := (others => '0');
            data_read_ready : in std_logic
        );
    end component;

    signal instr_addr : address_type;
    signal instr_data : word_type;
    signal data_we : std_logic;
    signal data_re : std_logic;
    signal data_read_ready : std_logic;
    signal data_addr : address_type;
    signal data_proc_to_ram : word_type;
    signal data_ram_to_proc : word_type;


    signal instr_mem : memory_type := init_memory_from_file("IO_performance");
    signal data_mem : memory_type := init_memory_from_file("data");
    signal expected_data_mem : memory_type := init_memory_from_file("expected_data");

begin
    uut : processor_top
    port map(
        clk => clk,
        reset => reset,
        instr_addr => instr_addr,
        instr_data => instr_data,
        data_we => data_we,
        data_re => data_re,
        data_addr => data_addr,
        data_in => data_ram_to_proc,
        data_out => data_proc_to_ram,
        data_read_ready => data_read_ready
    );

    -- just copying ram's internals : instruction memory
    instr_mem_process : process(reset, instr_addr)
    begin
        if reset='1' then
            instr_data <= to_word(x"000");
        else -- reading is 0-tick, async
            instr_data <= instr_mem(to_integer(unsigned(instr_addr)));
        end if;
    end process;

    -- just copying ram's internals : data memory
    data_mem_process : process (clk, reset, data_we, data_proc_to_ram)
    begin
        data_read_ready <= '1';
        if reset='1' then
            data_ram_to_proc <= to_word(x"000");
        else
            if rising_edge(clk) then
                if data_we = '1' then
                    data_mem(to_integer(unsigned(data_addr))) <= data_proc_to_ram; -- adresses are word-space
                end if;
            end if;
            if data_re = '1' then
                data_ram_to_proc <= data_mem(to_integer(unsigned(data_addr)));
            end if;
        end if;
    end process;

    clk_process : process
    begin
        if reset='1' then
            halt <= '0';
        end if;
        while not done loop
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
            if data_we='1' and data_addr=x"FFF" and data_proc_to_ram=x"458" then
                halt <= '1';
            end if;
        end loop;
        wait;
    end process;

    stim_process : process
    begin
        reset <= '1';
        wait for clk_period/3;
        reset <= '0';

        wait until halt='1';

        done <= true;
        
        if expected_data_mem /= data_mem then
            report "Failed processor test !" severity error;
        else
            report "Processor test passed !" severity note;
        end if;

        wait;
    end process;

end testbench;
