


Bit
 7   6   5   4   3   2   1   0

128 064 032 016 008 004 002 001

TO check IF the last bit (7) is on OR off, you can DO something like..

FUNCTION isBitOn (n, b : BYTE) : BOOLEAN;
BEGIN isBitOn := ( (n SHR b) AND 1) = 1 END;

TO SET a specific bit TO on, DO something like...

PROCEDURE setBitOn (VAR n : BYTE;b : BYTE);
BEGIN n := n OR (1 SHL b) END;

PROCEDURE toggleBit (VAR n : BYTE;b : BYTE);
BEGIN n := n XOR (1 SHL b) END;

