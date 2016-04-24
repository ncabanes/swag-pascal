(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0002.PAS
  Description: Change Default Drive
  Author: GREG ESTABROOKS
  Date: 05-28-93  13:38
*)

{ Author: Greg Estabrooks }
Program DriveInf;
Uses
  Crt,                        (* ClrScr routine                   *)
  Dos;                        (* Register Type, Intr() Routine    *)
Var
  Regs :Registers;            (* To hold register info For Intr() *)
  CH   :Char;                 (* To hold Drive to change to       *)


Function GetDrive :Byte;
                (* Routine to Determine the default drive             *)
begin
  Regs.AX := $1900;                (* Function to determine drive     *)
  Intr($21,Regs);                  (* Call Dos int 21h                *)
  GetDrive := Regs.AL;             (* Return Proper result            *)
        (* Returns  0 = A, 1 = B, 2 = C, ETC                          *)
end;

Procedure ChangeDrive( Drive :Byte );
                (* Routine to change default drive                    *)
begin
  Regs.AH := $0E;                (* Function to change Drives         *)
  Regs.DL := Drive;              (* Drive to change to                *)
  Intr($21,Regs);                (* Call Dos Int 21h                  *)
end;

Function NumDrives :Byte;
                (* Routine to determine number of valid drives        *)
Var
  CurDrive :Byte;             (* Temporary storage For current drive*)
begin
  CurDrive := GetDrive;         (* Find out the current drive         *)
  Regs.AH := $0E;               (* Function to change drives          *)
  Regs.DL := CurDrive;          (* Change to current drive            *)
  Intr($21, Regs);              (* Call Dos                           *)
  NumDrives := Regs.AL;         (* Return proper info to user         *)
end;

begin
  ClrScr;                        (* Clear the screen                  *)
                                 (* Write Current Drive to  Screen    *)
  Writeln('Current Drive Is : ',CHR(GetDrive+65 ),':\');
  Write('What Drive do you wish to change to ?[A..');
  WriteLn(CHR(NumDrives + 64 ),']');
  CH := ReadKey;                 (* Get Choice                        *)
  CH := UpCase( CH );            (* Convert to uppercase              *)
  ChangeDrive( Ord( CH )-65 );   (* Change to chosen drive            *)
end.
(**********************************************************************)


{        And here are the above in Inline Asm. I hope these help. }

Function GetDrive :Byte; Assembler;
                    {  Routine to Determine the default drive           }
Asm
  Mov AX,$1900                  {  Function to determine drive          }
  Int $21                       {  Call Dos int 21h                     }
                    { Returns  0 = A, 1 = B, 2 = C, ETC                 }
end;{GetDrive}

Procedure ChangeDrive( Drive :Byte ); Assembler;
                    {  Routine to change default drive                  }
                    {  0 = A, 1 = B, 2 = C, ETC                         }
Asm
  Mov AH,$0E                     {  Function to change Drives           }
  Mov DL,Drive                   {  Drive to change to                  }
  Int $21                        {  Call Dos Int 21h                    }
end;{ChangeDrive}

Function NumDrives :Byte; Assembler;
                     {  Routine to determine number of valid drives   }
Asm
  Call GetDrive                {  Find out the current drive, Returns }
                               {  Drive in AL                         }
  Mov AH,$0E                   {  Function to change drives           }
  Mov DL,AL                    {  Change to current drive             }
  Int $21                      {  Call Dos                            }
                               {  Number of drives is returns in AL   }
end;{NumDrives}


