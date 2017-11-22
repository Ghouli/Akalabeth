// Stores location of player as X, Y coordinates
// Facing, NWES
// Attributes
// Inventory

//.pc = $1A00 "Player data"
.pc = mapdataEnd+1 "Player data"

playerLocation:
playerX:	.byte 7
playerY:	.byte 5

playerFacing:
.byte 1		// 1 = north, 2 = west, 3 = south; 4 = east

// *** Indoor or outdoor ?
playerIndoor:
	.byte 00

// *** Player's stats
playerFood:
.word 5000

playerHitpoints:
.word 25

playerGold:
.word $ffff

// decrement food while moving
decFood:
{
	ldx #01
	stx toDec
	lda playerIndoor
	beq indoorMovement
outdoorMovement:
	ldx #10
	stx toDec
indoorMovement:
	sec
	:sub16 playerFood ; toDec
	bcs continue	// Carry still set?
// *** you are died :D
	jsr printDeathMessage
loop:	jsr $ffe4	// Scan keyboard
	beq loop
	cmp #'R'
	bne loop
	jmp start
continue:
	rts
toDec:
	.word 01
}

playerdataEnd: nop