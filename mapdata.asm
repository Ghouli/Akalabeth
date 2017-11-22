// Stores map data as 9 x 9 grid of bytes
// Bit indicates if there is a wall or clear space
// 0 = clear, 1 = wall

//.pc = $9100 "Map data"
.pc = wallsEnd+1 "Map data"

mapdata:
//    0  1  2  3  4  5  6  7  8
.byte 1, 1, 1, 1, 1, 1, 1, 1, 1 // 0
.byte 1, 0, 2, 0, 0, 3, 0, 0, 1 // 1
.byte 1, 0, 1, 1, 1, 0, 1, 0, 1 // 2
.byte 1, 0, 0, 3, 0, 4, 1, 2, 1 // 3
.byte 1, 1, 1, 2, 1, 1, 1, 2, 1 // 4
.byte 1, 0, 0, 0, 0, 0, 0, 3, 1 // 5
.byte 1, 0, 1, 0, 1, 1, 1, 0, 1 // 6
.byte 1, 0, 1, 0, 1, 0, 0, 0, 1 // 7
.byte 1, 1, 1, 1, 1, 1, 1, 1, 1 // 8


mapdataEnd: nop