//.pc = $6200 "View handler"
.pc = characterEnd+1 "View handler"

drawView:
{
// Clear variables!
	lda #00
	sta variables
	sta variables+1
	sta variables+2
	sta variables+3
	sta variables+4
	sta variables+5
	sta variables+6
	sta variables+7
	sta viewRange		// Null current 
// Store player location to temporary variables
	ldx playerX
	ldy playerY
	stx midX
	sty midY
	jsr calcLeft
	jsr calcRight

	lda #00
	sta leftWasClear
	sta rightWasClear
	lda #01
	sta viewBlocked

	lda playerFacing	
	cmp #01
	beq viewNorth
	cmp #02
	beq viewWest
	cmp #03
	beq viewSouth
viewEast:	
	dec leftY
	inc rightY
	inc aheadX
	jmp drawCorrectView

viewNorth:
	dec leftX
	inc rightX
	dec aheadY
	jmp drawCorrectView

viewWest:
	inc leftY
	dec rightY
	dec aheadX
	jmp drawCorrectView

viewSouth:
	inc leftX
	dec rightX
	inc aheadY
	jmp drawCorrectView

drawCorrectView:
// Player's square, sides
// Calculate correct xy for left side
	jsr updateScalingFactor
handleFront:
	jmp drawFront			// <- !!! Notice the jmp!!!
handleLeft:
	jmp drawLeft
handleRight:	
	jmp drawRight
allDrawn:
	// Move ahead
	jsr middleAhead
	jsr leftAhead
	jsr rightAhead
	inc viewRange
	lda viewRange

	cmp #08
	beq viewDone
	
	lda viewBlocked
	beq viewDone

	jmp drawCorrectView

viewDone:
	rts

// Calculate initial left side coordinates
calcLeft:
	clc
	lda playerX
	adc leftX
	sta leftX
	clc
	lda playerY
	adc leftY
	sta leftY
	rts
// Calculate initial right side coordinates
calcRight:
	clc
	lda playerX
	adc rightX
	sta rightX
	clc
	lda playerY
	adc rightY
	sta rightY
	rts
// Advance middle coordinates by one square
middleAhead:
	clc
	lda midX
	adc aheadX
	sta midX
	clc
	lda midY
	adc aheadY
	sta midY
	rts
// Advance left coordinates by one square
leftAhead:
	clc
	lda leftX
	adc aheadX
	sta leftX
	clc
	lda leftY
	adc aheadY
	sta leftY
	rts
// Advance right coordinates by one square
rightAhead:
	clc
	lda rightX
	adc aheadX
	sta rightX
	clc
	lda rightY
	adc aheadY
	sta rightY
	rts

drawFront:
{
	:checkMiddleWall
	bcc jump
	cmp #03
	beq laddersUp
	cmp #04
	beq laddersDown
	ldx viewRange
	beq jump
	cmp #01
	beq wall
	cmp #02
	beq door
jump:	jmp handleLeft	
door:
	:drawScaled #frontDoor
wall:
	:drawScaled #frontWall
	rts
laddersUp:
	:drawLaddersUp
	jmp handleLeft
laddersDown:
	:drawLaddersDown
end:	jmp handleLeft
}

drawLeft:
{
	:checkLeftWall
	bcc leftClear
skip1:	cmp #01
	beq wall
	cmp #02
	beq door
	cmp #03
	beq leftClear
	cmp #04
	beq leftClear
door:	:drawLeftDoor
wall:	:drawLeftWall
	lda #00
	sta leftWasClear
	jmp drawRight
leftClear:
	lda leftWasClear
	bne skip2
	lda viewRange
	cmp #00
	beq skip2
	:drawScaled #lineHorizontalLeft
skip2:	lda #01
	sta leftWasClear
	:drawLeftClear
	jmp handleRight
}

drawRight:
{
	:checkRightWall
	bcc rightClear
	cmp #01
	beq wall
	cmp #02
	beq door
	cmp #03
	beq rightClear
	cmp #04
	beq rightClear
door:	:drawRightDoor
wall:	:drawRightWall	
//	:drawRightWall
	lda #00
	sta rightWasClear
	jmp allDrawn
rightClear:
//	:drawScaled #rightClear
	lda rightWasClear
	bne skip3
	lda viewRange
	cmp #00
	beq skip3
	:drawScaled #lineHorizontalRight
skip3:	lda #01
	sta leftWasClear
	:drawRightClear
	jmp allDrawn
}

.pseudocommand checkMiddleWall {
	ldx midX
	ldy midY
	jsr CheckCollision
}

.pseudocommand checkLeftWall {
	ldx leftX
	ldy leftY
	jsr CheckCollision
}

.pseudocommand checkRightWall {
	ldx rightX
	ldy rightY
	jsr CheckCollision
}
}


updateScalingFactor:
{
	lda viewRange
	beq set0
	cmp #01
	beq set1
	cmp #02
	beq set2
	cmp #03
	beq set3
	cmp #04
	beq set4
	cmp #05
	beq set5
	cmp #06
	beq set6
	cmp #07
	beq set7
	jmp set8
set0:	:setScalingFactor(100, 0, 0)	// Scale 1
	rts
set1:	:setScalingFactor(75, 40, 20) // Scale 0.75
	rts
set2:	:setScalingFactor(56, 70, 35)
	rts
set3:	:setScalingFactor(42, 93, 46)
	rts
set4:	:setScalingFactor(31, 110, 55)
	rts
set5:	:setScalingFactor(23, 123, 62)
	rts
set6:	:setScalingFactor(17, 132, 66)
	rts	
set7:	:setScalingFactor(13, 139, 69)
	rts
set8:	:setScalingFactor(10, 145, 71)
	rts
}
//.pc = $6800
viewRange: .byte 0, 0
scalingFactor: .byte 0, 0
offsetX: .byte 0, 0
offsetY: .byte 0, 0
//.pc = $6820
variables:
midX:	.byte 0
midY:	.byte 0
leftX:	.byte 0
leftY:	.byte 0
rightX: .byte 0
rightY: .byte 0
aheadX: .byte 0
aheadY: .byte 0

viewBlocked:
	.byte 0
leftWasClear:
	.byte 0
rightWasClear:

.pseudocommand drawRightWall {
	:drawScaled #lineNE
	:drawScaled #lineSE
}

.pseudocommand drawRightClear {
	:drawScaled #lineVerticalTopEast
	:drawScaled #lineVerticalBottomEast
}

.pseudocommand drawRightDoor {
	:drawScaled #rightDoorTop
	:drawScaled #rightDoorLeftSide
	:drawScaled #rightDoorRightSide
}

.pseudocommand drawLeftWall {
	:drawScaled #lineNW
	:drawScaled #lineSW
}

.pseudocommand drawLeftClear {
	:drawScaled #lineVerticalTopWest
	:drawScaled #lineVerticalBottomWest
}

.pseudocommand drawLeftDoor {
	:drawScaled #leftDoorTop
	:drawScaled #leftDoorLeftSide
	:drawScaled #leftDoorRightSide
}

.pseudocommand drawLaddersUp {
	:drawScaled #topHatch
	:drawScaled #laddersLeftLine
	:drawScaled #laddersRightLine
	:drawScaled #laddersFirstStep
	:drawScaled #laddersSecondStep
	:drawScaled #laddersThirdStep
	:drawScaled #laddersFourthStep
}

.pseudocommand drawLaddersDown {
	:drawScaled #floorHatch
}


.macro setScalingFactor(scale, offx, offy) {
	lda #scale
	sta scalingFactor
	lda #offx
	sta offsetX
	lda #offy
	sta offsetY
}

viewhandlerEnd: nop