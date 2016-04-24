(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0057.PAS
  Description: Converting Text Files to EXE's
  Author: BOB SWART
  Date: 05-26-95  23:31
*)

{
From: bobs@dragons.nest.nl (Bob Swart)

> Does anyone have a program to produce a self-displaying exe file from
> a text file....
}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S+,V-,X-}
{$M 16384,0,655360}

Uses Strings;

Const
  bufsize = 4096;

  InLineCode: Array[1..200] of Byte =
   ($BA,$AC,$01,$B4,$09,$CD,$21,$B4,$01,$CD,$21,$3C,$73,$74,$13,$3C,
    $53,$74,$0F,$3C,$70,$74,$06,$3C,$50,$74,$02,$EB,$E3,$B6,$05,$EB,
    $03,$90,$B6,$02,$B2,$0D,$B4,$02,$CD,$21,$B2,$0A,$B4,$02,$CD,$21,
    $BB,$C8,$01,$B9,$00,$00,$8A,$17,$80,$FA,$0A,$74,$16,$80,$FA,$0D,
    $74,$11,$80,$FA,$7F,$74,$7F,$8A,$E6,$CD,$21,$43,$FE,$C1,$80,$F9,
    $4F,$7C,$E3,$B2,$0D,$8A,$E6,$CD,$21,$B2,$0A,$8A,$E6,$CD,$21,$43,
    $80,$FE,$05,$74,$07,$80,$FD,$17,$74,$06,$FE,$C5,$B1,$00,$EB,$C6,
    $BA,$8E,$01,$B4,$09,$CD,$21,$B4,$01,$CD,$21,$B9,$00,$00,$B6,$02,
    $B2,$0D,$B4,$02,$CD,$21,$B2,$0A,$B4,$02,$CD,$21,$EB,$A8,$2D,$2D,
    $2D,$48,$69,$74,$20,$61,$6E,$79,$20,$6B,$65,$79,$20,$74,$6F,$20,
    $63,$6F,$6E,$74,$69,$6E,$75,$65,$2D,$2D,$2D,$24,$0A,$0D,$28,$50,
    $29,$72,$69,$6E,$74,$65,$72,$20,$6F,$72,$20,$28,$53,$29,$63,$72,
    $65,$65,$6E,$3F,$20,$24,$CD,$20);

var f,g: File;
    size: Word;
    Buffer: Array[1..bufsize] of Byte;

{ This function added by Kerry Sokalsky - Dr. Bob forgot it! }
Function UpperStr(St : String) : String;
Var
  Count : Byte;
begin
  For Count := 1 to Length(St) do
    St[Count] := UpCase(St[Count]);
end;

begin
  writeln('TXT2COM (c) 1992 DwarFools & Consultancy, by drs. Robert E. Swart');
  writeln;

  if ParamCount <> 2 then
  begin
    writeln('Usage: txt2com txtfile comfile');
    Halt(0);
  end;

  if UpperStr(ParamStr(1)) = UpperStr(ParamStr(2)) then
  begin
    writeln('Error: infile = outfile');
    Halt(1);
  end;

  Assign(f,ParamStr(1));
  reset(f,1);
  if IOResult <> 0 then
  begin
    writeln('Error: could not open file ',ParamStr(1));
    Halt(2);
  end;

  Assign(g,ParamStr(2));
  rewrite(g,1);
  if IOResult <> 0 then
  begin
    writeln('Error: could not create file ',ParamStr(2));
    Halt(3);
  end;

  BlockWrite(g,InLineCode,200);
  repeat
    BlockRead(f,Buffer,bufsize,size);
    if size < bufsize then
    begin
      Inc(size);
      Buffer[size] := 127 {terminating character};
    end;
    BlockWrite(g,Buffer,size);
  until size < bufsize;
  close(f);
  close(g);
end.


