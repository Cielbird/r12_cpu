library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

entity register_bank is
    port (
        clk : in std_logic;

        rs1 : in std_logic_vector(1 downto 0);
        rs2 : in std_logic_vector(1 downto 0);
        rs1_val_out : out word_type;
        rs2_val_out : out word_type;

        we : in std_logic;
        rd : in std_logic_vector(1 downto 0);
        rd_val_in : in word_type
    );
end register_bank;

architecture rtl of register_bank is
    -- 4 registers
    signal reg0 : word_type := (others => '0');
    signal reg1 : word_type := (others => '0');
    signal reg2 : word_type := (others => '0');
    signal reg3 : word_type := (others => '0');
begin

    rs1_val_out <=
        reg0 when rs1 = "00" else
        reg1 when rs1 = "01" else
        reg2 when rs1 = "10" else
        reg3 when rs1 = "11";

    rs2_val_out <=
        reg0 when rs2 = "00" else
        reg1 when rs2 = "01" else
        reg2 when rs2 = "10" else
        reg3 when rs2 = "11";

    process (clk)
    begin
        if rising_edge(clk) and we = '1' then
            case rd is
                when "00" => reg0 <= rd_val_in;
                when "01" => reg1 <= rd_val_in;
                when "10" => reg2 <= rd_val_in;
                when "11" => reg3 <= rd_val_in;
                when others => null; -- unreachable
            end case;
        end if;
    end process;

end rtl;
