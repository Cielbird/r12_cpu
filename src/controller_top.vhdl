library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;
use work.ram_pkg.all;

-- controller : cpu + ram + peripherals
entity controller_top is
    generic (
        instr_init_file : string := "";
        data_init_file : string := ""
    );
    port (
        clk_in : in std_logic;
        reset : in std_logic;
        halt : out std_logic := '0';

        -- Data bus access (to know what's happening inside...)
        data_we : out std_logic := '0';
        data_re : out std_logic := '0';
        data_addr : out address_type := (others => '0');
        data_proc_to_ram : out word_type := (others => '0');
        data_ram_to_proc : out word_type := (others => '0');
        data_ready : out std_logic := '0';

        clk_counter_dbg : out unsigned(11 downto 0)
    );
end controller_top;

architecture rtl of controller_top is
    component processor_top is
        port (
            clk : in std_logic;
            reset : in std_logic;
            instr_addr : out address_type;
            instr_data : in word_type;
            data_we : out std_logic;
            data_re : out std_logic;
            data_addr : out address_type;
            data_in : in word_type;
            data_out : out word_type;
            data_read_ready : in std_logic
        );
    end component;

    component memory_controller is
        generic (
            init_file : string := ""
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

    signal clk : std_logic; -- stops if halted
    signal data_proc_to_ram_signal : word_type;
    signal data_ram_to_proc_signal : word_type;
    signal instr_addr : address_type;
    signal instr_data : word_type;
    
begin

    processor1 : processor_top
    port map(
        clk => clk,
        reset => reset,
        instr_addr => instr_addr,
        instr_data => instr_data,
        data_we => data_we,
        data_re => data_re,
        data_addr => data_addr,
        data_in => data_ram_to_proc_signal,
        data_out => data_proc_to_ram_signal,
        data_read_ready => data_ready);

    data_mem : memory_controller
    generic map(
        init_file => data_init_file
    )
    port map(
        clk => clk,
        reset => reset,
        we => data_we,
        re => data_re,
        addr_in => data_addr,
        data_in => data_proc_to_ram_signal,
        data_out => data_ram_to_proc_signal,
        ready => data_ready
    );

    instr_mem : memory_controller
    generic map(
        init_file => instr_init_file
    )
    port map(
        clk => clk,
        reset => reset,
        we => '0',
        re => '1',
        addr_in => instr_addr,
        data_in => to_word(x"000"),
        data_out => instr_data,
        ready => open -- suppose instant instr memory...
    );

    clk <= clk_in when halt='0' else '0';
    data_proc_to_ram <= data_proc_to_ram_signal;
    data_ram_to_proc <= data_ram_to_proc_signal;

    halt_proc : process (clk, reset)
    begin
        if reset = '1' then
            halt <= '0';
            clk_counter_dbg <= (others => '0');
        elsif rising_edge(clk) then
            clk_counter_dbg <= clk_counter_dbg + to_unsigned(1, 12);
            -- HALTING CONDITION : writing x458 at xFFF
            if data_we='1' and data_addr=x"FFF" and data_proc_to_ram_signal=x"458" then
                halt <= '1';
            end if;
        end if;
    end process;

end rtl;
