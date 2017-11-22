// Handles all character based routines ie printing text on screen
// While playing it is responsible for updating lower part of the screen
// Last 5 lines are used for stats etc

//.pc = $7000 "Character mode routines"

.pc = hiresEnd+1 "Character mode routines"

.label textarea = $0720
.label colorarea = $0db20

.label toPrint = $5e	// Stores pointer to text to write on screen

.var lineWidth = 40
.var textRows = 5
.var totalChars = 200
.var toScroll = 160
.var positionFood = 34
.var positionHitpoints = 74
.var positionGold = 114

// Clear character area
ClearTextArea:
{
	lda #' '
	ldx #totalChars
loop:	sta textarea,x
	dex
	bne loop
	sta textarea,x
	rts
}

scrollText:
ScrollText:
{
//Needs to be done line by line?
	ldx #40
	ldy #0
// First line
loop:	lda textarea,x
	sta textarea,y
	inx
	iny
	cpx #69	//#totalChars
	bne loop
// Second line
	ldx #80
	ldy #40
loop2:	lda textarea,x
	sta textarea,y
	inx
	iny
	cpx #109	//#totalChars
	bne loop2
// Third line
	ldx #120
	ldy #80
loop3:	lda textarea,x
	sta textarea,y
	inx
	iny
	cpx #149	//#totalChars
	bne loop3		
// Clear last line	
	lda #' '
	ldx #120	//#totalChars
loop4:	sta textarea,x
	inx
	cpx #149	//#160
	bne loop4	//*/
	rts
}

ClearLastLine:
{
	lda #' '
	ldx #totalChars
loop:	sta textarea,x
	dex
	cpx #160
	bne loop
	sta textarea,x
	rts
}

writeColorRam:
{
	lda #WHITE
	ldx #totalChars
loop:	sta colorarea,x
	dex
	bne loop
	sta colorarea,x
	rts
}
/*
// Pseudocommand to call writeText
.pseudocommand print text {
	lda text
	sta toPrint
	lda _16bit_nextArgument(text)
	sta toPrint+1
	jsr WriteText	
}
*/
WriteText:
{
/*	ldy #00
	ldx #161
loop:	lda (toPrint),y
	beq end
	sta textarea,x
	iny
	inx
	jmp loop*/
	ldx #totalChars
write:	lda messu2,x
	sta textarea,x
	dex
	bne write
	lda messu2,x
	sta textarea,x
end:	rts
}

askCommand:
{
	ldx #00
	ldy #120
write:	lda TextCommand,x
	beq end
	sta textarea,y
	inx
	iny
	jmp write
end:	rts
}

printForward:
{
	ldx #00
	ldy #129
write:	lda TextForward,x
	beq end
	sta textarea,y
	inx
	iny
	jmp write
end:	rts
}

printLeft:
{
	ldx #00
	ldy #129
write:	lda TextTurnLeft,x
	beq end
	sta textarea,y
	inx
	iny
	jmp write
end:	rts
}

printRight:
{
	ldx #00
	ldy #129
write:	lda TextTurnRight,x
	beq end
	sta textarea,y
	inx
	iny
	jmp write
end:	rts
}

printAround:
{
	ldx #00
	ldy #129
write:	lda TextTurnAround,x
	beq end
	sta textarea,y
	inx
	iny
	jmp write
end:	rts
}

printHuh:
{
	ldx #00
	ldy #129
write:	lda TextHuh,x
	beq end
	sta textarea,y
	inx
	iny
	jmp write
end:	rts
}

printPass:
{
	ldx #00
	ldy #129
write:	lda TextPass,x
	beq end
	sta textarea,y
	inx
	iny
	jmp write
end:	rts
}

printDeathMessage:
{
	ldx #00
write:	lda TextDeath,x
	beq end
	sta textarea,x
	inx
	jmp write
end:	rts
}

// Prints location of player to last line
printLocation:
{
	clc
	lda playerLocation
	adc #$30		// Writing directly to screen ram
	ldx #194		// So we need to add $30 to print decimal number
	sta textarea, x
	clc
	lda playerLocation+1
	adc #$30
	ldx #198
	sta textarea, x
	rts
}

// Prints facing of player to last line
printFacing:
{
	ldx #168
	lda playerFacing
	cmp #01	
	beq north
	cmp #02
	beq west
	cmp #03
	beq south
east:	lda #'e'
	sta textarea,x
	rts
north:	lda #'n'
	sta textarea,x
	rts
west:	lda #'w'
	sta textarea,x
	rts
south:	lda #'s'
	sta textarea,x
	rts
}

// *** Converts 4-bit bcd number to printable format
.pseudocommand addAscii 
{
	clc
	adc #$30
}

.pseudocommand ror4
{
	clc
	ror
	ror
	ror
	ror
}

// *** Prints amount of food to screen
printFood:
{
	lda playerFood
	sta binaryValue
	lda playerFood+1
	sta binaryValue+1
	jsr binbcd16	
	ldx #positionFood		// Cursor starting position 34
	lda #' '
	sta textarea,x
	sta textarea+1,x
	sta textarea+2,x
	sta textarea+3,x
	sta textarea+4,x
	sta textarea+5,x
	stx cursorStart
	jsr printStat
	rts	
}

// *** Prints amount of hitpoints to screen
printHitpoints:
{
	// First convert to bcd
	lda playerHitpoints
	sta binaryValue
	lda playerHitpoints+1
	sta binaryValue+1
	jsr binbcd16	
	ldx #positionHitpoints		// Cursor starting position 74
	stx cursorStart
	jsr printStat
	rts
}

// *** Prints amount of gold to screen
printGold:
{
	// First convert to bcd
	lda playerGold
	sta binaryValue
	lda playerGold+1
	sta binaryValue+1
	jsr binbcd16
	lda bcdValue
	lda bcdValue+1
	lda bcdValue+2
	ldx #positionGold		// Cursor starting position 114
	stx cursorStart
	jsr printStat
	rts
}

printStat:
{
	ldx cursorStart
	ldy #03
checkHigh:
// Check for food decimal point
	cpy #01
	bne loadValue
	lda cursorStart
	cmp #positionFood		// Food starts at cursor position 34
	bne loadValue
	lda bcdValue-1,y
	and #$F0
	:ror4
	:addAscii
	sta textarea,x
	inx
	lda #'.'		// Write decimal point!
	sta textarea,x
	inx
	jmp checkLow
loadValue:
	lda bcdValue-1,y
	and #$F0
	bne writeHigh		// Check for zero
	cpx cursorStart		// is it leading zero?
	beq checkLow		// Skip if so
writeHigh:			// Else handle writing high bits of byte
	:ror4
	:addAscii
	sta textarea,x
	inx
checkLow:
	lda bcdValue-1,y
	and #$0F
	bne writeLow		// Check for zero
	cpx cursorStart		// is it leading zero?
	beq checkForMore	// Skip if so
writeLow:
	:addAscii
	sta textarea ,x
	inx
checkForMore:
	dey
	bne checkHigh		// Read more
	rts
}
cursorStart:
	.byte 00

// *** Converts 16-bit binary number to 24-bit bcd number
binbcd16:
{
	sed			// Switch to decimal mode
	lda #00			// Ensure the result is clear
	sta bcdValue+0
	sta bcdValue+1
	sta bcdValue+2
	ldx #16			// Number of source bits
convertBit:
	asl binaryValue+0	// Shift out one bit
	rol binaryValue+1
	lda bcdValue+0		// And add into result
	adc bcdValue+0
	sta bcdValue+0
	lda bcdValue+1		// Propagating any carry..
	adc bcdValue+1
	sta bcdValue+1
	lda bcdValue+2		// .. through the whole result
	adc bcdValue+2
	sta bcdValue+2
	dex			// And repeat for next bit
	bne convertBit
	cld			// Back to binary
	rts
}
binaryValue:
	.word 00
bcdValue:
	.byte 00, 00, 00

messu:	.text "                                        "
	.text "                                        "
	.text "                                        "
	.text "                                        "
	.text "                                        "

messu2:	.text "                             food=73.4  "
	.text "                             h.p.=22    "
	.text "                             gold=0     "
	.text "                                        "
	.text "facing:         w.i.p.          x:  y:  "

TextDeath:
	.text "        we mourn the passing of         "
	.text "     the peasant and his computer       "
	.text "  to invoke a miracle of resurrection   "
	.text "             <hit esc key>              "
	.byte 0
//	.text "                                        "

// Command messages
TextCommand:
	.text "command?"
	.byte 0
TextForward:
	.text "forward"
	.byte 0
TextTurnRight:
	.text "turn right"
	.byte 0
TextTurnLeft:
	.text "turn left"
	.byte 0
TextTurnAround:
	.text "turn around"
	.byte 0
TextPass:
	.text "pass"
	.byte 0
TextHuh:
	.text "huh?"
	.byte 0

characterEnd: nop