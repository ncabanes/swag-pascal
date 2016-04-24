(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0068.PAS
  Description: Network Drives
  Author: GREG VIGNEAULT
  Date: 02-03-94  16:16
*)

{
  >Hi, I'm interested in trying to identify what type of drive a
  >logical drive is (specifically, whether or not a hard drive is
  >a network drive; I want the installation program I'm writing
  >to prevent the user from installing to a network drive).

 Hi Jim,

 I don't have access to a network, but the following code will
 consistently assure me that my drives are all local ;) ... }

(************************* NETDRV.PAS ******************************)
PROGRAM NetDrive;                     { compiler: Turbo Pascal 4.0+ }
                                      { Jan.17.94 Greg Vigneault    }

USES  Dos;                            { import MsDos, Registers     }

CONST Beep          = CHR(7);         { ASCII bell-tone             }

VAR   Reg           : Registers;      { to use CPU registers        }
      DosErrorCode  : WORD;           { MsDos function error code   }
      DriveID       : String[1];      { for PC/AT drive 'A'..'Z'    }
      DriveIsRemote : BOOLEAN;        { TRUE or FALSE, of course    }

(*-----------------------------------------------------------------*)
(* Return PC/MS-DOS version, times 100 (eg. 310 = version 3.1) ... *)

FUNCTION DosVersion : WORD;
  BEGIN
    Reg.AX := $3000;                  { Dos fn: get Dos version   }
    MsDos (Reg);                      { call the Dos services     }
    DosVersion := WORD(Reg.AL) * 100 + WORD(Reg.AH);  { convert   }
  END {DosVersion};

(*-----------------------------------------------------------------*)
(*  Return TRUE if Drive is redirected to a network server...      *)

FUNCTION NetworkDrive (Drive:CHAR):BOOLEAN;
  BEGIN
    Drive := UpCase (Drive);            { Drive _must_ be 'A'..'Z'  }
    IF (Drive IN ['A'..'Z']) THEN BEGIN { make sure of 'A'..'Z'     }
      Reg.BL := ORD(Drive) - 64;      { 1 = A:, 2 = B:, 3 = C: etc. }
      Reg.AX := $4409;                { Dos fn: check if dev remote }
      MsDos (Reg);                    { call Dos' services          }
      IF ODD(Reg.FLAGS) THEN          { Dos reports function error? }
        DosErrorCode := Reg.AX        { yes: return Dos' error code }
      ELSE BEGIN                      {   else ...                  }
        DosErrorCode := 0;            { 0 = no error was detected   }
        IF ODD(Reg.DX SHR 12) THEN    { is Drive remote?            }
          NetworkDrive := TRUE        { yes: return TRUE            }
        ELSE
          NetworkDrive := FALSE;      { no: return FALSE            }
        {END IF ODD(Reg.DX...}
      END; {IF ODD(Reg.FLAGS)}
    END; {IF Drive}
  END {NetworkDrive};

(*-----------------------------------------------------------------*)
BEGIN {NetDrive}

  WriteLn;

  IF (ParamCount <> 1) THEN BEGIN                 { user input?     }
    WriteLn ('Usage: NETDRV <DriveLetter>',Beep); { no: offer hint  }
    HALT (1);                                     { abort program   }
  END;

  IF (DosVersion < 310) THEN BEGIN                { check DOS ver   }
    WriteLn ('DOS version 3.1+ is needed.',Beep); { version too low }
    HALT (2);                                     { abort program   }
  END;

  DriveID := ParamStr(1);                       { get user's input  }
  DriveID[1] := UpCase (DriveID[1]);            { to uppercase      }
  DriveIsRemote := NetWorkDrive (DriveID[1]);   { check per netwrok }

  { _ALWAYS_ check if the function call failed....................  }

  IF (DosErrorCode <> 0) THEN BEGIN             { any DOS errors?   }
    WriteLn ('!DOS error #',DosErrorCode,Beep); { DOS fn failed     }
    HALT (3);                                   { abort program     }
  END;

  Write ('Drive ',DriveID[1],': is ');          { inform user of    }
  IF NOT DriveIsRemote THEN Write ('NOT ');     {  the drive status }
  WriteLn ('redirected to a network.');

END {NetDrive}.
(*******************************************************************)

