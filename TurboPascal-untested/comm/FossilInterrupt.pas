(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0056.PAS
  Description: Fossil Interrupt
  Author: GERHARD HOOGTERP
  Date: 08-25-94  09:08
*)

{
From: gerhard@loipon.wlink.nl (Gerhard Hoogterp)

> > Anyhow, the point is usualy not which fossil is loaded but
> > if there is a fossil at all. And that's what the $1954 result is for.

>I now realize that $1954 will be returned for either BNU/X00, but I would
>still like to be able to list to screen "which" fossil has been detected,
>and I cannot seem to figure it out.

}
Uses Dos;

Const UsePort      = 0;

Type InfoArray     = Array[0..255] of Char;
     FossilInfo    = Record
      Size         : Word;        { Record Size         }
      MajVer       : Byte;        { Major Version       }
      MinVer       : Byte;        { Minor Version       }
      IndentPtr    : ^InfoArray;  { Indentifier         }
      InpSize      : Word;        { Size inp. Buffer    }
      InpFree      : Word;        { Free in inp. buffer }
      OutBuf       : Word;        { Size out. Buffer    }
      OutFree      : Word;        { Free in out. Buffer }
      SWidth       : Byte;        { Screen width        }
      SHeight      : Byte;        { Screen height       }
     End;

Var Info : FossilInfo;
    C    : Byte;

Procedure InitPort(Port : Word);
Var Regs : Registers;
Begin
With Regs Do
 Begin
 AH:=$04;
 DX := Port;
 Intr($14,Regs);
 If AX<>$1954
    Then Halt;
 End;
End;


Procedure GrabPortInfo(Port : Word);
Var Regs : Registers;
Begin
With Regs Do
 Begin
 AH:=$1B;
 DX:=Port;
 CX:=SizeOf(Info);
 ES:=Seg(Info);
 DI:=Ofs(Info);
 Intr($14,Regs);
 End;
End;


Procedure DonePort(Port : Word);
Var Regs : Registers;
Begin
With Regs Do
 Begin
 AH:=$05;
 DX:=Port;
 Intr($14,Regs);
 End;
End;


Begin
FillChar(Info,SizeOf(Info),#00);

InitPort(UsePort);
GrabPortInfo(UsePort);

WriteLn('Fossil ID:');
Write('  ');

C:=0;
While (C<256) And (Info.IndentPtr^[C]<>#00) Do
 Begin
 Write(Info.IndentPtr^[C]);
 Inc(C);
 End;
Writeln;

DonePort(UsePort);
End.


