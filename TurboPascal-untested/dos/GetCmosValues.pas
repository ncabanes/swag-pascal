(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0036.PAS
  Description: Get CMOS Values
  Author: RANDALL WOODMAN
  Date: 11-21-93  09:28
*)

{
From: RANDALL WOODMAN
Subj: CMOS Info

  Does anyone know how to get the hard drive type(s) from CMOS ?
}

USES DOS,CRT;

TYPE
  String80 = STRING [80];  { some general purpose string types }
  String40 = STRING [40];
  String30 = STRING [30];
  String20 = STRING [20];
  String12 = STRING [12];
  String10 = STRING [10];
  String5  = STRING [5];

  CMOSRec = RECORD
    Found     : BOOLEAN;  { was a CMOS found to exist }
    CmosDate  : String30; { the date found in CMOS }
    CmosTime  : String30; { the time found in CMOS }
    VideoType : String10; { Type of video found in CMOS }
    Coproc    : BOOLEAN;  { does CMOS report a math coprocessor }
    FloppyA   : String12; { type of floppy drive for A }
    FloppyB   : String12; { Type of floppy drive for B }
    Hard0     : BYTE;     { Type of hard drive for drive 0 }
    Hard1     : BYTE;     { Type of hard drive for Drive 1 }
    ConvenRam : WORD;     { amount of conventional ram indicated }
    ExtendRam : WORD;     { amount of extended Ram indicated }
    checkSum  : BOOLEAN;  { Did checksum pass }
  END; { CMOS Rec }

CONST
  { values of constants for CMOS }
  DayName : ARRAY [0..7] OF STRING [9] = ('Sunday', 'Monday', 'Tuesday',
                                          'Wednesday', 'Thursday', 'Friday',
                                          'Saturday', 'Sunday');
  MonthName : ARRAY [0..12] OF STRING [9] = ('???', 'January', 'February', 'March',
                                          'April', 'May', 'June', 'July',
                                          'August', 'September', 'October',
                                          'November', 'December');
  ScreenName : ARRAY [0..3] OF STRING [10] = ('EGA/VGA', 'CGA 40col',
                                           'CGA 80col', 'Monochrome');
  FloppyName : ARRAY [0..5] OF STRING [11] = ('none', '5.25" 360K',
                                           '5.25" 1.2M', '3.5"  720K',
                                           '3.5"  1.44M', '3.5"  2.88M');
  CMOSport : BYTE = $70; { port to access the CMOS }

  Country  : BYTE = 0;  { used for country date format }

{===========================================================================}


VAR
  Regs             : REGISTERS; { General purpose variable to access
                                  registers }
  CMOS             : CMOSRec;   { variable to hold CMOS data }

FUNCTION nocarry : BOOLEAN;
{ returns the status of the carry flag }
BEGIN
  nocarry := regs.flags AND fcarry = $0000
END; {nocarry}

{---------------------------------------------------------------------------}

FUNCTION ByteToWord (ByteA, ByteB : BYTE) : WORD;
BEGIN
   ByteToWord := WORD (ByteB) SHL 8 + ByteA
END; {cbw}

{---------------------------------------------------------------------------}

FUNCTION BitIsSet (CheckWord : WORD; AndValue : WORD) : BOOLEAN;
{ returns true if the bit(s) indicated in AndValue are set in CheckByte }
BEGIN
  BitIsSet := CheckWord AND AndValue = AndValue;
END;

{---------------------------------------------------------------------------}

FUNCTION ReadCMOS (ADDR : BYTE) : BYTE;
{ read a value from the CMOS }
BEGIN
  IF CMOSport = $70 THEN
  BEGIN
    INLINE ($FA);
    Port [CMOSport] := ADDR;
    readCMOS := Port [CMOSport + 1];
    INLINE ($FB)
  END
END; {readCMOS}

{---------------------------------------------------------------------------}

FUNCTION addzero (b : BYTE) : string5;
VAR
  c2 : STRING [2];
BEGIN
  STR (b : 0, c2);
  IF b < 10 THEN
    c2 := '0' + c2;
  addzero := c2
END; {addzero}

{---------------------------------------------------------------------------}

FUNCTION ChangeBCD (b : BYTE) : BYTE;
{ change a BCD into a byte structure }
BEGIN
  ChangeBCD := (b AND $0F) + ( (b SHR 4) * 10)
END; {ChangeBCD}

{---------------------------------------------------------------------------}

FUNCTION Long2Str (Long : LONGINT) : STRING;
VAR Stg : STRING;
BEGIN
  STR (Long, Stg);
  Long2Str := Stg;
END;

FUNCTION  HexL (argument : LONGINT) : STRING; Assembler;
  asm
     cld
     les    di, @result
     mov    al, 8                   { store string length }
     stosb
     mov    cl, 4                  { shift count }

     mov    dx, WORD PTR Argument + 2 { hi word }
     call   @1                     { convert dh to ascii }
     mov    dh, dl                 { lo byte of hi word }
     call   @1                     { convert dh to ascii }
     mov    dx, WORD PTR Argument   { lo word }
     call   @1                     { convert dh to ascii }
     mov    dh, dl                 { lo byte of lo word }
     call   @1                     { convert dh to ascii }
     jmp    @2

   @1 :
     mov    al, dh                 { 1 byte }
     AND    al, 0fh                { low nybble }
     add    al, 90h
     daa
     adc    al, 40h
     daa
     mov    ah, al                 { store }
     mov    al, dh                 { 1 byte }
     SHR    al, cl                 { get high nybble }
     add    al, 90h
     daa
     adc    al, 40h
     daa
     stosw                         { move characters to result }
     retn                          { return near }
   @2 :
  END;

FUNCTION GetCMOSDate : String30;
{ gets the date found in the CMOS and returns it in string format }
VAR
  Date,
  Century,
  Year,
  Month : BYTE;
  WorkStr : String30;
BEGIN
  WorkStr := '';
  date    := ChangeBCD (readCMOS (7) );
  century := ChangeBCD (readCMOS ($32) );
  year    := ChangeBCD (readCMOS (9) );
  month   := ChangeBCD (readCMOS (8) );
  CASE country OF
    0, 3..255 :
      WorkStr := WorkStr + Monthname [month] + ' ' + Long2Str (date) + ', ' + Long2Str (century) + addzero (year);
    1 :
      WorkStr := WorkStr + Long2Str (date) + ', ' + Monthname [month] + ' ' + Long2Str (century) + addzero (Year);
    2 :
      WorkStr := WorkStr + Long2Str (century) + addzero (Year) + ', ' + Monthname [month] + ' ' + Long2Str (date);
  END; {case}
  GetCMosDate := workStr;
END; { GetCMOSDate }

{---------------------------------------------------------------------------}

FUNCTION GetCmosTime : String30;
{ returns the time as found in the CMOS }
VAR
  CH : CHAR;
  Hour,
  Min,
  Sec  : BYTE;
  WorkStr : String30;
  IsPM    : BOOLEAN;
BEGIN
  workStr := '';
  hour := ChangeBCD (readCMOS (4) );
  min := ChangeBCD (readCMOS (2) );
  sec := ChangeBCD (readCMOS (0) );
  IsPm := FALSE;
  CASE hour OF
        0 : hour := 12;
        1..11 : hour := hour;
        12 : IsPM := TRUE;
        13..23 : BEGIN
                  IsPM := TRUE;
                  hour := hour - 12
                END;
  END; {case}
  WorkStr := WorkStr + AddZero (hour) + ':' + addzero (min) + ':' + addzero (sec);
  IF IsPM THEN
    workStr := WorkStr + ' PM'
  ELSE
    WorkStr := WorkStr + ' AM';
  GetCMOSTime := WorkStr;
END; { GetCmosTime }

{---------------------------------------------------------------------------}

FUNCTION GetCmosCheckSum : BOOLEAN;
{ performs checksum on CMOS and returns true if ok }
VAR
  CheckSum1,
  CheckSum2 : WORD;
  Count     : BYTE;
BEGIN
  checksum1 := 0;
  FOR count := $10 TO $2D DO
    INC (checksum1, readCMOS (count) );
  checksum2 := (WORD (256) * readCMOS ($2E) ) + readCMOS ($2F);
  IF checksum1 = checksum2 THEN
    GetCmosCheckSum := TRUE
  ELSE
    GetCmosCheckSum := FALSE;
END; { GetCmosCheckSum }

{---------------------------------------------------------------------------}

PROCEDURE GetCMos;
{ gets the cmos record if it exist }
VAR
  Floppy : BYTE;
BEGIN
  FILLCHAR (CMOS, SIZEOF (CMos), 0);
  regs.AH := $C0;
  INTR ($15, regs);
  IF nocarry OR (Mem [$F000 : $FFFE] <= $FC) THEN
  WITH CMOS DO
  BEGIN
    Found := TRUE;
    CMOSDate := GetCMOSDate;
    CMOSTime := GetCmosTime;
    VideoType := ScreenName [ (readCMOS ($14) SHR 4) AND 3];
    CoProc := BitIsSet (readCMOS ($14), 1);
    Floppy := readCMOS ($10);
    IF (Floppy SHR 4) < 5 THEN
      FloppyA := FloppyName [floppy SHR 4]
    ELSE
      FloppyA := 'Unknown ' + HexL (floppy SHR 4);
    IF (floppy AND $0F) < 5 THEN
      FloppyB := FloppyName [floppy AND $0F]
    ELSE
      FloppyB := 'Unknown ' + HexL (floppy AND $0F);

    Hard0 := readCMOS ($12);
    Hard0 := Hard0 SHR 4;
    Hard1 := ReadCmos ($12);
    Hard1 := Hard1 AND $0F;
    IF Hard0 = $F THEN
      Hard0 := readCMOS ($19)
    ELSE Hard0 := $FF; { error }
    IF Hard1 = $F THEN
      Hard1 := readCMOS ($1A)
    ELSE Hard1 := $FF;
    ConvenRam := WORD (256) * readCMOS ($16) + readCMOS ($15); { value in K }
    ExtendRam := WORD (256) * readCMOS ($18) + readCMOS ($17); { value in K }
    CheckSum := GetCmosCheckSum;
  END
  ELSE
    CMOS.Found := FALSE;
END;

BEGIN
ClrScr;
GetCMos;
With CMOS DO
     BEGIN
     WriteLn('Date     : ',CMosDate);
     WriteLn('Time     : ',CMosTime);
     WriteLn('Video    : ',VideoType);
     WriteLn('Math     : ',CoProc);
     WriteLn('FloppyA  : ',FloppyA);
     WriteLn('FloppyB  : ',FloppyB);
     WriteLn('Hard #1  : ',Hard0);
     WriteLn('Hard #2  : ',Hard1);
     WriteLn('Base Ram : ',ConvenRam,'K');
     WriteLn('Ext Ram  : ',ExtendRam,'K');
     ReadKey;
     END;
END.
