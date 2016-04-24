(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0071.PAS
  Description: File Allocation Unit Size
  Author: MIGUEL MARTINEZ
  Date: 05-25-94  08:14
*)

{
 ▒ Anybody know a realitively easy way to determine the file allocation
 ▒ unit size offa hard/floppy drive??  Pascal source would be prefered over
 ▒ pascal assembly as I know next to nothing about assembly.
}
{───────────────────────────────────────────────────────────────}
Function GetUA(Drive: Byte:LongInt; {0=Default, 1=A, 2=B,..etc .}
Var regs:Registers;
Begin
  regs.ah:=$1C;   { Int 21h, Function 1Ch: Get drive data       }
                  { * Parameters:                               }
  regs.dl:=Drive; {     DL = Drive code                         }
  intr($21,regs); { Call function.                              }
                  { * Returns:                                  }
                  {     AL = Sectors per cluster                }
                  {     DS:DX = Segment:Offset of ID byte       }
                  {     CX = Physical sector length (bytes)     }
                  {     DX = Number of clusters of default unit }
  GetUA:=regs.al*regs.cx; { Returns SPC*SL                      }
End;

