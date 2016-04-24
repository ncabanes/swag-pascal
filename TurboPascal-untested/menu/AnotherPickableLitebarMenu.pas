(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0010.PAS
  Description: Another Pickable Litebar Menu
  Author: KIM FORWOOD
  Date: 05-31-96  09:16
*)

{============================================================================}

PROGRAM LightBar;
uses Crt;

const

   UPARROW  = #72;
   DNARROW  = #80;
   PAGEUP   = #73;
   PAGEDN   = #81;
   HOMEKEY  = #71;
   ENDKEY   = #79;
   ENTER    = #13;
   NUMITEMS = 4;
   StrLen   = 14;
   ListArray : array[1..NUMITEMS] of string[StrLen] =
      ('Apples',
       'Oranges',
       'Bananas',
       'Cumquats');

var
   Ch: char;
   CurrPos, OldPos: byte;

PROCEDURE InitMenuBox(x,y: byte);
var
   I: byte;

begin
   Window(x,y,x+StrLen,y+NUMITEMS-1);
   TextAttr := $70;
   ClrScr;
   for I := 1 to NUMITEMS do begin
      GotoXY(1,I);
      Write(' ',ListArray[I]);
   end;
   CurrPos := 1;
end;

PROCEDURE GetKey(var Ch: char);
begin
   Ch := UpCase(ReadKey);
   if Ch = #0 then Ch := UpCase(ReadKey);
end;

PROCEDURE WriteString(Place,Attr: byte);
begin
   GotoXY(1,Place);
   TextAttr := Attr;
   ClrEol;
   Write(' ',ListArray[Place]);
end;

BEGIN
   InitMenuBox(10,3);
   repeat
      OldPos := CurrPos;
      WriteString(CurrPos,$30);
      GetKey(Ch);
      case Ch of
         UPARROW: if CurrPos > 1 then Dec(CurrPos) else CurrPos := NUMITEMS;
         DNARROW: if CurrPos < NUMITEMS then Inc(CurrPos) else CurrPos := 1;
         PAGEUP : CurrPos := 1;
         PAGEDN : CurrPos := NUMITEMS;
         HOMEKEY: CurrPos := 1;
         ENDKEY : CurrPos := NUMITEMS;
         ENTER  : case CurrPos of
                     1: {Apples};
                     2: {Oranges};
                     3: {Bananas};
                     4: {Cumquats};
                  end;
           else ;
      end;
      WriteString(OldPos,$70);
   until Ch = #27;
   Window(1,1,80,25);
   TextAttr := $07;
   ClrScr;
END.
{============================================================================}

