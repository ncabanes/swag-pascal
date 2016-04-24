(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0021.PAS
  Description: device Driver Lists
  Author: WILLIAM PLANKE
  Date: 01-27-94  11:57
*)

{
I've posted a working util that lists the Device Drivers that are resident in
memory.  It uses the header record to point to the next driver in the chain
and "walks" the memory chain until an offset end flag is reached.  Hope you
enjoy it and that it isn't too sloppy.  At the end, I have a question that
needs to be answered if you're interested....
}

program DevList;

{ this program walks the device driver memory chain. Each device
  driver points to the next until the ENDFLAG is reached.  I use
  the popular undocumented DOS function $52 to jump to the DOS
  "List of Lists" then $22 bytes beyond that, the first device in
  the chain (NUL) can be found.

  Thanks to Ralf Brown and his valuable MS DOS Interrupts List,
  to Timo Salmi, and to the person(?) who wrote the cool
  hex-to-string conversion functions that I use all the time.
}

{$M 8192,0,0}

uses
  DOS;

type
  pstrg = string[9];                { pointer conversion format }

  Array8C = array [1..8] of char; { for device and file names }

  DevRec = record
    NextDev_ofs  : word; {pointer to next device header, offset value}
    NextDev_seg  : word; {pointer to next device header, segment value}
    Attributes   : word; {Attributes: block or char, IOCTL, etc.}
    Strategy     : word; {pointer to device strategy routine, offset}
    Interrupt    : word; {pointer to device interrupt routine, offset}
    NameDev      : Array8C; {Name if char, or units if block}
  end;
  DevPtr = ^DevRec;

  DevFileRec = record
    FileName : Array8C;
  end;
  DevFilePtr = ^DevFileRec;

const
  LOL_HEADDEV_NUL  = $22; { offset from "List of Lists"
                            to NUL device header }
  FNAME            = $8;
  ENDFLAG          = $FFFF;
  STDDEVS : array [1..12] of Array8C =
    ('NUL     ', 'CON     ', 'AUX     ', 'PRN     ',
     'CLOCK$  ', 'COM1    ', 'COM2    ', 'COM3    ',
     'COM4    ', 'LPT1    ', 'LPT2    ', 'LPT3    ');

var
  r       : registers;
  i,        { index }
  Adjust  : byte;
  Header  : DevPtr;
  DevFile : DevFilePtr;
  Valid,
  Done    : boolean;


function BinW(Decimal : word) : string;
const
  BINDIGIT : array [0..1] of char = '01';
var
  i     : byte;
  Binar : string;
begin
  fillchar (binar, sizeof(Binar), ' ');
  Binar [0] := chr(16);
  for i := 0 to 15 do
    Binar[16-i] := BINDIGIT[(Decimal shr i) and 1];
  BinW := Binar;
end;


function HexN (b : byte) : char;        { convert nibble to char }
begin
  b := b and 15;                   { forces to only 4 bits }
  if b > 9 then
     inc(b,7);                    { adjust for hex digits };
  HexN := chr(b+48);              { convert to character }
end;


function HexB(b : byte) : string;
begin
  HexB := HexN (b shr 4) + HexN (b);  { assemble the nibbles }
end;


function HexW(w : word) : string;
begin
{$R-}
  hexw := HexB(w shr 8) + HexB(w);  { assemble the bytes }
{$R+}
end;


function HexL(l : longint) : string;
begin
  HexL := HexW(l shr 16) + HexW(l); { assemble the words }
end;


function XP(p : pointer) : pstrg;         { display pointer P }
begin
  XP := HexW(seg(p^)) + ':' + HexW(ofs(p^));
end;

begin
  assign(output, '');
  rewrite(output);     { allow command line redirection }
  writeln('Device':0, 'Address':12, 'Strat':10, 'Intrpt':8,
          'Attrib':10, 'File Name':23);
  for i := 1 to 69 do
    write('-');
  writeln;

  with r do
  begin
    es := 0;
    bx := 0;
    ah := $52;
    { this is an undocumented DOS function call:
      Get pointer to DOS "List of Lists" }
    msdos (r);
    { es and bx now have values }
    if (es = 0) and (bx = 0) then
      halt(0);

    Header := ptr(es, bx + LOL_HEADDEV_NUL); { we get NUL dev from this }
  end; {with}

  Done := FALSE; { dummy variable to keep the repeat loop going,
                    otherwise would have to duplicate the output
                    routines one more time for the final device. }
  repeat
    with Header^ do
    begin
      Adjust := 0;
      { adjust keeps display columns aligned, bit 15 set is a Character
        device, if clear it is a Block device and 1st byte is # of block
        devs supported}

      if boolean ((Attributes shr 15) and 1) = TRUE then
        write (NameDev)
      else
      begin
        write ('BLKdev=', byte (NameDev[1]));
        Adjust := byte (NameDev[1]) div 10;
      end;

      write(XP(Header) : 12 - Adjust);
      write(HexW(Strategy) : 7);
      write(HexW(Interrupt) : 7);
      write(HexW(Attributes) : 7, '=');
      write(BinW(Attributes));

      { this next section I can't find documented anywhere, but I observed it
        and decided to include it anyway, with MSDOS v5.0, others are unknown.
        The file name's extension isn't saved and doesn't matter, either. }

      if ofs(Header^) < FNAME then
      { "borrow" from the segment and give it to the offset }
        DevFile := ptr(seg(Header^) - $1, ofs(Header^) + $10 - FNAME)
      else
        DevFile := ptr(seg(Header^), ofs(Header^) - FNAME);

      Valid := TRUE;
      for i := 1 to 12 do
        if DevFile^.FileName = STDDEVS[i] then
          Valid := FALSE;

      if Valid then
        for i := 1 to 8 do
          if not (DevFile^.Filename[i] in [' '..'z']) then
            Valid := FALSE;

      if {still} Valid then
        write ('  ', DevFile^.FileName);

      writeln;
      if NextDev_ofs = ENDFLAG then
        exit; { end of the device chain }

      Header := ptr(NextDev_seg, NextDev_ofs);

    end; {with}
  until Done;
end.
{
The question: I have seen utils that do this actually give the size of
the driver in memory.  MSD and PMap both do this.  Does anybody know
how I can determine the size of the driver in memory?
}
