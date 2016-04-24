(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0048.PAS
  Description: Change File Extensions
  Author: GAYLE DAVIS
  Date: 02-03-94  16:18
*)

{$S-,V-,R-,F+}

PROGRAM REX;

 { Rename all files matching one extension with another
   CAUTION !!!  This program will rename FILES !!!!!!!!
   Takes to parameters : Ext1(current) and Ext2(whatever)
   i.e.   *.XXX to *.PAS or *.MOD to *.INT
   Uses some of the routines from EDDY THILLEMAN'S recursive directory roam
   whice can be found in the SWAG distribution
   Gayle Davis 1/26/94 }

USES DOS, CRT;

TYPE
    ProcessType = PROCEDURE (Path : PathStr; FR : SearchRec);

CONST
    NotGoodFile : WORD = Directory + Hidden + Readonly + VolumeID + Sysfile;

VAR
     Ext1 : Pathstr;
     Ext2 : Pathstr;
     ExitSave : POINTER;

PROCEDURE Frename (SourceFile, TargetFile : STRING; VAR ErrCode : BYTE);
VAR
  reg : REGISTERS;
BEGIN                                   { Frename }
  SourceFile := CONCAT (SourceFile, #0);
  TargetFile := CONCAT (TargetFile, #0);
  reg.ds := SEG (SourceFile [1]); reg.dx := OFS (SourceFile [1]);
  reg.es := SEG (TargetFile [1]); reg.di := OFS (TargetFile [1]);
  reg.ah := $56;
  MSDOS (reg);
  ErrCode := 0;
  IF (reg.flags AND FCarry) = 1 THEN ErrCode := reg.ax;
END;                                    { Frename }

PROCEDURE DoitHere (Path : PathStr; FR : SearchRec); FAR;
VAR
   Name1,
   Name2 : PathStr;
   D     : PathStr;
   N     : NameStr;
   E     : ExtStr;
   Err   : BYTE;

BEGIN
IF (FR.Attr AND NotGoodFile) <> 0 THEN EXIT;
FSplit(FR.Name, D, N, E);
Name1 := Path + FR.Name;
Name2 := Path + N + Ext2;
WRITELN (Name1, ' ', Name2);
FRename(Name1,Name2,Err);
END;

FUNCTION Wildcard (Name : PathStr) : BOOLEAN ;

BEGIN
Wildcard := (POS ('*', Name) <> 0) OR (POS ('?', Name) <> 0) AND (POS('.',Name) > 0);
END ;


Procedure PathAnalyze (P: PathStr; Var D: DirStr; Var Name: NameStr);
Var
  N: NameStr;
  E: ExtStr;

begin
  FSplit(P, D, N, E);
  Name := N + E;
end;

PROCEDURE FindFiles (fMask : PathStr; fAttr : WORD; Process : ProcessType);
VAR
  FR   : SearchRec;
  Path : PathStr;
  Mask : NameStr;

BEGIN
  PathAnalyze(fMask,Path,Mask);
  FINDFIRST (FMask, FAttr, FR);
  WHILE DosError = 0 DO
  BEGIN
    Process (Path,FR);
    FINDNEXT (FR);
  END;
END;

PROCEDURE ExitHandler; FAR;
  { Return the cursor to its original shape }
  BEGIN
  ExitProc := ExitSave
  END;


BEGIN
ExitSave := ExitProc;
ExitProc := @ExitHandler;
ClrScr;
IF PARAMCOUNT < 2 THEN
   BEGIN
   WriteLn('REX : Rename all files matching Ext1 to Ext2');
   WRITELN('Needs 2 Parameters ..   *.ext1  *.ext2');
   HALT;
   END;
Ext1 := ParamStr(1);
Ext2 := ParamStr(2);
IF NOT WildCard(Ext1) THEN HALT;  { must contain a wildcard }
IF NOT WildCard(Ext2) THEN HALT;
Ext2 := COPY(Ext2,POS('.',Ext2),$FF);  { only want the extension }
FindFiles (Ext1, Anyfile, DoitHere);
END.
