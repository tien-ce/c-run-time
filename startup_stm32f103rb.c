#define IVT_ARRAY_SIZE 84 // Interupt vector table size, 84 vector entry, each entry occupies 4 bytes
extern int main(void);
extern unsigned int _stack;
void isr_reset(void)
{
    main();
    while(1); // We should never reach here 
}

// Trigered by mistake when working with startup
void isr_hardfault(void)
{
    while(1);
}

// Define the type for interupt handler (pointer to handler function) 
typedef void (*isr_t)(void);

// By default, the compiler places constant global arrays into standard read-only data section (.rodata) or .text
// But we want to leave the ivt into the start of flash memory (0x0800 0000)
/* section(".ivt") instrcuts gcc to place this specific variable into an elf section explicity named .ivt,
this allow linker script(.ld) to match that name and fix it's memory addres right at the start of flash
*/
/* used: Nobody explicitly calls or refernces ivt by name inside main or other functions. It's only read directly by CPU hardware logic on boot
 * Under optimazations flags (such as -O2,-O3 or -flto), the compiler would detect this array as unused and strip it out of output object file (.o)
 * The used attribute tells GCC: "Even if no software referneces to this symbol in code, keep it in object file anyway.
 * */
__attribute((used, section(".ivt")))
// Define interupt vector table, each entry contain the pointer to handler function, or same specific address
static const isr_t ivt[IVT_ARRAY_SIZE] =
{
    (isr_t) &_stack,  // The top of stack address (Descending stack : high address -> low address)
    (isr_t) isr_reset,  // Rest handler
    (isr_t) 0,  // Non-maskable interupt (NMI), the interupt that software can't ignore, mask, or disable under normal operating conditions
    (isr_t) isr_hardfault,  // hard fault handler
    // Incomplete table (only for demo)!
    // The rest of ISRs defaults to value 0. Common pratice is to give these default handler and atrribute them weak.
};
