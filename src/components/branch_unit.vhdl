library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

entity branch_unit is
    port(
        instruction : in word_type;
        PC_in : in word_type;
        A : in word_type;

        branch_taken : out std_logic;
        result : out word_type;
        PC_out : out word_type
    );
end branch_unit;

