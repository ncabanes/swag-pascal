(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0078.PAS
  Description: Save/Restore Text Screen
  Author: SWAG SUPPORT TEAM
  Date: 11-26-94  05:06
*)

program screen { save screen in file / restore screen from file };
               { only text mode screens }

 { no error checking! the video mode and
   (if restoring the screen from a file)
   the content of the file are not checked.

   it only moves the video memory to a file
   or from a file to the video memory }

 { if the file does not exist: the screen is saved in a new file
     with the given name;
   if the file does exist: the screen is restored from that file
     the file is not deleted. }

uses dos;
Const
  NoFAttr : word = $1C; { dir-, volume-, system attributen }
  FAttr   : word = $23; { readonly-, hidden-, archive attributen }
Var
  { bios area }
  mode      : byte absolute $40:$49;  { current video mode }
  columns   : byte absolute $40:$4A;  { number of columns  }
  dispOfs   : word absolute $40:$4E;  { current video page offset }
  CrtPort   : word absolute $40:$63;  { CRT port address }
  lastRow   : byte absolute $40:$84;  { newer bios only: rows on screen-1 }

  VidSeg    : word;
  dispSize  : word;
  ScreenF   : file;
  Fname     : string[128];
  Attr      : word;
  Exists    : boolean;
  tel       : word;

function GetVidSeg : word;
begin
 if CrtPort = $3D4 then
   GetVidSeg := $B800        { color }
 else
   GetVidSeg := $B000;       { mono  }
end;                         

Procedure SaveScreen;
begin
  BlockWrite( ScreenF, mem[ vidseg : dispOfs ], dispSize, tel );
end;

Procedure RestoreScreen;
begin
  BlockRead( ScreenF, mem[ vidseg : dispOfs ], dispSize, tel );
end;

begin
  VidSeg := GetVidSeg;
  dispSize := columns * (lastRow+1);

  if ParamCount > 0 then
  begin
    Fname := FExpand( ParamStr( 1 ) );
    Assign ( ScreenF, Fname );

    { ---------------------------------------------------------------------- }
    { does file exist? }
    GetFAttr( ScreenF, Attr );
    if DosError = 0 then
      Exists := ((Attr and NoFAttr) = 0)  { not dir-, volume- or system bit? }
    else
      Exists := False;                    { DosError }
    { ---------------------------------------------------------------------- }

    if Exists then
      Reset( ScreenF, 2 )         { open file }
    else
      Rewrite( ScreenF, 2 );      { create new file }
    {}

    if IOResult = 0 then       { no error reading or creating file }
    begin
      if Exists then
        RestoreScreen
      else
        SaveScreen;
      Close( ScreenF );
    end   { if IOResult = 0 }
    else  { IOResult <> 0 ! }
      Writeln( 'Error reading or creating file ', Fname );
    { endif IO error Fname }
  end;  { if ParamCount > 0 }
end.

