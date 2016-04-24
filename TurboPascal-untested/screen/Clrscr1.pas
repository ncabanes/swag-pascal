(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0001.PAS
  Description: CLRSCR1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

Procedure fillWord(Var dest; count, data: Word);
begin
  Inline(
    $C4/$BE/dest/          { les di, dest[bp] }
    $8B/$8E/count/         { mov cx, count[bp] }
    $8B/$86/data/          { mov ax,data[bp] }
    $FC/                   { cld }
    $F3/$AB                { rep stosw }
  )
end;

Procedure ClrScr;
Var
  screen: Array[1..25, 1..80, 1..2] of Char Absolute $b800:$0000;
begin
  fillWord(screen, sizeof(screen) div 2, $0720)
end;

{ or }

Procedure ClrScr;
Type
  TScreen: Array[1..25, 1..80, 1..2] of Char;
Var
  VideoSegment: Word;
begin
  if (MemW[$40:$10] and $30)=$30 then
    VideoSegment:=$B000
  else
    VideoSegment:=$B800;
  fillWord(ptr(VideoSegment, 0)^, sizeof(TScreen) div 2, $0720)
end;
