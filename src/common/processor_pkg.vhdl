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

    -- function data_to_instr_op (instruction : word_type) return instr_op_type;
    -- function instr_op_to_alu_op (instruction_op : instr_op_type) return alu_op_type;

end package processor_pkg;

package body processor_pkg is
    -- function data_to_instr_op (instruction : ram_data) return instr_op_type is
    -- begin
    --     case to_integer(unsigned(instruction(11 downto 8))) is
    --         when 0 =>
    --             case instruction(1 downto 0) is
    --                 when "00" => return NOP;
    --                 when "01" => return ADD_OP;
    --                 when "10" => return SUB_OP;
    --                 when "11" => return MULT_OP;
    --                 when others => null; -- unreachable
    --             end case;
    --         when 1 =>
    --             case instruction(1 downto 0) is
    --                 when "00" => return DIV_OP;
    --                 when "01" => return MOD_OP;
    --                 when "10" => return AND_OP;
    --                 when "11" => return OR_OP;
    --                 when others => null; -- unreachable
    --             end case;
    --         when 2 =>
    --             case instruction(1 downto 0) is
    --                 when "00" => return XOR_OP;
    --                 when "11" => return NOT_OP;
    --                 when others => null; -- others are undefined
    --             end case;
    --         when 3 => return ADDI_OP;
    --         when 4 => return SUBI_OP;
    --         when 5 => return MULTI_OP;
    --         when 6 => return DIVI_OP;
    --         when 7 => return MODI_OP;
    --         when 8 => return SHLI_OP;
    --         when 9 => return SLRI_OP;
    --         when 10 => return LD_OP;
    --         when 11 => return SD_OP;
    --         when 12 => return JALR_OP;
    --         when 13 => return JAL_OP;
    --         when 14 => return BZ_OP;
    --         when 15 => return BNZ_OP;
    --         when others => null; -- unreachable
    --     end case;
    -- end function data_to_instr_op;

    -- function instr_op_to_alu_op (instruction_op : instr_op_type) return alu_op_type is
    -- begin
    --     case instruction_op is
    --         when ADD_OP => return ALU_ADD;
    --         when SUB_OP => return ALU_SUB;
    --         when MULT_OP => return ALU_MUL;
    --         when AND_OP => return ALU_AND;
    --         when OR_OP => return ALU_OR;
    --         when XOR_OP => return ALU_XOR;
    --         when NOT_OP => return ALU_NOT;
    --         when DIV_OP => return ALU_DIV;
    --         when MOD_OP => return ALU_MOD;
    --         when SHLI_OP => return ALU_SLL;
    --         when SLRI_OP => return ALU_SRL;
    --         when others => return ALU_ADD; -- add by default
    --     end case;
    -- end function instr_op_to_alu_op;
end package body;
