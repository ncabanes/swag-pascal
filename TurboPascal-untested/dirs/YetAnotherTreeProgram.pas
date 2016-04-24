(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0051.PAS
  Description: Yet Another Tree Program
  Author: DAVID DANIEL ANDERSON
  Date: 11-22-95  13:33
*)

PROGRAM YATP; { Free DOS utility: Yet Another "Tree" Program. }
(*   I got much of the code for this program, particularly
     the "DisplayDir" and "ReadFiles" Procedures, from:
   ╔══════════════════════════════════════════════════════╗
   ║  VTree2                                              ║
   ║  Version 1.6, 7-16-90 -- Public Domain by John Land  ║
   ║  (Found in SWAG, in the DIRS library)                ║
   ╚══════════════════════════════════════════════════════╝
*)
{$M 32768,0,655360} { Allow a HUGE stack because of heavy recursion. }
{  ┌────────────────────────────────────────────────────┐
   │ USES AND GLOBAL VARIABLES & CONSTANTS              │
   └────────────────────────────────────────────────────┘  }

USES
  Crt, DOS;

CONST
  NL        = #13#10;
  NonVLabel = ReadOnly + Hidden + SysFile + Directory + Archive;
  LevelMax  = 16;

TYPE
  FPtr      = ^Dir_Rec;
  Dir_Rec   = RECORD                           { Double Pointer Record    }
                DirName : STRING [14];
                DirNum  : INTEGER;
                Next    : Fptr;
              END;

VAR
  Dir       : STRING;
  Loop,
  tooDeep   : BOOLEAN;
  Level     : INTEGER;
  Flag      : ARRAY [1..LevelMax] OF STRING [2];
  Filetotal,
  Bytetotal,
  Dirstotal : LONGINT;
  ColorCnt  : WORD;

  ClusterSize : WORD;
  TotalClusters : LONGINT;

PROCEDURE ShowHelp (CONST problem : BYTE);
(* If any *foreseen* errors arise, we are sent here to
   give a little help and exit (relatively) peacefully *)
CONST
  progdesc = 'YATP v1.00 - Free DOS utility: Yet Another "Tree" Program.';
  author   = 'July 3, 1995.  Copyright (c) 1995 by David Daniel Anderson - Reign Ware.' + NL;
  usage    = 'Usage:  YATP [drive:][\][directory]' + NL;
  notes    = 'Notes:  All parameters are optional; output may be piped or redirected.' + NL;
  examples = 'Examples:' + NL;
  examp1   = '        YATP                   <- all directories below current';
  examp2   = '        YATP c:\               <- all directories on drive C:';
  examp3   = '        YATP d:\os2\           <- only directories below D:\OS2';
  examp4   = '        YATP c:\ | list /s     <- pipe C: tree to LIST' + NL;
VAR
  message : STRING [50];
BEGIN
  WriteLn (progdesc);
  WriteLn (author);
  WriteLn (usage);
  WriteLn (notes);
  WriteLn (examples);
  WriteLn (examp1);
  WriteLn (examp2);
  WriteLn (examp3);
  WriteLn (examp4);
  IF problem > 0 THEN BEGIN
    CASE problem OF
      1 : message := 'Invalid drive or directory.';
      ELSE  message := 'Unanticipated error of unknown type.';
    END;
    WriteLn (#7, message);
  END;
  Halt (problem)
END;

FUNCTION Format (Num : LONGINT) : STRING;      {converts Integer to String}
VAR NumStr : STRING;                           {& inserts commas as needed}
  l : SHORTINT;
BEGIN
  Str (Num, NumStr);
  l := (Length (NumStr) - 2);
  WHILE (l > 1) DO BEGIN
    Insert (',', NumStr, l);
    Dec (l, 3);
  END;
  Format := NumStr;
END;

FUNCTION OutputRedirected : BOOLEAN; (* FROM SWAG *)
VAR Regs : REGISTERS; Handle : WORD ABSOLUTE Output;
BEGIN
  WITH Regs DO
  BEGIN
    AX := $4400;
    BX := Handle;
    MsDos (Regs);
    IF DL AND $82 = $82 THEN OutputRedirected := FALSE
    ELSE OutputRedirected := TRUE;
  END; {With Regs}
END; {OutputRedirected}

PROCEDURE CheckForRedirection;
BEGIN
  IF OutputRedirected THEN BEGIN
    WriteLn ('YATP output has been redirected.');
    Assign (Output, '');
  END
  ELSE
    AssignCrt (Output);
  Rewrite (Output);
END;

FUNCTION DirExists (filename: PATHSTR): BOOLEAN;
VAR
  Attr : WORD;
  f    : FILE;
BEGIN
  Assign (f, filename);
  GetFAttr (f, Attr);
  IF (DosError = 0) AND ((Attr AND Directory) = Directory)
  THEN DirExists := TRUE
  ELSE DirExists := FALSE;
END;

PROCEDURE ReadParameters;
VAR
  Param   : STRING;
BEGIN
  IF (ParamCount > 1) THEN ShowHelp (0);
  Param := STRING (Ptr (PrefixSeg, $0080)^);
  WHILE (Param [0] > #0) AND (Param [1] = #32) DO Delete (Param, 1, 1);

  IF (Pos ('?', Param) <> 0) OR (Pos ('/', Param) <> 0) THEN ShowHelp (0);

  Param := FExpand (Param);                    { Set Var to param. String }
  IF Param [Length (Param) ] = '\' THEN
    Dec (Param [0]);                           { Remove trailing backslash}

  Dir := Param;

  IF (Length (Param) = 2) AND (Param [2] = ':') THEN
    Param := Param + '\';                      {add backslash to test ROOT}

  IF NOT DirExists (Param) THEN
    ShowHelp (1);
END;

FUNCTION GetClusterSize (drive : BYTE): WORD;  { SWAG routine }
VAR
  regs : REGISTERS;
BEGIN
  regs. CX := 0;         {set for error-checking just to be sure}
  regs. AX := $3600;     {get free space}
  regs. DX := drive;     {0=current, 1=a:, 2=b:, etc.}
  MsDos (regs);
  getclustersize := regs. AX * regs. CX;       {cluster size!}
END;

PROCEDURE InitGlobalVars;
BEGIN
  Dir       := '';                             { Init. global Vars.       }
  Loop      := TRUE;
  Level     := 0;
  tooDeep   := FALSE;
  Filetotal := 0;
  Bytetotal := 0;
  Dirstotal := 1;                              { Always have a root dir.  }
  ColorCnt  := 1;

  IF ParamCount > 0 THEN
    ReadParameters                             { Deal With any params.    }
  ELSE
    GetDir (0, Dir);

  TotalClusters := 0;
  ClusterSize := (GetClusterSize (Ord (UpCase (Dir [1])) - 64));
  IF ClusterSize = 0
  THEN ShowHelp (1);
END;

PROCEDURE DisplayHeader;
BEGIN
  WriteLn ('             File size   Files   Directory name');
  WriteLn ('═══════════════════════════════════════════════════════════════════════════════');
END;

PROCEDURE CalculateWaste (VAR SR: SEARCHREC);
BEGIN
  IF ((SR. Attr AND Directory) <> Directory)
     AND ((SR. Attr AND VolumeID) <> VolumeID)
  THEN BEGIN
    TotalClusters := TotalClusters + (Sr. Size DIV ClusterSize);
    IF ((Sr. Size MOD ClusterSize) <> 0) THEN Inc (TotalClusters, 1);
  END;
END;

PROCEDURE DisplayDir (DirP, DirN : STRING; Levl,
                     NumSubsVar2, SubNumVar2, NumSubsVar3, NmbrFil : INTEGER;
                     FilLen : LONGINT);

{NumSubsVar2 is the # of subdirs. in previous level;
 NumSumsVar3 is the # of subdirs. in the current level.
 DirN is the current subdir.; DirP is the previous path}

CONST
  Blank    = #32;
VAR
  BegLine,
  WrtStr,
  FlagStr : STRING;
  FlagIndex : BYTE;

BEGIN
  BegLine := '';                               { Init. Variables          }
  IF Levl > LevelMax THEN
  BEGIN
    tooDeep := TRUE;
    Exit;
  END;

  IF Levl = 0 THEN                             { Special handling For     }
    IF Dir = '' THEN                           { initial (0) dir. level   }
      WrtStr := 'ROOT'
    ELSE
      WrtStr := DirP
  ELSE
  BEGIN                                        { Level 1+ routines        }
    IF SubNumVar2 = NumSubsVar2 THEN           { if last node in subtree, }
    BEGIN                                      { use └─ symbol & set flag }
      BegLine     := '└─';                     { padded With blanks       }
      Flag [Levl] := Blank + Blank;
    END
    ELSE                                       { otherwise, use ├─ symbol }
    BEGIN                                      { & set flag padded With   }
      BegLine     := '├─';                     { blanks                   }
      Flag [Levl] := '│' + Blank;
    END;

    FlagStr := '';
    FOR FlagIndex := 1 TO Levl - 1 DO          { Insert │ & blanks as     }
      FlagStr := FlagStr + Flag [FlagIndex];   { needed, based on level   }
    BegLine := FlagStr + BegLine;

    WrtStr := BegLine + '──' + DirN;
    IF (NumSubsVar3 <> 0) THEN                 { if cur. level has subs   }
      IF Levl < LevelMax THEN                  { then change to "T" off   }
        WrtStr [Length (BegLine) + 1] := '┬'
      ELSE                                     { if levelMax, special end }
        WrtStr := WrtStr + '─>';               { to indicate more levels  }
  END;                                         { end level 1+ routines    }

  IF Odd (ColorCnt) THEN
    TextColor (15)
  ELSE
    TextColor (9);
  Inc (ColorCnt);

  WriteLn (Format (FilLen): 22, Format (NmbrFil): 8, '': 3, WrtStr)
                                               { Write # of Files & Bytes  }
END;

PROCEDURE ReadFiles (DirPrev, DirNext : STRING;
                     SubNumVar1, NumSubsVar1 : INTEGER);

VAR
  FileInfo  : SEARCHREC;
  FileBytes : LONGINT;
  NumFiles,
  NumSubs   : INTEGER;
  Dir_Ptr,
  CurPtr,
  FirstPtr  : FPtr;

BEGIN
  FileBytes := 0;
  NumFiles  := 0;
  NumSubs   := 0;
  Dir_Ptr   := NIL;
  CurPtr    := NIL;
  FirstPtr  := NIL;

  IF (DirNext = '') AND (DirPrev [Length (DirPrev) ] = '\') THEN
    Dec (DirPrev [0]);                         { Avoid double backslashes }
  IF Loop THEN
    FindFirst (DirPrev + DirNext + '\*.*', NonVLabel, FileInfo);
  Loop      := FALSE;                          { Get 1st File             }

  WHILE DosError = 0 DO                        { Loop Until no more Files }
  BEGIN
    IF (FileInfo. Name [1] <> '.') THEN
    BEGIN
      IF ((FileInfo. Attr AND Directory) = Directory) THEN
      BEGIN                                    { if fetched File is dir., }
        New (Dir_Ptr);                         { store a Record With dir. }
        Dir_Ptr^. DirName  := FileInfo. Name;  { name & occurence number, }
        Inc (NumSubs);                         { and set links to         }
        Dir_Ptr^. DirNum   := NumSubs;         { other Records if any     }
        IF CurPtr = NIL THEN
        BEGIN
          Dir_Ptr^. Next := NIL;
          CurPtr        := Dir_Ptr;
          FirstPtr      := Dir_Ptr;
        END
        ELSE
        BEGIN
          Dir_Ptr^. Next := NIL;
          CurPtr^. Next  := Dir_Ptr;
          CurPtr        := Dir_Ptr;
        END;
      END
      ELSE
      BEGIN                                    { Tally # of Bytes in File }
        FileBytes := FileBytes + FileInfo. Size;
        CalculateWaste (FileInfo);
        Inc (NumFiles);                        { Increment # of Files,    }
      END;                                     { excluding # of subdirs.  }
    END;
    FindNext (FileInfo);                       { Get next File            }
  END;    {end While}

  Bytetotal := Bytetotal + FileBytes;
  Filetotal := Filetotal + NumFiles;
  Dirstotal := Dirstotal + NumSubs;

  DisplayDir (DirPrev, DirNext, Level, NumSubsVar1, SubNumVar1,
  NumSubs, NumFiles, FileBytes);               { Pass info to & call      }
  Inc (Level);                                 { display routine, & inc.  }
                                               { level number             }

  WHILE (FirstPtr <> NIL) DO                   { if any subdirs., then    }
  BEGIN                                        { recursively loop thru    }
    Loop     := TRUE;                          { ReadFiles proc. til done }
    ReadFiles ((DirPrev + DirNext + '\'), FirstPtr^. DirName,
    FirstPtr^. DirNum, NumSubs);
    FirstPtr := FirstPtr^. Next;
  END;
                                               { Decrement level when     }
  Dec (Level);                                 { finish a recursive loop  }
                                               { call to lower level of   }
END;                                           { subdir.                  }

PROCEDURE WriteDriveInfo;
VAR DS, DF : LONGINT;   {bytes of *partition* space Size/Free}
  Disk : BYTE;
  Percent : STRING[6];
BEGIN
  Disk := (Ord (UpCase (Dir [1])) - 64);

  DS := DiskSize (Disk);
  IF (DS < 0) THEN BEGIN
    DS := 0;
    DF := 0;
  END
  ELSE
    DF := DiskFree (Disk);

  IF DS = 0
  THEN Percent := ('0.00')
  ELSE Str ((100 * (DF / DS)): 0: 2, Percent);

  WriteLn ('Free:  ', Format (DF): 15,
  ' bytes out of ', Format (DS),
  ' (', percent, '% of drive is unused)');
END;

PROCEDURE DisplayTally;
VAR
  WasteSpace,
  TotalSpace  : LONGINT;
BEGIN
  WriteLn ('═══════════════════════════════════════════════════════════════════════════════');
  WriteLn ('Totals:', Format (Bytetotal): 15, Format (Filetotal): 8, '(': 4, Dirstotal, ' directories)');

  TotalSpace := (TotalClusters * ClusterSize);
  WasteSpace := (TotalSpace - Bytetotal);
  WriteLn ('Using: ', Format (TotalSpace): 15,
  ' bytes altogether (based on ', ClusterSize, ' bytes per cluster)');
  Write   ('Making:', Format (WasteSpace): 15, ' bytes wasted (');
  IF Bytetotal = 0
  THEN Write ('0.00')
  ELSE Write (100 * (WasteSpace / TotalSpace): 0: 2);
  WriteLn ('% of the space used is wasted)');

  WriteDriveInfo;
END;

{  ┌────────────────────────────────────────────────────┐
   │ Main Program                                       │
   └────────────────────────────────────────────────────┘  }

BEGIN

  ClrScr;
  CheckForRedirection;                         { Get ready ...            }

  InitGlobalVars;                              { Get set ...              }

  TextColor (Cyan);
  DisplayHeader;                               { Display Header           }

  ReadFiles (Dir, '', 0, 0);                   { Go! do main read routine }

  TextColor (Cyan);
  DisplayTally;                                { Display totals           }

  IF tooDeep THEN
    WriteLn (NL, NL, '': 21, '» CANNOT DISPLAY MORE THAN ', LevelMax, ' LEVELS «', NL);
                                               { if ReadFiles detects > 16}
                                               { levels, tooDeep flag set }

END.                                           { Finish.                  }




                                 YATP v1.00
                  DOS utility: Yet Another "Tree" Program
                    Freeware, copyright (c) July 3, 1995
                                     by
                           David Daniel Anderson
                                 Reign Ware

                  ** READ REIGNWAR.TXT FOR LEGAL TERMS **



YATP is Yet Another "Tree" Program.  YATP displays the directory structure
of the drive and/ or directory that you specify, or if none is specified,
the drive and directory structure of the current directory is displayed.

Usage:  YATP [drive:][\][directory]

Notes:  All parameters are optional; output may be piped or redirected.

Examples:

        YATP                   <- all directories below current
        YATP c:\               <- all directories on drive C:
        YATP d:\os2\           <- only directories below D:\OS2
        YATP c:\ | list /s     <- pipe C: tree to LIST


Enter "YATP ?" to display this short reminder of the syntax.


                  ** READ REIGNWAR.TXT FOR LEGAL TERMS **



