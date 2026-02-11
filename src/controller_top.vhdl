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
            data_addr : out ram_address;
            data_bus : inout ram_data
        );
    end component;

    component dual_port_ram is
        port (
            clk : in std_logic;
            addr_a : in ram_address;
            data_a : out ram_data;
            we_b : in std_logic;
            addr_b : in ram_address;
            data_b : inout ram_data
        );
    end component;

    signal internal_clk : std_logic;
    signal internal_instr_addr : ram_address;
    signal internal_instr_data : ram_data;
    signal internal_data_we : std_logic;
    signal internal_data_addr : ram_address;
    signal internal_data_bus : ram_data;
begin

    processor : processor_top -- generic map(...)
    port map(
        clk => internal_clk,
        instr_addr => internal_instr_addr,
        instr_data => internal_instr_data,
        data_we => internal_data_we,
        data_addr => internal_data_addr,
        data_bus => internal_data_bus);

    ram : dual_port_ram -- generic map(...)
    port map(
        clk => clk,
        addr_a => internal_instr_addr,
        data_a => internal_instr_data,
        we_b => internal_data_we,
        addr_b => internal_data_addr,
        data_b => internal_data_bus);

    process (clk)
    begin
        if rising_edge(clk) then
            -- cnt <= cnt + 1;
        end if;
    end process;

end rtl;
