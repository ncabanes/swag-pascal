{
From: GREG ESTABROOKS
Subj: Writing hexes
Is there a quick and easy way to convert an integer to a hex number?
example, if I have an integer num1:=32;  is there a way to print "20h
screen?
}

CONST
     HexList :ARRAY[0..15] OF CHAR ='0123456789ABCDEF';

FUNCTION HiWord( Long :LONGINT ) :WORD; ASSEMBLER;
                      { Routine to return high word of a LongInt.       }
ASM
  Mov AX,Long.WORD[2]              { Move High word into AX.            }
END;

FUNCTION LoWord( Long :LONGINT ) :WORD; ASSEMBLER;
                      { Routine to return low word of a LongInt.        }
ASM
  Mov AX,Long.WORD[0]              { Move low word into AX.             }
END;


FUNCTION BHex( V :BYTE ) :STRING;
BEGIN
  BHex := HexList[V Shr 4] + HexList[V Mod 16];
END;

FUNCTION WHex( V :WORD ) :STRING;
BEGIN
  WHex := Bhex(Hi(V)) + BHex(Lo(V));
END;

FUNCTION LHex( Long :LONGINT ) :STRING;
BEGIN
  LHex := WHex(HiWord(Long))+WHex(LoWord(Long));
END;
