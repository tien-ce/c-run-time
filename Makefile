#Bare metal toolchain targeting ARM architectures without and OS
CC = arm-none-eabi-gcc 
OBJDUMP = arm-none-eabi-objdump 
DUMPOUT = main_dump

# Target architecture flags
# -mcpu=cortex-m3 : Targets the ARM Cortex-M3 microarchitecture and its instruction scheduling
# -mthumb         : Emits Thumb/Thumb-2 instruction set code 
ARCH_FLAGS = -mcpu=cortex-m3 -mthumb
# Language and debug flags
# -std=c11 : Enforces the ISO C11 language standard
# -g       : Emits native DWARF debug symbols for GDB inspection
# -O0      : Disables compiler optimizations so variables map directly to memory during debugging
DEBUG_FLAGS = -std=c11 -g -O0

#Combine
C_FLAGS = $(ARCH_FLAGS) $(DEBUG_FLAGS)

# Link flag
# -nolibc: Prevents GCC from linking against standard C runtime libs
# -nostartfiles: Tells the linker not to use the standard system startup files (crt0.o, crti.o)
# -T name.ld Directs the linker to use the custom linker named name.ld
# -Wl, tell gcc don't process this flag yourself, forward everything after comma directly to the linker (arm-none-eabi-ld_
#  --verbose: Instructs the linker to ouput detailed trace information during execution
LD_FLAGS = $(ARCH_FLAGS) -nolibc -nostartfiles -T stm32f103rb.ld -Wl,--verbose

SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)
ELF = main.elf

# File definitions
.PHONY: all o elf clean dump
all: o elf dump
# Compile source code to object file
o: $(OBJ)

# Pattern rule: each .c file maps strictly to its own corresponding .o file
%.o: %.c
	$(CC) $(C_FLAGS) -c $< -o $@

elf: $(ELF)

$(ELF): $(OBJ)
	echo $(OBJ)
	$(CC) $(LD_FLAGS) $^ -o $@

dump: $(ELF)
	$(OBJDUMP) $(ELF) -D > $(DUMPOUT)

clean:
	rm -f $(OBJ) $(ELF) $(DUMPOUT)
