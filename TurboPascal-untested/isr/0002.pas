{
REYNIR STEFANSSON

> I need a Procedure in the form of:
> Type DelayHook = Function : Boolean;
> Procedure DelayIt(S : Word; Hook : DelayHook);

> What it needs to do is keep calling the hook Function Until it returns
> True or the number of 1/100th's of seconds, S, is up.

> Any ideas?  I know how to call the Hook Function, but I am concerned With
> how to go about keeping up With the time Without using the Crt.Delay
> Procedure. I am using this to play a tune (with Sound and NoSound) through
> the speaker and quit when the user presses a key.  The tune is read from
> a Text File of unknown length.  HELP!

{ More or less outta my head... }

Uses
  Dos;

Type
  Reg       : Registers;
  DelayHook : Function : Boolean;

{
   This proc Uses the AT BIOS' Wait Function: INT 15h, FUNC 86h. It's
   called With a LongInt in CX:DX. Its resolution is ca. 1 microsecond.
}

Procedure DelayIt(S : Word; Hook : DelayHook);
Var
  dly : LongInt;
  bdy : Boolean;
begin
  Repeat
    Reg.AH := $86;
    Reg.CX := 0;
    Reg.DX := 10000; { Wait 0.01 sec. }
    Intr($15, Reg);
  Until Hook;
end;
