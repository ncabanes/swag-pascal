Unit Globals;

Interface

Uses Crt{, Dos?};

{ Special keyboard Characters: }
{ I've squeezed them into a couple of lines so that they'd fit in a
message.. might be an idea to expand them back to ~20 lines or so..}

      NULL = #0;    BS = #8;    ForMFEED = #12;    CR = #13;    ESC = #27;

      HOMEKEY = #199;    {Values apply if only used With the 'Getkey' Function}
      endKEY = #207;      UPKEY = #200;      doWNKEY = #208;
      PGUPKEY = #201;     PGDNKEY = #209;    LEFTKEY = #203;
      inSKEY = #210;      RIGHTKEY = #205;   DELKEY = #211;
      CTRLLEFTKEY = #243; CTRLRIGHTKEY = #244;
      F1 = #187;    F2 = #188;    F3 = #189;    F4 = #190;    F5  = #191;
      F6 = #192;    F7 = #193;    F8 = #194;    F9 = #195;    F10 = #196;

Type  CurType       = ( off, Big, Small );

Var   Ins           : Boolean;  { Global Var containing status of Insert key}

{-----------------------------------------------------------------------------}
Function  GetKey : Char;
Procedure EdReadln(Var S : String);

Procedure Cursor( Size : CurType ); { Either off, Big or Small }
Procedure ChangeCursor( Ins : Boolean );

{-----------------------------------------------------------------------------}
Implementation

Function GetKey; { : Char; }

Var C : Char;

begin
  C := ReadKey;
  Repeat
    if C = NULL then
    begin
      C := ReadKey;
      if ord(C) > 127 then
        C := NULL
      else
        GetKey := Chr(ord(C) + 128);
    end else GetKey := C;
  Until C <> NULL;
end; { GetKey }

{-----------------------------------------------------------------------------}
Procedure EdReadln; { (Var S : String); }

{ Legal : IString; MaxLength : Word; Var ESCPressed : Boolean); }

Var CPos : Word;
    Ch   : Char;
    OldY : Byte;

    Legal      : String[1];
    MaxLength  : Byte;
    EscPressed : Boolean;

begin
  OldY := WhereY - 1;
  ChangeCursor(Ins);
  CPos := 1;                {Place cursor at START of line}
{ CPos := Succ(Length(S));} {Whereas this places cursor at end of line}
  Legal := '';              {Legal and Maxlength originally passed as params}
  MaxLength := Lo( WindMax ) - Lo( WindMin );

  Repeat
    Cursor( off );
    GotoXY(1, WhereY);
    Write(S, '':(MaxLength - Length(S)));
    GotoXY(CPos, WhereY);
    ChangeCursor(Ins);
    Ch := GetKey;
    Case Ch of
      HOMEKEY  : CPos := 1;
      endKEY   : CPos := Succ(Length(S));
      inSKEY   : begin
                    Ins := not Ins;
                    ChangeCursor(Ins);
                 end;
      LEFTKEY  : if CPos > 1 then Dec(CPos);
      RIGHTKEY : if CPos <= Length(S) then Inc(CPos);
      BS       : if CPos > 1 then
                 begin
                    Delete(S, Pred(CPos), 1);
                    Dec(CPos);
                 end;
      DELKEY   : if CPos <= Length(S) then Delete(S, CPos, 1);
      CR       : ;
      ESC      : begin
                    S := '';
                    CPos := 1;
                 end;
      else
      begin
        if ((Legal = '') or (Pos(Ch, Legal) <> 0)) and
           ((Ch >= ' ') and (Ch <= '~')) and
            (Length(S) < MaxLength) then
        begin
          if Ins then Insert(Ch, S, CPos) else
          if CPos > Length(S) then S := S + Ch else
             S[CPos] := Ch;
          Inc(CPos);
        end;
      end;
    end; { Case }
  Until (Ch = CR);
  Cursor( Small );
  ESCPressed := Ch <> ESC;
  Writeln;
end; { EditString }

{-----------------------------------------------------------------------------}
Procedure Cursor; { ( Size : CurType ); { Either off, Big or Small }

Var Regs : Registers;

begin
   With Regs Do begin
      Ax := $100;
      Case Size of
         off   : Cx := $3030;
         Big   : Cx := $0F;
         Small : Cx := $607;
      end;
      Intr ( $10, Regs );
   end;
end;

{-----------------------------------------------------------------------------}
Procedure ChangeCursor; { ( Ins : Boolean ); }
{Changes cursor size depending on status of insert key}

begin
   if Ins then Cursor( Small ) else Cursor( Big );
end;

begin
end.
