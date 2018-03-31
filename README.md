# MASM AddThree macro
MASM 4.0 macro command for obtaining a sum of 3 arguments.
The key moment is that this macro tries to generate the most optimal code
for each possible combination of given arguments (see `gencode` macro on line 387).

**Note:** since this assembler version is available only in early real-mode MS-DOS
and also makes use of special macros written by CMC programmers (lost `io.asm`),
any attempt to revive this monster will surely fail. So it's here for inspirational
purposes only :D
