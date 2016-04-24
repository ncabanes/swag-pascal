(*
  Category: SWAG Title: DOS REDIRECTION ROUTINES
  Original name: 0004.PAS
  Description: REDIRCT2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

{
> When pkzip executes... it Writes to the screen and scrolls my
> screen up. Is there a way in which I can prevent pkzip from writing
> to the screen.

This thread comes up a bunch.  Here's a tried and tested solution :
}
Unit Redir;

{ Redirect input, output, and errors }

Interface

Procedure RedirectInput (TextFile : String);
Procedure RedirectOutput (TextFile : String);
Procedure StdInput;
Procedure StdOutput;

Implementation

Uses
  Dos;

Const
    STDin  = 0;
    STdoUT = 1;
    STDERR = 2;

Procedure Force_Dup (Existing,              { Existing handle         }
                     Second     : Word);    { Handle to place it to   }

Var
  R : Registers;

begin

    r.AH := $46;
    r.BX := Existing;
    r.CX := Second;

    MSDos (R);

    if (r.Flags and FCarry) <> 0 then
        Writeln ('Error ', r.AX, ' changing handle ', Second);
end;


Procedure RedirectInput (TextFile : String);

Var
    TF : Text;

begin
    Assign (TF, TextFile);
    Reset (TF);
    Force_Dup (TextRec (TF).Handle, STDin);
end;

Procedure RedirectOutput (TextFile : String);

Var
    TF : Text;

begin
    Assign (TF, TextFile);
    ReWrite (TF);
    Force_Dup (TextRec (TF).Handle, STdoUT);
    Force_Dup (TextRec (TF).Handle, STDERR);
end;

Procedure StdInput;

begin
    Assign (Input, '');
    Reset (Input);
end;

Procedure StdOutPut;

begin
    Assign (Output, '');
    ReWrite (Output);
end;

end.

{------ cut here ------}
{
In your Program :

Uses Redir;

begin
     RedirectOutput ('LOGFile.OUT');
     Exec ('PKZIP.EXE', '');
     StdOutPut;
end.
}
