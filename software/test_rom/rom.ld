MEMORY
{
	code (x)  : ORIGIN = 0, LENGTH = 8K
	data (r)  : ORIGIN = 0, LENGTH = 8K
	reset (x) : ORIGIN = 0, LENGTH = 16
	bss (rw) : ORIGIN = 0, LENGTH = 8K
}
SECTIONS
{
	.text : {
		*(.text)
	} > code
	.data : AT(32K) 
	{
		*(.data)
	} > data
	.reset : AT(0x1FFF0)
	{
		*(.reset)
	} > reset
	.bss (NOLOAD) : {
		*(.bss)
	} > bss
}
