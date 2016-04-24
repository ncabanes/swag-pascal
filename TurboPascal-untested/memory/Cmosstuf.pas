(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0003.PAS
  Description: CMOSSTUF.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

(*******************************************************************)
 Program SaveCMOS;              { Compiler: Turbo & Quick Pascal    }
{                                                                   }
{ File name: SaveCMOS.PAS       coded: Mar.3.1993, Greg Vigneault   }
{                                                                   }
{ This utility will read the entire contents of the CMOS RAM, and   }
{ save it to a File.  Invoke this Program as...                     }
{                                                                   }
{               SAVECMOS <Filename>                                 }
{                                                                   }
 Uses   Crt;                        { import ReadKey                }
 Const  AddressRTC  = $70;          { RTC register address latch    }
        DataRTC     = $71;          { RTC register data             }
        AStatusRTC  = $0A;          { RTC status register A         }
 Var    tempCMOS,
        RegCMOS     : Byte;                     { RTC register      }
        MapCMOS     : Array [0..63] of Byte;    { RTC CMOS reg map  }
        OutFile     : File;                     { saved CMOS data   }
        ch          : Char;                     { For user input    }
        FResult     : Integer;                  { check File Write  }
(*-----------------------------------------------------------------*)
 Function ReadCMOS( RegCMOS :Byte ) :Byte;
    begin
        RegCMOS := RegCMOS and $3F;     { don't set the NMI bit     }
        if (RegCMOS < AStatusRTC) then  { wait For end of update?   }
            Repeat
                Port[AddressRTC] := AStatusRTC;     { read status   }
            Until (Port[DataRTC] and $80) <> 0;     { busy bit      }
        Port[AddressRTC] := RegCMOS;    { tell RTC which register   }
        ReadCMOS := Port[DataRTC];      { and read in the data Byte }
    end {ReadCMOS};
(*-----------------------------------------------------------------*)
 Procedure HelpExit;
    begin   WriteLn; WriteLn( 'Usage: SAVECMOS <Filename>' );
            WriteLn( CHR(7) );  Halt(1);
    end {HelpExit};
(*-----------------------------------------------------------------*)
 begin
    WriteLn; WriteLn( 'SaveCMOS v0.1  Greg Vigneault' ); WriteLn;
    if (ParamCount <> 1) then HelpExit;
    Assign( OutFile, ParamStr(1) );
    {$i-}  Reset( OutFile, SizeOf(MapCMOS) );  {$i+}
    if (IoResult = 0) then begin
        Repeat
          Write('File ',ParamStr(1),' exists! OverWrite? (Y/N): ',#7);
          ch := UpCase( ReadKey );  WriteLn;
        Until (ch in ['Y','N']);
        if (ch = 'N') then begin WriteLn('ABORTED'); Halt(2); end;
    end;
    ReWrite( OutFile, SizeOf(MapCMOS) );  WriteLn;
    For RegCMOS := 0 to 63 do MapCMOS[RegCMOS] := ReadCMOS(RegCMOS);
    MapCMOS[AStatusRTC] := MapCMOS[AStatusRTC] and $7F; { clear UIP }
    BlockWrite( OutFile, MapCMOS, 1, FResult );
    if (FResult <> 1) then begin
        WriteLn( 'Error writing to ',ParamStr(1),'!',#7 );
        Close( OutFile );   Halt(3);
    end;
    FillChar( MapCMOS, SizeOf(MapCMOS), 0 );
    Reset( OutFile, SizeOf(MapCMOS) );
    BlockRead( OutFile, MapCMOS, 1, FResult );
    if (FResult <> 1) then begin
        WriteLn( 'Error reading from ',ParamStr(1),'!',#7 );
        Close( OutFile );   Halt(4);
    end;
    Close(OutFile);
    For RegCMOS := 10 to 63 do begin { don't include time in verify }
        if (RegCMOS = AStatusRTC) then
            MapCMOS[RegCMOS] := MapCMOS[RegCMOS] and $7F;
        if (MapCMOS[RegCMOS] <> ReadCMOS(RegCMOS)) then begin
            WriteLn('!!! Error: can''t verify File contents !!!');
            WriteLn(#7#7#7#7#7); Halt(5);
        end;
    end;
    WriteLn('! The CMOS RAM has now been saved in ',ParamStr(1),#7);
 end {SaveCMOS}.
(*******************************************************************)

 Greg_

 Mar.03.1993.Toronto.Canada.         greg.vigneault@bville.gts.org
---
 ■ QNet3ß ■ City2City / 1/0/11 / Baudeville BBS / Toronto / 416-283-0114
<<<>>>


Date: 03-04-93 (03:03)              Number: 127 of 160 (Echo)
  To: CHRIS LAUTENBACH              Refer#: NONE
From: GREG VIGNEAULT                  Read: 03-05-93 (17:02)
Subj: TP: LOADCMOS SOURCE CODE      Status: PUBLIC MESSAGE
Conf: C-ProgramMING (368)        Read Type: GENERAL (+)

(*******************************************************************)
 Program LoadCMOS;              { Compiler: Turbo & Quick Pascal    }
{                                                                   }
{ File name: LoadCMOS.PAS       coded: Mar.3.1993, Greg Vigneault   }
{                                                                   }
{               LOADCMOS <Filename>                                 }
{                                                                   }
 Uses   Crt;                        { import ReadKey                }
 Const  AddressRTC      = $70;      { RTC register address latch    }
        DataRTC         = $71;      { RTC register data             }
        AStatusRTC      = $0A;      { RTC status register A         }
        BStatusRTC      = $0B;      { RTC status register B         }
        CStatusRTC      = $0C;      { RTC status register C         }
        DStatusRTC      = $0D;      { RTC status register D         }
        SecondsRTC      = 0;        { seconds       (BCD, 0..59)    }
        MinutesRTC      = 2;        { minutes       (BCD, 0..59)    }
        HoursRTC        = 4;        { hours         (BCD, 0..23)    }
        WeekDayRTC      = 6;        { day of week   (1..7)          }
        DayOfMonthRTC   = 7;        { day of month  (BCD, 1..31)    }
        MonthRTC        = 8;        { month         (BCD, 1..12)    }
        YearRTC         = 9;        { year          (BCD, 0..99)    }
 Var    RegCMOS     : Byte;                     { RTC register      }
        MapCMOS     : Array [0..63] of Byte;    { RTC CMOS reg map  }
        ChkSumCMOS  : Integer;                  { CMOS checksum     }
        InFile      : File;                     { saved CMOS data   }
        ch          : Char;                     { For user input    }
        FResult     : Integer;                  { check File Write  }
(*-----------------------------------------------------------------*)
 Procedure WriteCMOS( RegCMOS, Value :Byte );
    Var temp : Byte;
    begin
        if not (RegCMOS in [0,1,CStatusRTC,DStatusRTC]) then
        begin
            if (RegCMOS < CStatusRTC) then begin
                Port[AddressRTC] := BStatusRTC;
                temp := Port[DataRTC] or $80;       { stop the clock}
                Port[AddressRTC] := BStatusRTC;
                Port[DataRTC] := temp;
            end;
            Port[AddressRTC] := RegCMOS and $3F;    { select reg    }
            Port[DataRTC] := Value;                 { Write data    }
            if (RegCMOS < CStatusRTC) then begin
                Port[AddressRTC] := BStatusRTC;
                temp := Port[DataRTC] and not $80;  { enable clock  }
                Port[AddressRTC] := BStatusRTC;
                Port[DataRTC] := temp;
            end;
        end;
    end {WriteCMOS};
(*-----------------------------------------------------------------*)
 Procedure HelpExit;
    begin   WriteLn; WriteLn( 'Usage: LOADCMOS <Filename>' );
            WriteLn( CHR(7) );  Halt(1);
    end {HelpExit};
(*-----------------------------------------------------------------*)
 begin
    WriteLn; WriteLn( 'LoadCMOS v0.1  Greg Vigneault' ); WriteLn;
    if (ParamCount <> 1) then HelpExit;
    Assign( InFile, ParamStr(1) );
    {$i-}  Reset( InFile, SizeOf(MapCMOS) );  {$i+}
    if (IoResult <> 0) then begin
          Write('Can''t find ',ParamStr(1),'!',#7);
          Halt(1);
    end;
    FillChar( MapCMOS, SizeOf(MapCMOS), 0 );        { initialize    }
    BlockRead( InFile, MapCMOS, 1, FResult );       { saved CMOS    }
    Close(InFile);
    if (FResult <> 1) then begin
        WriteLn('! Error reading File',#7);
        Halt(2);
    end;
    MapCMOS[AStatusRTC] := MapCMOS[AStatusRTC] and $7F;
    ChkSumCMOS := 0;                                { do checksum   }
    For RegCMOS := $10 to $2D
        do ChkSumCMOS := ChkSumCMOS + Integer( MapCMOS[RegCMOS] );
    if (Hi(ChkSumCMOS) <> MapCMOS[$2E])
    or (Lo(ChkSumCMOS) <> MapCMOS[$2F]) then begin
        WriteLn('!!! CheckSum error in ',ParamStr(1) );
        WriteLn(#7#7#7#7#7);  Halt(2);
    end;
    For RegCMOS := AStatusRTC to 63
        do WriteCMOS( RegCMOS, MapCMOS[RegCMOS] );
    WriteLn('! The CMOS RAM has been restored from ',ParamStr(1),#7);
 end {LoadCMOS}.
(*******************************************************************)

