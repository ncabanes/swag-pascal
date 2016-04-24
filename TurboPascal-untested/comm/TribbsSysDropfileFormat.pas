(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0079.PAS
  Description: TRIBBS.SYS Dropfile Format
  Author: SEAN LAURENT
  Date: 05-26-95  23:02
*)


{
Following this text is a basic guide to the format of the TRIBBS.SYS
dropfile, JSDoor code for reading in TRIBBS.SYS and storing it in a
DoorSysType variable, and code for a FileExists function that's used in the
TRIBBS_SYS code.



TRIBBS.SYS is TriBB's proprietary door data file.  It is an ASCII text file
and uses the following format:
 
1                  <- The user's record number
Sean Laurent       <- The user's name
Something          <- The user's password
200                <- The user's security level (0 - 9999)
Y                  <- Y for Expert, N for Novice
Y                  <- Y for ANSi, N for monochrome
60                 <- Minutes left this call
715-344-4142       <- The user's phone number
Stevens Point, Wi  <- The user's city and state
12/18/77           <- The user's birth date
1                  <- The node number
2                  <- The serial port
14400              <- Baud rate or 0 for local
38400              <- Locked rate or 0 for not locked
Y                  <- Y for RTS/CTS, N for no RTS/CTS
Y                  <- Y for error correcting or N
The Magic Of Krynn <- The board's name
Sean Laurent       <- The sysop's name

--------CUT HERE FOR TRIBBS.SYS REFERENCE-------

}
Uses Dos, Strings;

Procedure TRIBBS_SYS(Path : String; Var DropInfo : DoorSysType);
Var FF    : Text;
    FName : String;
    TempS : String;

    Code,
    Int   : Integer;
Begin
  FName:=Concat(Path,'TRIBBS.SYS');
  If not(FileExists(FName)) Then
    Halt(4);
  Assign(FF,FName);
  Reset(FF);
  Readln(FF,TempS);             {User record number}
  Readln(FF,DropInfo.UserName);
  Readln(FF,DropInfo.Password);

  Readln(FF,TempS);             {Security Level}
  Val(TempS,Int,Code);
  If (Code <> 0) Then
    DropInfo.Access:=0
  Else Begin
    If (Int > 255) Then
      DropInfo.Access:=255
    Else
      DropInfo.Access:=Int;
  End;

  Readln(FF,TempS);             {Expert Y/N}
  Readln(FF,TempS);             {Y = ANSI, N = Monochrome}

  Readln(FF,TempS);             {Minutes left}
  Val(TempS,Int,Code);
  If (Code <> 0) Then
    DropInfo.MinutesLeft:=30
  Else
    DropInfo.MinutesLeft:=Int;
  DropInfo.SecondsLeft:=0;

  Readln(FF,DropInfo.Phone);
  DropInfo.WorkPhone:=DropInfo.Phone;
  Readln(FF,DropInfo.UserCity);
  Readln(FF,TempS);             {Birth date}

  Readln(FF,TempS);             {Node Number}
  Val(TempS,Int,Code);
  If (Code <> 0) Then
    DropInfo.Node:=1
  Else
    DropInfo.Node:=Int;

  Readln(FF,TempS);             {Serial port}
  Val(TempS,Int,Code);
  If (Code <> 0) Then
    DropInfo.ComPort:=0
  Else
    DropInfo.ComPort:=Int;

  Readln(FF,TempS);             {Baud rate}
  Val(TempS,Int,Code);
  If (Code <> 0) Then
    DropInfo.BaudRate:=0
  Else
    DropInfo.BaudRate:=Int;

  Readln(FF,TempS);             {Locked rate}
  Readln(FF,TempS);             {RTS/CTS}
  Readln(FF,TempS);             {Error correcting}
  Readln(FF,DropInfo.BBSName);

  Close(FF);
End;

{
Note, FileExists doesn't actually open/close the file... Also, it's the
fastest I've seen...
}

Function FileExists(filename : String) : Boolean; Assembler;
 
  ASM
    PUSH   DS
    LDS    SI, [filename]      { make ASCIIZ }
    XOR    AH, AH
    LODSB
    XCHG   AX, BX
    MOV    Byte Ptr [SI+BX], 0
    MOV    DX, SI
    MOV    AX, 4300h           { get file attributes }
    INT    21h
    MOV    AL, False
    JC     @1                  { fail? }
    INC    AX

    @1: POP    DS
end;  { FileExists}

{
There is support for RIPScrip graphics, but I can't find the information
on it with relation to TRIBBS.SYS files.  Sorry.
Anyway, I hope this helps!
}

