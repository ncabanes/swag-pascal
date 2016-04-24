(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0005.PAS
  Description: Get Drive ID
  Author: GREG VIGNEAULT
  Date: 05-28-93  13:38
*)

{
 Below is TP code to do drive-Type identification.  I leave it as a
 research exercise For you to create code to differentiate between
 a RAM drive and fixed disk, if that's needed.

}
(********************************************************************)
 Program DrvCount;                      { coded by Greg Vigneault   }
 Uses   Crt,Dos;                        { For MsDos Function        }
 Var    Drives      :Byte;              { count of logical drives   }
        Reg         :Registers;         { to access CPU Registers   }
        ThisDrive   :Byte;              { loop count                }
        DriveType   :String[16];        { Type of drive found       }
        DataBuffer  :Array [0..127] of Byte;   { buffer For Dos i/o }
 begin
    ClrScr;                             { remove screen clutter     }
    Reg.AH := $19;                      { get current disk code     }
    MsDos(Reg);                         { via Dos                   }
    Reg.DL := Reg.AL;                   { returned drive code       }
    Reg.AH := $E;                       { select disk               }
    MsDos(Reg);                         { via Dos                   }
    Drives := Reg.AL;                   { number of logical drives  }

    WriteLn('Number of logical drives: ', Drives );

    Intr($11,Reg);                      { get system equipment flag }
    if ( (Reg.AX and 1) <> 0 )          { any floppies installed?   }
        then WriteLn('(physical floppy drives: ',
                (Reg.AX SHR 6) and 3, ')' );    { get bits 6&7      }

    For ThisDrive := 1 to Drives do begin   { scan all drives       }
        Reg.AX := $440D;                { using generic I/O control }
        Reg.CX := $860;                 { to get drive parameters   }
        Reg.BL := ThisDrive;            { For this drive            }
        Reg.DX := ofs(DataBuffer);      { Pointer to scratch buffer }
        Reg.DS := Seg(DataBuffer);      {  in is DS:DX              }
        MsDos(Reg);                     { thank you, Dos            }
        Case ( DataBuffer[1] ) of       { which Type it is...       }
            0   : DriveType := '360 KB 5.25" FDD';
            1   : DriveType := '1.2 MB 5.25" FDD';
            2   : DriveType := '720 KB 3.5" FDD';
            3   : DriveType := 'SD 8"'; { a relic from CP/M roots   }
            4   : DriveType := 'DD 8"'; {   ditto                   }
            5   : DriveType := 'Fixed/RAM disk';    { HDD or RAM    }
            6   : DriveType := 'Tape drive';    { a good investment }
            7   : DriveType := '1.44 MB 3.5" FDD'  { or "other" drv }
            else  DriveType := '???';   { anything else             }
            end; { Case }
        WriteLn(' - ', CHR(ThisDrive+64),': (', DriveType, ')' );
        { further code could ID between RAM drive & HDD             }
        end; { For }
 end. { Program }
(********************************************************************)

