// Handles all IRQ related routines

//.pc = $9000 "IRQ routines"
.pc = movementEnd+1 "IRQ Routines"

SetRasterIRQ:
{
	sei          // turn off interrupts
	lda #$7f
	ldx #$01
	sta $dc0d    // Turn off CIA 1 interrupts
	sta $dd0d    // Turn off CIA 2 interrupts
	stx $d01a    // Turn on raster interrupts
	lda #$1b
	ldx #$08
	ldy #$14
	sta $d011    // Clear high bit of $d012, set text mode
	stx $d016    // single-colour
	sty $d018    // screen at $0400, charset at $2000
	lda #<irq1    // low part of address of interrupt handler code
	ldx #>irq1    // high part of address of interrupt handler code
	ldy #$00     // line to trigger interrupt
	sta $0314    // store in interrupt vector
	stx $0315
	sty $d012
	lda $dc0d    // ACK CIA 1 interrupts
	lda $dd0d    // ACK CIA 2 interrupts
	asl $d019    // ACK VIC interrupts
	cli
	rts

irq1:	lda #00
	sta $d020
	sta $d021

	// bitmap mode
	lda #$20
	sta bmpage
	lda #$18
	sta VMCSB
	lda SCROLY
	ora #32
	sta SCROLY


	lda #<irq2
	ldx #>irq2
	sta $0314
	stx $0315

        // Create raster interrupt at line 209, allows just 5 rows of text :3
	ldy #209
	sty $d012

        asl $d019
	jmp $ea31
//	jmp $ea81

	irq2:
	lda #$00
	sta $d020
	sta $d021

	lda #$1b
	ldx #$08
	ldy #$14
	sta $d011    // Clear high bit of $d012, set text mode
	stx $d016    // single-colour
	sty $d018    // screen at $0400, charset at $2000

	lda #<irq1
	ldx #>irq1
	sta $0314
	stx $0315

	ldy #$00
	sty $d012

	asl $d019
	jmp $ea31	
}

interruptsEnd: nop