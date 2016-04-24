(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0071.PAS
  Description: Large Virtual Text Screen
  Author: MICHAEL NICOLAI
  Date: 11-26-94  05:06
*)

{
> I just let dos write something on the screen, I'm in the normal
> videomode, say that writes 100 lines to the screen. How can I read
> whatever that program wrote if the lines have scrolled of the screen ???
> I need to have the output in an array ... with the colors ... there might
> even be an animation in the output (ansi) ... I know how to put a normal
> 25x80 in an array or a 50x80 ... but how do you work with something
> that's 100 lines long ... I want to be able to scroll back after the
> display ...

You can use an Array to do it - or, you can program your graphic-card. :-)

Perhaps this little prog will give you a clue:
}

program BreakOut;

uses CRT, DOS;

const

 UP   = 0;   { Verschieberichtung fuer Bildschirm. }
 DOWN = 1;
 ST_X = 10;  { Steine nebeneinander. }
 ST_Y = 5;   { Steine uebereinander. }

type

 screen_params = record
  zeichen  : char;
  attribut : byte;
 end;

 Video_params = record
  mode, page     : byte;
  start_scanline : byte;
  end_scanline   : byte;
  row, column    : byte;
 end;

 stone_params = record
  spalte : byte;
  zeile  : byte;
 end;

 bouncer_params = record  { bouncer == schlaeger }
  spalte : shortint;
  zeile  : shortint;
  dir    : shortint;
  speed  : longint;
  count  : longint;
 end;

 ball_params = record
  spalte : real;
  zeile  : real;
  speed  : longint;
  count  : longint;
  dir_x  : real;
  dir_y  : real;
  next_x : real;
  next_y : real;
  last_x : real;
  last_y : real;
  flag   : byte;
 end;

 screen_type = array [1..2000] of screen_params;

var

 regs    : Registers;
 Video   : Video_params;
 bouncer : bouncer_params;
 ball    : ball_params;
 stone   : array [1..ST_X,1..ST_Y] of stone_params;
 screen  : ^screen_type;  { Zeiger auf aktuelle Seite. }
 screen0 : pointer;       { Zeiger auf Seite 0. }
 screen1 : pointer;       { Zeiger auf Seite 1. }
 screen2 : pointer;       { Zeiger auf Seite 2. }

procedure GetCurrentVideoMode;
{
 Procedure to get and store the current video mode settings.
}

begin
 regs.ah := $0F;
 intr($10, regs);
 Video.mode := regs.al;
 Video.page := regs.bh;
end;

procedure GetCurrentCursorSettings;
{
 Procedure to get and store the current cursor settings.
}

begin
 regs.ah := 3;
 regs.bh := Video.page;
 intr($10, regs);
 Video.start_scanline := regs.ch;
 Video.end_scanline := regs.cl;
 Video.row := regs.dh;
 Video.column := regs.dl;
end;

procedure SetVideoMode(mode : byte);
{
 Procedure to set a specific video mode.

 mode = new video mode.
}

begin
 regs.ah := 0;
 regs.al := mode;
 intr($10, regs);
end;

procedure HideCursor;
{
 Procedure to make the cursor invisible on the screen.
}

begin
 regs.ah := 1;
 regs.al := Video.mode;
 regs.cx := $FFFF;
 intr($10, regs);
end;

procedure RestoreCursor;
{
 Procedure to restore the old cursor.
}

begin
 regs.ah := 1;
 regs.al := Video.mode;
 regs.ch := Video.start_scanline;
 regs.cl := Video.end_scanline;
 intr($10, regs);
end;

procedure ClearScreen;

var

 i : integer;

begin
 for i := 1 to 2000 do
 begin
  screen^[i].zeichen := #32;
  screen^[i].attribut := 7;
 end;
end;

procedure DrawBorder;

var

 i : integer;

begin
 for i := 1 to 80 do
  screen^[i].attribut := $30;
 for i := 81 to 1920 do  { 1920 = 2000 - 80 }
 begin
  screen^[i].attribut := $30;
  i := i + 79;
  screen^[i].attribut := $30;
 end;
end;

procedure InitializeStones;

var

 i, j : byte;
 x, y : byte;  { x = Spalte; y = Zeile }

begin
 y := 4;
 for i := 1 to ST_Y do  { Zeilen }
 begin
  x := 7;
  for j := 1 to ST_X do  { Spalten }
  begin
   stone[j, i].spalte := x;
   stone[j, i].zeile := y;
   x := x + 7;
  end;
  y := y + 2;
 end;
end;

procedure DrawStones;

var

 pos     : integer;
 i, j, k : byte;

begin
 for i := 1 to ST_Y do  { Zeilen }
 begin
  for j := 1 to ST_X do  { Spalten }
  begin
   pos := stone[j, i].zeile * 80 + stone[j, i].spalte;
   for k := 0 to 4 do
    screen^[(pos + k)].attribut := $60;
  end;
 end;
end;

procedure DrawBouncer;

var

 i   : integer;
 pos : integer;

begin
 pos := bouncer.zeile * 80 + bouncer.spalte - 1;
 screen^[pos].attribut := 7;
 for i := 1 to 8 do
  screen^[(pos + i)].attribut := $70;
 screen^[(pos + 9)].attribut := 7;
end;

procedure DrawBall;

var

 pos : integer;

begin
 pos := integer(trunc(ball.last_y) * 80 + trunc(ball.last_x));
 screen^[pos].zeichen := #32;
 screen^[pos].attribut := 7;
 pos := integer(trunc(ball.zeile) * 80 + trunc(ball.spalte));
 screen^[pos].zeichen := 'o';
 screen^[pos].attribut := 5;
 ball.last_x := ball.spalte;
 ball.last_y := ball.zeile;
 ball.next_x := ball.spalte + ball.dir_x;
 ball.next_y := ball.zeile + ball.dir_y;
end;

procedure MovePicture(scr : pointer; direction : byte);

var

 dir     : integer;
 count   : word;
 zaehler : word;

begin
 zaehler := ofs(screen^) shr 1;
 port[$03D4] := $0C;
 port[$03D5] := hi(zaehler);
 port[$03D4] := $0D;
 port[$03D5] := lo(zaehler);
 if (direction = UP) then
  dir := 80
 else
  dir := (-80);
 count := 0;
 repeat
  inc(count);
  zaehler := zaehler + dir;
  port[$03D4] := $0C;
  port[$03D5] := hi(zaehler);
  port[$03D4] := $0D;
  port[$03D5] := lo(zaehler);
  delay(20);
 until (count = 25);
 screen := scr;
end;

function MoveBouncer : byte;

var

 c : char;

begin
 bouncer.count := bouncer.count - 1;
 if (bouncer.count = 0) then
 begin
  bouncer.count := bouncer.speed;
  if (keypressed) then
  begin
   c := readkey;
   case c of
    #0  : begin
           c := readkey;
           case c of
            #75 : bouncer.dir := (-1);
            #77 : bouncer.dir := 1;
           end;
          end;
    #27 : begin
           MoveBouncer := 1;
           exit;
          end;
    #32 : bouncer.dir := 0;
   end;
  end;
  bouncer.spalte := bouncer.spalte + bouncer.dir;
  if (bouncer.spalte < 2) then
  begin
   bouncer.spalte := 2;
   bouncer.dir := 0;
  end;
  if (bouncer.spalte = 73) then
  begin
   bouncer.spalte := 72;
   bouncer.dir := 0;
  end;
  if (bouncer.dir <> 0) then
   DrawBouncer;
 end;
 MoveBouncer := 0;
end;

procedure MoveBall;

var

 pos    : integer;

begin
 ball.count := ball.count - 1;
 if (ball.count = 0) then
 begin
  ball.count := ball.speed;

  { Linken und rechten Rand abfragen. }

  if ((trunc(ball.next_x) < 2) or (trunc(ball.next_x) > 79)) then
  begin
   ball.dir_x := ball.dir_x * (-1.0);
   ball.next_x := ball.spalte + ball.dir_x;
  end;

  { Oberen Rand abfragen. }

  if (trunc(ball.next_y) < 1) then
  begin
   ball.dir_y := ball.dir_y * (-1.0);
   ball.next_y := ball.zeile + ball.dir_y;
  end;

  { Unteren Rand abfragen. }

  if (trunc(ball.next_y) > 23) then
  begin
   pos := integer((trunc(ball.zeile) + 1) * 80 + trunc(ball.spalte));
   if (screen^[pos].attribut = $70) then
   begin
    ball.dir_y := ball.dir_y * (-1.0);
    ball.next_y := ball.zeile + ball.dir_y;
   end
   else
   begin
    ball.flag := 2;
    exit;
   end;
  end;
  ball.spalte := ball.next_x;
  ball.zeile := ball.next_y;
  DrawBall;
 end;
end;

procedure Play;

var

 erg : byte;

begin
 while (TRUE) do
 begin
  erg := MoveBouncer;
  if (erg = 1) then
   exit;
  MoveBall;
  if (ball.flag = 2) then
   exit;
 end;
end;

begin
 GetCurrentVideoMode;
 GetCurrentCursorSettings;
 if (Video.mode <> 3) then
  SetVideoMode(3);
 HideCursor;

 screen0 := ptr($B800, 0000);  { Bildschirmseite 0. }
 screen1 := ptr($B800, 4000);  { Bildschirmseite 1. }
 screen2 := ptr($B800, 8000);  { Bildschirmseite 2. }
 screen := screen0;
 ClearScreen;
 screen := screen2;
 ClearScreen;
 screen := screen1;
 ClearScreen;
 DrawBorder;
 InitializeStones;
 DrawStones;
 bouncer.spalte := 35;
 bouncer.zeile := 24;
 bouncer.dir := 0;
 bouncer.speed := 3000;
 bouncer.count := bouncer.speed;
 DrawBouncer;
 ball.spalte := 40.0;
 ball.zeile := 20.0;
 ball.speed := 8000;
 ball.count := ball.speed;
 ball.dir_x := 1.0;
 ball.dir_y := (-1.0);
 ball.last_x := 39.0;
 ball.last_y := 21.0;
 ball.flag := 0;
 DrawBall;
 screen := screen0;
 repeat
  MovePicture(screen1, UP);
  MovePicture(screen2, UP);
  MovePicture(screen1, DOWN);
  MovePicture(screen0, DOWN);
 until (keypressed);

 MovePicture(screen1, UP);
 Play;

 RestoreCursor;
 port[$03D4] := $0C;
 port[$03D5] := 0;
 port[$03D4] := $0D;
 port[$03D5] := 0;
 if (Video.mode <> 3) then
  SetVideoMode(Video.mode)
 else
  clrscr;
 textattr := LIGHTGRAY;
 writeln;
 writeln('Thank you for playing BreakOut!');
 writeln;
 writeln('Do have a nice day...');
 writeln; writeln;
end.

