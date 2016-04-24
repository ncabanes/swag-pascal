(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0014.PAS
  Description: DOS Windowed Ouput
  Author: NORBERT IGL
  Date: 01-27-94  12:09
*)

{
   Norbert Igl
   Fido    : 2:243/8301.3
   Gernet  : 21:100/40.3
   Internet: q3976866@fernuni-hagen.de

> I seen some code posted here a few weeks ago. I meant to save it,
> but didn't. The code creates a windowed DOS shell.
> I would like to simply run a .BAT installation file in a window
> from my pascal program.

 ...same question a few days ago here in our local echo ... (:-)
 Its not only with windowed output ( easy possible )
 but also stores the pgm's output in your pgm's buffer ....
 have fun!
}

program test29;  {$M $1000,0,$FFF0}{ $C <Norbert Igl '93> }
uses    crt, dos;
const   maxBufSize = 64000;
        old29  : pointer = nil;
type    tVBuff = record
                    siz : word;
                    last: word;
                    txt : array[1..MaxBufSize] of char;
                 end;
        pVBuff = ^tVBuff;
var     Buf    : pVBuff;

procedure New29(Flags, CS, IP, AX,
                BX,CX, DX, SI, DI,
                DS, ES, BP: Word);  interrupt;
begin
  if Buf <> NIL then
  with Buf^ do
  begin
    if last < siz then inc( Last );
    txt[last] := CHAR(AX)
  end
end;

procedure BeginCapture;
begin
  if Old29 = NIL then  getintvec($29, Old29);
  SetIntVec($29, @New29 );
end;

procedure DoneCapture;
begin
  if old29 <> Nil then
  begin
    SetIntVec($29, old29);
    old29 := NIL
  end
end;

procedure InitBuffer;
begin
  Buf    := NIL
end;

procedure BeginBuffer(Size:word);
begin
  if Size > maxBufSize then size := maxBufSize;
  GetMem( Buf, Size );
  Buf^.siz := Size;
  Buf^.last:= 0;
  fillchar( Buf^.txt, size-4, 0);
end;

procedure DoneBuffer;
begin
  if Buf <> NIL then
  begin
    dispose(buf);
    initBuffer;
  end
end;

procedure ShowBuffer;
var i, maxy : word;
begin
  if buf = NIL then exit;
  maxy := (WindMax - WindMin) shr 8;
  clrscr;
  for i := 1 to Buf^.last do
  begin
    if wherey = maxy then
    begin
      write(' --- weiter mit Taste --- '); clreol;
      readkey;
      clrscr;
    end;
    write( buf^.txt[i] );
  end;
  write(#13#10' --- Ende, weiter mit Taste --- '); clreol;
  readkey;
  clrscr;
end;

begin
  InitBuffer;
  BeginBuffer($4000); { 16k Buffer, max=64k }
  BeginCapture;
  swapvectors;
  exec( getenv('comspec'),' /C DIR *.pas');
  swapvectors;
  DoneCapture;
  ShowBuffer;
  DoneBuffer
end.

