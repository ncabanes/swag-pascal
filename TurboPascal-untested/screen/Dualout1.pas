(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0004.PAS
  Description: DUALOUT1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

{
> Who knows how to detect and access dual display's?

As this feature is only available if you're using VGA as the primary adapter
you can get information about a second adapter by interrupt 10h.

        Get primary/secondary video adapter:
        interrupt:      10h
        input:          AH = 1Ah
                        AL = 00h                               (subFunction)
        output:         AL = 1Ah                (indicates Function support)
                        BL = code For active card              (primary one)
                        BH = code For inactive card

                        where following codes are valid:
                        00h     no card
                        01h     MDA With monochrome display
                        02h     CGA With CGA display
                        03h     reserved
                        04h     EGA With EGA or multiscan display
                        05h     EGA With monochrome display
                        06h     reserved
                        07h     VGA With monochrome display
                        08h     VGA With VGA or multiscan display
                        09h     reserved
                        0Ah     MCGA With CGA display (PS/2)
                        0Bh     MCGA With monochrome display (PS/2)
                        0Ch     MCGA With color display (PS/2)
                        FFh     unknown

        Set primary/secondary video adapter:
        interrupt:      10h
        input:          AH = 1Ah
                        AL = 01h                                (subFunction)
                        BL = code For active card        (here secondary one)
                        BH = code For inactive card
        output:         AH = 1Ah                 (indicates Function support)

First you call subFunction 00h to get the code of your primary and secondary
video adapter. Then you can toggle between them by using subFunction 01h.

To get back ontopic (Pascal code is needed ;-)) here's a simple example For a
toggle Procedure:
}
Uses Dos;

Procedure ToggleAdapters;
Var Regs            : Registers;
    Active,Inactive : Byte;
begin
  Regs.AH := $1A;
  Regs.AL := $00;
  Intr($10,Regs);
  If Regs.AL=$1A Then           { is Function supported? (is VGA?) }
 begin
   Active   := Regs.BL;                      { exchange both codes }
   Inactive := Regs.BH;
   Regs.AH  := $1A;
   Regs.AL  := $01;
   Regs.BL  := Inactive;
   Regs.BH  := Active;
   Intr($10,Regs);                           { now you can't see me }
 end;
end;

