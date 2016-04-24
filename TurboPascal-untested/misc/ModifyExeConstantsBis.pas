(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0047.PAS
  Description: Modify EXE Constants
  Author: JON JASIUNAS
  Date: 11-02-93  05:37
*)

{
JON JASIUNAS

>Is it possible to store variables in actual .EXE file of a TP program, inste
>of making an external config file for it?  Thanks.

Sure.  Make them typed constants, then modify the .EXE whenever you want
to store a change.
}

type
  tOwnerName = string[30];
  tRegCode   = String[12];

const
  OwnerName : tOwnerName = '';
  RegCode   : tRegCode   = '';

begin
  WriteLn('The current owner is : ', OwnerName);
  WriteLn('The current registration code is : ', RegCode);
  WriteLn;

  Write('Enter the new owner name: ');
  ReadLn(OwnerName);
  Write('Enter the new registration code: ');
  ReadLn(RegCode);

  If Write2Exe(OwnerName, SizeOf(OwnerName)) <> 0 then
    WriteLn('Owner name not updated!');

  If Write2Exe(RegCode, SizeOf(RegCode)) <> 0 then
    WriteLn('Registration code not updated!');
end.

{ Here's my self mod unit: }

{*****************************
 *      EXEMOD.PAS v1.0      *
 *                           *
 *    General purose .EXE    *
 *  self-modifying routines  *
 *****************************

1992-93  HyperDrive Software
Released into the public domain.}

{$S-,R-,D-,I-}
{$IFOPT O+}
  {$F+}
{$ENDIF}

unit ExeMod;

interface

var
  ExeName : String;

function Write2Exe(var Data2Write; DataSize : Word) : Integer;

implementation

function Write2Exe(var Data2Write; DataSize : Word): Integer;
const
  PrefixSize = 256;
var
  ExeFile    : File;
  HeaderSize : Word;
  IoError    : Integer;
begin
  Assign(ExeFile, ExeName);
  Reset(ExeFile, 1);
  IoError := IOResult;

  If IoError = 0 then
  {-Seek position of header size in EXE File }
  begin
    Seek(ExeFile, 8);
    IoError := IOResult;
  end;  { If }

  If IoError = 0 then
  {-Read header size in EXE File }
  begin
    BlockRead(ExeFile, HeaderSize, Sizeof(HeaderSize));
    IoError := IOResult;
  end;

  If IoError = 0 then
  {-Seek position of Data in EXE File }
  begin
    Seek(ExeFile, LongInt(16) * (HeaderSize + Seg(Data2Write) - PrefixSeg) +
    IoError := IOResult;
  end;

  If IoError = 0 then
  {-Write new Data to EXE File }
  begin
    BlockWrite(ExeFile, Data2Write, DataSize);
    IoError := IOResult;
  end;

  Close(ExeFile);
  Write2Exe := IoError;
end;

begin
  ExeName := ParamStr(0);
end.


