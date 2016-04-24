(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0024.PAS
  Description: Passing method as OBJect
  Author: STUART MACLEAN
  Date: 08-27-93  20:37
*)

{
Stuart Maclean

Hi there, I've found a neat way of passing an Object a method of its own
class, which it then executes. The idea comes from Smalltalk's
change/update mechanism For dependencies under the MVC paradigm.

Works under TP6.
}

Type
  DependentPtr = ^Dependent;

  Dependent = Object
                Procedure Update(p : Pointer);
                Procedure SomeMethod;
              end;

  Model = Object
            dep : DependentPtr;
            Procedure Change;
          end;

Procedure Dependent.Update; Assembler;
Asm
  les di, self
  push es
  push di
  call dWord ptr p
end;

Procedure Dependent.SomeMethod;
begin
{ do something here }
end;

Procedure Model.Change;
begin
  dep^.Update(@Dependent.Somemethod);
end;

Var
  m : Model;
  d : Dependent;

begin
  m.dep := @d; { add d as a dependent of m }
  m.Change;  { caUses d to be updated }
end.

