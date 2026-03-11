library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;
use work.ram_pkg.all;

-- controller : cpu + ram + peripherals
entity controller_top is
    port (
        clk : in std_logic
    );
end controller_top;

architecture rtl of controller_top is
    component processor_top is
        port (
            clk : in std_logic;
            instr_addr : out ram_address;
            instr_data : in ram_data;
            data_we : out std_logic;
            data_re : out std_logic;
            data_addr : out ram_address;
            data_bus : inout ram_data
        );
    end component;

    component memory_controller is
        port (
            clk : in std_logic;
            we : in std_logic;
            re : in std_logic;
            addr_in : in ram_address;
            data_bus : inout ram_data;
            ready : out std_logic
        );
    end component;

    signal instr_addr_bus : ram_address;
    signal instr_data_bus : ram_data;
    signal data_we : std_logic;
    signal data_re : std_logic;
    signal data_addr_bus : ram_address;
    signal data_bus : ram_data;
    signal data_ready : std_logic;
begin

    processor1 : processor_top
    port map(
        clk => clk,
        instr_addr => instr_addr_bus,
        instr_data => instr_data_bus,
        data_we => data_we,
        data_re => data_re,
        data_addr => data_addr_bus,
        data_bus => data_bus);

    instr_mem : memory_controller
    port map(
        clk => clk,
        we => data_we,
        re => data_re,
        addr_in => data_addr_bus,
        data_bus => data_bus,
        ready => data_ready);


    data_mem : memory_controller
    port map(
        clk => clk,
        we => '1',
        re => '0',
        addr_in => instr_addr_bus,
        data_bus => instr_data_bus,
        ready => open); -- suppose instant instr memory...



    process (clk)
    begin
        if rising_edge(clk) then
            -- cnt <= cnt + 1;
        end if;
    end process;

end rtl;
