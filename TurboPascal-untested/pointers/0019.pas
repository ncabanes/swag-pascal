type
  PDataRec = ^TDataRec;
  TDataRec = record
    Name: String;
    Next: PDataRec;
  end;

const
  DataRecList: PDataRec = nil;
  CurRec :PDataRec = nil;

procedure AddRec(AName: String);
var Temp: PDataRec;
begin
  New(CurRec);
  CurRec^.Name := AName;
  CurRec^.Next := nil;
  Temp := DataRecList;
  if Temp = nil then
    DataRecList := CurRec
  else
    begin
      while Temp^.Next <> nil do Temp := Temp^.Next;
      Temp^.Next := CurRec;
    end;
end;

procedure PrevRec;
var Temp: PDataRec;
begin
  Temp := DataRecList;
  if Temp <> CurRec then
    while Temp^.Next <> CurRec do Temp := Temp^.Next;
  CurRec := Temp;
end;

procedure NextRec;
begin
  if CurRec^.Next <> nil then CurRec := CurRec^.Next;
end;

procedure List;
var Temp: PDataRec;
begin
  Temp := DataRecList;
  while Temp <> nil do
    begin
      Write(Temp^.Name);
      if Temp = CurRec then
        Writeln(' <<Current Record>>')
      else
        Writeln;
      Temp := Temp^.Next;
    end;
end;

begin
  AddRec('Tom');  AddRec('Dick'); AddRec('Harry');  AddRec('Fred');
  Writeln('Original List');
  List;
  Writeln;
  Readln;

  PrevRec; PrevRec;
  Writeln('After Two PrevRec Calls');
  List;
  Writeln;
  Readln;

  NextRec;
  Writeln('After One NextRec Call');
  List;
  Writeln;
  Readln;

  Writeln('End of Program.');
end.