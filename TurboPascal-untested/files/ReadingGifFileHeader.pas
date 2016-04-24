(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0034.PAS
  Description: Reading GIF File Header
  Author: ERIC MILLER
  Date: 11-02-93  05:46
*)

{
ERIC MILLER

> How does one read/Write a header on a File in TPascal?

  Easy.  Write the header structure as a Type.  Then open
  the File as unTyped and blockread the data into a Variable
  of the structure Type.  Take GIFs For example:
}

Type
  Gif_Header = Record { first 13 Bytes of a Gif }
    Sig, Ver     : Array[1..3] of Char;
    Screen_X,
    Screen_Y     : Word;
    _Packed,
    Background,
    Pixel_Aspect : Byte;
  end;
Var
  F : File;        { unTyped File }
  G : GIF_Header;
begin
  Assign(F, 'Filename.gif');
  Reset(F, 1);               { blockread in Units of one Byte }
  Blockread(F, G, SizeOf(G));  { read from File }
  Close(F);
  With G DO
  begin
    Writeln('Version: ', Sig, Ver);
    Writeln('Res: ', Screen_X, 'x', Screen_Y, 'x', 2 SHL (_Packed and 7));
  end;
end.

