
Uses CRT, DOS;

{-- read the character at the cursor and return it as a Char --}
Function ScreenChar : Char;
Var
R : Registers;
begin
   Fillchar(R, SizeOf(R), 0);
   R.AH := 8;
   R.BH := 0;
   Intr($10, R);
   ScreenChar := Chr(R.AL);
end;

{-- sample routine to read the screen and dump it to an ASCII file --}
{-- it uses ScreenChar ----}
Procedure DumpScreen;
Var
Num : Integer;
X1,Y1, x,y : Byte;
S   : String[79]; {- line length string; some prefer string[80] -}
Ch  : Char;
Buf : Array[1..25] of String[79]; {- buffer to hold the screen contents -}
F   : Text;
FName:String[79];

begin
   x1 := WhereX; y1 := WhereY; {- save present location of the cursor -}

   {- initialise the variables --}
   Num := 0;
   X := 1;
   Y := 1;
   S := '';
   FillChar(Buf, Sizeof(Buf), #0);

 {- do the stuff --}
 Repeat
   GotoXy(X,Y);         {-- start from top left of screen --}
   Inc(Num);            {-- increase line counter --}
   Ch := ScreenChar;    {-- read the character at screen location --}
   S := S+Ch;                {-- add it to temporary string --}

   Inc(X);                {-- goto next screen column -}
   If (Ch = #13) or (X = 79) Then {- CR, or end of screen-width-}
   begin
     X := 1;            {- back to column 1 -}
     Buf[Y] := s;       {- put the line in buffer (string array) -}
     s      := '';      {- empty the temporary string -}
     Inc(Y);            {- goto next line (row) -}
   end;
 Until (Num = 1975);    {- until we have read the screen (79*25 chars )-}

{-- write the buffer to a text file --}
 FName := 'SCREEN.SAV';
 Assign(F, FName);
 SetTextBuf(F, Buf);

 {$I-}
 Append(f); {- if the file exists, append buffer to it -}
{$I+}
  If IoResult <> 0 Then ReWrite(f); {- else create a new one -}

  For x := 1 to 25 do Writeln(F, Buf[x]); {- write it -}

{$I-}
  Close(F);
{$I+}
  If IoResult <> 0 Then;

  GotoXy(x1,y1); {- return to original location -}
end;

BEGIN
DumpScreen;
END.
