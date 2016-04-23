
var
  s1, s2: string;
  position: byte;

function StrPos( var str1, str2: string ): byte; assembler;
  { returns position of the first occurrence of str1 in str2 }
  { return value in AL }
  { str1 - string to search for }
  { str2 - string to search in  }
asm
        CLD              { string operations forward                 }
        LES   DI,Str2    { load in ES:DI pointer to str2             }
        XOR   CH,CH      { clear CH                                  }
        MOV   CL,[DI]    { length str2 --> CL                        }
        AND   CL,CL      { length str2 = 0?                          }
        JZ    @Negatief  { length str2 = 0, nothing to search in     }
        MOV   BH,CL      { length str2 --> BH                        }
        INC   DI         { make DI point to the 1st char of str2     }
        LDS   SI,Str1    { load in DS:SI pointer to str1             }
        LODSB            { load in AL length str1                    }
        AND   AL,AL      { length str1 = 0?                          }
        JZ    @Negatief  { length str1 = 0, nothing to search for    }
        DEC   AL         { 1st char need not be compared again       }
        SUB   CL,AL      { length str2 - length str1                 }
        JBE   @Negatief  { length str2 < length str1                 }
        MOV   AH,AL      { length str1 --> AH                        }
        LODSB            { load in AL 1st character of str1          }
@Start:
  REPNE SCASB            { scan for next occurrence 1st char in str2 }
        JNE   @Negatief  { no success                                }
        MOV   DX,SI      { pointer to 2nd char in str1 --> DX        }
        MOV   BL,CL      { number of chars in str2 to go --> BL      }
        MOV   CL,AH      { length str1 --> CL                        }
   REPE CMPSB            { compare until characters don't match      }
        JE    @Positief  { full match                                }
        SUB   SI,DX      { current SI - prev. SI = # of chars moved  }
        SUB   DI,SI      { current DI - # of chars moved = prev. DI  }
        MOV   SI,DX      { restore pointer to 2nd char in str1       }
        MOV   CL,BL      { number of chars in str2 to go --> BL      }
        JMP   @Start     { scan for next occurrence 1st char in str2 }
@Negatief:
        XOR   AX,AX      { str1 is not in str2, result 0             }
        JMP   @Exit
@Positief:
        ADD   BL,AH      { number of chars in str2 left              }
        MOV   AL,BH      { length str2 --> AX                        }
        SUB   AL,BL      { start position of str1 in str2            }
@Exit:                   { we are finished. }
end  { StrPos };

begin
  s1 := ParamStr( 1 );
  s2 := ParamStr( 2 );
  writeln( StrPos( s1, s2 ) );
end.

