(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0004.PAS
  Description: Detection of EGA/VGA Card
  Author: EDWIN CALIMBO
  Date: 05-28-93  13:39
*)

{
EDWIN CALIMBO

│Can anyone supply me With a routine to determine a Graphics card? I want
│the Procedure to return a Variable if the user has a Graphics card less
│than an EGA. Anyone have anything quick?

The Function below will detect most Graphics (mono/color) card. It's
a bit long, but is has all the info on how to detect certain card.
}

Uses
  Dos;

Type
  CardType = (none,mda,cga,egamono,egacolor,
              vgamono,vgacolor,mcgamono,mcgacolor);

Function VideoCard: CardType;
Var
  code : Byte;
  Regs : Registers;
begin
  Regs.AH := $1A;      (* call VGA Identify Adapter Function *)
  Regs.AL := $00;      (* clear AL to 0...*)
  Intr($10, Regs);     (* call BIOS *)
  If Regs.AL = $1A then
  begin
    Case Regs.BL of
      $00 : VideoCard := NONE;       (* no Graphic card *)
      $01 : VideoCard := MDA;        (* monochrome *)
      $02 : VideoCard := CGA;        (* cga *)
      $04 : VideoCard := EGAColor;   (* ega color *)
      $05 : VideoCard := EGAMono;    (* ega mono*)
      $07 : VideoCard := VGAMono;    (* vga mono *)
      $08 : VideoCard := VGAColor;   (* vga color *)
      $0A,
      $0C : VideoCard := MCGAColor;  (* mcga color *)
      $0B : VideoCard := MCGAMono;   (* mcga mono *)
      Else
        VideoCard := CGA
    end
  end
  Else
  begin
    Regs.AH := $12;         (* use another Function service *)
    Regs.BX := $10;         (* BL = $10 means return EGA info *)
    Intr($10, Regs);        (* call BIOS video Function *)
    If Regs.bx <> $10 Then  (* bx unchanged means EGA is not present *)
    begin
      Regs.AH := $12;
      Regs.BL := $10;
      Intr($10, Regs);
      If Regs.BH = 0 Then
        VideoCard := EGAColor
      Else
        VideoCard := EGAMono
    end
    Else
    begin
      Intr($11, Regs);     (* eguipment determination service *)
      code := (Regs.AL and $30) shr 4;
      If (code = 3) Then
        VideoCard := MDA
      Else
        VideoCard := CGA
    end
  end
end; (* VideoCard *)

(*============================= cut here ==================================*)

begin
  Case VideoCard of
    VGAColor : Writeln('VGA Color');
  end;
end.
