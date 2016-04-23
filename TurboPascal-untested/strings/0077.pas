{
DJ>Can anyone please help me speed up the following functions?

  Aha! A challange! <g>

DJ>I wouldn't mind using built-in assembly either!

  You can still achieve a large increase in speed without using
  assembly code. Here's my stab at rewriting your routines.
  (These could be written faster still, but I'll leave that up
  to you.)
}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
{$M 4096,0,655360}

program Test_New_Tab_Functions;

  (***** Remove space-wasting chars from end of line.                 *)
  (*                                                                  *)
  function TrimRight2({input }
                         st_IN : string) :
                      {output}
                         string;
  var
    by_Index : byte;
  begin
    by_Index := length(st_IN);
    while st_IN[by_Index] IN [#0,#9,#32] do
      begin
        dec(by_Index);
        dec(st_IN[0])
      end;
    TrimRight2 := st_IN
  end;        (* TrimRight2.                                          *)

  (***** Replace tabs with 8 spaces.                                  *)
  (*                                                                  *)
  function DeTab2({input }
                     st_IN : string) :
                  {output}
                     string;
  var
    by_Index1,
    by_Index2 : byte;
    st_Temp   : string;
  begin
    by_Index2 := 0;
    fillchar(st_Temp[1], 255, #32);
    for by_Index1 := 1 to length(st_IN) do
      if (st_IN[by_Index1] <> #9) then
        begin
          inc(by_Index2);
          st_Temp[by_Index2] := st_IN[by_Index1]
        end
      else
        by_Index2 := succ(by_Index2 shr 3) shl 3;
    st_Temp[0] := chr(by_Index2);
    DeTab2 := st_Temp
  end;        (* DeTab2.                                              *)

  (***** Replace spaces with tabs to compress string.                 *)
  (*                                                                  *)
  function EnTab2({input }
                     st_IN : string) :
                  {output}
                     string;
  var
    by_Count,
    by_IndexIN,
    by_IndexOUT : byte;
    st_Temp     : string;
  begin
    by_IndexIN  := 0;
    by_IndexOUT := 0;
    by_Count    := 0;
    st_Temp[0]  := #0;
    fillchar(st_Temp[1], length(st_IN), #32);
    repeat
      inc(by_IndexIN);
      if (st_IN[by_IndexIN] <> #32) then
        begin
          inc(by_IndexOUT);
          st_Temp[by_IndexOUT] := st_IN[by_IndexIN]
        end
      else
        begin
          by_Count := 0;
          while ((by_IndexIN + by_Count) < length(st_IN))
          AND   (st_IN[(by_IndexIN + by_Count)] = #32)
          AND   (((by_IndexIN + by_Count) mod 8) <> 0) do
            inc(by_Count);

          if (by_Count > 0) then
            begin
              if (((by_IndexIN + by_Count) mod 8) = 0) then
                begin
                  inc(by_IndexOUT);
                  st_Temp[by_IndexOUT] := #9;
                  inc(by_IndexIN, by_Count)
                end
              else
                begin
                  inc(by_IndexOUT, by_Count);
                  inc(by_IndexIN,  pred(by_Count))
                end
            end
          else
            inc(by_IndexOUT)
        end
    until (by_IndexIN = length(st_IN));
    st_Temp[0] := chr(by_IndexOut);
    EnTab2 := st_Temp
  end;        (* EnTab2.                                              *)

var
  by_Loop  : byte;
  st_Temp1,
  st_Temp2 : string;

BEGIN
  st_Temp1[0] := chr(245);
  fillchar(st_Temp1[1], 245, 'A');
  st_Temp1 := st_Temp1 + #9#0#32#32#9#9#9#0#32#0;

  st_Temp2 := TrimRight2(st_Temp1);

  st_Temp1 := '';
  for by_Loop := 1 to 17 do
    st_Temp1 := st_Temp1 + 'ABCDEFG' + #9;

  st_Temp2 := DeTab2(st_Temp1);

  st_Temp1 := '';
  for by_Loop := 1 to 25 do
    st_Temp1 := st_Temp1 + 'ABCDE     ';

  st_Temp2 := EnTab2(st_Temp1)
END.

  Benchmarking my new routines against your old routines on my
  386DX-40 running Novell DOS 7.0, the results are:

    Old TrimRight Time = 1.034 ms
    New TrimRight Time = 0.126 ms (820 percent faster)

    Old DeTab Time     = 2.514 ms
    New DeTab Time     = 0.391 ms (640 percent faster)

    Old EnTab Time     = 8.450 ms
    New EnTab Time     = 1.004 ms (840 percent faster)

  ...Two things to keep in mind when trying to optimize a routine
  are:
        Always try to reduce the number of loops your routine
        has to make.

        Copy/Move your data as little as possible.

