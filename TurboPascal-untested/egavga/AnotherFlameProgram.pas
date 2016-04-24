(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0250.PAS
  Description: Another Flame Program
  Author: IAN LIN
  Date: 09-04-95  10:55
*)

{
> What are plasmas or fire (I know they are graphics
> displays, but what do they look like and what is the theory
> behind them?

It's just graphics stuff. Fun stuff. Theory? None. Not everything has
theory to it. Here is a flame program.
}
{$G+}

program flames;

uses crt;
const palette : array [1..768] of byte = (

    0,    0,    0,    0,    0,    24,    0,    0,    24,    0,    0,    28,
    0,    0,   32,    0,    0,    32,    0,    0,    36,    0,    0,    40,
    8,    0,   40,   16,    0,    36,   24,    0,    36,   32,    0,    32,
   40,    0,   28,   48,    0,    28,   56,    0,    24,   64,    0,    20,
   72,    0,   20,   80,    0,    16,   88,    0,    16,   96,    0,    12,
  104,    0,    8,  112,    0,     8,  120,    0,     4,  128,    0,     0,
  128,    0,    0,  132,    0,     0,  136,    0,     0,  140,    0,     0,
  144,    0,    0,  144,    0,     0,  148,    0,     0,  152,    0,     0,
  156,    0,    0,  160,    0,     0,  160,    0,     0,  164,    0,     0,
  168,    0,    0,  172,    0,     0,  176,    0,     0,  180,    0,     0,
  184,    4,    0,  188,    4,     0,  192,    8,     0,  196,    8,     0,
  200,   12,    0,  204,   12,     0,  208,   16,     0,  212,   16,     0,
  216,   20,    0,  220,   20,     0,  224,   24,     0,  228,   24,     0,
  232,   28,    0,  236,   28,     0,  240,   32,     0,  244,   32,     0,
  252,   36,    0,  252,   36,     0,  252,   40,     0,  252,   40,     0,
  252,   44,    0,  252,   44,     0,  252,   48,     0,  252,   48,     0,
  252,   52,    0,  252,   52,     0,  252,   56,     0,  252,   56,     0,
  252,   60,    0,  252,   60,     0,  252,   64,     0,  252,   64,     0,
  252,   68,    0,  252,   68,     0,  252,   72,     0,  252,   72,     0,
  252,   76,    0,  252,   76,     0,  252,   80,     0,  252,   80,     0,
  252,   84,    0,  252,   84,     0,  252,   88,     0,  252,   88,     0,
  252,   92,    0,  252,   96,     0,  252,   96,     0,  252,  100,     0,
  252,  100,    0,  252,  104,     0,  252,  104,     0,  252,  108,     0,
  252,  108,    0,  252,  112,     0,  252,  112,     0,  252,  116,     0,
  252,  116,    0,  252,  120,     0,  252,  120,     0,  252,  124,     0,
  252,  124,    0,  252,  128,     0,  252,  128,     0,  252,  132,     0,
  252,  132,    0,  252,  136,     0,  252,  136,     0,  252,  140,     0,
  252,  140,    0,  252,  144,     0,  252,  144,     0,  252,  148,     0,
  252,  152,    0,  252,  152,     0,  252,  156,     0,  252,  156,     0,
  252,  160,    0,  252,  160,     0,  252,  164,     0,  252,  164,     0,
  252,  168,    0,  252,  168,     0,  252,  172,     0,  252,  172,     0,
  252,  176,    0,  252,  176,     0,  252,  180,     0,  252,  180,     0,
  252,  184,    0,  252,  184,     0,  252,  188,     0,  252,  188,     0,
  252,  192,    0,  252,  192,     0,  252,  196,     0,  252,  196,     0,
  252,  200,    0,  252,  200,     0,  252,  204,     0,  252,  208,     0,
  252,  208,    0,  252,  208,     0,  252,  208,     0,  252,  208,     0,
  252,  212,    0,  252,  212,     0,  252,  212,     0,  252,  212,     0,
  252,  216,    0,  252,  216,     0,  252,  216,     0,  252,  216,     0,
  252,  216,    0,  252,  220,     0,  252,  220,     0,  252,  220,     0,
  252,  220,    0,  252,  224,     0,  252,  224,     0,  252,  224,     0,
  252,  224,    0,  252,  228,     0,  252,  228,     0,  252,  228,     0,
  252,  228,    0,  252,  228,     0,  252,  232,     0,  252,  232,     0,
  252,  232,    0,  252,  232,     0,  252,  236,     0,  252,  236,     0,
  252,  236,    0,  252,  236,     0,  252,  240,     0,  252,  240,     0,
  252,  244,    0,  252,  244,     0,  252,  244,     0,  252,  248,     0,
  252,  248,    0,  252,  248,     0,  252,  248,     0,  252,  252,     0,
  252,  252,    4,  252,  252,     8,  252,  252,    12,  252,  252,    16,
  252,  252,   20,  252,  252,    24,  252,  252,    28,  252,  252,    32,
  252,  252,   36,  252,  252,    40,  252,  252,    40,  252,  252,    44,
  252,  252,   48,  252,  252,    52,  252,  252,    56,  252,  252,    60,
  252,  252,   64,  252,  252,    68,  252,  252,    72,  252,  252,    76,
  252,  252,   80,  252,  252,    84,  252,  252,    84,  252,  252,    88,
  252,  252,   92,  252,  252,    96,  252,  252,   100,  252,  252,   104,
  252,  252,  108,  252,  252,   112,  252,  252,   116,  252,  252,   120,
  252,  252,  124,  252,  252,   124,  252,  252,   128,  252,  252,   132,
  252,  252,  136,  252,  252,   140,  252,  252,   144,  252,  252,   148,
  252,  252,  152,  252,  252,   156,  252,  252,   160,  252,  252,   164,
  252,  252,  168,  252,  252,   168,  252,  252,   172,  252,  252,   176,
  252,  252,  180,  252,  252,   184,  252,  252,   188,  252,  252,   192,
  252,  252,  196,  252,  252,   200,  252,  252,   204,  252,  252,   208,
  252,  252,  208,  252,  252,   212,  252,  252,   216,  252,  252,   220,
  252,  252,  224,  252,  252,   228,  252,  252,   232,  252,  252,   236,
  252,  252,  240,  252,  252,   244,  252,  252,   248,  252,  252,   252,
  252,  252,  240,  252,  252,   244,  252,  252,   248,  252,  252,   252);

   radius    = 1.9;
   frequency = 2;
   angleinc  = 3 * pi / frequency;

var
   count       : word;
   delta       : integer;
   path        : array[0..199] of word;
   buffer      : array[0..102,0..159] of integer;

procedure buildpath;
   var
      count     : byte;
      currangle : real;
   begin
      currangle := pi;
      for count := 0 to 199 do
         begin
            path[count] := 320 + round(radius*sin(currangle));

            { the sin path _must_ lie on an even number }
            { otherwise the picture will be garbage     }

            if path[count] mod 2 <> 0 then
               if path[count] > 320 then
                  dec(path[count])            { round down }
               else
                  inc(path[count]);           { round up   }

            { the path is rounded to the closest even number to 320 }

            currangle := currangle + angleinc;
         end;
   end;

begin
  randomize;
  buildpath;

  asm
     mov   ax,13h              { ; AX := 13h                            }
     int   10h                 { ; Set Mode 13h (320x200x256)           }

     xor   ax,ax               { ; AX := 0                              }
     mov   cx,768              { ; CX := # of palette entries           }
     mov   dx,03C8h            { ; DX := VGA Port                       }
     mov   si,offset palette   { ; SI := palette[0]                     }

     out   dx,al               { ; send zero to index port              }
     inc   dx                  { ; inc to write port                    }

   @l1:

     mov   bl,[si]             { ; set palette entry                    }
     shr   bl,2                { ; divide by 4                          }
     mov   [si],bl             { ; save entry                           }
     outsb                     { ; and write to port                    }
     dec   cx                  { ; CX := CX - 1                         }
     jnz   @l1                 { ; if not done then loop                }

     mov   ax,seg buffer       { ; AX := segment of buffer              }
     mov   es,ax               { ; ES := AX                             }
     mov   di,offset buffer    { ; DI := buffer[0]                      }
     mov   cx,8109             { ; CX := sizeof(buffer) div 2           }
     xor   ax,ax               { ; AX := 0                              }
     rep   stosw               { ; clear every element in buffer to zero}
  end;

  repeat

     asm
        mov   bx,1             { ; BX := 1                              }
        mov   si,offset path   { ; SI := path[0]                        }

        mov   cx,16160         { ; CX := # of elements to change        }
        mov   di,offset buffer { ; DI := buffer[0]                      }
        add   di,320           { ; DI := buffer[320] (0,1)              }

     @l2:

        mov   ax,ds:[di-2]     { ; AX := buffer[DI-2]    (x-1,y)        }
        add   ax,ds:[di]       { ; AX += buffer[DI]      (x  ,y)        }
        add   ax,ds:[di+2]     { ; AX += buffer[DI+2]    (x+1,y)        }
        add   ax,ds:[di+320]   { ; AX += buffer[DI+320]  (x,y+1)        }
        shr   ax,2             { ; AX := AX div 4 (calc average)        }

        jz    @l3              { ; if AX = 0 then skip next line        }
        dec   ax               { ; else AX--                            }

     @l3:

        push  di               { ; save DI                              }
        sub   di,ds:[si]       { ; DI := (x + or - sin,y-1)             }
        mov   word ptr ds:[di],ax { store AX somewhere one line up      }
        pop   di               { ; restore DI                           }

        inc   di               { ; DI++                                 }
        inc   di               { ; DI++ (move to next word)             }

        inc   bx               { ; BX++                                 }
        cmp   bx,320           { ; if bx <> 320                         }
        jle   @l4              { ; then jump to @l4                     }
        mov   bx,1             { ; else BX := 1 (we're on a new line)   }
        inc   si               { ; point SI to next element in path     }
        inc   si               { ;                                      }

     @l4:
        dec   cx               { ; CX--                                 }
        jnz   @l2              { ; if CX <> 0 then loop                 }
     end;

     for count := 0 to 159 do {set new bottom line}
        begin
           if random < 0.4 then
              delta := random(2)*255;
           buffer[101,count] := delta;
           buffer[102,count] := delta;
        end;

     asm
        mov   si,offset buffer { ; SI := buffer[0]                      }
        mov   ax,0A000h        { ; AX := 0A000h (vga segment)           }
        mov   es,ax            { ; ES := AX                             }
        xor   di,di            { ; DI := 0                              }
        mov   dx,100           { ; DX := 100 (# of rows div 2)          }

     @l5:
        mov   bx,2             { ; BX := 2                              }

     @l6:
        mov   cx,160           { ; CX := 160 (# of cols div 2)          }

     @l7:
        mov   al,ds:[si]       { ; AL := buffer[si]                     }
        mov   ah,al            { ; AH := AL (replicate byte)            }
        mov   es:[di],ax       { ; store two bytes into video memory    }
        inc   di               { ; move to next word in VRAM            }
        inc   di               { ;                                      }
        inc   si               { ; move to next word in buffer          }
        inc   si               { ;                                      }
        dec   cx               { ; CX--                                 }
        jnz   @l7              { ; repeat until done with column        }

        sub   si,320           { ; go back to start of line in buffer   }
        dec   bx               { ; BX--                                 }
        jnz   @l6              { ; repeat until two columns filled      }

        add   si,320           { ; restore position in buffer           }
        dec   dx               { ; DX--                                 }
        jnz   @l5              { ; repeat until 100 rows filled         }
     end;

  until keypressed;

  asm
     mov   ax,03h              { ; AX := 3h                             }
     int   10h                 { ; restore text mode                    }
  end;

end.

