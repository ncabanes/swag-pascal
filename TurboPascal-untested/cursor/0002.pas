Unit cursor;

(*
 *  CURSOR v1.1 - a Unit to provide extended control of cursor shape.
 *
 *  Public Domain 1991 by John Giesbrecht (1:247/128)
 *
 *  Notes:
 *
 *  - This version requires Turbo Pascal 6.0 or later.
 *  - These routines affect only the cursor on page 0.
 *  - This Unit installs an Exit Procedure which restores the cursor
 *    to its original shape when the Programme terminates.
 *)

Interface

Procedure cursoroff;
Procedure cursoron;           (* original cursor shape *)

Procedure blockcursor;
Procedure halfblockcursor;
Procedure linecursor;         (* Default Dos cursor    *)

Procedure setcursor(startline, endline : Byte);
Procedure getcursor(Var startline, endline : Byte);

(********************************************************************)

Implementation

Const
  mono = 7;

Var
  origstartline,
  origendline,
  mode : Byte;
  origexitproc : Pointer;

(********************************************************************)
Procedure setcursor(startline, endline : Byte); Assembler;

Asm
  mov ah, $01
  mov ch, startline
  mov cl, endline
  int $10
end;
(********************************************************************)
Procedure getcursor(Var startline, endline : Byte); Assembler;

Asm
  mov ah, $03
  mov bh, $00
  int $10
  les di, startline
  mov Byte ptr es:[di], ch
  les di, endline
  mov Byte ptr es:[di], cl
end;
(********************************************************************)
Procedure cursoroff;

begin
  setcursor(32, 32);
end;
(********************************************************************)
Procedure cursoron;

begin
  setcursor(origstartline, origendline);
end;
(********************************************************************)
Procedure blockcursor;

begin
  if mode = mono
    then setcursor(1, 12)
    else setcursor(1, 7);
end;
(********************************************************************)
Procedure halfblockcursor;

begin
  if mode = mono
    then setcursor(7, 12)
    else setcursor(4, 7);
end;
(********************************************************************)
Procedure linecursor;
begin
  if mode = mono
    then setcursor(11, 12)
    else setcursor(6, 7);
end;
(********************************************************************)
Procedure restorecursor; Far;

begin
  system.exitproc := origexitproc;
  cursoron;
end;
(**  I N I T I A L I Z A T I O N  ***********************************)
begin
 getcursor(origstartline, origendline);
 Asm
  mov ah, $0F
  int $10
  mov mode, al
 end;
 origexitproc := system.exitproc;
 system.exitproc := addr(restorecursor);
end.
