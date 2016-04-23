
Unit sCrt;

InterFace

uses
  Crt;

procedure init;
procedure ws(X, Y, Atr : Byte; Ch : Char);
function  rs(X, Y : byte) : Char;
procedure wst(X, Y, Atr : Byte; S : String);
procedure WstCenter(X, Y, Atr : Byte; Str : string);
procedure WstRight(X, Y, Atr : Byte; Str : string);

Implementation

var
  ScreenSeg : longint;
  att       : byte;                (* atributt(se over) *)

procedure init;
(* Denne prosedyren finner ut skjermadressen i RAM og setter att *)
(* til 15 (hvitt p} sort), dette funker b}de p} farge og monoskjerm *)
begin
  if (Mem[0000:1040] and 48) <> 48 then
    ScreenSeg := $B800
  else
    ScreenSeg := $B000;
  Att := 15;
end;

procedure ws(X, Y, Atr : Byte; Ch : Char);
(* Skriver ut et tegn(thischar) i posisjon (col,row), der col er *)
(* vanrett (1-80) og row er loddrett (1-25) *)
var
  locationCode : Integer;
begin
  Att := Atr;
  locationCode := (X - 1) * 2 + (Y - 1) * 160;
  Mem[screenseg : locationcode] := Ord(Ch);
  Mem[screenseg : locationcode + 1] := Atr;
end;

function rs(X, Y : byte) : Char;
(* Leser et tegn p} skjermen i pos. col,row *)
var
  locationcode : Integer;
begin
   LocationCode := (X - 1) * 2 + (Y - 1) * 160;
   rs := chr(Mem[ScreenSeg:LocationCode]);
end;

procedure wst(X, Y, Atr : Byte; S : String);
(* Skriver ut en streng til skjermen i pos. x,y *)
var
  t : Byte;
begin
   for t := 1 to Length(S) do
     ws(x + t - 1, y, Atr, S(.t.));
end;

procedure WstCenter(X, Y, Atr : Byte; Str : string);
var
  t : Byte;
begin
  for t := 1 to Length(Str) do
    Ws(t + X - (Length(Str) div 2), Y, Atr, Str[t]);
end;

procedure WstRight(X, Y, Atr : Byte; Str : string);
var
  t : Byte;
begin
  for t := 1 to Length(Str) do
    Ws(t + X - Length(Str), Y, Atr, Str[t]);
end;


begin
  Init;
end.
