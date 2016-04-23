(*
 -=> Quoting Tim Benoit to All <=-

 TB> I am having a bit of difficulty figuring out how to sort an
 TB> array of records by numerical or alphabetical order.
 TB>                  I need all the information that goes with that
 TB> specific Record to stay with it...

    This example uses a modified bubblesort algorithm, not real fast but
fairly easy to follow. You may want to use a faster sort procedure but
the basic idea is to examine the data in your selected sort
field (RecArray[i].variable) but do the sort on the whole
record (RecArray[i]):

eg:
     Var

         Buffer : Rec;

     If RecArray[3].Number1 > RecArray[4].Number1 then { sort }

        Begin   { interchange RecArray[3] and RecArray[4] }
                Buffer := RecArray[3];
                RecArray[3] := RecArray[4];
                RecArray[4] := Buffer
        End;

Bubblesort makes multiple passes moving data only one place per pass.
This example is similar but uses only one pass.
*)

Program Modsort;

uses Crt;      {only needed for clrscr}

Const
  max = 10;      {max number of records}

Type
  fieldtype = string[2];
  datatype = record
         rec1 : fieldtype;
         rec2 : fieldtype;
         end;
Var
  data : array [1..max] of datatype;
  i,j : byte;

Procedure interchange(r,l:datatype);

Var
   buffer : datatype;

Begin
     buffer := r;
     data[i] := l;
     data[i+1] := buffer;
     dec(i);
End;

Procedure sort(j : byte);  {j is the selected sort field number}

Var
   field : array [1..2] of fieldtype;

Begin
   i := 1;

   While i < max  do
         Begin
            Case j of
                1 : Begin
                       field[1] := data[i].rec1;
                       field[2] := data[i+1].rec1;
                    End;
                2 : Begin
                       field[1] := data[i].rec2;
                       field[2] := data[i+1].rec2;
                    End;
            End;

         If field[1] > field[2] then
            Interchange(data[i], data[i+1])
         Else
            Inc(i);
         End;
End;

Begin                              {main}

Clrscr;
Writeln('UNSORTED :');
For i := 1 to max do              {make up random array of alphas}
    Begin
        j := random(26);
        data[i].rec1 := chr(j+65);
        Write(data[i].rec1);
        j := random(26);
        Data[i].rec2 := chr(j+65);
        Writeln(',',data[i].rec2);
    End;

Write('Sort on which field? ');
Readln(j);
Sort(j);
Writeln('SORTED ON FIELD: ',j);

For i := 1 to max do
    Begin
        Write(data[i].rec1);
        Writeln(',',data[i].rec2);
    End;

End.
