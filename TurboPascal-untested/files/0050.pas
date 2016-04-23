{*************************************************************************
 *                    LOW LEVEL FILE READING OBJECT                      *
 *                                                                       *
 *                      Copyright 1992 Tom Clancy                        *
 *                                                                       *
 *   Description:                                                        *
 *                                                                       *
 *        This library allows you to create a file of any type record    *
 *   by passing in the record size.  You must also pass in a record of   *
 *   the same type that the object has been initialized with so that     *
 *   you don't get errors when reading and writing.                      *
 *                                                                       *
 *        There is no internal buffering, but the routines are fairly    *
 *   fast and because each file is actually an object, you can create    *
 *   higher level objects of this object type that allow more            *
 *   flexibility, such as indexing and sorting.                          *
 *                                                                       *
 *************************************************************************}

{$I-}   {Turn off I/O checking}
{$S-}   {Turn off Stack checking}
{$R-}   {Turn off Range checking}
{$V-}   {No strict VAR string checking allowed here!}

Unit FileRead;

Interface

Const

   Open       = 1;
   Create     = 2;
   OpenCreate = 3;

Type

   TFreadPtr = ^TFreadObj;
   TFreadObj = Object
     Constructor Init(fn : string; mode:integer; recsize : longint);
     Destructor  Done;

     { random access methods. }
     Procedure   ReadRec(var frec; fpos:longint);  virtual;
     Procedure   WriteRec(var frec; fpos:longint); virtual;

     { sequential access methods. }
     Procedure   AppendRec(var frec);
     Procedure   ReadNext(var frec);
     Procedure   ReadPrevious(var frec);
     Procedure   ReadCurrent(var frec);

     { various file modification methods. }
     Procedure   EraseFile;
     Function    RenameFile(fn:string):boolean;

     { miscellaneous functions and error flag functions. }
     Procedure   Rewind;
     Function    NumRecs     : Longint;
     Function    GetFilename : String;
     Function    GetCurrent  : Longint;
     Function    OpenError   : boolean;
     Function    ReadError   : boolean;
     Function    WriteError  : boolean;

   private
     Ifile       : File;     {file variable}
     Rsize       : Longint;  {the internal record size}
     FileName    : String;   {physical file name}
     Oerror,                 {open error flag}
     Rerror,                 {read error flag}
     Werror      : Boolean;  {write error flag}
     Current     : Longint;  {current file pointer location}

     { methods used internally.  No access allowed! }
     Procedure   OpenFile;
     Procedure   CreateFile;
     Procedure   CloseFile;
   end;

Function Exist(fn:string):Boolean;

Implementation

uses
  Dos;

{ Pass in a string which contains a file name to see if that file exists.}
Function Exist(fn:string):Boolean;
Var
   DirInfo : SearchRec;
Begin
  FindFirst(fn,Archive,DirInfo);
  Exist:=DosError=0;
End;

{
    Initialize the object.

    Fn    = File name
    Mode  = Open, Create, or OpenCreate
      - Open will try to open the file.  An error is set if the file does not
        exist.
      - Create will create the file regardless if it's there or not.
      - OpenCreate will attemp to open the file first, then create it if it's
        not there.
    RecSize = The size of the records that the file will contain.
      - Use Sizeof(Rec) for safety.
}
Constructor TFreadObj.Init(fn:string; mode:integer; recsize:longint);
Begin
  Oerror:=true;
  Rerror:=false;
  Werror:=false;
  Rsize:=recsize;
  FileName := fn;
  Assign(Ifile,FileName);
  case mode of
    Open       : openfile;
    Create     : createfile;
    OpenCreate :
      begin
        OpenFile;
        if Oerror then
          CreateFile;
      end;
  end;
End;

{ Close the file when disposing object. }
Destructor TFreadObj.done;
begin
  CloseFile;
end;

{ Open the file.  Set an error if it could not open. }
Procedure TFreadObj.OpenFile;
Begin
  if Exist(FileName) then
  begin
    Oerror:=false;
    Reset(Ifile,Rsize);
    Current:=0;
  end
  else
    Oerror:=true;
End;

{ Create a new file, zeroing out an existing file.}
Procedure TFreadObj.CreateFile;
Begin
  Rewrite(Ifile,Rsize);
  Current:=0;
  Oerror:=Ioresult<>0;
end;

{ Close the file only if it has been successfully opened.}
Procedure TFreadObj.CloseFile;
Begin
  if not Oerror then
  begin
    Close(Ifile);
    Oerror:=true;
  end;
End;

{ Will erase the file.}
Procedure TFreadObj.EraseFile;
Begin
  if not Oerror then
  begin
    CloseFile;
    Erase(Ifile);
  end;
End;

{ Renames the file.}
Function TFreadObj.RenameFile(fn:string):Boolean;
Var
  Temp : Longint; {Save the current file pointer}
Begin
  CloseFile;
  FileName:=fn;
  Rename(Ifile,FileName);
  if ioresult=0 then
  begin
    Temp:=Current;
    Assign(Ifile,FileName);
    OpenFile;
    Current:=Temp;
  end;
  RenameFile := not Oerror;
end;

{ Rewinds the file pointer back to the beginning.}
Procedure TFreadObj.Rewind;
Begin
  if not Oerror then
  begin
    Seek(Ifile,0);
    Current:=0;
  end;
end;


Function TFreadObj.OpenError:Boolean;
Begin
  OpenError:=Oerror;
End;

Function TFreadObj.ReadError:Boolean;
Begin
  ReadError:=Rerror;
End;

Function TFreadObj.WriteError:Boolean;
Begin
  WriteError:=Werror;
End;

{ Reads a record from the file at location FPOS.  Returns the record in
  Frec.}
Procedure TFreadObj.ReadRec(var frec; fpos:longint);
Var
  numread : word;
Begin
  Rerror:=false;
  if not Oerror then
  begin
    Seek(Ifile,fpos);
    if ioresult<>0 then
      Rerror:=true
    else
    begin
      Blockread(Ifile,frec,1,numread);
      if (numread<>1) or (ioresult<>0) then
        Rerror:=true
      else
        Current:=fpos;
    end;
  end;
End;

{ Writes a record to the file at location Fpos.}
Procedure TFreadObj.WriteRec(var frec; fpos:longint);
Var
  numwritten : word;
  i:integer;
Begin
  Werror:=false;
  if not Oerror then
  begin
    Seek(Ifile,fpos);
    if Ioresult<>0 then
      Werror:=true
    else
    begin
      Blockwrite(Ifile,frec,1,numwritten);
      if (numwritten<>1) or (ioresult<>0) then
        Werror:=true
      else
        Current:=fpos;
    end;
  end;
End;

{ Appends a record to the end of the file.}
Procedure TFreadObj.AppendRec(var frec);
Begin
  WriteRec(frec,NumRecs);
End;

{ Reads the next record from the file, allowing sequential access.}
Procedure TFreadObj.ReadNext(var frec);
Begin
  ReadRec(frec,Current+1);
End;

{ Reads the previous record from the file. }
Procedure TFreadObj.ReadPrevious(var frec);
Begin
  ReadRec(frec,Current-1);
End;

{ Reads the record pointed to by current. }
Procedure TFreadObj.ReadCurrent(var frec);
Begin
  ReadRec(frec,Current);
End;

{ Returns the number of records in the file.}
Function TFreadObj.NumRecs:Longint;
Begin
  if not Oerror then
    NumRecs:=Filesize(Ifile);
End;

{ Returns the file name of the file.}
Function TFreadObj.GetFilename : String;
Begin
  GetFilename:=FileName;
End;

{ Returns the number of the current record. }
Function TFreadObj.GetCurrent : Longint;
Begin
  GetCurrent:=Current;
End;

{ No initialization required.}
end.