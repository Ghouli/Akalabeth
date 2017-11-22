
// Color ram for bitmapped screen occupies $0400-07E8 at 320x200
// at 320x160 only $0400 - $0720 are actually used
// Initializations are still done to whole area!
.pc = $0400 "Bitmap color" virtual
.fill 800,0	// Change to 1000 if going 320x200

// Character screen occupies $0720-$07E7
.pc = $0720 "Character screen" virtual
.fill 200,0

// Bitmapped screen occupies $2000-$3F40 at 320x200
// at 320x160 only $2000-$3900 is actually used
// Initializations are still done to whole area!
.pc = $2000 "Bitmap screen" virtual
.fill 8000,0	// Change to 6400 if going 320x200

// Color ram for character screen occupies $db20-$dbe8
.pc = $db20 "Character color" virtual
.fill 200,0