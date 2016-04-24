(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0086.PAS
  Description: Accessing DBASE3 Files
  Author: SWAG SUPPORT TEAM
  Date: 02-03-94  09:59
*)

unit dbaseiii;
{ unit including procedures for accessing DBaseIII files}

interface

uses Crt;

Procedure OpenDBFData;
Procedure OpenDBFMemo;
Procedure ReadDBFRecord(I : Longint);
Procedure WriteDBFRecord;
Procedure ReadDBFMemo(BlockNumber : integer);
Procedure WriteDBFMemo(var BlockNumberString : string);
Procedure CloseDBFData;
Procedure CloseDBFMemo;

const
        DBFMaxRecordLength = 4096;
        DBFMemoBlockLength =  512;
        DBFMaxMemoLength   = 4096;

type
        DBFHeaderRec = Record
                HeadType                : byte;
                Year                        : byte;
                Month                        : byte;
                Day                                : byte;
                RecordCount                : longint;
                HeaderLength        : integer;
                RecordSize          : integer;
                Garbage                         : array[1..20] of byte;
        end;

type
        DBFFieldRec = Record
                FieldName                : array[1..11] of char;
                FieldType                : char;
                Spare1,
                Spare2                        : integer;
                Width                        : byte;
                Dec                                : byte;
                WorkSpace                : array[1..14] of byte;
        end;

var
        DBFFileName                         : string;

        DBFDataFile                                : File;
        DBFDataFileAvailable        : boolean;
        DBFBuffer                                : array [1..DBFMaxRecordLength] of char;

        DBFHeading                                : DBFHeaderRec;

        DBFField                                : DBFFieldRec;
        DBFFieldCount                        : integer;
        DBFFieldContent                        : array [1..128] of string;

        DBFNames                                : array [1..128] of string[10];
        DBFLengths                                : array [1..128] of byte;
        DBFTypes                                : array [1..128] of char;
        DBFDecimals                                : array [1..128] of byte;
        DBFContentStart                        : array [1..128] of integer;

        DBFMemoFile                                : File;
        DBFMemoFileAvailable        : boolean;
        DBFMemoBuffer                        : Array [1..DBFMemoBlockLength] of byte;
        DBFMemo                                        : Array [1..DBFMaxMemoLength] of char;

        DBFMemoLength                        : integer;
        DBFMemoEnd                                : boolean;
        DBFMemoBlock                        : integer;

        DBFDeleteField                        : char;
        DBFFieldStart                        : integer;

        DBFRecordNumber                        : longint;

(****************************************************************)

implementation

(****************************************************************)

Procedure ReadDBFHeader;

var
        RecordsRead : integer;

begin
        BlockRead (DBFDataFile, DBFHeading, SizeOf(DBFHeading), RecordsRead);
end;

(*****************************************************************)

Procedure ProcessField (F : DBFFieldRec;
                                                I : integer);
var
        J : integer;

begin
        with F do
        begin
                DBFNames [I] := '';
                J := 1;
                while (J<11) and (FieldName[J] <> #0) do
                        begin
                                DBFNames[I] := DBFNames[I] + FieldName [J];
                                J := J + 1;
                        end;
                DBFLengths [I]                 := Width;
                DBFTypes [I]                 := FieldType;
                DBFDecimals [I]         := Dec;
                DBFContentStart [I] := DBFFieldStart;
                DBFFieldStart                 := DBFFieldStart + Width;
        end;
end;

(***************************************************************)

Procedure ReadFields;

var
        I                         : integer;
        RecordsRead : integer;

begin
        Seek(DBFDataFile,32);
        I := 1;
        DBFFieldStart := 2;
        DBFField.FieldName[1] := ' ';
        while (DBFField.FieldName[1] <> #13) do
                begin
                        BlockRead(DBFDataFile,DBFField.FieldName[1],1);
                        if (DBFField.FieldName[1] <> #13) then
                                begin
                                        BlockRead(DBFDataFile, DBFField.FieldName[2],SizeOf(DBFField) - 1, RecordsRead);
                                        ProcessField (DBFField, I);
                                        I := I + 1;
                                end;
                end;
        DBFFieldCount := I - 1;
end;

(***********************************************************)

Procedure OpenDBFData;

begin
        DBFDataFileAvailable := false;
        Assign(DBFDataFile, DBFFileName+'.DBF');

{$I-}
        Reset(DBFDataFile,1);
        If IOResult<>0 then exit;
{$I+}

        DBFDataFileAvailable := true;
        Seek(DBFDataFile,0);
        ReadDBFHeader;
        ReadFields;
end;

(******************************************************************)

Procedure CloseDBFData;

begin
        if DBFDataFileAvailable then Close(DBFDataFile);
end;

(*******************************************************************)

Procedure OpenDBFMemo;

begin
        DBFMemoFileAvailable := false;
        Assign(DBFMemoFile, DBFFileName+'.DBT');

{$I-}
        Reset(DBFMemoFile,1);
        If IOResult<>0 then exit;
{$I+}

        DBFMemoFileAvailable := true;
        Seek(DBFMemoFile,0);
end;

(*******************************************************************)

Procedure CloseDBFMemo;

begin
        If DBFMemoFileAvailable then close(DBFMemoFile);
end;

(*******************************************************************)

Procedure GetDBFFields;

var
        I                         : byte;
        J                         : integer;
        Response         : string;

begin
        DBFDeleteField := DBFBuffer[1];
        For I:=1 to DBFFieldCount do
                begin
                        DBFFieldContent[I] := '';
                        For J := DBFContentStart[I] to DBFContentStart [I] + DBFLengths[I] -1 do
                                DBFFieldContent[I] := DBFFieldContent[I] + DBFBuffer[J];
                        For J := 1 to DBFLengths[I] do
                                if DBFFieldContent[J]=#0 then DBFFieldContent[J]:=#32;
                end;
end;

(***********************************************************************)

Procedure ReadDBFRecord (I : Longint);

var
        RecordsRead : integer;

begin
        Seek(DBFDataFile, DBFHeading.HeaderLength + DBFHeading.RecordSize * (I - 1));
        BlockRead (DBFDataFile, DBFBuffer, DBFHeading.RecordSize, RecordsRead);
        GetDBFFields;
end;

(**********************************************************************)

Procedure ReadDBFMemo(BlockNumber : integer);

var
        I                         : integer;
        RecordsRead        : word;

begin
        DBFMemoLength := 0;
        DBFMemoEnd := false;
        If not DBFMemoFileAvailable then
                begin
                        DBFMemoEnd := true;
                        exit;
                end;
        FillChar(DBFMemo[1],DBFMaxMemoLength,#0);
        Seek(DBFMemoFile,BlockNumber*DBFMemoBlockLength);
        repeat
                BlockRead(DBFMemoFile,DBFMemoBuffer,DBFMemoBlockLength,RecordsRead);
                For I := 1 to RecordsRead  do
                        begin
                                DBFMemoLength := DBFMemoLength + 1;
                                DBFMemo[DBFMemoLength] := chr(DBFMemoBuffer[I] and $7F);
                                If (DBFMemoBuffer[I] = $1A) or (DBFMemoBuffer[I] = $00) then
                                        begin
                                                DBFMemoEnd := true;
                                                DBFMemoLength := DBFMemoLength - 1;
                                                exit;
                                        end;
                        end;
        until DBFMemoEnd;
end;

(*********************************************************************)

Procedure WriteDBFMemo  {(var BlockNumberString : string)};

var
        K : integer;
        ReturnCode : integer;

begin
        Val(BlockNumberString,DBFMemoBlock,ReturnCode);
        If ReturnCode>0 then DBFMemoBlock := 0;
        If DBFMemoBlock>0 then
                begin
                        Writeln;
                        ReadDBFMemo(DBFMemoBlock);
                        If DBFMemoLength=0 then exit;
                        For K := 1 to DBFMemoLength do
                                Write(DBFMemo[K]);
                        WriteLn;
                end;
end;

(****************************************************************)

Procedure WriteDBFRecord;

var
        J : byte;

begin
        For J := 1 to DBFFieldCount do
                begin
                        Write(DBFNames[J]);
                        GoToXY(12,J);
                        WriteLn(DBFFieldContent[J]);
                        if DBFTypes[J]='M' then WriteDBFMemo(DBFFieldContent[J]);
                end;
end;

(*******************************************************************)

begin
end.

