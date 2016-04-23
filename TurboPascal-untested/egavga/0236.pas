{$X+}
uses crt;

type
 ModeInfoBlock = record
        ModeAttributes     : word;    { mode attributes                    }
        WinAAttributes     : byte;    { window A attributes                }
        WinBAttributes     : byte;    { window B attributes                }
        WinGranularity     : word;    { window granularity                 }
        WinSize            : word;    { window size                        }
        WinASegment        : word;    { window A start segment             }
        WinBSegment        : word;    { window B start segment             }
        WinFuncPtr         : pointer; { pointer to windor function         }
        BytesPerScanLine   : word;    { bytes per scan line                }
        XResolution        : word;    { horizontal resolution              }
        YResolution        : word;    { vertical resolution                }
        XCharSize          : byte;    { character cell width               }
        YCharSize          : byte;    { character cell height              }
        NumberOfPlanes     : byte;    { number of memory planes            }
        BitsPerPixel       : byte;    { bits per pixel                     }
        NumberOfBanks      : byte;    { number of banks                    }
        MemoryModel        : byte;    { memory model type                  }
        BankSize           : byte;    { bank size in kb                    }
        NumberOfImagePages : byte;    { number of images                   }
        Reserved           : byte;    { reserved for page function         }
        RedMaskSize        : byte;    { size of direct color red mask      }
        RedFieldPosition   : byte;    { bit position of LSB of red mask    }
        GreenMaskSize      : byte;    { size of direct color green mask    }
        GreenFieldPosition : byte;    { bit position of LSB of green mask  }
        BlueMaskSize       : byte;    { size of direct color blue mask     }
        BlueFieldPosition  : byte;    { bit position of LSB of blue mask   }
        RsvdMaskSize       : byte;    { size of direct color reserved mask }
        DirectColorModeInfo: byte;    { Direct Color mode attributes       }
        Reserved2          : array[1..216] of byte; { remainder            }
       end;
 Mogis = ^ModeInfoBlock;

var
 modeinfo   : Mogis;
 CurBank, i : integer;
 p          : ^pointer;

procedure GetModeInfo(mode : word; var block : modeinfoblock); Assembler;
asm
   mov     ax, 4F01h
   mov     cx, mode
   les     di, block
   int     10h
end;

procedure BankSwitch(bank : integer); Assembler;
asm
   mov     ax, bank
   cmp     CurBank, ax
   je      @end
   mov     CurBank, ax
   mov     ax, 4F05h
   xor     bx, bx
   mov     dx, bank
   call    p
 @end:
end;

procedure SetVesaMode(mode : word); Assembler;
asm
   mov     ax, 4F02h
   mov     bx, mode
   int     10h
end;

procedure SetText; Assembler;
asm
   mov     ax, 3
   int     10h
end;

begin
 CurBank := 0;
 SetVesaMode($101);
 GetMem(modeinfo, 256);
 GetModeInfo($101, modeinfo^);
 p := modeinfo^.winfuncptr;
 for i := 0 to 4 do
  begin
   BankSwitch(i);
   Fillchar(mem[$a000:0000], $FFFF, i+1);
  end;
 ReadKey;
 SetText;
end.
