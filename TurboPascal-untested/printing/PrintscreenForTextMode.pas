(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0034.PAS
  Description: PrintScreen for Text Mode
  Author: SWAG SUPPORT TEAM
  Date: 02-15-94  08:05
*)

Unit PrntScrn;     (* PrintScreen Unit for regular text modes *)

(*--*)  Interface  (*--*)

Procedure PrintScreen;

(*--*)  Implementation  (*--*)

Uses Dos,Crt,Printer;

Procedure PrintScreen;
Var
  line : string[80];
  x,y : integer;
  Ms : Registers;

Begin
  Ms.Ax := $10 shl 8 + $1a;       (* Read the current Page state *)
  Intr($10,Ms);
  For y := 1 to 25 do Begin       (* Do lines 1 to 25 *)
    Line := '';
    For x := 1 to 80 do Begin     (* and columns 1 to 80 *)
      Gotoxy(x,y);                (* Move cursor *)
      Ms.Ax := $8 shl 8;          (* Read character at cursor *)
      Intr($10,Ms);
      Line := Line + Chr(Lo(Ms.Ax));   (* Add to total line *)
    End;
    Writeln(lst,Line);            (* Write to printer *)
  End;
End;

End.  (* PrntScrn UNIT *)
