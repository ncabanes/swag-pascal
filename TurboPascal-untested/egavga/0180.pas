{
> Ok, here goes, I'm trying to write my own putpixel routine for
> 640x480x256 and I have one working but the fastest I can do a
> fullscreen memory write using it is 26.85 seconds! Using BGI drivers I
> get 5-6 seconds! what am I missing? Is it because I'm using TP? does
> anyone have inline assembly code for a putpixel at this resolution? I'm
> using mode 101h with VESA driver loaded. I would really like to know
> what I'm missing here! Any help is greatly appreciated.

Here's something I was working on... It's been a while since I touched
these but they work perfectly on my video (ATI/XL24/VESA 1.2). It takes
about 2 seconds to do a full 640x480 (VESA 101) on my 386DX/33.

I'm not sure if it will work on your system and I think it will work
only with window granularity of 64K. Please tell me if it works with
yours, and what granularity is 101 using on your system.
}

var
 VesaBank : Word;     { bank cache     }
 VesaSeg  : Word;     { video segment  }
 VesaBPL  : Word;     { bytes per line }

procedure SetPixel(X, Y : Word; C : Byte); assembler;
asm
 mov ax,[Y]                   { transform X/Y into one linear offset }
 mul [VesaBPL]                { DX:AX = Y * VesaBPL                  }
 add ax,[X]                   { DX:AX = DX:AX + X                    }
 adc dx,0                     {                                      }
 cmp dx,[VesaBank]            { Time to change bank?                 }
 je @10                       { jump if not                          }
 push ax                      { set the new memory bank...           }

 mov ax,$4F05                 { AX = 4F05h Memory Control            }
 mov bx,$0000                 { BH = Set Bank / BL = Window A        }
                              { DX = Memory Bank                     }
 int $10                      { call VESA                            }

 mov [VesaBank],dx            { save bank # to save time later       }

 pop ax
@10:
 mov bx,ax                    { BX = memory offset                   }
 mov ax,[VesaSeg]             { ES = Vesa segment                    }
 mov es,ax                    {                                      }
 mov al,[C]                   { AL = pixel value                     }
 mov es:[bx],al               { show it...                           }
end;

{
> Also I'm wondering how to do direct memory writes to memory above 1 meg?
> like 10000h etc... the highest MEM[] lets you go is FFFFh, any help there?

You will have to switch to protected mode to do that. If you just want
to store memory above 1meg, and not access specific parts of it (for
memory viewers, etc.), you can use EMS, XMS or switch over to BP7's
DPMI/protected mode.
}
