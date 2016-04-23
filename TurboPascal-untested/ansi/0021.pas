{
MAYNARD PHILBROOK

> I am having troubles displaying an ANSI codes from a Text File. I can do it
> fine With the full screen, but I have trouble trying to do it Within a
> Window.  if I use the usual ASSIGN (Con, ''); WriteLn (Con, AnsiText);
> IT works fine, but not Within a Window.  The Con TextFile seems to ignore
> Window limitations, and I can understand that.  My question is how to get
> around it?  Do I have to use an ANSI Unit which converts ANSI codes to
> TP color codes?  I am looking For such a Unit, but is that the only

 TP Windows is Directly Writeln to the Screen memory, You can how ever
 Redirect Dos to a TP Window.
}

{$M 1024, 0, 1000}

Uses
  Dos, Crt;

Var
  Old_Vect : Pointer;

Procedure Redirect_OutPut(Character : Char); Interrupt;
begin
  Write(Character);
end;

begin
 GetIntVec($29, Old_Vect);        { Save Old Vector }
 SetIntVec($29, @Redirect_OutPut);
 Window(10, 3, 70, 20);
 Exec(' MainProgram ','');        { all output using WriteLn(Con,'????') }
 SetIntVec($29, Old_Vect);      { to this Window }
 Halt(DosError);
end;

