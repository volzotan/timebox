The UDC3 must be able to perform analogRead on one of the analog in pins of the SAMD21 (AIN6) for the voltage divider.
These pins are not directly supported in the board configuration of the Arduino Zero.

source: https://forum.arduino.cc/index.php?topic=363393.0

Changes required:

	/Users/volzotan/Library/Arduino15/packages/arduino/hardware/samd/1.8.3/variants/arduino_zero/variant.h 

		change:

		// #define NUM_ANALOG_INPUTS    (6u)

		#define NUM_ANALOG_INPUTS    (8u)

		add:

		#define PIN_A6               (8ul)
		#define PIN_A7               (9ul)

		static const uint8_t A6  = PIN_A6;
		static const uint8_t A7  = PIN_A7;


	/Users/volzotan/Library/Arduino15/packages/arduino/hardware/samd/1.8.3/variants/arduino_zero/variant.cpp 

		change:

		// { PORTA,  6, PIO_TIMER, (PIN_ATTR_DIGITAL|PIN_ATTR_PWM|PIN_ATTR_TIMER), No_ADC_Channel, PWM1_CH0, TCC1_CH0, EXTERNAL_INT_6 }, // TCC1/WO[0]
		// { PORTA,  7, PIO_TIMER, (PIN_ATTR_DIGITAL|PIN_ATTR_PWM|PIN_ATTR_TIMER), No_ADC_Channel, PWM1_CH1, TCC1_CH1, EXTERNAL_INT_7 }, // TCC1/WO[1]
		  
		{ PORTA,  6, PIO_TIMER, (PIN_ATTR_DIGITAL|PIN_ATTR_PWM|PIN_ATTR_TIMER|PIN_ATTR_ANALOG), ADC_Channel6, PWM1_CH0, TCC1_CH0, EXTERNAL_INT_6 }, // TCC1/WO[0]
		{ PORTA,  7, PIO_TIMER, (PIN_ATTR_DIGITAL|PIN_ATTR_PWM|PIN_ATTR_TIMER|PIN_ATTR_ANALOG), ADC_Channel7, PWM1_CH1, TCC1_CH1, EXTERNAL_INT_7 }, // TCC1/WO[1]


	/Users/volzotan/Library/Arduino15/packages/arduino/hardware/samd/1.8.3/cores/arduino/wiring_analog.c

		change:

		  // if (pin < A0) {
		  //   pin += A0;
		  // }

		  if ( pin <= 5 ) // turn '0' -> 'A0'
		  {
		    pin += A0 ;
		  }
		  if (pin == 6) pin = PIN_A6;
		  if (pin == 7) pin = PIN_A7;