.import source "memlocations.asm"
.import source "16bit.asm"
.import source "playerdata.asm"
.import source "movement.asm"
.import source "mapdata.asm"
.import source "hiresmode.asm"
.import source "charactermode.asm"
.import source "interrupts.asm"
.import source "walls.asm"
.import source "viewhandler.asm"
.import source "input.asm"

.pc = $0801 "Basic loader"	// BASIC starts at #2049 = $0801

:BasicUpstart(start)		// Generate BASIC loader

.pc = $0810 "Main program"
start:
	//clear screen
	jsr $e544

	lda #00
	sta $d020    // black background
	sta $d021
	sta $d022	
	jsr SetRasterIRQ	
	jsr SetHiresmode
	jsr ClearTextArea
	jsr writeColorRam
	jsr WriteText
	jsr printFacing	
	jsr printLocation
	jsr clearbitmap
	jsr printFood
	jsr printHitpoints
	jsr printGold
	jsr printFacing	
	jsr printLocation

//jsr plotmap

	jsr drawView
	jsr askCommand

	

mainLoop:
//	jmp mainLoop

	jsr handleInput
//	bcs mainLoop
	jsr decFood
	jsr clearbitmap
	jsr printFood
	jsr printHitpoints
	jsr printGold
	jsr printFacing	
	jsr printLocation

//	lda #$0
//	sta filval
//	jsr setcolour
	jsr drawView
//	lda #$10
//	sta filval
//	jsr setcolour
	jsr scrollText
	jsr askCommand
	
	jmp mainLoop



mainEnd: nop