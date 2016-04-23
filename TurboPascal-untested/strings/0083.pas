function Str2Int(Str:string): integer;
var
  temp,code : integer;
begin
  if length(Str) = 0 then
     Str2Int := 0
  else begin
    val(Str,temp,code);
    if code = 0 then
       Str2Int := temp
    else
       Str2Int := 0;
  end;
end;

function StripFrontChars(Var S : String;Ch : Char) : String;
var
  S1 : String;
begin
  While (S[1] = Ch) and (Length(S) > 0) do
  S := Copy(S,2,Length(S) - 1);
  StripFrontChars := S
end;

function StripBlanks(Var S : String) : String;
var
  i : Integer;
begin
  i := Length(S);
  while S[i] = ' ' do begin
    Delete(S,i,1);
    Dec(i);
  end;
  StripBlanks := S;
end;

function CleanString(var S: String): String;
begin
  StripFrontChars(S, #32);
  StripBlanks(S);
end;

var
  S: String;
  i: Integer;
begin
  S := '   3   ';        { Create a bad string that will cause errors }
  CleanString(S);        { Clean it up                                }
  i := Str2Int(S);       { Convert                                    }
  WriteLn(i);            { Show it to the screen                      }
end.