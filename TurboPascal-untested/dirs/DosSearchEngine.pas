(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0028.PAS
  Description: DOS Search Engine
  Author: SWAG SUPPORT TEAM
  Date: 02-15-94  08:41
*)

UNIT Engine;

{$V-}

(**************************************************************************)
(* SEARCH ENGINE                                                          *)
(*        Input Parameters:                                               *)
(*              Mask  : The file specification to search for              *)
(*                      May contain wildcards                             *)
(*              Attr  : File attribute to search for                      *)
(*              Proc  : Procedure to process each found file              *)
(*                                                                        *)
(*        Output Parameters:                                              *)
(*              ErrorCode  : Contains the final error code.               *)
(**************************************************************************)

(************************)
(**)   INTERFACE      (**)
(************************)

USES DOS;

TYPE
    ProcType     = PROCEDURE (VAR S : SearchRec; P : PathStr);
    FullNameStr  = STRING[12];

    PROCEDURE SearchEngine(Mask : PathStr; Attr : Byte; Proc : ProcType; VAR ErrorCode : Byte);

    FUNCTION GoodDirectory(S : SearchRec) : Boolean;
    PROCEDURE ShrinkPath(VAR path   : PathStr);
    PROCEDURE ErrorMessage(ErrCode  : Byte);
    PROCEDURE SearchEngineAll(path  : PathStr; Mask : FullNameStr; Attr : Byte; Proc : ProcType; VAR ErrorCode : Byte);

    (************************)
    (**) IMPLEMENTATION   (**)
    (************************)

VAR
    EngineMask : FullNameStr;
    EngineAttr : Byte;
    EngineProc : ProcType;
    EngineCode : Byte;

    PROCEDURE SearchEngine(Mask : PathStr; Attr : Byte; Proc : ProcType; VAR ErrorCode : Byte);

    VAR
       S : SearchRec;
       P : PathStr;
       Ext : ExtStr;

    BEGIN
       FSplit(Mask, P, Mask, Ext);
       Mask := Mask + Ext;
       FindFirst(P + Mask, Attr, S);
       IF DosError <> 0 THEN
          BEGIN
               ErrorCode := DosError;
               Exit;
          END;

    WHILE DosError = 0 DO
          BEGIN
               Proc(S, P);
               FindNext(S);
          END;
    IF DosError = 18 THEN ErrorCode := 0
    ELSE ErrorCode := DosError;
END;

FUNCTION GoodDirectory(S : SearchRec) : Boolean;
BEGIN
    GoodDirectory := (S.name <> '.') AND (S.name <> '..') AND (S.Attr AND Directory = Directory);
END;

PROCEDURE ShrinkPath(VAR path : PathStr);
VAR P : Byte;
    Dummy : NameStr;
BEGIN
    FSplit(path, path, Dummy, Dummy);
    Dec(path[0]);
END;

{$F+} PROCEDURE SearchOneDir(VAR S : SearchRec; P : PathStr); {$F-}
      {Recursive procedure to search one directory}
BEGIN
    IF GoodDirectory(S) THEN
       BEGIN
            P := P + S.name;
            SearchEngine(P + '\' + EngineMask, EngineAttr, EngineProc, EngineCode);
            SearchEngine(P + '\*.*',Directory OR Archive, SearchOneDir, EngineCode);
       END;
END;

PROCEDURE SearchEngineAll(path : PathStr; Mask : FullNameStr; Attr : Byte; Proc : ProcType; VAR ErrorCode : Byte);

BEGIN
    (* Set up Unit global variables for use in recursive directory search procedure *)
    EngineMask := Mask;
    EngineProc := Proc;
    EngineAttr := Attr;
    SearchEngine(path + Mask, Attr, Proc, ErrorCode);
    SearchEngine(path + '*.*', Directory OR Attr, SearchOneDir, ErrorCode);
    ErrorCode := EngineCode;
END;

PROCEDURE ErrorMessage(ErrCode : Byte);
BEGIN
    CASE ErrCode OF
         0 : ;                              {OK -- no error}
         2 : WriteLn('File not found');
         3 : WriteLn('Path not found');
         5 : WriteLn('Access denied');
         6 : WriteLn('Invalid handle');
         8 : WriteLn('Not enough memory');
         10 : WriteLn('Invalid environment');
         11 : WriteLn('Invalid format');
         18 : ;                    {OK -- merely no more files}
    ELSE WriteLN('ERROR #', ErrCode);
    END;
END;


END.


{ ===============================   DEMO     ==============================}

{$R-,S+,I+,D+,F-,V-,B-,N-,L+ }
{$M 2048,0,0 }
PROGRAM DirSum;
        (*******************************************************)
        (* Uses SearchEngine to write the names of all files   *)
        (* in the current directory and display the total disk *)
        (* space that they occupy.                             *)
        (*******************************************************)
USES DOS,ENGINE;

VAR
   Template  : PathStr;
   ErrorCode : Byte;
   Total     : LongInt;

{$F+} PROCEDURE WriteIt(VAR S : SearchRec; P : PathStr);  {$F-}
BEGIN   WriteLn(S.name); Total := Total + S.Size END;

BEGIN
     Total := 0;
     GetDir(0, Template);
     IF Length(Template) = 3 THEN Dec(Template[0]);
     {^Avoid ending up with "C:\\*.*"!}
     Template := Template + '\*.*';
     SearchEngine(Template, AnyFile, WriteIt, ErrorCode);
     IF ErrorCode <> 0 THEN ErrorMessage(ErrorCode) ELSE
        WriteLn('Total size of displayed files: ', Total : 8);
END.

