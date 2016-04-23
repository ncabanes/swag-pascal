{
CombSort is an extended BubbleSort algorithm which is nearly
AS FAST AS MergeSort! I found it some months ago in an computer
magazine. It is really useful, because it is really FAST and does
not need much memory so I think it should be included into SWAG.

Thomas Dreibholz

The procedures sort an array <gArray> with <count> elements.
}

procedure CombSort(count : Integer);
var notChanged : Boolean;
    i,j        : Integer;
    gap        : Integer;
begin

 gap := count;
 repeat
  notChanged := True;

  gap := Trunc(gap / 1.3);
  case gap of
   0:
    gap := 1;
   9:
    gap := 11;
   10:
    gap := 11;
  end;

  for i := 0 to count-gap do
   if gArray[i]>gArray[i+gap] then
    begin
     j := gArray[i+gap];             { Tauschen von gArray[i] und gArray[i+gap] }
     gArray[i+gap] := gArray[i];
     gArray[i] := j;
     notChanged := False;
    end;

 until (notChanged) and (gap=1);
end;


For comparision: The standard BubbleSort procedure.

procedure BubbleSort(count : Integer);
var notChanged : Boolean;
    i,j        : Integer;
begin

 repeat

  notChanged := True;
  for i := 0 to count-1 do
   if gArray[i]>gArray[i+1] then
    begin
     j := gArray[i+1];             { Tauschen von gArray[i] und gArray[i+1] }
     gArray[i+1] := gArray[i];
     gArray[i] := j;
     notChanged := False;
    end;

 until (notChanged);
end;

