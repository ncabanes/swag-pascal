{
TREVOR@wordperfect.com

Below is a dinky program to start a os/2 program from a os/2 dos window.
It's pretty ugly right now, but it works fairly well.  I dug this up by
debugging VIEW.EXE, so there may be errors or omissions.  Anyone can have
this, feel free to mutilate it in any way you wish.
}

program dosstart;

var
  buf   : array[0..8] of PChar;
  dir,
  title,
  fname,
  opts  : string;
  i     : integer;
begin
  if paramcount > 0 then
  begin
    fillchar(buf, sizeof(buf), 0);
    buf[0] := ptr(0, $20);
    title  := 'Blah blah: ' + paramstr(1) + #0;   { window title }
    buf[2] := @title[1];
    fname  := paramstr(1);
    fname  := fname + #0;
    buf[3] := @fname[1];
    if paramcount > 1 then
    begin
      opts := '';
      for i := 2 to paramcount do
        opts := opts + paramstr(i);
      opts := opts + #0;
      buf[4] := @opts[1];
    end;
    asm
      mov ax, 6400h
      mov bx, 0025h
      mov cx, 636ch
      mov si, offset buf
      int 21h
    end;
  end
  else
  begin
    writeln('USAGE:');
    writeln('   DOSSTART.EXE OS2PROG [OS2PROG_OPTIONS]');
    writeln;
  end;
end.

