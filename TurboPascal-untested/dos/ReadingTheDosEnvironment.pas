(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0078.PAS
  Description: Reading The DOS Environment
  Author: GARY MAYS
  Date: 11-26-94  05:08
*)

{
>> How do I detect / read a string in the enviornment?  For example
> WriteLn('The DOS variable "COMSPEC" = ",GetEnv('COMSPEC'));

If you are using an older version of pascal without the getenv function, then
here are two functions to get the environment string and executed program name
that I wrote a while ago. It can examime any environment, not just the current
program... you just provide the prefix segment...
}

{--get the text of an environment string variable--}
function getenvstr(_prefixseg: word; v : string): string;
{ gary a. mays 3/1/88 }
  type
    envstr = array[1..32768] of char;
  var
    env    : ^envstr;
    p    : integer;
    temp : string;
    i : integer;
begin
  if v = '' then
  begin
    getenvstr := '';
    exit;
  end;

  { convert specified variable name to uppercase }
  for i := 1 to length(v) do v[i] := upcase(v[i]);

  env := ptr(memw[_prefixseg:$2c],0);
  i := 1;
  temp := '';

  while env^[i] <> #0 do
  begin
    temp := temp + env^[i];
    i := succ(i);
    if env^[i] = #0 then { end of current string }
    begin
      i := succ(i);
      p := pos('=',temp) + 1;
      if p > 1 then
        if v = copy(temp,1,p-2) then { caller's variable name matched }
        begin
          getenvstr := copy(temp,p,255); { return variable's value }
          exit;
        end;
      temp := '';
    end;
  end;
  getenvstr := '';
end; { getenvstr }

{--get the executed program name--}
function getprogramname(_prefixseg: word): string;
{ gary a. mays 5/11/88 }
  type
    envstr = array[1..32768] of char;
  var
    env    : ^envstr;
    p      : integer;
    temp   : string;
    i : integer;
begin
  env := ptr(memw[_prefixseg:$2c],0);
  i := 1;
  temp := '';

  while env^[i] <> #0 do
  begin
    repeat i := succ(i); until env^[i] = #0; {locate end of a string}
    i := succ(i); { point to next string or final nul }
  end;

  i := i + 3; { point to start of asciz string }

  while env^[i] <> #0 do
  begin
    temp := temp + env^[i];
    i := succ(i);
  end;

  getprogramname := temp;
end; { getprogramname }


