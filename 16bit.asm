.function _16bit_nextArgument(arg) {
	.if (arg.getType()==AT_IMMEDIATE)
	.return CmdArgument(arg.getType(),>arg.getValue())
	.return CmdArgument(arg.getType(),arg.getValue()+1)
}

.pseudocommand inc16 arg {
	inc arg
	bne over
	inc _16bit_nextArgument(arg)
over:
}

.pseudocommand dec16 arg {
	lda arg
	bne skip
	dec _16bit_nextArgument(arg) 
skip:   dec arg
}

.pseudocommand mov16 src;tar {
	lda src
	sta tar
	lda _16bit_nextArgument(src)
	sta _16bit_nextArgument(tar)
}

.pseudocommand add16 arg1 ; arg2 ; tar {
.if (tar.getType()==AT_NONE) .eval tar=arg1
	lda arg1
	adc arg2
	sta tar
	lda _16bit_nextArgument(arg1)
	adc _16bit_nextArgument(arg2)
	sta _16bit_nextArgument(tar)
} 

.pseudocommand sub16 arg1 ; arg2; tar {
.if (tar.getType()==AT_NONE) .eval tar=arg1
	lda arg1
	sbc arg2
	sta tar
	lda _16bit_nextArgument(arg1)
	sbc _16bit_nextArgument(arg2)
	sta _16bit_nextArgument(tar)
}

// Signed 16-bit to unsigned
.pseudocommand mod16 arg ; tar {
.if (tar.getType()==AT_NONE) .eval tar=arg
	lda _16bit_nextArgument(arg)
	bpl stop
	sec
	lda #$00
	sbc arg
	sta tar
	lda #$00
	sbc _16bit_nextArgument(arg)
	sta _16bit_nextArgument(tar)
	clc
	bcc retmod
stop:	lda arg
	sta tar
	lda _16bit_nextArgument(arg)
	sta _16bit_nextArgument(tar)	
retmod:
} 


// Compare 16-bit values, carry set if first val same or bigger
.pseudocommand cmp16 arg1 ; arg2 {
	sec
	lda arg1
	sbc arg2
	lda _16bit_nextArgument(arg1)
	sbc _16bit_nextArgument(arg2)
}

// Compare 16-bit values, zero flag set if equal
.pseudocommand equ16 arg1 ; arg2 {
	lda arg1
	cmp arg2
	bne over
	lda _16bit_nextArgument(arg1)
	cmp _16bit_nextArgument(arg2)
over:	
}

// *** Multiplication by 100
/*
2, 4, 8, 16, 32, 64, 

asl lo
rol hi		// *2
asl lo
rol hi		// *4
lda lo
sta loX2
lda hi
sta hiX2
asl lo
rol hi		// *8
asl lo
rol hi		// *16
asl lo
rol hi		// *32
lda lo
sta loX32
lda hi
sta hiX32
asl lo
rol hi		// *64
clc
lda lo
adc loX32
sta lo
lda hi
adc hiX32
sta hi		// *64 + *32
lda lo
adc loX2
sta lo
lda hi
adc hiX2
sta hi
rts

 2 * 64 = 128
+2 * 32 = 64 + 128 = 192
+2 * 4 = 8 + 64 + 128 = 200
*/
// *** Division by 100
/*

*/ 
// Multiplies 16-bit number with 8-bit number, 16-bit result
.pseudocommand mul16 arg1 ; arg2 ; tar {
.if (tar.getType()==AT_NONE) .eval tar=arg1
	lda #$00
	tay
//	sty num1Hi  ; remove this line for 16*8=16bit multiply
	beq enterLoop
doAdd:
	clc
	adc arg1
	tax
	tya
	adc _16bit_nextArgument(arg1)
	tay
	txa
multloop:
	asl arg1
	rol _16bit_nextArgument(arg1)
enterLoop:		//; accumulating multiply entry point (enter with .A=lo, .Y=hi)
	lsr arg2
	bcs doAdd
	bne multloop
	sta tar
	sty _16bit_nextArgument(tar)
}

// Multiplies 16-bit number by two
.pseudocommand dbl16 arg1 ; tar {
.if (tar.getType()==AT_NONE) .eval tar=arg1
	clc
	lda arg1
	asl
	sta tar
	lda _16bit_nextArgument(arg1)
	rol
	sta _16bit_nextArgument(tar)
}