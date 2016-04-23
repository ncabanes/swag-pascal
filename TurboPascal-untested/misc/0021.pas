{
Here is a VERY simple source-code mangler that I just made. It simply:

1) Removes whitespace,
2) Removes comments (but not Compiler-directives!),
3) Makes everything upper-Case.
4) Make lines max. 127 Chars wide (max. For Turbo Pascal),
5) Doesn't mess up literal Strings :-)

I don't imagine that this is anything Near perfect - but it's better than
nothing...

}

Program Mangler;

Const
  Alpha : Set of Char = ['a'..'z', 'A'..'Z', '0'..'9'];

Var
  F, F2 : Text;
  R, S : String;
  X : Byte;
  InString : Boolean;

Function NumChar(C : Char; S : String; Max : Byte) : Byte;
Var
  N, Y : Byte;
begin
  N := 0;
  For Y := 1 to Max do
    if S[Y] = C then Inc(N);
  NumChar := N;
end;

Function TrimF(T : String) : String;
Var
  T2 : String;
begin
  T2 := T;
  While (Length(T2) > 0) and (T2[1] = ' ') do
    Delete(T2, 1, 1);
  TrimF := T2;
end;

Function Trim(T : String) : String;
Var
  T2 : String;
begin
  T2 := TrimF(T);
  While (Length(T2) > 0) and (T2[Length(T2)] = ' ') do
    Delete(T2, Length(T2), 1);
  Trim := T2;
end;

Procedure StripComments(Var T : String);
Var
  Y : Byte;
  Rem : Boolean;
begin
  Rem := True;
  if Pos('(*', T) > 0 then
  begin
    For Y := Pos('(*', T) to Pos('*)', T) do
      if (T[Y] = '$') or (T[Y] = '''') then
        Rem := False;
    if (Rem) and (not Odd(NumChar('''', T, Pos('(*', T)))) then
      Delete(T, Pos('(*', T), Pos('*)', T)+2-Pos('(*', T));
  end;
  if Pos('{', T) > 0 then
  begin
    For Y := Pos('{', T) to Pos('}', T) do
      if (T[Y] = '$') or (T[Y] = '''') then
        Rem := False;
    if (Rem) and (not Odd(NumChar('''', T, Pos('(*', T)))) then
      Delete(T, Pos('{', T), Pos('}', T)+1-Pos('{', T));
  end;
end;

begin
  ReadLn(S);
  Assign(F, S);
  Reset(F);
  ReadLn(S);
  Assign(F2, S);
  ReWrite(F2);
  R := '';
  S := '';

  While not EoF(F) do
  begin
    ReadLn(F, R);
    StripComments(R);
    R := Trim(R);
    X := 1;
    While X <= Length(R) do
    begin
      InString := (R[X] = '''') xor InString;
      if not InString then
      begin
        if R[X] = #9 then
          R[X] := ' ';
        if ((R[X] = ' ') and (R[X+1] = ' ')) then
        begin
          Delete(R, X, 1);
          if X > 1 then
            Dec(X);
        end;
        if ((R[X] = ' ') and not(R[X+1] in Alpha)) then
          Delete(R, X, 1);
        if ((R[X+1] = ' ') and not(R[X] in Alpha)) then
          Delete(R, X+1, 1);
        R[X] := UpCase(R[X]);
      end;
      Inc(X);
    end;
    if (Length(R) > 0) and (R[Length(R)] <> ';') then
      R := R+' ';
    if Length(R)+Length(S) <= 127 then
      S := TrimF(S+R)
    else
    begin
      WriteLn(F2, Trim(S));
      S := TrimF(R);
    end;
  end;

  WriteLn(F2, S);
  Close(F);
  Close(F2);
end.
{
 > 1) Remove whitespace.
Just removes indentation now.
 > 2) Put lines together (max. length approx. 120 Chars).
This is going to be one of the harder parts.
 > 3) Make everything lower-Case (or upper-Case).
No need.. see 4.
4.  Convert all Types, Consts, and VarS to an encypted name, like so:
     IIl0lll1O0lI1
5.  Convert all Procedures, and Functions like #4
6.  On Objects, Convert all "data" fields.  Leave alone all others except For
the "ConstRUCtoR" and on that, only check to see if any Types are being used.
Constructors are the only ones that can change from the ancestor.
7.  on Records, When Typed like this:
aRec.Name:='Rob Green';  check to see if arec is in the list, if not, skip.
if like this:
   With arec do
     name:='Rob Green';  do the same as above, but check For begin and end.
8.  Leave externals alone.
9.  Also mangle the Includes.
10. Leave Any Interface part alone, and only work With the Implementation.
This is what my mangler currently does.(all except For #7 and #10, havent got
that Far yet.)  Any ways it works pretty good.  im happy With the results i
am getting With it.  It makes it "VERY" hard to read.  The only thing i see
having trouble With down the line, is the "Compressing" of mulitiple lines.

Anyways, heres a small Program, and then what PAM(Pascal automatic mangler)
did to it:
}

Program test;

Type
   pstr30 = ^str30;
   str30  = String[30];

Var
   b : Byte;
   s : pstr30;

Function hex(b : Byte) : String;
Const
   Digits : Array [0..15] of Char = '0123456789ABCDEF';
Var
   s:String;
begin
   s:='';
   s[0] := #2;
   s[1] := Digits [b shr 4];
   s[2] := Digits [b and $F];
   hex:=s;
end;

begin
   new(s);
   s^:='Hello world';
   Writeln(s^);
   Writeln('Enter a Byte to convert to hex:');
   readln(b);
   s^:=hex(b);
   Writeln('Byte :',b,' = $',s^);
   dispose(s);
end.


Program test;
Type
  IO1II0IO00O = ^II0lOl1011I;
  II0lOl1011I = String[30];
Var
  III0O1ll10l:Byte;
  I11110I11Il0:IO1II0IO00O;

Function Il00O011IO0I(III0O1ll10l:Byte):String;
Const
  Illl1OOOO0I : Array [0..15] of Char = '0123456789ABCDEF';
Var
  I11110I11Il0:String;
begin
  I11110I11Il0:='';
  I11110I11Il0[0] := #2;
  I11110I11Il0[1] := Illl1OOOO0I [III0O1ll10l shr 4];
  I11110I11Il0[2] := Illl1OOOO0I [III0O1ll10l and $F];
  Il00O011IO0I:=I11110I11Il0;
end;
begin
  new(I11110I11Il0);
  I11110I11Il0^:='Hello world';
  Writeln(I11110I11Il0^);
  Writeln('Enter a Byte to convert to hex:');
  readln(III0O1ll10l);
  I11110I11Il0^:=Il00O011IO0I(III0O1ll10l);
  Writeln('Byte :',III0O1ll10l,' = $',I11110I11Il0^);
  dispose(I11110I11Il0);
end.

