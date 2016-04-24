(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0012.PAS
  Description: Palette Control
  Author: GEOFF WATTS
  Date: 05-28-93  13:34
*)

{
 Hello, could somone tell me how to fade a screen out..
}

{ --------------------------------------------------------------------- }
{ Palette Unit (Text and Graphics modes)                                }
{ Author: Geoff Watts, 27-07-92                                         }
{ Usable Procedures:                                                    }
{   fadeup    -- fade the palette up                                    }
{   fadedown  -- fade the palette down                                  }
{   getpal256 -- fill the parameter Pal With the palette values         }
{   setpal256 -- fill the palette values With the parameter Pal         }
{   cpuType   -- determines wether the cpu is 8086/88 or different      }
{ --------------------------------------------------------------------- }

Unit Palette;
Interface
Uses Dos;
{ structure in which the palette inFormation is stored }
Type
  PaletteType = Array[0..255,1..3] of Byte; { 256 Red/Green/Blue (RGB)    }
Var
  OlPlt  : PaletteType;                     { internal palette structure  }
                                            { which contains the standard }
                                            { palette                     }
  SetPal256: Procedure (Var Pal : PaletteType); { the Procedure determined    }
                                                { at run time                 }
{ Forward declarations }
Procedure SetPal86 (Var Pal : PaletteType);
Procedure SetPal286 (Var Pal : PaletteType);
Procedure FadeUp;
Procedure FadeDown;
Function  CpuType : Boolean;
Implementation
{
    GetPal256:
        Load Pal Structure With the 256 RGB palette
        values.
}
Procedure GetPal256 (Var Pal : PaletteType);
Var
  loope : Word;
begin
  port[$3C7] := 0;
  { when a read is made on port $3C9 it increment port $3C7 so no changing }
  { of the register port ($3C7) needs to be perFormed here                 }
  For loope := 0 to 255 do
    begin
      Pal[loope,1] := port[$3C9];   { Read red value   }
      Pal[loope,2] := port[$3C9];   { Read green value }
      Pal[loope,3] := port[$3C9];   { Read blue value  }
    end;
end;
{
    SetPal86:
        Loads the palette Registers With the values in
        Pal.
    86/88 instructions.
}
Procedure SetPal86 (Var Pal : PaletteType);
begin
  Asm
    push    ds      { preserve segment Registers }
    push    es
    mov cx,256 * 3  { 256 RBG values             }
    mov dx,03DAh
    { by waiting For the retrace to end it avoids static }
    { when the palette is altered                        }
@retrace1:
    in  al,dx       { wait For no retrace        }
    and al,8        { check For retrace          }
    jnz @retrace1   { so loop Until it goes low  }
@retrace2:
    in  al,dx       { wait For retrace           }
    and al,8        { check For retrace          }
    jz  @retrace2   { so loop Until it goes high }
    lds si, Pal     { ds:si = @Pal               }
    mov dx,3c8h     { set up For a blitz-white   }
    mov al,0        { from this register         }
    cli             { disable interrupts         }
    out dx,al       { starting register          }
    inc dx          { set up to update DAC       }
    cld             { clear direction flag       }
@outnext:
    { the following code is what I have found to be the  }
    { most efficient way to emulate the "rep outsb"      }
    { instructions on the 8086/88                       }
    lodsb               { load al With ds:[si]       }
    out dx,al           { out al to port in dx       }
    loop    @outnext    { loop cx times              }
    sti                 { end of critical section    }
    pop es
    pop ds              { restore segment Registers  }
  end;
end;
{$G+}       { turn on 286 instruction generation }

{ --------------------------------------------------------------------- }
{ Palette Unit (Text and Graphics modes)                                }
{ --------------------------------------------------------------------- }
{
    SetPal286:
        Loads the palette Registers With the values in
        Pal.
    286+ instructions.
}
Procedure SetPal286 (Var Pal : PaletteType);
begin
  Asm
    push    ds      { preserve segment Registers }
    push    es
    mov cx,256 * 3  { 256 RBG values             }
    mov dx,03dah
    { by waiting For the retrace to end it avoids static }
    { when the palette is altered                        }
@retrace1:
    in  al,dx       { wait For no retrace        }
    and al,8        { check For retrace          }
    jnz @retrace1   { so loop Until it goes low  }
@retrace2:
    in  al,dx       { wait For retrace           }
    and al,8        { check For retrace          }
    jz  @retrace2   { so loop Until it goes high }
    lds si, Pal     { ds:si = @Pal               }
    mov dx,3c8h     { set up For a blitz-white   }
    mov al,0        { from this register         }
    cli             { disable interrupts         }
    out dx,al       { starting register          }
    inc dx          { set up to update DAC       }
    cld             { clear direction flag       }
    rep outsb       { 768 multiple out's         }
                    { rapid update acheived      }
    sti             { end of critical section    }
    pop es
    pop ds          { restore segment Registers  }
  end; { Asm }
end; { SetPal286 }
{$G-}               { turn off 286 instructions }
{
    fadedown:
        fades the palette down With little or no static
}
Procedure fadedown;
Var
  Plt     : PaletteType;
  i, j, k : Integer;
begin
  plt := olplt;
  For k := 0 to 63 do
    begin
      For j := 0 to 255 do
    For i := 1 to 3 do
          if Plt[j,i] <> 0 then
            dec(Plt[j,i]);      { decrease palette numbers gradually }
      SetPal256(Plt);           { gradually fade down the palette    }
    end;
end;
{
    fadeup:
        fades the palette up With little or no static
}
Procedure fadeup;
Var
  Plt     : PaletteType;
  i, j, k : Integer;
begin
  GetPal256(Plt);           { Load current palette }
  For k := 1 to 63 do
    begin
      For j := 0 to 255 do
        For i := 1 to 3 do
          if Plt[j,i] <> OlPlt[j,i] then
            inc(Plt[j,i]);      { bring palette back to the norm }
        SetPal256(Plt);         { gradually fades up the palette }
                                { to the normal values           }
    end;
end;
{
    CpuType:
        determines cpu Type so that we can use 286 instructions
}
Function CpuType : Boolean;
Var cpu : Byte;
begin
  Asm
    push sp
    pop  ax
    cmp  sp,ax                  { stack Pointer treated differently on }
    je   @cpu8086               { the 8086 Compared to all others      }
    mov  cpu,0
    jmp  @cpufound
@cpu8086:
    mov cpu,1
@cpufound:
  end; { Asm }
  cpuType := (cpu = 1);
end;
begin
  { determine the cpu Type so that we can use faster routines }
  if CpuType then
    SetPal256 := SetPal286
  else
    SetPal256 := SetPal86;
  { load the standard palette }
  GetPal256(OlPlt);
end.

