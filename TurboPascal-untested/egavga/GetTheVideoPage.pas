(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0182.PAS
  Description: Get the Video Page
  Author: JOE WILCOX
  Date: 11-26-94  04:59
*)

{
From: josephw@ramp.com (Joe Wilcox)
>> Are there any Pascal function/procedures that will return to me the DOS
>> segment of the current video page? If not, is there an easy way
>> to do this? Thanks!
>Not built-in Pascal, as far as I know (perhaps in graphics mode, using the
>Graph unit, but I don't use it).  In text mode, each screen takes 2*80*25 =
>4000 bytes, so I think you simply add a 4K (that is, 4096) offset for each
>logical page.  Screen mode 3, co80, mem. starts at phys. address B8000h.

Ok, if you are trying to find the segment in text mode, it's real easy..
here is a function...
}

function GetVPage : word;
asm
  mov BX,$B000;  { Default is monochrome segment      }
  mov AH,$0F;    { Bios function 0Fh : Get Video Mode }
  int $10;       { Do a Bios video interrupt          }
  cmp AL,$07;    { Are we in monochrome?              }
  je @@Done;     { Yes, then jump                     }
  mov BX,$B800;  { Set it to the color segment        }
 @@Done:
  mov AX,BX;     { Return the value in AX             }
end;


