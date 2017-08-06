(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0018.PAS
  Description: Batch Error Level
  Author: SEAN PALMER
  Date: 08-27-93  20:13
*)

{
SEAN PALMER

> How would I use this Variable after I Exit the pascal Program??

You wouldn't. It won't work. What you COULD do though is to have it return an
errorlevel to Dos if you cancel...
}

Program ruSure;
Uses
  Crt;

Procedure yes;
begin
  TextAttr := 12;
  Writeln('Okay.');  {no error here}
end;

Procedure no;
begin
  TextAttr := 26;
  Writeln('Aborted.');
  halt(1);          {report an error to Dos}
end;

begin
  TextAttr := 13;
  Write('Do you wish to continue? [Y/N]');
  Case upcase(ReadKey) of
    'Y' : yes;
    'N' : no;
  end;
end.
{

 Now the batch file :

rusure
REM check For an error from the Program
if errorlevel 1 Goto NOPE
goto EXIT
:NOPE
cd ..
etc.
}
