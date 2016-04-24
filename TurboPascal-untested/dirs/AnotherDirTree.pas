(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0009.PAS
  Description: Another DIR Tree
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

Program Vtree2;

{$B-,D+,R-,S-,V-}
{
   ┌────────────────────────────────────────────────────┐
   │ Uses and GLOBAL VarIABLES & ConstANTS              │
   └────────────────────────────────────────────────────┘
}

Uses
  Crt, Dos;

Const
  NL        = #13#10;
  NonVLabel = ReadOnly + Hidden + SysFile + Directory + Archive;

Type

  FPtr      = ^Dir_Rec;

  Dir_Rec   = Record                             { Double Pointer Record    }
    DirName : String[12];
    DirNum  : Integer;
    Next    : Fptr;
  end;

  Str_Type  = String[65];

Var
  Version   : String;
  Dir       : str_Type;
  Loop      : Boolean;
  Level     : Integer;
  Flag      : Array[1..5] of String[20];
  TreeOnly  : Boolean;
  Filetotal : LongInt;
  Bytetotal : LongInt;
  Dirstotal : LongInt;
  tooDeep   : Boolean;
  ColorCnt  : Byte;

{
   ┌────────────────────────────────────────────────────┐
   │ Procedure Beepit                                   │
   └────────────────────────────────────────────────────┘
}

Procedure Beepit;

begin
  Sound (760);                                          { Beep the speaker }
  Delay (80);
  NoSound;
end;

{
   ┌────────────────────────────────────────────────────┐
   │ Procedure Usage                                    │
   └────────────────────────────────────────────────────┘
}

Procedure Usage;

begin
  BEEPIT;
  Write (NL,
    'Like the Dos TREE command, and similar to PC Magazine''s VTREE, but gives',NL,
    'you a Graphic representation of your disk hierarchical tree structure and',NL,
    'the number of Files and total Bytes in each tree node (optionally can be',NL,
    'omitted).  Also allows starting at a particular subdirectory rather than',NL,
    'displaying the entire drive''s tree structure.  Redirection of output and',NL,
    'input is an option.',NL,NL, 'USAGE:     VTREE2 {path} {/t} {/r}',NL,NL,
    '/t or /T omits the number of Files and total Bytes inFormation.',NL,
    '/r or /R activates redirection of input and output.',NL,NL, Version);
  Halt;
end;

{
┌────────────────────────────────────────────────────┐
│ Function Format                                    │
└────────────────────────────────────────────────────┘
}

Function Format (Num : LongInt) : String;   {converts Integer to String}
                                            {with commas inserted      }
Var
  NumStr : String[12];
  Place  : Byte;

begin
  Place := 3;
  STR (Num, NumStr);
  Num := Length (NumStr);                  {re-use Num For Length value }

  While Num > Place do                     {insert comma every 3rd place}
  begin
    inSERT (',',NumStr, Num - (Place -1));
    inC (Place, 3);
  end;

  Format := NumStr;
end;

{
   ┌────────────────────────────────────────────────────┐
   │ Procedure DisplayDir                               │
   └────────────────────────────────────────────────────┘
}

Procedure DisplayDir (DirP : str_Type; DirN : str_Type; Levl : Integer;
                     NumSubsVar2 : Integer; SubNumVar2 : Integer;
                     NumSubsVar3 : Integer;
                     NmbrFil : Integer; FilLen : LongInt);

{NumSubsVar2 is the # of subdirs. in previous level;
 NumSumsVar3 is the # of subdirs. in the current level.
 DirN is the current subdir.; DirP is the previous path}

Const
  LevelMax = 5;
Var
  BegLine : String;
  MidLine : String;
  Blank   : String;
  WrtStr  : String;

begin

  if Levl > 5 then
  begin
    BEEPIT;
    tooDeep := True;
    Exit;
  end;

  Blank   := '               ';                  { Init. Variables          }
  BegLine := '';
  MidLine := ' ──────────────────';

  if Levl = 0 then                               { Special handling For     }
    if Dir = '' then                             { initial (0) dir. level   }
      if not TreeOnly then
        WrtStr := 'ROOT ──'
      else
        WrtStr := 'ROOT'
    else
      if not TreeOnly then
        WrtStr := DirP + ' ──'
      else
        WrtStr := DirP
  else
  begin                                        { Level 1+ routines        }
    if SubNumVar2 = NumSubsVar2 then           { if last node in subtree, }
    begin                                    { use └─ symbol & set flag }
      BegLine  := '└─';                      { padded With blanks       }
      Flag[Levl] := ' ' + Blank;
    end
    else                                       { otherwise, use ├─ symbol }
    begin                                    { & set flag padded With   }
      BegLine    := '├─';                    { blanks                   }
      Flag[Levl] := '│' + Blank;
    end;

    Case Levl of                               { Insert │ & blanks as     }
      1: BegLine := BegLine;                  { needed, based on level   }
      2: Begline := Flag[1] + BegLine;
      3: Begline := Flag[1] + Flag[2] + BegLine;
      4: Begline := Flag[1] + Flag[2] + Flag[3] + BegLine;
      5: Begline := Flag[1] + Flag[2] + Flag[3] + Flag[4] + BegLine;
    end; {end Case}

    if (NumSubsVar3 = 0) then                  { if cur. level has no     }
      WrtStr := BegLine + DirN                 { subdirs., leave end blank}
    else
    begin
      WrtStr := BegLine + DirN + COPY(Midline,1,(13-Length(DirN)));
      if Levl < LevelMax then
        WrtStr := WrtStr + '─┐'
      else                                   { if level 5, special      }
      begin                                { end to indicate more     }
        DELETE (WrtStr,Length(WrtStr),1);  { levels                   }
        WrtStr := WrtStr + '»';
      end;
    end;
  end;                                         { end level 1+ routines    }

  if ODD(ColorCnt) then
    TextColor (3)
  else
    TextColor (11);
  inC (ColorCnt);

  if ((Levl < 4) or ((Levl = 4) and (NumSubsVar3=0))) and not TreeOnly then
    WriteLn (WrtStr,'':(65-Length(WrtStr)), Format(NmbrFil):3,
             Format(FilLen):11)
  else
    WriteLn (WrtStr);                            { Write # of Files & Bytes  }
                                                 { only if it fits, else     }
end;                                             { Write only tree outline   }


{
   ┌────────────────────────────────────────────────────┐
   │ Procedure DisplayHeader                            │
   └────────────────────────────────────────────────────┘
}

Procedure DisplayHeader;

begin
  WriteLn ('DIRECtoRIES','':52,'FileS','      ByteS');
  WriteLn ('═══════════════════════════════════════════════════════════════════════════════');
end;

{
   ┌────────────────────────────────────────────────────┐
   │ Procedure DisplayTally                             │
   └────────────────────────────────────────────────────┘
}

Procedure DisplayTally;

begin
  WriteLn('':63,'════════════════');
  WriteLn('NUMBER of DIRECtoRIES: ', Dirstotal:3, '':29,
          'toTALS: ', Format (Filetotal):5, Format (Bytetotal):11);
end;

{
   ┌────────────────────────────────────────────────────┐
   │ Procedure ReadFiles                                │
   └────────────────────────────────────────────────────┘
}

Procedure ReadFiles (DirPrev : str_Type; DirNext : str_Type;
                     SubNumVar1 : Integer; NumSubsVar1 : Integer);

Var
  FileInfo  : SearchRec;
  FileBytes : LongInt;
  NumFiles  : Integer;
  NumSubs   : Integer;
  Dir_Ptr   : FPtr;
  CurPtr    : FPtr;
  FirstPtr  : FPtr;

begin
  FileBytes := 0;
  NumFiles  := 0;
  NumSubs   := 0;
  Dir_Ptr   := nil;
  CurPtr    := nil;
  FirstPtr  := nil;

  if Loop then
    FindFirst (DirPrev + DirNext + '\*.*', NonVLabel, FileInfo);
  Loop      := False;                            { Get 1st File             }

  While DosError = 0 do                          { Loop Until no more Files }
  begin
    if (FileInfo.Name <> '.') and (FileInfo.Name <> '..') then
    begin
      if (FileInfo.attr = directory) then    { if fetched File is dir., }
      begin                                { store a Record With dir. }
        NEW (Dir_Ptr);                     { name & occurence number, }
        Dir_Ptr^.DirName  := FileInfo.name;{ and set links to         }
        inC (NumSubs);                     { other Records if any     }
        Dir_Ptr^.DirNum   := NumSubs;
        if CurPtr = nil then
        begin
          Dir_Ptr^.Next := nil;
          CurPtr        := Dir_Ptr;
          FirstPtr      := Dir_Ptr;
        end
        else
        begin
          Dir_Ptr^.Next := nil;
          CurPtr^.Next  := Dir_Ptr;
          CurPtr        := Dir_Ptr;
        end;
      end
      else
      begin                                { Tally # of Bytes in File }
        FileBytes := FileBytes + FileInfo.size;
        inC (NumFiles);                    { Increment # of Files,    }
      end;                                 { excluding # of subdirs.  }
    end;
    FindNext (FileInfo);                       { Get next File            }
  end;    {end While}

  Bytetotal := Bytetotal + FileBytes;
  Filetotal := Filetotal + NumFiles;
  Dirstotal := Dirstotal + NumSubs;

  DisplayDir (DirPrev, DirNext, Level, NumSubsVar1, SubNumVar1, NumSubs,
              NumFiles, FileBytes);            { Pass info to & call      }
  inC (Level);                                 { display routine, & inc.  }
                                               { level number             }


  While (FirstPtr <> nil) do                   { if any subdirs., then    }
  begin                                      { recursively loop thru    }
    Loop     := True;                        { ReadFiles proc. til done }
    ReadFiles ((DirPrev + DirNext + '\'),FirstPtr^.DirName,
                FirstPtr^.DirNum, NumSubs);
    FirstPtr := FirstPtr^.Next;
  end;

  DEC (Level);                                 { Decrement level when     }
                                               { finish a recursive loop  }
                                               { call to lower level of   }
                                               { subdir.                  }
end;

{
   ┌────────────────────────────────────────────────────┐
   │ Procedure Read_Parm                                │
   └────────────────────────────────────────────────────┘
}

Procedure Read_Parm;

Var
  Cur_Dir : String;
  Param   : String;
  i       : Integer;

begin

  if ParamCount > 3 then
    Usage;
  Param := '';

  For i := 1 to ParamCount do                    { if either param. is a T, }
  begin                                        { set TreeOnly flag            }
    Param := ParamStr(i);
    if Param[1] = '/' then
      Case Param[2] of
        't','T': begin
                   TreeOnly := True;
                   if ParamCount = 1 then
                     Exit;
                 end;                          { Exit if only one param   }

        'r','R': begin
                   ASSIGN (Input,'');          { Override Crt Unit, &     }
                   RESET (Input);              { make input & output      }
                   ASSIGN (Output,'');         { redirectable             }
                   REWrite (Output);
                   if ParamCount = 1 then
                     Exit;
                 end;                          { Exit if only one param   }
        '?'    : Usage;

        else
          Usage;
      end; {Case}
  end;

  GETDIR (0,Cur_Dir);                            { Save current dir         }
  For i := 1 to ParamCount do
  begin
    Param := ParamStr(i);                      { Set Var to param. String }
    if (POS ('/',Param) = 0) then
    begin
      Dir := Param;
{$I-} CHDIR (Dir);                           { Try to change to input   }
      if Ioresult = 0 then                   { dir.; if it exists, go   }
      begin                                { back to orig. dir.       }
{$I+}   CHDIR (Cur_Dir);
        if (POS ('\',Dir) = Length (Dir)) then
          DELETE (Dir,Length(Dir),1);       { Change root symbol back  }
        Exit;                                { to null, 'cause \ added  }
      end                                  { in later                 }
      else
      begin
        BEEPIT;
        WriteLn ('No such directory -- please try again.');
        HALT;
      end;
    end;
  end;
end;

{
   ┌────────────────────────────────────────────────────┐
   │ MAin Program                                       │
   └────────────────────────────────────────────────────┘
}

begin

  Version   := 'Version 1.6, 7-16-90 -- Public Domain by John Land';
                                                 { Sticks in EXE File      }

  Dir       := '';                               { Init. global Vars.      }
  Loop      := True;
  Level     := 0;
  TreeOnly  := False;
  tooDeep   := False;
  Filetotal := 0;
  Bytetotal := 0;
  Dirstotal := 1;                                { Always have a root dir. }
  ColorCnt  := 1;

  ClrScr;

  if ParamCount > 0 then
    Read_Parm;              { Deal With any params.   }

  if not TreeOnly then
    DisplayHeader;

  ReadFiles (Dir,'',0,0);                        { do main read routine    }

  TextColor(Yellow);

  if not TreeOnly then
    DisplayTally;             { Display totals          }

  if tooDeep then
    WriteLn (NL,NL,'':22,'» CANnot DISPLAY MorE THAN 5 LEVELS «',NL);
                                                 { if ReadFiles detects >5 }
                                                 { levels, tooDeep flag set}

end.

