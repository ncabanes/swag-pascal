(*
  Category: SWAG Title: SCREEN SCROLLING ROUTINES
  Original name: 0007.PAS
  Description: Scrolling Demo
  Author: DANIEL JOHN LEE PARNELL
  Date: 11-02-93  06:14
*)

{
S921878@MINYOS.XX.RMIT.OZ.AU, Daniel John Lee Parnell

 I have received several requests for the source code to the
scrolly demo I posted to this group.  Sorry about posting a binary.  I
didn't know it was not allowed on this group.  Anyway the following is the
source code to the scrolly.  It is not a unit.  It uses one 286
instruction so it wont work on an XT :(
}

{$G+}
program ColorBars;

uses
  DOS, CRT;

const
  maxBars  = 7;
  maxStars = 100;
  maxLines = 7;
  m : array [1..maxLines] of string =
     ('Welcome to my first scrolly demo on the PC.    It was written using ',
      'Turbo Pascal 6.0 on the 7th of October 1993.  This program took me ',
      'about 2 hours to write and I had a lot of fun writing it!         ',
      'I suppose I''d better put in some greets I guess...............',
      'Greetings go to      Robyn       Adam       Rowan      Mandy       ',
      '   Weng       Speed      Shane      Iceberg Inc.       And anybody ',
      'else out there whom I have forgotten about......         ');

var
  colors   : array [0..768] of byte;
  rMsk,
  gMsk,
  bMsk     : array [0..255] of byte;
  y, dy, s : array [1..maxBars]  of integer;
  sx, sy,
  sdx      : array [1..maxStars] of integer;
  tx, ty   : array [0..640]      of integer;
  dot      : integer;
  ticks    : word;
  scrly    : array [0..360] of integer;
  mpos,
  mlen     : integer;

procedure SetMode(m : integer);   { Set video mode }
var
  regs : registers;
begin
  regs.ax := m;
  intr($10, regs);
end;

procedure WaitRetrace;          { Wait for vertical retrace }
begin
  repeat { Nothing } until (Port[$03da] and 8) <> 0;
end;

procedure WaitNotRetrace;       { Wait for not vertical retrace }
begin
  repeat { Nothing } until (Port[$03da] and 8) <> 8;
end;

procedure InitScreen;           { Sets up the colored bars }
var
  i, j : integer;
begin
  for i := 0 to 199 do
    for j := 0 to 319 do
      mem[$a000 : i * 320 + j] := i;
end;

procedure InitColors;           { Zeros the first 200 colors }
var
  i : integer;
begin
  for i := 0 to 199 * 3 do
    colors[i] := 0;
end;

procedure SetColors; assembler;   { Loads the colors into the regs }
asm
 @ntrace:                { Wait for not retrace }
  mov  dx, $03da
  in   al, dx
  test al, 8
  jnz  @vtrace

 @vtrace:                { Now wait for retrace }
  mov  dx, $03da
  in   al, dx
  test al, 8
  jz   @vtrace

  mov  dx, $03c8          { Start changeing colors from color # 1 }
  mov  al, 1
  out  dx, al

  inc  dx                { Make DX point to the color register }
  mov  cx, 199*3          { The number of bytes to put into the color register }
  mov  si, offset colors  { Load the address of the color array }
  rep  outsb             { Now change the colors }
end;

procedure CalcBars;     { Calculate the color bars }
var
  i, j, k : integer;
begin
  for i := 0 to 199 * 3 do  { Zero all the colors }
    colors[i] := 0;

  for i := 1 to maxBars do { Now process each bar in turn }
  begin
    y[i] := y[i] + dy[i];  { Move the bar }
    if (y[i] < 4) or (y[i] > 190) then  { Has it hit the top or the bottom? }
    begin
      dy[i] := -dy[i];              { Yes, so make it bounce }
      y[i]  := y[i] + dy[i];
    end;

  for j := (y[i] - s[i]) to (y[i] + s[i]) do  { Now update the color array }
  begin
    if j < y[i] then       { Calculate the intensity }
      k := 63 - (y[i] - j) * 4
    else
      k := 63 - (j - y[i]) * 4;

    if j > 0 then          { If it is a valid color change it }
    begin
      colors[j * 3]     := (colors[j * 3]   + (k and rMsk[i]));   { Do red }
      colors[j * 3 + 1] := (colors[j * 3 + 1] + (k and gMsk[i])); { Do green }
      colors[j * 3 + 2] := (colors[j * 3 + 2] + (k and bMsk[i])); { Do blue }
    end;
    end;
  end;
end;

procedure InitBars;     { Set up the bars randomly }
var
  i : integer;
begin
  for i := 1 to MaxBars do
  begin
    y[i] := random(150)+4;       { Starting pos }
    s[i] := random(6)+4;         { Size }

    rMsk[i] := random(2)*255;    { Red mask }
    gMsk[i] := random(2)*255;    { Green mask }
    bMsk[i] := random(2)*255;    { Blue mask }

    repeat                     { Calc direction }
      dy[i] := random(6) - 3;
    until dy[i] <> 0;
  end;
end;

procedure InitStars;            { Set up the stars }
var
  i : integer;
begin
  port[$03c8] := $f8;                     { Change the colors for stars }
  for i := 7 downto 0 do
  begin
    port[$03c9] := 63 - (i shl 2);
    port[$03c9] := 63 - (i shl 2);
    port[$03c9] := 63 - (i shl 2);
  end;

  for i := 1 to maxStars do
  begin
    sx[i]  := random(320);               { Choose  X pos }
    sy[i]  := random(200);               {         Y pos }
    sdx[i] := 1 shl random(3);          {         Speed }
  end;
end;

procedure InitScroll;   { Initialize the scrolly }
const
  k = 3.141 / 180;
var
  i : integer;
begin
  mlen := 0;                      { Calc length of scroll text }
  for i := 1 to maxLines do
   mlen := mlen + length(m[i]);

  for i := 0 to 640 do            { Zero all the star positions }
    tx[i] := -1;

  for i := 0 to 360 do            { Calculate the scroll path }
    scrly[i] := round(100 + 50 * sin(i * k));
end;

procedure UpdateStars;          { Draw the stars }
var
  i, ad : integer;
begin
  for i := 1 to maxStars do
  begin
    ad := sx[i] + sy[i] * 320;              { Calc star address in video ram }
    mem[$a000 : ad] := sy[i];             { Unplot old star pos }
    sx[i] := sx[i] + sdx[i];              { Calc new star pos }

    if sx[i] > 319 then                 { Is it past the end of the screen? }
    begin
      sy[i] := random(200);           { Yes, generate a new star }
      sx[i] := 0;
      sdx[i] := 1 shl random(3);
      ad := sx[i] + sy[i] * 320;
    end;
    mem[$a000:ad + sdx[i]] := $f7 + (sdx[i]) * 2;
  end;
end;

function msg(var i : integer) : char;     { Get a char from the scroll text }
var
  j, t, p : integer;
begin
  if i > mlen then                { Is I longer then the text? }
    i := 1;

  j := 0;                         { Find which line it is in }
  t := 0;
  repeat
    inc(j);
    t := t + length(m[j]);
  until i<t;

  p := i - t + length(m[j]);          { Calculate position in line }

  if p > 0 then
    msg := m[j][p]
  else
    msg := chr(0);
  inc(i);                       { Increment text position }
end;

procedure NextChar;             { Create nex character in scroll text }
var
  ad   : word;
  i, j,
  q, c : integer;
begin
  c := ord(msg(mpos));            { Get the char }

  ad := $fa6e + (c * 8);              { Calc address of character image in ROM }
  for i := 0 to 7 do
  begin
    q := mem[$f000 : ad + i];       { Get a byte of the image }
    for j := 0 to 7 do
    begin
      if odd(q) then        { Is bit 0 set? }
      begin
        tx[dot] := 320 + (7 - j) * 4;   { If so add a dot to the list }
        ty[dot] := i * 4;
        inc(dot);
        if dot > 640 then
          dot := 0;
      end;
      q := q shr 1;           { Shift the byte one pos to the right }
    end;
  end;
end;

procedure DisplayScroll;        { Display scrolly and update dot positions }
var
  i  : integer;
  ad : word;
begin
  if (ticks mod 32) = 0 then      { Is it time for the next char? }
    NextChar;

  for i := 0 to 640 do
    if tx[i] > 0 then             { Is this dot being used? }
    begin
      if tx[i] < 320 then         { Is it on the screen? }
      begin
        ad := tx[i] + (ty[i] + scrly[tx[i]]) * 320;  { Calc old position }
        mem[$a000:ad] := ty[i] + scrly[tx[i]];   { Clear old dot }
      end;

      dec(tx[i]);                              { Move dot to the left }
      ad := tx[i] + (ty[i] + scrly[tx[i]]) * 320;      { Calc new position }

      if (tx[i] > 0) and (tx[i] < 320) then        { Is it on the screen? }
        mem[$a000:ad] := $ff - (ty[i] shr 2);      { Plot new dot }

    end;
end;

begin
  randseed := 4845267;            { Set up the random seed   }
  SetMode($13);                 { Go to 320*200*256 mode   }
  InitColors;                   { Blank the color array    }
  SetColors;                    { Set the colors to black  }
  InitScreen;                   { Set up the colored bars  }
  InitBars;                     { Set up the bar positions }
  InitStars;                    { Set up the stars         }
  InitScroll;                   { Set up the scrolly       }
  dot  := 0;                       { Set the dot counter to 0 }
  mpos := 1;                      { Set up the text pos      }

  repeat
    CalcBars;                   { Calculate the color bars   }
    DisplayScroll;              { Display the scrolly text   }
    UpdateStars;                { Update & display the stars }
    SetColors;                  { Set the colors             }
    inc(ticks);                 { Update the tick counter    }
  until KeyPressed;

  SetMode(3);                   { Return to text mode }
end.

