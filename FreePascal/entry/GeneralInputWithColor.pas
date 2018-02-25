(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0002.PAS
  Description: General Input with Color
  Author: SWAG SUPPORT TEAM
  Date: 06-08-93  08:24
*)

{ General STRING input routine with Color prompt and input }

USES DOS,Crt;

TYPE
    CharSet = Set OF Char;

VAR
    Name : STRING;

procedure QWrite( Column, Line , Color : byte; S : STRING );
(*
var
   VMode  : BYTE ABSOLUTE $0040 : $0049; { Video mode: Mono=7, Color=0-3 }
   NumCol : WORD ABSOLUTE $0040 : $004A; { Number of CRT columns (1-based) }
   VSeg   : WORD;
   OfsPos : integer;  { offset position of the character in video RAM }
   vPos   : integer;
   sLen   : Byte ABSOLUTE S;
*)
Begin
  (*
  If VMode in [0,2,7] THEN VSeg := $B000 ELSE VSeg := $B800;
  OfsPos   := (((pred(Line) * NumCol) + pred(Column)) * 2);
  FOR vPos := 0 to pred(sLen) do
      MemW[VSeg : (OfsPos + (vPos * 2))] :=
                     (Color shl 8) + byte(S[succ(vPos)])
  *)
  GotoXY(column, line);
  TextAttr := color;
  Write(S);
End;

Function GetString(cx,cy,cc,pc : Byte; Default,Prompt : String; 
    MaxLen : Integer;OKSet :charset):string;

{ cx = Input Column }
{ cy = Input Row    }
{ cc = Input Color  }
{ pc = Prompt Color }

const
  BS                 = ^H;
  CR                 = ^M;
  iPutChar           = '-';
  ConSet             : CharSet = [BS,CR];
var
  TStr               : string;
  TLen,X,i           : Integer;
  Ch                 : Char;
begin
  {$I-} { turn off I/O checking }
  TStr := '';
  TLen := 0;
  Qwrite(cx,cy,pc,Prompt);
  X := cx + Length(Prompt);
  For i := x to (x + Maxlen - 1) do
    Qwrite(i,cy,cc,iputChar);
  Qwrite(x,cy,cc,Default);
  OKSet := OKSet + ConSet;
  repeat
    Gotoxy(x,cy);
    repeat
      ch := readkey
    until Ch in OKSet;
    if Ch = BS then begin
      if TLen > 0 then begin
        TLen := TLen - 1;
        X := X - 1;
        QWrite(x,cy,cc,iPutChar);
      end
    end
    else if (Ch <> CR) and (TLen < MaxLen) then begin
      QWrite(x,cy,cc,Ch);
      TLen := TLen + 1;
      TStr[TLen] := Ch;
      X := X + 1;
    end
  until Ch = CR;
  If Tlen > 0
    Then Begin
           TStr[0] := chr(Tlen);
           Getstring := TStr
         End
    Else Getstring := Default;
  {$I+}
end;


BEGIN
    ClrScr;
    Name := Getstring(16,5,79,31,'GOOD OLE BOY',
        'Enter Name : ',25,['a'..'z','A'..'Z',' ']);
    GOTOXY(16,7);
    WriteLn('Name : ',Name);
    Readkey;
END.
