
procedure White2Space( var Str: string; const WhiteSpace: string ); assembler;
  { replace white space chars in Str by spaces
    the string WhiteSpace contains the chars to replace }
asm     { setup }
        cld                      { string operations forwards    }
        les   di, str            { ES:DI points to Str           }
        xor   cx, cx             { clear cx                      }
        mov   cl, [di]           { length Str in cl              }
        jcxz  @exit              { if length of Str = 0, exit    }
        inc   di                 { point to 1st char of Str      }
        mov   dx, cx             { store length of Str           }
        mov   bx, di             { pointer to Str                }
        lds   si, WhiteSpace     { DS:SI points to WhiteSpace    }
        mov   ah, [si]           { load length of WhiteSpace     }

@start: cmp   ah, 0              { more chars WhiteSpace left?   }
        jz    @exit              { no, exit                      }
        inc   si                 { point to next char WhiteSpace }
        mov   al, [si]           { next char to hunt             }
        dec   ah                 { ah counting down              }
        xor   dh, dh             { clear dh                      }
        mov   cx, dx             { restore length of Str         }
        mov   di, bx             { restore pointer to Str        }
        mov   dh, ' '            { space char                    }
@scan:
  repne scasb                    { the hunt is on                }
        jnz   @next              { white space found?            }
        mov   [di-1], dh         { yes, replace that one         }
#next:  jcxz  @start             { if no more chars in Str       }
        jmp   @scan              { if more chars in Str          }
@exit:
end  { White2Space };


procedure Trim( var Str: string ); assembler;
  { remove trailing and leading spaces from str }
asm     { setup }
        les   di, str            { ES:DI points to Str                }
        lds   si, str            { DS:SI points to Str                }
        xor   cx, cx             { clear cx                           }
        mov   cl, [di]           { length Str in cl                   }
        jcxz  @exit              { if length of Str = 0, exit         }
        mov   bx, di             { bx points to length byte of Str    }
        xor   dx, dx             { clear dx                           }
        mov   al, ' '            { hunt for spaces                    }

        { look for trailing spaces }
        std                      { string operations backwards        }
        add   di, cx             { start with last char in Str        }
   repe scasb                    { the hunt is on                     }
        jz    @done              { only spaces?                       }
        inc   cx                 { no, don't lose last char           }

        { look for leading spaces }
        cld                      { string operations forward          }
        inc   si                 { pointer to 1st char of Str         }
        mov   di, si             { pointer to 1st char of Str --> di  }
   repe scasb                    { the hunt is on                     }
        jz    @done              { if only spaces, we are done        }
        inc   cx                 { no, don't lose 1st non-blank char  }
        dec   di                 { no, don't lose 1st non-blank char  }
        mov   dx, cx             { new lenght of Str                  }
        xchg  di, si             { swap si and di                     }
    rep movsb                    { move remaining part of Str         }
@done:  mov   [bx], dl           { new length of Str                  }
@exit:
end  { Trim };

procedure RTrim( var Str: string ); assembler;
  { remove trailing spaces from str }
asm     { setup }
        std                      { string operations backwards   }
        les   di, str            { ES:DI points to Str           }
        xor   cx, cx             { clear cx                      }
        mov   cl, [di]           { length Str in cl              }
        jcxz  @exit              { if length of Str = 0, exit    }
        mov   bx, di             { bx points to Str              }
        add   di, cx             { start with last char in Str   }
        mov   al, ' '            { hunt for spaces               }

        { remove trailing spaces }
   repe scasb                    { the hunt is on                }
        jz    @done              { only spaces?                  }
        inc   cx                 { no, don't lose last char      }
@done:  mov   [bx], cl           { overwrite length byte of Str  }
@exit:
end  { RTrim };


procedure LTrim( var Str: string ); assembler;
  { remove leading white space from str }
asm     { setup }
        cld                      { string operations forward          }
        lds   si, str            { DS:SI points to Str                }
        xor   cx, cx             { clear cx                           }
        mov   cl, [si]           { length Str --> cl                  }
        jcxz  @exit              { if length Str = 0, exit            }
        mov   bx, si             { save pointer to length byte of Str }
        inc   si                 { 1st char of Str                    }
        mov   di, si             { pointer to 1st char of Str --> di  }
        mov   al, ' '            { hunt for spaces                    }
        xor   dx, dx             { clear dx                           }

        { look for leading spaces }
   repe scasb                    { the hunt is on                     }
        jz    @done              { if only spaces, we are done        }
        inc   cx                 { no, don't lose 1st non-blank char  }
        dec   di                 { no, don't lose 1st non-blank char  }
        mov   dx, cx             { new lenght of Str                  }
        xchg  di, si             { swap si and di                     }
    rep movsb                    { move remaining part of Str         }
@done:  mov   [bx], dl           { new length of Str                  }
@exit:
end  { LTrim };

