(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0119.PAS
  Description: EGA/VGA Font Editor
  Author: THIERRY DE LEEUW
  Date: 08-24-94  13:40
*)


{..$define First} { disable to force loading of file }

{use this if you launch the program for the first time (you also may add a
code to detect if the file already exiists but... normally, you should use
this option once.}

program GenSmallCar;
{CopyRight Thierry De Leeuw 1994}
uses crt, dos, graph;

Type TSmallCar = Array [0..8] of Byte;
     PSmallCar = ^TSmallCar;

var  SmallCar : Array[32..180] of PSmallCar;
     Buffer   : Array[0..7,0..8] of Char;
     grDriver : Integer;
     grMode   : Integer;
     ErrCode  : Integer;
     EnCours  : Byte;

Procedure ReserveMemoire;
var i : byte;
begin
   For i := 32 to 180 do
   begin
      New(SmallCar[i]);
   end;
end;

procedure ChargeTable;
var Fichier : Text;
    i       : byte;
    j       : byte;
begin
   {$Ifndef First}
   Assign(Fichier, 'Small.FON');
   Reset(Fichier);
   {$Endif}
   For i := 32 to 180 do
   begin
      for j := 0 to 8 do
      begin
         {$IFDEF First}
         SmallCar[i]^[j] := 0;
         {$Else}
         readLn(Fichier, SmallCar[i]^[j]);
         {$Endif}
      end;
      {$Ifndef First}
      Readln(Fichier);
      {$Endif}
   end;
   {$Ifndef First}
   Close(Fichier);
   {$endif}
end;

function Analyse(Valeur: byte) : String;
var Tmp : String[19];
begin
   Tmp := ' ';
   Analyse := Tmp


end;

Procedure Update(No : Byte);
var i : byte;
    j : byte;

begin
   ClrScr;
   LowVideo;
   GotoXY(22,1);
   Write('Edition du caractère n° ',No:3,' - "',Chr(No),'".');
   GotoXY(22,2);
   Write('══════════════════════════════════');
   gotoXY(30,4);
   Write('╔═════════════════╗');
   gotoXY(30,5);
   Write('║                 ║');
   gotoXY(30,6);
   Write('║                 ║');
   gotoXY(30,7);
   Write('║                 ║');
   gotoXY(30,8);
   Write('║                 ║');
   gotoXY(30,9);
   Write('║                 ║');
   gotoXY(30,10);
   Write('║                 ║');
   gotoXY(30,11);
   Write('║                 ║');
   gotoXY(30,12);
   Write('║                 ║');
   gotoXY(30,13);
   Write('║                 ║');
   gotoXY(30,14);
   Write('╚═════════════════╝');
   For i := 0 to 8 do
   begin
      gotoXY(31,5+i);
      For j := 0 to 7 do
         Write(' ' + Buffer[j,i]);
   end;
end;

Procedure Bufferize(No : Byte);
var i : byte;
begin
   for i := 0 to 8 do
   begin
      if SmallCar[No]^[i] and 1 <> 0 then Buffer[0,i] := '*' else Buffer[0,i]
:= '·';
      if SmallCar[No]^[i] and 2 <> 0 then Buffer[1,i] := '*' else Buffer[1,i]
:= '·';
      if SmallCar[No]^[i] and 4 <> 0 then Buffer[2,i] := '*' else Buffer[2,i]
:= '·';
      if SmallCar[No]^[i] and 8 <> 0 then Buffer[3,i] := '*' else Buffer[3,i]
:= '·';
      if SmallCar[No]^[i] and 16 <> 0 then Buffer[4,i] := '*' else Buffer[4,i]
:= '·';
      if SmallCar[No]^[i] and 32 <> 0 then Buffer[5,i] := '*' else Buffer[5,i]
:= '·';
      if SmallCar[No]^[i] and 64 <> 0 then Buffer[6,i] := '*' else Buffer[6,i]
:= '·';
      if SmallCar[No]^[i] and 128 <> 0 then Buffer[7,i] := '*' else
Buffer[7,i] := '·';

   end;
end;

procedure Encode(No : Byte);
var i,j : byte;
begin
   for i := 0 to 8 do
   begin
      SmallCar[No]^[i] := 0;
      if Buffer[0,i] = '*' then SmallCar[No]^[i] := 1;
      if Buffer[1,i] = '*' then SmallCar[No]^[i] := SmallCar[No]^[i] + 2;
      if Buffer[2,i] = '*' then SmallCar[No]^[i] := SmallCar[No]^[i] + 4;
      if Buffer[3,i] = '*' then SmallCar[No]^[i] := SmallCar[No]^[i] + 8;
      if Buffer[4,i] = '*' then SmallCar[No]^[i] := SmallCar[No]^[i] + 16;
      if Buffer[5,i] = '*' then SmallCar[No]^[i] := SmallCar[No]^[i] + 32;
      if Buffer[6,i] = '*' then SmallCar[No]^[i] := SmallCar[No]^[i] + 64;
      if Buffer[7,i] = '*' then SmallCar[No]^[i] := SmallCar[No]^[i] + 128;
   end;
end;

procedure Preview;
var i, j : byte;
begin
   initGraph(grDriver,GrMode,'\turbo\tp\');
   for i := 0 to 8 do
   begin
      for j := 0 to 7 do
      begin
         if Buffer[j,i] = '*' then putpixel(j+GetMaxX div 2 ,i+GetMaxY div
2,15);
      end;
   end;
   readkey;
   closeGraph;
end;

procedure PreviewAll;
var i, j, k : byte;
begin
   initGraph(grDriver,GrMode,'\turbo\tp\');
   for k := 32 to 96 do
   begin
      Bufferize(k);
      for i := 0 to 8 do
      begin
         for j := 0 to 7 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-32) * 9 ,i+GetMaxY div
2-10,15);
         end;
      end;
   end;
   for k := 97 to 180 do
   begin
      Bufferize(k);
      for i := 0 to 8 do
      begin
         for j := 0 to 7 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-97) * 9 ,i+GetMaxY div
2+10,15);
         end;
      end;
   end;
   readkey;
   closeGraph;
end;

function Edit(No : byte) : Char;
var x, y : byte;
    car  : Char;
    Sortie : Boolean;
    Go     : byte;
begin
   UpDate(No);
   x := 0;
   y := 0;
   Sortie := false;

   repeat
      GotoXY(32 + 2*x,5+y);
      HighVideo;
      Write(Buffer[x,y]);
      GotoXY(32 + 2*x,5+y);
      repeat
      until keypressed;
      car := ReadKey;
      GotoXY(32 + 2*x,5+y);
      LowVideo;
      Write(Buffer[x,y]);
      if (car = 'q') or (car = 'Q') then car := #13;
      if car = #0 then car := ReadKey;
      case car of
         '2',chr(80)   : if y = 8 then y := 0 else inc(y);
         '8',chr(72)   : if y = 0 then y := 8 else dec(y);
         '4',chr(75)   : if x = 0 then x := 7 else dec(x);
         '6',chr(77)   : if x = 7 then x := 0 else inc(x);
         ' '           : if Buffer[x,y] = '*' then Buffer[x,y] := '·' else
Buffer[x,y] := '*';
         #13, #81, #73 : Sortie := true;
         #27           : Sortie := True;
         'G','g'       : begin
                            GotoXY(20,24);
                            Write('Aller à quel code ascii ? ');
                            Read(Go);
                            if (Go >= 32) and (go <= 180) then
                            begin
                               Encode(No);
                               EnCours := Go -1;
                               Car := #81;
                               Sortie := true;
                            end;
                            GotoXY(1,24);
                            ClrEol;
                         end;

         'v'           : begin
                           Preview;
                           update(No);
                         end;
         'a'           : begin
                            Encode(No);
                            PreviewAll;
                            Bufferize(No);
                            Update(No);
                         end;
      end;
   until (sortie);
   Encode(No);
   Edit := Car;
end;

procedure EditeTable;
var fin     : boolean;
    Car     : char;
    Car_Retour : char;
begin
   fin := false;
   Encours := 32;
   repeat
      Bufferize(Encours);
      Car_Retour := Edit(EnCours);
      case car_Retour of
         #13 : begin
                  gotoXY(20,24);
                  Write('Quitter ? ');
                  Car := UpCase(readKey);
                  GotoXY(1,24);
                  ClrEol;
                  if Car = 'O' then Fin := true;
               end;
         #81 : begin
                  if EnCours = 180 then Encours := 32 else inc(EnCours);
               end;
         #73 : begin
                  if EnCours = 32 then Encours := 180 else dec(EnCours);
               end;
         #27 : begin
                  gotoXY(20,24);
                  Write('Abandon des modifications ? ');
                  Car := UpCase(readKey);
                  GotoXY(1,24);
                  ClrEol;
                  if Car = 'O' then Halt(0);
               end;
      end;
   until fin;
end;

procedure SauveTable;
var Fichier : Text;
    i       : byte;
    j       : byte;
begin
   Assign(Fichier, 'Small.FON');
   Rewrite(Fichier);
   For i := 32 to 180 do
   begin
      for j := 0 to 8 do
      begin
         writeLn(Fichier, SmallCar[i]^[j]);
      end;
      WriteLn(Fichier);
   end;
   Close(Fichier);
end;

begin
   DetectGraph(GrDriver, GrMode);
   InitGraph(grDriver, grMode,'\turbo\tp\');
   ErrCode := GraphResult;
   if ErrCode <> grOk then
   begin
     Writeln('Graphics error:', GraphErrorMsg(ErrCode));
     Halt(255);
   end;
   CloseGraph;


   NormVideo;
   ReserveMemoire;
   ChargeTable;
   EditeTable;
   SauveTable;
end.

{$define}
{same remark as above}

program GenMidCar;
{CopyRight Thierry De Leeuw 1994}
uses crt, dos, graph;

Type TMidCar = Array [0..18] of Word;
     PMidCar = ^TMidCar;

var  MidCar : Array[32..180] of PMidCar;
     Buffer   : Array[0..15,0..18] of Char;
     grDriver : Integer;
     grMode   : Integer;
     ErrCode  : Integer;
     EnCours  : Byte;

Procedure ReserveMemoire;
var i : byte;
begin
   For i := 32 to 180 do
   begin
      New(MidCar[i]);
   end;
end;

procedure ChargeTable;
var Fichier : Text;
    i       : byte;
    j       : byte;
begin
   {$Ifndef First}
   Assign(Fichier, 'Mid.FON');
   Reset(Fichier);
   {$Endif}
   For i := 32 to 180 do
   begin
      for j := 0 to 18 do
      begin
         {$IFDEF First}
         MidCar[i]^[j] := 0;
         {$Else}
         readLn(Fichier, MidCar[i]^[j]);
         {$Endif}
      end;
      {$Ifndef First}
      Readln(Fichier);
      {$Endif}
   end;
   {$Ifndef First}
   Close(Fichier);
   {$endif}
end;

function Analyse(Valeur: byte) : String;
var Tmp : String[19];
begin
   Tmp := ' ';
   Analyse := Tmp


end;

Procedure Update(No : Byte);
var i : byte;
    j : byte;

begin
   ClrScr;
   LowVideo;
   GotoXY(22,1);
   Write('Edition du caractère n° ',No:3,' - "',Chr(No),'".');
   GotoXY(22,2);
   Write('══════════════════════════════════');
   gotoXY(20,4);
   Write('╔═════════════════════════════════╗');
   gotoXY(20,5);
   Write('║                                 ║');
   gotoXY(20,6);
   Write('║                                 ║');
   gotoXY(20,7);
   Write('║                                 ║');
   gotoXY(20,8);
   Write('║                                 ║');
   gotoXY(20,9);
   Write('║                                 ║');
   gotoXY(20,10);
   Write('║                                 ║');
   gotoXY(20,11);
   Write('║                                 ║');
   gotoXY(20,12);
   Write('║                                 ║');
   gotoXY(20,13);
   Write('║                                 ║');
   gotoXY(20,14);
   Write('║                                 ║');
   gotoXY(20,15);
   Write('║                                 ║');
   gotoXY(20,16);
   Write('║                                 ║');
   gotoXY(20,17);
   Write('║                                 ║');
   gotoXY(20,18);
   Write('║                                 ║');
   gotoXY(20,19);
   Write('║                                 ║');
   gotoXY(20,20);
   Write('║                                 ║');
   gotoXY(20,21);
   Write('║                                 ║');
   gotoXY(20,22);
   Write('║                                 ║');
   gotoXY(20,23);
   Write('║                                 ║');
   gotoXY(20,24);
   Write('╚═════════════════════════════════╝');
   For i := 0 to 18 do
   begin
      gotoXY(21,5+i);
      For j := 0 to 15 do
         Write(' ' + Buffer[j,i]);
   end;
end;

Procedure Bufferize(No : Byte);
var i : byte;
begin
   for i := 0 to 18 do
   begin
      if MidCar[No]^[i] and 1 <> 0 then Buffer[0,i] := '*' else Buffer[0,i] :=
'·';
      if MidCar[No]^[i] and 2 <> 0 then Buffer[1,i] := '*' else Buffer[1,i] :=
'·';
      if MidCar[No]^[i] and 4 <> 0 then Buffer[2,i] := '*' else Buffer[2,i] :=
'·';
      if MidCar[No]^[i] and 8 <> 0 then Buffer[3,i] := '*' else Buffer[3,i] :=
'·';
      if MidCar[No]^[i] and 16 <> 0 then Buffer[4,i] := '*' else Buffer[4,i]
:= '·';
      if MidCar[No]^[i] and 32 <> 0 then Buffer[5,i] := '*' else Buffer[5,i]
:= '·';
      if MidCar[No]^[i] and 64 <> 0 then Buffer[6,i] := '*' else Buffer[6,i]
:= '·';
      if MidCar[No]^[i] and 128 <> 0 then Buffer[7,i] := '*' else Buffer[7,i]
:= '·';
      if MidCar[No]^[i] and 256 <> 0 then Buffer[8,i] := '*' else Buffer[8,i]
:= '·';
      if MidCar[No]^[i] and 512 <> 0 then Buffer[9,i] := '*' else Buffer[9,i]
:= '·';
      if MidCar[No]^[i] and 1024 <> 0 then Buffer[10,i] := '*' else
Buffer[10,i] := '·';
      if MidCar[No]^[i] and 2048 <> 0 then Buffer[11,i] := '*' else
Buffer[11,i] := '·';
      if MidCar[No]^[i] and 4096 <> 0 then Buffer[12,i] := '*' else
Buffer[12,i] := '·';
      if MidCar[No]^[i] and 8192 <> 0 then Buffer[13,i] := '*' else
Buffer[13,i] := '·';
      if MidCar[No]^[i] and 16384 <> 0 then Buffer[14,i] := '*' else
Buffer[14,i] := '·';
      if MidCar[No]^[i] and 32768 <> 0 then Buffer[15,i] := '*' else
Buffer[15,i] := '·';

   end;
end;

procedure Encode(No : Byte);
var i,j : byte;
begin
   for i := 0 to 18 do
   begin
      MidCar[No]^[i] := 0;
      if Buffer[0,i] = '*' then MidCar[No]^[i] := 1;
      if Buffer[1,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 2;
      if Buffer[2,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 4;
      if Buffer[3,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 8;
      if Buffer[4,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 16;
      if Buffer[5,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 32;
      if Buffer[6,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 64;
      if Buffer[7,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 128;
      if Buffer[8,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 256;
      if Buffer[9,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 512;
      if Buffer[10,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 1024;
      if Buffer[11,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 2048;
      if Buffer[12,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 4096;
      if Buffer[13,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 8192;
      if Buffer[14,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 16384;
      if Buffer[15,i] = '*' then MidCar[No]^[i] := MidCar[No]^[i] + 32768;
   end;
end;

procedure Preview;
var i, j : byte;
begin
   initGraph(grDriver,GrMode,'\turbo\tp\');
   for i := 0 to 18 do
   begin
      for j := 0 to 15 do
      begin
         if Buffer[j,i] = '*' then putpixel(j+GetMaxX div 2 ,i+GetMaxY div
2,15);
      end;
   end;
   readkey;
   closeGraph;
end;

procedure PreviewAll;
var i, j, k : byte;
begin
   initGraph(grDriver,GrMode,'\turbo\tp\');
   for k := 32 to 64 do
   begin
      Bufferize(k);
      for i := 0 to 18 do
      begin
         for j := 0 to 15 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-32) * 18 ,i+GetMaxY div
2-20,15);
         end;
      end;
   end;
   for k := 65 to 96 do
   begin
      Bufferize(k);
      for i := 0 to 18 do
      begin
         for j := 0 to 15 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-65) * 18 ,i+GetMaxY div
2+10,15);
         end;
      end;
   end;
   for k :=  97 to 127 do
   begin
      Bufferize(k);
      for i := 0 to 18 do
      begin
         for j := 0 to 15 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-97) * 18 ,i+GetMaxY div
2+30,15);
         end;
      end;
   end;
   for k :=  128 to 155 do
   begin
      Bufferize(k);
      for i := 0 to 18 do
      begin
         for j := 0 to 15 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-128) * 18 ,i+GetMaxY div
2+50,15);
         end;
      end;
   end;
   for k :=  156 to 180 do
   begin
      Bufferize(k);
      for i := 0 to 18 do
      begin
         for j := 0 to 15 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-156) * 18 ,i+GetMaxY div
2+70,15);
         end;
      end;
   end;
   readkey;
   closeGraph;
end;

function Edit(No : byte) : Char;
var x, y : byte;
    car  : Char;
    Sortie : Boolean;
    Go     : byte;
    CaracTempo :  char;
begin
   UpDate(No);
   x := 0;
   y := 0;
   Sortie := false;

   repeat
      GotoXY(22 + 2*x,5+y);
      HighVideo;
      Write(Buffer[x,y]);
      GotoXY(22 + 2*x,5+y);
      repeat
      until keypressed;
      car := ReadKey;
      GotoXY(22 + 2*x,5+y);
      LowVideo;
      Write(Buffer[x,y]);
      if (car = 'q') or (car = 'Q') then car := #13;
      if car = #0 then car := ReadKey;
      case car of
         '2',chr(80)   : if y = 18 then y := 0 else inc(y);
         '8',chr(72)   : if y = 0 then y := 18 else dec(y);
         '4',chr(75)   : if x = 0 then x := 15 else dec(x);
         '6',chr(77)   : if x = 15 then x := 0 else inc(x);
         ' '           : if Buffer[x,y] = '*' then Buffer[x,y] := '·' else
Buffer[x,y] := '*';
         #13, #81, #73 : Sortie := true;
         #27           : Sortie := True;
         'G','g'       : begin
                            GotoXY(20,24);
                            Write('Aller à quel code ascii ? ');
                            Read(Go);
                            if (Go >= 32) and (go <= 180) then
                            begin
                               Encode(No);
                               EnCours := Go -1;
                               Car := #81;
                               Sortie := true;
                            end;
                            GotoXY(1,24);
                            ClrEol;
                         end;

         'v', 'V'      : begin
                           Preview;
                           update(No);
                         end;
         'a', 'A'      : begin
                            Encode(No);
                            PreviewAll;
                            Bufferize(No);
                            Update(No);
                         end;
         'c', 'C'      : begin
                            gotoXY(20,24);
                            Write('Copier quel caractère ? ');
                            CaracTempo := ReadKey;
                            if CaracTempo <> #13 then
                            begin
                               Bufferize(ord(CaracTempo));
                               UpDate(EnCOurs);
                            end;
                            GotoXY(20,24);
                            ClrEol;
                         end;
      end;
   until (sortie);
   Encode(No);
   Edit := Car;
end;

procedure EditeTable;
var fin     : boolean;
    Car     : char;
    Car_Retour : char;
begin
   fin := false;
   Encours := 32;
   repeat
      Bufferize(Encours);
      Car_Retour := Edit(EnCours);
      case car_Retour of
         #13 : begin
                  gotoXY(20,24);
                  Write('Quitter ? ');
                  Car := UpCase(readKey);
                  GotoXY(1,24);
                  ClrEol;
                  if Car = 'O' then Fin := true;
               end;
         #81 : begin
                  if EnCours = 180 then Encours := 32 else inc(EnCours);
               end;
         #73 : begin
                  if EnCours = 32 then Encours := 180 else dec(EnCours);
               end;
         #27 : begin
                  gotoXY(20,24);
                  Write('Abandon des modifications ? ');
                  Car := UpCase(readKey);
                  GotoXY(1,24);
                  ClrEol;
                  if Car = 'O' then Halt(0);
               end;
      end;
   until fin;
end;

procedure SauveTable;
var Fichier : Text;
    i       : byte;
    j       : byte;
begin
   Assign(Fichier, 'Mid.FON');
   Rewrite(Fichier);
   For i := 32 to 180 do
   begin
      for j := 0 to 18 do
      begin
         writeLn(Fichier, MidCar[i]^[j]);
      end;
      WriteLn(Fichier);
   end;
   Close(Fichier);
end;

begin
   DetectGraph(GrDriver, GrMode);
   InitGraph(grDriver, grMode,'\turbo\tp\');
   ErrCode := GraphResult;
   if ErrCode <> grOk then
   begin
     Writeln('Graphics error:', GraphErrorMsg(ErrCode));
     Halt(255);
   end;
   CloseGraph;


   NormVideo;
   ReserveMemoire;
   ChargeTable;
   EditeTable;
   SauveTable;
end.

{$define}
{same remark as above}
program GenMidCar;

{CopyRight Thierry De Leeuw 1994}

uses crt, dos, graph;

Type TBigCar = Array [0..36] of LongInt;
     PBigCar = ^TBigCar;
     TEtat = (Move, delete, trace);

var  BigCar : Array[32..180] of PBigCar;
     Buffer   : Array[0..31,0..36] of Char;
     grDriver : Integer;
     grMode   : Integer;
     ErrCode  : Integer;
     EnCours  : Byte;
     Etat     : TEtat;

Procedure ReserveMemoire;
var i : byte;
begin
   For i := 32 to 180 do
   begin
      New(BigCar[i]);
   end;
end;

procedure ChargeTable;
var Fichier : Text;
    i       : byte;
    j       : byte;
begin
   {$Ifndef First}
   Assign(Fichier, 'Big.FON');
   Reset(Fichier);
   {$Endif}
   For i := 32 to 180 do
   begin
      for j := 0 to 36 do
      begin
         {$IFDEF First}
         BigCar[i]^[j] := 0;
         {$Else}
         readLn(Fichier, BigCar[i]^[j]);
         {$Endif}
      end;
      {$Ifndef First}
      Readln(Fichier);
      {$Endif}
   end;
   {$Ifndef First}
   Close(Fichier);
   {$endif}
end;

function Analyse(Valeur: byte) : String;
var Tmp : String[19];
begin
   Tmp := ' ';
   Analyse := Tmp
end;

Procedure Update(No : Byte);
var i : byte;
    j : byte;

begin
   ClrScr;
   textMode(258);
   LowVideo;
   GotoXY(1,1);
   if etat = move then write('Move')
   else
      if etat = delete then write('Delete')
      else
         if etat = trace then write('Trace');
   GotoXY(22,1);
   Write('Edition du caractère n° ',No:3,' - "',Chr(No),'".');
   GotoXY(22,2);
   Write('══════════════════════════════════');
   gotoXY(2,4);
Write('╔══════════════════════════════════════════════════════════════════╗');
   gotoXY(2,5);
   Write('║ ║');
   gotoXY(2,6);
   Write('║ ║');
   gotoXY(2,7);
   Write('║ ║');
   gotoXY(2,8);
   Write('║ ║');
   gotoXY(2,9);
   Write('║ ║');
   gotoXY(2,10);
   Write('║ ║');
   gotoXY(2,11);
   Write('║ ║');
   gotoXY(2,12);
   Write('║ ║');
   gotoXY(2,13);
   Write('║ ║');
   gotoXY(2,14);
   Write('║ ║');
   gotoXY(2,15);
   Write('║ ║');
   gotoXY(2,16);
   Write('║ ║');
   gotoXY(2,17);
   Write('║ ║');
   gotoXY(2,18);
   Write('║ ║');
   gotoXY(2,19);
   Write('║ ║');
   gotoXY(2,20);
   Write('║ ║');
   gotoXY(2,21);
   Write('║ ║');
   gotoXY(2,22);
   Write('║ ║');
   gotoXY(2,23);
   Write('║ ║');
   gotoXY(2,24);
   Write('║ ║');
   gotoXY(2,25);
   Write('║ ║');
   gotoXY(2,26);
   Write('║ ║');
   gotoXY(2,27);
   Write('║ ║');
   gotoXY(2,28);
   Write('║ ║');
   gotoXY(2,29);
   Write('║ ║');
   gotoXY(2,30);
   Write('║ ║');
   gotoXY(2,31);
   Write('║ ║');
   gotoXY(2,32);
   Write('║ ║');
   gotoXY(2,33);
   Write('║ ║');
   gotoXY(2,34);
   Write('║ ║');
   gotoXY(2,35);
   Write('║ ║');
   gotoXY(2,36);
   Write('║ ║');
   gotoXY(2,37);
   Write('║ ║');
   gotoXY(2,38);
   Write('║ ║');
   gotoXY(2,39);
   Write('║ ║');
   gotoXY(2,40);
   Write('║ ║');
   gotoXY(2,41);
   Write('║ ║');
   gotoXY(2,42);
   Write('║ ║');
   gotoXY(2,43);
Write('╚══════════════════════════════════════════════════════════════════╝');
   For i := 0 to 36 do
   begin
      gotoXY(3,5+i);
      For j := 0 to 31 do
         Write(' ' + Buffer[j,i]);
   end;
end;

Procedure Bufferize(No : Byte);
var i : byte;
begin
   for i := 0 to 36 do
   begin
      if BigCar[No]^[i] and 1 <> 0 then Buffer[0,i] := '*' else Buffer[0,i] :=
'·';
      if BigCar[No]^[i] and 2 <> 0 then Buffer[1,i] := '*' else Buffer[1,i] :=
'·';
      if BigCar[No]^[i] and 4 <> 0 then Buffer[2,i] := '*' else Buffer[2,i] :=
'·';
      if BigCar[No]^[i] and 8 <> 0 then Buffer[3,i] := '*' else Buffer[3,i] :=
'·';
      if BigCar[No]^[i] and $10 <> 0 then Buffer[4,i] := '*' else Buffer[4,i]
:= '·';
      if BigCar[No]^[i] and $20 <> 0 then Buffer[5,i] := '*' else Buffer[5,i]
:= '·';
      if BigCar[No]^[i] and $40 <> 0 then Buffer[6,i] := '*' else Buffer[6,i]
:= '·';
      if BigCar[No]^[i] and $80 <> 0 then Buffer[7,i] := '*' else Buffer[7,i]
:= '·';
      if BigCar[No]^[i] and $100 <> 0 then Buffer[8,i] := '*' else Buffer[8,i]
:= '·';
      if BigCar[No]^[i] and $200 <> 0 then Buffer[9,i] := '*' else Buffer[9,i]
:= '·';
      if BigCar[No]^[i] and $400 <> 0 then Buffer[10,i] := '*' else
Buffer[10,i] := '·';
      if BigCar[No]^[i] and $800 <> 0 then Buffer[11,i] := '*' else
Buffer[11,i] := '·';
      if BigCar[No]^[i] and $1000 <> 0 then Buffer[12,i] := '*' else
Buffer[12,i] := '·';
      if BigCar[No]^[i] and $2000 <> 0 then Buffer[13,i] := '*' else
Buffer[13,i] := '·';
      if BigCar[No]^[i] and $4000 <> 0 then Buffer[14,i] := '*' else
Buffer[14,i] := '·';
      if BigCar[No]^[i] and $8000 <> 0 then Buffer[15,i] := '*' else
Buffer[15,i] := '·';
      if BigCar[No]^[i] and $10000 <> 0 then Buffer[16,i] := '*' else
Buffer[16,i] := '·';
      if BigCar[No]^[i] and $20000 <> 0 then Buffer[17,i] := '*' else
Buffer[17,i] := '·';
      if BigCar[No]^[i] and $40000 <> 0 then Buffer[18,i] := '*' else
Buffer[18,i] := '·';
      if BigCar[No]^[i] and $80000 <> 0 then Buffer[19,i] := '*' else
Buffer[19,i] := '·';
      if BigCar[No]^[i] and $100000 <> 0 then Buffer[20,i] := '*' else
Buffer[20,i] := '·';
      if BigCar[No]^[i] and $200000 <> 0 then Buffer[21,i] := '*' else
Buffer[21,i] := '·';
      if BigCar[No]^[i] and $400000 <> 0 then Buffer[22,i] := '*' else
Buffer[22,i] := '·';
      if BigCar[No]^[i] and $800000 <> 0 then Buffer[23,i] := '*' else
Buffer[23,i] := '·';
      if BigCar[No]^[i] and $1000000 <> 0 then Buffer[24,i] := '*' else
Buffer[24,i] := '·';
      if BigCar[No]^[i] and $2000000 <> 0 then Buffer[25,i] := '*' else
Buffer[25,i] := '·';
      if BigCar[No]^[i] and $4000000 <> 0 then Buffer[26,i] := '*' else
Buffer[26,i] := '·';
      if BigCar[No]^[i] and $8000000 <> 0 then Buffer[27,i] := '*' else
Buffer[27,i] := '·';
      if BigCar[No]^[i] and $10000000 <> 0 then Buffer[28,i] := '*' else
Buffer[28,i] := '·';
      if BigCar[No]^[i] and $20000000 <> 0 then Buffer[29,i] := '*' else
Buffer[29,i] := '·';
      if BigCar[No]^[i] and $40000000 <> 0 then Buffer[30,i] := '*' else
Buffer[30,i] := '·';
      if BigCar[No]^[i] and $80000000 <> 0 then Buffer[31,i] := '*' else
Buffer[31,i] := '·';

   end;
end;

procedure Encode(No : Byte);
var i,j : byte;
begin
   for i := 0 to 36 do
   begin
      BigCar[No]^[i] := 0;
      if Buffer[0,i] = '*' then BigCar[No]^[i] := 1;
      if Buffer[1,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $2;
      if Buffer[2,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $4;
      if Buffer[3,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $8;
      if Buffer[4,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $10;
      if Buffer[5,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $20;
      if Buffer[6,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $40;
      if Buffer[7,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $80;
      if Buffer[8,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $100;
      if Buffer[9,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $200;
      if Buffer[10,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $400;
      if Buffer[11,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $800;
      if Buffer[12,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $1000;
      if Buffer[13,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $2000;
      if Buffer[14,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $4000;
      if Buffer[15,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $8000;
      if Buffer[16,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $10000;
      if Buffer[17,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $20000;
      if Buffer[18,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $40000;
      if Buffer[19,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $80000;
      if Buffer[20,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $100000;
      if Buffer[21,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $200000;
      if Buffer[22,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $400000;
      if Buffer[23,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $800000;
      if Buffer[24,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $1000000;
      if Buffer[25,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $2000000;
      if Buffer[26,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $4000000;
      if Buffer[27,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $8000000;
      if Buffer[28,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $10000000;
      if Buffer[29,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $20000000;
      if Buffer[30,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $40000000;
      if Buffer[31,i] = '*' then BigCar[No]^[i] := BigCar[No]^[i] + $80000000;
   end;
end;

procedure Preview;
var i, j : byte;
begin
   initGraph(grDriver,GrMode,'\turbo\tp\');
   for i := 0 to 36 do
   begin
      for j := 0 to 31 do
      begin
         if Buffer[j,i] = '*' then putpixel(j+GetMaxX div 2 ,i+GetMaxY div
2,15);
      end;
   end;
   readkey;
   closeGraph;
end;

procedure PreviewAll;
var i, j, k : byte;
begin
   initGraph(grDriver,GrMode,'\turbo\tp\');
   for k := 32 to 47 do
   begin
      Bufferize(k);
      for i := 0 to 36 do
      begin
         for j := 0 to 31 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-32) * 36 ,i+20,15);
         end;
      end;
   end;
   for k := 48 to 96 do
   begin
      Bufferize(k);
      for i := 0 to 36 do
      begin
         for j := 0 to 31 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-48) * 36 ,i+60,15);
         end;
      end;
   end;
   for k :=  97 to 127 do
   begin
      Bufferize(k);
      for i := 0 to 36 do
      begin
         for j := 0 to 31 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-97) * 36 ,i+100,15);
         end;
      end;
   end;
   for k :=  128 to 155 do
   begin
      Bufferize(k);
      for i := 0 to 36 do
      begin
         for j := 0 to 31 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-128) * 36 ,i+140,15);
         end;
      end;
   end;
   for k :=  156 to 180 do
   begin
      Bufferize(k);
      for i := 0 to 36 do
      begin
         for j := 0 to 31 do
         begin
            if Buffer[j,i] = '*' then putpixel(j+(k-156) * 36 ,i+GetMaxY div
2+70,15);
         end;
      end;
   end;
   readkey;
   closeGraph;
end;

function Edit(No : byte) : Char;
var x, y : byte;
    car  : Char;
    Sortie : Boolean;
    Go     : byte;
    CaracTempo :  char;
begin
   UpDate(No);
   x := 0;
   y := 0;
   Sortie := false;
   Etat := Move;

   repeat
      GotoXY(1,1);
      Write('          ');
      gotoxy(1,1);
      if etat = move then write('Move')
      else
         if etat = delete then write('Delete')
         else
            if etat = trace then write('Trace');
      GotoXY(60,1);
      write('(',x:2,' , ',y:2,')');
      GotoXY(4 + 2*x,5+y);
      HighVideo;
      Write(Buffer[x,y]);
      GotoXY(4 + 2*x,5+y);
      repeat
      until keypressed;
      car := ReadKey;
      GotoXY(4 + 2*x,5+y);
      LowVideo;
      Write(Buffer[x,y]);
      if (car = 'q') or (car = 'Q') then car := #13;
      if car = #0 then car := ReadKey;
      case car of
         '2',chr(80)   : begin
                            if y = 36 then y := 0 else inc(y);
                            if etat = trace then buffer[x,y] := '*'
                            else if etat = delete then buffer[x,y] := '·';
                         end;
         '8',chr(72)   : begin
                            if y = 0 then y := 36 else dec(y);
                            if etat = trace then buffer[x,y] := '*'
                            else if etat = delete then buffer[x,y] := '·';
                         end;
         '4',chr(75)   : begin
                            if x = 0 then x := 31 else dec(x);
                            if etat = trace then buffer[x,y] := '*'
                            else if etat = delete then buffer[x,y] := '·';
                         end;
         '6',chr(77)   : Begin
                            if x = 31 then x := 0 else inc(x);
                            if etat = trace then buffer[x,y] := '*'
                            else if etat = delete then buffer[x,y] := '·';
                         end;
         '1',chr(80)   : begin
                            if y = 36 then y := 0 else inc(y);
                            if x = 0 then x := 31 else dec(x);
                            if etat = trace then buffer[x,y] := '*'
                            else if etat = delete then buffer[x,y] := '·';
                         end;
         '7',chr(72)   : begin
                            if y = 0 then y := 36 else dec(y);
                            if x = 0 then x := 31 else dec(x);
                            if etat = trace then buffer[x,y] := '*'
                            else if etat = delete then buffer[x,y] := '·';
                         end;
         '9',chr(75)   : begin
                            if x = 31 then x := 0 else inc(x);
                            if y = 0 then y := 36 else dec(y);
                            if etat = trace then buffer[x,y] := '*'
                            else if etat = delete then buffer[x,y] := '·';
                         end;
         '3',chr(77)   : Begin
                            if x = 31 then x := 0 else inc(x);
                            if y = 36 then x := 0 else inc(y);
                            if etat = trace then buffer[x,y] := '*'
                            else if etat = delete then buffer[x,y] := '·';
                         end;
         ' '           : if etat <> trace then etat := succ(etat) else etat :=
move;
         #13, #81, #73 : Sortie := true;
         #27           : Sortie := True;
         'G','g'       : begin
                            GotoXY(20,49);
                            Write('Aller à quel code ascii ? ');
                            Read(Go);
                            if (Go >= 32) and (go <= 180) then
                            begin
                               Encode(No);
                               EnCours := Go -1;
                               Car := #81;
                               Sortie := true;
                            end;
                            GotoXY(1,49);
                            ClrEol;
                         end;

         'v', 'V'      : begin
                           Preview;
                           update(No);
                         end;
         'a', 'A'      : begin
                            Encode(No);
                            PreviewAll;
                            Bufferize(No);
                            Update(No);
                         end;
         'c', 'C'      : begin
                            gotoXY(20,49);
                            Write('Copier quel caractère ? ');
                            CaracTempo := ReadKey;
                            if CaracTempo <> #13 then
                            begin
                               Bufferize(ord(CaracTempo));
                               UpDate(EnCOurs);
                            end;
                            GotoXY(20,49);
                            ClrEol;
                         end;
      end;
   until (sortie);
   Encode(No);
   Edit := Car;
end;

procedure EditeTable;
var fin     : boolean;
    Car     : char;
    Car_Retour : char;
begin
   fin := false;
   Encours := 32;
   repeat
      Bufferize(Encours);
      Car_Retour := Edit(EnCours);
      case car_Retour of
         #13 : begin
                  gotoXY(20,49);
                  Write('Quitter ? ');
                  Car := UpCase(readKey);
                  GotoXY(1,49);
                  ClrEol;
                  if Car = 'O' then Fin := true;
               end;
         #81 : begin
                  if EnCours = 180 then Encours := 32 else inc(EnCours);
                  etat := move;
               end;
         #73 : begin
                  if EnCours = 32 then Encours := 180 else dec(EnCours);
                  etat := move;
               end;
         #27 : begin
                  gotoXY(20,49);
                  Write('Abandon des modifications ? ');
                  Car := UpCase(readKey);
                  GotoXY(1,49);
                  ClrEol;
                  if Car = 'O' then Halt(0);
               end;
      end;
   until fin;
end;

procedure SauveTable;
var Fichier : Text;
    i       : byte;
    j       : byte;
begin
   Assign(Fichier, 'Big.FON');
   Rewrite(Fichier);
   For i := 32 to 180 do
   begin
      for j := 0 to 36 do
      begin
         writeLn(Fichier, BigCar[i]^[j]);
      end;
      WriteLn(Fichier);
   end;
   Close(Fichier);
end;

begin
   DetectGraph(GrDriver, GrMode);
   InitGraph(grDriver, grMode,'\turbo\tp\');
   ErrCode := GraphResult;
   if ErrCode <> grOk then
   begin
     Writeln('Graphics error:', GraphErrorMsg(ErrCode));
     Halt(255);
   end;
   CloseGraph;


   NormVideo;
   ReserveMemoire;
   ChargeTable;
   EditeTable;
   SauveTable;
end.

{
You'll find here the fonts I had already done. They are not complete. (use A
to see all the characters) You must use XX3402 that you'll find on the Swag.
If you make others fonts, would you please send them to me ?
}

{ cut this out as save as FON.XX.  Use XX3402 :   XX3402 d FON.XX to
  create FON.ZIP containing the FONT files need here }

*XX3402-004554-160794--72--90-49467---------FON.ZIP--1-OF--1
I2g1--E++++6+1lIWFn1MZsTikA++8QI+++7++++Iop-H2kiFYxCXJVhggAU0DnTaRv3449h
yIzq+c6iWiaP0Ool-70D3NDSfxrpTaJujocOlDRAA5mzXdHptmmlaDi5Z+tylkr6i6vvvSia
md8HXZCvtn2z3xPDHKRh2okwHDTQhs6Y2trjmNAOAQAr8lDJFaRi9mlKqsDe9tvWFvTcKw1m
a4FSF-k3XAwoJeTeCZCbH5v0aBN91NgaBHPSxRA3ARGLS35gZaxd5V2fvjgmZg8K3zAn9y4X
2lRMmJsFfyfMuAVUXIYet1lwc2b6EzfzeAlw7k8DX6gX0MYYAAKGH7ilpNJ3lAlKno5eJhRp
5D46Km81627lm1m1rTKIa3l99ao9iPEkjzjIURmqxsMkmMYcX8C8Sebqj75bIdS-RvJQVqBc
r-UHVaMS-t4YI-AnTz788AFGVVdqh739nt+XG3zG7IS7oAqTpshfjV+PU7nn1eWoHgIbX+aK
STqTZR3miIKrueyhyij4M-snAbkAu-Uit4RS3fsRyaQ8wRP7FYBRBZ-vndj+66Lce0MLO6sE
63fIIy0B8CrZa9j3xvCjyutOlbXaEEKFoHrvcAdvJUeHS9F4Znld6-HVX2F-CAv++8HHvRjV
hNZarRQZ4vfczzKi-PWVfupVCACKlbkFD60I4a8AxFFAD5wKqu0qIUlE5+j9yHFnQbRsVi+C
x1QJdWvHsr6y4DrGdSkEtgn9iV-XiW6KHGe9oeHeeLlEKPi6Fi6PHOtHsJ2tSyR4FEUmZ0tf
Ell5fNBnhIg8VCnWQlKD8lPVCYJKcoq9U5ajQjpBKj-Wld8Jcl6orMs1cKFpe1C+pq9q+gxV
uLVcjUoIyQuFbxecthQbY10GnfFvXR03wdHnsYdUZMS0UwwDxTcx4Dh5usHPJFIE8a1gt42D
8r1+a+iytmEUrkB+oLxEf5dhANDdgz9P6y6KvqdYRvGqx7j3BcrzWRa03JWntOazAOzIzzGY
u278HpnJRMrOAffaWWi4gOOaQE8HBWNVxOn55MIauLj0DBfUrmyK8MQW3h0oHrq6utt7THLl
xBDFJM+dOVpRr+7BoL21tI-CBrE7RpvNPB-YppDpLA8YOZYqhRpm6j--MkxJA+mHAWScBD1-
jenfvle7TFakv6Aa4zqDfFVsv41EizHCN8aiqgg0ptXcKXCCeOTeIT0IWejm6fDPANOD8CTV
DRQXSIVPeq3gwJ6RqNoC3vMY-rHxyX+KHHpEoKQqr5IZLJHW7vybdVOT44RD9TOrSCxtw9wB
YETwfIUFujjJD+gbUZBdEChACGCiDp-9+kEI++++0++JUMoQbzQ8qa+5++-FC+++-k+++2p7
F0t4HovJKyhmvGc6zhyNjcire5by7ng-j60L74NZRQyNOP-B6WX07q0eTbySzTnyu1qurlyb
T83F-mwdTofjlxobEbnkptsJSzbskxbRpANM0nmAUPSpBaj1hhec8yernKuZySkhcYQ92n78
cqvURyq0Wn+R5sv4vWcF-nAmmc3mh3Ts6f+kPjSW0OMk6Mv25EIVkFZP2o09PhTFEnSj3SfE
59qx-VtK6OQBh-dwH7opu-dvFZExXWEsEspqp4VwNYBGvUTaJ+o1lv0V3XOzm+F5vPJnSJdq
kwbUt5G+dwUSGFJNtG8V3uYHAG-al7W256c-RGPxu8EgB2dwXgH-kofe+rkDHFxukXBYZRSg
9C5F9NNJ1Zs-7lJJKKgHT4rc5XqbRpB5sZ8t6a29pXldWDMKC8Paz3qq3jTLfGe6b+FKLNhs
lcEAbiWdFOkOcg+b6N0kls+aiM4RyUpOUw43ZKBWO71+F8DpYTpuI9HTUP3rk0DFPMCb-fVv
Mz3rJTcG5sM-KJOmtdpQ3zFu94INyGQo2ikXnR9G+1kAoWcQ8UuDR9OYCSCuVOM7gSr07szr
OWVWXqInsGsg8TJ3TqKPHuCyaF8H8UZZT4COuyfXjEqvRX6MFnh8cwwFrInKD+SA9AMd45NY
IyT026hI9-i9BZOPKkrTxYRHmfO+WuvOrOSpW0aVmQUdQTHXMbd8vxltQuv+dx8S9JQ9H9TE
eoD-FFPxDYnyg6W-3C0Nx6XqJxdNaIAadV7n9u5yt32OOhqW9sNl0wPbWpyw+8QVanBBhHhb
2vmFWC82GbKBpHUlNmWY36opV2Q64bhA0WaLhy0fFyCNtb4d8GV5Z9D7YjSdslQqq3l1V3mW
GtUdHZ3ccz2V0gK0M8qsaeX6DWrywSgIspMawvGNHoWeDlf2FHtwr16GPON3PogCvr5bZyGO
oVcmj-Dpuwp4pYmg1mBttBUuzqoZftfkaI5nfSZw2vivisbpcC0M4fu-9ZAK9St1tF2gMoBV
7gIRSUAcW9+yawcYob9hdYEbFbJQIhCcuwFeFhQBaoq9Yuc3aoDUQqWXqVdAWkvpLI16wffL
NnFLFs8GGO4KhA4ci2ULXIKcpnNWcaVhWcQ6nmbv5iDb1B+yVdkNmd4vQmkS-Xpl5FXi-pIL
33Ab5YUpgQmBST+Ns3eaaU0gVAlfKbdrUR03T7qpPOCVohlPZkmc0F9r64cOuyElb9tbOizk
dyW36Va8OX1+YRKZRyEZLmOIGNWH2QWm4Ce4qAac8vYNcBqTcN0sZn-trJGOzREEueqZ1FR+
vnRomhEwr4V5F18ayFmDXXh9yMFkNCCqE1JMGDCUKdQXvUoee2VSb27ZaidcK3i9kfpiZpFL
SrG3wItB5sxV08Y0APo3FQg6Isi6wJU2qvbz82OaM5stB2kFgolBFvB97OTHM3UCTEGIOd7v
rZ56yHHCZ0JnwLYAnNIVtpCDWXfacYFZ+2ZrHpSBCzARThKbwz4Ou+DHlxbeWWltcaCi8lfk
qyMYaatSPFKVph7jY25ofqF-fUVdvexEZ3GCF8fBpWjUgEISAS1iH-3n7jUbDg-LM3DBhDRV
SEWnHb11DfLqsDXiZ4DrlSP8btXtjKIdRnpq+S4ewts8GQ-XzOn7vVBG+A0jR6MuMxzLZXbB
JQ9UtkJMABAdEBQHJYdfNwbAo75YODqkw759T5s+szVG5m5bxVsatgjeic4IIsvtS-z5kKEP
JcJn41sDTTg+y1lsTn7sYM7jm1HgR4kDhwtLYm7IAZzOcOkVnFeJEo7WVfTd3NozLx0bTjBI
txp4hPDu5JfFI7csscJSBMH34G+WIjp3RIT0H2hdMyoRP3O5Gjg1bOily9abDQwYvBLMSIEU
SKgClldwceF3pSm3Lm8GErNlcqr1s8Zy0CIISCbbs8WXqksVpgC56zzcfxwDuietqVJRZ01L
bESCzS8dfpn1J7CJjVvXhiQgLwtgt3vvHK51NCwvcUVVAOQaaWJyAo3QmRqcKdWhb4RjPSZX
NV1TG8l49jGWY3aqzzswq+QMvyExkq97dolZcSU3bWYucb5yoIbhqBIK1cijNPTG8jX8ngod
tCE2wjeQuBbDdpr5PjupJ4nJptw94vfxRoGBRTWB84+seKw6SWqmiNw3XCGxQNcsCQptNrdf
loSeeMvNyhrUSg4pGkcy+s9zJxQqLjZqi1cKxwaiCKPt5MmOmbcRCfE7W2ts64pX4r+lF5Uc
KQf0+nx35tAbRqgzS1Xtoi5V7ktDPLOO5Z0pMMoDkzzF+OWRT1DMO9FKWiVoUoMmYTnd2SS2
vGR5Xe9udG9zG+xfDCXny7Ju85o0famA0jyr-SgqJDZFuKFU3ddRG5+FDlDN6+9Mw-oLe1N3
yk2KJ7n4TtbEGWvdxLwReSNXq4TzvREdLlgg2uJecOOeZpTZJACLqvZO8AwW7atlrbgWfERt
yhXZI0-coOBPzwKhMqn-iTrrNvQS10A4Q7szj+TTsSVUXw5t06tVcc7zZjffarxEm3nuSi07
UDw+I2g1--E++++6+AloXVlDpuzgVkI++DBH+++5++++EYZ59YNDHipNuqsXCkXyLubjkgI4
yzaTv-XkX4SmiPFdYxoX6OK-n6IDA4-AsTDXbNzD1mFePL-I4tHqyJ47eA0W02JfdKSNGr4r
u+NzWqtevdzGoSFzLSpPW3DEkGKAdLM0SAFFFJ4K2nSchh-UtlerXaEuMmxJLfCChGa-Eba4
Ep1KUcrUOzlDgBv9jRCmnkyWnWe9WW6otQ2V3o6J4MyFhA8pY9r9oVFO5kwIuPqXDp0+KeDa
2GNBd68GmlGIfpD5PdsuUKocUQqRBalhdUMATKefwVfKh+yqksvKdNrgDrXZs8jZk2jLPjGE
+ppUmd48t5uIKgZnL9d8EElB43gh7P7KU1pCe1M4x2KXXiCpaSZ8JbLEe3Uium1gBngHSgPr
6QESuYB0qGeHeH9SxURauF6gRdh-DSeepkgJiwLB8oOr4khTlawdrQCbYcUf5SloZ93FRc8Z
Bhw0iqyG9ifBSrSLokNnWvfPRW8pqb7DkeEK7mVgQTc8tIFJmTCagk0O+lT5J030SEL+jisv
gurvFjw6pFY5SnlUYRNyXpv8jwGzp0x0y7cZ-mhrmuztNLbBZb3Qw-Hq9zP2bj2Q6Hv71Dx7
jaj2fx25Wr4VtQa0g0cgL-Ov+usMw6+mBk08AZZpL+9PGvd6wQ958CWZVp4VxB0WPko3cfeE
Udrx8M7SAHOwIcdRWRcO3TQFivyoWxY3vp+9TKaoh3mO9qiKVRzpnIMDeTegW4zHq6T8ZxVr
uHHdKufsfQG7PKvFQsJy+aRhy+zN7wlseMiSKuRdY0K2hmOAheZtOo7lVf5KF06F8oeRtkUO
H7kTpcPyRpcHHzfE9nGnnDTwzjlcpzrTS+-saFGp5hHfEeoZBbhfRQ0XOaVA09vJaVCuq+tp
NeKnOs5IJL1ePrpWl0KdxWfFKIUPTu4W1+jN1s6o-044-+4RdNpe9sJw0lWghMjHtlpVQrxh
d-Gg+BCwKaNNhhNFcYwlRWu9gP50nW9uAS+q0x4RBXJ5mB39mrCvAzTmT5Pqjhs2JdZhNI08
xosoffiCUqbF8ECd-kDq9bvOkBuUcCSuqW5N-PPMwHT7zmC4iFO75Sg8RzMQEFQrp1mfRXsm
LoTQK9A1PPO14Xo+ZdaRpVGVrnpnZmrHTKuZAnAkc1Tu3hbC1HqeklNgsa40I8Gu023D1zhZ
hcjjhx4WFAvSzptFRdyvW1C9G1EjqFCFZLtIWomAwlhgKE0+gdKliVqqe3Bddy9q91jY2zgq
6EcxwbSclH5RKRmuSrXZ3z+jqMBRRFohkkT9AwhRmsL9fFTiXV6zaAOnLDssoKRzqtJpvVFx
VcIx2cl4+FlMRRhBcanvOA51vWvrpemLMMSXbborFknh8qntnhT-nAjNXVz1EutsUow+bLo+
QxXWLw1KTQ+VJLQoLRpyH5fL2CVeE3s25lRgNNyhMDRdZ6YHobpwledaRCRSapO9kkOJiQKa
BVtiseAavLmcHrOZalsyt6Vuiby3Pac01XrrMKGonSow6E-2a5ogyptyuT1ElKT5fU5RTQvr
VV-ZRI-hHzdtezRDY4gC+PUmgHkgzHN1N7jRkPjNUnc57KzcypsZZrSi8vbQywTVtBzmz+PQ
HXLUlVHvdTKohDpIJdTlTivxWPjj12ArydDDBqLzCsdRbEGTFw0TVktonarbGTZuCzqSor5k
qtEk5hgaWBizJuTA1KD1L8SJHOpRoQAoRfTbQ5XMvJuyi9OUlwzOsyxnxtTlRuEQ0vyTB8oB
g7mDErKQHZvcrFQDGIePBdZlXxPZNTxvGQ+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2
HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+2HA+T+js5I2g-
+VE+3+++++U+D3G75ABWLVyv+k++dlE+++Y++++++++++E+U+++++++++3BBEIlA9YNDHZ-9
+E6I+-E++++6+-K-XFmTxkfOM+Q++32s+++5++++++++++2+6++++C61++-BGIEiFYxCI2g-
+VE+3+++++U+n5GC52zLfym5-E++wpA+++Q++++++++++E+U++++Nkg++277Fmt4HotEGkI4
++++++A++k0V++++2l2+++++
***** END OF BLOCK 1 *****

