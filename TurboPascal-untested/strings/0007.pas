today class we are looking at some String routines. Routines to
convert Strings to upper Case, lower Case,etc.

Remember to turn off CHECK String Var PARAMETER LENGTHS With {$V-}
beFore calling the String Procedures. Turn it back on after calling
this proc.

{--[UPPER CASinG StringS]--}

Procedure UPCaseL(Var CString:String);

Var I:Byte;

 begin
   For I:=1 to LENGTH(CString) do CString[I]:=UPCase(CString[I])
 end;

{--[LOWER CASinG CharS]--}

Function DWNCase(DWNCH:Char):Char;

begin
if ('A' <= DWNCH) and (DWNCH <= 'z') then DWNCase:=CHR(orD(DWNCH)+32)
end;

{--[LOWER CASinG StringS]--}

Procedure DWNCaseL(Var CString:String);

Var I:Byte;

begin
  For I:=1 to LENGTH(CString) do CString[I]:=DWNCase(CString[I])
end;

--------------
if you are offended at the subject line, then please don't read the
message. if you think that I, TL, am calling you an idiot because my
subject line said IDIOT PASCAL LESSONS and you read this message...
well, hey, I'm not.
-------------
