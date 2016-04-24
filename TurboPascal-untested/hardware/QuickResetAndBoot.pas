(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0017.PAS
  Description: Quick Reset and BOOT
  Author: LAURENT M. CHARTINIER
  Date: 11-02-93  16:11
*)

{Laurent M. CHARTINIER}
{computer do a RESET using a small Pascal routine?}

Procedure Reboot;
Begin
 Asm
  JMP FFFF:0000
 End;
End;


