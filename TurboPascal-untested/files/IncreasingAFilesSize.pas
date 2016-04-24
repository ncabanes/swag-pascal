(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0037.PAS
  Description: Increasing a files size
  Author: IAN LIN
  Date: 11-02-93  05:58
*)

{
IAN LIN

Add junk to file to increase size. v.2.2. }

{$I-,G+,R-,D-,L-}

Uses
  dos;

Type
  buf = array [1..$ffff] of byte;

Var
  c, k,
  size : longint;
  s, v : word;
  f    : file;
  b    : ^buf;

Begin
  writeln('JUNK v2.2');
  if paramcount = 0 then
  begin
   writeln('Help screen. Syntax:');
   writeln(paramstr(0),' <infile> <bytes>');
   writeln('<infile>: source file -- <bytes>: bytes to add to source file');
   writeln('Error level codes');
   writeln('0: Normal execution or show help screen (no parameters)');
   writeln('1: Not enough parameters. Must have specify a file and size.');
   writeln('2: Invalid size specified for <bytes>');
   halt(0);
  End;

  if paramcount = 1 then
  begin
    writeln('Not enough parameters.');
    halt(1);
  End;

  assign(f, paramstr(1));
  val(paramstr(2), size, v);
  if (v <> 0) or (size < 0) then
  begin
    writeln('Invalid number in <bytes>. Run ', paramstr(0), ' alone for help.');
    halt(2);
  end;

  reset(f, 1);
  if ioresult = 0 then
    seek(f, filesize(f))
  else
    rewrite(f, 1);
  k := size div sizeof(buf);
  s := size mod sizeof(buf);
  randomize;
  new(b);
  for c := 1 to sizeof(buf) do
    b^[c] := random(128) + 128;

  while k > 0 do
  begin
    blockwrite(f, b^, sizeof(buf));
    dec(k);
  end;

  if s > 0 then
    blockwrite(f, b^, s);
  writeln('Wrote ', size, ' bytes to ', fexpand(paramstr(1)));
  writeln('Total size of ', fexpand(paramstr(1)), ' is ', filesize(f));
  close(f);
  dispose(b);
end.


