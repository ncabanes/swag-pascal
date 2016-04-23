{
MARTIN LARSEN

There are at least two nice features in BP7: BREAK and CONTINUE:
}

Repeat
  Inc(Count);
  if Odd(Count) then Continue; { Go to start of loop }
  if Count = 10 then Break;    { Go to sentence just after loop }
Until False;
