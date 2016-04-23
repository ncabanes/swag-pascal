{ Alphabetic Rec Sort }

Procedure SortIt(Key : Byte);
Var
  I, J : Byte;

Procedure Swapper;
Var
  T : Member;

begin
  T := Memrec[I];
  MemRec[I] := MemRec[J];
  MemRec[J] := T;
end;

begin
  For I := 1 to MaxMem - 1 DO
   For J := I To MaxMem do begin
     Case Key OF
       1 : if MemRec[I].Firstname < MemRec[J].FirstName then Swapper;
       2 : if MemRec[I].LastName  < MemRec[J].LastName  then Swapper;
       3 : if MemRec[I].Points    < MemRec[J].Points    then Swapper;
     end;
end;

{
Another Alternative would be to do as C does, make a Generic Sort routine
where you pass it a Function that returns > 0 if Record1 is greater than
Record2, < 0 if Record1 is Less than Record2, and 0 if they are the same.
}
