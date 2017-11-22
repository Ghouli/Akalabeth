.pc = playerdataEnd+1 "Input handler routines"

.label readKeyboard = $ffe4

setupInput:
{

}

// *** Waits for keyboard input
// Note! RTS is done from routines called by handleInput
// handleInput only contains jump list
handleInput:
{

readKey:
	jsr readKeyboard
	beq readKey
// *** This depends on where the player is...
// ... but since we only have our little dungeon so far,
//     let's just focus on that for now.
	cmp keysUp
	beq moveKey
	cmp keysUp+1
	beq moveKey
// ***
	cmp keysLeft
	beq leftKey	
	cmp keysLeft+1
	beq leftKey
// ***
	cmp keysRight
	beq rightKey
	cmp keysRight+1
	beq rightKey
// ***
	cmp keysDown
	beq downKey
	cmp keysDown+1
	beq downKey
// ***
	cmp keysPass
	beq passKey
// ***
	cmp keysAttack
	beq attackKey
// ***
	cmp keysAscend
	beq ascendKey
// *** Unknown key
	jmp unknownKey
moveKey:
	jmp move
leftKey:
	jmp turnLeft
rightKey:
	jmp turnRight
downKey:
	jmp turnAround
passKey:
	jmp pass
attackKey:
	jmp attack
ascendKey:
	jmp ascend
}

keysUp:
	.byte $40, 'I'//$91	// @, cursor up
keysLeft:
	.byte $3A, 'J'//$9D	// :, cursor left
keysRight:
	.byte $3B, 'L'//$1D	// ;, cursor right
keysDown:
	.byte $2F, 'K'//$11	// /, cursor keysDown
keysPass:
	.byte ' '
keysAttack:
	.byte 'A'
keysAscend:
	.byte 'X'

unknownKey:
{
	jsr printHuh		// Unknown key, print message
	jsr scrollText
	jsr askCommand
	jmp handleInput	// and read another key press
}

move:
{
	jsr movePlayer
	bcs moveBlocked		// Movement blocked?
	jsr printForward
	clc
	rts
moveBlocked:			// Movement blocked, do nothing
	jmp handleInput		// read again
}

turnLeft:
{
	clc
	lda #01			// left
	jsr turnPlayer
	jsr printLeft
	clc
	rts
}

turnRight:
{
	clc
	lda #02			// right
	jsr turnPlayer
	jsr printRight
	clc
	rts
}

turnAround:
{
	sec			// set carry to turn around
	jsr turnPlayer
	jsr printAround
	clc
	rts
}

pass:
{
	jsr printPass
	clc
	rts
}

attack:
{
	jsr printHuh		// Unknown key, print message
	jsr scrollText
	jsr askCommand	
// *** Ask for weapon and perform the actual attack
	clc
	rts
}

ascend:
{
	jsr printHuh		// Unknown key, print message
	jsr scrollText
	jsr askCommand	
// *** Check for ladders up / down and move accordingly if found
	clc
	rts
}