//zp
.label plot_lo = $fe
.labelplot_hi = $ff
 
//coords
.label x_1 = 100
.label x_2 = 155
.label y_1 = 199
.label y_2 = 0
 
.pc = $0801 "Basic loader"	// BASIC starts at #2049 = $0801

:BasicUpstart(start)

       .pc = $1000
//init screen
 
 start:
        lda #$36	// Load %00110110 to
        sta $01		// processor port, default %00110111:
        		// Bits 0-2 -> 110 Swap out BASIC ROM from $A000-$BFFF
			//	RAM $A000-$BFFF, KERNAL $E000-$FFFF, I/O $D000-$DFFF
        lda #$0b
        sta $d020	// Set border color
        lda #$18	// Load %00011000 to
        sta $d018	// memory setup register, set bitmap memory to $2000-$3FFF
        and #$08	// Load %00001000 to
        sta $d016	// Screen lenght to 40 characters
        lda #2		// Load %00000010 to
        sta $dd00	// VIC bank #1, $4000-$7FFF
        lda #$3b	// Load %00110011 to
        sta $d011	// Screen control register, bits 4-5 = screen & bitmap on
			// bits 0-2 = vertical raster scroll 
        ldx #0
        lda #$10	// %0001000
loop1:   sta $4400,x
        sta $4500,x
        sta $4600,x
        sta $4700,x
        inx
        bne loop1
 
 
 //       sei
loop2: //  lda #$f8
        //cmp $d012
       // bne *-3
       // dec $d020
        jsr draw_line
       // inc $d020
       // jmp loop2
loop3: 	jmp loop3
draw_line:
 
//init
 
        ldx #$e8        //inx
        lda #y_2
        sta to_y+1
        sec
        sbc #y_1
        bcs skip1
        eor #$ff
        adc #1
        ldx #$ca        //dex - change direction
skip1:
        sta d_y+1
        sta t_y_1+1
        sta t_y_2+1
        stx incx1
        stx incx2
 
        ldx #$c8        //iny
        lda #x_2
        sta to_x+1
        sec
        sbc #x_1
        bcs skip2
        eor #$ff
        adc #1
        ldx #$88        //dey - change direction
skip2:
        stx incy1
        stx incy2
 
        ldy #x_1
        ldx #y_1
 
//loop
 
//start y in x-register
//start x in y-register
//delta x in a-register
 
d_y:     cmp #0
        bcc steep
 
        sta t_x_1+1
        lsr
        sta errx+1
loopx:
        clc                 //needed, as previous cmp could set carry. could be saved if we always count up and branch with bcc//
        lda x_char,y
        adc y_char_lo,x
        sta plot_lo
        lda y_char_hi,x
        sta plot_hi
 
        lda x_pixel_char,y
        ora (plot_lo),y
        sta (plot_lo),y     //Remember that the y_char_lo table in this example starts at $20 (which center hires mode plotting). If you lower the start of table to below $08 (say for multicolor purposes where x steps are in doubles), you will get high-byte issues when you $FE in the adc x_char with the sta (),y  
 
errx:    lda #$00
        sec
t_y_1:   sbc #0
        bcs skip3
 
        //one might also swap cases (bcc here) and duplicate the loopend. saves more or less cycles as the subtract-case occurs more often than the add-case. Copying the whole loop to zeropage also save cycles as sta errx+1 is only 3 cycles then. (Bitbreaker)
 
t_x_1:   adc #0
incx1:   inx
skip3:   sta errx+1
 
incy1:   iny
to_x:    cpy #0
        bne loopx
        rts
 
steep:
        sta t_x_2+1
        lsr
        sta erry+1
loopy:
        clc                 //needed, as previous cmp could set carry. could be saved if we always count up and branch with bcc//
        lda x_char,y
        adc y_char_lo,x
        sta plot_lo
        lda y_char_hi,x
        sta plot_hi
 
        lda x_pixel_char,y
        ora (plot_lo),y
        sta (plot_lo),y
 
erry:    lda #$00
        sec
t_x_2:   sbc #0
        bcs skip4
 
t_y_2:   adc #0
incy2:   iny
skip4:   sta erry+1
 
incx2:   inx
to_y:    cpx #0
        bne loopy
        rts
 
.align 256
y_char_lo:
	.byte $20,$21,$22,$23,$24,$25,$26,$27,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7
	.byte $20,$21,$22,$23,$24,$25,$26,$27,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7
	.byte $20,$21,$22,$23,$24,$25,$26,$27,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7
	.byte $20,$21,$22,$23,$24,$25,$26,$27,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7
	.byte $20,$21,$22,$23,$24,$25,$26,$27,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7
	.byte $20,$21,$22,$23,$24,$25,$26,$27,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$e0,$e1,$e2,$e3,$e4,$e5,$e6,$e7
	.byte $20,$21,$22,$23,$24,$25,$26,$27,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $60,$61,$62,$63,$64,$65,$66,$67,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $60,$61,$62,$63,$64,$65,$66,$67,$60,$61,$62,$63,$64,$65,$66,$67
	.byte $60,$61,$62,$63,$64,$65,$66,$67,$60,$61,$62,$63,$64,$65,$66,$67
 
y_char_hi:
	.byte $60,$60,$60,$60,$60,$60,$60,$60,$61,$61,$61,$61,$61,$61,$61,$61
	.byte $62,$62,$62,$62,$62,$62,$62,$62,$63,$63,$63,$63,$63,$63,$63,$63
	.byte $65,$65,$65,$65,$65,$65,$65,$65,$66,$66,$66,$66,$66,$66,$66,$66
	.byte $67,$67,$67,$67,$67,$67,$67,$67,$68,$68,$68,$68,$68,$68,$68,$68
	.byte $6a,$6a,$6a,$6a,$6a,$6a,$6a,$6a,$6b,$6b,$6b,$6b,$6b,$6b,$6b,$6b
	.byte $6c,$6c,$6c,$6c,$6c,$6c,$6c,$6c,$6d,$6d,$6d,$6d,$6d,$6d,$6d,$6d
	.byte $6f,$6f,$6f,$6f,$6f,$6f,$6f,$6f,$70,$70,$70,$70,$70,$70,$70,$70
	.byte $71,$71,$71,$71,$71,$71,$71,$71,$72,$72,$72,$72,$72,$72,$72,$72
	.byte $74,$74,$74,$74,$74,$74,$74,$74,$75,$75,$75,$75,$75,$75,$75,$75
	.byte $76,$76,$76,$76,$76,$76,$76,$76,$77,$77,$77,$77,$77,$77,$77,$77
	.byte $79,$79,$79,$79,$79,$79,$79,$79,$7a,$7a,$7a,$7a,$7a,$7a,$7a,$7a
	.byte $7b,$7b,$7b,$7b,$7b,$7b,$7b,$7b,$7c,$7c,$7c,$7c,$7c,$7c,$7c,$7c
	.byte $7e,$7e,$7e,$7e,$7e,$7e,$7e,$7e,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	.byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	.byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	.byte $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
x_char:
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
	.byte $00,$ff,$fe,$fd,$fc,$fb,$fa,$f9,$00,$ff,$fe,$fd,$fc,$fb,$fa,$f9
 
x_pixel_char:
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
	.byte $80,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$01
 
.pc = $6000
        .fill $2000,0