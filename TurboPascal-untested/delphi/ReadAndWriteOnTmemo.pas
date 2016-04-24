(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0017.PAS
  Description: Read and Write on TMemo
  Author: KIRIAKOS VLAHOS
  Date: 11-22-95  13:27
*)


My small contribution to DELPHI programmers:
Here follows a small unit that helps you use any derivative of TCustomEdit for 
standard Pascal Input/Output.  Hope you find it useful.  It works the fine 
with the TP yacc and lex for parsing the contents of a TMemo.  Could also 
replace the need for WinCRT.

How to use it:

Uses
   ...., EditText;

Var
   F : Text;
   Memo1, Memo2: TMemo;
   S : String;
   i : Integer;

Begin

  {Assumes the Memos have been created and exist on the form}
   AssignDevice(System.Input, Memo1);
   Reset(System.Input);
   AssignDevice(System.Output, Memo2);
   Rewrite(System.Output);

  {Now normal Reads and Writes work with Memo1 and Memo2.  ie.}
  Writeln(S); Write(i:2);


  {Also}
   AssignDevice(F, Memo2);
   Rewrite(F);
   Writeln(F,S); Write(F,i:2);

end;


Source:

unit EditText;
{

      Written by Kiriakos Vlahos (kvlahos.@lbs.lon.ac.uk)
      Freeware   -  Please send comments of improvements.
   
}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, Dialogs;

  procedure AssignDevice(var T: Text; NewEditComponent: TCustomEdit);

implementation

type
  EditData = record
    Edit: TCustomEdit;
    Filler: Array [1..12] of Char;
  end;

function EditWrite(var F: TTextRec): Integer; far;
begin
  with F do
  begin
    BufPtr^[BufPos] := #0;
    EditData(F.UserData).Edit.SetSelTextBuf(PChar(BufPtr));
    BufPos := 0;
  end;
  EditWrite := 0;
end;

function EditRead(var F: TTextRec): Integer; far;
Var
  CurPos : Integer;
begin
  with F do
    with EditData(UserData) do begin
      BufPos := 0;
      Edit.SelLength := BufSize;
      Edit.GetSelTextBuf(PChar(BufPtr), BufSize);
      BufEnd := StrLen(PChar(BufPtr));
      Edit.SelStart := Edit.SelStart + BufEnd;
    end;
  EditRead := 0;
end;

function EditFlush(var F: TTextRec): Integer; far;
begin
  F.BufPos := 0;
  F.BufEnd := 0;
  EditFlush := 0;
end;

function EditOpen(var F: TTextRec): Integer; far;
begin
  with F do
  begin
    if Mode = fmInput then
    begin
      InOutFunc := @EditRead;
      FlushFunc := nil;
      EditData(F.UserData).Edit.SelStart := 0;
    end
    else
    begin
      Mode := fmOutput;
      InOutFunc := @EditWrite;
      FlushFunc := @EditWrite;
    end;
    EditOpen := 0;
  end;
end;

function EditIgnore(var F: TTextRec): Integer; far;
begin
  EditIgnore := 0;
end;

procedure AssignDevice(var T: Text; NewEditComponent: TCustomEdit);
begin
  with TTextRec(T) do
  begin
    Handle := $FFFF;
    Mode := fmClosed;
    BufSize := SizeOf(Buffer)-1;
    BufPtr := @Buffer;
    OpenFunc := @EditOpen;
    CloseFunc := @EditIgnore;
    Name[0] := #0;
    EditData(UserData).Edit:= NewEditComponent;
  end;
end;

end.


