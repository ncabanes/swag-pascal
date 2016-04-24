(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0012.PAS
  Description: Dealing with File Share
  Author: LARS HELLSTEN
  Date: 06-22-93  09:23
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 06-16-93 (16:14)             Number: 26531
From: LARS HELLSTEN                Refer#: NONE
  To: RITO SALOMONE                 Recvd: NO  
Subj: Re: Novell/File Locking/S      Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
RS> Does anyone have any samples of network file sharing/access code for Turbo
RS> Pascal/Borland Pascal 6-7.

   Here's some source that I use.  I haven't had a chance to test it out
as much as I'd like to, but so far, it appears to work quite nicely:

--- 8< --------------------------------------------------------------------
Unit Share;

INTERFACE

Uses DOS;

Var
   ShareInstalled : Boolean;

Function LockRec(Var Untyped; pos, size : LongInt) : Boolean;
Function UnLockRec(Var Untyped; pos, size : LongInt) : Boolean;
Procedure FMode(Mode : Byte);
Function Share : Boolean;

IMPLEMENTATION

Function LockRec(Var Untyped; pos, size : LongInt) : Boolean;

Var
   Regs : Registers;
   f : File absolute Untyped;

Begin
   pos := pos * FileRec(f).RecSize;
   size := size * FileRec(f).RecSize;
   Regs.AH := $5C;
   Regs.AL := $00;
   Regs.BX := FileRec(f).Handle;
   Regs.CX := Hi(pos);
   Regs.DX := Lo(pos);
   Regs.SI := Hi(size);
   Regs.DI := Lo(size);
   Intr($21,Regs);
   LockRec := (Regs.Flags AND FCarry) = 0;
End; { LockRec }

Function UnLockRec(Var Untyped; pos, size : LongInt) : Boolean;

Var
   Regs : Registers;
   f : File absolute Untyped;

Begin
   pos := pos * FileRec(f).RecSize;
   size := size * FileRec(f).RecSize;
   Regs.AH := $5C;
   Regs.AL := $01;
   Regs.BX := FileRec(f).Handle;
   Regs.CX := Hi(pos);
   Regs.DX := Lo(pos);
   Regs.SI := Hi(size);
   Regs.DI := Lo(size);
   Intr($21,Regs);
   UnlockRec := (Regs.Flags AND FCarry) = 0;
End; { UnLockRec }

Procedure FMode(Mode : Byte);

Begin
   If ShareInstalled then
      If (mode in [0..2,23..24,48..50,64..66]) then
         FileMode := Mode;
End;

function Share : boolean;
var regs : registers;
begin
    with regs do
    begin
        AH := 16;
        AL := 0;
        Intr($2f, regs);
        Share := AL = 255;
    end;
end; { IsShare }

Begin
   ShareInstalled := Share;
End. { MyShare }
--- 8< ---------------------------------------------------------------------

   By the way, the unit name should be "MyShare", there's duplicate
identifiers in there by accident.  All you do, is call the lock/unlock
routines, passing the file variable, the record number, and the number of
records (you'll see it determines the size itself, using the FileRec.RecSize
variable).  The FMode procedure doesn't do much, I just use it instead of
constantly putting "If ShareInstalled then FileMode :=..." inside the
program(s).  You should call this to set the FileMode variable to a sharing
method, before you reset the file.  Here's a table of values you can pass:

                                         Sharing Method
Access Method   Compatibility  Deny Write  Deny Read  Deny None
-------------------------------------------------------------------
Read Only             0            32         48         64
Write Only            1            33         49         65
Read/Write            2            34         50         66
-------------------------------------------------------------------

--- GEcho 1.00
 * Origin: Access-PC BBS ■ Scarborough, ON ■ (416)491-9249 (1:250/320)

