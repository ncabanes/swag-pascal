(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0093.PAS
  Description: Basm routines
  Author: EDDY THILLEMAN
  Date: 08-25-94  09:05
*)

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
        JMP   @copy
@null:
        MOV   AL,0         { return a empty string         }
        JMP   @done
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

function StrPos( var str1, str2: string ): byte; assembler;
  { returns position of the first occurrence of str1 in str2 }
  { return value in AX }
  { str1 - string to search for }
  { str2 - string to search in  }
asm
        CLD              { string operations forward                 }
        LES   DI,Str2    { load in ES:DI pointer to str2             }
        XOR   CH,CH      { clear CH                                  }
        MOV   CL,[DI]    { length str2 --> CX                        }
        AND   CX,CX      { length str2 = 0?                          }
        JZ    @Negatief  { length str2 = 0, nothing to search in     }
        INC   DI         { make DI point to the 1st char of str2     }
        LDS   SI,Str1    { load in DS:SI pointer to str1             }
        LODSB            { load in AL length str1                    }
        AND   AL,AL      { length str1 = 0?                          }
        JZ    @Negatief  { length str1 = 0, nothing to search for    }
        MOV   AH,AL      { length str1 --> AH                        }
        DEC   AH         { 1st char need not be compared again       }
        LODSB            { load in AL 1st character of str1          }
@Start:
  REPNE SCASB            { scan for next occurrence 1st char in str2 }
        JNE   @Negatief  { no success                                }
        CMP   CL,AH      { length str1 > # chars left in str2 ?      }
        JB    @Negatief  { yes, str1 not in str2                     }
        MOV   DX,SI      { pointer to 2nd char in str1 --> DX        }
        MOV   BX,CX      { number of chars in str2 to go --> BX      }
        MOV   CL,AH      { length str1 --> CL                        }
        REPE  CMPSB      { compare until characters don't match      }
        JE    @Positief  { full match                                }
        SUB   SI,DX      { current SI - prev. SI = # of chars moved  }
        SUB   DI,SI      { reconstruct DI                            }
        MOV   SI,DX      { restore pointer to 2nd char in str1       }
        MOV   CX,BX      { number of chars in str2 to go --> BX      }
        JMP   @Start     { scan for next occurrence 1st char in str2 }
@Negatief:
        XOR   AX,AX      { str1 is not in str, result 0              }
        JMP   @Exit
@Positief:
        XOR   AH,AH      { clear AH                                  }
        LES   DI,Str2    { load in ES:DI pointer to str2             }
        MOV   AL,[DI]    { length str2 --> AX                        }
        SUB   AX,BX      { start position of str1 in str2            }
@Exit:                   { we are finished. }
end  { StrPos };

procedure Trim( var Str: string ); assembler;
  { remove leading and trailing white space from str }
asm
        { setup }
        LDS   SI,Str     { load in DS:SI pointer to Str       }
        MOV   AX,DS      { Set ES to same segment as DS       }
        MOV   ES,AX      { Set ES to same segment as DS       }
        MOV   AL,[SI]    { length Str --> AL                  }
        AND   AL,AL      { length Str = 0?                    }
        JZ    @exit      { yes, nothing to do                 }
        MOV   DI,SI      { pointer to Str --> DI              }
        MOV   AH,AL      { length Str --> AH                  }

        { remove trailing white space }
        XOR   CH,CH      { clear CH                           }
        MOV   CL,AH      { length Str --> CX                  }
        ADD   SI,CX      { start with last character          }
@start1:
        MOV   AL,[SI]    { character  --> AL                  }
        CMP   AL,20H     { no white space                     }
        JA    @stop1     { last non-blank character found     }
        DEC   SI         { count down SI                      }
        DEC   CL         { count down CX                      }
        AND   CL,CL      { more characters left?              }
        JZ    @stop1     { no, done                           }
        JMP   @start1    { try again                          }
@stop1:
        AND   CL,CL      { length Str = 0?                    }
        JZ    @done      { string is empty, done              }

        { look for leading white space }
        MOV   SI,DI      { pointer to Str --> SI              }
@start2:
        INC   SI         { next character                     }
        MOV   AL,[SI]    { character  --> AL                  }
        CMP   AL,20H     { no white space                     }
        JA    @stop2     { first non-blank character found    }
        DEC   CL         { count down                         }
        AND   CL,CL      { more characters left?              }
        JZ    @stop2     { no, done                           }
        JMP   @start2    { try again                          }
@stop2:
        MOV   DX,SI      { difference between SI and DI gives }
        SUB   DX,DI      { position first non-blank character }
        CMP   DX,1       { first character non-blank?         }
        JE    @done      { yes, done                          }

        { remove leading white space }
        CLD              { string operations forward          }
        MOV   BX,CX      { save length Str                    }
        MOV   DX,DI      { save pointer to Str                }
        INC   DI         { don't overwrite length byte of Str }
        REP   MOVSB      { move remaining part of Str         }
        MOV   DI,DX      { restore pointer to Str             }
        MOV   CX,BX      { restore length Str                 }
@done:
        MOV   [DI],CL    { overwrite length byte of Str       }
@exit:
end  { Trim };


procedure RTrim( var Str: string ); assembler;
  { remove trailing white space from str }
asm
        { setup }
        LDS   SI,Str     { load in DS:SI pointer to Str      }
        MOV   AL,[SI]    { length Str --> AL                 }
        AND   AL,AL      { length Str = 0?                   }
        JZ    @exit      { yes, exit                         }
        MOV   DI,SI      { pointer to Str --> DI             }
        MOV   AH,AL      { length Str --> AH                 }

        { remove trailing space }
        STD              { SeT Direction flag --> backwards  }
        XOR   CH,CH      { clear CH                          }
        MOV   CL,AH      { length Str --> CX                 }
        ADD   SI,CX      { start with last character         }
@start:
        MOV   AL,[SI]    { character  --> AL                 }
        CMP   AL,20H     { no white space                     }
        JA    @stop      { last non-blank character found    }
        DEC   SI         { count down                        }
        DEC   CL         { count down                        }
        AND   CL,CL      { more characters left?             }
        JZ    @stop      { no, done                          }
        JMP   @start     { try again                         }
@stop:
        MOV   [DI],CL    { overwrite length byte of Str      }
@exit:
end  { RTrim };


procedure LTrim( var Str: string ); assembler;
  { remove leading white space from str }
asm
        { setup }
        LDS   SI,Str     { load in DS:SI pointer to Str       }
        MOV   AL,[SI]    { length Str --> AL                  }
        AND   AL,AL      { length Str = 0?                    }
        JZ    @exit      { yes, nothing to do                 }
        MOV   DI,SI      { pointer to Str --> DI              }
        XOR   CH,CH      { clear CH                           }
        MOV   CL,AL      { length Str --> CX                  }

        { look for leading white space }
@start:
        INC   SI         { next character                     }
        MOV   AL,[SI]    { character  --> AL                  }
        CMP   AL,20H     { no white space                     }
        JA    @stop      { first non-blank character found    }
        DEC   CL         { count down                         }
        AND   CL,CL      { more characters left?              }
        JZ    @nullstr   { no, done                           }
        JMP   @start     { try again                          }
@nullstr:
        MOV   CL,0       { null string                        }
        JMP   @done      { we're done                         }
@stop:
        MOV   DX,SI      { difference between SI and DI gives }
        SUB   DX,DI      { position first non-blank character }
        CMP   DX,1       { first character non-blank?         }
        JE    @exit      { yes, exit                          }

        { remove leading white space }
        CLD              { string operations forward          }
        MOV   DX,CX      { save length Str                    }
        MOV   BX,DI      { save pointer to Str                }
        INC   DI         { don't overwrite length byte of Str }
        REP   MOVSB      { move remaining part of Str         }
        MOV   DI,BX      { restore pointer to Str             }
        MOV   CX,DX      { restore length Str                 }
@done:
        MOV   [DI],CL    { overwrite length byte of Str       }
@exit:
end  { LTrim };


