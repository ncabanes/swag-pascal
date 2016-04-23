{
Now, I could go in and edit the File by hand...( But I do have a
life )  So I still am asking is it possible to find some sort of
TPU stripper Program to cut out the other sections While keeping
the needed bits still working...

  The only thing that comes to mind is building an Interface shell
  Unit, that calls the routines you want to include from your main
  Unit. User's can then ignore your main Compiled .TPU that will
  be required to Compile With your shell Unit. For example here's
  a shell Unit that Uses the ClrScr Procedure from the standard
  TP Crt Unit:
}

Unit MyCrt;
Interface

Procedure ClrScr;

Implementation

Uses
  Crt;

Procedure ClrScr;
begin
  Crt.ClrScr
end;

end.
