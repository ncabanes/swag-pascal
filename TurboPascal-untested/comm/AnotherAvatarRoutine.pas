(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0011.PAS
  Description: Another AVATAR Routine
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{
GREGORY P. SMITH

Here's a Unit I just pieced together from some old code I wrote a couple
years ago.  It'll generate AVT/0+ and ANSI codes:
}

Unit TermCode;  {$S-,D-,L-,R-,F-,O-}
{  Generate ANSI and AVT/0+ codes For color and cursor ctrl }
{  Public Domain -- by Gregory P. Smith  }  { untested }

Interface

Type
  Str12 = String[12];  { Maximum size For most ANSI Strings }
  Str3  = String[3];
  grTermType = (TTY, ANSI, AVT0); { TTY, ANSI or Avatar/0+ }

Var
  grTerm : grTermType;
  grColor : Byte;  { Last color set }

{ Non Specific Functions }
Function grRepChar(c:Char;n:Byte): String;   { Repeat Chars }
Function grSetPos(x,y:Byte): Str12;   { Set Cursor Position }
Function grCLS: Str12;          { Clear Screen + reset Attr }
Function grDelEOL: Str12;                   { Delete to EOL }

Function grSetAttr(a:Byte): Str12;      { Change writing color }
Function grSetColor(fg,bg:Byte): Str12; { Change color fg & bg }

{ AVT/0+ Specific Functions }
Function AVTRepPat(pat:String;n:Byte): String; { Repeat Pattern (AVT/0+) }
Function AVTScrollUp(n,x1,y1,x2,y2:Byte): Str12;
Function AVTScrollDown(n,x1,y1,x2,y2:Byte): Str12;
Function AVTClearArea(a,l,c:Byte): Str12;
Function AVTInitArea(ch:Char;a,l,c:Byte): Str12;

Implementation

Const
  hdr = #27'['; { ansi header }

{ Misc support Functions }

Function bts(x:Byte): str3; { Byte to String }
Var
  z: str3;
begin
  Str(x,z);
  bts := z;
end;

Function Repl(n:Byte; c:Char): String;
Var
  z : String;
begin
  fillChar(z[1],n,c);
  z[0] := chr(n);
  repl := z;
end;

{ Cursor Control Functions }

Function grRepChar(c:Char;n:Byte): String;
begin
  if grTerm = AVT0 then
    grRepChar := ^Y+c+chr(n)
  else
    grRepChar := repl(n,c);
end; { repcahr }

Function grSetPos(x,y:Byte): Str12;
begin
  Case grTerm of
    ANSI : if (x = 1) and (y > 1) then
             grSetPos := hdr+bts(y)+'H'   { x defualts to 1 }
           else
             grSetPos := hdr+bts(y)+';'+bts(x)+'H';
    AVT0 : grSetPos := ^V+^H+chr(y)+chr(x);
    TTY  : grSetPos := '';
  end; { Case }
end;


Function grCLS: Str12;
begin
  Case grTerm of
    ANSI : grCLS := hdr+'2J';
    TTY,
    AVT0 : grCLS := ^L;
  end;
  if grTerm = AVT0 then GrColor := 3; { reset the color }
end; { cls }

Function grDelEOL: Str12; { clear rest of line }
begin
  Case grTerm of
    ANSI : grDelEOL := hdr+'K';
    AVT0 : grDelEOL := ^V^G;
    TTY  : grDelEOL := '';
  end;
end;

{ Color Functions }

Function grSetAttr(a:Byte): Str12;
Const
  ANS_Colors : Array[0..7] of Char = ('0','4','2','6','1','5','3','7');
Var
  tmp : Str12;
begin
  tmp := '';
  Case grTerm of
    ANSI :
    begin
      tmp := hdr;
      if (a and $08)=8 then tmp := tmp+'1' else tmp := tmp+'0'; { bright }
      if (a and $80)=$80 then tmp := tmp+';5';  { blink }
      tmp := tmp+';3'+ANS_Colors[a and $07]; { foreground }
      tmp := tmp+';4'+ANS_Colors[(a shr 4) and $07]; { background }
      grSetAttr := tmp+'m'; { complete ANSI code }
    end;
    AVT0 :
    begin
      tmp := ^V+^A+chr(a and $7f);
      if a > 127  then tmp := tmp+^V+^B; { Blink }
      grSetAttr := tmp;
    end;
    TTY  : grSetAttr := '';
  end; { Case }
  GrColor := a; { Current Attribute }
end; { setattr }

Function grSetColor(fg,bg:Byte): Str12;
begin
  grSetColor := grSetAttr((bg shl 4) or (fg and $0f));
end; { SetColor }

{ AVATAR Specific Functions: }

Function AVTRepPat(pat:String;n:Byte): String; { Repeat Pattern (AVT/0+) }
begin
  AVTRepPat := ^V+^Y+pat[0]+pat+chr(n); { Repeat pat n times }
end;

Function AVTScrollUp(n,x1,y1,x2,y2:Byte): Str12;
begin
  AVTScrollUp := ^V+^J+chr(n)+chr(y1)+chr(x1)+chr(y2)+chr(x2);
end; { AVTScrollUp }

Function AVTScrollDown(n,x1,y1,x2,y2:Byte): Str12;
begin
  AVTScrollDown := ^V+^K+chr(n)+chr(y1)+chr(x1)+chr(y2)+chr(x2);
end; { AVTScrollDown }

Function AVTClearArea(a,l,c:Byte): Str12;
Var
  b:Byte;
  s:Str12;
begin       { Clear lines,columns from cursor pos With Attr }
  b := a and $7f;
  s := ^V+^L+chr(b)+chr(l)+chr(c);
  if a > 127 then
    Insert(^V+^B,s,1); { blink on }
  AVTClearArea := s;
  GrColor := a;
end; { AVTClearArea }

Function AVTInitArea(ch:Char;a,l,c:Byte): Str12;
Var
  b:Byte;
  s:Str12;
begin
  b := a and $7f;
  s := ^V+^M+chr(b)+ch+chr(l)+chr(c);
  if a > 127 then
    Insert(^V+^B,s,1);
  AvtInitArea := s;
  GrColor := a;
end; { AVTInitArea }

{ Initalization code }
begin
  GrTerm  := AVT0;  { Default to Avatar }
  GrColor := 3;     { Cyan is the AVT/0+ defualt }
end.

{
set GrTerm to whatever terminal codes you want to create; then you can use the
common routines to generate ANSI or Avatar codes.  Here's a Print Procedure
that you were mentioning:
}

Procedure Print(Var msg:String);
Var
  idx : Byte
begin
  if length(msg) > 0 then
    For idx := 1 to length(msg) do begin
      Parse_AVT1(msg[idx]);
      SendOutComPortThingy(msg[idx]);
    end; { For }
end;
{
You could modify this so that it pays attention to the TextAttr Variable of the
Crt Unit if you wish so that it compares TextAttr to GrColor and adds a
SetAttr(TextAttr) command in before it sends msg.
}
