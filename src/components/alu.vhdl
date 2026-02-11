library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

entity alu is
    port (
        clk : in std_logic;
        op : in alu_op_type;
        a : in word_type;
        b : in word_type;
        d_out : out word_type
    );
end alu;

architecture rtl of alu is
begin
    process (clk)
        variable a_u12 : unsigned(11 downto 0);
        variable b_u12 : unsigned(11 downto 0);
        variable out_u12 : unsigned(11 downto 0);
    begin
        if rising_edge(clk) then
            a_u12 := unsigned(a);
            b_u12 := unsigned(b);
            case op is
                when ALU_ADD =>
                    out_u12 := a_u12 + b_u12;
                when ALU_SUB =>
                    out_u12 := a_u12 - b_u12;
                when ALU_MUL =>
                    out_u12 := resize(a_u12 * b_u12, 12); -- report overflow
                when ALU_AND =>
                    out_u12 := a_u12 and b_u12;
                when ALU_OR =>
                    out_u12 := a_u12 or b_u12;
                when ALU_XOR =>
                    out_u12 := a_u12 xor b_u12;
                when ALU_NOT =>
                    out_u12 := not a_u12;
                when ALU_DIV =>
                    if b_u12 /= to_unsigned(0, 12) then
                        out_u12 := a_u12 / b_u12;
                    else
                        out_u12 := (others => '1'); -- TODO generate error signal
                    end if;
                when ALU_MOD =>
                    if b_u12 /= to_unsigned(0, 12) then
                        out_u12 := a_u12 mod b_u12;
                    else
                        out_u12 := (others => '0');
                    end if;
                when ALU_SLL =>
                    out_u12 := shift_left(a_u12, to_integer(b_u12));
                when ALU_SRL =>
                    out_u12 := shift_right(a_u12, to_integer(b_u12));
                when others =>
                    null; -- no other operators
            end case;

            d_out <= std_logic_vector(out_u12);
        end if;
    end process;

end rtl;
