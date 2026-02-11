library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

-- r12 cpu
entity alu is
    port (
        clk : in std_logic;
        op : in r12_alu_op;
        a : in unsigned12;
        b : in unsigned12;
        d_out : out unsigned12
    );
end alu;

architecture rtl of alu is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            case op is
                when ALU_ADD =>
                    d_out <= a + b;
                when ALU_SUB =>
                    d_out <= a - b;
                when ALU_MUL =>
                    d_out <= resize(a * b, 12); -- report overflow
                when ALU_AND =>
                    d_out <= a and b;
                when ALU_OR =>
                    d_out <= a or b;
                when ALU_XOR =>
                    d_out <= a xor b;
                when ALU_NOT =>
                    d_out <= not a;
                when ALU_DIV =>
                    if b /= to_unsigned(0, 12) then
                        d_out <= a / b;
                    else
                        d_out <= (others => '1'); -- TODO generate error signal
                    end if;
                when ALU_MOD =>
                    if b /= to_unsigned(0, 12) then
                        d_out <= a mod b;
                    else
                        d_out <= (others => '0');
                    end if;
                when ALU_SLL =>
                    d_out <= shift_left(a, to_integer(b));
                when ALU_SRL =>
                    d_out <= shift_right(a, to_integer(b));
                when others =>
                    null; -- no other operators
            end case;
        end if;
    end process;

end rtl;
