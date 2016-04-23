
procedure CopySubStr( Str1: string; start, nrchars: byte; var Str2: string );
assembler;
  { copy part of Str1 (beginning at start for nrchars) to Str2
    if start > length of Str1, Str2 will contain a empty string.
    if nrchars specifies more characters than remain starting at the
    start position, Str2 will contain just that remainder of Str1. }
asm
        { setup }
        LDS   SI,Str1      { load in DS:SI pointer to str1 }
        CLD                { string operations forward     }
        LES   DI,Str2      { load in ES:DI pointer to str2 }
        MOV   AH,[SI]      { length str1 --> AH            }
        AND   AH,AH        { length str1 = 0?              }
        JE    @null        { yes, empty string in Str2     }
        MOV   BL,[start]   { starting position --> BL      }
        CMP   AH,BL        { start > length str1?          }
        JB    @null        { yes, empty string in Str2     }

        { start + nrchars - 1 > length str1?               }
        MOV   AL,[nrchars] { nrchars --> AL                }
        MOV   DH,AL        { nrchars --> DH                }
        ADD   DH,BL        { add start                     }
        DEC   DH
        CMP   AH,DH        { nrchars > rest of str1?       }
        JB    @rest        { yes, copy rest of str1        }
        JMP   #copy
@null:
        MOV   AL,0         { return a empty string         }
        JMP   #done
@rest:
        SUB   AH,BL        { length str1 - start           }
        INC   AH
        MOV   AL,AH
@copy:
        MOV   CL,AL        { how many chars to copy        }
        XOR   CH,CH        { clear CH                      }
        XOR   BH,BH        { clear BH                      }
        ADD   SI,BX        { starting position             }
        MOV   DX,DI        { save pointer to str2          }
        INC   DI
        REP   MOVSB        { copy part str1 to str2        }
        MOV   DI,DX        { restore pointer to str2       }
@done:
        MOV   [DI],AL      { overwrite length byte of str2 }
@exit:
end  { CopySubStr };


procedure StrCopy( var Str1, Str2: string ); assembler;
  { copy str1 to str2 }
asm
        LDS   SI,Str1    { load in DS:SI pointer to str1 }
        CLD              { string operations forward     }
        LES   DI,Str2    { load in ES:DI pointer to str2 }
        XOR   CH,CH      { clear CH                      }
        MOV   CL,[SI]    { length str1 --> CX            }
        INC   CX         { include length byte           }
        REP   MOVSB      { copy str1 to str2             }
@exit:
end  { StrCopy };
