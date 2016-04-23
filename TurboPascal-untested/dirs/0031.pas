{
> browsing. Q59 (How do you hide a directory?) leapt out at me as it's
something

Q53 actually.

> I have been trying to do for ages. However on closer examination the
'solution'
> proved to be calling the SETFATTR function (either directly or through it's
> DOS interrupt.) This worried me- I am SURE I tried this, and without
success.
> It worked fine for ordinary files, but NOT directories. In fact I have a

That's very strange since I have no problems when I test
}

uses Dos;

procedure HIDE (dirname : string);
var regs : registers;
begin
  FillChar (regs, SizeOf(regs), 0);
  dirname := dirname + #0;
  regs.ah := $43;
  regs.al := $01;
  regs.ds := Seg(dirname[1]);
  regs.dx := Ofs(dirname[1]);
  regs.cx := 2; { set bit 1 on }
  Intr ($21, regs);
  if regs.Flags and FCarry <> 0 then
    writeln ('Failed to hide');
end;  (* hide *)

begin
  HIDE ('r:\tmpdir');
end.
