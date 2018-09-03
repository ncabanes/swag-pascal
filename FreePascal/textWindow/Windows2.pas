(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0005.PAS
  Description: WINDOWS2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:08
  
  Note: Shadow, SaveBox and RestoreBox omitted when porting
  to FreePascal
*)

Uses Crt;


Function CharS(Len:Byte; C: Char): String;
Var
  S: String;
begin                       { This Function returns a String of }
  FillChar(S, Len+1, C);    { Length Len and of Chars C.        }
  S[0] := Chr(Len);
  CharS := S;
end;

Function Center(X1, X2: Byte; S: String): Byte;
Var
  L, Max: Integer;
begin                           { This Function is used to center     }
  Max := (X2 - (X1-1)) div 2;   { a String between two X coordinates. }
  L := Length(S);
  if Odd(L) then Inc(L);
  Center := X1 + (Max - (L div 2));
end;


Procedure DrawBox(X1, Y1, X2, Y2: Integer; Attr: Byte; Title: String);
Var
  L, Y, X: Integer;
  S: String;

begin
  X := X2 - (X1-1);      { find box width  }
  Y := Y2 - (Y1-1);      { find box height }
  { draw box }
  S := Concat('+', CharS(X-2, '-'), '+');
  GotoXY(X1, Y1);
  TextAttr := Attr;
  Write(S);
  Title := Concat('= ', Title,' =');
  GotoXY(Center(X1, X2, Title), Y1);
  Write(Title);
  For L := 2 to (Y-1) do
    begin
      GotoXY(X1, Y1+L-1);
      Write('|', CharS(X-2, ' '), '|');
    end;
  GotoXY(X1, Y2);
   Write('+', CharS(X-2, '-'), '+');

end;


Procedure Hello;
begin
  { note, that if you use shadow, save an xtra 2 columns
    and 1 line to accomadate what Shadow does }
   {             V   V   }
  DrawBox(7, 7, 71, 13, $4F, 'Hello');
  GotoXY(9, 9);
  Write('Hello Terry! I hope this is what you were asking For.');
  GotoXY(9, 11);
  Write('Press Enter');
  While ReadKey <> #13 do;
end;

Procedure Disclaimer;
begin
  DrawBox(5, 5, 75, 20, $1F, 'DISCLAIMER');
  Window(7, 7, 73, 19);
  Writeln('  Seeing as I came up With these Procedures For');
  Writeln('my own future Programs (I just recently wrote these)');
  Writeln('please don''t Forget who wrote them originally if you');
  Writeln('decide to use them in your own.  Maybe a ''thanks to Eric Miller');
  Writeln('For Window routines'' somewhere in your doCs?');
  Writeln;
  Writeln('  Also, if anyone can streamline this source, well, I''d');
  Writeln('I''d like to see it...not that too much can be done.');
  Writeln;
  Writeln('                    Eric Miller');
  Window(1,1,80,25);
  Hello;
  TextAttr := $1F;
  GotoXY(9, 18);
  Writeln('Press Enter...');
  While ReadKey <> #13 do;

end;

begin
  TextAttr := $3F;
  ClrScr;
  Disclaimer;
end.
