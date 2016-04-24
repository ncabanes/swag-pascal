(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0044.PAS
  Description: VGA User Fonts
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
>so it appears nothing happened).  I have seen some Programs that are
>able to save the Dos font into a buffer in the Program and then just
>set the video card back to that font when the Program quits.  The problem
>is, I have not seen any documented Dos interrupt that will allow me to
>do this.
>  I'm wondering if anyone knows of such an interrupt that I can use to
>  get the current VGA font and save it to a buffer.
>  Any help would be greatly appreciated!

   Interrupt $10 is what you're looking For. Function $11,
   subFunction $30 gets the Character generator info.
   Function $11, subFunction $10 loads user fonts. Function $11 can
   also be used to Reset to one of the hardware fonts (subFunction
   $11 Resets to ROM 8x14, $12 Resets to ROM 8x8, $14 Resets to VGA
   ROM 8x16)

   The structure Types are as follows:
}
Type

  { enumerated font Type }
  ROMfont = (ROM8x14, ROM8x8, ROM8x16);

  { Character definition table }
  CharDefTable = Array[0..4096] of Byte;
  CharDefPtr   = ^CharDefTable;

  { Text Character generator table }
  Char_Table = Record
     Points :Byte;
     Def    :CharDefPtr;
  end;

  { font Format }
  FontPackage = Record
     FontInfo :Char_Table;
     Ch       :CharDefTable;
  end;
  FontPkgPtr = ^FontPackage;

{ Here are some handy Procedures to use those Types: }

Procedure GetCharGenInfo(font: ROMfont; Var Table:Char_Table);
begin
  if is_EGA then
  begin
    Reg.AH := $11;
    Reg.AL := $30;
    Case font of
      ROM8x8 : Reg.BH := 3;
      ROM8x14: Reg.BH := 2;
      ROM8x16: Reg.BH := 6;
    end;
    Intr($10, Reg);
    Table.Def := Ptr(Reg.ES, Reg.BP);
    Case font of
      ROM8x8 : Table.Points := 8;
      ROM8x14: Table.Points := 14;
      ROM8x16: Table.Points := 16;
    end;
  end;
end;

Procedure SetHardwareFont(Var font :ROMfont);
begin
  if is_EGA then
  begin
    Reg,AH := $11;
    Case font of
      ROM8x14 : Reg.AL := $11;
      ROM8x8  : Reg.AL := $12;
      ROM8x16 :
        if is_VGA then
           Reg.AL := $14 { 8x16 on VGA only }
        else
        begin
           Reg.AL := $12;
           font := ROM8x14;
        end;
    end;
    Reg.BL := 0;
    Intr($10, Reg);
  end;
end;

Function FetchHardwareFont(font :ROMfont):FontPkgPtr;
Var
  pkg :FontPkgPtr;
begin
  New(pkg);
  GetCharGenInfo(font, Pkg^.FontInfo);
  Pkg^.Ch := Pkg^.FontInfo.Def^;
  FetchHardwareFont := Pkg;
end;

Procedure LoadUserFont(pkg :FontPkgPtr);
begin
  Reg.AH := $11;
  Reg.AL := $10;
  Reg.ES := Seg(pkg^.ch);
  Reg.BP := Ofs(pkg^.ch);
  Reg.BH := Pkg^.FontInfo.Points;
  Reg.BL := 0;
  Reg.CX := 256;
  Reg.DX := 0;
  Intr($10, Reg);
end;


