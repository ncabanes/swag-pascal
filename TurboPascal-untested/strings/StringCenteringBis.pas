(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0026.PAS
  Description: String Centering
  Author: GUY MCLOUGHLIN
  Date: 08-27-93  20:24
*)

{
GUY MCLOUGHLIN

>What's the easiest way to center an arbitrary string on a line?
}

program CenterStringDemo;

{ Return a copy of the MainString, with the SubString centered     }
{ within it. Routine passes copies of variables on the STACK,      }
{ taking up more STACK space than the one below, however variable  }
{ strings passed as parameters are not permanently changed.        }
{                                                                  }
function CenterStr1(MainString, SubString : String) : String;
Var
  InsertPos  : byte;
  TempString : string;
begin
  TempString := MainString;
  InsertPos  := succ((length(MainString) - length(SubString)) div 2);
  move(SubString[1], TempString[InsertPos], length(SubString));
  CenterStr1 := TempString;
end;

{ Center a sub-string withing the main-string. Routine uses VAR    }
{ parameters which pass pointers to the actual variable being      }
{ passed, making the changes permanent and saving on STACK space.  }
{                                                                  }
procedure CenterStr2(var MainString : string; var SubString : string);
var
  InsertPos : byte;
begin
  InsertPos := succ((length(MainString) - length(SubString)) div 2);
  move(SubString[1], MainString[InsertPos], length(SubString))
end;


var
  SubStr,
  MainStr,
  TempStr : string;

BEGIN
  SubStr  := '----------';
  MainStr := '012345678901234567890123456789';
  { Return string with sub-string centered in main-      }
  { string. Neither sub-string or main-string variables  }
  { are permanently affected.                            }
  TempStr := CenterStr1(MainStr, SubStr);
  writeln(SubStr);
  writeln(MainStr);
  writeln(TempStr);
  writeln;

  { Position sub-string in the center of main-string.    }
  { Changes to main-string are permanent.                }
  CenterStr2(MainStr, SubStr);
  writeln(SubStr);
  writeln(MainStr);
  writeln(TempStr)
END.


