(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0096.PAS
  Description: RPos in BASM
  Author: EDDY THILLEMAN
  Date: 08-25-94  09:11
*)

var
  s1, s2: string;

function RPos( var str1, str2: string ): byte; assembler;
  { returns position of the last occurrence of str1 in str2 }
  { return value in AX }
  { str1 - string to search for }
  { str2 - string to search in  }
asm
        STD              { string operations backwards               }
        LES   DI,Str2    { load in ES:DI pointer to str2             }
        XOR   CH,CH      { clear CH                                  }
        MOV   CL,[DI]    { length str2 --> CX                        }
        AND   CX,CX      { length str2 = 0?                          }
        JZ    @Negatief  { length str2 = 0, nothing to search in     }
        ADD   DI,CX      { make DI point to the last char of str2    }
        LDS   SI,Str1    { load in DS:SI pointer to str1             }
        XOR   AH,AH      { clear AH                                  }
        MOV   AL,[SI]    { load in AX length str1                    }
        AND   AL,AL      { length str1 = 0?                          }
        JZ    @Negatief  { length str1 = 0, nothing to search for    }
        ADD   SI,AX      { make SI point to the last char of str1    }
        MOV   AH,AL      { length str1 --> AH                        }
        DEC   AH         { last char need not be compared again      }
        LODSB            { load in AL last character of str1         }
@Start:
  REPNE SCASB            { scan for next occurrence 1st char in str2 }
        JNE   @Negatief  { no success                                }
        CMP   CL,AH      { length str1 > # chars left in str2 ?      }
        JB    @Negatief  { yes, str1 not in str2                     }
        MOV   DX,SI      { pointer to last but 1 char in str1 --> DX }
        MOV   BX,CX      { number of chars in str2 to go --> BX      }
        MOV   CL,AH      { length str1 --> CL                        }
   REPE CMPSB            { compare until characters don't match      }
        JE    @Positief  { full match                                }
        SUB   SI,DX      {                                           }
        NEG   SI         { prev. SI - current SI = # of chars moved  }
        ADD   DI,SI      { reconstruct DI                            }
        MOV   SI,DX      { restore pointer to 2nd char in str1       }
        MOV   CX,BX      { number of chars in str2 to go --> BX      }
        JMP   @Start     { scan for next occurrence 1st char in str2 }
@Negatief:
        XOR   AX,AX      { str1 is not in str, result 0              }
        JMP   @Exit
@Positief:
        INC   BL
        SUB   BL,AH      { start position of str1 in str2            }
        MOV   AL,BL      { in AL                                     }
        XOR   AH,AH      { clear AH                                  }
@Exit:                   { we are finished. }
end  { RPos };

begin
  s1 := ParamStr( 1 );
  s2 := ParamStr( 2 );
  writeln( RPos( s1, s2 ) );
end.

{
If a '#' (shift-3) appears in the assembler source code, please replace
that by a at-sign (shift-2).
}
