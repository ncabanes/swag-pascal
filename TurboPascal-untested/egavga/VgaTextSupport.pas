(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0060.PAS
  Description: VGA TEXT Support
  Author: WIM VAN DER VEGT
  Date: 10-28-93  11:40
*)

{===========================================================================
Date: 10-09-93 (10:40)
From: WIM VAN DER VEGT
Subj: textmodes w/43/50 lines
---------------------------------------------------------------------------
Here the uncodes sources of some routines I've written to replace
turbo's internal textmode routines to enable 43 & 50 lines textmodes on
VGA. They use the BIOS and can be combined with normal read/write
statements. Just use the unit and call one of the Vgaxxlines routines.

{---------------------------------------------------------}
{  Project : Vga Textmode Support                         }
{  By      : G.W. van der Vegt                            }
{---------------------------------------------------------}
{  Date  .time  Revision                                  }
{  931003.2200  Creatie.                                  }
{---------------------------------------------------------}

Unit Vts_01;

Interface

Function  MaxX : Byte;

Function  MaxY : Byte;

Function  WhereX : Byte;

Function  WhereY : Byte;

Procedure GotoXY(x,y : Byte);

Function  GetXY(x,y : Byte) : Char;

Procedure vga50lines;

Procedure vga43lines;

Procedure vga25lines;

{---------------------------------------------------------}

Implementation

Uses
  Dos;

{---------------------------------------------------------}

Function MaxX : Byte;

{----Return horizontal size of textmode in characters}

Var
  r      : Registers;

Begin
  r.ah:=$0F;
  Intr($10,r);
  MaxX:=r.AH;
End; {of MaxX}

{---------------------------------------------------------}

Function MaxY : Byte;

{----Return vertical size of textmode in characters}

Var
  r      : Registers;
  buf    : Array[0..63] Of byte;

Begin
  r.ah:=$1B;
  r.bx:=$00;
  r.es:=Seg(buf);
  r.di:=Ofs(buf);
  Intr($10,r);
  MaxY:=buf[$22];
End; {of MaxY}

{---------------------------------------------------------}

Function WhereX : Byte;

{----WhereX, aware of textmodes larger than 80x25}

Var
  r : registers;

Begin
  r.ah:=$0f;
  Intr($10,r);
  r.ah:=$03;
  Intr($10,r);
  WhereX:=r.dl;
End; {of WhereX}

{---------------------------------------------------------}

Function WhereY : Byte;

{----WhereY, aware of textmodes larger than 80x25}


Var
  r : registers;

Begin
  r.ah:=$0f;
  Intr($10,r);
  r.ah:=$03;
  Intr($10,r);
  WhereY:=r.dh;
End; {of WhereY}

{---------------------------------------------------------}

Procedure GotoXY(x,y : Byte);

{----GotoXY, aware of textmodes larger than 80x25}

Var
  r : registers;

Begin
  r.ah:=$0f;
  Intr($10,r);
  r.ah:=$02;
  r.dh:=y;
  r.dl:=x;
  Intr($10,r);
End; {of GotoXY}

{---------------------------------------------------------}

Function GetXY(x,y : Byte) : Char;

{----GetXY, returns char at x,y and is aware of textmodes larger than 80x25}
{           leave cursor unchanged.                                        }

Var
  r     : registers;
  xs,ys : Byte;
Begin
  xs:=WhereX;
  ys:=WhereY;
  GotoXY(x,y);
  r.ah:=$0f;
  Intr($10,r);
  r.ah:=$08;
  Intr($10,r);
  GetXY:=Chr(r.al);
  GotoXY(xs,ys);
End; {of GotoXY}

{---------------------------------------------------------}

Procedure vga50lines;

{----Put VGA display into 80x50 textmode}

Var
  r : registers;
  b : Byte;

Begin
{----50 line mode}
  b:=Mem[$40:$87];
  Mem[$40:$87]:=Mem[$40:$87] OR $01;
  r.ah:=$11;
  r.al:=$12; {----8x8 Character set}
  r.bl:=$00;
  Intr($10,r);
  Mem[$40:$87]:=b;

{----400 scan lines neccesary}
  r.ah:=$12;
  r.al:=$02; {----400}
  r.bl:=$30;
  Intr($10,r);
End; {of Vga50lines}

{---------------------------------------------------------}

Procedure vga43lines;

{----Put VGA display into 80x43 (EGA) textmode}

Var
  r : registers;
  b : Byte;

Begin
{----43 line mode}
  b:=Mem[$40:$87];
  Mem[$40:$87]:=Mem[$40:$87] OR $01;
  r.ah:=$11;
  r.al:=$12; {----8x8 Character set}
  r.bl:=$00;
  Intr($10,r);
  Mem[$40:$87]:=b;

{----350 scan lines neccesary}
  r.ah:=$12;
  r.al:=$01; {----350}
  r.bl:=$30;
  Intr($10,r);
End; {of Vga43lines}

{---------------------------------------------------------}

Procedure vga25lines;

{----Put VGA display into 80x25 textmode}

Var
  r : registers;
  b : Byte;

Begin
{----25 line mode}
  b:=Mem[$40:$87];
  Mem[$40:$87]:=Mem[$40:$87] OR $01;
  r.ah:=$11;
  r.al:=$11; {----8x14 Character set}
  r.bl:=$00;
  Intr($10,r);
  Mem[$40:$87]:=b;

{----400 scan lines neccesary}
  r.ah:=$12;
  r.al:=$02; {----400}
  r.bl:=$30;
  Intr($10,r);
End; {of Vga25lines}

End.

