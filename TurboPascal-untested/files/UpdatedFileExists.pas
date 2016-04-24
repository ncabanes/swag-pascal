(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0077.PAS
  Description: Updated File Exists
  Author: JOHN O'HARROW
  Date: 09-04-95  10:49
*)

(*
In an earlier release of SWAG Andrew Eigus provided code for a fast
'FileExist' function.

The function however has a potential bug in that the filename passed
into the function must be ASCIIZ (null terminated) to work correctly.
It will also return a TRUE result for a directory name or the volume ID.

My 'EntryExists' function below includes the extra code to convert the
filename to ASCIIZ and has been optimised for speed slightly by replacing
the Jump instruction.

My 'FileExists' function below is an extended version which returns TRUE
for files only (not a directory entry or volume ID).

*)

FUNCTION EntryExists(FileName : String) : Boolean; ASSEMBLER;
ASM
  PUSH DS          {Save DS                         }
  LDS  SI,Filename {DS:SI => Filename               }
  XOR  BX,BX       {Clear BX                        }
  MOV  BL,[SI]     {BX = Length(Filename)           }
  INC  SI          {DS:SI => Filename[1]            }
  MOV  DX,SI       {DS:DX => Filename[1]            }
  MOV  [SI+BX],BH  {Append Ascii 0 to Filename      }
  MOV  AX,4300h    {Get Attribute Function Code     }
  INT  21h         {Get File Attributes             }
  MOV  AL,BH       {Set Default Result to FALSE     }
  CMC              {Toggle Carry Flag               }
  ADC  AL,AL       {Change Result to TRUE if Failed }
  POP  DS          {Restore DS                      }
END; {EntryExists}

FUNCTION FileExists(FileName : String) : Boolean; ASSEMBLER;
ASM
  PUSH DS          {Save DS                         }
  LDS  SI,Filename {DS:SI => Filename               }
  XOR  BX,BX       {Clear BX                        }
  MOV  BL,[SI]     {BX = Length(Filename)           }
  INC  SI          {DS:SI => Filename[1]            }
  MOV  DX,SI       {DS:DX => Filename[1]            }
  MOV  [SI+BX],BH  {Append Ascii 0 to Filename      }
  MOV  AX,4300h    {Get Attribute Function Code     }
  INT  21h         {Get File Attributes             }
  MOV  AL,BH       {Default Result = FALSE          }
  ADC  CL,CL       {Attribute * 2 + Carry Flag      }
  AND  CL,31h      {Directory or VolumeID or Failed }
  JNZ  @@Done      {Yes - Exit                      }
  INC  AL          {No - Change Result to TRUE      }
@@Done:
  POP  DS          {Restore DS                      }
END; {FileExists}

CONST
  Found : ARRAY[Boolean] OF String[10] = ('Not Found', 'Found');
VAR
  FileName : String;

BEGIN
  Write('Enter file name to search: ');
  ReadLn(FileName);
  WriteLn('File "', FileName, '" ', Found[EntryExists(FileName)], '.');
END.

