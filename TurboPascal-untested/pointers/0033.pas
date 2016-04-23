{
AW>Hi all! how do i pass an array of pointers to a procedure? i know how to
AW>do it in C++, but is it been done in pascal?

Something like this :
}

Const
     MaxPointer = 20;

Type
    MyPointerArrayType = Array [1..MaxPointer] of Pointer;

Var
   MainPointerArray : MyPointerArrayType;

*Only give the pointer to the array to the procedure*
This method allows you to alter the original variable.

procedure ProcessPointers1 (Var LocalArray : MyPointerArrayType);

begin
     {Do something} 
end;

*make a copy of the array*
This method makes a copy of the array, and allows you to precess the array in 
the procedure.

Procedure ProcessPointers2 (LocalArray : MyPointerArrayType);

begin
     {Do something}
end;

begin {Main}
     MainPointerArray [1] := NIL;
     ProcessPointers1 (MainPointerArray);     
     ProcessPointers2 (MainPointerArray);
end.{Main}
        
What you must remember that you have to declare a type first and then refer to
this type when you declare a function or procedure.

