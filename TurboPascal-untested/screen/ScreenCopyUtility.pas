(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0020.PAS
  Description: Screen Copy Utility
  Author: SWAG SUPPORT TEAM
  Date: 06-22-93  09:22
*)

unit scrncopy;
interface

Const
         bord : ARRAY [0..2, 0..5] Of Byte = (
         ( 32, 32, 32, 32, 32, 32),
         ( 196, 179, 218, 191, 217, 192),
         ( 205, 186, 201, 187, 188, 200));

procedure copyscrn (scrn1,scrn2 : Byte);
{copy the screen}

Procedure savescrn (scrn : Byte);
{saves the designated screen in RAM memory}

Procedure restorescrn (scrn : Byte);
{restores the screen to the designated page}

procedure drawborder (Fg,Bg,ur,lc,lr,rc,lines,page : Word);
{draw the borders, optionally clears the screen}
{Fg is the foreground color, Bg is the background color,
 ur is the upper row, lc is the left column,
 lr is the lower row, rc is the right column,
 lines is:
   0 for clear screen;
   1 for single lines (─┐);
   2 for double lines (═╗);
 page is the screen page to draw the border on}

implementation
Type
        Hold = ARRAY[0..4047] Of Byte;

VAR
        x : Word;
        tmpscrn : ^Hold;
Procedure copyscrn (scrn1, scrn2 : Byte);
Begin
        For x := 0 To 4047 Do
            Mem[$B800:(scrn2*$1000+x)] := Mem[$B800:(scrn1*$1000+x)];
End;
Procedure savescrn (scrn : Byte);
Begin
        New(tmpscrn);
        For x := 0 To 4047 Do
            tmpscrn^[x] := Mem[$B800:(scrn*$1000+x)];
End;

Procedure restorescrn (scrn : Byte);
Begin
        For x := 0 To 4047 Do
            Mem[$B800:(scrn*$1000+x)] := tmpscrn^[x];
            Dispose(tmpscrn);
End;

Procedure drawborder (Fg,Bg,ur,lc,lr,rc,lines,page : Word);
VAR
        x, y, point : Word;
Begin
        page := $B800 + (page * $100);
        Fg := 16 * Bg + Fg;
        Dec(ur);
        Dec(lc);
        Dec(lr);
        Dec(rc);
        point := ur * 80 * 2 + lc * 2;
        Mem[page:point] := bord[lines,2];
        Mem[page:point + 1] := Fg;
        point := point + 2;
        For x := point To (ur * 80 * 2 + (rc-1) * 2) + 1 Do Begin
            Mem[page:x] := bord[lines,0];
            Inc(x);
            Mem[page:x] := Fg;
            End;
        point := ur * 80 * 2 + rc * 2;
        Mem[page:point] := bord[lines,3];
        Mem[page:point+1] := Fg;
        For x := ur + 1 To lr - 1 Do Begin
            point := x * 80 * 2 + lc * 2;
            Mem[page:point] := bord[lines,1];
            Mem[page:point + 1] := Fg;
            For y := lc + 1 To rc - 1 Do Begin
                point := x * 80 * 2 + y * 2;
                Mem[page:point] := 32;
                Mem[page:point+1] := Fg;
                End;
            point := x * 80 * 2 + rc * 2;
            Mem[page:point] := bord[lines,1];
            Mem[page:point + 1] := Fg;
            End;
        point := lr * 80 * 2 + lc * 2;
        Mem[page:point] := bord[lines,5];
        Mem[page:point + 1] := Fg;
        point := point + 2;
        For x := point To (lr * 80 * 2 + (rc-1) * 2) + 1 Do Begin
            Mem[page:x] := bord[lines,0];
            Inc(x);
            Mem[page:x] := Fg;
            End;
        point := lr * 80 * 2 + rc * 2;
        Mem[page:point] := bord[lines,4];
        Mem[page:point+1] := Fg;
End;

End.


