{
From: GREG VIGNEAULT
Subj: Extended drives (CD-ROM)
---------------------------------------------------------------------------
 In a message with STEVE ROGERS...
SR>PN>  Is it acceptable and safe for the hardware to attempt to write
SR>  >  a test file to a CD-Rom drive? I would do this to find out that
SR>  I tried this a few years ago and just got a write error. Should be
SR>  safe enough.

LD>Although... would you not get the same result as you would on a
  >write-protected disk, or a full disk, or one where the "test"
  >file name is unacceptable?

 Hi Lou,

 I haven't been following this thread, so I don't know what all has
 been said. I don't have a CD-ROM but I'll toss in some of the info
 that I'm aware of...

 Here is TP source that can detect if one or more CD-ROM is present
 in a PC system, and the drive letter of the first CD-ROM. It tries
 to find if the Microsoft CD-ROM Extension (MSCDEX) is installed...
}

(*******************************************************************)
PROGRAM CDROM;                    { compiler: Turbo Pascal 4.0+     }
                                  { Jan.07.94 Greg Vigneault        }

USES  Dos;                        { import  Intr, Registers         }
VAR   DrvName   : CHAR;           { first extended drive (A: to Z:) }
      DrvCount   : WORD;          { number of extended drives       }
      IsMSCDEX,                   { TRUE if MSCDEX is installed     }
      IsCDROM   : BOOLEAN;        { TRUE if extended drive is CDROM }

(*-----------------------------------------------------------------*)
{ Detect if/how-many extended drives (CD-ROMs) are in system ...    }

PROCEDURE CD_ROMdat ( VAR DrvCount  : WORD;     { total ext. drives }
                      VAR FirstDrv  : CHAR;     { first ext. drv    }
                      VAR IsMSCDEX  : BOOLEAN;  { MSCDEX found?     }
                      VAR IsCDROM   : BOOLEAN); { is CD-ROM?        }
  VAR Reg : Registers;            { to access 8086 CPU registers    }
  BEGIN {CD_ROMdat}
                                  { initialize the VARs...          }
      FirstDrv  := #0;            { assume no extension drives      }
      IsMSCDEX  := FALSE;         { assume MSCDEX not installed     }
      IsCDROM   := FALSE;         { assume drive isn't a CD-ROM     }
      Reg.AX := $1500;            { fn: check if CD-ROM is present  }
      Reg.BX := 0;                    { clear BX                    }
      Intr ($2F, Reg);                { invoke MSCDEX               }
      DrvCount := Reg.BX;             { count of extended drives    }
      IF (DrvCount = 0) THEN EXIT;    { abort if no extended drive  }
      FirstDrv := CHR (Reg.CX + 65);  { first drive IN ['A'..'Z']   }
      Reg.AX := $150B;                { fn: CD-ROM drive check      }
      Reg.BX := 0;                    { Reg.CX already has drive #  }
      Intr ($2F, Reg);                { call the CD-ROM services    }
      IF (Reg.BX <> $ADAD) THEN EXIT; { MSCDEX isn't installed      }
      IsMSCDEX := TRUE;               { MSCDEX is installed         }
      IF (Reg.AX = 0) THEN EXIT;      { ext. drive isn't a CD-ROM   }
      IsCDROM := TRUE;                { extended is a CD-ROM        }
  END {CD_ROMdat};                    { END PROCEDURE DC_ROMdat     }

(*-----------------------------------------------------------------*)
BEGIN {PROGRAM CDROM}

  CD_ROMdat (DrvCount, DrvName, IsMSCDEX, IsCDROM);
  WriteLn;

  IF (DrvCount <> 0) THEN BEGIN
    IF IsMSCDEX THEN WriteLn ('MSCDEX is installed');
    Write ('Extended drive(s) detected');
    IF IsCDROM THEN Write (' (CD-ROM)');
    WriteLn (' = ',DrvCount,' at ',DrvName,':');
    END {IF DrvCount}
  ELSE
    WriteLn ('No extended drives (CD-ROMs) detected in system.');

  WriteLn;

END {CDROM}.
(*******************************************************************)

 The familiar Int21h file i/o can be used for reading files on an
 extended drive.  The MSCDEX also offers the following extended
 functions...

      o Get CD-ROM Drive List
      o Get Copyright Filename
      o Get Abstract Filename
      o Get Bibliographic Filename
      o Read Volume Table of Contents
      o Absolute Disk Read
      o Absolute Disk Write
      o Get CD-ROM Extensions Version
      o Get CD-ROM Units
      o Get or Set Volume Descriptor Preference
      o Get Directory Entry
      o Send Device Request

 Greg_
