{Laurent M. CHARTINIER}
{computer do a RESET using a small Pascal routine?}

Procedure Reboot;
Begin
 Asm
  JMP FFFF:0000
 End;
End;

