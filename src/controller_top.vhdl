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
        data_addr_bus : out address_type := (others => '0');
        data_bus : out word_type := (others => '0');
        data_ready : out std_logic := '0'
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
            data_bus : inout word_type;
            data_read_ready : in std_logic
        );
    end component;

    component memory_controller is
        generic (
            init_file : string := ""
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

    signal clk : std_logic; -- stops if halted
    signal instr_addr_bus : address_type;
    signal instr_data_bus : word_type;
    
begin

    processor1 : processor_top
    port map(
        clk => clk,
        reset => reset,
        instr_addr => instr_addr_bus,
        instr_data => instr_data_bus,
        data_we => data_we,
        data_re => data_re,
        data_addr => data_addr_bus,
        data_bus => data_bus,
        data_read_ready => data_ready);

    data_mem : memory_controller
    generic map(
        init_file => data_init_file
    )
    port map(
        clk => clk,
        we => data_we,
        re => data_re,
        addr_in => data_addr_bus,
        data_bus => data_bus,
        ready => data_ready
    );

    instr_mem : memory_controller
    generic map(
        init_file => instr_init_file
    )
    port map(
        clk => clk,
        we => '0',
        re => '1',
        addr_in => instr_addr_bus,
        data_bus => instr_data_bus,
        ready => open -- suppose instant instr memory...
    );

    clk <= clk_in when halt='0' else '0';

    halt_proc : process (clk, reset)
    begin
        if reset = '1' then
            halt <= '0';
        elsif rising_edge(clk) then
            -- HALTING CONDITION : writing x458 at xFFF
            if data_we='1' and data_addr_bus=x"FFF" and data_bus=x"458" then
                halt <= '1';
            end if;
        end if;
    end process;

end rtl;
