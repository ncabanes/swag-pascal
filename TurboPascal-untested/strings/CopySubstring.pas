(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0130.PAS
  Description: Copy SubString
  Author: EDDY THILLEMAN
  Date: 05-31-96  09:17
*)

CSUBSTR.PAS  in MISC.SWG     0123 01/01 37/47   79%

Bug: if nrchars specifies more characters than remain starting at the
     start position, Str2 will contain nrchars characters. This is fixed.
}
procedure CopySubStr( Str1: string; start, nrchars: byte; var Str2: string );
assembler;
  { copy part of Str1 (beginning at start for nrchars) to Str2
    if start > length of Str1, Str2 will contain a empty string.
    if nrchars specifies more characters than remain starting at the
    start position, Str2 will contain just that remainder of Str1. }
asm     { setup }
        push  ds           { save DS                       }
        cld                { string operations forward     }
        lds   si, str1     { load in DS:SI pointer to str1 }
        les   di, str2     { load in ES:DI pointer to str2 }
        mov   ah, [si]     { length str1 --> AH            }
        and   ah, ah       { length str1 = 0?              }
        je    @null        { yes, empty string in Str2     }
        mov   bl, [start]  { starting position --> BL      }
        cmp   ah, bl       { start > length str1?          }
        jb    @null        { yes, empty string in Str2     }

        { start + nrchars - 1 > length str1?               }
        mov   al, [nrchars]{ nrchars --> AL                }
        mov   dh, al       { nrchars                       }
        add   dh, bl       { + start                       }
        jc    @rest        { if overflow copy rest of str1 }
        dec   dh           { - 1                           }
        cmp   ah, dh       { nrchars > rest of str1?       }
        jb    @rest        { yes, copy rest of str1        }
        jmp   @copy
@null:  xor   ax, ax       { return a empty string         }
        jmp   @done
@rest:  sub   ah, bl       { length str1 - start           }
        inc   ah
        mov   al, ah
@copy:  mov   cl, al       { how many chars to copy        }
        xor   ch, ch       { clear CH                      }
        xor   bh, bh       { clear BH                      }
        add   si, bx       { starting position             }
        mov   dx, di       { save pointer to str2          }
        inc   di           { don't overwrite length str2   }
    rep movsb              { copy part str1 to str2        }
        mov   di, dx       { restore pointer to str2       }
@done:  mov   [di], al     { overwrite length byte of str2 }
@exit:  pop   ds           { restore DS                    }
end  { CopySubStr };


