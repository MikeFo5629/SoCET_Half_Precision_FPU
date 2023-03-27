# SoCET_Half_Precision_FPU
SystemVerilog implementation of half precision floating point unit

Multiplication: 
  - Functional for most numbers I've checked by hand (Including infinities, qNans, and sNans).
  - Partial sub-normal capabilities
    - Subnormal inputs are not fully supported
  - Khoi is writing testbench so that we can finalize module.

Addition: N/A

Subtraction: N/A

Rounding: N/A
