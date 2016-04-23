
TYPE
  Fixed = RECORD CASE Boolean OF
    True  : (w : LongInt); False : (f, i : Word);
  END;

{ originally by SEAN PALMER, I just mangled it  :^) }
PROCEDURE ScaleBitmap(VAR bmp2scale; actualx, actualy : Byte;
                      bstrtx, bstrty, bendx, bendy : Word);
{ These are notes I added, so they might be wrong.  :^)     }
{ - bmp2scale is an array [0..actualx, 0..actualy] of byte  }
{   which contains the original bitmap                      }
{ - actualx and actualy are the actual width and height of  }
{   the normal bitmap                                       }
{ - bstrtx and bstrty are the x and y values for the upper- }
{   left-hand corner of the scaled bitmap                   }
{ - bendx and bendy are the lower-right-hand corner of the  }
{   scaled version of the original bitmap                   }
{ - eg. to paste an unscaled version of a bitmap that is    }
{   64x64 pixels in size in the top left-hand corner of the }
{   screen, fill the array with data and call:              }
{     ScaleBitmap(bitmap, 64, 64, 0, 0, 63, 63);            }
{ - apparently, the bitmap is read starting at (0,0) and    }
{   then going to (0,1), then (0,2), etc; meaning that it's }
{   not read horizontally, but vertically                   }
VAR
   bmp_sx, bmp_sy, bmp_cy : Fixed;
   bmp_s, bmp_w, bmp_h    : Word;
BEGIN
     bmp_w := bendx - bstrtx + 1; bmp_h := bendy - bstrty + 1;
     bmp_sx.w := actualx * $10000 DIV bmp_w;
     bmp_sy.w := actualy * $10000 DIV bmp_h;
     bmp_s := 320 - bmp_w; bmp_cy.w := 0;
     ASM
        PUSH DS
        MOV DS,WORD PTR bmp2scale + 2
        MOV AX,$A000; MOV ES,AX; CLD; MOV AX,320;
        MUL bstrty; ADD ax,bstrtx; MOV DI,AX;
       @L2:
        MOV AX,bmp_cy.i; MUL actualx; MOV BX,AX;
        ADD BX,WORD PTR bmp2scale;
        MOV CX,bmp_w; MOV SI,0; MOV DX,bmp_sx.f;
       @L:
        MOV AL,[BX]; STOSB; ADD SI,DX; ADC BX,bmp_sx.i;
        LOOP @L
        ADD DI,bmp_s; MOV AX,bmp_sy.f; MOV bx,bmp_sy.i;
        ADD bmp_cy.f,AX; ADC bmp_cy.i,BX;
        DEC WORD PTR bmp_h; JNZ @L2; POP DS;
     END;
END;

