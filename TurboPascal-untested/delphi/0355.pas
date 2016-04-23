
Erik Sperling Johansen <erik@info-pro.no>
--------------------------------------------------------------------------------

function LowCase(ch : CHAR) : CHAR;
begin
  case ch of
    'A'..'Z' : LowCase := CHR (ORD(ch)+31);
  else
    LowCase := ch;
  end;
end;

function Proper (source, separators : STRING) : STRING;
var
  LastWasSeparator : BOOLEAN;
  ndx              : INTEGER;
begin
  LastWasSeparator := TRUE;  
  ndx := 1;
  while (ndx<=Length(source)) do begin
    if LastWasSeparator
    then source[ndx] := UpCase(source[ndx])
    else source[ndx] := LowCase(source[ndx]);
    LastWasSeparator := Pos(source[ndx], separators)>0;
    inc(ndx);
  end;
  Result := source;
end;

--------------------------------------------------------------------------------

From: "Cleon T. Bailey" <baileyct@ionet.net>
--------------------------------------------------------------------------------

Function  TfrmLoadProtocolTable.ToMixCase(InString: String): String;
Var I: Integer;
Begin
  Result := LowerCase(InString);
  Result[1] := UpCase(Result[1]);
  For I := 1 To Length(InString) - 1 Do Begin
    If (Result[I] = ' ') Or (Result[I] = '''') Or (Result[I] = '"')
    Or (Result[I] = '-') Or (Result[I] = '.')  Or (Result[I] = '(') Then
      Result[I + 1] := UpCase(Result[I + 1]);
  End;
End;

--------------------------------------------------------------------------------

From: "Paul Motyer" <paulm@linuxserver.pccity.com.au>

Both Tim Stannard's and Cleon T. Bailey's functions will bomb in D2 if sent an empty string (where accessing InString[1] causes an access violation, the second attempt will do the same if the last character is in the set.
try this instead:
--------------------------------------------------------------------------------

function proper(s:string):string;
var t:string;
    i:integer;
    newWord:boolean;
begin
if s='' then exit;
s:=lowercase(s);
t:=uppercase(s);
newWord:=true;
for i:=1 to length(s) do
    begin
    if newWord and (s[i] in ['a'..'z']) then
       begin s[i]:=t[i]; newWord:=false; continue; end;
    if s[i] in ['a'..'z',''''] then continue;
    newWord:=true;
    end;
result:=s;
end;
