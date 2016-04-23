
Below is a function I'm using in a program I'm writing.  What it will do is
take a given string in the form 1-1/2 and convert it from a mixed number
into a floating point number. (e.g. 1-1/2 to 1.5)  I was wondering if there
was a better way to implement it than the way I have below.  (It's ugly, but
it works.)  The program is being written in Delphi 1.02 (but Pascal is
Pascal, no matter how one looks at it.  :-)

I'd much rather force people to just input a friggin' decimal,
unfortunately, the databases are old and have already been saved.  Anyway,
code snippet to follow.

 Begin
  function FracToFloat(Incoming : string): Single;
    var i : integer;
    begin
      Incoming := Trim(Incoming);
      i := Pos('-',Incoming);
      if i = 0 then begin
        try Result := StrToFloat(Incoming);
        except
          on EConvertError do Result := 0.0;
        end;
        exit;
      end;
      Result := StrToFloat(Copy(Incoming,1,i-1));
      Incoming := Copy(Incoming,i+1,Length(Incoming)-i);
      i := Pos('/',Incoming);
      Result := Result + StrToInt(Copy(Incoming,1,i-1))/
		StrToInt(Copy(Incoming,i+1,Length(Incoming)-i));
    end;
End

BTW, the Trim function (in the first line of the proc body) is my own
creation for Delphi.  It yanks out ALL spaces, not just leading/trailing.

Program FractionalStrings;
{ written in Turbo v.6.0  <clifpenn@airmail.net>  Nov 3, 1996
  Accepts string input of the form 5-3/4 and converts to a floating
  point number. However, '  ab  cd.xx5nmjk---3   xxx///cc  4  ***'
will be cleaned up to show 5-3/4 = 5.75000, also. Will not convert
negative numbers as written but is trivial to change. }

VAR
s:String;
p1, p2:Byte;
proper:Boolean;

Function FracToFloat(Incoming:String):Single;
VAR
      frag:Array[1..3] of String[10];
      NumVal:Array[1..3] of Byte;
      p, indx:Byte;
      code:Integer;  (* required for VAL *)
                     (* may be used for error checking *)
Begin
     Incoming := Incoming + ' ';   (* for convenience *)
     (* remove non-numeric leading chars including spaces *)
     While Not (Incoming[1] in ['0'..'9']) Do
           Delete(Incoming, 1, 1);

     p := 1;
     For indx := 1 to 3 Do
     Begin
          frag[indx] := '';
          While Incoming[p] in ['0'..'9'] do
          Begin
               frag[indx] := frag[indx] + Incoming[p];
               Inc(p);
          End;
          VAL(frag[indx], NumVal[indx], code);
          If indx < 3 then  (* skip non-numeric *)
              While Not(Incoming[p] in ['0'..'9']) Do Inc(p);
     End;
     (* show cleaned input *)
     Write(frag[1], '-', frag[2], '/', frag[3], ' = ' );
     FracToFloat := NumVal[1] + NumVal[2] / NumVal[3];
End;

Begin
     Writeln; Writeln;
     Writeln('Just press <Enter> to quit');
Repeat

     Repeat
           Writeln;
           Write('Enter a mixed fraction such as 5-3/4: ');
           Readln(s);
           If Length(s) = 0 then exit;
           p1 := Pos('-', s);
           p2 := Pos('/', s);
           proper := (p1 > 0) AND (p2 > p1);
           If not proper then Write(Chr(7));  (* beep *)
     Until proper;

     Writeln(FracToFloat(s):10:5);
Until Length(s) = 0;
End.

