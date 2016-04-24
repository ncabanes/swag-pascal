(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0077.PAS
  Description: Writing Text in Graphics
  Author: SWAG SUPPORT TEAM
  Date: 02-03-94  10:58
*)

(*
Write a unit, that assigns an text file to the Graphics Screen and then
assign output with this proc, then use rewrite(output) and you can
use write/writeln in Graphics mode as well. Don't forget
Assign(output,'');rewrite(output) or
CrtAssign(output);rewrite(output) when back in Text Mode!
You can even implement read/readln in graphics mode, but this is more
 complicated.
One difference to text mode: use MoveTo instead of GotoXY!

I've neither my unit nor the TP manual available just now,
but it works like this (output only!):
*)
unit GrpWrite;

interface

uses Graph,Dos,BGIFont,BGIDriv;

procedure GraphAssign(var F:text);

implementation
{$R-,S-}

var
  GraphDriver, GraphMode, Error : integer;
  a : string;

procedure Abort(Msg : string);
begin
  Writeln(Msg, ': ', GraphErrorMsg(GraphResult));
  Halt(1);
end;

{$F+} {DO NOT FORGET}

function GraphFlush(var F:TextRec):integer;
begin
  GraphFlush := 0;
end;

function GraphClose(var F:TextRec):integer;
 begin
   GraphClose := 0;
 end;       {There's nothing to close}


function GraphWrite(var F:TextRec):integer;
 var
  s : string;
  P : word;
 begin
 with F do
 begin
   P := 0;
   while P<BufPos do
   begin
     OutText(BufPtr^[P]);
     Inc(P);
   end;
   BufPos := 0;
 end;
{               (may need more than one OutText...)}
  (*... {Clear buffer}*)
  GraphWrite := 0;
 end;


function GraphOpen(var F:TextRec):integer;
 begin
   { Register all the drivers }
  if RegisterBGIdriver(@CGADriverProc) < 0 then
    Abort('CGA');
  if RegisterBGIdriver(@EGAVGADriverProc) < 0 then
    Abort('EGA/VGA');
  if RegisterBGIdriver(@HercDriverProc) < 0 then
    Abort('Herc');
  if RegisterBGIdriver(@ATTDriverProc) < 0 then
    Abort('AT&T');
  if RegisterBGIdriver(@PC3270DriverProc) < 0 then
    Abort('PC 3270');


  { Register all the fonts }
  if RegisterBGIfont(@GothicFontProc) < 0 then
    Abort('Gothic');
  if RegisterBGIfont(@SansSerifFontProc) < 0 then
    Abort('SansSerif');
  if RegisterBGIfont(@SmallFontProc) < 0 then
    Abort('Small');
  if RegisterBGIfont(@TriplexFontProc) < 0 then
    Abort('Triplex');

  GraphDriver := Detect;                  { autodetect the hardware }
  InitGraph(GraphDriver, GraphMode, '');  { activate graphics }
  if GraphResult <> grOk then             { any errors? }
  begin
    Writeln('Graphics init error: ', GraphErrorMsg(GraphDriver));
    Halt(1);
  end;
  with F do
  begin
  Closefunc:=@GraphClose;
  InOutFunc:=@GraphWrite;
  FlushFunc:=@GraphFlush;
  end;
  GraphOpen := 0;
(*  ... {Initialisations, see your TP manual}*)
 end;
{$F-}
procedure GraphAssign;
 begin
  with TextRec(F) do
   begin
     Mode := fmClosed;
     BufSize := SizeOf(Buffer);
     BufPtr := @Buffer;
     Name[0] := #0;
     OpenFunc:= @GraphOpen;
    {You can make some initialisations already here}
   end
 end;
end.
=================WRTGRTST.PAS follows==================
{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
uses Crt,
     Graph,     { library of graphics routines }
     GrWrite;
var
  GraphDriver, GraphMode, Error : integer;
  a : string;
  GrOutput:Text;

procedure Abort(Msg : string);
begin
  Writeln(Msg, ': ', GraphErrorMsg(GraphResult));
  Halt(1);
end;

begin
 GraphAssign(Output);  {Standard output to graphics screen}
 {$I-}
 rewrite(Output); {actually calls GraphOpen}
  {$I+}
 if IoResult <> 0 then halt;

(* ....*)
 MoveTo(65,90);
 a := 'this is a string';
 write('this is an embedded string');   {write to graphics screen}
 MoveTo(65,120);
 write(' and this is the second');
 Close(Output); {nothing shows on the screen until this is executed}
 ReadLn(a);
 CloseGraph;
 {Standard output to text screen}
 Assign(output,'');
 rewrite(output);
 GotoXY(5,20); {THIS WORKS}
 write(a);{nothing happens here}             {write to textscreen}
end.


