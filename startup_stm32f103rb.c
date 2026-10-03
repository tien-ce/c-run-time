#define IVT_ARRAY_SIZE 84 // Interupt vector table size, 84 vector entry, each entry occupies 4 bytes
extern int main(void);

/* symbol defined by the linker script*/
extern unsigned int _stack; // stack pointer
extern unsigned int _idata; // the .data section in flash
extern unsigned int _data;  // the .data section in ram
extern unsigned int _edata; // the end of .data section in ram
extern unsigned int _bss; // the start of .bss section in ram
extern unsigned int _ebss; // the end of .bss section in ram

/* Initilize data for ram by 
 *  Copy value from flash with .data section
 *  Initialize 0 with .bss section
 */
static void initilze_data(void)
{
    /* Get the symbol to memory address defined in link script */
    unsigned int *flash_data_ptr = &_idata;
    unsigned int *ram_data_ptr = &_data;
    unsigned int *ram_bss_ptr = &_bss;
    /* Copy value from flash to ram with .data section */
    while (ram_data_ptr < &_edata)
    {
        *ram_data_ptr++ = *flash_data_ptr++;
    }

    /* Initialize the value of .bss section in ram by filling with 0 */
    while (ram_bss_ptr < &_ebss)
    {
        *ram_bss_ptr++ = 0; 
    }
    
}

void isr_reset(void)
{
    // Initilize data variable
    initilze_data();
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
