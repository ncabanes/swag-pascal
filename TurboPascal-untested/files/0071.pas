{
Here are some routines for Hiding files, making read only files and
stuff.  Let me know what you think.  Any comments, criticism, or rude
remarks are welcome.

{ ********************************************************** }
{ *********************** Files Unit *********************** }
{ ********************************************************** }
{ **************** Written by: Rick Haines ***************** }
{ ********************************************************** }
{ ***************** Last Revised 02/02/95 ****************** }
{ ********************************************************** }

Unit Files;

Interface

 { Note: All FileNames MUST end in a null Char }
 { EX:   HideFile(FileName+#0);                }
 { EX:   HideFile('MyFile.Exe'+#0);            }

 Function HideFile(FileName : String) : Byte;     { Hide FileName }
 Function SystemFile(FileName : String) : Byte;   { Make FileName a System File }
 Function ReadOnlyFile(FileName : String) : Byte; { Make FileName ReadOnly }
 Function NormalFile(FileName : String) : Byte;   { Make FileName a Normal File }
 Function FileAttributes(FileName : String) : Integer; { Returns Attributes of   }

Implementation

 Function HideFile(FileName : String) : Byte; Assembler;
  Asm
   Push DS           { Push Data Segment                  }
   LDS DX, FileName  { Nul Terminated String of FileName  }
   Inc DX            { Get Rid Of Length Byte             }
   Mov AH, 43h       { Dos Function 43h, File Change Mode }
   Mov AL, 1         { Change Attributes                  }
   Mov CX, 2         { Bit 1, Hide It                     }
   Int 21h           { Call Dos                           }
   JC @Done          { See if there was an error          }
   Mov AL, 0         { If Not, Then No Error              }
  @Done:
   Pop DS            { Pop Data Segment                   }
  End;

 Function SystemFile(FileName : String) : Byte; Assembler;
  Asm
   Push DS           { Push Data Segment                  }
   LDS DX, FileName  { Nul Terminated String of FileName  }
   Inc DX            { Get Rid Of Length Byte             }
   Mov AH, 43h       { Dos Function 43h, File Change Mode }
   Mov AL, 1         { Change Attributes                  }
   Mov CX, 4         { Bit 3, System File                 }
   Int 21h           { Call Dos                           }
   JC @Done          { See if there was an error          }
   Mov AL, 0         { If Not, Then No Error              }
  @Done:
   Pop DS            { Pop Data Segment                   }
  End;

 Function ReadOnlyFile(FileName : String) : Byte; Assembler;
  Asm
   Push DS           { Push Data Segment                  }
   LDS DX, FileName  { Nul Terminated String of FileName  }
   Inc DX            { Get Rid Of Length Byte             }
   Mov AH, 43h       { Dos Function 43h, File Change Mode }
   Mov AL, 1         { Change Attributes                  }
   Mov CX, 1         { Bit 0, Read Only                   }
   Int 21h           { Call Dos                           }
   JC @Done          { See if there was an error          }
   Mov AL, 0         { If Not, Then No Error              }
  @Done:
   Pop DS            { Pop Data Segment                   }
  End;

 Function NormalFile(FileName : String) : Byte; Assembler;
  Asm
   Push DS           { Push Data Segment                  }
   LDS DX, FileName  { Nul Terminated String of FileName  }
   Inc DX            { Get Rid of Length Byte             }
   Mov AH, 43h       { Dos Function 43h, File Change Mode }
   Mov AL, 1         { Change Attributes                  }
   Mov CX, 0         { Nothing, UnEverything it           }
   Int 21h           { Call Dos                           }
   JC @Done          { See if there was an error          }
   Mov AL, 0         { If not, then no error              }
  @Done:
   Pop DS            { Pop Data Segment                   }
  End;

 Function FileAttributes(FileName : String) : Integer; Assembler;
  Asm
   Push DS           { Push Data Segment                  }
   LDS DX, FileName  { Nul Terminated String of FileName  }
   Inc DX            { Get Rid of Length Byte             }
   Mov AH, 43h       { Dos Function 43h, File Change Mode }
   Mov AL, 0         { Return Attributes                  }
   Int 21h           { Call Dos                           }
   JC @Error         { See if there was an error          }
   Mov AX, CX        { Return Attributes                  }
   Jmp @Done
  @Error:
   Mov AX, -1        { Return -1 For Error                }
  @Done:
   Pop DS            { Pop Data Segment                   }
  End;

End.
