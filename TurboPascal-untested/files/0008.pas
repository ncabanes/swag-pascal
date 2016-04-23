Program ShareVolation;
Uses Dos,Crt;
Var
  Dummy:    Boolean;

Function FileOpen(F:String):Boolean;
Var
  Regs: Registers;
  I:    Byte;
begin
  With Regs do
  begin
    Ah := $3d;
    Al := 2;
    Ds := Seg(F);
    Dx := Ofs(F)+1;
  end;
  Intr($21,Regs);

  WriteLn(F,' open: ',Regs.Ax = 5);
  FileOpen := (Regs.Ax = 5);
end; { FileOpen }

begin
  Dummy := FileOpen('D:\FILSHARE.EXE'+#0);
  Dummy := FileOpen('C:\CONFIG.SYS'+#0);
  Dummy := FileOpen('C:\IO.SYS'+#0);
  Dummy := FileOpen('C:\MSDos.SYS'+#0);
end.

{
And the funny thing was that it worked..
(But it returns error code 6 [Invalide handle] on closed Files)..
}