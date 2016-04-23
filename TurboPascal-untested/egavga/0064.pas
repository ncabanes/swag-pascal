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
}
Var
  Field  : Array [0..199] of Pointer;  {The Field}
  P      : Pointer;  {I'll tell you what happens With this}
  Count,
  Count2 : Integer;

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

  For Count := 0 to 199 do
  begin
    getmem(field[count],1000);   {Find a chunk of memory For the field}
    For count2 := 0 to 999 do
      mem[seg(field[count]^) : ofs(field[count]^)] := random(256);
      {Create a random field}
  end;
  getmem(p, 64000);
  For Count2 := 0 to 679 do
  begin
    For count := 0 to 199 do
      Move(mem[seg(field[count]^) : ofs(field[count]^) + Count2],
           mem[seg(p^) : ofs(p^) + count * 320], 320);
    {Now do put your player on, supposing it's a white block}
    For count := 90 to 110 do
      FillChar(mem[seg(p^) : ofs(p^) + count * 320 + 150], 20, 15);
    move (p^, mem[$A000 : 0], 64000);
    {Now copy that workspace into the video memory}
  end;

  {Now time to close the Graphics}
  Asm
    MOV AH,$00;
    MOV AL,$03;
    INT 10H
  end;

  {Free all blocks}
  For Count := 0 to 199 do
    freemem(field[count], 320);
  freemem(p, 64000);
end.
{
  Well.  That's it.  It actually took me 20 minutes to Type this whole thing
right in the message base.  I guess there's a bit of errors.  - James Saito
}
