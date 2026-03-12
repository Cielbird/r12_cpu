library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

-- helper entity for reading instructions
entity instr_logic is
    port (
        instruction : in word_type;
        instr_is_sd : out std_logic;
        instr_is_ld : out std_logic;
        instr_bz_or_bnz : out std_logic;
        instr_is_branch : out std_logic; -- 1 if is branching instruction : {bz, bnz, jal, jalr}
        is_nop : out std_logic;
        rs1_used : out std_logic;
        rs2_used : out std_logic;
        rd_used : out std_logic;
        rs1 : out std_logic_vector(1 downto 0);
        rs2 : out std_logic_vector(1 downto 0);
        rd : out std_logic_vector(1 downto 0)
    );
end instr_logic;

architecture rtl of instr_logic is
    signal instr_11_8 : unsigned(3 downto 0);
begin
    instr_11_8 <= unsigned(instruction(11 downto 8));
    instr_is_sd <= '1' when instr_11_8 = 11 else '0';
    instr_is_ld <= '1' when instr_11_8 = 11 else '0';
    instr_bz_or_bnz <= '1' when instr_11_8 = 14 or instr_11_8 = 15 else '0';
    instr_is_branch <= '1' when instr_11_8 >= 12 else '0';
    is_nop <= '1' when instruction(11 downto 8) = "0000" and instruction(1 downto 0) = "00" else '0';
    rs1_used <= '0' when is_nop='1' or instr_11_8=13 else '1';
    rs2_used <= '1' when (is_nop='0' and instr_11_8<3) or instr_is_sd='1' else '0';
    rd_used <= '0' when instr_is_sd='1' or instr_bz_or_bnz='1' or is_nop='1' else '1';
    rs1 <= instruction(7 downto 6) when instr_is_sd='1' else instruction(3 downto 2);
    rs2 <= instruction(7 downto 6) when instr_bz_or_bnz='1' else instruction(5 downto 4);
    rd <= instruction(7 downto 6);
end rtl;


