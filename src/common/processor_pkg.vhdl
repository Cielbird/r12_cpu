library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package processor_pkg is
    subtype unsigned12 is unsigned(11 downto 0);
    type r12_alu_op is (ALU_ADD, ALU_SUB, ALU_MUL, ALU_AND, ALU_OR, ALU_XOR, ALU_NOT, ALU_DIV, ALU_MOD, ALU_SLL, ALU_SRL);

    -- Add other types/constants here
end package processor_pkg;
