(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0018.PAS
  Description: Example of LINKED Records
  Author: SWAG SUPPORT TEAM
  Date: 08-24-94  13:44
*)

program LinkLst2;

uses
  Crt;

const
  FileName = 'LinkExp.dta';

type
  PMyNode = ^TMyNode;
  TMyNode = record
    Name  : String;
    Flight: integer;
    Day   : String;
    Next  : PMyNode;  {Used to link each field}
  end;

procedure CreateNew(var Item: PMyNode);
begin
  New(Item);
  Item^.Next := nil;
  Item^.Name := '';
  Item^.Flight := 0;
  Item^.Day := '';
end;

procedure GetData(var Item: PMyNode);
begin
  ClrScr;
  repeat
    GotoXY(1, 1);
    Write('Enter Name: ');
    Read(Item^.Name);
  until (Item^.Name <> '');
  GotoXY(1, 2);
  Write('Enter Flight number: ');
  ReadLn(Item^.Flight);
  GotoXY(1, 3);
  Write('Enter Day: ');
  ReadLn(Item^.Day);
end;

procedure DoFirst(var First, Current: PMyNode);
begin
  CreateNew(Current);
  GetData(Current);
  First := Current;
end;

procedure Add(var Prev, Current: PMyNode);
begin
  Prev := Current;
  CreateNew(Current);
  GetData(Current);
  Prev^.Next := Current;
end;

procedure DeleteNode(var Head, Node, Current: PMyNode);
var
  Temp: PMyNode;
begin
  Temp := Head;
  while Temp^.Next <> Node do
    Temp := Temp^.Next;
  if Temp^.Next^.Next <> nil then
    Temp^.Next := Temp^.Next^.Next
  else begin
    Temp^.Next := nil;
    Current := Temp;
  end;
  Dispose(Node);
end;

function Find(Head: PMyNode; S: String): PMyNode;
var
  Temp: PMyNode;
begin
  Temp := nil;
  while Head^.Next <> nil do begin
    if Head^.Name = S then begin
      Temp := Head;
      break;
    end;
    Head := Head^.Next;
  end;
  if Head^.Name = S then Temp := Head;
  Find := Temp;
end;

procedure DoDelete(var Head, Current: PMyNode);
var
  S: String;
  Temp: PMyNode;
begin
  ClrScr;
  Write('Enter name from record to delete: ');
  ReadLn(S);
  Temp := Find(Head, S);
  if Temp <> nil then
    DeleteNode(Head, Temp, Current);
end;

procedure ShowRec(Item: PMyNode; i: Integer);
begin
  GotoXY(1, i); Write('Name: ', Item^.Name);
  GotoXY(25, i); Write('Flight: ', Item^.Flight);
  GotoXY(45, i); Write('Day: ', Item^.Day);
end;

procedure Show(Head: PMyNode);
var
  i: Integer;
begin
  i := 1;
  ClrScr;
  while Head^.Next <> nil do begin
    Head := Head^.Next;
    ShowRec(Head, i);
    Inc(i);
  end;
  WriteLn;
  WriteLn('==========================================================');
  WriteLn(i, ' records shown');
  ReadLn;
end;

procedure FreeAll(var Head: PMyNode);
var
  Temp: PMyNode;
begin
  while Head^.Next <> nil do begin
    Temp := Head^.Next;
    Dispose(Head);
    Head := Temp;
  end;
  Dispose(Head);
end;

procedure CreateNewFile(Head: PMyNode);
var
  F: File of TMyNode;
begin
  Assign(F, FileName);
  ReWrite(F);
  while Head^.Next <> nil do begin
    Write(F, Head^);
    Head := Head^.Next;
  end;
  Write(F, Head^);
  Close(F);
end;

procedure ReadFile(var First, Prev, Current: PMyNode);
var
  F: File of TMyNode;
begin
  Assign(F, FileName);
  Reset(F);
  CreateNew(Current);
  Read(F, Current^);
  First := Current;
  while not Eof(F) do begin
    Prev := Current;
    CreateNew(Current);
    Read(F, Current^);
    Prev^.Next := Current;
  end;
  Close(F);
end;

procedure Main(var First, Prev, Current: PMyNode);
var
  F      : Text;
begin
  {$I-}
  Assign (f, 'HW2FILE.TXT');
  Reset(f);
  {$I+}
  if (IOResult <> 0) then begin
    WriteLn('error Reading File');
    Halt;
  end;
  CreateNew(Current);
  ReadLn(F, Current^.Name);
  ReadLn(F, Current^.Flight);
  ReadLn(F, Current^.Day);
  First := Current;
  while not Eof(F) do begin
    Prev := Current;
    CreateNew(Current);
    ReadLn(F, Current^.Name);
    ReadLn(F, Current^.Flight);
    ReadLn(F, Current^.Day);
    Prev^.Next := Current;
  end;
  Close(F);
  Show(First);
  CreateNewFile(First);
end;

function WriteMenu: Char;
var
  Ch: Char;
begin
  ClrScr;
  GotoXY(1, 1);
  WriteLn('A) Add');
  WriteLn('D) Delete');
  WriteLn('S) Show');
  WriteLn('W) Write File');
  WriteLn('X) Exit');
  repeat
    Ch := UpCase(ReadKey);
  until Ch in ['A', 'D', 'S', 'W', 'X'];
  WriteMenu := Ch;
end;

var
  Ch: Char;
  First,
  Prev,
  Current: PMyNode;

begin
  ClrScr;
  {  Main(First, Prev, Current); Use this option to read text file }
  ReadFile(First, Prev, Current);
  repeat
    Ch := WriteMenu;
    case Ch of
      'A': Add(Prev, Current);
      'D': DoDelete(First, Current);
      'S': Show(First);
      'W': CreateNewFile(First);
    end;
  until Ch = 'X';
end.
end. { main program}

