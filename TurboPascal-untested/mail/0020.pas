
{***********************************************************************}
{$M 16384,0,0}                  { Save memory for Calling PKUNZIP.      }
PROGRAM NMembers;               { May 16/94, Greg Estabrooks.           }
USES
     DOS;
CONST
     Ver      = 'V0.2ß';        { Current Version of program.           }
     ProgTitle= 'NMem '+Ver+'- Conference Member Tracking Program. ';
     Author   = 'CopyRight (C) 1994, Greg Estabrooks.';
TYPE
    Direction = (Left,Right);

    MsgDHdr = RECORD            { Structre of QWK Message Header.       }
               Status    :CHAR;
               MNum      :ARRAY[1..7] OF CHAR;
               Date      :ARRAY[1..8] OF CHAR;
               Time      :ARRAY[1..5] OF CHAR;
               MTo       :ARRAY[1..25] OF CHAR;
               MFrom     :ARRAY[1..25] OF CHAR;
               MSubj     :ARRAY[1..25] OF CHAR;
               Pass      :ARRAY[1..12] OF CHAR;
               MRefer    :ARRAY[1..8] OF CHAR;
               NChunks   :ARRAY[1..6] OF CHAR;
               Active    :CHAR;
               MConf     :WORD;
               Fill      :ARRAY[1..3] OF CHAR;
             END;{MsgDHdr}

    NDXType = RECORD
                Offset :LONGINT;
                Misc   :BYTE;
              END;

    MessInfType = RECORD
                   Name  :STRING[25];   { Name of person message FROM.  }
                   Origin:STRING[80];   { Origin line from message.     }
                  END;

VAR
  QWKName :STRING[128];         { QWK File to process.                  }
  OutFile :STRING[128];         { File to place new member names.       }
  WorkDir :STRING[128];         { Holds the name of our work directory. }
  OutHan  :TEXT;                { File handle for output file.          }
  MessDat :FILE;                { File handle for MESSAGES.DAT.         }

  NumMess :WORD;                { Number of messages in conference.     }
  NewMems :WORD;                { Number of new members found.          }
  NumFound:WORD;                { Holds number of different names found.}

  fOfs    :ARRAY[1..500] OF LONGINT;{ Holds offset info from NDX file.  }
  FInf    :ARRAY[1..500] OF MessInfType;

FUNCTION PadStr( Dir :Direction; Str2Pad :STRING; Til :BYTE;
                                                 Ch :CHAR ) :STRING;
                         { Function to pad a string with 'Ch' until it  }
                         { is 'Til' long.                               }
VAR
   Temp :STRING;                { Temporary String info.                }
BEGIN
  Temp := Str2Pad;              { Initialize 'Temp' to users string.    }
  IF Length(Temp) < Til THEN    { If its smaller than 'Til' add padding.}
  WHILE (Length(Temp) < Til) DO { Loop until proper length reached.     }
   BEGIN
     CASE Dir OF
      Right :Temp := Temp + Ch; { If Right then add to end of string.   }
      Left  :Temp := Ch + Temp; { If Left then add to begining.         }
     END;
   END;
  PadStr := Temp;               { Return proper result.                 }
END;

PROCEDURE InitVars;
                        { Procedure to initialize program variables.    }
VAR
   Temp :STRING[4];             { Temporary String value.               }
BEGIN
  FillChar(FInf,SizeOf(FInf),#0); { Clear FInf.                         }
  NumMess := 0;                 { Clear number of messages.             }
  NewMems := 0;                 { Clear number of new members found.    }
  QWKName := ParamStr(1);       { Get QWK Name from command line.       }
  NumFound := 1;                { Initialize 'NumFound.'                }
  Temp := ParamStr(2);          { Get Conf Number from command line.    }
  OutFile := 'CNF'+PadStr(Left,Temp,5,'0')+'.LST';
                                { Prepare output file name.             }

  GetDir(0,WorkDir);            { Save current directory.               }
  IF WorkDir[Length(WorkDir)] = '\' THEN
   WorkDir := WorkDir +'NMEM'
  ELSE
   WorkDir := WorkDir +'\NMEM';
END;{InitVars}

PROCEDURE Syntax_Error;
                       { Display proper command line syntax to user.    }
BEGIN
  Writeln;                      { Skip a line.                          }
  Writeln(
     'Syntax: NMEM [drive]:[path]PacketName ConfNum');
                                { Show syntax for user.                 }
  Writeln;                      { Skip a line.                          }
                                { Show an example usage.                }
  Writeln('EXAMPLE : NMEM C:\QWK\MYBBS.QWK 123');
  Writeln(' Scans MYBBS.QWK and generates CNF00123.LST');
  Halt(1);                      { Halt program with and ERRORLEVEL of 1.}
END;{Syntax_Error}

FUNCTION fExist( FName :STRING ) :BOOLEAN;
                        { Routine to determine whether or not 'FName'   }
                        { really exists.                                }
BEGIN
  fExist := (fSearch(FName,'') <> '');
END;{fExist}

FUNCTION DirExist( DName :STRING ) :BOOLEAN;
                         { Routine to determine whether or not the      }
                         { Directory 'DName' exists.                    }
VAR
   DirInf :SearchRec;           { Hold info if dir found.               }
BEGIN
  FindFirst(DName,Directory,DirInf);
  DirExist := (DosError = 0);
END;{DirExist}

PROCEDURE DelWorkDir;
                         { Routine to delete files in the work directory}
                         { and them remove the directory.               }
VAR
   FileInf :SEARCHREC;          { Holds file names for erasure.         }
   fVar    :FILE;               { Handle of file to delete.             }
BEGIN
  FindFirst(WorkDir+'\*.*',Archive,FileInf); { Get File Name.           }
  WHILE (DosError = 0) DO       { Loop until all file names read.       }
  BEGIN
    Assign(fVar,WorkDir+'\'+FileInf.Name);
                                { Assign file name to handle.           }
    Erase(fVar);                { Erase File.                           }
    FindNext(FileInf);          { Get next file name.                   }
  END;
END;{DelWorkDir}

PROCEDURE OpenPacket( QName :STRING );
                         { Routine open mail packets.                   }
VAR
   PKPath :STRING;              { Holds location of PKUNZIP.EXE         }
BEGIN
  IF NOT DirExist(WorkDir) THEN { If dir doesn't exist then make it.    }
   BEGIN
    {$I-}                       { Turn I/O checking off.                }
    MKDir(WorkDir);             { Create our work directory.            }
    {$I+}                       { Turn I/O checking off.                }

    IF IOResult <>0 THEN        { If I/O error then                     }
     BEGIN                      { Display error message.                }
      Writeln('Error creating work directory',^G);
      Halt(1);                  { Now halt program.                     }
     END;

   END
  ELSE
   DelWorkDir;                  { If it does exist then clear it.       }

  IF NOT fExist('PKUNZIP.EXE') THEN { If it's not in the current dir    }
   BEGIN                        { then search the %PATH%.               }
    PKPath := fSearch('PKUNZIP.EXE',GetEnv('PATH'));
    IF PKPath = '' THEN         { If it's nowhere to be found then      }
     BEGIN                      { Display error message.                }
      Writeln('Cannot find PKUNZIP.EXE!',^G);
      Writeln('It must be located either in the ',
                 'current directory or along your %PATH%');
      Halt(1);                  { Now halt program.                     }
     END;
   END;

  SwapVectors;                  { Swap to proper Interrupt vectors.     }
  Exec(GetEnv('COMSPEC'),'/C '+PKPath+' '+QWKName+' '+WorkDir+' >NUL');
  SwapVectors;                  { Swap em back.                         }

  IF DosError <> 0 THEN         { If there was an 'Exec' error then     }
   BEGIN                        { Display error message.                }
    Writeln('Error #',DosError,' occured executing ',PKPath,^G);
    Halt(1);                    { Now Halt program.                     }
   END;

  IF DosExitCode <> 0 THEN      { Check for a program error.            }
   Writeln(PKPath,' returned an ERRORLEVEL of ',DosExitCode,^G);
END;{OpenPacket}

FUNCTION NotNumber( NumStr :STRING ) :BOOLEAN;
                         { Routine to determine whether or not 'NumStr' }
                         { is a valid number.                           }
                         { Returns TRUE if not a number FALSE if a num. }
VAR
   Result :BOOLEAN;             { Holds Function result.                }
   StrPos :BYTE;                { Position withing string.              }
BEGIN
  Result := FALSE;              { Defaults to false.                    }
  FOR StrPos := 1 TO Length(NumStr) DO { Loop through entire string.    }
   IF NOT (NumStr[StrPos] IN
            ['0','1','2','3','4','5','6','7','8','9']) THEN
     Result := TRUE;

  NotNumber := Result;          { Return proper result.                 }
END;{NotNumber}

FUNCTION ReadNDX :BOOLEAN;
                         { Routine to read proper NDX file for conference.}
VAR
   Result :BOOLEAN;             { Holds Function result.                }
   NDX    :FILE;                { File handle for NDX file.             }
   Info   :NDXType;             { Hold info read from NDX file.         }
   NumRead:WORD;                { Holds number of bytes read from NDX.  }
BEGIN
  Result := TRUE;               { Default to success.                   }
  Assign(NDX,WorkDir+'\'+PadStr(Left,ParamStr(2),3,'0')+'.NDX');
  {$I-}                         { Turn off I/O checking.                }
  Reset(NDX,1);                 { Open NDX for reading.                 }
  {$I+}                         { Turn on I/O checking.                 }
  WHILE NOT EOF(NDX) DO         { Loop until end of file.               }
   BEGIN
     BlockRead(NDX,Info,SizeOf(Info),NumRead); { Read offset of message.}
     IF (NumRead = Sizeof(Info)) AND (NumMess <501) THEN
                                { If proper amount read then            }
      BEGIN                     { Convert it to a proper LONGINT.       }
        INC(NumMess);           { Increase message total.               }
                                { Now convert offset.                   }
        fOfs[NumMess] := ((Info.Offset AND NOT $FF000000) OR $00800000)
                          SHR (24 - ((Info.Offset SHR 24) AND $7F));
        fOfs[NumMess] := (fOfs[NumMess]-1) SHL 7;
      END
     ELSE
      Result := FALSE;          { Otherwise return FALSE result.        }
   END;
  Close(NDX);                   { Close NDX File.                       }
  ReadNDX := Result;            { Return proper result.                 }
END;{ReadNDX}

PROCEDURE RemoveSpaces(VAR Str2Rem :STRING);
                         { Routine to remove any spaces from 'Str2Rem'. }
VAR
   StrPos :WORD;                { Position within string.               }
   Temp   :STRING;              { Temporary string work space.          }
BEGIN
  Temp := '';                   { Clear string.                         }
  FOR StrPos := 1 TO Length(Str2Rem) DO { Loop through all characters.  }
   IF Str2Rem[StrPos] <> #32 THEN   { If its not a space then           }
    Temp := Temp + Str2Rem[StrPos]; { add it to our string.             }

  Str2Rem := Temp;              { Return newly changed string.          }
END;{RemoveSpaces}

FUNCTION Compare( Str1,Str2 :STRING ) :BOOLEAN;
                         { Routine to compare to strings after removing }
                         { any spaces from it.Case INSENSITIVE.         }
VAR
   Result :BOOLEAN;             { Result from comparing.                }
   StrPos :BYTE;                { Position within 2 strings.            }
BEGIN
  Result := TRUE;               { Default result to TRUE.               }
  RemoveSpaces(Str1);           { Trim spaces from the strings.         }
  RemoveSpaces(Str2);
  IF Length(Str1) <> Length(Str2) THEN { If different lengths then they }
   Result := FALSE                     { must be different.             }
  ELSE
   BEGIN
    StrPos := 0;                { Initialize 'StrPos' to 0.             }
    REPEAT                      { Loop until every char checked.        }
     INC(StrPos);               { Point to next char.                   }
     IF UpCase(Str1[StrPos]) <> UpCase(Str2[StrPos]) THEN
      BEGIN
       Result := FALSE;         { If there not the same then return     }
                                { a FALSE result.                       }
       StrPos := Length(Str2);  { Now set loop exit condition.          }
      END;
    UNTIL StrPos = Length(Str2);
   END;

  Compare := Result;            { Return proper result.                 }
END;{Compare}

FUNCTION Arr2String( VAR Arr; Len :BYTE ) :STRING;
                         { Routine to convert 'Len' bytes of the array  }
                         { 'Arr' into a string.                         }
VAR
   Result :STRING;              { Holds function result.                }
BEGIN
  MOVE(Arr,Result[1],Len);      { Move bytes into our result string.    }
  Result[0] := CHR(Len);        { Set string length byte.               }

  Arr2String := Result;         { Return proper result.                 }
END;{Arr2String}

FUNCTION Fmt( Info :WORD ) :STRING;
                         { Routine to create a String with info int the }
                         { format '00'.                                 }
VAR
   Temp :STRING;                { Hold temporary string info.           }
BEGIN
  Str(Info,Temp);               { Convert info to a string.             }
  IF Length(Temp) = 1 THEN      { if its only a single digit then add   }
    Fmt := '0'+Temp             { leading zero.                         }
  ELSE
    Fmt := Temp;
END;{Fmt}

FUNCTION TimeStr :STRING;
VAR
   Hour,Min,Sec,Sec100 :WORD;   { Holds temporary time info.            }
   Year,Mon,Day,DoWeek :WORD;   { Holds temporary date info.            }
   TempTime :STRING;            { Holds temporary TimeStr.              }
BEGIN
  GetDate(Year,Mon,Day,DoWeek);
  TempTime := Fmt(Mon)+'-'+Fmt(Day)+'-'+Fmt(Year-1900)+' at ';
  GetTime(Hour,Min,Sec,Sec100); { Get Current Time.                     }
  IF Hour >= 12 THEN
    TempTime := TempTime+Fmt(Hour-12)+':'+Fmt(Min)+'pm'
  ELSE
    IF Hour = 0 THEN
      TempTime := TempTime+'12:'+Fmt(Min)+'am'
    ELSE
      TempTime := TempTime+Fmt(Hour)+':'+Fmt(Min)+'pm';
  TimeStr := TempTime;
END;

FUNCTION GetOrigin( Chunks :WORD ) :STRING;
                         { Routine to get message origin line if any.   }
VAR
   Result :STRING;              { Holds function result.                }
   CurChnk:WORD;                { Holds current chunk being read.       }
   BufPos :WORD;                { Position within buffer.               }
   Temp   :STRING;
   NumRead:WORD;                { Holds number of bytes read from file. }
   Buffer :ARRAY[1..128] OF CHAR;{ Buffer for info read from file.      }
   TareLin:BOOLEAN;             { Holds whether or not we've past the   }
                                { tear line.                            }
BEGIN
  Result := '';                 { Clear result.                         }
  Temp := '';                   { Clear temporary storage space.        }
  TareLin := FALSE;             { Default to FALSE.                     }
  FOR CurChnk := 1 TO Chunks-1 DO { Loop through all the 128 byte chunks.}
   BEGIN
    BlockRead(MessDat,Buffer,128,NumRead); { Read message info.         }
    FOR BufPos := 1 TO 128 DO
     BEGIN
      IF Buffer[BufPos] = #227 THEN
       BEGIN
        IF Temp = '---' THEN
         TareLin := TRUE
        ELSE
         IF TareLin AND (Temp <> PadStr(Right,'',Length(Temp),' ')) THEN
          Result := Temp;
        Temp := ''
       END
      ELSE
       Temp := Temp + Buffer[BufPos];
     END;
   END;

  IF (Result = '') OR (Pos('ILink:',Result) = 0) THEN
   Result := ' ■ Origin Line Unavailable ■ ';

  GetOrigin := Result;          { Return proper result.                 }
END;

PROCEDURE ReadMsgs;
                         { Routine to read Messages and save new members}
                         { to disk.                                     }
VAR
  MessBuf :MsgDHdr;             { Holds header info read from file.     }
  InfPos  :WORD;                { Loop variable for searching 'FileInf'.}
  CurMess :WORD;                { Loop variable for reading messages.   }
  NumRead :WORD;                { Holds number of bytes read from file. }
  Found   :BOOLEAN;             { Holds whether or not name was already }
                                { read.                                 }
  FoundPos:WORD;                { Holds position in array name was found.}
  Temp    :STRING;              { Holds temporary string info.          }
  Chunks  :WORD;                { Holds number of 128 byte chunks message}
                                { takes up in file.                     }
  ErrCode :WORD;                { Holds error codes returned from 'Val'.}
  Create  :BOOLEAN;
BEGIN
  Create  := NOT fExist(OutFile);
  IF NumFound = 0 THEN NumFound := 1;
  Assign(MessDat,WorkDir+'\MESSAGES.DAT');{ Assign handle to message file.}
  {$I-}                         { Turn I/O checking off.                }
  Reset(MessDat,1);             { Open file for reading.                }
  {$I+}                         { Turn I/O checking back on.            }
  FOR CurMess := 1 TO NumMess DO { Loop through all the messages.       }
   BEGIN
     Seek(MessDat,fOfs[CurMess]);{ Move to current message position.    }
     BlockRead(MessDat,MessBuf,SizeOf(MessBuf),NumRead); { Read Header. }
     FOR InfPos := 1 TO NumFound DO
      BEGIN
       Found := Compare(FInf[InfPos].Name,Arr2String(MessBuf.MFrom,25));
       IF Found THEN
        InfPos := NumFound;
      END;
     IF NOT Found THEN
      BEGIN
       INC(NewMems);            { Increase number of new members.       }
       IF Create AND (NumFound = 1) THEN
        BEGIN
          NumFound := 0;
          Create := FALSE;
        END;
       INC(NumFound);           { Increase number found.                }

       FInf[NumFound].Name := Arr2String(MessBuf.MFrom,25);
       Temp := Arr2String(MessBuf.NChunks,6);
       RemoveSpaces(Temp);
       Val(Temp,Chunks,ErrCode);
       FInf[NumFound].Origin := GetOrigin(Chunks);
      END;
   END;
  Close(MessDat);               { Close message file.                   }
END;{ReadMsgs}

PROCEDURE SaveList;
                         { Routine to write our list to the list file.  }
VAR
   ListPos :WORD;               { Position withing list being written.  }
BEGIN
  Assign(OutHan,OutFile);       { Assign handle to file name.           }
  {$I-}                         { I/O off.                              }
  Rewrite(OutHan);              { Open file for writing.                }
  {$I+}                         { I/O on.                               }
  IF IOResult <> 0 THEN         { If there was an error.                }
   Writeln('-Error! Unable to Open ',OutFile,^G)
  ELSE
   BEGIN
    Writeln(OutHan,'');         { Write a blank line to file.           }
    Writeln(OutHan,'/*'+PadStr(Right,'',75,'-')+'*/');

    Writeln(OutHan,'                         Conference [',ParamStr(2),
                   '] Members list.');
    Writeln(OutHan,PadStr(Right,'',24,' ')+'Last Change '+TimeStr);
    Writeln(OutHan,'/*'+PadStr(Right,'',75,'-')+'*/');
    FOR ListPos := 1 TO NumFound DO
     BEGIN
      Writeln(OutHan,'');       { Writeln a blank line.                 }
      Writeln(OutHan,'User : '+FInf[ListPos].Name); { Writeln user name.}
      Writeln(OutHan,FInf[ListPos].Origin); { Write users origin line.  }
     END;
    Close(OutHan);                { Close file.                           }
   END;
END;{SaveList}

PROCEDURE ReadList;
                         { Routine to read in the conf members list.    }
VAR
   InFile :TEXT;                { Text handle for conference list.      }
   Temp   :STRING;              { Holds string read from file.          }
BEGIN
  NumFound := 0;
  Assign(InFile,OutFile);       { Assign handle to file name.           }
  {$I-}                         { I/O checking off.                     }
  Reset(Infile);                { Open file for reading.                }
  {$I+}                         { I/O checking on.                      }
  WHILE (NOT EOF(InFile)) AND (NumFound <500) DO
   BEGIN
    ReadLn(InFile,Temp);        { Read a line from the file.            }
    IF Copy(Temp,1,7) = 'User : ' THEN { If its the user name then.     }
     BEGIN                      { Save Name to array and read origin.   }
      INC(NumFound);
      FInf[NumFound].Name := Copy(Temp,8,Length(Temp));
      ReadLn(InFile,FInf[NumFound].Origin);
     END;
   END;
  IF NumFound = 0 THEN
   NumFound := 1;
  Close(InFile);                { Close file.                           }
END;{ReadList}

PROCEDURE SortList;
                         { Routine to sort the list of conference       }
                         { members using a simple bubble sort.          }
VAR
   Temp  :MessInfType;          { Temporary record for swapping.        }
   Index1,Index2:WORD;          { Sort loop variables.                  }
BEGIN
  FOR Index1 := NumFound DOWNTO 1 DO
   FOR Index2 := 2 TO Index1 DO
    IF FInf[Index2-1].Name > FInf[Index2].Name THEN
     BEGIN
      Temp := FInf[Index2];
      FInf[Index2] := FInf[Index2-1];
      FInf[Index2-1] := Temp;
     END;
END;{SortList}

BEGIN
  Writeln(ProgTitle);           { Display program title.                }

  IF (ParamCount <> 2) OR NotNumber(ParamStr(2)) THEN
                                { If wrong command argument show proper }
    Syntax_Error                { syntax to use.                        }
  ELSE
   BEGIN
    InitVars;                   { Initialize variables.                 }
    IF fExist(QWKName) THEN     { If it exists begin processing.        }
     BEGIN
      Writeln('-Opening Packet');
      OpenPacket(QWKName);      { Open mail packet.                     }
      IF fExist(WorkDir+'\'+PadStr(Left,ParamStr(2),3,'0')+'.NDX') THEN
       BEGIN                    { IF there are any Messages in conf then}
                                { Attempt to read NDX files.            }
        Writeln('-Reading NDX file');

        IF ReadNDX THEN         { IF there is no error, read messages.  }
         BEGIN

          IF fExist(OutFile) THEN{ IF Conf list already exist then read.}
           BEGIN
            Writeln('-Reading ',OutFile);
            ReadList;

           END;

          Writeln('-Reading Messages in conference [',ParamStr(2),']');
          ReadMsgs;

          IF NewMems > 0 THEN
           BEGIN

            IF fExist(OutFile) THEN
             BEGIN
              Writeln('-Renaming ',OutFile,' to ',Copy(OutFile,1,8)+'.BAK');

              IF fExist(Copy(OutFile,1,8)+'.BAK') THEN
               BEGIN
                Assign(OutHan,Copy(OutFile,1,8)+'.BAK');
                Erase(OutHan);
               END;

              Assign(OutHan,OutFile);
              Rename(OutHan,Copy(OutFile,1,8)+'.BAK');
             END
            ELSE
             BEGIN
              Writeln('-Creating ',OutFile);
              Assign(OutHan,OutFile);
              {$I-}
              Rewrite(OutHan);
              {$I+}
              Close(OutHan);
             END;
            Writeln('-Sorting member list');
            SortList;
            Writeln('-Saving ',NewMems,
                    ' new members for a total of ',NumFound,' members');
            SaveList;
           END
          ELSE
           Writeln('-No new members found');
         END
        ELSE
         Writeln('-Error reading NDX file',^G);
       END
      ELSE                      { Other wise let user know its not there.}
       Writeln('-NDX file for conference [',ParamStr(2),
               '] does not exist. No new messages?'^G);

      Writeln('-Deleteing Work Directory');
      DelWorkDir;               { Delete Work Directory.                }
      {$I-}                     { Turn I/O checking off.                }
      RMDir(WorkDir);           { Remove work Directory.                }
      {$I+}                     { Turn I/O checking on.                 }
      IF IOResult <> 0 THEN     { If and error occurs then              }
      Writeln('Error Removing work directory.',^G);

     END
    ELSE                        { .... Otherwise ......                 }
     BEGIN                      { Show error message and beep.          }
      Writeln(^G,'Cannot find ',QWKName);
      Writeln('Tracking aborted!!');
     END;
   END;
END.{NMembers}
{***********************************************************************}
