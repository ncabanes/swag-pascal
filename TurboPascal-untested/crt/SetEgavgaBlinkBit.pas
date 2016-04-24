(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0002.PAS
  Description: Set EGA/VGA Blink Bit
  Author: GUY MCLOUGHLIN
  Date: 05-28-93  13:36
*)


  Hi, Rolfi:

RM>Anybody know and easy way to do DarkGrey for a bkgrnd???

  ...You have to turn off the "blink-bit", if possible. This is
  only available for CGA and EGA/VGA color text modes.

  (***** Turn the "blink-bit" on/off to allow 16 different background *)
  (*     colors. (CGA ONLY!)                                          *)
  (*                                                                  *)
  procedure SetBlinkCGA({input } TurnOn : boolean);
  begin
    if TurnOn then
      begin
        mem[$0040:$0065] := (mem[$0040:$0065] AND (NOT $20));
        port[$3D8] := $29
      end
    else
      begin
        mem[$0040:$0065] := (mem[$0040:$0065] OR $20);
        port[$3D8] := $09
      end
  end;        (* SetBlinkCGA.                                         *)


  (***** Turn the "blink-bit" on/off to allow 16 different background *)
  (*     colors. (EGA or VGA ONLY!)                                   *)
  (*                                                                  *)
  procedure SetBlinkEGAVGA({input } TurnOn : boolean);
  begin
    asm
      mov ax, 1003h
      mov bl, TurnOn
      int 10h
    end
  end;        (* SetBlinkEGAVGA.                                      *)

                               - Guy
---
 ■ DeLuxe²/386 1.25 #5060 ■
 * Rose Media, Toronto, Canada : 416-733-2285
 * PostLink(tm) v1.04  ROSE (#1047) : RelayNet(tm)

                       
