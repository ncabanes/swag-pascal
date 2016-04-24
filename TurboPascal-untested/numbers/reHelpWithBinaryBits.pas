(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0066.PAS
  Description: re: Help With Binary Bits
  Author: RICK HAINES
  Date: 02-28-95  09:48
*)


 { This code is untested, but should work correctly }

 { A word is arranged like this...                     }

 { The Word   -  0  0  0  0  0  0 0 0 0 0 0 0 0 0 0 0  }
 { Bit Number - 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0  }

Const
 Bit0 = 1;
 Bit1 = 2;
 Bit2 = 4;
 Bit3 = 8;
 Bit4 = 16;
 Bit5 = 32;
 Bit6 = 64;
 Bit7 = 128;

 Bit8 = 256;
 Bit9 = 512;
 Bit10 = 1024;
 Bit11 = 2048;
 Bit12 = 4096;
 Bit13 = 8192;
 Bit14 = 16384;
 Bit15 = 32768;

Procedure SetBit(SetWord, BitNum : Word);
 Begin
  SetWord := SetWord Or BitNum;     { Set bit }
 End;

Procedure ClearBit(SetWord, BitNum : Word);
 Begin
  SetWord := SetWord Or BitNum;     { Set bit    }
  SetWord := SetWord Xor BitNum;    { Toggle bit }
 End;

Procedure ToggleBit(SetWord, BitNum : Word);
 Begin
  SetWord := SetWord Xor BitNum;    { Toggle bit }
 End;

 Function GetBitStat(SetWord, BitNum : Word) : Boolean;
  Begin
   If SetWord And BitNum = BitNum Then            { If bit is set }
    GetBitStat := True Else GetBitStat := False;
  End;



 SetWord is the word that contains the bit you want to set.  BitNum is
 the number of the bit you want to set as defined in the const section
 (Bit0, Bit1, etc...). GetBitStat returns true if the bit is Set,
 otherwise it returns false.

                                                        -Rick


