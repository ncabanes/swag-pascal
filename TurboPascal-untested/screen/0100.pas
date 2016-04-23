
PROGRAM Example;
USES Crt,Dos;

{ +-----------------------------------------------------------------+ )
  | PROCEDURE ScrollStr(message:string;x,y,bckcol,txtcol,highlight, |
  |                     dlay,waitkey:word);                         |
  +-----------------------------------------------------------------+
  |   message   = message to be displayed (length = 2..75)          |
  |   x,y       = screen location (1..80, 1..25)                    |
  |   bckcol    = background color (0..7)                           |
  |   txtcol    = text color       (0..15)                          |
  |   highlight = highlight color  (0..15)                          |
  |   dlay      = time delay (milliseconds) (0..)                   |
  |   waitkey   = 0 - cycle once only                               |
  |               1 - continue cycle until a key is hit             |
  +-----------------------------------------------------------------+
  |  By Timothy M. Lasek - Electronic Exchange BBS @(315)786-0215   |
( +-----------------------------------------------------------------+ }

procedure ScrollStr(message:string;x,y,bckcol,txtcol,highlight,
                    dlay,waitkey:word);
var l,direction: byte;
    regs: registers;
    c: char;
begin
  regs.ax:= $0100; regs.cx:= $2607; intr($10,regs);   { hide cursor }
  direction:= 1;  l:= 1;
  gotoxy(x,y);
  textattr:= txtcol+bckcol*16;
  write(message);
  while (keypressed=FALSE) AND (direction>0) do
  begin
     if direction=1 then
       begin
         inc(l);
         if l=length(message) then direction:= 2;
       end else
       begin
         dec(l);
         if l=1 then direction:= 1;
         if (WaitKey=0) AND (direction=1) then
         begin
           direction:=0;
           gotoxy(x,y);
           textattr:= highlight+bckcol*16;
           write(message[1]);
           delay(dlay);
         end;
       end;
     if direction>0 then
     begin
       gotoxy(x+(l-1),y);
       textattr:= highlight+bckcol*16;
       c:= message[l];
       if (c>#96) AND (c<#123)
         then c:= chr(ord(c)-32);
       write(c);
       textattr:= txtcol+bckcol*16;
       delay(dlay);
       gotoxy(x+(l-1),y);
       write(message[l]);
     end;
  end;
  gotoxy(x,y);
  textattr:= txtcol+bckcol*16;
  writeln(message);
  regs.ax:= $0100; regs.cx:= $0506; intr($10,regs);   { restore cursor }
end;

BEGIN { Main Module }
  clrscr;
  ScrollStr('SOURCEWARE ARCHIVE GROUP HAS BEEN HERE',1,1,black,lightred,white,110,1);
END.  { Main Module }
