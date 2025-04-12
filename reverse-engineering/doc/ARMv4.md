* RISC [load-store architecture](https://en.wikipedia.org/wiki/Load%E2%80%93store_architecture)
* 32 bit instructions
* 32 bit memory addresses
* 32 bit registers, named R0 through R15
* 

# Registers
[ARM registers](https://developer.arm.com/documentation/dui0473/m/overview-of-the-arm-architecture/arm-registers)

* R0-R12 = general purpose
* R13 = stack pointer (SP)
* R14 = link register (LR)
* R15 = program counter (PC)
* CPSR = Current Program Status Register (similar to EFLAGS in x86)

Additional registers are available in privileged software execution.

Keep in mind that although R0-R12 are general purpose as far as the ISA is concerned, a particular ABI can define a convention when it comes to using them.

# Assembly
## Notation
When an instruction that needs three registers is written with only two, it is a shorthand notation where the first register is also the destination. For example,
```arm
and r0, r1
```
means
```arm
and r0, r0, r1
```

Immediates/constants are denoted with # followed by the numerical value, e.g 
```arm
add r0, r1, #10
```
adds 10 to r1 and stores the result in r0.