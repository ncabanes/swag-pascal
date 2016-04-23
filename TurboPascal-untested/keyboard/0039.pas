{
PER-ERIC LARSSON

> How do you determine if a key is still held down after another is
> pressed ? KeyPressed returns False after second key is pressed and first
> key is still held down. ??

From the helpFile For KEEP :
}

Procedure Keyclick; interrupt;
begin
  if Port[$60] < $80 then
    { Only click when key is pressed }
