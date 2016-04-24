(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0078.PAS
  Description: Misc Utilities
  Author: GREG ESTABROOKS
  Date: 01-27-94  13:34
*)

UNIT Utils;                {  Misc Utilities Last Updates  Nov 01/93       }
                        {  Copyright (C) 1992,93 Greg Estabrooks        }

INTERFACE
{ *********************************************************************}
USES
    CRT,KeyIO,DOS;

CONST
      FpuType :ARRAY[0..3] OF STRING[10] =('None','8087','80287','80387');
      CPU     :ARRAY[0..3] Of STRING[13] =('8088/V20','80286',
                                          '80386/80486','80486');
CONST                                   {  Define COM port Addresses    }
     ComPort :ARRAY[1..4] Of WORD = ($3F8,$2F8,$3E8,$2E8);

CONST
     Warm :WORD = 0000;         { Predefined value for warm boot.       }
     Cold :WORD = 0001;         { Predefined value for cold boot.       }

VAR
    BiosDate  :ARRAY[0..7] of CHAR Absolute $F000:$FFF5;
    EquipFlag :WORD Absolute $0000:$0410;
    CompID    :BYTE Absolute $F000:$FFFE;

FUNCTION CoProcessorExist :BOOLEAN;
FUNCTION NumPrinters :WORD;
FUNCTION GameIOAttached :BOOLEAN;
FUNCTION NumSerialPorts :INTEGER;
FUNCTION NumDisketteDrives :INTEGER;
FUNCTION InitialVideoMode :INTEGER;
PROCEDURE Noise(Pitch, Duration :INTEGER);
FUNCTION  Time :STRING;
FUNCTION  WeekDate :STRING;
FUNCTION DayOfWeek( Month, Day, Year :WORD ) :BYTE; {  Returns 1-7 }
FUNCTION PrinterOK :BOOLEAN;
FUNCTION AdlibCard :BOOLEAN;
FUNCTION TrueDosVer :WORD;
PROCEDURE SetPrtScr( On_OFF :BOOLEAN );
FUNCTION CpuType :WORD;
PROCEDURE IdePause;
FUNCTION RingDetect( CPort :WORD) :BOOLEAN;
function DetectOs2: Boolean;
FUNCTION HiWord( Long :LONGINT ) :WORD;
                      { Routine to return high word of a LongInt.       }
FUNCTION LoWord( Long :LONGINT ) :WORD;
                      { Routine to return low word of a LongInt.        }
FUNCTION Running4DOS : Boolean;
PROCEDURE Reboot( BootCode :WORD );
                      { Routine to reboot system according to boot code.}


FUNCTION GetChar( X,Y :WORD; VAR Attrib:BYTE ) :CHAR;

IMPLEMENTATION
{ *********************************************************************}
FUNCTION CoProcessorExist :BOOLEAN;
BEGIN
  CoProcessorExist := (EquipFlag And 2) = 2;
END;

FUNCTION NumPrinters :WORD;
BEGIN
  NumPrinters := EquipFlag Shr 14;
END;

FUNCTION GameIOAttached :BOOLEAN;
BEGIN
  GameIOAttached := (EquipFlag And $1000) = 1;
END;

FUNCTION NumSerialPorts :INTEGER;
BEGIN
  NumSerialPorts := (EquipFlag Shr 9) And $07;
END;

FUNCTION NumDisketteDrives :INTEGER;
BEGIN
  NumDisketteDrives := ((EquipFlag And 1) * (1+(EquipFlag Shr 6) And $03));
END;

FUNCTION InitialVideoMode :INTEGER;
BEGIN
  InitialVideoMode := (EquipFlag Shr 4) And $03;
END;

PROCEDURE Noise( Pitch, Duration :INTEGER );
BEGIN
  Sound(Pitch);
  Delay(Duration);
  NoSound;
END;

Function Time : String;
VAR
  Hour,Min,Sec :STRING[2];
  H,M,S,T      :WORD;

BEGIN
    GetTime(H,M,S,T);
    Str(H,Hour);
    Str(M,Min);
    Str(S,Sec);
    If S < 10 Then
      Sec := '0' + Sec;
    If M < 10 Then
        Min := '0' + Min;
    If H > 12 Then
    BEGIN
       Str(H - 12, Hour);
       IF Length(Hour) = 1 Then Hour := ' ' + Hour;
          Time := Hour + ':' + Min + ':' + Sec+' pm'
    END
    ELSE
      BEGIN
       If H = 0 Then
         Time :=   '12:' + Min + ':' + Sec + ' am'
       ELSE
         Time := Hour +':'+Min+':'+Sec+' am';
      END;
    If H = 12 Then
       Time := Hour + ':' + Min + ':' + Sec + ' pm';
END;

FUNCTION WeekDate :STRING;
TYPE
  WeekDays = Array[0..6]  Of STRING[9];
  Months   = Array[1..12] Of STRING[9];

CONST
    DayNames   : WeekDays  = ('Sunday','Monday','Tuesday','Wednesday',
                              'Thursday','Friday','Saturday');
    MonthNames : Months    = ('January','February','March','April','May',
                              'June','July','August','September',
                              'October','November','December');
VAR
         Y,
         M,
         D,
         DayOfWeek :WORD;
         Year      :STRING;
         Day       :STRING;

BEGIN
    GetDate(Y,M,D,DayofWeek);
    Str(Y,Year);
    Str(D,Day);
    WeekDate := DayNames[DayOfWeek] + ' ' + MonthNames[M] + ' ' + Day+ ', '
     + Year;
END;

FUNCTION DayOfWeek( Month, Day, Year :WORD ) :BYTE;
VAR ivar1, ivar2    : Integer;
BEGIN
  IF (Day > 0) AND (Day < 32) AND (Month > 0) AND (Month < 13)
    THEN
        BEGIN
          ivar1 := ( Year MOD 100 );
          ivar2 := Day + ivar1 + ivar1 DIV 4;
          CASE Month OF
              4, 7    : ivar1 := 0;
              1, 10   : ivar1 := 1;
              5       : ivar1 := 2;
              8       : ivar1 := 3;
              2,3,11  : ivar1 := 4;
              6       : ivar1 := 5;
              9,12    : ivar1 := 6;
          END; {case}
          ivar2 := ( ivar1 + ivar2 ) MOD 7;
          IF ( ivar2 = 0 ) THEN ivar2 := 7;
          END {IF}
    ELSE
        ivar2 := 0;
    DayOfWeek := BYTE( ivar2 );
END;

FUNCTION PrinterOK :BOOLEAN;
                {  Determine whether printer is on or off line         }
BEGIN
  If (Port[$379]) And (16) <> 16 Then
     PrinterOK := False
  Else
     PrinterOK := True;
END;

FUNCTION AdlibCard :BOOLEAN;
        {  Routine to determine if a Adlib compatible card is installed }
VAR
        Val1,Val2 :BYTE;
BEGIN
  Port[$388] := 4;                {  Write 60h to register 4              }
  Delay(3);                        {  Which resets timer 1 and 2           }
  Port[$389] := $60;
  Delay(23);
  Port[$388] := 4;                {  Write 80h to register 4              }
  Delay(3);                     {  Which enables interrupts             }
  Port[$389] := $80;
  Delay(23);
  Val1 := Port[$388];                {  Read status byte                     }
  Port[$388] := 2;                {  Write ffh to register 2              }
  Delay(3);                     {  Which is also Timer 1                }
  Port[$389] := $FF;
  Delay(23);
  Port[$388] := 4;                {  Write 21h to register 4              }
  Delay(3);                        {  Which will Start Timer 1             }
  Port[$389] := $21;
  Delay(85);                        {  wait 85 microseconds                 }
  Val2 := Port[$388];                {  read status byte                     }
  Port[$388] := 4;                {  Repeat the first to steps            }
  Delay(3);                        {  Which will reset both Timers         }
  Port[$389] := $60;
  Delay(23);
  Port[$388] := 4;
  Delay(3);
  Port[$389] := $80;                        {  Now test the status bytes saved }
  If ((Val1 And $E0) = 0) And ((Val2 And $E0) = $C0) Then
     AdlibCard := True                        {  Card was found               }
  Else
     AdlibCard := False;                {  No Card Installed            }
END;

FUNCTION TrueDosVer :WORD; ASSEMBLER;
                {  Returns true Dos Version. Not affected by Setver     }
ASM
  Mov AX,$3306                  {  get true dos ver                     }
  Int $21                        {  Call Dos                             }
  Mov AX,BX                     {  Return proper results                }

        {  DL = Revision Number                                         }
        {  DH = V Flags, 8h = Dos in ROM,  10h Dos in HMA               }
END;{TrueDosVer}

PROCEDURE SetPrtScr( On_OFF :BOOLEAN );
                {  Routine to Enable or disable Print screen key   }
BEGIN
  If On_OFF Then                {  Turn it on                      }
    Mem[$0050:0000] := 0
  Else
    Mem[$0050:0000] := 1;        {  Turn it off                     }
END;

FUNCTION CpuType :WORD; ASSEMBLER;
                 {  Returns a value depending on the type of CPU        }
                 {          0 = 8088/V20 or compatible                  }
                 {          1 = 80286    2 = 80386/80486+               }
ASM
  Xor DX,DX                             {  Clear DX                     }
  Push DX
  PopF                                  {  Clear Flags                  }
  PushF
  Pop AX                                {  Load Cleared Flags           }
  And AX,$0F000                         {  Check hi bits for F0h        }
  Cmp AX,$0F000
  Je @Quit                              {  Quit if 8088                 }
  Inc DX
  Mov AX,$0F000                         {  Now Check For 80286          }
  Push AX
  PopF
  PushF
  Pop AX
  And AX,$0F000                         {  If The top 4 bits aren't set }
  Jz @Quit                              {  Its a 80286+                 }
  Inc DX                                {  Else its a 80386 or better   }
@Quit:
  Mov AX,DX                             {  Return Result in AX          }
END;{CpuType}

procedure idepause;
begin
  gotoxy(1,25);
  write('Press any key to return to IDE');
  pausekey;
end;

FUNCTION RingDetect( CPort :WORD) :BOOLEAN;
                             {  Routine to detect whether or not the    }
                             {  phone is ringing by checking the comport}
BEGIN
  RingDetect := ODD( PORT[CPort] SHR 6 );
END;

function DetectOs2: Boolean;
begin
  { if you use Tpro, then write Hi(TpDos.DosVersion) }
  DetectOs2 := (Lo(Dos.DosVersion) > 10);
end;

FUNCTION HiWord( Long :LONGINT ) :WORD; ASSEMBLER;
                      { Routine to return high word of a LongInt.       }
ASM
  Mov AX,Long.WORD[2]              { Move High word into AX.            }
END;

FUNCTION LoWord( Long :LONGINT ) :WORD; ASSEMBLER;
                      { Routine to return low word of a LongInt.        }
ASM
  Mov AX,Long.WORD[0]              { Move low word into AX.             }
END;

FUNCTION Running4DOS : Boolean;
VAR Regs : Registers;
begin
  With Regs do
     begin
       ax := $D44D;
       bx := $00;
     end;
  Intr ($2F, Regs);
  if Regs.ax = $44DD then Running4DOS := TRUE
     else Running4DOS := FALSE
end;

PROCEDURE Reboot( BootCode :WORD );
                      { Routine to reboot system according to boot code.}
                      { Also flushes all DOS buffers.                   }
                      { NOTE: Doesn't update directory entries.         }
BEGIN
  Inline(
          $BE/$0D/              { MOV   AH,0Dh                          }
          $CD/$21/              { INT   21h                             }
          $FB/                  { STI                                   }
          $B8/Bootcode/         { MOV   AX,BootCode                     }
          $8E/$D8/              { MOV   DS,AX                           }
          $B8/$34/$12/          { MOV   AX,1234h                        }
          $A3/$72/$04/          { MOV   [0472h],AX                      }
          $EA/$00/$00/$FF/$FF); { JMP   FFFFh:0000h                     }
END;


FUNCTION GetChar( X,Y :WORD; VAR Attrib:BYTE ) :CHAR;
                      { Retrieves the character and attribute of        }
                      { coordinates X,Y.                                }
VAR
   Ofs :WORD;
BEGIN
  Ofs := ((Y-1) * 160) + ((X SHL 1) - 1);
  Attrib := MEM[$B800:Ofs];
  GetChar := CHR( MEM[$B800:Ofs-1] );
END;


BEGIN
END.
