{$A+,B-,D-,E+,F+,G+,I-,L-,N+,P-,Q-,R-,S-,T-,V-,X+,Y-}
{*-----------------------------------------------*}
{|                                               |}
{|  <<< VGA 13h-mode unit for fast graphics >>>  |}
{|         Written on Borland Pascal 7.0         |}
{|     and supports real and protected modes.    |}
{|    Version 1.11 p, last update : 20-Dec-97    |}
{|       Coded by HardBreaker [FleXoft Co.]      |}
{|    alexic@ropnet.ru; 9135@multi-page.cea.ru   |}
{|      Alexic@hotmail.com, #pascal-IRC-EFNet    |}
{|  Special thanks to : Zyklon, [bios], my wife  |}
{|                                               |}
{*-----------------------------------------------*}

Unit Graphics;
Interface
Type
  { VGA color record }
  TColor    = record
    R, G, B : byte;
  end;

  { VGA palette structures }
  PVGAPalette  = ^TVGAPalette;
  TVGAPalette  = array[0..255] of TColor;

  { Sprite structures }
  PSprite = ^TSprite;
  TSprite = record
    a, b : word;
    data : pointer;
  end;

Const
  { Unit version label }
  Version        = '1.11 p';

  { Error codes }
  VGA_Ok          =   0;
  VGA_NoMemory    =  -1;
  VGA_IOError     =  -2;
  VGA_NoFile      =  -3;
  VGA_BadVersion  =  -4;
  VGA_BadFormat   =  -5;

  { Workplace area }
  MinX           =   0;
  MaxX           = 319;
  MinY           =   0;
  MaxY           = 199;

Var
  { Pointer to double buffer     }
  { aka virtual or shadow screen }
  DBuffer   : pointer;

  { Pointer to VGA videobuffer   }
  VBuffer   : pointer;

  {$L vb30.obj}                          { include 32-bit grapics procedures }
                                         { see asm source at the end of file }
{ -------------------------------------------------------------------------- }
Function  GetVideoMode:byte;                    { get current video mode     }
Procedure SetVideoMode(n:byte);                 { set video mode             }
Procedure InitGraphMode;                        { init 13h graph mode        }
Procedure DoneGraphMode;                        { restore old mode           }
Function  InitDoubleBuffer:integer;             { allocate double buffer     }
Procedure DoneDoubleBuffer;                     { deallocate double buffer   }
Procedure ShowBuffer32;                         { copy d-buffer to screen    }
Procedure ClearDBuffer32;                       { clear d-buffer fast        }
Procedure ClearVBuffer32;                       { clear screen buffer fast   }
Procedure Retrace;                              { wait for back trace        }
{ -------------------------------------------------------------------------- }
Procedure SetPoint(x,y:integer;c:byte);         { fast point to d-buffer     }
Function  GetPoint(x,y:integer):byte;           { get point from d-buffer    }
Procedure SetScreenPoint(x,y:integer;c:byte);   { fast point direct to screen}
Function  GetScreenPoint(x,y:integer):byte;     { get point from screen      }
Procedure SetVLine(x,y1,y2:integer;c:byte);     { fast vertical line (db)    }
Procedure SetHLine(x1,x2,y:integer;c:byte);     { fast horizontal line (db)  }
Procedure SetLine(x1,y1,x2,y2:integer;c:byte);  { set line (not so fast)     }
Procedure SetBox(x1,y1,x2,y2:integer;c:byte);   { draw box                   }
Procedure SetRect(x1,y1,x2,y2:integer;c:byte);  { draw rectangle             }
{ -------------------------------------------------------------------------- }
Procedure SetPaletteColor(c,r,g,b:byte);        { set palette color          }
Procedure GetPaletteColor(c:byte;var r,g,b:byte); { get palette color        }
Function  ColorInPal(var c:byte;r,g,b:byte;p:pointer):boolean; { check color }
Function  FindColor(var c:byte;r,g,b:byte;p:pointer):integer;  { find color  }
Procedure SetAllPalette(p: pointer);            { set all vga palette        }
Procedure GetAllPalette(p: pointer);            { get all vga palette        }
Procedure FadeIn(n:word;p:pointer);             { fading palette in          }
Procedure FadeOut(n:word);                      { fading palette out         }
{ -------------------------------------------------------------------------- }
Procedure BitBLT_Opaque(x,y:integer; sprite:TSprite);       { bit blitting   }
Procedure BitBLT_Transparent(x,y:integer; sprite:TSprite);  { bit blitting   }
Procedure BitBLT_OpaqueT(x,y:integer; sprite:TSprite);      { bit blitting   }
Procedure BitBLT_TransparentT(x,y:integer; sprite:TSprite); { bit blitting   }
Procedure Zoom_OpaqueT(zx,zy,za,zb:integer; sprite:TSprite); { zoom opaque   }
Procedure Zoom_TransparentT(zx,zy,za,zb:integer; sprite:TSprite); { zoom tr. }
Procedure GetImage(zx,zy:integer; sprite:TSprite); {                         }
{ -------------------------------------------------------------------------- }
Function  InitSysFont(cb,cf:byte):integer;      { load BIOS 1st 128 chars    }
Procedure DoneSysFont;                          { unload system font         }
Procedure TextOut(x,y:integer; st:string);      { write to screen/d-buffer   }
{ -------------------------------------------------------------------------- }
Function  GetVGAErrorMsg(n:integer):string;     { get error msg by errnum    }
{ -------------------------------------------------------------------------- }

Implementation
Uses
  CRT;

Type
  PFontBuffer = ^TFontBuffer;
  TFontBuffer = array[0..8191] of byte;

Var
  sysfont  : PFontBuffer;

{ --------------------------------------------------------------------- }

Function GetVideoMode;
{    Job : return current videomode via bios call                       }
{  Input : none                                                         }
{ Output : videomode ( byte )                                           }
begin;
  asm
    mov ah, $0F
    int $10
    mov @result, al
  end;
end;

Procedure SetVideoMode; assembler;
{    Job : set video mode via bios call                                 }
{  Input : videomode number ( byte )                                    }
{ Output : none                                                         }
asm
  xor ah, ah
  mov al, n
  int $10
end;

Procedure InitGraphMode; assembler;
{    Job : initiate 13h mode ( 320x200x256 )                            }
{  Input : none                                                         }
{ Output : none                                                         }
asm
  mov ax,$0013
  int $10
end;

Procedure DoneGraphMode; assembler;
{    Job : reset to 03h text mode ( 80x25 )                             }
{  Input : none                                                         }
{ Output : none                                                         }
asm
  mov ax, $0003
  int $10
end;

Function InitDoubleBuffer;
{    Job : allocate double buffer 64000 bytes in heap                   }
{  Input : none                                                         }
{ Output : operation error code (integer), 0 if no errors               }
begin
  if dbuffer = vbuffer then begin
    if MaxAvail < 64000 then begin
      InitDoubleBuffer:=VGA_NoMemory; exit;
    end;
    getmem(dbuffer,64000);
  end;
  InitDoubleBuffer:=VGA_Ok;
end;

Procedure DoneDoubleBuffer;
{    Job : deallocate double buffer                                     }
{  Input : none                                                         }
{ Output : none                                                         }
begin
  if dbuffer <> vbuffer then begin
    freemem(dbuffer,64000);
    dbuffer:=vbuffer;
  end;
end;

Procedure ShowBuffer32;   external;
{    Job : fast copy double buffer to VGA screen memory                 }
{  Input : none                                                         }
{ Output : none                                                         }

Procedure ClearDBuffer32; external;
{    Job : fast cleaning double buffer                                  }
{  Input : none                                                         }
{ Output : none                                                         }

Procedure ClearVBuffer32; external;
{    Job : fast cleaning VGA screen memory                              }
{  Input : none                                                         }
{ Output : none                                                         }

Procedure Retrace; assembler;
{    Job : wait for begin retracing CRT                                 }
{  Input : none                                                         }
{ Output : none                                                         }
asm
  mov dx,$3da
 @wait1:
  in al,dx
  and al,8
  jnz @wait1
 @wait2:
  in al,dx
  and al,8
  jz @wait2
end;

{ --------------------------------------------------------------------- }

Procedure SetPoint; assembler;
{    Job : set fast point on screen/double buffer ( with clipping )     }
{  Input : x, y - coordinates; c - color index                          }
{ Output : none                                                         }
asm
  mov ax, y              { load y to ax }
  cmp ax, MinY
  jl @fin
  cmp ax, MaxY
  jg @fin
  mov cx, x              { load x to cx }
  cmp cx, MinX
  jl @fin
  cmp cx, MaxX
  jg @fin
  les di, dbuffer        { loading d-buffer starting address }
  mov bx, ax             { copy y to bx }
  sal ax, 6              { shift equal mult on 32 }
  sal bx, 8              { shift equal mult on 256 }
  add ax, bx             { equal mult on 320 (with shifts) }
  add ax, cx             { starting point solved }
  add di, ax             { starting point in es:di now }
  mov bh, c              { load color into bh }
  mov es:[di], bh        { moving color into d-buffer }
 @fin:
end;

Function  GetPoint;
{    Job : get point from screen/double buffer ( with clipping )        }
{  Input : x, y - coordinates                                           }
{ Output : color index                                                  }
begin;
  asm
    mov ax, y              { load y to ax }
    cmp ax, MinY
    jl @fin
    cmp ax, MaxY
    jg @fin
    mov cx, x              { load x to cx }
    cmp cx, MinX
    jl @fin
    cmp cx, MaxX
    jg @fin
    les di, dbuffer        { loading d-buffer starting address }
    mov bx, ax             { copy y to bx }
    sal ax, 6              { shift equal mult on 32 }
    sal bx, 8              { shift equal mult on 256 }
    add ax, bx             { equal mult on 320 (with shifts) }
    add ax, cx             { starting point solved }
    add di, ax             { starting point in es:di now }
    mov bh, es:[di]
    mov @result, bh
    jmp @ok
   @fin:
    mov @result, 0
   @ok:
  end;
end;

Procedure SetScreenPoint; assembler;
{    Job : set point direct to screen ( with clipping )                 }
{  Input : x, y - coordinates; c - color index                          }
{ Output : none                                                         }
asm
  mov ax, y              { load y to ax }
  cmp ax, MinY
  jl @fin
  cmp ax, MaxY
  jg @fin
  mov cx, x              { load x to cx }
  cmp cx, MinX
  jl @fin
  cmp cx, MaxX
  jg @fin
  les di, vbuffer        { loading screen buffer starting address }
  mov bx, ax             { copy y to bx }
  sal ax, 6              { shift equal mult on 32 }
  sal bx, 8              { shift equal mult on 256 }
  add ax, bx             { equal mult on 320 (with shifts) }
  add ax, cx             { starting point solved }
  add di, ax             { starting point in es:di now }
  mov bh, c              { load color into bh }
  mov es:[di], bh        { moving color into d-buffer }
 @fin:
end;

Function  GetScreenPoint;
{    Job : get point from VGA screen memory                             }
{  Input : x, y - coordinates                                           }
{ Output : color index                                                  }
begin;
  asm
    mov ax, y              { load y to ax }
    cmp ax, MinY
    jl @fin
    cmp ax, MaxX
    jg @fin
    mov cx, x              { load x to cx }
    cmp cx, MinX
    jl @fin
    cmp cx, MaxX
    jg @fin
    les di, vbuffer        { loading d-buffer starting address }
    mov bx, ax             { copy y to bx }
    sal ax, 6              { shift equal mult on 32 }
    sal bx, 8              { shift equal mult on 256 }
    add ax, bx             { equal mult on 320 (with shifts) }
    add ax, cx             { starting point solved }
    add di, ax             { starting point in es:di now }
    mov bh, es:[di]        { load point from buffer to bh }
    mov @result, bh        { return color into func. result }
    jmp @ok
   @fin:
    mov @result, 0
   @ok:
  end;
end;

Procedure SetVLine; assembler;
{    Job : draw vertical line to screen/double buffer ( with clipping ) }
{  Input : x, y1, y2 - coordinates; c - color index                     }
{ Output : none                                                         }
asm
  mov cx, x
  cmp cx, MinX
  jl @fin
  cmp cx, MaxX
  jg @fin
  mov ax, y1
  cmp y2, ax
  jg @nochange
    xchg y2, ax
    mov y1, ax
 @nochange:
  mov ax, y1
  cmp ax, MaxY
  jg @fin
  cmp ax, MinY
  jge @notopcut
  mov ax, MinY
  mov y1, ax
 @notopcut:
  mov ax, y2
  cmp ax, MinY
  jl @fin
  cmp ax, MaxY
  jle @nobottomcut
  mov ax, MaxY
  mov y2, ax
 @nobottomcut:
  les di, dbuffer       { loading d-buffer starting address }
  mov ax, y1            { solving starting point }
  mov bx, ax            { copy y1 to bx }
  sal ax, 6             { shift equal mult on 32 }
  sal bx, 8             { shift equal mult on 256 }
  add ax, bx            { equal mult on 320 (with shifts) }
  mov bx, x             { load x to bx }
  add ax, bx            { starting point solved }
  add di, ax            { starting point in es:di now }
  mov cx, y2            { load y2 coordinate to ax }
  mov bx, y1            { load y1 coordinate to bx }
  inc cx                { correct size of line }
  sub cx, bx            { size of line -1 in ax }
  mov bh, c             { load color into bh }
  mov ax, 320           { load size of line into cx }
 @cont:                 { label for repeat points }
    mov es:[di], bh     { moving color into d-buffer }
    add di, ax          { increment pointer }
  loop @cont            { return if not ready }
 @fin:
end;

Procedure SetHLine; assembler;
{    Job : draw horizontal line to screen/dble buffer ( with clipping ) }
{  Input : x1, x2, y - coordinates, c - color index                     }
{ Output : none                                                         }
asm
  mov ax, y
  cmp ax, MinY
  jl @fin
  cmp ax, MaxY
  jg @fin
  mov ax, x1
  cmp x2, ax
  jg @nochange
    xchg x2, ax
    mov x1, ax
 @nochange:
  mov ax, x1
  cmp ax, MaxX
  jg @fin
  cmp ax, MinX
  jge @noleftcut
  mov ax, MinX
  mov x1, ax
 @noleftcut:
  mov ax, x2
  cmp ax, MinX
  jl @fin
  cmp ax, MaxX
  jle @norightcut
  mov ax, MaxX
  mov x2, ax
 @norightcut:
  les di, dbuffer       { loading d-buffer starting address }
  mov ax, y             { solving starting point }
  mov bx, ax            { copy y to bx }
  sal ax, 6             { shift equal mult on 32 }
  sal bx, 8             { shift equal mult on 256 }
  add ax, bx            { equal mult on 320 (with shifts) }
  mov bx, x1            { load first x to bx }
  add ax, bx            { starting point solved }
  add di, ax            { starting point in es:di now }
  mov cx, x2            { load y2 coordinate to ax }
  inc cx                { correct size of line }
  mov bx, x1            { load y1 coordinate bx }
  sub cx, bx            { size of line -1 in ax }
  mov bh, c             { load color into bh }
 @cont:                 { label for repeat point }
    mov es:[di], bh     { moving color into d-buffer }
    inc di              { increment pointer }
  loop @cont            { return if not ready }
 @fin:
end;

procedure SetLine;  { * needs optimizing * }
{    Job : draw any line on screen/double buffer                        }
{  Input : x1, y1, x2, y2 - coordinates; c - color index                }
{ Output : none                                                         }
var dx, dy, s, e, i : integer; j, delta : single;
begin
  dx:=x2 - x1;
  dy:=y2 - y1;
  if dx = 0 then begin
    if dy = 0 then begin SetPoint(x1,y1,c); exit; end;
    if dy > 0 then begin SetVLine(x1,y1,y2,c); exit; end;
  end;
  if dy = 0 then begin
    if dx = 0 then begin SetPoint(x1,y1,c); exit; end;
    if dx > 0 then begin SetHLine(x1,x2,y1,c); exit; end;
  end;
  if abs(dx) > abs(dy) then begin
    delta:=dy / dx;
    if dx > 0 then begin
      j:=y1; s:=x1; e:=x2;
    end else begin
      j:=y2; s:=x2; e:=x1;
    end;
    for i:=s to e do begin
      SetPoint(i,round(j),c); j:=j+delta;
    end;
  end else begin
    delta:=dx / dy;
    if dy > 0 then begin
      j:=x1; s:=y1; e:=y2;
    end else begin
      j:=x2; s:=y2; e:=y1;
    end;
    for i:=s to e do begin
      SetPoint(round(j),i,c); j:=j+delta;
    end;
  end;
end;

Procedure SetBox;  { * needs optimizing a bit * }
{    Job : draw filled box on screen/double buffer                      }
{  Input : x1, y1, x2, y2 - coordinates; c - color index                }
{ Output : none                                                         }
var i, s, e : integer;
begin
  if y1 < y2 then begin s:=y1; e:=y2 end else begin s:=y2; e:=y1; end;
  for i:=s to e do SetHLine(x1,x2,i,c);
end;

Procedure SetRect;  { * needs optimizing a bit * }
{    Job : draw rectangle on screen/double buffer                       }
{  Input : x1, y1, x2, y2 - coordinates; c - color index                }
{ Output : none                                                         }
begin
  SetHLine(x1,x2,y1,c);
  SetHLine(x1,x2,y2,c);
  SetVLine(x1,y1,y2,c);
  SetVLine(x2,y1,y2,c);
end;

{ --------------------------------------------------------------------- }

Procedure SetPaletteColor;
{    Job : set selected color in VGA palette                            }
{  Input : c - color index; r, g, b - color components (0..63)          }
{ Output : none                                                         }
begin
  port[$3C6]:=$FF;
  port[$3C8]:=c;
  port[$3C9]:=r;
  port[$3C9]:=g;
  port[$3C9]:=b;
end;

Procedure GetPaletteColor;
{    Job : get selected color from VGA palette                          }
{  Input : c - color index                                              }
{ Output : r, g, b - color components (0..63)                           }
begin
  port[$3C6]:=$FF;
  port[$3C7]:=c;
  r:=port[$3C9];
  g:=port[$3C9];
  b:=port[$3C9];
end;

Function ColorInPal;
{    Job : check color in palette                                       }
{  Input : r,g,b - color components; p - palette, if NIL - VGA palette  }
{ Output : true if color in palette, in that case c - index in palette  }
var
  pal        : PVGAPalette;
  tr, tg, tb : byte;
  ok, en     : boolean;
begin
  c:=0; pal:=p; ok:=false; en:=false;
  repeat
    if pal = NIL then begin
      GetPaletteColor(c,tr,tg,tb);
    end else begin
      tr:=pal^[c].r;
      tg:=pal^[c].g;
      tb:=pal^[c].b;
    end;
    if (r = tr) and (g = tg) and (b = tb) then ok:=true;
    if (not ok) and (c < 255) then inc(c) else en:=true;
  until ok or en;
  ColorInPal:=ok;
end;

Function FindColor;
{    Job : find nearest color in palette                                }
{  Input : r, g, b - color components; p - palette,if NIL - VGA palette }
{ Output : deviation                                                    }
var
  i, save, tr, tg, tb : byte;
  dist, d : integer; pal : PVGAPalette;
begin
  dist:=1000; save:=0; pal:=p;
  for i:=0 to 255 do begin
    if pal = NIL then begin
      GetPaletteColor(i,tr,tg,tb);
    end else begin
      tr:=pal^[i].r;
      tg:=pal^[i].g;
      tb:=pal^[i].b;
    end;
    d:=round(sqrt(sqr(tr-r)+sqr(tg-g)+sqr(tb-b)));
    if d < dist then begin dist:=d; save:=i; end;
  end;
  c:=save;
end;

Procedure SetAllPalette;
{    Job : set all palette colors from memory buffer                    }
{  Input : p - pointer to mem buffer ( 768 bytes of color components )  }
{ Output : none                                                         }
var i:byte; pp : PVGAPalette;
begin
  pp:=p;
  for i:=0 to 255 do begin
    port[$3C6]:=$FF;
    port[$3C8]:=i;
    port[$3C9]:=pp^[i].r;
    port[$3C9]:=pp^[i].g;
    port[$3C9]:=pp^[i].b;
  end;
end;

Procedure GetAllPalette;
{    Job : read all VGA palette colors from DAC to memory buffer        }
{  Input : p - pointer to mem buffer ( 768 bytes of color components )  }
{ Output : none                                                         }
var i:byte; pp : PVGAPalette;
begin
  pp:=p;
  for i:=0 to 255 do begin
    port[$3C6]:=$FF;
    port[$3C7]:=i;
    pp^[i].r:=port[$3C9];
    pp^[i].g:=port[$3C9];
    pp^[i].b:=port[$3C9];
  end;
end;

Procedure FadeIn; { * needs optimizing * }
{    Job : fading screen palette into new palette                       }
{  Input : n - fading speed; p : new palette                            }
{ Output : none                                                         }
var tmp : TVGAPalette; pp : PVGAPalette; i, j : byte;
begin
  pp:=p;
  for j:=0 to 63 do begin
    Delay(n);
    for i:=0 to 255 do begin
      tmp[i].R:=round((pp^[i].r / 63) * j);
      tmp[i].G:=round((pp^[i].g / 63) * j);
      tmp[i].B:=round((pp^[i].b / 63) * j);
    end;
    Retrace;
    SetAllPalette(@tmp);
  end;
end;

Procedure FadeOut; { * needs optimizing * }
{    Job : fading screen out                                            }
{  Input : n - fading speed                                             }
{ Output : none                                                         }
var tmp, base : TVGAPalette; i, j : byte;
begin
  GetAllPalette(@base);
  for j:=63 downto 0 do begin
    Delay(n);
    for i:=0 to 255 do begin
      tmp[i].R:=round(j * (base[i].R / 63));
      tmp[i].G:=round(j * (base[i].G / 63));
      tmp[i].B:=round(j * (base[i].B / 63));
    end;
    Retrace;
    SetAllPalette(@tmp);
  end;
end;

{ --------------------------------------------------------------------- }

Procedure BitBLT_Opaque;
{    Job : draw sprite to screen/double buffer ( with clipping )        }
{  Input : x, y - coordinates; sprite - sprite structure                }
{ Output : none                                                         }
var ra, rb, ox, oy, fx, fy, ch1, ch2 : integer; sz, rz : word;
begin
  asm
    mov ax, x
    mov bx, MaxX
    cmp ax, bx
    jg @fin
    mov dx, MinX
    mov cx, sprite.a
    add ax, cx
    cmp ax, dx
    jle @fin
    mov ra, cx
    mov ax, x
    cmp ax, dx
    jge @m_zx
      mov ox, dx
      sub ox, ax
      mov fx, dx
      mov cx, ox
      sub ra, cx
      jmp @m_zxe
    @m_zx:
      mov ox, 0
      mov fx, ax
    @m_zxe:
    mov ch1, ax
    mov bx, sprite.a
    dec bx
    add ch1, bx
    mov cx, MaxX
    cmp ch1, cx
    jle @noxdec
      mov ax, ch1
      sub ax, cx
      sub ra, ax
    @noxdec:
    mov ax, y
    mov bx, MaxY
    cmp ax, bx
    jg @fin
    mov dx, MinY
    mov cx, sprite.b
    add ax, cx
    cmp ax, dx
    jle @fin
    mov rb, cx
    mov ax, y
    cmp ax, dx
    jge @m_zy
      mov oy, dx
      sub oy, ax
      mov fy, dx
      mov cx, oy
      sub rb, cx
      jmp @m_zye
    @m_zy:
      mov oy, 0
      mov fy, ax
    @m_zye:
    mov ch2, ax
    mov bx, sprite.b
    dec bx
    add ch2, bx
    mov cx, MaxY
    cmp ch2, cx
    jle @noydec
      mov ax, ch2
      sub ax, cx
      sub rb, ax
    @noydec:
    mov ax, oy
    mov bx, sprite.a
    imul bx
    mov sz, ax
    mov ax, ra
    mov bx, rb
    imul bx
    mov rz, ax
    { go draw }
    push ds
    les di, dbuffer
    add di, fx
    mov ax, fy
    mov bx, ax
    sal ax, 6
    sal bx, 8
    add di, bx
    add di, ax
    lds si, sprite.data
    add si, sz
    add si, ox
    mov dx, sprite.a
    mov bx, ra
    mov cx, rz
    @sprite_loop:
      mov al, ds:[si]
      mov es:[di], al
      inc di
      inc si
      dec bx
      cmp bx, 0
      jne @nocorr
        mov bx, ra
        sub di, bx
        add di, 320
        add si, dx
        sub si, bx
      @nocorr:
    loop @sprite_loop
    pop ds
    @fin:
  end;
end;

Procedure BitBLT_Transparent;
{    Job : draw sprite to screen/double buffer with transparency check  }
{          trancparency color = 0  ( with clipping )                    }
{  Input : x, y - coordinates; sprite - sprite structure                }
{ Output : none                                                         }
var ra, rb, ox, oy, fx, fy, ch1, ch2 : integer; sz, rz : word;
begin
  asm
    mov ax, x
    mov bx, MaxX
    cmp ax, bx
    jg @fin
    mov dx, MinX
    mov cx, sprite.a
    add ax, cx
    cmp ax, dx
    jle @fin
    mov ra, cx
    mov ax, x
    cmp ax, dx
    jge @m_zx
      mov ox, dx
      sub ox, ax
      mov fx, dx
      mov cx, ox
      sub ra, cx
      jmp @m_zxe
    @m_zx:
      mov ox, 0
      mov fx, ax
    @m_zxe:
    mov ch1, ax
    mov bx, sprite.a
    dec bx
    add ch1, bx
    mov cx, MaxX
    cmp ch1, cx
    jle @noxdec
      mov ax, ch1
      sub ax, cx
      sub ra, ax
    @noxdec:
    mov ax, y
    mov bx, MaxY
    cmp ax, bx
    jg @fin
    mov dx, MinY
    mov cx, sprite.b
    add ax, cx
    cmp ax, dx
    jle @fin
    mov rb, cx
    mov ax, y
    cmp ax, dx
    jge @m_zy
      mov oy, dx
      sub oy, ax
      mov fy, dx
      mov cx, oy
      sub rb, cx
      jmp @m_zye
    @m_zy:
      mov oy, 0
      mov fy, ax
    @m_zye:
    mov ch2, ax
    mov bx, sprite.b
    dec bx
    add ch2, bx
    mov cx, MaxY
    cmp ch2, cx
    jle @noydec
      mov ax, ch2
      sub ax, cx
      sub rb, ax
    @noydec:
    mov ax, oy
    mov bx, sprite.a
    imul bx
    mov sz, ax
    mov ax, ra
    mov bx, rb
    imul bx
    mov rz, ax
    { go draw }
    push ds
    les di, dbuffer
    add di, fx
    mov ax, fy
    mov bx, ax
    sal ax, 6
    sal bx, 8
    add di, bx
    add di, ax
    lds si, sprite.data
    add si, sz
    add si, ox
    mov dx, sprite.a
    mov bx, ra
    mov cx, rz
    @sprite_loop:
      mov al, ds:[si]
      cmp al, 0
      je @skip_transparent
        mov es:[di], al
      @skip_transparent:
      inc di
      inc si
      dec bx
      cmp bx, 0
      jne @nocorr
        mov bx, ra
        sub di, bx
        add di, 320
        add si, dx
        sub si, bx
      @nocorr:
    loop @sprite_loop
    pop ds
    @fin:
  end;
end;

Procedure BitBLT_OpaqueT;
{    Job : draw sprite to screen/double buffer  ( w/o clipping )        }
{  Input : x, y - coordinates; sprite - sprite structure                }
{ Output : none                                                         }
begin
  asm
    push ds                         { save DS segment }
    les di, dbuffer                 { load d-buffer }
    mov ax, y                       { load starting y }
    mov bx, ax                      { copy starting y }
    sal ax, 6                       { mul to 64 }
    sal bx, 8                       { mul to 256 }
    add ax, bx                      { now mul to 320 }
    mov bx, x                       { load starting x }
    add ax, bx                      { solving starting dest point }
    add di, ax                      { dest first point in es:di }
    lds si, sprite.data             { load source point to ds:si }
    mov bx, sprite.b                { load height to bx }
    mov cx, sprite.a                { load width to cx }
    @cont_next_line:                { label for next line }
      mov cx, sprite.a              { load width again }
      @cont_line:                   { label for next pixel }
        mov al, ds:[si]             { load source to al }
        mov [es:di], al             { load al to dest }
        inc si                      { increment source line }
        inc di                      { increment dest line }
        dec cx                      { decrement pixel counter }
      jnz @cont_line                { return if line not ready }
      add di, 320                   { add const to next line }
      sub di, sprite.a              { correct to start line }
      dec bx                        { decrement lines counter }
    jnz @cont_next_line             { continue if block not ready }
    pop ds                          { return ds segment }
  end;
end;

Procedure BitBLT_TransparentT;
{    Job : draw sprite to screen/double buffer with transparency check  }
{          trancparency color = 0  ( w/o clipping )                     }
{  Input : x, y - coordinates; sprite - sprite structure                }
{ Output : none                                                         }
begin
  asm
    push ds                         { save DS segment }
    les di, dbuffer                 { load d-buffer }
    mov ax, y                       { load starting y }
    mov bx, ax                      { copy starting y }
    sal ax, 6                       { mul to 64 }
    sal bx, 8                       { mul to 256 }
    add ax, bx                      { now mul to 320 }
    mov bx, x                       { load starting x }
    add ax, bx                      { solving starting dest point }
    add di, ax                      { dest first point in es:di }
    lds si, sprite.data             { load source point to ds:si }
    mov bx, sprite.b                { load height to bx }
    mov cx, sprite.a                { load width to cx }
    @cont_next_line:                { label for next line }
      mov cx, sprite.a              { load width again }
      @cont_line:                   { label for next pixel }
        mov al, ds:[si]             { load source to al }
        cmp al, 0                   { compare with transparent }
        je @skip_transparent        { skip if transparent }
          mov [es:di], al           { load al to dest }
        @skip_transparent:          { label for skipping }
        inc si                      { increment source line }
        inc di                      { increment dest line }
        dec cx                      { decrement pixel counter }
      jnz @cont_line                { return if line not ready }
      add di, 320                   { add const to next line }
      sub di, sprite.a              { correct to start line }
      dec bx                        { decrement lines counter }
    jnz @cont_next_line             { continue if block not ready }
    pop ds                          { return ds segment }
  end;
end;

procedure Zoom_OpaqueT;    { * needs addon clipping * }
{    Job : moving sprite into screen with zooming ( w/o clipping )   }
{          max sprite size for correct zooming - 255x255             }
{  Input : zx, zy, za, zb - position and size of sprite on screen,   }
{          sprite - sprite structure                                 }
{ Output : none ( visual result :)                                   }
var vdx, vdy, soff : word;
begin
  asm
    push ds                     { save ds register, will changed }
    mov ax, 320                 { * }
    sub ax, word ptr za
    mov word ptr soff, ax       { make screen offset }
    mov ax, word ptr sprite.a   { * }
    mov bx, word ptr za
    sal ax, 8
    xor dx, dx
    div bx
    mov word ptr vdx, ax        { count increment x factor }
    mov ax, word ptr sprite.b   { * }
    mov bx, word ptr zb
    sal ax, 8
    xor dx, dx
    div bx
    mov word ptr vdy, ax     { count increment y factor }
    les di, dbuffer          { * }
    mov ax, zy
    mov bx, ax
    sal ax, 6
    sal bx, 8
    add ax, bx
    mov bx, zx
    add ax, bx
    add di, ax               { es:di points to first screen pixel }
    lds si, sprite.data      { ds:si points to first pixel of sprite }
    xor dx, dx               { reset current row (fixed) counter }
    mov cx, zb               { init counter by column size }
    @column:
      push cx                { save cx for inner loop }
      push dx                { save dx for inner loop }
      xor bx, bx             { reset bx (row pixel offset) }
      xor dx, dx             { reset row (fixed) counter }
      mov cx, za             { init current pixel in row }
      @row:
        mov al, ds:[si][bx]  { pick up pixel from sprite }
        mov es:[di], al      { draw pixel into video (or double) buffer }
        add dx, word ptr vdx { increment pixel in row counter (fixed) }
        mov bl, dh           { modify bx by integer part of current pixel }
        inc di               { increment video (double) buffer offset }
      loop @row              { loop of row drawing }
      add di, word ptr soff  { increment screen (double) buffer offset }
      pop dx                 { restore dx for outer loop }
      pop cx                 { restore cx for outer loop }
      mov ah, dh             { move dh to ah }
      add dx, word ptr vdy   { increment column counter (fixed) }
      mov al, dh
      sub al, ah
      jz @nonextcol
      @incy:
        add si, word ptr sprite.a
        dec al
        cmp al, 0
      jnz @incy
      @nonextcol:
    loop @column
    pop ds                 { restore ds register }
  end;
end;

procedure Zoom_TransparentT;    { * needs addon clipping * }
{    Job : moving sprite into screen with zooming ( w/o clipping )   }
{          max sprite size for correct zooming - 255x255             }
{  Input : zx, zy, za, zb - position and size of sprite on screen,   }
{          sprite - sprite structure                                 }
{ Output : none ( visual result :)                                   }
var vdx, vdy, soff : word;
begin
  asm
    push ds                       { save ds register, will changed }
    mov ax, 320                   { * }
    sub ax, word ptr za
    mov word ptr soff, ax         { make screen offset }
    mov ax, word ptr sprite.a     { * }
    mov bx, word ptr za
    sal ax, 8
    xor dx, dx
    div bx
    mov word ptr vdx, ax          { count increment x factor }
    mov ax, word ptr sprite.b     { * }
    mov bx, word ptr zb
    sal ax, 8
    xor dx, dx
    div bx
    mov word ptr vdy, ax          { count increment y factor }
    les di, dbuffer               { * }
    mov ax, zy
    mov bx, ax
    sal ax, 6
    sal bx, 8
    add ax, bx
    mov bx, zx
    add ax, bx
    add di, ax                    { es:di points to first screen pixel }
    lds si, sprite.data           { ds:si points to first pixel of sprite }
    xor dx, dx                    { reset current row (fixed) counter }
    mov cx, zb                    { init counter by column size }
    @column:
      push cx                     { save cx for inner loop }
      push dx                     { save dx for inner loop }
      xor bx, bx                  { reset bx (row pixel offset) }
      xor dx, dx                  { reset row (fixed) counter }
      mov cx, za                  { init current pixel in row }
      push bp                     { save bp (will changed) }
      mov bp, word ptr vdx        { store horiz. increment into bp }
      @row:
        mov al, ds:[si][bx]       { pick up pixel from sprite }
        cmp al, 0                 { compare pixel with transparent color }
        je @skip                  { skip if transparent color }
          mov es:[di], al         { draw pixel into video (or double) buffer }
        @skip:
        add dx, bp                { increment pixel in row counter (fixed) }
        mov bl, dh                { modify bx by int. part of current pixel }
        inc di                    { increment video (double) buffer offset }
      loop @row                   { loop of row drawing }
      pop bp                      { restore bp register }
      add di, word ptr soff       { increment screen (double) buffer offset }
      pop dx                      { restore dx for outer loop }
      pop cx                      { restore cx for outer loop }
      mov ah, dh                  { move dh to ah }
      add dx, word ptr vdy        { increment column counter (fixed) }
      mov al, dh
      sub al, ah
      jz @nonextcol
        mov bx, word ptr sprite.a
        @incy:
          add si, bx
          dec al
          cmp al, 0
        jnz @incy
      @nonextcol:
    loop @column
    pop ds                        { restore ds register }
  end;
end;

procedure GetImage;  { * needs optimizing * }
{    Job : moving screen/dbl buffer image to sprite structure           }
{  Input : zx, zy - position image on screen                            }
{          sprite - sprite structure, filled with a, b sprite size      }
{          and allocated memory for sprite ( getmem(data, a * b) )      }
{ Output : none                                                         }
type tm = array[0..64000] of byte;
var i, j : integer; m : ^tm;
begin
  m:=sprite.data;
  for i:=zx to zx+sprite.a-1 do begin
    for j:=zy to zy+sprite.b-1 do begin
      m^[(i-zx)+(j-zy)*sprite.a]:=GetPoint(i,j);
    end;
  end;
end;

{ ------------------------------------------------------------------------ }

Function InitSysFont;
{    Job : allocate buffer and fill it with char bitmaps                  }
{          here using copy of BIOS standart first 128 ASCII chars         }
{  Input : cb, cf - colors of background and foreground of chars          }
{ Output : error code, 0 if Ok                                            }
const
  fs : array[0..1023] of byte =
          (  0,  0,  0,  0,  0,  0,  0,  0,126,129,165,129,189,153,129,126,
           126,255,219,255,195,231,255,126,108,254,254,254,124, 56, 16,  0,
            16, 56,124,254,124, 56, 16,  0, 56,124, 56,254,254,124, 56,124,
            16, 16, 56,124,254,124, 56,124,  0,  0, 24, 60, 60, 24,  0,  0,
           255,255,231,195,195,231,255,255,  0, 60,102, 66, 66,102, 60,  0,
           255,195,153,189,189,153,195,255, 15,  7, 15,125,204,204,204,120,
            60,102,102,102, 60, 24,126, 24, 63, 51, 63, 48, 48,112,240,224,
           127, 99,127, 99, 99,103,230,192,153, 90, 60,231,231, 60, 90,153,
           128,224,248,254,248,224,128,  0,  2, 14, 62,254, 62, 14,  2,  0,
            24, 60,126, 24, 24,126, 60, 24,102,102,102,102,102,  0,102,  0,
           127,219,219,123, 27, 27, 27,  0, 62, 99, 56,108,108, 56,204,120,
             0,  0,  0,  0,126,126,126,  0, 24, 60,126, 24,126, 60, 24,255,
            24, 60,126, 24, 24, 24, 24,  0, 24, 24, 24, 24,126, 60, 24,  0,
             0, 24, 12,254, 12, 24,  0,  0,  0, 48, 96,254, 96, 48,  0,  0,
             0,  0,192,192,192,254,  0,  0,  0, 36,102,255,102, 36,  0,  0,
             0, 24, 60,126,255,255,  0,  0,  0,255,255,126, 60, 24,  0,  0,
             0,  0,  0,  0,  0,  0,  0,  0, 48,120,120,120, 48,  0, 48,  0,
           108,108,108,  0,  0,  0,  0,  0,108,108,254,108,254,108,108,  0,
            48,124,192,120, 12,248, 48,  0,  0,198,204, 24, 48,102,198,  0,
            56,108, 56,118,220,204,118,  0, 96, 96,192,  0,  0,  0,  0,  0,
            24, 48, 96, 96, 96, 48, 24,  0, 96, 48, 24, 24, 24, 48, 96,  0,
             0,102, 60,255, 60,102,  0,  0,  0, 48, 48,252, 48, 48,  0,  0,
             0,  0,  0,  0,  0, 48, 48, 96,  0,  0,  0,252,  0,  0,  0,  0,
             0,  0,  0,  0,  0, 48, 48,  0,  6, 12, 24, 48, 96,192,128,  0,
           124,198,206,222,246,230,124,  0, 48,112, 48, 48, 48, 48,252,  0,
           120,204, 12, 56, 96,204,252,  0,120,204, 12, 56, 12,204,120,  0,
            28, 60,108,204,254, 12, 30,  0,252,192,248, 12, 12,204,120,  0,
            56, 96,192,248,204,204,120,  0,252,204, 12, 24, 48, 48, 48,  0,
           120,204,204,120,204,204,120,  0,120,204,204,124, 12, 24,112,  0,
             0, 48, 48,  0,  0, 48, 48,  0,  0, 48, 48,  0,  0, 48, 48, 96,
            24, 48, 96,192, 96, 48, 24,  0,  0,  0,252,  0,  0,252,  0,  0,
            96, 48, 24, 12, 24, 48, 96,  0,120,204, 12, 24, 48,  0, 48,  0,
           124,198,222,222,222,192,120,  0, 48,120,204,204,252,204,204,  0,
           252,102,102,124,102,102,252,  0, 60,102,192,192,192,102, 60,  0,
           248,108,102,102,102,108,248,  0,126, 96, 96,120, 96, 96,126,  0,
           126, 96, 96,120, 96, 96, 96,  0, 60,102,192,192,206,102, 62,  0,
           204,204,204,252,204,204,204,  0,120, 48, 48, 48, 48, 48,120,  0,
            30, 12, 12, 12,204,204,120,  0,230,102,108,120,108,102,230,  0,
            96, 96, 96, 96, 96, 96,126,  0,198,238,254,254,214,198,198,  0,
           198,230,246,222,206,198,198,  0, 56,108,198,198,198,108, 56,  0,
           252,102,102,124, 96, 96,240,  0,120,204,204,204,220,120, 28,  0,
           252,102,102,124,108,102,230,  0,120,204,224,112, 28,204,120,  0,
           252, 48, 48, 48, 48, 48, 48,  0,204,204,204,204,204,204,252,  0,
           204,204,204,204,204,120, 48,  0,198,198,198,214,254,238,198,  0,
           198,198,108, 56, 56,108,198,  0,204,204,204,120, 48, 48,120,  0,
           254,  6, 12, 24, 48, 96,254,  0,120, 96, 96, 96, 96, 96,120,  0,
           192, 96, 48, 24, 12,  6,  2,  0,120, 24, 24, 24, 24, 24,120,  0,
            16, 56,108,198,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,255,
            48, 48, 24,  0,  0,  0,  0,  0,  0,  0,120, 12,124,204,118,  0,
           224, 96, 96,124,102,102,220,  0,  0,  0,120,204,192,204,120,  0,
            28, 12, 12,124,204,204,118,  0,  0,  0,120,204,252,192,120,  0,
            56,108, 96,240, 96, 96,240,  0,  0,  0,118,204,204,124, 12,248,
           224, 96,108,118,102,102,230,  0, 48,  0,112, 48, 48, 48,120,  0,
            12,  0, 12, 12, 12,204,204,120,224, 96,102,108,120,108,230,  0,
           112, 48, 48, 48, 48, 48,120,  0,  0,  0,204,254,254,214,198,  0,
             0,  0,248,204,204,204,204,  0,  0,  0,120,204,204,204,120,  0,
             0,  0,220,102,102,124, 96,240,  0,  0,118,204,204,124, 12, 30,
             0,  0,220,118,102, 96,240,  0,  0,  0,124,192,120, 12,248,  0,
            16, 48,124, 48, 48, 52, 24,  0,  0,  0,204,204,204,204,118,  0,
             0,  0,204,204,204,120, 48,  0,  0,  0,198,214,254,254,108,  0,
             0,  0,198,108, 56,108,198,  0,  0,  0,204,204,204,124, 12,248,
             0,  0,252,152, 48,100,252,  0, 28, 48, 48,224, 48, 48, 28,  0,
            24, 24, 24,  0, 24, 24, 24,  0,224, 48, 48, 28, 48, 48,224,  0,
           118,220,  0,  0,  0,  0,  0,  0,  0, 16, 56,108,198,198,254,  0);
var i,j,k,v : byte;
begin
  if sysfont <> NIL then exit;
  if maxavail < sizeof(TFontBuffer) then begin
    InitSysFont:=VGA_NoMemory; exit;
  end;
  new(sysfont);
  for i:=0 to 127 do begin                          { symbol count }
    for j:=0 to 7 do begin                          { byte   count(line) }
      for k:=0 to 7 do begin                        { bit    count(column) }
        {v:=($80 shr k) and (mem[$F000:$FA6E+i*8+j]);}
        v:=($80 shr k) and fs[i*8+j];
        if v > 0 then sysfont^[i*64+j*8+k]:=cf
                 else sysfont^[i*64+j*8+k]:=cb;
      end;
    end;
  end;
  InitSysFont:=VGA_Ok;
end;

Procedure DoneSysFont;
{    Job : deallocate system bitmap font buffer                           }
{  Input : none                                                           }
{ Output : none                                                           }
begin
  if sysfont = NIL then exit;
  dispose(sysfont); sysfont:=NIL;
end;

Procedure TextOut;   { * needs addon clipping * }
{    Job : writing string out to screen/dble-buffer ( without cliping ) }
{  Input : x, y - position of left top corner of string; st - string    }
{ Output : none                                                         }
var size : word; lineptr : pointer;
begin
  if sysfont = NIL then begin exit; end;
  size:=length(st);
  if size = 0 then exit;
  lineptr:=addr(st);
  asm
    push ds
    les di, dbuffer
    mov ax, y
    mov bx, ax             { copy y to bx }
    sal ax, 6              { shift equal mult on 32 }
    sal bx, 8              { shift equal mult on 256 }
    add ax, bx             { equal mult on 320 (with shifts) }
    mov bx, x
    add ax, bx
    add di, ax             { es:di - screen position }
    lds si, sysfont
    mov dx, 1              { current char }
    mov cx, size
    @char:
      push es
      push di
      les di, lineptr
      add di, dx
      inc dx
      xor ax, ax
      mov al, es:[di]
      and al, $7F
      sal ax, 6
      mov bx, ax
      pop di
      pop es
      push cx
      mov cx, 8
        @col:
        push cx
        mov cx, 8
          @row:
          mov al, ds:[si+bx] { ds:si points to 64 bytes of char in font }
          cmp al, 0
          jz @skip_transparent
          mov es:[di], al
          @skip_transparent:
          inc si
        inc di
      loop @row
      pop cx
      add di, 312
    loop @col
    sub di, 2552
    sub si, 64
    pop cx
    loop @char
    pop ds
  end;
end;

{ --------------------------------------------------------------------- }

Function  GetVGAErrorMsg(n:integer):string;
{    Job : return text message of VGA error                             }
{  Input : n - error code                                               }
{ Output : string with error message                                    }
var msg : string;
begin
  case n of
    VGA_Ok         : msg:='No errors';
    VGA_NoMemory   : msg:='Out of memory';
    VGA_IOError    : msg:='IO error';
    VGA_NoFile     : msg:='File not exists';
    VGA_BadVersion : msg:='Version unsupported';
    VGA_BadFormat  : msg:='Incorrect file format';
  else
    msg:='Undefined error';
  end;
  GetVGAErrorMsg:=msg;
end;

Begin
  sysfont:=NIL;
  {$IFDEF DPMI}
    dbuffer:=ptr(SegA000,$0000);
    vbuffer:=ptr(SegA000,$0000);
  {$ELSE}
    dbuffer:=ptr($A000,$0000);
    vbuffer:=ptr($A000,$0000);
  {$ENDIF}
End.

{ ---x---x---x---x---x---x---x--- Cut here ---x---x---x---x---x---x---x--- }

{ Move that part into VB30.ASM and assemble it with TASM  }

.MODEL MEDIUM

EXTRN vbuffer:DWORD
EXTRN dbuffer:DWORD

PUBLIC ClearDBuffer32
PUBLIC ClearVBuffer32
PUBLIC ShowBuffer32

.CODE
.386

ClearDBuffer32 PROC FAR
  cld
  les di, dbuffer
  mov cx, 16000
  xor eax, eax
  rep stosd
  ret
ClearDBuffer32 ENDP

ClearVBuffer32 PROC FAR
  cld
  les di, vbuffer
  mov cx, 16000
  xor eax, eax
  rep stosd
  ret
ClearVBuffer32 ENDP

ShowBuffer32 PROC FAR
  push ds
  cld
  les di, vbuffer
  lds si, dbuffer
  mov cx, 16000
  rep movsd
  pop ds
  ret
ShowBuffer32 ENDP

END

{ End of VB30.ASM file }

{ ---x---x---x---x---x---x---x--- Cut here ---x---x---x---x---x---x---x--- }

{ there are 8x8 chars, image from BIOS first 128 chars           }
{ every char coded by 8 bytes, every bit in byte is point in row }

{   bits : 7 6 5 4 3 2 1 0                                       }
{ byte 0  [#|#|#|#|#|#| | ]  = 1111 1100 = $FC = 252             }
{ byte 1  [ |#|#| | |#|#| ]  = 0110 0110 = $66 = 102             }
{ byte 2  [ |#|#| | |#|#| ]  = 0110 0110 = $66 = 102             }
{ byte 3  [ |#|#|#|#|#| | ]  = 0111 1100 = $7C = 124             }
{ byte 4  [ |#|#| | |#|#| ]  = 0110 0110 = $66 = 102             }
{ byte 5  [ |#|#| | |#|#| ]  = 0110 0110 = $66 = 102             }
{ byte 6  [#|#|#|#|#|#| | ]  = 1111 1100 = $FC = 252             }
{ byte 7  [ | | | | | | | ]  = 0000 0000 = $00 =   0             }

const
  fs : array[0..1023] of byte =
  (  0,  0,  0,  0,  0,  0,  0,  0,126,129,165,129,189,153,129,126,
   126,255,219,255,195,231,255,126,108,254,254,254,124, 56, 16,  0,
    16, 56,124,254,124, 56, 16,  0, 56,124, 56,254,254,124, 56,124,
    16, 16, 56,124,254,124, 56,124,  0,  0, 24, 60, 60, 24,  0,  0,
   255,255,231,195,195,231,255,255,  0, 60,102, 66, 66,102, 60,  0,
   255,195,153,189,189,153,195,255, 15,  7, 15,125,204,204,204,120,
    60,102,102,102, 60, 24,126, 24, 63, 51, 63, 48, 48,112,240,224,
   127, 99,127, 99, 99,103,230,192,153, 90, 60,231,231, 60, 90,153,
   128,224,248,254,248,224,128,  0,  2, 14, 62,254, 62, 14,  2,  0,
    24, 60,126, 24, 24,126, 60, 24,102,102,102,102,102,  0,102,  0,
   127,219,219,123, 27, 27, 27,  0, 62, 99, 56,108,108, 56,204,120,
     0,  0,  0,  0,126,126,126,  0, 24, 60,126, 24,126, 60, 24,255,
    24, 60,126, 24, 24, 24, 24,  0, 24, 24, 24, 24,126, 60, 24,  0,
     0, 24, 12,254, 12, 24,  0,  0,  0, 48, 96,254, 96, 48,  0,  0,
     0,  0,192,192,192,254,  0,  0,  0, 36,102,255,102, 36,  0,  0,
     0, 24, 60,126,255,255,  0,  0,  0,255,255,126, 60, 24,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0, 48,120,120,120, 48,  0, 48,  0,
   108,108,108,  0,  0,  0,  0,  0,108,108,254,108,254,108,108,  0,
    48,124,192,120, 12,248, 48,  0,  0,198,204, 24, 48,102,198,  0,
    56,108, 56,118,220,204,118,  0, 96, 96,192,  0,  0,  0,  0,  0,
    24, 48, 96, 96, 96, 48, 24,  0, 96, 48, 24, 24, 24, 48, 96,  0,
     0,102, 60,255, 60,102,  0,  0,  0, 48, 48,252, 48, 48,  0,  0,
     0,  0,  0,  0,  0, 48, 48, 96,  0,  0,  0,252,  0,  0,  0,  0,
     0,  0,  0,  0,  0, 48, 48,  0,  6, 12, 24, 48, 96,192,128,  0,
   124,198,206,222,246,230,124,  0, 48,112, 48, 48, 48, 48,252,  0,
   120,204, 12, 56, 96,204,252,  0,120,204, 12, 56, 12,204,120,  0,
    28, 60,108,204,254, 12, 30,  0,252,192,248, 12, 12,204,120,  0,
    56, 96,192,248,204,204,120,  0,252,204, 12, 24, 48, 48, 48,  0,
   120,204,204,120,204,204,120,  0,120,204,204,124, 12, 24,112,  0,
     0, 48, 48,  0,  0, 48, 48,  0,  0, 48, 48,  0,  0, 48, 48, 96,
    24, 48, 96,192, 96, 48, 24,  0,  0,  0,252,  0,  0,252,  0,  0,
    96, 48, 24, 12, 24, 48, 96,  0,120,204, 12, 24, 48,  0, 48,  0,
   124,198,222,222,222,192,120,  0, 48,120,204,204,252,204,204,  0,
   252,102,102,124,102,102,252,  0, 60,102,192,192,192,102, 60,  0,
   248,108,102,102,102,108,248,  0,126, 96, 96,120, 96, 96,126,  0,
   126, 96, 96,120, 96, 96, 96,  0, 60,102,192,192,206,102, 62,  0,
   204,204,204,252,204,204,204,  0,120, 48, 48, 48, 48, 48,120,  0,
    30, 12, 12, 12,204,204,120,  0,230,102,108,120,108,102,230,  0,
    96, 96, 96, 96, 96, 96,126,  0,198,238,254,254,214,198,198,  0,
   198,230,246,222,206,198,198,  0, 56,108,198,198,198,108, 56,  0,
   252,102,102,124, 96, 96,240,  0,120,204,204,204,220,120, 28,  0,
   252,102,102,124,108,102,230,  0,120,204,224,112, 28,204,120,  0,
   252, 48, 48, 48, 48, 48, 48,  0,204,204,204,204,204,204,252,  0,
   204,204,204,204,204,120, 48,  0,198,198,198,214,254,238,198,  0,
   198,198,108, 56, 56,108,198,  0,204,204,204,120, 48, 48,120,  0,
   254,  6, 12, 24, 48, 96,254,  0,120, 96, 96, 96, 96, 96,120,  0,
   192, 96, 48, 24, 12,  6,  2,  0,120, 24, 24, 24, 24, 24,120,  0,
    16, 56,108,198,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,255,
    48, 48, 24,  0,  0,  0,  0,  0,  0,  0,120, 12,124,204,118,  0,
   224, 96, 96,124,102,102,220,  0,  0,  0,120,204,192,204,120,  0,
    28, 12, 12,124,204,204,118,  0,  0,  0,120,204,252,192,120,  0,
    56,108, 96,240, 96, 96,240,  0,  0,  0,118,204,204,124, 12,248,
   224, 96,108,118,102,102,230,  0, 48,  0,112, 48, 48, 48,120,  0,
    12,  0, 12, 12, 12,204,204,120,224, 96,102,108,120,108,230,  0,
   112, 48, 48, 48, 48, 48,120,  0,  0,  0,204,254,254,214,198,  0,
     0,  0,248,204,204,204,204,  0,  0,  0,120,204,204,204,120,  0,
     0,  0,220,102,102,124, 96,240,  0,  0,118,204,204,124, 12, 30,
     0,  0,220,118,102, 96,240,  0,  0,  0,124,192,120, 12,248,  0,
    16, 48,124, 48, 48, 52, 24,  0,  0,  0,204,204,204,204,118,  0,
     0,  0,204,204,204,120, 48,  0,  0,  0,198,214,254,254,108,  0,
     0,  0,198,108, 56,108,198,  0,  0,  0,204,204,204,124, 12,248,
     0,  0,252,152, 48,100,252,  0, 28, 48, 48,224, 48, 48, 28,  0,
    24, 24, 24,  0, 24, 24, 24,  0,224, 48, 48, 28, 48, 48,224,  0,
   118,220,  0,  0,  0,  0,  0,  0,  0, 16, 56,108,198,198,254,  0);

{ End of char fonts }

{ ---x---x---x---x---x---x---x--- Cut here ---x---x---x---x---x---x---x--- }

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}

{ ----------------------------  OBJ NEEDED FOR THIS UNIT --------------------- }


*XX3402-000335-170197--72--85-61511--------VB30.OBJ--1-OF--1
U+c+05NWAn+iMLBhl6UU++++53FpQa7j623nQqJhMalZQW+UJaJmQqZjPW+n9X8NW-++ECZ1
crcX05NWAn+iMLBh0cU1+21dH7M0++-cW+A+E84IZV++0JN0An-TJ2JMJ+F1HoF3YtU5+2Uk
++61+SCK1++3LoF-J222F23IEQ8M-k-6+++2-E2DZUU+-YF5IYxJI6iO-++4zk7PX-A+-pN0
JIN4FJ6+-oF0JIN4FJ6+FN+J+++-1YBAFI3GF27JFYN3IXAm++++Ud+J+++-1YBAFI3GJY7J
FYN3IXAm1k++MN+H+++-13B6HpR0JIN4FJ6nAVs++B86-+-+cU4Fc1E++E++zAEy++0tU1ta
Aw1nNej9zAEy++0tU1taAw1nNej95jn2DU++lHM++9a+DjBadFz9StkF+AE1JU922ZM-l07K
+QEaJU86WU6++5E+
***** END OF BLOCK 1 *****


{ ----------------------------  ASM MODULE --------------------- }
.MODEL MEDIUM

EXTRN vbuffer:DWORD
EXTRN dbuffer:DWORD

PUBLIC ClearDBuffer32
PUBLIC ClearVBuffer32
PUBLIC ShowBuffer32

.CODE
.386

ClearDBuffer32 PROC FAR
  cld
  les di, dbuffer
  mov cx, 16000
  xor eax, eax
  rep stosd
  ret
ClearDBuffer32 ENDP

ClearVBuffer32 PROC FAR
  cld
  les di, vbuffer
  mov cx, 16000
  xor eax, eax
  rep stosd
  ret
ClearVBuffer32 ENDP

ShowBuffer32 PROC FAR
  push ds
  cld
  les di, vbuffer
  lds si, dbuffer
  mov cx, 16000
  rep movsd
  pop ds
  ret
ShowBuffer32 ENDP

END