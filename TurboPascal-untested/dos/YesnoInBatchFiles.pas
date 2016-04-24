(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0075.PAS
  Description: Yes/No in Batch files
  Author: RICK SCHAEFER
  Date: 08-24-94  17:57
*)


{
This is a VERY simple program to return an
errorlevel based on whether the user pressed Y or N at a Yes/No
prompt.  Has to be simple since the wife uses it.  :-)  I use it in my
batch files to branch to a different option depending on the user's
selection.


{  Yes/No Errorlevel returner v.000003432ß  }
{ Returns errorlevel depending on the key   }
{ chosen by the end user.                   }
{ by Rick Schaefer                          }
{ Donated to the public domain              }

Program YNExe;
        Uses Dos,
             Crt;
var
   YN : char;
   i  : integer;

   PROCEDURE Color(back, fore : BYTE);
   BEGIN
   TextAttr := (Fore + (Back SHL 4) ) MOD 128;
   END;

begin
     color(15,0);
     writeln;
     writeln;
     for i := 1 to paramcount do write(paramstr(i)+' ');
     write(' (Y/N)? ');
     YN := readkey;
     YN := upcase(YN);
     textcolor(14);
     writeln(yn);
     if (YN = 'Y') then halt(1);
     if (YN = 'N') then halt(0);
end.

