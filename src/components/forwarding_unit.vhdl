library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.processor_pkg.all;

entity forwarding_unit is
    port (
        EX_instr_info : in instruction_info;
        MEM_instr_info : in instruction_info;
        WB_instr_info : in instruction_info;
        forward_a_from_mem : out std_logic;
        forward_b_from_mem : out std_logic;
        forward_a_from_wb : out std_logic;
        forward_b_from_wb : out std_logic
    );
end forwarding_unit;

architecture rtl of forwarding_unit is
begin
    forward_a_from_mem <= '1' when EX_instr_info.is_rs1_used = '1' and MEM_instr_info.is_rd_used = '1' and EX_instr_info.rs1 = MEM_instr_info.rd else
        '0';

    forward_b_from_mem <= '1' when EX_instr_info.is_rs2_used = '1' and MEM_instr_info.is_rd_used = '1' and EX_instr_info.rs2 = MEM_instr_info.rd else
        '0';

    forward_a_from_wb <= '1' when EX_instr_info.is_rs1_used = '1' and WB_instr_info.is_rd_used = '1' and EX_instr_info.rs1 = WB_instr_info.rd else
        '0';

    forward_b_from_wb <= '1' when EX_instr_info.is_rs2_used = '1' and WB_instr_info.is_rd_used = '1' and EX_instr_info.rs2 = WB_instr_info.rd else
        '0';
end rtl;
