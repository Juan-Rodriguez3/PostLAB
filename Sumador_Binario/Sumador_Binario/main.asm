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
	;Del 0 al 3 la salida del segundo contador
	;Bit 4 salida del carry del Sumador

	// Configurar Puerto D como salida y que conduzca cero l?gico
	LDI R16, 0xFF
	OUT DDRD, R16		// Seteamos todo el puerto C como salida
	LDI R16, 0x00
	OUT PORTD, R16		//El puerto C conduce cero logico.
	;Del 0 al 3 la salida es el primer contador
	;Del 4 al 7 la salida es el total de la SUMA


	// Guardar estado actual de los botones en R17 y el valor de la salida
	LDI	R17, 0xFF		// 0b11111111
	LDI R18, 0x00		//Salida del primer contador y el carry
	LDI R19, 0x00		//Salida del segundo contador
	LDI	R20, 0x00		//Salida del sumador	

//LOOP
LOOP:
	IN		R16,PINC	//Leer PUERTO D
	CP		R17,R16		//Comparar el estado anterior de los botones con el estado actual.
	BREQ	LOOP		//Si son iguales regresa al inicio.
	CALL	DELAY
	IN		R16,PINC
	CP		R17,R16		//Comparar si realmente se pulso el boton
	BREQ	LOOP		//Si son iguales regresa al inicio.
	MOV		R17, R16	//Actualizar el estado anterior por el actual.
	//Revisamos cual es el botón que se presiono
	SBRS	R16, 0		// salta si el bit 0 esta en set
	CALL	AUTM1		//Aumentar el contador 1
	SBRS	R16, 1		//Salta si el bit 1 esta en set
	CALL	DECM1		//Decrementar el contador 1
	SBRS	R16, 2		// salta si el bit 2 esta en set
	CALL	AUTM2		//Aumentar el contador 2
	SBRS	R16, 3		//Salta si el bit 3 esta en set
	CALL	DECM2		//Decrementar el contador 2
	SBRS	R16, 4		//Salta si el bit 4 esta en set
	CALL	SUMA
	RJMP	LOOP

//Subrutinas
DELAY:
	 LDI	R31, 10
	LOOP_DELAY:
	 DEC	R31
	 CPI	R31, 0
	 BRNE	LOOP_DELAY
	 RET

;R18
AUTM1:
	CBR		R18,	0b11110000  ; Borra los 4 bits massignificativos de R18
	CPI		R18,	0x0F
	BREQ	REINICIO1
	INC		R18
	OUT		PORTD,	R18
	RET
REINICIO1:
	LDI		R18,	0x00
	OUT		PORTD,	R18
	RET

DECM1:
	CBR		R18,	0b11110000  ; Borra los 4 bits massignificativos de R18
	CPI		R18,	0x00
	BREQ	REINICIO2
	DEC		R18
	OUT		PORTD, R18
	RET
REINICIO2:
	LDI		R18,	0X0F
	OUT		PORTD,	R18
	RET

;R19
AUTM2:
	CBR		R19,	0b00010000	; Borra el quinto bit
	CPI		R19,	0x0F
	BREQ	REINICIO3
	INC		R19
	OUT		PORTB,	R19
	RET
REINICIO3:
	LDI		R19,	0x00
	OUT		PORTB,	R19
	RET

DECM2:
	CBR		R19,	0b00010000  ; Borra los 4 bits massignificativos de R18
	CPI		R19,	0x00
	BREQ	REINICIO4
	DEC		R19
	OUT		PORTB, R19
	RET
REINICIO4:
	LDI		R19,	0X0F
	OUT		PORTB,	R19
	RET

;R20
SUMA:
	MOV		R20,	R18
	ADD		R20,	R19
	//Comparar que bits estan encendidos
	SBRC	R20,	0		//Salta si el bit 0 esta clear
	SBR		R18,	(1 << 4)	//Enciende unicamente el bit 4
	SBRC	R20,	1		//Salta si el bit 1 esta clear
	SBR		R18,	(1 << 5)	//Enciende unicamente el bit 5
	SBRC	R20,	2		//Salta si el bit 2 esta clear
	SBR		R18,	(1 << 6)	//Enciende unicamente el bit 6
	SBRC	R20,	3		//Salta si el bit 3 esta clear
	SBR		R18,	(1 << 7)	//Enciende unicamente el bit 7
	SBRC	R20,	4		//Salta si el bit 4 esta clear
	SBR		R19,	(1 << 4)	//Enciende unicamente el bit 4 del puerto B
	OUT		PORTB	R19
	OUT		PORTD	R18
	RET