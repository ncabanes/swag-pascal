(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0037.PAS
  Description: TWEAKED.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
 Hi, would anyone like to tell me how to get the tweaked video
 mode With 4 pages to work With because I'm tired of the 16 color
 2 page demos I'm making.

Sure, here's an adaptation of some code from Dr. Dobbs magazine on Mode-X.
I've only posted the routine to set the VGA to 360x240x256 With 3 pages of
Graphics.  Only 3 pages since the increase in resolution Uses more RAM.
}

Procedure InitVGA360x240;

Const
  GC_inDEX    = $03CE;    { VGA Graphics Controller }
  SC_inDEX    = $03C4;    { VGA Sequence controller }
  CrtC_inDEX  = $03D4;    { VGA Crt Controller      }
  MISC_OUTPUT = $03C2;    { VGA Misc Register       }
  MAP_MASK    = $02;      { Map Register #          }
  READ_MAP    = $04;      { Read Map Register #     }

  VMODE_DATA  : Array[1..17] of Word =
                   ($6B00,    { Horizontal total          }
                    $5901,    { Horizontal displayed      }
                    $5A02,    { Start horizontal blanking }
                    $8E03,    { end horizontal blanking   }
                    $5E04,    { Start H sync.             }
                    $8A05,    { end H sync.               }
                    $0D06,    { Vertical total            }
                    $3E07,    { Overflow                  }
                    $4109,    { Cell height               }
                    $EA10,    { V sync. start             }
                    $AC11,    { V sync. end/Prot CR0 CR7  }
                    $DF12,    { Vertical displayed        }
                    $2D13,    { offset                    }
                    $0014,    { DWord mode off            }
                    $E715,    { V Blank start             }
                    $0616,    { V Blank end               }
                    $E317);   { Turn on Byte mode         }

begin
  Asm
   mov   ax, $13
   int   $10

   mov   dx, SC_inDEX           { Sequencer Register }
   mov   ax, $0604              { Disable Chain 4 Mode }
   out   dx, ax

   mov   ax, $0100              { (A)synchronous Reset }
   out   dx, ax

   mov   dx, MISC_OUTPUT        { VGA Misc Register }
   mov   al, $E7                { Use 28Mhz Clock & 60Hz }
   out   dx, al

   mov   dx, SC_inDEX           { Sequencer Register }
   mov   ax, $0300              { Restart Sequencer }
   out   dx, ax

   {
     Diasable Write protect For CrtC Registers 0-7, since we are
     about to change the horizontal & vertical timing settings.
   }
   mov   dx, CrtC_inDEX         { VGA CrtC Registers }
   mov   al, $11                { CrtC register 11h }
   out   dx, al                 { Load current value }
   inc   dx                     { Point to data }
   in    al, dx                 { Get CrtC register 11h }
   and   al, $7F                { Mask out Write protect }
   out   dx, al                 { and send it back }

   { Send CrtC data in VMODE_DATA Array to the CrtC. }
   mov   dx, CrtC_inDEX         { VGA CrtC Registers }
   cld                          { Forward block load }
   mov   si, offset VMODE_DATA  { Get parameter data }
   mov   cx, 17                 { Number of entries in block }

   @@1:
     mov   ax, ds:[si]      { Get next parameter value }
     inc   si               { Advance to next Word }
     inc   si
     out   dx, ax           { Output next value }
     loop  @@1              { Process next value }

   { Clear all VGA memory to black. }
   mov   dx, SC_inDEX     { Select all planes }
   mov   ax, $0F02
   out   dx, ax

   mov   ax, VGA_SEG      { Point to VGA memory }
   mov   es, ax
   mov   di, 0

   xor   ax, ax           { clear 256K }
   mov   cx, $8000        { 32K * 2 * 4 planes }
   rep   stosw
  end;
end;
{
That's about it.  The video memory in this mode is organised a bit differently
than CGA/HERC.  It is a lot like the 16 color modes you're probably used to, in
that you must go through the EGA/VGA Registers to access the memory, by setting
MAP MASK & PLANE SELECT, etc.
}

