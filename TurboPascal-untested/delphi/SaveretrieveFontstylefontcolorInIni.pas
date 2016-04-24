(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0248.PAS
  Description: Save/Retrieve Fontstyle/Fontcolor in INI
  Author: JENS SCHUMANN
  Date: 05-30-97  18:17
*)

{
Anyone with a code snippet to save/retrieve FontStyle and FontColor
in an INI file ?

Hey Dick here are some code snippets from me.

regards
:-) Jens
Germany/Gerdau

------------------------------------------------------------------------
Here is a section from my Unit with constants

     DefaultMemoFontColor       =clBlack;
     DefaultMemoFontSize        =10;
     DefaultMemoFontName      ='Arial';
     DefaultMemoFontStyle       =0;
{           0                 Standart
            1    fsBold        Die Schriftart wird fett dargestellt.
            2    fsItalic          Die Schriftart wird kursiv dargestellt.
            3    fsUnderline  Die Schriftart wird unterstrichen dargestellt.
            4    fsStrikeout    Die Schriftart wird durchgestrichen
dargestellt.}
--------------------------------------------------------------------------------
----------------------------------------------------

This section reads the Fontstyle from the infile
It's called during Form1.Create

 {Lese Schriftart}
  Memo.Font.Color:=Ini.ReadInteger('Schriftart','Farbe',DefaultMemoFontColor);
  Memo.Font.Name:=Ini.ReadString('Schriftart','Name',DefaultMemoFontName);
  Memo.Font.Size:=Ini.ReadInteger('Schriftart','Grv_e',DefaultMemoFontSize);
  Case Ini.ReadInteger('Schriftart','Style',DefaultMemoFontStyle) of
     0 : Memo.Font.Style:=[];
     1 : Memo.Font.Style:=[fsBold];
     2 : Memo.Font.Style:=[fsItalic];
     3 : Memo.Font.Style:=[fsUnderline];
     4 : Memo.Font.Style:=[fsStrikeout];
     else
       Memo.Font.Style:=[];
  end;{Case}
--------------------------------------------------------------------------------
----------------------------------------------------
  {Write Fontstyle}
  This Codesection is called during the close-event from Form1.
  Ini:=TIniFile.Create(BAQIniFile);
  Ini.WriteInteger('Schriftart','Farbe',Memo.Font.Color);
  Ini.WriteString('Schriftart','Name',Memo.Font.Name);
  Ini.WriteInteger('Schriftart','Grv_e',Memo.Font.Size);
  If Memo.Font.Style=[] then
    Ini.WriteInteger('Schriftart','Style',0);
  If Memo.Font.Style=[fsBold] then
    Ini.WriteInteger('Schriftart','Style',1);
  If Memo.Font.Style=[fsItalic] then
    Ini.WriteInteger('Schriftart','Style',2);
  If Memo.Font.Style=[fsUnderline] then
    Ini.WriteInteger('Schriftart','Style',3);
  If Memo.Font.Style=[fsStrikeout] then
    Ini.WriteInteger('Schriftart','Style',4);
  Ini.Free;


