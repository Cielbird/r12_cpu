library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

entity register_bank is
    port (
        clk : in std_logic;
        op : in instr_op_type;
        a : in word_type;
        b : in word_type;
        d_out : out word_type
    );
end register_bank;

architecture rtl of register_bank is
begin
    -- ...
end rtl;
