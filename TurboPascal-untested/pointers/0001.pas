{ > Does anybody have any good source/Units For Turbo
 > Pascal 6.0/7.0 For doing Double Linked List File
 > structures?
}

Type

   DLinkPtr = ^DLinkRecord;

   DLinkRecord = Record
      Data     : Integer;
      Next     : DLinkPtr;
      Last     : DLinkPtr;
     end;

Var
  Current,
  First,
  Final,
  Prev    : DLinkPtr;
  X       : Byte;

Procedure AddNode;
begin
  if First = Nil then
   begin
     New(Current);
     Current^.Next:=Nil;
     Current^.Last:=Nil;
     Current^.Data:=32;
     First:=Current;
     Final:=Current;
   end
  else
   begin
    Prev:=Current;
    New(Current);
    Current^.Next:=Nil;
    Current^.Last:=Prev;
    Current^.Data:=54;
    Prev^.Next:=Current;
    Final:=Current;
   end;
end;

begin
  First:=Nil;
  For X:=1 to 10 Do AddNode;
  Writeln('First: ',first^.data);
  Writeln('Final: ',final^.data);
  Writeln('Others:');
  Writeln(first^.next^.data);

end.
