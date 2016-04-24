(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0051.PAS
  Description: SoundBlaster version...
  Author: GREG VIGNEAULT
  Date: 08-25-94  09:11
*)

{
 Someone in an Assembly conference posted a routine to determine the
 version of a Sound Blaster card. I've adapted it for use in TP ...
}

PROGRAM sb;               { Determine Sound Blaster version.  TP5+  }
                          { Jul.13.94 Greg Vigneault                }
USES  Dos,                { import GetEnv                           }
      Crt;                { import Delay                            }
VAR Major, Minor : BYTE;  { version has major & minor parts         }

(*-----------------------------------------------------------------*)
{ this procedure returns 0.0 if any error condition...              }
PROCEDURE SBver (VAR Maj, Min : BYTE);
  VAR bev : STRING[32];                       { environment string  }
      j,k : WORD;                             { scratch variables   }
  BEGIN
    Maj := 0;  Min := 0;                      { initialize          }
    bev := GetEnv('BLASTER');                 { look in environment }
    IF bev[0] = #0 THEN EXIT;                 { no sign of Blaster  }
    j := Pos('A',bev);                        { search for i/o port }
    IF j = 0 THEN EXIT ELSE INC(j);           { none?               }
    Val( '$'+Copy(bev,j,3), j, k );           { base port number    }
    IF k <> 0 THEN EXIT;                      { if bad port value   }
    INC(j,$C);                                { command port        }
    Port[j] := $E1;                           { command             }
    DEC(j,2);                                 { input port          }
    Delay(20);                                { wait for response   }
    Maj := Port[j];                           { version major part  }
    Delay(20);                                { wait for response   }
    Min := Port[j];                           { version minor part  }
  END {SBver};

BEGIN

  SBver (Major, Minor);
  WriteLn;
  WriteLn ('Sound Blaster version: ',Major,'.',Minor);
  WriteLn;

END.

