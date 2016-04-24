(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0100.PAS
  Description: Several Reboot Routines
  Author: MIKAEL RYDBERG
  Date: 02-21-96  21:04
*)

{
Here's three different ways of rebooting your computer. The last one does
a coldboot, wich includes the POST (Power On Self Test). This is the same
as using your powerswitch.
}
Procedure ReStart;Assembler;

Asm
  INT 19h
End;

Procedure WarmBoot;

Begin
   InLine
     ($B8/$40/$00                { MOV AX,0040   }
     /$8E/$D8                    { MOV DS,AX     }
     /$89/$C3                    { MOV BX,AX     }
     /$B8/$34/$12                { MOV AX,1234   }
     /$A3/$72/$00                { MOV [0072],AX }
     /$EA/$00/$00/$FF/$FF);      { JMP FFFF:0000 }
End;

Procedure ColdBoot;

Begin
   InLine
     ($B8/$40/$00                { MOV AX,0040   }
     /$8E/$D8                    { MOV DS,AX     }
     /$89/$C3                    { MOV BX,AX     }
     /$B8/$00/$00                { MOV AX,1234   }
     /$A3/$72/$00                { MOV [0072],AX }
     /$EA/$00/$00/$FF/$FF);      { JMP FFFF:0000 }
End;

