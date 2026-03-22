# r12 cpu

A 12-bit processor written in VHDL. With pipelining, and forwarding.

## r12 assembler

See this for a link to the assembler

https://github.com/Cielbird/GIF-3000-R12

## testing

[ghdl](https://github.com/ghdl/ghdl), make, and bash scripts used for testing.

run all tests :
`make test`

view output with [gtkwave](https://github.com/gtkwave/gtkwave). 
alu test, for example:
`gtkwave ./build/tb_alu_wave.vcd`
