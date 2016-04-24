(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0059.PAS
  Description: Sort a data file on disk
  Author: MARIO POLYCARPOU
  Date: 11-22-95  13:26
*)


{$A+,B-,D-,E-,F-,G+,I-,K-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,W-,X-,Y-}

{Sorts a data file on disk}

{*WARNING*: This program will create two .5Mb files for test
 purposes. Reduce the constant "Max" to about 100 if you only
 want a quick look at the program.}

PROGRAM DiskSort;
USES  Dos;                          {For start/stop time}
CONST Max=1000;                     {Number of records}
TYPE  OneRecord=RECORD              {550 bytes}
                 S:String[20];      {The sorted field}
                 W:Word;            {Some other fields..}
                 B:Byte;
                 I:Integer;
                 R:Real;
                 P:Pointer;
                 L:LongInt;
                 X:String;
                 Y:String;
                END;
 
      FileType=File OF OneRecord;
{------------------------------------------------}
{This routine creates the data file and writes
 randomly generated records in it for testing.}
 
PROCEDURE CreateDataFile(FileName:String);
VAR This:OneRecord; F:FileType; N,X,C:Integer;
BEGIN
 Assign(F,FileName); Rewrite(F);
 FOR N:=1 TO Max DO
  BEGIN
   FillChar(This,SizeOf(This),#0);
   FOR X:=1 TO 20 DO
    BEGIN
     REPEAT
      C:=Random(100);
     UNTIL C IN [65..90];
     This.S:=This.S+Chr(C);
    END;
   Write(F,This);
  END; Close(F);
END;
{------------------------------------------------}
{This routine sorts the data file and puts the sorted
 records in the temp file.}

PROCEDURE SortDataFile(FileName,TempName:String);
VAR Old,This,Saved,Temp:OneRecord; F1,F2:FileType;
    N1,N2,N3:LongInt; SavedStr:String[20];
 {-----------------------------------------------}
 PROCEDURE CheckIt;  {comparison routine}
  BEGIN
   IF This.S<SavedStr THEN
    BEGIN
     SavedStr:=This.S;
     Temp:=This; This:=Saved; Saved:=Temp;
     N3:=Pred(FilePos(F1));
    END;
  END;
 {-----------------------------------------------}
BEGIN
 Assign(F1,FileName); Reset(F1);
 Assign(F2,TempName); Rewrite(F2);
 N1:=0; N2:=FileSize(F1); N3:=0;
 REPEAT
  Seek(F1,N1); Read(F1,Old);
  SavedStr:=Old.S; This:=Old; Saved:=Old;
  WHILE NOT EOF(F1) DO
   BEGIN CheckIt; Read(F1,This); END;
  CheckIt;
  Seek(F1,N3); Write(F1,Old);
  Seek(F2,FileSize(F2)); Write(F2,Saved);
  Inc(N1);
 UNTIL N1>=N2;
 Close(F1); Close(F2);
END;
{------------------------------------------------}
VAR S1,S2:String; H,M,S,U:Word;
BEGIN
 Randomize;
 S1:='MIXED.DAT'; S2:='SORTED.DAT';
 Writeln;
 Writeln('Creating the data file ',S1);
 CreateDataFile(S1);
 Writeln;
 Writeln('Now sorting it as ',S2);
 GetTime(H,M,S,U);
 Writeln('Start : ',H,':',M,':',S,'.',U);
 SortDataFile(S1,S2);
 GetTime(H,M,S,U);
 Writeln('Stop  : ',H,':',M,':',S,'.',U);
END.

