(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0089.PAS
  Description: Reding VGA Palettes
  Author: COLIN BUCKLEY
  Date: 01-27-94  12:16
*)

{
>thanks for the example -- do you have any idea how to read the whole
>palette at one time, etc?

Here you go...  It will work on all computers.  I do not use the 286
string instructions, as they go too fast for some VL-Bus video cards causing
incorrect colours.  The first part waits for a full vertical retrace
before changing the colours to prevent "snow" at the top of the display on
slower computers.  The only time you'll see the snow is if you continuously
get or set the palette such as in a screen fade.
}

Procedure VGAGetPalette(Pal:Pointer); Assembler;
Asm
  { Wait for Vertical Retrace }
  MOV   DX,3DAh
@@WaitNotVSync:
  IN    AL,DX
(91 min left), (H)elp, More?   AND   AL,00001000b
  JNZ   @@WaitNotVSync
@@WaitVSync:
  IN    AL,DX
  AND   AL,00001000b
  JZ    @@WaitVSync

  LES   DI,[Pal]                    {;ES:DI:=Palette Pointer           }
  XOR   AX,AX                       {;Start with DAC 0                 }
  MOV   CX,256                      {;End with DAC 255                 }
  MOV   DX,3C7h                     {; |Send Starting DAC register     }
  OUT   DX,AL                       {;/                                }
  INC   DX                          {; |DX:=DAC Data register          }
  INC   DX                          {;/                                }
  CLD
@@DACLoop:
  IN    AL,DX                       {;Read Red Byte                    }
  STOSB                             {;Store Red Byte                   }
  IN    AL,DX                       {;Read Green Byte                  }
  STOSB                             {;Store Green Byte                 }
  IN    AL,DX                       {;Read Blue Byte                   }
  STOSB                             {;Store Blue Byte                  }
  LOOP  @@DACLoop                   {;Loop until CX=0                  }
End;


