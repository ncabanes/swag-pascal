{
The reason is because when you are using the CRT unit, the write() and
writeln() commands use direct writes.  Direct writes?  Direct writes are
direct writes to video memory (at $b800:0000), not going through BIOS.
Therefore, ANSI.SYS never even SEES what you write to the screen when
the CRT unit is being used, and therefore cannot interperate the ansi
sequences as colors, cursor movements, and so on.  So if you want to use
ANSI.SYS to decode your ansi screens, but also want to have the CRT unit
installed, you must make your own "write()" type procedure which doesn't
go directly to the screen.  Here is one:

procedure ansiwrite(c:char); assembler;
asm
  mov ah,2
  mov dl,c
  int 21h
end;

To display an ansi using this procedure, give it one character at a time.
However, this is going to be extremely slow.  Using this same code (with a
small amount of modification and additional junk), you could speed up the
ansi file displaying process dramatically.  Here is an example program, all
tested, that will display an ansi, with the CRT unit installed, quickly...
I'm sure someone out there has got a better way, but this is the quickest
that I know of.  :)

{ -- CUT HERE -- }

program displayansi;

uses crt;

var buf:array[1..1024] of char; nr,n:word; f:file;

begin
  IF Paramcount > 0 THEN
  BEGIN
  assign(f,paramStr(1));
  reset(f,1);
  repeat
    blockread(f,buf,sizeof(buf),nr);
    asm
      mov cx,0               { set our counter to zero }
      @1:                    { top of loop marker }
      add cx,1               { increase it by one }
      cmp cx,nr              { compare CX to nr }
      jg  @2                 { CX greater than nr, jump to @2 }
      mov bx,cx              { move CX into BX }
      mov si,offset buf      { move "buf" offset into SI }
      mov dl,[si+bx-1]       { copy byte from "buf" into DL }
      mov ah,2               { function 2 into AH }
      int 21h                { call interrupt 21h }
      jmp @1                 { jump back to @1 and start over - loop }
      @2:                    { asm loop ends here }
    end;
  until (nr=0);
  close(f);
  END;
end.

