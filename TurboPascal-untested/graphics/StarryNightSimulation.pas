(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0095.PAS
  Description: Starry night simulation
  Author: ANDREW GOLOVIN
  Date: 05-25-94  08:23
*)


Program StarryNight;

{ Looks like some late evening in the summer before starry night }
{ But i guess that stars goes brighter much faster than dimmer   }
{ Can you advise me on that fenomenon?                           }

Const
  NumberOfStars = 55; { Number of Stars. Can't be greater than 55 }
type
  StarMapArray = Array [0..6,0..4] of Word;
  { Each star allocate rectangle 4 pixels width and 6 pixels height }
const
   StarMap : StarMapArray =
         ((0,0,1,0,0),
          (0,0,2,0,0),
          (0,0,3,0,0),
          (1,3,4,3,1),
          (0,0,3,0,0),
          (0,0,2,0,0),
          (0,0,1,0,0));
  { This is picture of one star }
Type

  RGBRec = Record
    r,g,b: byte;
  end;
  { Palette record }

  PStar = ^TStar;   { Star itself }
  TStar = object
    Delta: byte;       { Step for brightness change }
    Brightest: RGBRec; { The very brightest color of the star }
    Brighten: Boolean; { Do star go brighter? }
    Number: byte;      { Personal star number }
    Xloc,Yloc: word;   { X,Y location }
    Colors: Array [1..4] of RGBRec;  { Star colors }
    constructor Init(ANumber: Byte);
    procedure Relocate;              { Move star to new position }
    procedure Rotate;                { Change colors step by step }
  end;

{..$DEFINE Mono}
{ Define MONO if you whant to see gray-scaled stars }

function keypressed : boolean; assembler;
  asm
    Mov AH,01h
    Int 16h
    JNZ @0
    XOR AX,AX
    Jmp @1
@0: Mov AL,1
@1:
  end;

constructor TStar.Init(ANumber: Byte);
  var
    cx,cy: word;
  begin
    Number:=ANumber;
    XLoc:=0;YLoc:=0;
    Relocate;
  end;

procedure TStar.Relocate;
  var
    cx,cy: word;
    cc: byte;
    {$IFDEF Mono}
    mc: byte;
    {$ENDIF}
  begin
    For cy:=0 to 6 do
      For cx:=0 to 4 do
        Mem[$A000:(cx+XLoc)+(cy+Yloc)*320]:=(224+(cy+YLoc) div 8);
    { Restore old background }
    Brighten:=True;
    {$IFDEF Mono}
    mc:=Random(64);
    With Brightest do
      begin
        r:=mc;
        g:=mc;
        b:=mc;
      end;
    {$ELSE}
    With Brightest do
      begin
        r:=Random(64);
        g:=Random(64);
        b:=Random(64);
      end;
    {$ENDIF}
    Port[968]:=Number*4;
    For cc:=1 to 4 do
      begin
        with Colors[cc] do
          begin
            r:=0; g:=0; b:=0;
          end;
        Port[969]:=0;
        Port[969]:=0;
        Port[969]:=0;
      end;
    XLoc:=Random(320-5);
    YLoc:=Random(200-7);
    Delta:=Random(5)+1;
    { Delta:=(YLoc Div 40)+1;}
    { Stars near horizont blink rapidly }
    For cx:=0 to 4 do
      For cy:=0 to 6 do
        if StarMap[cy,cx]<>0
           then
             Mem[$A000:(cx+XLoc)+(cy+Yloc)*320]:=
                 StarMap[cy,cx]+(Number ShL 2)-1;
    { Put star to screen }
  end;

procedure TStar.Rotate;
  var
    cc: byte;
    cx,cy: word;
  begin
    If Brighten
       then
         begin
           For cc:=1 to 4 do
             begin
               If Colors[5-cc].r+Delta<=Brightest.r div cc
                  then
                    Inc(Colors[5-cc].r,Delta)
                  else
                    Colors[5-cc].r:=Brightest.r div cc;
               If Colors[5-cc].g+Delta<=Brightest.g div cc
                  then
                    Inc(Colors[5-cc].g,Delta)
                  else
                    Colors[5-cc].g:=Brightest.g  div cc;
               If Colors[5-cc].b+Delta<=Brightest.b div cc
                  then
                    Inc(Colors[5-cc].b,Delta)
                  else
                    Colors[5-cc].b:=Brightest.b div cc;
             end;
           if (Colors[4].r=Brightest.r) and
              (Colors[4].g=Brightest.g) and
              (Colors[4].b=Brightest.b)
              then
                Brighten:=False
         end
       else
         begin
           For cc:=1 to 4 do
             begin
               If Colors[cc].r>=Delta
                  then
                    Dec(Colors[cc].r,Delta)
                  else
                    Colors[cc].r:=0;
               If Colors[cc].g>=Delta
                  then
                    Dec(Colors[cc].g,Delta)
                  else
                    Colors[cc].g:=0;
               If Colors[cc].b>=Delta
                  then
                    Dec(Colors[cc].b,Delta)
                  else
                    Colors[cc].b:=0;
             end;
           if (Colors[4].r=0) and (Colors[4].g=0) and (Colors[4].b=0)
              then
                Relocate;
         end;
      Port[968]:=Number*4;
      For cc:=1 to 4 do
        begin
          Port[969]:=Colors[cc].r;
          Port[969]:=Colors[cc].g;
          Port[969]:=Colors[cc].b;
        end;
  end;

var
  StarArray: Array [1..NumberOfStars] of PStar;
  sc: byte;
  c: char;
  ccx,ccy: word;

begin
  asm mov ax,13h; int 10h end;
  port[968]:=224;
  for ccx:=1 to 255-224 do
    begin
      port[969]:=ccx div 2;
      port[969]:=0;
      port[969]:=ccx;
    end;
  For ccx:=0 to 319 do
    For ccy:=0 to 199 do
      Mem[$A000:(ccx+ccy*320)]:=(224+ccy div 8);
  { This make a background or backsky as you like }

  for sc:=1 to NumberOfStars do
    begin
      StarArray[sc]:=New(PStar,Init(sc));
    end;
  sc:=1;
  repeat
    StarArray[sc]^.Rotate;
    If sc=NumberOfStars
       then
         sc:=1
       else
         Inc(sc);
  until keypressed;
end.

