library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

-- helper entity for reading instructions
entity instr_logic is
    port (
        instruction : in word_type;
        info : out instruction_info
    );
end instr_logic;

architecture rtl of instr_logic is
    signal instr_11_8 : unsigned(3 downto 0);
begin
    instr_11_8 <= unsigned(instruction(11 downto 8));

    info.opcode <=
    OP_NOP when instruction(11 downto 8) = "0000" and instruction(1 downto 0) = "00" else
    OP_ADD when instruction(11 downto 8) = "0000" and instruction(1 downto 0) = "01" else
    OP_SUB when instruction(11 downto 8) = "0000" and instruction(1 downto 0) = "10" else
    OP_MULT when instruction(11 downto 8) = "0000" and instruction(1 downto 0) = "11" else
    OP_DIV when instruction(11 downto 8) = "0001" and instruction(1 downto 0) = "00" else
    OP_MOD when instruction(11 downto 8) = "0001" and instruction(1 downto 0) = "01" else
    OP_AND when instruction(11 downto 8) = "0001" and instruction(1 downto 0) = "10" else
    OP_OR when instruction(11 downto 8) = "0001" and instruction(1 downto 0) = "11" else
    OP_XOR when instruction(11 downto 8) = "0010" and instruction(1 downto 0) = "00" else
    OP_NOT when instruction(11 downto 8) = "0010" and instruction(1 downto 0) = "11" else
    OP_ADDI when instruction(11 downto 8) = "0011" else
    OP_SUBI when instruction(11 downto 8) = "0100" else
    OP_MULTI when instruction(11 downto 8) = "0101" else
    OP_DIVI when instruction(11 downto 8) = "0110" else
    OP_MODI when instruction(11 downto 8) = "0111" else
    OP_SHLI when instruction(11 downto 8) = "1000" else
    OP_SHRI when instruction(11 downto 8) = "1001" else
    OP_LD when instruction(11 downto 8) = "1010" else
    OP_SD when instruction(11 downto 8) = "1011" else
    OP_JALR when instruction(11 downto 8) = "1100" else
    OP_JAL when instruction(11 downto 8) = "1101" else
    OP_BZ when instruction(11 downto 8) = "1110" else
    OP_BNZ when instruction(11 downto 8) = "1111" else
    OP_NOP;

    info.is_sd <= '1' when info.opcode = OP_SD else
    '0';
    info.is_ld <= '1' when info.opcode = OP_LD else
    '0';
    info.is_bz_or_bnz <= '1' when info.opcode = OP_BZ or info.opcode = OP_BNZ else
    '0';
    info.is_branch <= '1' when info.opcode = OP_JALR or info.opcode = OP_JAL or info.opcode = OP_BZ or info.opcode = OP_BNZ else
    '0';
    info.is_nop <= '1' when info.opcode = OP_NOP else
    '0';
    info.is_rs1_used <= '0' when info.is_nop = '1' or info.opcode = OP_JAL else
    '1';
    info.is_rs2_used <= '1' when (info.is_nop = '0' and instr_11_8 < 3) or info.is_sd = '1' else
    '0';
    info.is_rd_used <= '0' when info.is_sd = '1' or info.is_bz_or_bnz = '1' or info.is_nop = '1' else
    '1';
    info.rs1 <= instruction(7 downto 6) when info.is_bz_or_bnz = '1' else
    instruction(5 downto 4);
    info.rs2 <= instruction(7 downto 6) when info.is_sd = '1' else
    instruction(3 downto 2);
    info.rd <= instruction(7 downto 6);

    info.imm <= signed("000000" & instruction(5 downto 0)) when instr_11_8 > 12 else
    signed("00000000" & instruction(3 downto 0));
end rtl;
