{
Q:  How do I use "array of const"?

A: An array of const is in fact an open array of TVarRec (a
predeclared Delphi type you can look up in the online help). So
the following is Object Pascal psuedocode for the general battle
plan:
}
procedure AddStuff( Const A: Array of Const );
Var i: Integer;
Begin
  For i:= Low(A) to High(A) Do
  With A[i] Do
    Case VType of
    vtExtended: Begin
       { add real number, all real formats are converted to 
         extended automatically }
      End;
    vtInteger: Begin

       { add integer number, all integer formats are converted 
         to LongInt automatically }
      End;
    vtObject: Begin
        If VObject Is DArray Then
          With DArray( VObject ) Do Begin
            { add array of doubles }
          End
        Else If VObject Is IArray Then
          With IArray( VObject ) Do Begin
            { add array of integers }
          End;
      End;
    End; { Case }
End; { AddStuff }
