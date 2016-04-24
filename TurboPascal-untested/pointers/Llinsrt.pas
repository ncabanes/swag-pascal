(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0003.PAS
  Description: LL-INSRT.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:54
*)

{     The following Program yields output that indicates that I have it set up
correctly but With my scanty understanding of exactly how to handle a linked
list I would be surprised if it is.  This is one difficult area in which Swan
is not quite as expansive as he might be.

        I will appreciate critique and commentary on this if you are anybody
would be so kind as to give it:
}

Program InsertLink;
Uses Crt;

Type
  Str15 = String[15];
  Aptr = ^Link;
  Link = Record
       Data : Str15;
       Node : Aptr;
  end;

Var
  FirstItem, NewItem, OldItem : Aptr;

Procedure CreateList;
begin
  Writeln('Linked list BEForE insertion of node.');
  Writeln;
  New(FirstItem);
  FirstItem^.Data := 'inSERT ';
  Write(FirstItem^.Data);
  Write('             ');
  New(FirstItem^.Node);
  FirstItem^.Node^.Data := 'HERE';
  Writeln(FirstItem^.Node^.Data);
  FirstItem^.Node^.Node := NIL;
end;

Procedure InsertALink;
begin
  Writeln; Writeln;
  Writeln('Linked list AFTER insertion of node.');
  Writeln;
  Write(FirstItem^.Data);
  New(NewItem);
  NewItem^.Node := OldItem^.Node;
  OldItem^.Node := NewItem;
  FirstItem^.Node^.Data := 'inSERTEDLinK';
  Write(FirstItem^.Node^.Data);
  New(FirstItem^.Node^.Node);
  FirstItem^.Node^.Node^.Data := ' HERE';
  Writeln(FirstItem^.Node^.Node^.Data);
  FirstItem^.Node^.Node^.Node := NIL;
end;

Procedure DisposeList;
begin
  Dispose(FirstItem^.Node^.Node);
  FirstItem^.Node := NIL;
end;

begin
  ClrScr;
  CreateList;
  Writeln;
  InsertALink;
  DisposeList;
end.

