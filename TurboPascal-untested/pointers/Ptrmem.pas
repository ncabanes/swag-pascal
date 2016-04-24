(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0006.PAS
  Description: PTR-MEM.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:54
*)

Program Test_Pointers;

Type
  Array_Pointer = ^MyArray;
  MyArray = Array[1..10] of String;

Var
  MyVar : Array_Pointer;

begin
  Writeln('Memory beFore initializing Variable : ',MemAvail);

  New(MyVar);

  Writeln('Memory after initializiation : ',MemAvail);

  MyVar^[1] := 'Hello';
  MyVar^[2] := 'World!';

  Writeln(MyVar^[1], ' ', MyVar^[2]);

  Dispose(MyVar);

  Writeln('Memory after Variable memory released : ',MemAvail);
end.

