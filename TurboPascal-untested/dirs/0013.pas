{
    Hi Mark, there is a Procedure in Turbo Pascal called MkDir that allows
you to create a subdirectory. However if you want source code For a similar
routine try the following. I just whipped it up so it doesn't contain any
error checking, but you could add a simple if else after the Dos call to
check the register flags. Anyhow, I hope that this helps ya out.
}
Procedure Make_Directory (Directory: String);
{ parameters:  Directory - name of the new directory
  sample-call: Make_Directory('\tools') }
Var
    Regs: Registers;
begin
  With Regs do
  begin
    Directory := Directory + chr(0);
    AX := $3900;
    DS := Seg(Directory[1]);
    DX := ofs(Directory[1]);
    MSDos(Dos.Registers(Regs));
  end;
end;
