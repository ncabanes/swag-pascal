(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0087.PAS
  Description: 4DOS File Descriptions
  Author: WILLEM DE VRIES
  Date: 02-28-95  09:47
*)


{ Please check below for the WINDOWS version of this code }
{$A+,B-,D+,E+,F-,G+,I+,L+,N+,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}

Unit D4Dos;
{
******************4DOS description functions****************
Written by: W. de Vries, dVELP Services
Target:     DOS real-mode
Date:       March 1994
Purpose:    Reading and modifying the 4DOS file descriptions
************************************************************

Usage: GetDescript(FileName / directoryname): String;
       Returns the description of the filename or directory name.
       Use a full path to specify the exact location of the file.
}

Interface
         Function GetDescript(Name:String):String;
         Function SetDescript(Name, Descript: String): Boolean;

Implementation
Uses DOS;

Function Upper(Str: String): String;
{Replace this function if you've got a faster one}

Var i: Integer;
Begin
    For i := 1 to Length(Str) do
        Str[i] := Upcase(Str[i]);
    Upper := Str;
end;

Function getDescriptFileName(Name: String): String;
{Internal function that gives the complete path of DESCRIPT.ION}
Var D: DirStr;
    N: NameStr;
    E: ExtStr;
    tmp: PathStr;
begin
     If Name='' then
     begin
        getDescriptFileName := '';
        exit;
     end;
     tmp := FExpand(Name);
     FSplit(tmp, D, N, E);
     Tmp:= D;
     getDescriptFileName:= tmp+'DESCRIPT.ION';
end;

Function GetName(Name: String): String;
{Returns only the filename without the path}

Var D: DirStr;
    N: NameStr;
    E: ExtStr;
    tmp: PathStr;
Begin
     If Name='' then
     begin
        getName := '';
        exit;
     end;
     tmp := FExpand(Name);
     FSplit(tmp, D, N, E);
     getName:= N+E;
end;

Function GetDescript(Name:String):String;
{Input: The path/name of a file
output: The 4DOS file description
        or '' if there is no description}

Var
    IOBuf: Array[0..2047] of Char; {2 Kb read-buffer}
    f: text;
    Regel, tmp: String;
    Found : Boolean;

Begin
     Found := False;
     Assign(f,GetDescriptFileName(Name));
     SetTextBuf(F, IOBuf);
     {$I-} Reset(f);{$I+}
     If IOResult <> 0 then
     begin
        GetDescript := '';
        exit;
     end;
     While (not Found) and (not eof(f)) do
     begin
           ReadLn(f, regel);
           Tmp := Copy(Regel, 1, Pos(' ', regel)-1);
           Found := Upper(Tmp) = Upper(GetName(Name));
     end;
     If Found then
     begin
       GetDescript := Copy(Regel, Pos(' ', Regel)+1, Length(Regel));
     end
     else
       GetDescript := '';
     Close(f);
end;

Function SetDescript(Name, Descript: String): Boolean;
{Input: the path/name of a file, the description of the file. Enter '' for
        the description to remove it.
Output: True if the description has been succesfully set, otherwise
        it is false.}


Type FileInfo=^FileRec;
    FileRec= Record
              FileName: String;
              Str: String;
              Next: FileInfo;
    end;

Var f: Text;
    IOBuf: Array[0..2047] of Char; {2 Kb read-buffer}
    BeginPtr, UsePtr, EndPtr: FileInfo;
    regel, tmp: String;
    FileFound: Boolean;

  Procedure ReadInfo;
  {Read all descriptions in a pointer-array}
  Begin
      {$I-} Reset(f); {$I+}
      FileFound := False;
      BeginPtr := nil;
      UsePtr := nil;
      EndPtr := nil;
      If (IOResult <> 0) or (eof(f)) then
      begin {The DESCRIPT.ION file does not exist: create a new one}
            {$I-} Rewrite(f);{$I+}
            if IOResult <> 0 then
                  exit;
            BeginPtr := New(FileInfo);{Create a new record}
            BeginPtr^.FileName := Upper(GetName(Name));
            BeginPtr^.Str := Descript;
            BeginPtr^.Next := nil;
            EndPtr := BeginPtr;
      end else
        While not eof(f) do
        begin
           Readln(f, regel);
           UsePtr := New(FileInfo); {just create a new record}
           tmp := Copy(Regel, 1, Pos(' ', regel)-1);
           UsePtr^.FileName := tmp;
           If Upper(tmp)=Upper(GetName(Name)) then
           begin
              FileFound := True;
              If Descript <> '' then
              begin
                 UsePtr^.FileName := getName(tmp); {File found in list, change it!}
                 UsePtr^.Str := Descript;
                 UsePtr^.Next := nil;
              end else
              begin
                 Dispose(UsePtr); {Description is NIL, remove the new record}
                 UsePtr := nil;
              end;
           end else
           begin
              UsePtr^.FileName := GetName(tmp);
              If Regel <> '' then
                  tmp :=Copy(Regel, Pos(' ', Regel)+1, Length(Regel))
              else
                  tmp := '';
              UsePtr^.Str := tmp;
              UsePtr^.Next := nil;
           end;

           If BeginPtr=nil then
           begin
              BeginPtr := UsePtr; {Created a new array}
              EndPtr := BeginPtr;      {Point the endpointer to the begin}
           end else
           begin
              EndPtr^.Next := UsePtr; {Stick the new record to the previous one}
              If UsePtr <> nil then
                 EndPtr := UsePtr;  {Point the EndPtr to the last record}
           end;
        end;
        If (not FileFound) and (Descript <> '') then
        begin
            UsePtr := New(FileInfo); {Create a new record}
            UsePtr^.FileName := Upper(getName(Name));
            UsePtr^.Str := Descript;
            UsePtr^.Next := nil;
            EndPtr^.Next := UsePtr;
            EndPtr := UsePtr;
        end;
        Close(f); {Close file}
  end;

  Function WriteInfo: Boolean;
  Begin
      SetFAttr(f, Archive); {Unhide the file}
      WriteInfo := True;
      {$I-} Rewrite(f); {$I+}
      If IOResult <> 0 then
      begin
         WriteInfo := False;
         Exit;
      end;
      If BeginPtr = nil then
      begin
           Close(f);   {No descriptions: delete file}
           Erase(f);
           exit;
      end;
      While BeginPtr <> nil do
      Begin
           Writeln(f, BeginPtr^.FileName, ' ', BeginPtr^.Str);
           UsePtr := BeginPtr;
           BeginPtr := UsePtr^.Next; {Move the begin-pointer 1 up}
           Dispose(UsePtr);      {Delete first record}
      end;
      Close(f);
      SetFAttr(f, Hidden); {Hide the DESCRIPT.ION file}
  end;

Begin
     SetDescript := False;
     If Name='' then
        Exit;                              {If there's no name specified:
quit}
     Assign(f, GetDescriptFileName(Name)); {Open DESCRIPT.ION}
     SetTextBuf(f, IOBuf);                 {create a 2Kb buffer}
     ReadInfo;                             {Read the descriptions}
     SetDescript := WriteInfo;             {Write the descriptions}
end;


Begin
end.


{   FOLLOWING IS THE WINDOWS SPECIFIC CODE FOR THIS UNIT !! }

{$A+,B-,D-,F-,G+,I+,K+,L-,N+,P-,Q+,R+,S+,T+,V+,W+,X+,Y-}

Unit W4Dos;
{******************4DOS description functions****************
Written by: W. de Vries, dVELP Services
Target:     Windows, DPMI
Date:       March 1994
Purpose:    Reading and modifying the 4DOS file descriptions
************************************************************}

Interface
         Function GetDescript(Name:PChar):PChar;
         Function SetDescript(Name, Descript: PChar): Boolean;

Implementation
Uses Windos, Strings, WinCrt;

Function getDescriptFileName(Name: PChar): PChar;
{Internal function that gives the complete path of DESCRIPT.ION}
Var D: array[0..fsDirectory] of Char;
    N: Array[0..fsFileName] of Char;
    E: Array[0..fsExtension] of Char;
    tmp: PChar;
begin
     If Name=nil then
     begin
        getDescriptFileName := nil;
        exit;
     end;
     GetMem(tmp, 256);
     FileExpand(tmp, Name);
     FileSplit(tmp, D, N, E);
     StrCopy(Tmp, D);
     StrCat(Tmp, 'DESCRIPT.ION');
     getDescriptFileName:= StrNew(Tmp);
end;

Function GetName(Name: PChar): PChar;
{Returns only the filename without the path}

Var D: Array[0..fsDirectory] of Char;
    N: Array[0..fsFileName] of Char;
    E: Array[0..fsExtension] of Char;
    tmp: PChar;
Begin
     If Name=nil then
     begin
        getName := nil;
        exit;
     end;
     GetMem(tmp, 256);
     FileExpand(tmp, Name);
     FileSplit(tmp, nil, N, E);
     StrCopy(Tmp, N);
     StrCat(tmp, E);
     getName:= StrNew(tmp);
     StrDispose(tmp);
end;


Function GetDescript(Name:PChar):PChar;
{Input: The path/name of a file
output: The 4DOS file description
        or NIL if there is no description}

Var
    IOBuf: Array[0..2047] of Char; {2 Kb read-buffer}
    f: text;
    Regel: String;
    tmp: PChar;
    Found : Boolean;

Begin
     Found := False;
     GetMem(tmp, 256);
     Assign(f,GetDescriptFileName(Name));
     SetTextBuf(F, IOBuf);
     {$I-} Reset(f);{$I+}
     If IOResult <> 0 then
     begin
        GetDescript := nil;
        StrDispose(Tmp);
        exit;
     end;
     While (not Found) and (not eof(f)) do
     begin
           ReadLn(f, regel);
           StrPCopy(Tmp, Copy(Regel, 1, Pos(' ', regel)-1));
           Found := StrIComp(tmp,GetName(Name))=0;
     end;
     If Found then
     begin
       GetDescript := StrNew(StrPCopy(tmp, Copy(Regel, Pos(' ', Regel)+1, Length(Regel))));
     end
     else
       GetDescript := nil;
     Close(f);
     StrDispose(tmp);
end;

Function SetDescript(Name, Descript: PChar): Boolean;
{Input: the path/name of a file, the description of the file. Enter NIL for
        the description to remove it.
Output: True if the description has been succesfully set, otherwise
        it is false.}


Type FileInfo=^FileRec;
    FileRec= Record
              FileName:PChar;
              Str: PChar;
              Next: FileInfo;
    end;

Var f: Text;
    IOBuf: Array[0..2047] of Char; {2 Kb read-buffer}
    BeginPtr, UsePtr, EndPtr: FileInfo;
    regel: String;
    tmp: Array[0..255] of Char;
    FileFound: Boolean;

  Procedure ReadInfo;
  {Read all descriptions in a pointer-array}
  Begin
      If Descript <> nil then
         If StrIComp(Descript, '') = 0 then
            Descript := nil;
      FileFound := False;
      BeginPtr := nil;
      UsePtr := nil;
      EndPtr := nil;
      {$I-} Reset(f); {$I+}
      If (IOResult <> 0) or (eof(f)) then
      begin {The DESCRIPT.ION file does not exist: create a new one}
            {$I-} Rewrite(f); {$I+}
            If IOResult <> 0 then
               Exit;
            BeginPtr := New(FileInfo);{Create a new record}
            BeginPtr^.FileName := StrNew(StrUpper(GetName(Name)));
            BeginPtr^.Str := StrNew(Descript);
            BeginPtr^.Next := nil;
            EndPtr := BeginPtr;
            FileFound := True;
      end else

        While not eof(f) do
        begin
           Readln(f, regel);
           UsePtr := New(FileInfo); {just create a new record}
           StrPCopy(tmp, Copy(Regel, 1, Pos(' ', regel)-1));
           UsePtr^.FileName := StrNew(GetName(tmp));
           If StrIComp(tmp, GetName(Name))=0 then
           begin  {File found in list, change it!}
              FileFound := True;
              If Descript <> nil then
              begin
                 UsePtr^.Str := StrNew(Descript);
                 UsePtr^.Next := nil;
              end else
              begin
                 Dispose(UsePtr); {Description is NIL, remove the new record}
                 UsePtr := nil;
              end;
           end else
           begin
              If Regel <> '' then
                  StrPCopy(tmp, Copy(Regel, Pos(' ', Regel)+1, Length(Regel)))
              else
                  tmp[0] := #0;
              UsePtr^.Str := StrNew(tmp);
              UsePtr^.Next := nil;
           end;

           If BeginPtr=nil then
           begin
              BeginPtr := UsePtr; {Created a new array}
              EndPtr := BeginPtr;      {Point the endpointer to the begin}
           end else
           begin
              EndPtr^.Next := UsePtr; {Stick the new record to the previous}
              If UsePtr <> nil then
                 EndPtr := UsePtr;  {Point the EndPtr to the last record}
           end;
        end;

        If (not FileFound) and (Descript <> nil) then
        begin
            UsePtr := New(FileInfo); {Create a new record}
            UsePtr^.FileName := StrNew(StrUpper(getName(Name)));
            UsePtr^.Str := StrNew(Descript);
            UsePtr^.Next := nil;
            EndPtr^.Next := UsePtr;
            EndPtr := UsePtr;
        end;
      Close(f); {Close file}
  end;

  Function WriteInfo: Boolean;
  Begin
      SetFAttr(f, faArchive); {Unhide the file}
      WriteInfo := True;
      {$I-} Rewrite(f); {$I+}
      If IOResult <> 0 then
      begin
         WriteInfo := False;
         Exit;
      end;
      If BeginPtr=nil then
      begin
           Close(f);   {No descriptions: delete file}
           Erase(f);
           exit;
      end;
      While BeginPtr <> nil do
      Begin
           Writeln(f, BeginPtr^.FileName, ' ', BeginPtr^.Str);
           UsePtr := BeginPtr;
           BeginPtr := UsePtr^.Next; {Move the begin-pointer 1 up}
           Dispose(UsePtr);      {Delete first record}
      end;
      Close(f);
      SetFAttr(f, faHidden); {Hide the DESCRIPT.ION file}
  end;

Begin
     SetDescript := False;
     If (Name=nil) or (StrIComp(Name, '')=0) then
        Exit;                              {If there's no name specified: quit}
     Assign(f, GetDescriptFileName(Name)); {Open DESCRIPT.ION}
     SetTextBuf(f, IOBuf);                 {create a 2Kb buffer}
     ReadInfo;                             {Read the descriptions}
     SetDescript := WriteInfo;             {Write the descriptions}
end;


Begin
end.

