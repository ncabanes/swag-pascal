(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0042.PAS
  Description: Trap Runtime Errors
  Author: FRANK HECKENBACH
  Date: 05-31-96  09:16
*)

UNIT BPTrap;  { see DEMO at the bottom !! }

{ Trap runtime errors, Version 1.0
  Copyright (C) 1991-1996 by Frank Heckenbach, heckenb@mi.uni-erlangen.de

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, version 1, for NON-COMMERCIAL use.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. }

{$IFNDEF VER70}
This unit was tested only with Borland Pascal 7.0. You can use it with other
versions by commenting these two lines, but at your own risk!
{$ENDIF}

INTERFACE

FUNCTION  Trap:Boolean; FAR;
{* Returns False on installation.
 * After trapping a runtime error it jumps back to where the function was
   called returning True.
 * The procedure that calls Trap must NOT return as long as Trap is installed
   (so it is safest to call Trap from the main program, if possible)!
 * You must call this function AFTER installing all other Exitprocs (if any).
 * In Real mode: You must NOT call it from an overlayed unit.
 * In Protected mode and Windoze: You must call it from a code segment with
   the following attributes: FIXED PRELOAD PERMANENT. (I am not sure if this
   is really necessary...).}

FUNCTION UnTrap:Boolean;
{Returns True iff Trap could be uninstalled.}

IMPLEMENTATION

TYPE ptrrec=RECORD ofs,sgm:Word END;

CONST
  addrsave:Pointer=NIL;
  codesave:Word=0;

VAR
  exitsave,trapaddr:Pointer;
  trapsp,trapbp:Word;

{$S-}
PROCEDURE Trapexit; FAR;
BEGIN
  IF Erroraddr<>NIL
    THEN {Trapping runtime error}
      BEGIN
        {Install Trapexit again (in case another runtime error occurs later)!}
        Exitproc:=@Trapexit;

        {Keep error address and exit code and reset these variables}
        addrsave:=Erroraddr;
        codesave:=Exitcode;
        Erroraddr:=NIL;
        Exitcode:=0;

        {If you want, you can do something here to indicate the user that an
         error occurred. You could e.g. pop up a message telling the user to
         quit the program asap and report the error to the programmer.}

        ASM
          {Load the saved SP and BP registers}
          MOV  SP,trapsp
          MOV  BP,trapbp

          {Continue at saved address returning True}
          MOV  AL,1
          JMP  [trapaddr]
        END
      END

    ELSE {Programm finished without an error}
      BEGIN
        {Continue with other exit procs}
        Exitproc:=exitsave;

        {Restore error address and exit code of the last trapped error, if any}
        IF addrsave<>NIL THEN
          BEGIN
            Erroraddr:=addrsave;
            Exitcode:=codesave
          END
      END
END;

FUNCTION Trap:Boolean; ASSEMBLER;
ASM
   {Install Trapexit as an Exitproc}
   MOV  AX,OFFSET Trapexit
   MOV  DX,SEG Trapexit
   CMP  Exitproc.ptrrec.ofs,AX
   JNE  @1
   CMP  Exitproc.ptrrec.sgm,DX
   JE   @2
@1:XCHG Exitproc.ptrrec.ofs,AX
   XCHG Exitproc.ptrrec.sgm,DX
   MOV  exitsave.ptrrec.ofs,AX
   MOV  exitsave.ptrrec.sgm,DX

   {Save SP and BP registers and the return address}
@2:MOV  trapbp,BP
   MOV  SI,SP
   {$IFDEF WINDOWS}
   ADD  SI,4
   ADD  trapbp,6
   {$ENDIF}
   LES  DI,SS:[SI]
   MOV  trapaddr.ptrrec.ofs,DI
   MOV  trapaddr.ptrrec.sgm,ES
   ADD  SI,4
   MOV  trapsp,SI

   {Return False}
   XOR  AX,AX
END;

FUNCTION UnTrap:Boolean;
BEGIN
  IF Exitproc=@Trapexit
    THEN
      BEGIN
        Exitproc:=exitsave;
        UnTrap:=True
      END
    ELSE UnTrap:=False
END;
END.


{ -----------------------  DEMO PROGRAM --------------------- }

PROGRAM TrapDemo;
{ Demo program for BPTrap unit, Version 1.0
  Copyright (C) 1996 by Frank Heckenbach, heckenb@mi.uni-erlangen.de

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, version 1, for NON-COMMERCIAL use.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. }

{$C FIXED PRELOAD PERMANENT} {Not necessary for real mode.}

USES BPTrap{$IFDEF WINDOWS},Wincrt{$ENDIF};

VAR a,b:Byte;

BEGIN
  Writeln;
  Writeln('TrapDemo version 1.0, Copyright (C) 1996 by Frank Heckenbach');
  Writeln('TrapBP and TrapDemo come with ABSOLUTELY NO WARRANTY.');
  Writeln('This is free software, and you are welcome to redistribute it');
  Writeln('under certain conditions for NON-COMMERCIAL use.');
  Writeln('For details see the file COPYING.');
  Writeln;
  Writeln('Before the trap...');
  Writeln;
  Randomize;
  IF NOT Trap THEN
    REPEAT
      a:=Random(10);
      b:=Random(10);
      Writeln(a,'/',b,'=',a/b)
    UNTIL False;
  Writeln('Infinity.');
  Write('Press Enter.');
  Readln;
  Write('The program caused a... ')
END.

