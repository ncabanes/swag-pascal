(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0281.PAS
  Description: Another GetMem > 64k
  Author: GERHARD PIRAN
  Date: 11-29-96  08:17
*)

{
example 0064.pas of egavga.swg is buggy.
please replace it with the corrected attachment.
(gerhard piran is my pseudonym ;-) so please don't change! )

  thanx for great work on SWAG
  have fun, Gerd


{$Q-,R-}
{
JAMES SAITO

> I wonder if I can allocate With GetMem more than 64K, though. You see, I'm
> interested in creating games With my own code, and the most important part
> of games is Graphics. You don't want to play some dumb monochrome Text
> adventure With a little man (@). :) Do you have any tips For outputting a
> screen of information such as a part of a dungeon? I'd sorta like to keep
> the Character centered like in Nintendo games.

Well.  if you want to make a 320x200x256 game, I know the right stuff.  if you
would like to make the Character centered, and when you press
up/down/left/right, the whole screen scrolls.  Here is an example on a playing
field that is umm.  Let's say 1000x200 (200K).

GERHARD PIRAN
  correted and accelerated
}
uses crt;

procedure DMove (var source, dest; count: word); assembler;

asm
  push ds
  lds  si,source      {ds,si = source}
  les  di,dest        {es,di = dest}
  mov  cx,count       {cx = count}
  mov  ax,cx          {ax = count}
  cld
  shr  cx,2           {cx = count / 4}
  db   66h
  rep  movsw          {copy double words}
  mov  cl,al          {get rest bytes}
  and  cl,3
  rep  movsb          {copy rest}
  pop  ds
end;

const maxY = 199;
      maxL = 999;

type  line = array[0..maxL] of byte;
      linePtr = ^line;
      vga = array[0..63999] of byte;
Var
  ws: array [0..maxY] of linePtr;  {work space}
  lp   : linePtr;
  vp   : ^vga;    {pointer to vga buffer}
  vm   : vga absolute $A000:0;
  x,y  : word;

begin
  {Init The Graphics}
  Asm
    MOV AH,00H  {AH = 0}
    MOV AL,13H  {AL = 13H,which is the Graphics mode 320x200x256}
    INT 10H     {Call the Graphics bios services}
  end;

  if Mem[$40:$49] <> $13 Then
  begin
    WriteLn('VGA Graphics Required For this game');
    Halt(1);
  end;

  For y := 0 to maxY do
  begin
    new (lp);   {Find a chunk of memory For the field}
    if lp = nil then RunError (203);
    ws[y] := lp;   {Find a chunk of memory For the field}
    For x := 0 to maxL do
      lp^[x] := random(256);     {Create a random field}
  end;

  new(vp);
  if vp = nil then RunError (203);
  For x := 0 to 679 do
  begin
    For y := 0 to maxY do
      move (ws[y]^[x], vp^[y*320], 320);
    {Now do put your player on, supposing it's a white block}
    For y := 90 to 110 do
      FillChar(vp^[y*320 + 150], 20, 15);
    {WaitVRetrace}
    repeat until (port[$03DA] and $08) = 0;
    repeat until (port[$03DA] and $08) <> 0;
    {Now copy that workspace into the video memory}
    DMove (vp^, vm, 64000);
    if keypressed then break;
  end;

  {Now time to close the Graphics}
  Asm
    MOV AH,$00;
    MOV AL,$03;
    INT 10H
  end;

  {Free all blocks}
  dispose(vp);
  For y := 0 to maxY do dispose(ws[y]);
end.
{
  Well.  That's it.  It actually took me 20 minutes to Type this whole thing
right in the message base.  I guess there's a bit of errors.  - James Saito
}

