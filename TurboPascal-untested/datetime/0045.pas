{
MD>What would anyone here recommend as being the best way for DOS
  >protected mode to get the current time of day *without* flipping
  >back to real mode to make a standard DOS call?

 If your code is allowed to talk to the real-time clock (RTC) chip,
 here's some example code to access the RTC directly. The functions
 work solely with 24-hr time format (if needed, internally by the RTC,
 they translate between 12/24-hr times and binary/BCD formats)...
}

(*******************************************************************)
PROGRAM RClock;         { Get/Set Time/Date directly from RTC chip  }
                        { June 9, 1994. Greg Vigneault              }
TYPE  Treg = 0..$D;     { range for time/date register addresses    }
      To23 = 0..23;     { range for hours                           }
      To59 = 0..59;     { range for minutes and seconds             }
VAR   Yr, Mth, Day, DoW, Hr, Min, Sec : BYTE;

FUNCTION RTCbusy:BOOLEAN; BEGIN { RTC time/date being updated?... }
    Port[$70] := $A;;  RTCbusy := (Port[$71] AND 128) = 128;
  END {RTCbusy};

FUNCTION ReadReg (Reg:Treg):BYTE; BEGIN { read an RTC register... }
    IF Reg IN [0..9] THEN REPEAT {wait} UNTIL NOT RTCbusy;
    Port[$70] := Reg;;  ReadReg := Port[$71];
  END {ReadReg};

PROCEDURE WriteReg (Reg:Treg; Data:BYTE); { write RTC reg... }
  VAR temp:BYTE; BEGIN
    IF Reg IN [0..9] THEN BEGIN { time/date reg? }
      REPEAT {wait} UNTIL NOT RTCbusy;
      Port[$70] := $B;; temp := Port[$71];; Port[$71] := temp OR $80;
    END{IF};
    Port[$70] := Reg;;  Port[$71] := Data;
    IF Reg IN [0..9] THEN BEGIN
      Port[$70] := $B;;  Port[$71] := temp AND NOT $80;
    END{IF};
  END {WriteReg};

FUNCTION BCD2Bin (BCD:BYTE):BYTE; BEGIN { xlate BCD to binary... }
    BCD2Bin := (BCD AND $0F) + ((BCD SHR 4) * 10);
  END {BCD2Bin};
FUNCTION Bin2BCD (Bin:BYTE):BYTE; BEGIN { xlate binary to BCD... }
    Bin2BCD := (Bin MOD 10) OR BYTE((Bin DIV 10) SHL 4);
  END {Bin2BCD};

PROCEDURE GetTime (VAR Hr,Min,Sec:BYTE);
  VAR temp:BYTE; BEGIN
    Sec := ReadReg(0);;  Min := ReadReg(2);
    Hr := ReadReg(4);;  temp := Hr;;  Hr := Hr AND NOT $80;
    IF (ReadReg($B) AND 4) <> 4 THEN BEGIN { xlate BCD to bin... }
      Sec := BCD2Bin(Sec);; Min := BCD2Bin(Min);; Hr := BCD2Bin(Hr);
    END{IF};
    IF (ReadReg($B) AND 2) <> 2 THEN  { RTC in 12-hr mode?... }
      IF (temp AND 128) = 128  { P.M.? }
        THEN BEGIN IF (Hr < 12) THEN INC(Hr,12); END
        ELSE IF Hr = 12 THEN Hr := 0;
  END {GetTime};

PROCEDURE SetTime (Hr:To23; Min,Sec:To59);
  VAR temp:BYTE; BEGIN
    temp := BYTE(Hr);
    IF (ReadReg($B) AND 2) <> 2 THEN  { RTC in 12-hr mode?... }
      IF (Hr > 12) THEN DEC(Hr,12) ELSE IF Hr = 0 THEN Hr := 12;
    IF (ReadReg($B) AND 4) <> 4 THEN BEGIN { RTC wants BCD format... }
      Hr := Bin2BCD(Hr);; Min := Bin2BCD(Min);; Sec := Bin2BCD(Sec);
    END{IF};
    IF ((ReadReg($B) AND 2)<>2) AND (temp > 11) THEN Hr := Hr OR $80;
    WriteReg(0,Sec);; WriteReg(2,Min);; WriteReg(4,Hr);
  END {SetTime};

PROCEDURE GetDate (VAR Yr,Mth,Day:BYTE); BEGIN
    Day := ReadReg(7);;  Mth := ReadReg(8);;  Yr := ReadReg(9);
    IF (ReadReg($B) AND 4) <> 4 THEN BEGIN { xlate BCD to binay... }
      Day := BCD2Bin(Day);; Mth := BCD2Bin(Mth);; Yr := BCD2Bin(Yr);
    END; {IF}
  END {GetDate};

PROCEDURE SetDate (Yr,Mth,Day:BYTE); BEGIN
    IF (ReadReg($B) AND 4) <> 4 THEN BEGIN { RTC wants BCD format... }
      Day := Bin2BCD(Day);; Mth := Bin2BCD(Mth);; Yr := Bin2BCD(Yr);
    END{IF};
    WriteReg(7,Day);;  WriteReg(8,Mth);;  WriteReg(9,Yr);
  END {SetDate};

BEGIN {RClock}
  GetTime (Hr,Min,Sec);;  GetDate (Yr,Mth,Day);;  WriteLn;
  Write ('Date is ',Mth,'/',Day,'/',Yr,'. ');
  WriteLn ('Time is ',Hr,':',Min:2,':',Sec:2,'.');
  Write ('(BTW, your RTC is in ');
  IF (ReadReg($B) AND 2) <> 2 THEN Write ('12') ELSE Write ('24');
  Write ('-hour mode using ');
  IF (ReadReg($B) AND 4) <> 4 THEN Write('BCD') ELSE Write('binary');
  WriteLn (' format.)');
END {RClock}.
