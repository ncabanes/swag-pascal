(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0070.PAS
  Description: String Conversions
  Author: GREG ESTABROOKS
  Date: 01-27-94  13:34
*)

{***********************************************************************}
UNIT Strings;           {  String Conversion Routines,                  }
                        {  Last Updated Dec 07/93                       }
                        {  Copyright (C) 1993, Greg Estabrooks          }
                        {  NOTE: Requires TP 6.0+ to compile.           }
INTERFACE
(************************************************************************)
CONST
     HexList :ARRAY[0..15] OF CHAR ='0123456789ABCDEF';

FUNCTION BHex( V :BYTE ) :STRING;
FUNCTION WHex( V :WORD ) :STRING;
FUNCTION LHex( Long :LONGINT ) :STRING;
PROCEDURE UpperCase( VAR UpStr :STRING );
PROCEDURE LowerCase( VAR LoStr :STRING );

IMPLEMENTATION
(************************************************************************)
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
                       { Routine to convert a byte to a Hex string.     }
BEGIN
  BHex := HexList[V Shr 4] + HexList[V Mod 16];
END;

FUNCTION WHex( V :WORD ) :STRING;
                       { Routine to convert a word to a Hex string.     }
BEGIN
  WHex := Bhex(Hi(V)) + BHex(Lo(V));
END;

FUNCTION LHex( Long :LONGINT ) :STRING;
                       { Routine to convert a longint to a Hex string.  }
BEGIN
  LHex := WHex(HiWord(Long))+WHex(LoWord(Long));
END;

PROCEDURE UpperCase( VAR UpStr :STRING ); ASSEMBLER;
                     {  Routine to convert string to uppercase          }
ASM
  Push ES                       {  Save Registers to be used            }
  Push DI
  Push CX
  LES DI,UpStr                  {  Point ES:DI to string to be converted}
  Sub CX,CX                     {  Clear CX                             }
  Mov CL,ES:[DI]                {  Load Length of string for looping    }
  Cmp CX,0                      {  Check for a clear string             }
  JE @Exit                      {  If it was then exit                  }
@ReadStr:
  Inc DI                        {  Point to next Character              }
  Cmp BYTE PTR ES:[DI],'z'      {  If Character above 'z' jump to end of}
  Ja @LoopEnd                   {  loop.                                }
  Cmp BYTE PTR ES:[DI],'a'      {  if below 'a' jump to end of loop.    }
  Jb @LoopEnd
  Sub BYTE PTR ES:[DI],32       {  If not make it upper case            }
@LoopEnd:
  Loop @ReadStr                 {  Loop Until done                      }
@Exit:
  Pop CX                        {  Restore registers                    }
  Pop DI
  Pop ES
END;{UpperCase}

PROCEDURE LowerCase( VAR LoStr :STRING ); ASSEMBLER;
                     {  Routine to convert a string to lower case       }
ASM
  Push ES                       {  Save Registers to be used            }
  Push DI
  Push CX
  LES DI,LoStr                  {  Point ES:DI to string to be converted}
  Sub CX,CX                     {  Clear CX                             }
  Mov CL,ES:[DI]                {  Load Length of string for looping    }
  Cmp CX,0                      {  Check for a clear string             }
  JE @Exit                      {  If it was then exit                  }
@ReadStr:
  Inc DI                        {  Point to next Character              }
  Cmp BYTE PTR ES:[DI],'Z'      {  If Character above 'Z' jump to end of}
  Ja @LoopEnd                   {  loop.                                }
  Cmp BYTE PTR ES:[DI],'A'      {  if below 'A' jump to end of loop.    }
  Jb @LoopEnd
  Add BYTE PTR ES:[DI],32       {  If not make it Lower case            }
@LoopEnd:
  Loop @ReadStr                 {  Loop Until done                      }
@Exit:
  Pop CX                        {  Restore registers                    }
  Pop DI
  Pop ES
END;{LowerCase}

BEGIN
END.
{***********************************************************************}
