(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0083.PAS
  Description: CD-Rom player routines
  Author: GREG ESTABROOKS
  Date: 09-04-95  10:44
*)

{
 TK> Monday March 13 1995 21:16, Ville Lumme wrote to All:
 SC>
 > Has anyone got some kind of specs how to interrupt MSCDEX to play audio
 > CDs? I have spent much time for searching them, and I'm getting hopeless...

 TK> Read my answer from Netmail.

 SC> Can you do a post in echomail. Others might want to read it
 SC> too.

Okey sounds like you want a unit (or a routine) for playing audio cds. Well, I
have one, here the source:
}

{$X+,O+,F+}
UNIT CDRom;              { CD Rom Interfacing routines.                 }
                         { Last Updated July 16/94, Greg Estabrooks.    }
INTERFACE
{***********************************************************************}
USES DOS;
CONST
   CDRead  = $4402;
   CDWrite = $4403;

             { Define some CD IOCTL OutPut function codes.              }
   EjectDisk   = 0;
   LockUnlock  = 1;
   ResetCD     = 2;
   AudioCtrl   = 3;
   WriteCtrlStr= 4;
   CloseTray   = 5;

TYPE
CDPosType = RECORD
   CtlAdr : BYTE;  { Control and ADR byte.                 }
   Track  : BYTE;  { Current Track #.                      }
   Indx   : BYTE;  { Point or Index Byte.                  }
   Min    : BYTE;  { Minute. \                             }
   Sec    : BYTE;  { Second.  > Running time within track. }
   Frame  : BYTE;  { Frame.  /                             }
   Zero   : BYTE;  { Should be a 0.                        }
   DMin   : BYTE;  { Minute. \                             }
   DSec   : BYTE;  { Second.  > Running time on disk.      }
   DFrame : BYTE;  { Frame.  /                             }
END;

CDInfoRecord = RECORD
   Status : WORD; { Holds the status of last operation. }
   NumCD  : WORD; { Number of CD Drives available.      }
   DrvChar: CHAR; { First CD drive in CHAR format.      }
   DrvNo  : BYTE; { BYTE value of first drive. 0 = A,ETC}
   DVParam: LONGINT;{ Device parameters.                }
   VolInf : ARRAY[1..8] OF BYTE; { Holds Audio Channel inf.}
   LoTrack: BYTE; { Lowest Audio track #.               }
   HiTrack: BYTE; { Highest Audio Track #.              }
   LdAdr  : LONGINT;{ Address of Lead track in HSG.     }
END;

DriveList = RECORD
   UnitCode : BYTE;
   DOffset,DSegment : WORD;
END;

VAR
   CDDevice :TEXT;              { File Handle for the CD Driver.        }
   CDStatus :WORD;              { Status for last CD operation.         }
   CDControl:ARRAY[0..200] OF BYTE;
   CDHandle :WORD;
   CDInf    :CDInfoRecord;
   PosInf   :CDPosType;

FUNCTION CDGetHandle : WORD;
                         { Routine to get handle for referencing the CD }
                         { Device driver.                               }
PROCEDURE CDCloseHandle;
                         { Routine to close Handle referencing the CD   }
                         { Driver.                                      }
FUNCTION CDIoctl(IntFunc, Len : WORD; VAR CtlBlk) : BOOLEAN;
                         { Routine to call the CD IOCTL.                }
PROCEDURE DriverRequest(Drive : BYTE; VAR CtlBlk);
                         { Routine to make request of MSCDEX.           }
FUNCTION CDEject : BOOLEAN;
                         { Routine to Eject the CD tray.                }
FUNCTION CDCloseTray : BOOLEAN;
                         { Routine to close the CD tray.                }
FUNCTION CDReset : BOOLEAN;
                         { Routine to reset the CD Drive.               }
FUNCTION CDGetVol(VAR InfRec : CDInfoRecord) : BOOLEAN;
                         { Routine to get current audio volume output.  }
FUNCTION CDStop : BOOLEAN;
                         { Routine to stop the playing and Audio CD.    }
PROCEDURE CDInitInfo;
                         { Routine to Intilialize CD Info.              }
FUNCTION CDResumePlay : BOOLEAN;
                         { Routine to Resume playing a previously stopped}
                         { audio track.                                  }
FUNCTION CDGetPos(VAR PosInf : CDPosType ) : BOOLEAN;
                         { Routine to retrieve current position being   }
                         { played.                                      }
FUNCTION Red2HSG(Inf : LONGINT ) : LONGINT;

FUNCTION CDGetTrackStart(Track : BYTE ) : LONGINT;

FUNCTION CDVolSize : LONGINT;
                         { Routine to determine the volume size in      }
                         { sectors.                                     }
FUNCTION CDSectSize : WORD;
                         { Routine to determine the Sector size in      }
                         { bytes.                                       }
FUNCTION CDPlayAudio(Track : BYTE; Len : LONGINT ) : BOOLEAN;

IMPLEMENTATION
{***********************************************************************}
VAR
   OldExit : POINTER;
   CDDL     : DriveList;
   CDDriver : STRING[8];  { CD Driver name.                }

FUNCTION GetDriverName : String;
VAR
   CDNTemp : Array[1..18] OF BYTE;
   Where : POINTER;
   Count : BYTE;
   CDSTemp : STRING[8];
BEGIN
   ASM
      MOV AX, 1501h
      MOV BX, OFFSET CDDL
      MOV DX, SEG CDDL
      MOV ES, DX
      INT $2F
   END;
   Where := Ptr(CDDL.DSegment,CDDL.DOffset);
   Move(Where^,CDNTEMP,18);
   Count := 1;
   REPEAT
      CDStemp[Count] := CHR(CDNTemp[10+Count]);
      INC(Count);
   UNTIL (Count > 8) OR (CDNTemp[10+Count]=32);
   CDSTemp[0] := CHR(Count-1);
   GetDriverName := CDSTemp;
END;


FUNCTION CDGetHandle : WORD;
{ Routine to get handle for referencing the CD }
{ Device driver.                               }
VAR
   Handle : WORD;
BEGIN
   Assign(CDDevice,CDDriver);     { Assign Handle to driver.              }
   {$I-}                          { Turn I/O checking off.                }
   Reset(CDDevice);               { Attempt to open driver.               }
   {$I+}                          { Turn I/O checking on.                 }
   IF (IOResult = 0) THEN
      Handle := TextRec(CDDevice).Handle{ Save DOS Handle.                }
    ELSE
      Handle := 0;
   CDGetHandle := Handle;
END;{CDGetHandle}

PROCEDURE CDCloseHandle;
{ Routine to close Handle referencing the CD   }
{ Driver.                                      }
BEGIN
   {$I-}                          { Turn I/O checking off.                }
   Close(CDDevice);               { Attempt to Close driver.              }
   {$I+}                          { Turn I/O checking on.                 }
   IF (IOResult = 0) THEN           { Dummy IF to clear IOResult.           }
   BEGIN
   END;
END;{CDCloseHandle}

FUNCTION CDIoctl(IntFunc, Len : WORD;VAR CtlBlk ) : BOOLEAN; ASSEMBLER;
{ Routine to call the CD IOCTL.                }
ASM
  PUSH   DS
  MOV    AX,IntFunc                { 4402 = Read, 4403 = Write.            }
  MOV    BX,CDHandle               { Load Handle for Driver into BX.       }
  MOV    CX,Len
  LDS    DX,CtlBlk                 { Point DS:DX to the control block.     }

  INT    $21                       { Call DOS Interrupt.                   }
  MOV    CDStatus,AX               { Save status of function.              }
  JNC    @NoError                  { If there was no error jump to noerror.}
  MOV    AX,0                      { Return FALSE.                         }
@NoError:
  MOV    AX,1                      { Return TRUE.                          }
@Exit:
  POP    DS
END;{CDIoctl}

PROCEDURE DriverRequest(Drive : BYTE;VAR CtlBlk ); ASSEMBLER;
{ Routine to make request of MSCDEX.           }
ASM
   PUSH  ES                       { Save ES.                              }
   MOV   AX,$1510                  { Subfunction to make request of CD driver.}
   XOR   CH,CH                     { Clear High byte of CX.                }
   MOV   CL,Drive                  { Load drive to make request of. 0 = A,etc}
   LES   BX,CtlBlk                 { Point ES:BX to the control block.     }
   INT $2F                       { Call Multiplex interrupt.             }
   POP ES                        { Restore ES.                           }
END;{DriverRequest}

FUNCTION CDEject : BOOLEAN;
{ Routine to Eject the CD tray.                }
BEGIN
   CDControl[0] := EjectDisk;     { Function code to eject CD.            }
   CDEject := CDIoctl(CDWrite,1,CDControl); { Now try function and return }
                                            { result to program/user.     }
END;{CDEject}

FUNCTION CDCloseTray : BOOLEAN;
{ Routine to close the CD tray.                }
BEGIN
   CDControl[0] := CloseTray;     { Function code to close CD.            }
   CDCloseTray := CDIoctl(CDWrite,1,CDControl);{ Now try function and return}
                                          { result to program/user.     }
END;{CDCloseTray}

FUNCTION CDReset : BOOLEAN;
{ Routine to reset the CD Drive.               }
BEGIN
   CDControl[0] := ResetCD;       { Function code to Reset drive.         }
   CDReset := CDIoctl(CDWrite,1,CDControl);{ Now try function and return  }
                                          { result to program/user.     }
END;{CDReset}

FUNCTION CDGetVol(VAR InfRec : CDInfoRecord) : BOOLEAN;
{ Routine to get current audio volume output.  }
VAR
   Temp : BOOLEAN;               { Holds IOCTL Read Result.              }
BEGIN
   CDControl[0] := 4;             { Function to read current volumes.     }
   Temp := CDIoctl(CDRead,8,CDControl);
   IF Temp THEN                    { IF all was fine then save volumes to }
      Move(CDControl[1],InfRec.VolInf,8){ array.                            }
    ELSE
      FillChar(InfRec.VolInf,8,#0);  { Otherwise zero the array.            }
   CDGetVol := Temp;               { Return proper result.                }
END;{CDGetVol}

FUNCTION CDStop : BOOLEAN;
{ Routine to stop the playing and Audio CD.    }
BEGIN
   FillChar(CDControl,Sizeof(CDControl),#0);
   CDControl[0] := 5;             { Byte length of request header.        }
   CDControl[1] := 0;             { Sub unit #.                           }
   CDControl[2] := $85;           { Function to stop CD.                  }
   DriverRequest(CDInf.DrvNo,CDControl);
   CDStatus := CDControl[3] OR CDControl[4] SHL 8;
   CDStop   := (CDStatus AND $8000) = 0;
END;{CDStop}

PROCEDURE CDInitInfo;
{ Routine to Intilialize CD Info.              }
BEGIN
   ASM
     MOV  AX,$1500                  { Function to get installation info.    }
     MOV  BX,0                      { Clear BX.                             }
     INT  $2F                       { Call CD Multiplex.                    }
     MOV  CDInf.NumCD,BX            { Save number of CD drives available.   }
     MOV  CDInf.DrvNo,CL            { Save first drive number.              }
     MOV  CDInf.DrvChar,CL          { Save Drive number and convert it to   }
     ADD  CDInf.DrvChar,'A'         { a CHAR. I.E A,B,C,ETC                 }
   END;

  FillChar(CDControl,SizeOf(CDControl),#0);
  CDControl[0] := $0A;           { Function to get Audio Disk info.      }
  CDIoctl(CDRead,6,CDControl);
  Move(CDControl[1],CDInf.LoTrack,6);
END;{CDInitInfo}

FUNCTION CDResumePlay : BOOLEAN;
{ Routine to Resume playing a previously stopped}
{ audio track.                                  }
BEGIN
   FillChar(CDControl,Sizeof(CDControl),#0);
   CDControl[0] := 5;             { Byte length of request header.        }
   CDControl[1] := 0;             { Sub unit #.                           }
   CDControl[2] := $88;           { Function to Resume play a CD.         }
   DriverRequest(CDInf.DrvNo,CDControl);
   CDStatus := CDControl[3] OR CDControl[4] SHL 8;
   CDResumePlay := (CDStatus AND $8000) = 0;
END;{CDResumePlay}

FUNCTION CDGetPos(VAR PosInf : CDPosType ) : BOOLEAN;
{ Routine to retrieve current position being   }
{ played.                                      }
BEGIN
   CDControl[0] := $0C;           { Function to get Audio Postion info.   }
   CDGetPos := CDIoctl(CDRead,10,CDControl);
   Move(CDControl[1],PosInf,10);
END;{CDGetPos}

FUNCTION Red2HSG(Inf : LONGINT ) : LONGINT;
VAR
   Temp :LONGINT;
BEGIN
   Temp :=        LONGINT(( Inf SHR 16 ) AND $FF )  * 4500;
   Temp := Temp + LONGINT(( Inf SHR  8 ) AND $FF )  * 75;
   Temp := Temp + LONGINT(( Inf ) AND $FF ) ;
   Red2HSG := Temp - 2;
END;{Red2HSG}

FUNCTION CDGetTrackStart(Track : BYTE ) : LONGINT;
VAR
   TrackInf :ARRAY[0..6] OF BYTE;
   Start    :LONGINT;
BEGIN
   TrackInf[0] := $0B;            { Function to get track info.           }
   TrackInf[1] := Track;          { Track to get information of.          }

   CDIoctl(CDRead,6,TrackInf);
   Move(TrackInf[2],Start,4);
   CDGetTrackStart := Red2HSG(Start);
END;{CDGetTrackStart}

FUNCTION CDVolSize : LONGINT;
{ Routine to determine the volume size in      }
{ sectors.                                     }
VAR
   TempLong : LONGINT;           { Holds temporary size info.            }
BEGIN
   CDControl[0] := 8;            { Function code to determine volume size.}
   CDIoctl(CDRead,4,CDControl);  { Now get information.                   }
   Move(CDControl[1],TempLong,4);
   CDVolSize := TempLong;
END;{CDVolSize}

FUNCTION CDSectSize : WORD;
{ Routine to determine the Sector size in      }
{ bytes.                                       }
VAR
   TempWord :WORD;              { Holds temporary size info.            }
BEGIN
   CDControl[0] := 7;            { Function code to determine Sector size.}
   CDIoctl(CDRead,4,CDControl);  { Now get information.                   }
   Move(CDControl[2],TempWord,2);
   CDSectSize := TempWord;
END;{CDSectSize}

FUNCTION CDPlayAudio(Track : BYTE;Len : LONGINT ) : BOOLEAN;
VAR
   TrackStart : LONGINT;
BEGIN
   FillChar(CDControl,SizeOf(CDControl),#0); { Clear Control block.       }
   CDControl[0] := 22;            { Length of request header.             }
   CDControl[1] := 0;             { Zero the sub unit.                    }
   CDControl[2] := $84;           { Function to play audio.               }
   TrackStart := CDGetTrackStart(Track);
   Move(TrackStart,CDControl[14],4);
   Move(Len,CDControl[18],4);     { # of sectors to play.                 }
   DriverRequest(CDInf.DrvNo,CDControl);
   CDStatus := CDControl[3] OR CDControl[4] SHL 8;
   CDPlayAudio := (CDStatus AND $8000) = 0;
END;{CDPlayAudio}

{$F+}
PROCEDURE CDExit;
{ Our Exiting routine to clean up after our    }
{ selves.                                      }
BEGIN
   ExitProc := OldExit;           { Restore original exit procedure.      }
   CDCloseHandle;                 { Close the handle for the CD Driver.   }
END;
{$F-}

BEGIN

   CDDriver := GetDriverName;
   CDHandle := CDGetHandle;
   IF (CDHandle <> 0) THEN
   BEGIN
      CDInitInfo;
      OldExit := ExitProc;
      ExitProc := @CDExit;
   END;
END.{CDRom}

