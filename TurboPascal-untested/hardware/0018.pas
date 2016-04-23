{
» Does anyone know how to get the hard drive type(s) from CMOS ?
» I can't seem to find this information documented anywhere.

This is probably a lot more than you are asking for but. . .
NOTE: one function (Long2Str) is not defined in this because it comes from
a commercial unit.  Basically all it does is convert a number to a string
and return the string.
     This code comes from a unit I wrote to get all kinds of niffty
information about your system.  I think I included everything you will need
to get it up and running.  If you get any strange problems or ones you
can't seem to resolve, let me know and I'll see if I can pass you the right
information.
}

Uses
  KMath,
  Dos;

type
  String80 = String[80];  { some general purpose string types }
  String40 = String[40];
  String30 = String[30];
  String20 = String[20];
  String12 = String[12];
  String10 = String[10];
  String5  = String[5];

  CMOSRec = Record
    Found     : Boolean;  { was a CMOS found to exist }
    CmosDate  : String30; { the date found in CMOS }
    CmosTime  : String30; { the time found in CMOS }
    VideoType : String10; { Type of video found in CMOS }
    Coproc    : Boolean;  { does CMOS report a math coprocessor }
    FloppyA   : String12; { type of floppy drive for A }
    FloppyB   : String12; { Type of floppy drive for B }
    Hard0     : Byte;     { Type of hard drive for drive 0 }
    Hard1     : Byte;     { Type of hard drive for Drive 1 }
    ConvenRam : Word;     { amount of conventional ram indicated }
    ExtendRam : Word;     { amount of extended Ram indicated }
    checkSum  : Boolean;  { Did checksum pass }
  end; { CMOS Rec }

const
  { values of constants for CMOS }
  DayName: array[0..7] of string[9] = ('Sunday', 'Monday', 'Tuesday',
                                       'Wednesday', 'Thursday', 'Friday',
                                       'Saturday', 'Sunday');
  MonthName: array[0..12] of string[9] = ('???', 'January', 'February', 'March',
                                          'April', 'May', 'June', 'July',
                                          'August', 'September', 'October',
                                          'November', 'December');
  ScreenName: array[0..3] of string[10] = ('EGA/VGA', 'CGA 40col',
                                           'CGA 80col', 'Monochrome');
  FloppyName: array[0..5] of string[11] = ('none', '5.25" 360K',
                                           '5.25" 1.2M', '3.5"  720K',
                                           '3.5"  1.44M', '3.5"  2.88M');
  CMOSport : Byte = $70; { port to access the CMOS }

{===========================================================================}


VAR
  Regs : Registers; { General purpose variable to access registers }
  CMOS : CMOSRec;   { variable to hold CMOS data }

function nocarry : boolean;
{ returns the status of the carry flag }
begin
  nocarry:=regs.flags and fcarry = $0000
end; {nocarry}

{---------------------------------------------------------------------------}

Function ByteToWord(ByteA, ByteB : byte) : word;
begin
   ByteToWord := Word(ByteB) shl 8 + ByteA
end; {cbw}

{---------------------------------------------------------------------------}

Function BitIsSet(CheckWord : Word; AndValue : Word) : Boolean;
{ returns true if the bit(s) indicated in AndValue are set in CheckByte }
BEGIN
  BitIsSet := CheckWord AND AndValue = AndValue;
end;

{---------------------------------------------------------------------------}

Function ReadCMOS(addr: byte): byte;
{ read a value from the CMOS }
Begin
  if CMOSport = $70 then
  begin
    inline($FA);
    Port[CMOSport] := addr;
    readCMOS := Port[CMOSport + 1];
    inline($FB)
  end
end; {readCMOS}

{---------------------------------------------------------------------------}

function addzero(b: byte): string5;
var
  c2: string[2];
begin
  Str(b:0, c2);
  if b < 10 then
    c2:='0' + c2;
  addzero:=c2
end; {addzero}

{---------------------------------------------------------------------------}

Function ChangeBCD(b: byte): byte;
{ change a BCD into a byte structure }
Begin
  ChangeBCD:=(b and $0F) + ((b shr 4) * 10)
end; {ChangeBCD}

{---------------------------------------------------------------------------}

Function GetCMOSDate : String30;
{ gets the date found in the CMOS and returns it in string format }
VAR
  Date,
  Century,
  Year,
  Month : Byte;
  WorkStr : String30;
BEGIN
  WorkStr := '';
  date    := ChangeBCD(readCMOS(7));
  century := ChangeBCD(readCMOS($32));
  year    := ChangeBCD(readCMOS(9));
  month   := ChangeBCD(readCMOS(8));
  WorkStr := DayName[readCMOS(6)]+', ';
  {case country.DateFormat of
    0, 3..255 :}
      WorkStr := WorkStr + Monthname[month]+' '+IntToStr(date)+', '+IntToStr(century)+addzero(year);
 {   1 :
      WorkStr := WorkStr + Long2Str(date)+', '+Monthname[month]+' '+Long2Str(century)+addzero(Year);
    2 :
      WorkStr := WorkStr + Long2Str(century)+addzero(Year)+', '+Monthname[month]+' '+Long2Str(date);
  end; {case}
  GetCMosDate := workStr;
end; { GetCMOSDate }

{---------------------------------------------------------------------------}

Function GetCmosTime : String30;
{ returns the time as found in the CMOS }
VAR
  CH : Char;
  Hour,
  Min,
  Sec  : Byte;
  WorkStr : String30;
  IsPM    : Boolean;
BEGIN
  workStr := '';
  hour := ChangeBCD(readCMOS(4));
  min := ChangeBCD(readCMOS(2));
  sec := ChangeBCD(readCMOS(0));
  IsPm := false;
  case hour of
        0: hour := 12;
        1..11: hour := hour;
        12: IsPM := true;
        13..23: begin
                  IsPM := true;
                  hour := hour - 12
                end;
  end; {case}
  WorkStr := WorkStr + AddZero(hour)+':'+addzero(min)+':'+addzero(sec);
  if IsPM then
    workStr := WorkStr + ' PM'
  Else
    WorkStr := WorkStr + ' AM';
  GetCMOSTime := WorkStr;
end; { GetCmosTime }

{---------------------------------------------------------------------------}

Function GetCmosCheckSum : Boolean;
{ performs checksum on CMOS and returns true if ok }
VAR
  CheckSum1,
  CheckSum2 : word;
  Count     : Byte;
BEGIN
  checksum1 := 0;
  for count := $10 to $2D do
    Inc(checksum1, readCMOS(count));
  checksum2 := (word(256) * readCMOS($2E)) + readCMOS($2F);
  if checksum1 = checksum2 then
    GetCmosCheckSum := true
  else
    GetCmosCheckSum := false;
end; { GetCmosCheckSum }

{---------------------------------------------------------------------------}

Procedure GetCMos;
{ gets the cmos record if it exist }
VAR
  Floppy : Byte;
BEGIN
  FillChar(CMOS, SizeOf(CMos), 0);
  regs.AH:=$C0;
  Intr($15, regs);
  if nocarry or (Mem[$F000:$FFFE] <= $FC) then
  With CMOS DO
  begin
    Found := true;
    CMOSDate := GetCMOSDate;
    CMOSTime := GetCmosTime;
    VideoType := ScreenName[(readCMOS($14) shr 4) and 3];
    CoProc := BitIsSet(readCMOS($14), 2);
    Floppy := readCMOS($10);
    if (Floppy shr 4) < 5 then
      FloppyA := FloppyName[floppy shr 4]
    else
      FloppyA := 'Unknown '+ Byte2Hex(floppy shr 4);
    if (floppy and $0F) < 5 then
      FloppyB := FloppyName[floppy and $0F]
    else
      FloppyB := 'Unknown '+ Byte2Hex(floppy and $0F);

    Hard0 := readCMOS($12);
    Hard0 := Hard0 shr 4;
    Hard1 := ReadCmos($12);
    Hard1 := Hard1 and $0F;
    if Hard0 = $F then
      Hard0 := readCMOS($19)
    Else Hard0 := $FF; { error }
    if Hard1 = $F then
      Hard1 := readCMOS($1A)
    Else Hard1 := $FF;
    ConvenRam := word(256) * readCMOS($16) + readCMOS($15); { value in K }
    ExtendRam := word(256) * readCMOS($18) + readCMOS($17); { value in K }
    CheckSum := GetCmosCheckSum;
  end
  else
    CMOS.Found := false;
end;

begin
  GetCmos;
  Writeln(CMOS.Found);
  Writeln(CMOS.CmosDate);
  Writeln(CMOS.CmosTime);
  Writeln(CMOS.VideoType);
  Writeln(CMOS.Coproc);
  Writeln(CMOS.FloppyA);
  Writeln(CMOS.FloppyB);
  Writeln(CMOS.Hard0);
  Writeln(CMOS.Hard1);
  Writeln(CMOS.ConvenRam);
  Writeln(CMOS.ExtendRam);
  Writeln(CMOS.checkSum);
end.
