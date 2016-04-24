(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0207.PAS
  Description: DBase file management
  Author: DAVID HOOPER
  Date: 01-02-98  07:34
*)

unit DBaseDB;
{$V-,S-,R-}
{              ***************24/10/97*****************
               *This UNIT was created by DAVID HOOPER*
               *for general use, can use filelocking *
               *A record level locking version will  *
               *be available soon. Both going to SWAG*
               *          loki1@ihug.co.nz           *
               *  http://homepages.ihug.co.nz/~loki1 *
               ***************************************}

interface
uses Dos; {, MyDBase;}
type
    string30 = string[30];
{****NB:****  To use custom records:
     The Simple Way:- Do a SEARCh and REPLACE for DBase and replace it
       with your database name, (max 6 letters) eg. PLAYER or USERS
       also edit the DBaseRec (PLAYERRec) and put your own fields in.

     The other way :-
              make a simple unit that has just the record structure
              DBaseRec, and also the Vars
              DBase: DBaseRec;
              DBaseFile: File of DBaseRec;
              and include the USES Dos, MyDBase line (where MyDBase
              is the unit with your structures in it)
              then delete them from this unit

    An Example of using this DBase is at the end of this file}
    MemoType = Record
                 Memo_Date: string[15];
                 Memo_Line: string;
               End;
    DBaseRec = Record             {this is an example, make your own}
                 Deleted: boolean;{delete DBaseFINDDELD if u delete this}
                 Name: string30;  {delete DBaseFINDNAME if u delete this}
                 Age: byte;
                 Memo: array[1..10] of MemoType;
                End;
Var
  {GLOBAR VARIABLES}
   DBase : DBaseRec;
   DBaseFile : File of DBaseRec;
   OldFileMode : integer;
   RecFoundAT: word; {where was the searched for record found}

function FILEEXISTS(PathAndFile: string):Boolean;
function  DBaseOPEN(Path, FileName: string; fm: byte): Boolean;
procedure DBaseCLOSE;
procedure DBaseREAD(var DBase: DBaseRec);  {not normally used by user}
function  DBaseSEEK(Rec: word) : boolean;  {not normally used by user}
function  DBaseGET(var DBase: DBaseRec; Rec: word) :Boolean;{uses above 2}
procedure DBaseADD(var DBase: DBaseRec);
procedure DBaseEDIT(var DBase: DBaseRec);
function  DBaseCREATEFIRST(Path, FileName: string; fm: byte;
                               var DBase: DBaseRec): Boolean;
function  DBaseFINDNAME(var DBase: DBaseRec; InName: string30): Boolean;
function  DBaseFINDDEL(var DBase: DBaseRec): Boolean;
procedure DBaseSORT;

implementation


{***********************************
 *Opens the DBase file and returns *
 *TRUE if successful               *
 *fm= filemode:- 0=read, 2= write  *
 *64=read&share, 66=write&share    *
 ***********************************}
function FILEEXISTS(PathAndFile: string):Boolean;
var F: File;
begin
  assign(F,PathAndFile);
{$I-}
  reset(f);
{$I+}
  if ioresult = 0 then
  begin
    close(f);
    fileExists := true;
  end
  else
  fileExists := false;
end;

function DBaseOPEN(Path, FileName: string; fm: byte): Boolean;
var S: string;
 IsOK: Boolean;
begin
 S := FSearch(FileName,Path); {check it exists}
 IsOK := True;
 if ((fm = 0) or (fm = 64)) then IsOk := FILEEXISTS(Path+FileName);
 if IsOK then
 begin
  {$I-}
  OldFileMode := filemode;
  filemode := fm;
  Assign(DBaseFILE , Path+FileName);
  Reset(DBaseFILE);
  IsOK := (ioresult = 0);
  {$I+}
 end;
 if (not IsOK) then filemode := OldFileMode;
 DBaseOPEN := IsOK;
end;

{************************
 *Closes the DBase file *
 ************************}
procedure DBaseCLOSE;
begin
 CLOSE(DBaseFILE);
 filemode := OldFileMode;
end;

{***********************************
 *Seeks to a specific record number*
 *0 to end of file. Will return a  *
 *True if REC is within the range  *
 *Normally not used by user, but   *
 *here if needed                   *
 ***********************************}
function DBaseSEEK(Rec: word) : boolean;
begin
 if (((Rec+1) <= (FileSize(DBaseFILE))) and (Rec >=0)) then
 begin
  Seek(DBaseFILE, Rec);
  DBaseSEEK := True;
 end
 else DBaseSEEK := False;
end;

{**************************************
 *Simply Reads the next record.       *
 *Again, normally only used internally*
 *by other functions and procedures   *
 *such as DBaseGET, after range check *
 **************************************}
procedure DBaseREAD(var DBase: DBaseRec);
begin
 Read(DBaseFILE , DBase);
end;

{**************************************
 *Seeks to Rec with range checking    *
 *Reads in the record and returns and *
 *returns TRUE if successful or FALSE *
 *if Rec was out of range             *
 **************************************}
function DBaseGET(var DBase: DBaseRec;Rec: word) : boolean;
var IsOK: boolean;
begin
 IsOK := DBaseSEEK(Rec);
 if IsOK then DBaseREAD(DBase);
 DBaseGET := IsOK;
end;

{************************************************
 *Writes the DBase record to the current        *
 *Record number. This is usually called         *
 *like thius:-                                  *
 *If DBaseSeek(Rec_Number) then EDITDBase(DBase)*
 ************************************************}
procedure DBaseEDIT(var DBase: DBaseRec);
begin
 write(DBaseFILE, DBase);
end;

{************************************************
 *Writes a new record to the end of the database*
 ************************************************}
procedure DBaseADD(var DBase: DBaseRec);
begin
 RESET(DBaseFile);  {this line can be removed}
 SEEK(DBaseFILE, filesize(DBaseFile));
 DBaseEDIT(DBase);
end;

{*********************************************************
 *An alternate to automatically making a new file        *
 *If it does not exist.(eg. may just be a wrong          *
 *path. An example of calling this is :-                 *
 *if (NOT OPENDBase('C:\DATA\','MyDBase.DAT',2))         *
 *  then CREATEFIRSTDBase('C:\DATA\'MyDBase.Dat', DBase);*
 *the filemode that is passed, is used to reopen the file*
 *after it has been created. First record written assumes*
 *SharingWrite 66                                        *
 *********************************************************}
function DBaseCREATEFIRST(Path, FileName: string; fm: byte;
                               var DBase: DBaseRec):boolean;
begin
  {$I-}
  OldFileMode := filemode;
  filemode := 66;
  Assign(DBaseFILE , Path+FileName);
  Rewrite(DBaseFILE);
  {$I+}
 if ioresult <>0 then
 begin
   DBaseCREATEFIRST := False;
   exit;
 end;
 DBaseEDIT(DBase);
 close(DBaseFile);
 DBaseCREATEFIRST := DBaseOPEN(Path, FileName, fm);
end;

{*********************************************
 *Finds a name, and returns the record number*
 *in RecFoundAt, and a TRUE, else            *
 *RecFoundAt = 0, and function returns FALSE *
 *********************************************}
function  DBaseFINDNAME(var DBase: DBaseRec; InName: string30): Boolean;
var L1, UCLoop: word;
    found: boolean;
    TBName, TIName: string30;
begin
 L1 := 0;
 found := False;
 for UCLoop := 1 to length(InName) do InName[UCLoop] := upcase(InName[UCLoop]);
 while ((L1 < filesize(DBaseFile)) and (not found)) do
 begin
  if (DBaseGET(DBase, L1)) then
    TBName := DBase.Name;
    for UCLoop := 1 to length(TBName) do TBName[UCLoop] := upcase(TBName[UCLoop]);
     if ((TBName = InName) and (not DBase.deleted)) then found := true
     else found := false;
  if not found then inc(L1);
 end;

 if Found then
 begin
   RecFoundAt := L1;
   DBaseSEEK(L1);
   DBaseFINDNAME := TRUE;
 end
 else
 begin
   RecFoundAt := 0;
   DBaseFINDNAME := FALSE;
 end;
end;

{*********************************************
 *Finds the first Deleted (empty) record.    *
 *ie. DBase.Deleted := TRUE. returns record #*
 *in RecFoundAt, and a TRUE, else            *
 *RecFoundAt = 0, and function returns FALSE *
 *********************************************}
function  DBaseFINDDEL(var DBase: DBaseRec): Boolean;
var L1: word;
 found: boolean;
begin
 L1 := 0;
 found := False;
 while ((L1 < filesize(DBaseFile)) and (not found)) do
 begin
  if (DBaseGET(DBase, L1)) then found := (DBase.Deleted = True);
  if not found then inc(L1);
 end;
 if Found then
 begin
   RecFoundAt := L1;
   DBaseSEEK(L1);
   DBaseFINDDEL := TRUE;
 end
 else
 begin
   RecFoundAt := 0;
   DBaseFINDDEL := FALSE;
 end;
end;

PROCEDURE DBaseSORT;
var SORTLOOP: word;
    TempDBase: DBaseRec;
    DidSort: boolean;     {flag eg. why continue sorting when sorted?}
    count, endcount: integer;
begin
  count := 0;
  endcount := FileSize(DBaseFILE)-3;
  {-2(-3) because we do +1 in the search}
  DidSort := TRUE; {set true for first sort}
  while (DidSort AND (count <= endcount)) do
  begin
    DidSort := FALSE;
    for SortLoop := 0 to (FileSize(DBaseFILE)-(1+Count)) do
    begin
      DBaseGET(DBase, SortLoop);
      TempDBase := DBase;
      DBaseGET(DBase, SortLoop+1);
      if ((TempDBase.Name > DBase.Name) or (TempDBase.Deleted)) then
      {swap order, put deleted at end}
      begin
        DidSort := TRUE;                {Swapping part, uses a temp record}
        DBaseSEEK(SortLoop);
        write(DBaseFILE, DBase);
        DBaseSEEK(SortLoop+1);
        write(DBaseFILE, TempDBase);
      end;
    end; {of SortLoop}
    Count := Count + 1;
  end; {of while loop}
end;


begin
end.


(*  EXAMPLE OF USING THE DBASEDB UNIT
program TESTDB(input, output);
uses DBASEDB;
var
   Loop1: word; {only used for example}

begin
  if not FILEEXISTS('C:\TESTDB.DAT') then {no database made yet}
  begin
    DBase.Deleted := False;
    DBase.Name := 'First Person';
    DBase.Age := 27;
    DBase.Memo[1].Memo_Date := '27/10/97';
    DBase.Memo[1].Memo_Line := 'Meeting went well...';

    DBaseCREATEFIRST('C:\','TESTDB.DAT',66, DBase); {make the new database}
  end
  else {the database file DOES exist}
    DBaseOpen('C:\','TESTDB.DAT',66);{so open it}

    DBase.Deleted := False;
    DBase.Name := 'Joe Bloggs';
    DBase.Age := 23;
    DBase.Memo[1].Memo_Date := '23/10/97';
    DBase.Memo[1].Memo_Line := 'didn''t show for Meeting';
    DBaseADD(DBase); {ADD THIS RECORD}

    DBase.Deleted := False;
    DBase.Name := 'Fred Flintstone';
    DBase.Age := 47;
    DBase.Memo[1].Memo_Date := '29/11/97';
    DBase.Memo[1].Memo_Line := 'bought a new car';
    DBase.Memo[2].Memo_Date := '30/11/97';
    DBase.Memo[2].Memo_Line := 'crashed the new car';
    DBaseADD(DBase); {ADD THIS RECORD}

    writeln('There are ',filesize(DBaseFile),' records');
    for Loop1 := 0 to filesize(DBaseFile)-1 do  {-1 because first record}
    begin                                       {is record 0 (zero)     }
      DBaseGet(DBase, Loop1);
      with DBase do
      begin
        Writeln('Record: ',Loop1);
        Writeln(Name,'   ',Age);
      end;
    end;
   if DBaseFINDNAME(DBase, 'Fred Flintstone') then
   begin
     writeln('First name matching ''Fred Flintstone'' found at ',RecFoundAt);
     DBaseGet(DBase, RecFoundAt);        {or simply DBaseREAD(DBASE); since}
     Writeln(DBase.Name,'   ',DBase.Age);{FINDNAME Seeks to the start of it}
   end
   else writeln ('''Fred Flintstone'' not found');
   DBaseClose;
end.
*)

