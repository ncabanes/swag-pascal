(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0017.PAS
  Description: Drive Volume ID
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

{
 In the thread concerning copy protection (in which I have no
 interest) the serial number of a disk was mentioned.
 How can this be read from TP? Can it be changed other than
 by re-Formatting? I can't find any reference to serial number
 in the Dos 5.0 users guide except a passing one in the section
 on the ForMAT command.

Reading the volume id number is no problem:

reads volume id number -- not sophisticated enough to
determine whether disk was Formatted With a Dos version
new enough to assign volume id }

Uses Dos;

Function Byte2HexSt(b : Byte) : String;
Const
  hexChars: Array [0..$F] of Char =
    '0123456789ABCDEF';
begin
  Byte2HexSt := hexChars[b shr 4] + hexChars[b and $F];
end;

Procedure ResetDisk(DriveNo : Byte);
Var
  reg : Registers;
begin
  reg.ah := 0;        { bios Function reset drive system }
  reg.dl := DriveNo;
  intr($13,reg);
end;

Function VolIDSt(DriveCh : Char) : String;
{ returns Volume ID number as a String of hex digits }
Var
  reg : Registers;
  try : Integer;
  buff : Array[0..1023] of Byte;
begin
  DriveCh := upCase(DriveCh);
  try := 0;
  Repeat
    reg.ax := $0201;  { ah = bios Function read disk sector }
                      { al = read 1 sector }
    reg.cx := $0001;  { ch = cylinder number }
                      { cl = sector number }
    reg.dh := 0;      { head number }
    reg.dl := ord(DriveCh) - 65;  { drive number }
    reg.es := seg(buff);
    reg.bx := ofs(buff);
    intr($13,reg);
    inc(try);
    if reg.flags and FCarry <> 0 then ResetDisk(reg.dl);
  Until ((reg.flags and FCarry) = 0) or (try = 3);
  if reg.flags and FCarry <> 0
    then VolIDSt := 'Error attempting to read volume ID number'
    else VolIDSt := Byte2HexSt(buff[$2A]) +
                    Byte2HexSt(buff[$29]) + '-' +
                    Byte2HexSt(buff[$28]) +
                    Byte2HexSt(buff[$27]);
end;

{
Can the volume id number be changed?  You bet.

Although it is True that DISKCOPY will not copy the volume id
number from the original disk, it's still a pretty weak basis For a
copy protection scheme.  I consider myself a pretty unsophisticated
Programmer, but it only took me a few minutes of fooling around to
figure out where the volume id number is on the disk.  then all you
have to do is grab an interrupt reference and quickly Type up some
code to read and Write to the right spot on the disk.
}

