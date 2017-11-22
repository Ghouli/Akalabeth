// Handles updating player X, Y coordinates, facing 
//  and collision detection

//.pc = $7500 "Movement routines"
.pc = viewhandlerEnd+1 "Movement routines"

// Changes current facing
// Carry set -> turn around
// A = 1 -> turn left
// A = 2 -> turn left
// Facing goes like this:
// 1 = north, 2 = west, 3 = south, 4 = east
// So pressing left increases, until at 5 it is reset back to 1
// and pressing right decreases, until at 0 it is set to 4.
// Turning around either increases or decreases by 2.
turnPlayer:
{
	bcs turnAround
	cmp #01
	beq turnLeft
turnRight:
	dec playerFacing
	bne doneTurner		// Not zero yet, move along
	lda #$04		// north -> east
	sta playerFacing
	rts
turnLeft:
	inc playerFacing
	clc
	lda playerFacing
	cmp #$05		// Man, is it five already ?
	bcc doneTurner
	lda #$01		// yes, change from east -> north
	sta playerFacing
	rts
turnAround:
	lda playerFacing
	cmp #$04
	beq decFace		// Turn west
	cmp #$03		// now why the hell didn't bcc work here?
	beq decFace		// Turn north
	inc playerFacing
	inc playerFacing
	rts
decFace:
	dec playerFacing
	dec playerFacing	
doneTurner:
	rts	
}

// Check players facing and move to correct direction
// Returns with carry clear if moved
movePlayer:
{
	lda playerFacing
	cmp #01			// North, decrease Y
	beq north
	cmp #02			// West, decrease X
	beq west
	cmp #03			// South, increase Y
	beq south
east:	jsr moveEast		// must be 04, move east
	rts
north:	jsr moveNorth
	rts
west:	jsr moveWest
	rts
south:	jsr moveSouth
	rts	
}

// Moves player north, decrease Y
moveNorth:
{
	ldx playerX
	ldy playerY
	dey
	jsr CheckCollision
//	bcs northCollides	// Dont update coordinates if collision detected
	cmp #01
	beq northCollides
	dec playerY
	clc
	rts
northCollides:
	sec
	rts
}

// Moves player east, increase X
moveEast:
{
	ldx playerX
	ldy playerY
	inx
	jsr CheckCollision
//	bcs eastCollides
	cmp #01
	beq eastCollides
	inc playerX	// East, increase X
	clc
	rts
eastCollides:
	sec
	rts
}

// Moves player west, decrease X
moveWest:
{
	ldx playerX
	ldy playerY
	dex
	jsr CheckCollision
//	bcs westCollides
	cmp #01
	beq westCollides
	dec playerX
	clc
	rts
westCollides:
	sec
	rts
}

// Moves player south, increase Y
moveSouth:
{
	ldx playerX
	ldy playerY
	iny
	jsr CheckCollision
//	bcs southCollides
	cmp #01
	beq southCollides
	inc playerY
	clc
	rts
southCollides:
	sec
	rts
}

// *** Takes coordinates given in X, Y registers
// Returns with carry set if collision is detected,
//  otherwise returns with carry clear
// Also returns element on map in A
CheckCollision:
{
	cpy #00		// Row 0 always has walls
	beq collision
	cpx #00		// Column 0 always has walls
	beq collision
	stx Xposition	
	lda #00
	clc
getRow:	adc #09
	dey
	bne getRow
firstRow:
	adc Xposition
	tax
	lda mapdata,x
	beq noCollision
collision:
	lda mapdata,x
	sec
	rts
noCollision:
	clc
	rts
Xposition:
	.byte $00
}

movementEnd: nop