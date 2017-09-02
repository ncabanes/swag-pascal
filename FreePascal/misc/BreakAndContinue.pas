(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0050.PAS
  Description: BREAK and CONTINUE
  Author: MARTIN LARSEN
  Date: 11-02-93  06:02
*)

{
MARTIN LARSEN

There are at least two nice features in BP7: BREAK and CONTINUE:
}
program rc;

var
    count: integer;

begin
    count := 0;
    Repeat
        Inc(Count);
        if Odd(Count) then Continue; { Go to start of loop }
        if Count = 10 then Break;    { Go to sentence just after loop }
        Write(Count, ' ');
    Until False;
end.
