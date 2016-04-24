(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0112.PAS
  Description: Return Letter of CDROM drive
  Author: ERWIN PAGUIO
  Date: 05-31-96  09:16
*)

{
The returned value of FirstDrive is an unsigned integer where 0 = 'A', 1 = 'B',

and so on.  So to get the actual drive letter you use:

   FirstDriveLetter := Chr(FirstDrive + Ord('A'));

   LastDriveLetter  := Chr(FirstDrive + NumDrives + Ord('A'));

}

Function CheckCDROMDrives(Var FirstDrive, NumDrives : Word):Boolean;Assembler;

ASM
    XOR  BX, BX           { zero out BX to check availability of function }
    MOV  AX, 1500h        { get no. of CDROM drive letters                }
    INT  2Fh              { BX = count,  CX = first                       }
    OR   BX, BX           { was BX modified?                              }
    JZ   @Error           { if not, then no MSCDEX driver installed       }
    LES  DI, FirstDrive
    MOV  ES:[DI], CX      { device number of first drive                  }
    LES  DI, NumDrives
    MOV  ES:[DI], BX      { number of CD drives                           }
    MOV  AL, Byte(True)
    JMP  @Exit
 @Error:
    XOR  AX, AX
    LES  DI, FirstDrive
    MOV  ES:[DI], AX
    LES  DI, NumDrives
    MOV  ES:[DI], AX
    MOV  AL, Byte(False)
 @Exit:
 End;

