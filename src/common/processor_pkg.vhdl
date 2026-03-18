library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package processor_pkg is
    constant ADDR_WIDTH : integer := 12; -- 4096 words (12-bit addresses)
    constant DATA_WIDTH : integer := 12; -- 12-bit data

    subtype address_type is unsigned(11 downto 0); -- 12 bit addresses
    subtype word_type is std_logic_vector(11 downto 0); -- word here is 12 bits

    type proc_state is (
        PROC_IF, -- instruction fetch
        PROC_ID, -- instruction decode
        PROC_EX, -- execute
        PROC_MEM, -- memory access
        PROC_WB -- write-back
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
