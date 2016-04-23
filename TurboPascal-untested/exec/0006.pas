{===================================================================
Date: 10-19-93 (19:37)
From: MAYNARD PHILBROOK
Subj: Re: Execwindow graphics
----------------------------------------------------------------------}
{$F+,I-,S-,D-}
{$m 1024, 0, 3000}

Uses Crt, Dos;
Var
OLD_29H :Pointer;
C   :Char;         { Holds Charactor to Write }
{$F+}

Procedure Patch1;
Interrupt;
Begin
    Write(C);
End;

Procedure Patch; Assembler;
  Asm
    Push DS
    Push Ax
        Mov   AX, Seg C;
        Mov   DS, AX;
        Pop   AX;
        Mov   C, Al;
        Pop   DS
        Jmp   Patch1;
  End;
Begin
 Clrscr;
 GetINtVec($29, OLD_29H);
 SetIntVec($29, @Patch);
 Window(14, 10, 40, 22);
 ClrScr;
 Exec('C:\Command.com',' /c dir');
 Readkey;
 SetIntVec($29, OLD_29h);
End.

The Command.com is just an example..
Note:
If your using ANSI.SYS in Dos, this will not use Anis..
TP uses its own screen writes, but this code directs all Dos Char Output
to the TP window.
To Stop echo of Dos functions or what ever, use the
> NULL at the end of the parms when executing..

--- MsgToss 2.0b
 * Origin: Sherwood Forest RBBS 203-455-0646 (1:327/453)
