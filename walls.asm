// Seinien muodot
//.pc = $8000 "Dungeon wall coordinates"
.pc = interruptsEnd+1 "Dungeon wall coordinates"
// Offsets for different depths
// First (player is here)
.var xmin = 0
.var ymin = 0
.var xmax = 319
.var ymax = 159
.var xoffset = 40
.var yoffset = 20

frontWall:
 .byte 5
// * Point of origin
.word xmin
 .byte ymin
// ***
.word xmax
 .byte ymin
.word xmax
 .byte ymax
.word xmin
 .byte ymax
.word xmin
 .byte ymin

leftWall:
.byte 4
// *
.word xmin
 .byte ymin
// ***
.word xoffset
 .byte ymin+yoffset
.word xoffset
 .byte ymax-yoffset
.word xmin
 .byte ymax

leftClear:
.byte 4
.word xmin
 .byte ymin+yoffset
// Directions
.word xmin+xoffset
 .byte ymin+yoffset
.word xmin+xoffset
 .byte ymax-yoffset
.word xmin
 .byte ymax-yoffset


rightWall:
.byte 4
// *
.word xmax
 .byte ymin
// ***
.word xmax-xoffset
 .byte ymin+yoffset
.word xmax-xoffset
 .byte ymax-yoffset
.word xmax
 .byte ymax

rightClear:
.byte 4
// Point of origin
.word xmax
 .byte ymin+yoffset
// Directions
.word xmax-xoffset
 .byte ymin+yoffset
.word xmax-xoffset
 .byte ymax-yoffset
.word xmax
 .byte ymax-yoffset

lineVerticalTopWest:
.byte 2
.word xmin
 .byte ymin+yoffset
.word xmin+xoffset
 .byte ymin+yoffset

lineVerticalBottomWest:
.byte 2
.word xmin
 .byte ymax-yoffset
.word xmin+xoffset
 .byte ymax-yoffset

lineVerticalTopEast:
.byte 2
.word xmax
 .byte ymin+yoffset
.word xmax-xoffset
 .byte ymin+yoffset

lineVerticalBottomEast:
.byte 2
.word xmax
 .byte ymax-yoffset
.word xmax-xoffset
 .byte ymax-yoffset

lineVerticalTop:
.byte 2
.word xmin
 .byte ymin
.word xmax
 .byte ymin

 lineVerticalBottom:
.byte 2
.word xmin
 .byte ymax
.word xmax
 .byte ymax

lineHorizontalLeft:
.byte 2
.word xmin
 .byte ymin
.word xmin
 .byte ymax

lineHorizontalRight:
.byte 2
.word xmax
 .byte ymin
.word xmax
 .byte ymax

lineNW:
.byte 2
.word xmin
 .byte ymin
.word xmin+xoffset
 .byte ymin+yoffset

lineSW:
 .byte 2
.word xmin
 .byte ymax
.word xmin+xoffset
 .byte ymax-yoffset

lineSE:
 .byte 2
.word xmax
 .byte ymax
.word xmax-xoffset
 .byte ymax-yoffset

 lineNE:
 .byte 2
.word xmax
 .byte ymin
.word xmax-xoffset
 .byte ymin+yoffset

firstLine:
.byte 2
.word xmin
 .byte ymin
.word xmax
 .byte ymax

secondLine:
.byte 2
.word xmin
 .byte ymax
.word xmax
 .byte ymin

leftDoorTop:
 .byte 2
.word xmin
 .byte 26
.word xmin+xoffset-8
 .byte 36

leftDoorLeftSide:
 .byte 2
.word xmin
 .byte 26
.word xmin
 .byte ymax

leftDoorRightSide:
 .byte 2
.word xmin+xoffset-8
 .byte 36
.word xmin+xoffset-8
 .byte ymax-yoffset+4

rightDoorTop:
 .byte 2
.word xmax
 .byte 26
.word xmax-xoffset+8
 .byte 36

rightDoorLeftSide:
 .byte 2
.word xmax-xoffset+8
 .byte 36
.word xmax-xoffset+8
 .byte ymax-yoffset+4

rightDoorRightSide:
.byte 2
.word xmax
 .byte 26
.word xmax
 .byte ymax

frontDoor:
.byte 4
.word xmin+106
 .byte ymax
.word xmin+106
 .byte ymin+26
.word xmax-106
 .byte ymin+26
.word xmax-106
 .byte ymax

topHatch:
.byte 5
.word xmin+110
 .byte ymin+2
.word xmax-110
 .byte ymin+2
.word xmax-120
 .byte ymin+10
.word xmin+120
 .byte ymin+10
.word xmin+110
 .byte ymin+2

laddersLeftLine:
.byte 2
.word xmin+140
 .byte ymin+2
.word xmin+140
 .byte ymax+2

laddersRightLine:
.byte 2
.word xmax-140
 .byte ymin+2
.word xmax-140
 .byte ymax+2

laddersFirstStep:
.byte 2
.word xmin+140
 .byte ymin+32
.word xmax-140
 .byte ymin+32

laddersSecondStep:
.byte 2
.word xmin+140
 .byte ymin+62
.word xmax-140
 .byte ymin+62

laddersThirdStep:
.byte 2
.word xmin+140
 .byte ymin+92
.word xmax-140
 .byte ymin+92

laddersFourthStep:
.byte 2
.word xmin+140
 .byte ymin+122
.word xmax-140
 .byte ymin+122

floorHatch:
.byte 5
.word xmin+110
 .byte ymax-10
.word xmax-110
 .byte ymax-10
.word xmax-120
 .byte ymax-2
.word xmin+120
 .byte ymax-2
.word xmin+110
 .byte ymax-10
/*
//.var xoffset = 40*/
//.var yoffset = 20
wallsEnd: nop