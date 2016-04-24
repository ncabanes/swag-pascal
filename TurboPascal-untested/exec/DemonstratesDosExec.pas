(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0004.PAS
  Description: Demonstrates DOS Exec
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:51
*)

{$M 8192,0,0}
{* This memory directive is used to make
   certain there is enough memory left
   to execute the DOS shell and any
   other programs needed.  *}

Program EXEC_Demo;

{*

  EXEC.PAS

  This program demonstrates the use of
  Pascal's EXEC function to execute
  either an individual DOS command or
  to move into a DOS Shell.

  You may enter any command you could
  normally enter at a DOS prompt and
  it will execute.  You may also hit
  RETURN without entering anything and
  you will enter into a DOS Shell, from
  which you can exit by typing EXIT.

  The program stops when you hit a
  'Q', upper or lower case.
*}


Uses Crt, Dos;

Var
  Command : String;

{**************************************}
Procedure Do_Exec; {*******************}

  Var
    Ch : Char;

  Begin
    If Command <> '' Then
      Command := '/C' + Command
    Else
      Writeln('Type EXIT to return from the DOS Shell.');
    {* The /C prefix is needed to
       execute any command other than
       the complete DOS Shell. *}

    SwapVectors;
    Exec(GetEnv('COMSPEC'), Command);
    {* GetEnv is used to read COMSPEC
       from the DOS environment so the
       program knows the correct path
       to COMMAND.COM. *}

    SwapVectors;
    Writeln;
    Writeln('DOS Error = ',DosError);
    If DosError <> 0 Then
      Writeln('Could not execute COMMAND.COM');
    {* We're assuming that the only
       reason DosError would be something
       other than 0 is if it couldn't
       find the COMMAND.COM, but there
       are other errors that can occur,
       we just haven't provided for them
       here. *}

    Writeln;
    Writeln;
    Writeln('Hit any key to continue...');
    Ch := ReadKey;
  End;


Function Get_Command : String;

  Var
    Count : Integer;
    Cmnd : String;

  Begin
    Clrscr;
    Write('Enter DOS Command (or Q to Quit): ');
    Readln(Cmnd);
    Get_Command := Cmnd
  End;

Begin
  Command := Get_Command;
  While NOT ((Command = 'Q') OR (Command = 'q')) Do
    Begin
      Do_Exec;
      Command := Get_Command
    End;
End.
