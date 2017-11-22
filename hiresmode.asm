// Handles everything related to handling of bitmapped high resolution screen

// Requires 16bit pseudocommands from 16bit.asm
// .import source "16bit.asm"

//.pc = mainEnd+1 "High resolution routines"

.pc = $6000 "High resolution routines"

// Memory locations used
.label base = $2000
.label SCROLY = $D011
.label VMCSB = $D018
.label colmap = $0400
.label C2DDRA = $DD02
.label CI2PRA = $DD00
.label xcoord = $fb
.label ycoord = $fd
.label tabptr = xcoord
.label tabsiz = $9000
.label filval = tabsiz+2
.label bmpage = $ff
.label mask = $59
.label loc = $5a
.label store = $5c
.label toDraw = $5e		// Stores pointer to shape to draw

// Variables for initialization
.var scrlen = 6400//8000	// 6400 if using 320x160 resolution!
.var maplen = 800//1000

SetHiresmode:
{
	jsr calcTables
// main routine
// define bit map and enable high-res
start:	lda #$20
	sta bmpage
	lda #$18
	sta VMCSB
	lda SCROLY
	ora #32
	sta SCROLY

// select graphics bank 1
// $2000 to $3F40
// at 320x160 only 2000-3900 is actually used 
	lda C2DDRA
	ora #$03
	sta C2DDRA
	lda CI2PRA
	ora #$03
	sta CI2PRA

// clear bit map
	lda #0
	sta filval
	lda #<base
	sta tabptr
	lda #>base
	sta tabptr+1
	lda #<scrlen
	sta tabsiz
	lda #>scrlen
	sta tabsiz+1
	jsr blkfil

// set bg and line colors
	lda #$10
	sta filval
	lda #<colmap
	sta tabptr
	lda #>colmap
	sta tabptr+1
	lda #<maplen
	sta tabsiz
	lda #>maplen
	sta tabsiz+1
	jsr blkfil
	rts
}

clearbitmap:
{
	lda #0
	sta filval
	lda #<base
	sta tabptr
	lda #>base
	sta tabptr+1
	lda #<scrlen
	sta tabsiz
	lda #>scrlen
	sta tabsiz+1
	jsr blkfil	
}

// fill routine
blkfil:
{
	lda filval
	ldx tabsiz+1
	beq partpg
	ldy #0
fullpg:	sta (tabptr),y
	iny
	bne fullpg
	inc tabptr+1
	dex
	bne fullpg
partpg:	ldx tabsiz
	beq fini
	ldy #0
partlp:	sta (tabptr),y
	iny
	dex
	bne partlp
fini:	rts	
}

// colourfill
setcolour:
{
	lda #<colmap
	sta tabptr
	lda #>colmap
	sta tabptr+1
	lda #<maplen
	sta tabsiz
	lda #>maplen
	sta tabsiz+1

	lda filval
	ldx tabsiz+1
	beq partpg
	ldy #0
fullpg:	sta (tabptr),y
	iny
	bne fullpg
	inc tabptr+1
	dex
	bne fullpg
partpg:	ldx tabsiz
	beq fini
	ldy #0
partlp:	sta (tabptr),y
	iny
	dex
	bne partlp
fini:	rts	
}


// plot routine, calculates a location in memory to write from coordinates given
// address = base + int(y/8) * 320 + (y and 7) + int(x/8) * 8
plot2:
{
	lda xcoord

	and #7
	tax
	sec
	lda #0
	sta loc
shift:	ror
	dex
	bpl shift
	sta mask
	lda xcoord
	and #$f8
	sta store
	lda ycoord
	lsr
	lsr
	lsr
	sta loc+1
	lsr
	ror loc
	lsr
	ror loc
	adc loc+1
	sta loc+1
	lda ycoord
	and #7
	adc loc
	adc store
	sta loc
	lda loc+1
	adc xcoord+1
	adc bmpage		// This is set in setup!! Do not overwrite $ff!!
	sta loc+1
	ldy #0
	lda (loc),y
	ora mask,y
	sta (loc),y
	rts
}

// Bresenham's line algorithm
// Calculates points to draw between coordinates given
// in X0, Y0 and X1, Y1
drawline:
{	// 16-bit sub for DX = X1 - X0
	sec
	:sub16 X1 ; X0; DX
	bcs skipDX 
	// Convert DX to absolute value
	:mod16 DX
	// 8-bit sub for DY = Y1-Y0 */
skipDX:	sec             
	lda Y1
	sbc Y0
	sta DY
	bcs skipDY 
	// Convert DY to absolute value
	// Branch if carry set ! (DY is positive)
	// 8 bit negation
	clc
	lda DY		//load value (already loaded with this one, who cares)
	eor #$FF	//Flip all bits
	adc #$01	//add one
	sta DY		//and store
	// Clear high bytes and initialize XI and XY and Dtmp */
skipDY:	ldx #$00
	stx DY+1
	stx DX2+1
	stx DY2+1
	stx Dtmp
	stx Dtmp+1
	stx IX		// Do simple bne check for these when looping
	stx IY
	// DX2 = 2 * DX
	:dbl16 DX ; DX2
	// DY2 = 2 * DY
	:dbl16 DY ; DY2
	// ix = x1 > x0 ? 1 : -1; // check X increment direction
	:cmp16 X1 ; X0
	bcc skip2	// X0 was bigger, don't increment
	:equ16 X1 ; X0
	beq skip2	// X0 was same size, don't increment
	inc IX		// IX = 1
skip2:	// iy = y1 > y0 ? 1 : -1; // check Y increment direction
	:cmp16 Y1 ; Y0
	bcc skip3	// Y0 was bigger
	:equ16 Y1 ; Y0
	beq skip3	// Y0 same size
	inc IY		// IY = 1
skip3:	//check DX >= DY
	//Check if dy is of same size or smaller than DX by checking
	//if carry is set. cmp sets carry if same or higher
	:cmp16 DX ; DY
	bcs DXloop
DYjmp:	jmp DYloop
	// DX was bigger
// DX => DY loop
DXloop:	// X coordinate was bigger in this loop
	// plot current X0, Y0
	:mov16 X0 ; xcoord
	:mov16 Y0 ; ycoord
	jsr plot
	// check if X0 == X1
	:equ16 X0 ; X1
	bne DXnoteq
	rts		//if equal, we are done here. 
// else, calculate new coordinates
DXnoteq:
	lda IX		// Check if increment (1) or decrement (0)
	beq DXdecX	
	:inc16 X0
	jmp DXincD
DXdecX:	:dec16 X0
DXincD:	// D += DY2
	clc
	:add16 Dtmp ; DY2	
	// if d > dx
	:mod16 Dtmp ; tmp
	:cmp16 tmp ; DX
	bcc DXloopj
	// D was bigger, change Y coordinate
	// first check if increment or decrement
DXbigD:	lda IY
	beq DXdecY	//IY was zero, go to decrement
	:inc16 Y0
	jmp DXdecD
DXdecY:	:dec16 Y0
DXdecD:	//D -= DX2
	sec
	:sub16 Dtmp ; DX2

DXloopj:jmp DXloop	//And continue looping
// DY > DX loop	
DYloop:	//Y coordinate was bigger on this loop
	//plot current X0, Y0
	:mov16 X0 ; xcoord
	:mov16 Y0 ; ycoord
	jsr plot
	//Check if Y0 == Y1
	:equ16 Y0 ; Y1
	bne DYnoteq
	rts		//if equal, we are done here. 
DYnoteq://else, calculate new coordinates
	//check if inc or dec
	lda IY
	beq DYdecY	//IY was zero, go to decrement
	:inc16 Y0
DYskp:	jmp DYincD
DYdecY:	:dec16 Y0
DYincD:	//D += DX2
	clc
	:add16 Dtmp ; DX2
	// if d > dY
	:mod16 Dtmp ; tmp
	:cmp16 tmp ; DY
	bcc DYloopj
	// D was bigger, change X coordinate
	// first check if increment or decrement
DYbigD:	lda IX
	beq DYdecX	//IX was zero, go to decrement
	:inc16 X0	//IX was not zero, do increment
	jmp DYdecD
DYdecX:	:dec16 X0
DYdecD:	// D -= DY2
	sec
	:sub16 Dtmp ; DY2

DYloopj:jmp DYloop	//And continue looping

// Local variables
.label DX = $73
.label DY = $75
.label DX2 = $77
.label DY2 = $79
.label Dtmp = $7B
.label IX = $7D
.label IY = $7F
.label tmp = $81
//DX:	.byte 0, 0
//DY:	.byte 0, 0
//DX2:	.byte 0, 0
//DY2:	.byte 0, 0
//Dtmp:	.byte 0, 0
//IX:	.byte 0, 0
//IY:	.byte 0, 0
//tmp:	.byte 0, 0
}

// Variables shared between drawLine and drawShape
X0:	.byte 0, 0
Y0:	.byte 0, 0
X1:	.byte 0, 0
Y1:	.byte 0, 0

// Pseudocommand to call drawShape
.pseudocommand draw element {
	lda element
	sta toDraw
	lda _16bit_nextArgument(element)
	sta toDraw+1
	jsr drawShape	
}

// Pseudocommand to call drawScaledShape
.pseudocommand drawScaled element {
	lda element
	sta toDraw
	lda _16bit_nextArgument(element)
	sta toDraw+1
	jsr drawScaledShape	
}

// Handles drawing of shapes stored in data files
// Pointer to memory location of desired shape needs
//  to be stored in toDraw at $5e-$5f
// Data files are stored in following format:
// .byte 4	// How many dots to plot
// // Point of origin
// .byte 00, 00	// Xlo, Xhi
// .byte 00	// Y
// // Directions
// .byte 48, 00	// Xlo, Xhi
// .byte 24	// Y
// .byte 48, 00	// Xlo, Xhi
// .byte 136	// Y
// .byte 00, 00	// Xlo, Xhi
// .byte 160	// Y
drawShape:
{
	ldy #0
	lda (toDraw),y
	iny
	sta pointsToPlot
	dec pointsToPlot
// Plot starting point	
	lda (toDraw),y
	sta X0
	iny
	lda (toDraw),y	
	sta X0+1
	iny
	lda (toDraw),y
	sta Y0
	sty counter
// Plot following points
draw:	ldy counter
	iny
	lda (toDraw),y
	sta X1
	sta pointX
	iny
	lda (toDraw),y	
	sta X1+1
	sta pointX+1
	iny
	lda (toDraw),y
	sta Y1
	sta pointY
	sty counter
	jsr drawline
	dec pointsToPlot
	bne draw
	rts
// Local variables
pointX: .byte 0, 0
pointY:	.byte 0
pointsToPlot: .byte 0
counter: .byte 0
}


 

.label divisor = $58		//$59 used for hi-byte
.label dividend = $fb		//$fc used for hi-byte
.label remainder = $fd		//$fe used for hi-byte
.label result = dividend	//save memory by reusing divident to store the result

divide:	lda #0	        //preset remainder to 0
	sta remainder
	sta remainder+1
	ldx #16	        //repeat for each bit: ...

divloop:asl dividend	//dividend lb & hb*2, msb -> Carry
	rol dividend+1	
	rol remainder	//remainder lb & hb * 2 + msb from carry
	rol remainder+1
	lda remainder
	sec
	sbc divisor	//substract divisor to see if it fits in
	tay	        //lb result -> Y, for we may need it later
	lda remainder+1
	sbc divisor+1
	bcc skip	//if carry=0 then divisor didn't fit in yet

	sta remainder+1	//else save substraction result as new remainder,
	sty remainder	
	inc result	//and INCrement result cause divisor fit in 1 times

skip:	dex
	bne divloop	
	rts

drawScaledShape:
{
// Test element
	ldy #0
	lda (toDraw),y
	iny
	sta pointsToPlot
	dec pointsToPlot
// Plot starting point	
	lda (toDraw),y
	sta toScaleX
	iny
	lda (toDraw),y
	sta toScaleX+1
	iny
	lda (toDraw),y
	sta toScaleY
	lda #00
	sta toScaleY+1

	sty counter

	lda scalingFactor	
	sta scalefactor
	lda #00
	sta scalefactor+1
	:mul16 toScaleX ; scalefactor

	lda scalingFactor	
	sta scalefactor
	lda #00
	sta scalefactor+1

	:mul16 toScaleY ; scalefactor	
	jsr divByHundred

	lda scaledX
	sta X0
	lda scaledX+1
	sta X0+1
	lda scaledY
	sta Y0
// Plot following points
draw:
	ldy counter
	iny
	lda (toDraw),y

	sta toScaleX
	sta pointX
	iny
	lda (toDraw),y	
	sta toScaleX+1

	sta pointX+1
	iny
	lda (toDraw),y
	sta toScaleY
	lda #0
	sta toScaleY+1

	sty counter

	lda scalingFactor	
	sta scalefactor
	lda #00
	sta scalefactor+1
	:mul16 toScaleX ; scalefactor

	lda scalingFactor	
	sta scalefactor
	lda #00
	sta scalefactor+1
	:mul16 toScaleY ; scalefactor	
	jsr divByHundred

	lda scaledX
	sta X1
	lda scaledX+1
	sta X1+1
	lda scaledY
	sta Y1
	jsr drawline
	dec pointsToPlot
	beq exit
	jmp draw
exit:	rts

//Divide by hunded
divByHundred:
	lda toScaleX
	sta dividend
	lda toScaleX+1
	sta dividend+1
	lda #100
	sta divisor
	lda #0
	sta divisor+1
	jsr divide
	clc
	lda dividend
	adc offsetX
	sta scaledX
	lda #0
	adc dividend+1
	sta scaledX+1

	lda toScaleY
	sta dividend
	lda toScaleY+1
	sta dividend+1
	lda #100
	sta divisor
	lda #0
	sta divisor+1
	jsr divide
	clc
	lda dividend
	adc offsetY
	sta scaledY
	lda #0
	adc dividend+1
	sta scaledY+1
	rts
// Local variables
pointX: .byte 0, 0
pointY:	.byte 0
pointsToPlot: .byte 0
counter: .byte 0

toScaleX: .word 0
toScaleY: .word 0
scaledX: .word 0
scaledY: .word 0
ten: .byte 10, 0
scalefactor: .byte 7, 0
}

/*

plotmap:
{
	ldx #$00
loop:
	txa
	and #$07
	asl
	asl
	sta $FC
	txa
	lsr
	lsr
	lsr
	sta $FD
	lsr
	ror $FC
	lsr
	ror $FC
	adc $FD
	ora #$20		// bitmap address $2000
	sta YTABHI,x
	lda $FC
	sta YTABLO,x
	inx
	cpx #200
	bne loop
//	rts
//For horizontal access, you need these tables for hires pixels:

	lda #$80
	sta $FC
	ldx #$00
loop2:
	txa
	and #$F8
	sta XTAB,X
	lda $FC
	sta BITTAB,x
	lsr
	bcc skip
	lda #$80
skip:
	sta $FC
	inx
	bne loop2
	rts
}

getpix:
//plot:
{
	ldx xcoord
	ldy ycoord
	//Plotting a pixel would be:
	lda YTABLO,y
	sta $FC
	lda YTABHI,y
	sta $FD
	ldy XTAB,x
	lda ($FC),y
	ora BITTAB,x
	sta ($FC),y
	rts
}
*/
.label address = xcoord
.label bitmapstart = $2000
plot:
{
		ldy ycoord		// 3
		ldx xcoord		// 3
		lda #>xtablehigh	// 2
		sta XTBmdf+2		// 3		SELF MODIFYING CODE
		lda xcoord+1		// 3
		beq skipadj		// 2 / 3	Skip if higher byte is 0: 0 < x < 255
		lda #$C7			
		//lda #>xtablehigh2	// 2
		sta XTBmdf+2		// 3		SELF MODIFYING CODE
		//sta $c900
		//brk
skipadj:	lda ytablelow,y		// 4+
		clc			// 2
		adc xtablelow,x		// 4+
		sta address		// 3

		lda ytablehigh,y	// 4+

XTBmdf:		adc xtablehigh,x	// 4+		// Modification done to high bits of xtablehigh
		sta address+1		// 3
/*
		lda address		// 3
		clc			// 2
		adc #<bitmapstart	// 2
		sta address		// 3

		lda address+1		// 3
		adc #>bitmapstart	// 2
		sta address+1		// 3
*/
		ldy #$00		// 2
		lda (address),y		// 5+
		ora bitmasktable,x	// 4
		sta (address),y		// 6
		rts
}

calcTables:
{
	// First calculate Y tables
	.var tmp = 0
	.for (var row = 0; row < 25; row++) {
		.for (var i = 0; i < 8; i++, tmp++) {
			//tmp = 
			lda #<i+320*row+bitmapstart
			sta ytablelow+tmp
			lda #>i+320*row+bitmapstart
			sta ytablehigh+tmp
		}
	}
	// Then calculate X tables
	.var tmp2 = 0
	.for (var column = 0; column < 40; column++) {
		.for (var i = 0; i < 8; i++, tmp2++) {
			//tmp = 
			lda #<8*column
			sta xtablelow+tmp2
			lda #>8*column
			sta xtablehigh+tmp2
		}
	}
	// Finally create bitmask table
	.var tmp3 = 0
	.for (var column = 0; column < 40; column++)
	{
		.for (var i = 0; i < 8; i++, tmp3++) {
			lda #$80>>i
			sta bitmasktable+tmp3
		}
/*		lda #$80
		sta masktable+tmp3
		tmp3++
		lda #$40
		sta masktable+tmp3
		tmp3++
		lda #$20
		sta masktable+tmp3
		tmp3++
		lda #$10
		sta masktable+tmp3
		tmp3++
		lda #$08
		sta masktable+tmp3
		tmp3++
		lda #$04
		sta masktable+tmp3
		tmp3++
		lda #$02
		sta masktable+tmp3
		tmp3++
		lda #$01
		sta masktable+tmp3
		tmp3++*/
	}
	rts
}


hiresEnd: nop


.pc = $c000 "ytablelow" virtual 
ytablelow:
.fill 200, 0


.pc = $C200 "ytablehigh" virtual
ytablehigh:
.fill 200, 0

.pc = $C400 "xtablelow" virtual
xtablelow:
.fill 255, 0

.pc = $C600 "xtablehigh" virtual
xtablehigh:
.fill 255, 0
xtablehigh2:
.pc = $C700 "xtablehigh2" virtual

.pc = $C800 "masktable" virtual
bitmasktable:
.fill 255, 0