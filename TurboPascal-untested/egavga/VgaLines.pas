(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0063.PAS
  Description: VGA Lines
  Author: ANDREW WOOLFSON
  Date: 11-02-93  08:10
*)

{
ANDREW WOOLFSON

I recall certain people discussing ways of drawing LINES in Pascal.
Unfortunately I'v lost the thread of those messages - BUT thought I could
add my endevours to this same task.
I hope this helps someone.

}
Program VGA_Line_Demo;
(***************************************************************************)
(* Designed, thought out and programmed by Andrew Woolfson {using TP v6.0} *)
(*                                                                         *)
(* Because you have lost all those handy Borland Graphic Functions, I have *)
(* had to redesign the second elementary function in graphics : THE LINE   *)
(* This proved very difficult, and so far this program is a example of the *)
(* best I have managed to do (using vector mathematics).                   *)
(*                                                                         *)
(* This program also shows VGA direct screen addressing in 320x200x256     *)
(* mode.                                                                   *)
(*                                                                         *)
(* I have not documented this program, as I feel it it fairly explanatory. *)
(* If you Do not understand any routine, dont hesitate to ask.             *)
(*            Please share your experiments as I have.                     *)
(***************************************************************************)

Uses
  Crt, Graph, DOS;

Var
  x, y, Loop : Integer;
  Key        : Char;
  Pixels     : Array [0..199,0..319] OF BYTE ABSOLUTE $A000:0000;
                       { NOTE: Y & X Coord's have been swapped }

Procedure InitializeVGA;
Var
  GraphDriver  : Integer;
  GraphMode    : Integer;
  PathtoDriver : String[8];
  Regs         : Registers;
Begin
  GraphDriver := VGA;
  GraphMode   := VGAHi;
  InitGraph(GraphDriver, GraphMode, 'e:\bp\bgi');

  Regs.AX := 19;
  intr($10, Regs);     { Interrupt 16 }
End;

Procedure Plot(X, Y, Color : Integer);
Begin
  Pixels[Y,X] := Color;
End;

Procedure Line(x1, y1, x2, y2, Color : Integer);
Var
  Loop,
  tx, ty   : Integer;
  Gradiant : Real;
Begin
  If ((x1 < x2) AND (y1 < y2)) OR
     ((x1 = x2) AND (y1 < y2)) OR
     ((x1 < x2) AND (y1 = y2)) Then
  Begin
    If (ABS(y2 - y1) + 1) / (ABS(x2 - x1) + 1) <= 1 Then
    Begin
      Gradiant := (ABS(y2 - y1) + 1) / (ABS(x2 - x1) + 1);
      For Loop := x1 To (x1 + ABS(x2 - x1)) Do
        Plot(Loop, (y1 + trunc((Loop - x1) * Gradiant)), Color);
    End
    else
    Begin
      Gradiant := (ABS(x2 - x1) + 1) / (ABS(y2 - y1) + 1);
      For Loop := y1 To (y1 + ABS(y2 - y1)) Do
        Plot((x1 + trunc((Loop - y1) * Gradiant)), Loop, Color);
    End;
  End;

  If (x1 > x2) AND (y1 < y2) Then
  Begin
    If (ABS(y2 - y1) + 1) / (ABS(x2 - x1) + 1) <= 1 Then
    Begin
      Gradiant := (ABS(y2 - y1) + 1) / (ABS(x2 - x1) + 1);
      For Loop := x2 To x1 Do
        Plot(Loop, (y1 + trunc((x1 - Loop) * Gradiant)), Color);
    End
    else
    Begin
      Gradiant := (ABS(x2 - x1) + 1) / (ABS(y2 - y1) + 1);
      For Loop := y1 To (y1 + ABS(y2 - y1)) Do
        Plot((x1 + trunc((y1 - Loop) * Gradiant)), Loop, Color);
    End;
  End;

  If ((x1 < x2) AND (y1 > y2)) Then
  Begin
    If (ABS(y2 - y1) + 1) / (ABS(x2 - x1) + 1) <= 1 Then
    Begin
      Gradiant := (ABS(y2 - y1) + 1) / (ABS(x2 - x1) + 1);
      For Loop := x1 To (x1 + ABS(x2 - x1)) Do
        Plot(Loop, y1 + trunc((x1 - Loop) * Gradiant), color);
    End
    else
    Begin
      ty := y1;
      y1 := y2;
      y2 := ty;
      Gradiant := (ABS(x2 - x1) + 1) / (ABS(y2 - y1) + 1);
      For Loop := y1 To (y1 + ABS(y2 - y1)) Do
        Plot(x2 + trunc((y1 - Loop) * Gradiant), Loop, color);
    End;
  End;

  If ((x1 > x2) AND (y1 > y2)) OR
     ((x1 = x2) AND (y1 > y2)) OR
     ((x1 > x2) AND (y1 = y2)) Then
  Begin
    tx := x1;
    ty := y1;
    x1 := x2;
    y1 := y2;
    x2 := tx;
    y2 := ty;
    If (ABS(y2 - y1) + 1) / (ABS(x2 - x1) + 1) <= 1 Then
    Begin
      Gradiant := (ABS(y2 - y1) + 1) / (ABS(x2 - x1) + 1);
      For Loop := x1 To (x1 + ABS(x2 - x1)) Do
        Plot(Loop, y1 + trunc((Loop - x1) * Gradiant), color);
    End
    else
    Begin
      Gradiant := (ABS(x2 - x1) + 1) / (ABS(y2 - y1) + 1);
      For Loop := y1 To (y1 + ABS(y2 - y1)) Do
        Plot(x1 + trunc((Loop - y1) * Gradiant), Loop, color);
    End;
  End;

End;

Begin
  InitializeVGA;

  SetRGBPalette(1,63, 0, 0);   { RED    }
  SetRGBPalette(2, 0,63, 0);   { GREEN  }
  SetRGBPalette(3, 0, 0,63);   { BLUE   }
  SetRGBPalette(4,63,63,63);   { WHITE  }

  For x := 50 To 250 Do
    Line(150, 100, x, 50, 1);
  For y := 50 To 150 Do
    Line(150, 100, 250, y, 2);
  For x := 250 Downto 50 Do
    Line(150, 100, x, 150, 3);
  For y := 150 Downto 50 Do
    Line(150, 100, 50, y, 4);

  Readln;
End.

