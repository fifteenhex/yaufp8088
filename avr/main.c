#define F_CPU 8000000ULL

#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	PORTB |= (_BV(PB1) | _BV(PB2));
	DDRB  |= (_BV(PB1) | _BV(PB2));

	/* Release 8088 reset */
	_delay_ms(500);
	PORTB &= ~_BV(PB2);

	while(1) {
		PORTB |=  _BV(PB1);
		_delay_ms(500);
		PORTB &= ~_BV(PB1);
		_delay_ms(500);
	}

	return 0;
}
