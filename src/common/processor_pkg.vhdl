library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package processor_pkg is
    constant ADDR_WIDTH : integer := 12; -- 4096 words (12-bit addresses)
    constant DATA_WIDTH : integer := 12; -- 12-bit data

    subtype address_type is unsigned(11 downto 0); -- 12 bit addresses
    subtype word_type is std_logic_vector(11 downto 0); -- word here is 12 bits

    type instruction_code is (
        OP_NOP,
        OP_ADD,
        OP_SUB,
        OP_MULT,
        OP_DIV,
        OP_MOD,
        OP_AND,
        OP_OR,
        OP_XOR,
        OP_NOT,
        OP_ADDI,
        OP_SUBI,
        OP_MULTI,
        OP_DIVI,
        OP_MODI,
        OP_SHLI,
        OP_SHRI,
        OP_LD,
        OP_SD,
        OP_JALR,
        OP_JAL,
        OP_BZ,
        OP_BNZ
    );

    -- signed when possible
    type alu_op_type is (
        ALU_ADD,
        ALU_SUB,
        ALU_MUL,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_NOT,
        ALU_DIV,
        ALU_MOD,
        ALU_SLL,
        ALU_SRL
    );

    type instruction_info is record
        opcode : instruction_code;
        is_sd : std_logic;
        is_ld : std_logic;
        is_bz_or_bnz : std_logic;
        is_branch : std_logic; -- 1 if is branching instruction : {bz, bnz, jal, jalr}
        is_nop : std_logic;
        is_rs1_used : std_logic;
        is_rs2_used : std_logic;
        is_rd_used : std_logic;
        rs1 : std_logic_vector(1 downto 0); -- register address
        rs2 : std_logic_vector(1 downto 0); -- register address
        rd : std_logic_vector(1 downto 0); -- register address
        imm : signed(11 downto 0);
    end record instruction_info;

    -- pour resetter les registres
    constant NOP_INSTR_INFO : instruction_info := (
        opcode => OP_NOP,
        is_sd => '0',
        is_ld => '0',
        is_bz_or_bnz => '0',
        is_branch => '0',
        is_nop => '0',
        is_rs1_used => '0',
        is_rs2_used => '0',
        is_rd_used => '0',
        rs1 => (others => '0'),
        rs2 => (others => '0'),
        rd => (others => '0'),
        imm => (others => '0')
    );

    function to_word(s: std_logic_vector) return word_type;
    function to_address(i: integer) return address_type;
end package processor_pkg;

package body processor_pkg is
    
    function to_word(s : std_logic_vector) return word_type is
    begin
        return word_type(s);
    end function;

    function to_address(i : integer) return address_type is
    begin
        return address_type(to_unsigned(i, 12));
    end function;
end package body;
