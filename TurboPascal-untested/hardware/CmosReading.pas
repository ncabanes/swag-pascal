(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0034.PAS
  Description: CMOS reading
  Author: PETER VAN DER LANDEN
  Date: 08-25-94  09:05
*)

{
From: landen@cir.frg.eur.nl (Peter van der Landen)

>I am attempting to write a program in TP6.0 that reads the CMOS memory
>(IBM PC) and saves the settings to a disk file.  I know there are 255
>locations, but I don't know where.  If someone could point me to the
>correct memory addresses, I'd really appreciate it.  Thanks (in advance)!

This unit (by an unknown other) shows you how it's done. The CMOS memory is
not part of the PC's main memory. Values are written/read by accessing an
I/O port.

}
unit CMOS;

Interface

const
     ClockSec  = $00;    { RTclock seconds }
     ClockMin  = $02;    { RTclock minutes }
     ClockHour = $04;    { RTclock hours }
     ClockDOW  = $06;    { RTclock day of week }
     ClockDay  = $07;    { RTclock day in month }
     ClockMon  = $08;    { RTclock month }
     ClockYear = $09;    { RTclock year (mod 100)}
     AlarmSec  = $01;    { Alarm seconds }
     AlarmMin  = $03;    { Alarm minutes }
     AlarmHour = $05;    { Alarm hours }
     Diskettes = $10;    { Floppy disk type byte }
     HardDisk  = $12;    { Regular hard disk type }
     HDExt1    = $19;    { Extended hard disk type, unit 1 }
     HDExt2    = $1A;    { Extended hard disk type, unit 2 }
     Equipment = $14;    { Equipment list }
     CheckLo   = $2F;    { Checksum low }
     CheckHi   = $2E;    { Checksum high }
     BaseLo    = $15;    { Base mem low }
     BaseHi    = $16;    { Base mem high }
     ExpdLo    = $17;    { Expansion mem size low }
     ExpdHi    = $18;    { Expansion mem size high }
     StatRegA  = $0A;    { Status Register A }
     StatRegB  = $0B;    { Status register B }
     StatRegC  = $0C;    { Status register C }
     StatRegD  = $0D;    { Status register D }
     DiagStat  = $0E;    { Diagnostic status byte }
     ShutDown  = $0F;    { Shutdown status byte }
     Century   = $32;    { BCD Century number }
     AltExpdLo = $30;    { Expansion mem size low (alternate) }
     AltExpdHi = $31;    { Expansion mem size high (alternate) }
     InfoFlags = $33;    { Bit 7 set = top 128k installed, bit
                           6 set = first user message (?) }

function ReadCmos(Address: byte): byte;
          { Returns the byte at the given CMOS ADDRESS }

procedure WriteCmos(Address, Data: byte);
          { Writes DATA to ADDRESS in CMOS ram }

procedure SetCMOSCheckSum;
          { Sets the CMOS checksum after you've messed with it :-}

{ The following bytes are RESERVED: $11, $13, $1B-$2D, and
  $34-$3F ($3F marks the end of the CMOS area).  You'll note that
  some of these are included in the checksum calculation. }

implementation

const
     CmosAddr  = $70;    { CMOS control port }
     CmosData  = $71;    { CMOS data port }

function ReadCmos(Address: byte): byte;
begin
     port[CmosAddr] := Address;
     ReadCmos := port[CmosData]
end; {ReadCmos}

procedure WriteCmos(Address, Data: byte);
begin
     port[CmosAddr] := Address;
     port[CmosData] := Data
yend; {WriteCmos}

procedure SetCMOSCheckSum;
{ The checksum is simply the sum of $10 to $2D 
  (some of these bytes are reserved) }

var
     I, Sum: word;
begin
     Sum := 0;
     for I:= $10 to $2D do Sum := Sum + ReadCmos(I);
     WriteCmos(CheckHi, Hi(sum));
     WriteCmos(CheckLo, Lo(sum));
end; {SetCMOSCheckSum}

end.

