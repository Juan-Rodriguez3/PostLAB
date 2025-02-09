;***************************************************************
; Universidad del Valle de Guatemala
; IE2025: Programación de Microcontroladores
;
; Author: Juan Rodríguez
; Proyecto: Post-Lab I
; Hardware: ATmega328P
; Creado: 09/02/2025
; Modificado: 09/02/2025
; Descripción: Este programa consiste un sumador de 4 bits de dos contadores de 4 bits.
;***************************************************************
.include "M328PDEF.inc"

.cseg
.org 0x0000

//Configuraci?n de pila //0x08FF
LDI		R16, LOW(RAMEND)	// Cargar 0xFF a R16
OUT		SPL, R16			// Cargar 0xFF a SPL
LDI		R16, HIGH(RAMEND)	
OUT		SPH, R16			// Cargar 0x08 a SPH


// Configuracion de MCU
SETUP:
	//Configurar el Prescaler
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16		// Habilitar cambio de PRESCALER
	LDI R16, 0b00000100
	STS CLKPR, R16		//Prescaler con 1MHz

	// DDRx, PORTx y PINx
	// Configurar Puerto C como entrada con pull-ups habilitados
	LDI R16, 0x00
	OUT DDRC,R16		// Seteamos todo el puerto D como entrada
	LDI R16, 0xFF		
	OUT PORTC, R16		//Habilitamos los pull-ups

	// Configurar Puerto B como salida y que conduzca cero l?gico
	LDI R16, 0xFF
	OUT DDRB, R16		// Seteamos todo el puerto B como salida
	LDI R16, 0x00
	OUT PORTB, R16		//El puerto B conduce cero logico.

	// Configurar Puerto D como salida y que conduzca cero l?gico
	LDI R16, 0xFF
	OUT DDRD, R16		// Seteamos todo el puerto C como salida
	LDI R16, 0x00
	OUT PORTD, R16		//El puerto C conduce cero logico.

	// Guardar estado actual de los botones en R17 y el valor de la salida
	LDI	R17, 0xFF		// 0b11111111
	LDI R18, 0x00		//Salida del primer contador
	LDI R19, 0x00		//Salida del segundo contador
	

//LOOP
LOOP:
	IN		R16,PIND	//Leer PUERTO D
	CP		R17,R16		//Comparar el estado anterior de los botones con el estado actual.
	BREQ	LOOP		//Si son iguales regresa al inicio.

DELAY:
	LDI		R20, 0
SUBDELAY1:
	INC		R20
	CPI		R20,0
	BRNE	SUBDELAY1
	LDI		R20, 0
SUBDELAY2:
	INC		R20
	CPI		R20,0
	BRNE	SUBDELAY2
	RET