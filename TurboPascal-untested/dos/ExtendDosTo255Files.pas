(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0022.PAS
  Description: Extend DOS to 255 Files
  Author: MARK LEWIS
  Date: 08-27-93  21:02
*)

{
MARK LEWIS

> The problem is that Without allocating a new FCB For Dos, you
> can't have more than 15 or so Files open at a time in TP, no
> matter WHAT the CONFIG.SYS FileS= statement says.  (By default,

i cannot remember exactly what INT $21 Function $6700 is but here's a PD Unit
i got from borland's bbs the other day... i've trimmed the Text down for
posting... if anyone Really needs everything that comes With it, they should
look For EXTend6.*
}

Unit Extend;
{ This extends the number of File handles from 20 to 255 }
{ Dos requires 5 For itself. Applications can use up to 250 }

Interface

Implementation
Uses
  Dos;

Const
  Handles = 255;
  { You can reduce the value passed to Handles if fewer Files are required. }

Var
  Reg : Registers;
  begin
  { Check the Dos Version - This technique only works For Dos 3.0 or later }
  Reg.ah := $30;
  MsDos(Reg);
  if Reg.al<3 then
  begin
    Writeln('Extend Unit Require Dos 3.0 or greater');
    halt(1);
  end;

  {Reset the FreePtr - This reduces the heap space used by Turbo Pascal}
  if HeapOrg <> HeapPtr then
  {Checks to see if the Heap is empty}
  begin
    Write('Heap must be empty before Extend Unit initializes');
    Writeln;
    halt(1);
  end;
  Heapend := ptr(Seg(Heapend^) - (Handles div 8 + 1), Ofs(Heapend^));

  {Determine how much memory is allocated to Program}
  {Reg.Bx will return how many paraGraphs used by Program}
  Reg.ah := $4A;
  Reg.es := PrefixSeg;
  Reg.bx := $FFFF;
  msDos(Reg);

  {Set the Program size to the allow For new handles}
  Reg.ah := $4A;
  Reg.es := PrefixSeg;
  Reg.bx := reg.bx - (Handles div 8 + 1);
  msDos(Reg);

  {Error when a Block Size is not appropriate}
  if (Reg.flags and 1) = 1 then
  begin
    Writeln('Runtime Error ', Reg.ax, ' in Extend.');
    halt(1);
  end;

  {Allocate Space For Additional Handles}
  reg.ah := $67;
  reg.bx := Handles;
  MsDos(reg);
end.

{
Write the following Program to a separate File. This Program tests the EXTend
Unit. This test should be done on systems equipped With a hard disk.
}

Program TestEx;

Uses
  EXTend;

Type
  FileArray = Array [1..250] of Text;

Var
  f : ^FileArray;
  i : Integer;
  s : String;

begin
  {Allocate Space For fILE Variable Table}
  new(f);
  {oPEN 250 Files simultaneously}
  For i:=1 to 250 do
  begin
    str(i,s);
    Assign(f^[i],'Dum'+s+'.txt');
    reWrite(f^[i]);
    Writeln('Open #',s);
  end;
  {Write some Text to the Files}
  For i:=1 to 250 do
  Write(f^[i],'This is a test File');
  {Close the Files}
  For i:=1 to 250 do
  begin
    close(f^[i]);
    Writeln('Closing #',i);
  end;
  {Erase the Files}
  For i:=1 to 250 do
  begin
    erase(f^[i]);
    Writeln('Erasing #',i);
  end;
end.


