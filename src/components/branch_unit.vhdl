library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

entity branch_unit is
    port(
        instruction : in word_type;
        PC_in : in address_type;
        rs1_val : in word_type;
        instr_imm : in signed(11 downto 0);

        branch_taken : out std_logic;
        result : out word_type;
        PC_out : out address_type
    );
end branch_unit;

architecture a1 of branch_unit is
    signal opcode : integer;
    signal rs1_is_zero : std_logic;
    signal PC_plus_imm : signed(11 downto 0);
    signal rs1_plus_imm : signed(11 downto 0);
begin

    opcode <= to_integer(unsigned(instruction(11 downto 8)));
    rs1_is_zero <= '1' when unsigned(rs1_val) = 0 else '0';

    branch_taken <= '1' when (opcode = 12 or opcode = 13) else -- jalr and jal
        rs1_is_zero when opcode = 14 else  -- bz
        not rs1_is_zero when opcode = 15 else -- bnz
        '0';

    -- JAL, BZ, BNZ
    PC_plus_imm <= signed(PC_in) + instr_imm - to_signed(1, 12); -- PC_new = PC_old + imm - 1
    -- LD, SD, JALR
    rs1_plus_imm <= signed(rs1_val) + instr_imm;

    result <= word_type(PC_plus_imm) when opcode>=13 else word_type(rs1_plus_imm);
    PC_out <= PC_in when opcode<12 else
        address_type(rs1_plus_imm) when opcode=12 else -- jalr
        address_type(PC_plus_imm); -- jal, bz, bnz
end a1;

