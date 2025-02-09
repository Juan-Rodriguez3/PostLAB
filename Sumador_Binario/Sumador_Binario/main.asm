;***************************************************************
; Universidad del Valle de Guatemala
; IE2025: Programaci?n de Microcontroladores
;
; Author: Juan Rodr?guez
; Proyecto: Prelab I
; Hardware: ATmega328P
; Creado: 06/02/2025
; Modificado: 06/02/2025
; Descripci?n: Este programa consiste en un contador binario de 4 bits. 
;***************************************************************
.include "M328PDEF.inc"

.cseg
.org 0x0000

//Configuraci?n de pila //0x08FF
LDI		R16, LOW(RAMEND)	// Cargar 0xFF a R16
OUT		SPL, R16			// Cargar 0xFF a SPL
LDI		R16, HIGH(RAMEND)	
OUT		SPH, R16			// Cargar 0x08 a SPH


// Configuraci?n de MCU
SETUP:
	// DDRx, PORTx y PINx
	// Configurar Puerto D como entrada de pull-ups habilitados
	LDI R16, 0x00
	OUT DDRD,R16		// Seteamos todo el puerto D como entrada
	LDI R16, 0xFF		
	OUT PORTD, R16		//Habilitamos los pull-ups

	// Configurar Puerto B como salida y que conduzca cero l?gico
	LDI R16, 0xFF
	OUT DDRB, R16		// Seteamos todo el puerto B como salida
	LDI R16, 0x00
	OUT PORTB, R16		//El puerto B conduce cero l?gico.

	// Configurar Puerto C como salida y que conduzca cero l?gico
	LDI R16, 0xFF
	OUT DDRC, R16		// Seteamos todo el puerto C como salida
	LDI R16, 0x00
	OUT PORTC, R16		//El puerto C conduce cero l?gico.

	// Guardar estado actual de los botones en R17 y el valor de la salida
	LDI	R17, 0xFF		// 0b11111111
	LDI R18, 0x00		//Salida del primer contador
	LDI R19, 0x00		//Salida del segundo contador
	

//LOOP
LOOP:
	IN		R16,PIND	//Leer PUERTO D
	CP		R17,R16		//Comparar el estado anterior de los botones con el estado actual.
	BREQ	LOOP		//Si son iguales regresa al inicio.
	//Agregar el delay
	CALL	DELAY
LECTURA2:
	//Volver a leer para ver si fue botonazo.
	IN		R16, PIND	// Releer PUERTO D. para detectar si fue botonazo.
	CP		R17, R16	//Comparar el estado anterior con el actual.
	BREQ	LOOP
	//Actualizar el estado
	MOV		R17, R16
	//Salta si es 0
	CALL	Contador1
	CALL	Contador2
	RJMP	LOOP

//Subrutinas
Contador1:
	SBRS	R16,2		//Revisando si el bit 2 no "esta apachado" = 1 l?gico.
	CALL	incrementar1	//El bit 2 esta apachado Boton Azul
	SBRS	R16,3		//Revisando si el bit 3 no esta "apachado" = 1 l?gico.
	CALL	decrementar1	//El bit 3 esta apachado Boton Verde
	RET

Contador2:
	SBRS	R16,4		//Revisando si el bit 2 no "esta apachado" = 1 l?gico.
	CALL	incrementar2	//El bit 2 esta apachado Boton Azul
	SBRS	R16,5		//Revisando si el bit 3 no esta "apachado" = 1 l?gico.
	CALL	decrementar2	//El bit 3 esta apachado Boton Verde
	RET

//Contador 1
incrementar1:
	INC		R18			//Incrementar valor
	CPI		R18, 0x10	//Comparar para ver si ocurre un acarreo.
	BREQ	Reinicio1	//Reiniciar si hay overflow
RETURNI1:
	OUT		PORTB, R18  //Actualizar salida
	RET	
Reinicio1:
	LDI		R18, 0x00	//Reiniciar conteo
	RJMP	RETURNI1

decrementar1: 
	CPI		R18, 0x00	//Comparar para ver si ocurre un acarreo.
	BREQ	Reinicio2	//Reiniciar si hay overflow
	DEC		R18			//Decrementar valor
RETURND1:
	OUT		PORTB, R18	//Actualizar salida
	RET
Reinicio2:
	LDI		R18, 0x0F	//Reiniciar conteo
	RJMP	RETURND1

//Contador 2
incrementar2:
	INC		R19			//Incrementar valor
	CPI		R19, 0x10	//Comparar para ver si ocurre un acarreo.
	BREQ	Reinicio3	//Reiniciar si hay overflow
RETURNI2:
	OUT		PORTC, R19  //Actualizar salida
	RET
Reinicio3:
	LDI		R19, 0x00	//Reiniciar conteo
	RJMP	RETURNI2

decrementar2: 
	CPI		R19, 0x00	//Comparar para ver si ocurre un acarreo.
	BREQ	Reinicio4	//Reiniciar si hay overflow
	DEC		R19		//Decrementar valor
RETURND2:
	OUT		PORTC, R19	//Actualizar salida
	RET
Reinicio4:
	LDI		R19, 0x0F	//Reiniciar conteo
	RJMP	RETURND2



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