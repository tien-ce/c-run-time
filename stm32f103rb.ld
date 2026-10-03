/* Memory layout */
MEMORY
{
    /* r: readable, w: writable, x: executable. Flash holds instructions and constants. */
    /* Flash memory starts at 0x08000000 */
    flash (rx)  : ORIGIN = 0x08000000, LENGTH = 129K

    /* SRAM memory starts at 0x20000000 */
    ram   (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}
/*
 * Calculate the end address of physical RAM (ORIGIN + LENGTH).
 * This defines a symbol (address label) in the linker symbol table
 * that consumes 0 bytes of storage, typically used as the initial 
 * Main Stack Pointer (_estack) for full descending stacks.
 */
_eram = ORIGIN(ram) + LENGTH(ram); /* The end of ram */
_stack = _eram; /* Stack starts at end of RAM and grows downwards */

/* The SECTIONS directive is the core isntrcution block of a linker script.
 * It tells the linker how to map input sections (produced by the compiler in individual .o file) into output sections
 * and where place them in physical memory (flash or RAM) */
SECTIONS
{
    /* rounds the current memory addrsess (the location counter .) up to next multiple of 4 bytes (32 bits word alignment)
     * if . = 0x01-> set . to 0x04*/
    /* 1. outer .text (output section): This is the name of combined section that will exist in the final generated .elf binay and get loaded into flash memory
     * 2. inner *(.text*) (input partern): This is a wildcard matching rule that instructs the linker how to aggregate object files:
     *    2.1: The first * (File Wildcard): Matches all linked .o object files (e.g., main.o, startup.o, standard library files).
     *    2.2: (.text*) (Section Wildcard): Inside parentheses is the section name pattern inside those .o files.*/
    .text : ALIGN(4)
    /* Place text section at the stat of flash memory */
    {
        KEEP(*(.ivt))   /* Keeps vector table at the beginning of flash */
        *(.text*)       /* Code instructions follow right after */
        /* e_text marks the end of text section also the start address of initialized data (.data)
         * placing . = ALIGN(4); right before _etext = .; is to ensure that the address assigned to _etext is a multiple of 4 (word-aligned).
         * */
        . = ALIGN(4);
        _etext = .;
    } > flash

    _idata = LOADADDR(.data); /* Initilize data is placed in flash after the program code */
    .data : ALIGN(4) /* Declear the .data output section, start of the section aligned to 4*/
    {
        /* Mark the starting RAM address (VMA) of .data */
        _data = .; 

        /* Pull all .data sections from all input object files */
        *(.data*)
        /* Ensure end address aligns to 4-byte boundary */
        . = ALIGN(4);
        /* End of ending RAM address (VMA) of .data*/
        _edata = .;
    } > ram AT > flash  /* Execution in RAM (VMA), storage in Flash (LMA) */

    .bss : ALIGN(4)
    {
        _bss = .;
        *(.bss*)
        . = ALIGN(4);
        _ebss = .;
        PROVIDE(_end = .);
    } > ram
}
