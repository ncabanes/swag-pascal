{
>I am making a computer game using pascal and a 640x480x16 resolution,
>using Jordan Hargrafix's SVGABG16.BGI driver, and I want to use the
>setactivepage/setvisualpage commands to "hide" the screen as it is being
>redrawn, and then show it again to give the effect of super fast screen
>refresh (i.e. so fast, you can't see it)

I don't havce time to find out what you mean exactly.
This unit redraws sprites, and doesn't display them until
ShowVirtualScreen is activated.
}
unit Sprites;
{ Basically a simple and effective spriteengine for use with Turbo }
{ Pascal 6.0. (Does not require the GRAPH unit..)                  }
{                                                                  }
{ Designed for use with MCGA, VGA and compatibles. Works in mode   }
{ mode $13 (320x200 with 256 simultaneously colours.               }
{                                                                  }
{ Written by:                                                      }
{            Marius Kjeldahl                                       }
{            Stud. post 104                                        }
{            N-7034 Trondheim - NTH                                }
{            Norway                                                }
{            Ph. +47 7 58 91 11                                    }
{            e-mail: mariusk@lise.unit.no                          }
{                    (at NTH - Norwegian Institute of Technology ) }
{                    (dept. of Business and Information Technolgy) }
{                                                                  }
{ These routines are being distributed as shareware. To be used in,}
{ or as part of any commercial product, you have to become a       }
{ registered user. As a registered user you will receive upgrades  }
{ and rights to distribute these routines with your products.      }
{ To become a registered user, you will have to send a letter with }
{ who you are and what product(s) will use these routines and      }
{ make US$39 payable to the author (cheque or money..).            }
{                                                                  }
{                                                                  }
{ If you have any suggestions or comments please do not hesitate   }
{ to contact me. Have fun...                                       }
{                                                                  }
{ Future plans for enhancements: interrupt driven, faster rep      }
{ movsw for sprites, built in animation, screen region scrolling   }
{ and more..                                                       }

interface
uses
  Dos;
const
  MaxSprites = 14; { Maximum number of sprites activated simultaneously }
  MaxDim = 80*10;  { Dimensions of largest sprite to be used (x*y)      }
type
  ScreenTypePointer = ^ScreenType;       { Pointer to a virtual screen  }
  ScreenType = array [1..64000] of byte; { Array to hold virtual screen }
  SpriteType = record                    { Misc. sprite data            }
                 oldx, oldy,             { - old location               }
                 x, y : integer;         { - current location           }
                 w, h : byte;            { - width and height           }
                 SpriteData,             { - spriteimage                }
                 Buffer : array [0..MaxDim-1] of byte; { spritebackgr.  }
                 Active : boolean;       { - currently active           }
                 ix, iy : integer;       { - sprite increment           }
                                         {   (not currently used)       }
               end;
var
  Sprite : array [1..MaxSprites] of SpriteType; { Array of sprites      }
  Virtual_Screen : ScreenTypePointer;    { Pointer to virtual screen    }

  procedure DrawSprites;
  { Saves background and draws all currently active sprites at their    }
  { current location.                                                   }

  procedure LoadSprite (Num : byte; FileName : string);
  { Loads spritedata from ordinary text file. Examine the .SPR files    }
  { for further details. Use .CEL files instead if you've have          }
  { purchased AutoDesk Animator...                                      }

  procedure SetMode (Mode : word);
  { Sets screen mode. Use $13 for use with sprites                      }

  procedure ShowVirtualScreen ;
  { Copies the VirtualScreen to the users screen. Any changes done with }
  { the sprites and/or their position will NOT be visible until this    }
  { routine has been called!                                            }

  procedure LoadCOL (FileName : string);
  { Loads a file containing the palette desc. of the 256 colours and    }
  { programs the VGA/MCGA to use these palette. It uses AutoDesk        }
  { Animators file format - so you can use Animator to select colors and}
  { then save the palette in Animators ordinary .COL file.              }
  { For those without Animator (you should not be..) the file format is }
  { simple. Each colour (from 0 to 255) has three bytes which containts }
  { red, green and blue values. First in the file comes (usually)       }
  { 0,0,0 - black and so on until the last colour.                      }

  procedure LoadCEL (FileName :  string; ScrPtr : pointer);
  { Directly loads a CEL to the location pointed to by ScrPtr.          }
  { This routine uses AutoDesk Animators file format. This means you    }
  { can use Animators excellent drawing tools to design you sprites and }
  { save them in a ordinary .CEL file.                                  }
  { For those without Animator; here is a short desc. of the format:    }
  { The first 800 bytes is Animators header. It does include various    }
  { information like it's own colours palette, width and height.        }
  { However this version skips all that information and just reads the  }
  { image data into the location pointed to by ScrPtr. Remember to      }
  { set the sprites width and height too! (It is NOT read you of the    }
  { .CEL file in this release..                                         }

  procedure DisableAllSprites;
  { Disables all sprites. But this routine does not restore the screen  }
  { image (compare with HideSprites..                                   }

  procedure HideSprites;
  { Disables all sprites. Basically same as DisableAllSprites, but this }
  { routine also recovers the "original" screen image.                  }

  procedure FillBox (x1, y1, x2, y2 : integer; b : byte);
  { Draws a coloured box with upper left corner x1,y1 and lower right   }
  { corner x2,y2.                                                       }

  procedure CopySprite (var Sprite : SpriteType; x1, y1 : integer);
  { "Stamps" a copy of any sprite at the chosen location x1,y1.         }
  { Use this routine if you want to put the image there, but do not plan}
  { to animate in anyway..                                              }

  procedure WaitForVerticalRetrace;
  { Waits for vertical retrace. Will be used in further releases..      }

implementation

procedure CopySprite (var Sprite : SpriteType; x1, y1 : integer); assembler;
label
  _Redraw, _DrawLoop, _Exit, _LineLoop, _NextLine, _Store, _NoPaint;
  asm
    push  ds
    push  es
    lds   si,Sprite
    mov   ax,x1     { ax = x }
    mov   bx,y1     { bx = y }
_Redraw:
    push  ax
    push  bx
    mov   ax,word(Virtual_Screen+2)
    mov   es,ax         { ES=A000h }
    pop   bx            { ax = y }
    mov   ax,320
    mul   bx            { ax = y * 320 }
    pop   bx            { ax = x }
    add   ax,bx         { bx = bx + ax dvs. skjermadr.. }
    mov   di,ax         { di = skjermadr. }
    mov   dl,[si+9]     { dl = height of sprite }
    xor   ch,ch
    mov   cl,[si+8]     { cx = width of sprite }
    add   si,10         { si = start of spritedata }
    cld
_DrawLoop:
    push  di            { store y adr. for later }
    push  cx            { store width }
_LineLoop:
    mov   bl,byte ptr [si]
    or    bl,bl
    jnz   _Store
_NoPaint:
    inc    si
    inc    di
    loop   _LineLoop
    jmp    _NextLine
_Store:
{    test   byte ptr [es:di],1
    jz     _NoPaint}
    movsb
    loop  _LineLoop
_NextLine:
    pop   cx
    pop   di
    dec   dl
    jz    _Exit
    add   di,320        { di = next line of sprite }
    jmp   _DrawLoop
_Exit:
    pop   es
    pop   ds
  end;

procedure DrawSprite (var Sprite : SpriteType); assembler;
label
  _Redraw, _DrawLoop, _Exit, _LineLoop, _NextLine, _Store, _NoPaint;
  asm
    push  ds
    push  es
    lds   si,Sprite
    mov   ax,[si+4]     { ax = x }
    mov   bx,[si+6]     { bx = y }
    cmp   ax,[si]        {if x <> oldx then _Redraw}
    jne   _Redraw       {
    cmp   bx,[si+2]
   je    _Exit         { if (x=oldx) and (y=oldy) then exit }
_Redraw:
    mov   [si],ax       { oldx = x }
    mov   [si+2],bx     { oldy = y }
    push  ax
    push  bx
    mov   ax,word(Virtual_Screen+2)
    mov   es,ax         { ES=A000h }
    pop   bx            { ax = y }
    mov   ax,320
    mul   bx            { ax = y * 320 }
    pop   bx            { ax = x }
    add   ax,bx         { bx = bx + ax dvs. skjermadr.. }
    mov   di,ax         { di = skjermadr. }
    mov   dl,[si+9]     { dl = height of sprite }
    xor   ch,ch
    mov   cl,[si+8]     { cx = width of sprite }
    add   si,10         { si = start of spritedata }
    cld
_DrawLoop:
    push  di            { store y adr. for later }
    push  cx            { store width }
_LineLoop:
    mov   bl,byte ptr [si]
    or    bl,bl
    jnz   _Store
_NoPaint:
    inc    si
    inc    di
    loop   _LineLoop
    jmp    _NextLine
_Store:
{    test   byte ptr [es:di],1
    jz     _NoPaint}
    movsb
    loop  _LineLoop
_NextLine:
    pop   cx
    pop   di
    dec   dl
    jz    _Exit
    add   di,320        { di = next line of sprite }
    jmp   _DrawLoop
_Exit:
    pop   es
    pop   ds
  end;

procedure SaveSpriteBackground (var Sprite : Spritetype); assembler;
label
  _Redraw, _DrawLoop, _Exit;
  asm
    push  ds
    push  es
    les   di,Sprite
    mov   ax,es:[di+4]     { ax = x }
    mov   bx,es:[di+6]     { bx = y }
    push  ax
    push  bx
    mov   ax,word(Virtual_Screen+2)
    mov   ds,ax         { DS=A000h }
    pop   bx            { bx = y }
    mov   ax,320
    mul   bx            { ax = y * 320 }
    pop   bx            { bx = x }
    add   ax,bx         { ax = ax + bx dvs. skjermadr.. }
    mov   si,ax         { si = skjermadr. }
    mov   dl,es:[di+9]     { dl = height of sprite }
    xor   ch,ch
    mov   cl,es:[di+8]     { cx = width of sprite }
    add   di,10+MaxDim  { di = start of screenbuffer }
    cld
_DrawLoop:
    push  si            { store y adr. for later }
    push  cx            { store width }
    rep   movsb
    pop   cx
    pop   si
    dec   dl
    jz    _Exit
    add   si,320        { di = next line of sprite }
    jmp   _DrawLoop
_Exit:
    pop   es
    pop   ds
  end;

procedure FillBox (x1, y1, x2, y2 : integer; b : byte); assembler;
label
  _l1;
asm
  push  ds
  push  es
  mov   ax,word(Virtual_Screen+2)
  mov   es,ax
  mov   ax,y1
  mov   bx,320
  mul   bx
  mov   di,ax
  add   di,x1
  mov   ax,y1
  mov   dx,y2
  sub   dx,ax
  inc   dx

  mov   ax,x1
  mov   cx,x2
  sub   cx,ax { cx contains number of bytes across }
  inc   cx
  mov   al,b
  cld
_l1:
  push  di
  push  cx
  rep   stosb
  pop   cx
  pop   di
  add   di,320
  dec   dx
  jnz   _l1
  pop   es
  pop   ds
end;


procedure RestoreSpriteBackground (var Sprite : Spritetype); assembler;
label
  _Redraw, _DrawLoop, _Exit, _LineLoop;
  asm
    push  ds
    push  es
    lds   si,Sprite
    mov   ax,[si]     { ax = x }
    mov   bx,[si+2]     { bx = y }
    push  ax
    push  bx
    mov   ax,word(Virtual_Screen+2)
    mov   es,ax         { ES=A000h }
    pop   bx            { ax = y }
    mov   ax,320
    mul   bx            { ax = y * 320 }
    pop   bx            { ax = x }
    add   ax,bx         { bx = bx + ax dvs. skjermadr.. }
    mov   di,ax         { di = skjermadr. }
    mov   dl,[si+9]     { dl = height of sprite }
    xor   ch,ch
    mov   cl,[si+8]     { cx = width of sprite }
    add   si,10+MaxDim         { si = start of spritedata }
    cld
_DrawLoop:
    push  di            { store y adr. for later }
    push  cx            { store width }
    rep   movsb
    pop   cx
    pop   di
    dec   dl
    jz    _Exit
    add   di,320        { di = next line of sprite }
    jmp   _DrawLoop
_Exit:
    pop   es
    pop   ds
  end;

procedure DrawSprites;
var
  I : byte;
begin
  for I := MaxSprites downto 1 do
    if (Sprite[I].Active) and (Sprite [I].oldx <> -1) then
      RestoreSpriteBackground (Sprite [I]);
  for I := 1 to MaxSprites do begin
    if Sprite [I].Active then begin
      SaveSpriteBackground (Sprite [I]);
      DrawSprite (Sprite [I]);
    end;
  end;
end;

procedure HideSprites;
var
  I : byte;
begin
  for I := MaxSprites downto 1 do
    if (Sprite [I].oldx <> -1) then begin
      RestoreSpriteBackground (Sprite [I]);
      Sprite [I].oldx := -1;
    end;
end;

procedure SetMode (Mode : word);
begin
  asm
    mov ax,Mode;
    int 10h
  end;
end;

procedure LoadSprite (Num : byte; FileName : string);
var
  Fil : text;
  fx, fy : word;
begin
  assign (Fil, FileName);
  reset (Fil);
  fillchar (Sprite [Num], sizeof (Sprite[1]), 0);
  with Sprite [Num] do begin
    oldx := integer ($FFFF);
    readln (Fil, w, h);          {integer-32768}
    for fy := 1 to h do begin
      for fx := 1 to w do
        read (Fil, SpriteData [pred (fy) * w + pred (fx)]);
      readln (fil);
    end;
  end;
  close (Fil);
end;

procedure LoadCOL (FileName : string);
type
  DACType = array [0..255] of record
                                R, G, B : byte;
                              end;
var
  DAC : DACType;
  Fil : file of DACType;
  I : integer;
  Regs : Registers;
begin
  assign (Fil, FileName);
  reset (Fil);
  read (Fil, DAC);
  close (Fil);
  for I := 0 to 255 do begin
    with Regs do begin
      AX := $1010;
      BX := I;
      DH := DAC [I].R;
      CH := DAC [I].G;
      CL := DAC [I].B;
    end;
    Intr ($10, Regs);
  end;
end;

procedure WaitForVerticalRetrace; assembler;
label
  l1, l2;
asm
    cli
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
    sti
end;

procedure ShowVirtualScreen; assembler;
    asm
      push ds
      push es
      xor  si,si
      xor  di,di
      cld
      mov  ax,word(Virtual_Screen + 2)
      mov  ds,ax
      mov  ax,0A000h
      mov  es,ax
      mov  cx,7D00h
      rep  movsw
      pop  es
      pop  ds
    end;

procedure LoadCEL (FileName :  string; ScrPtr : pointer);
var
  Fil : file;
  Buf : array [1..1024] of byte;
  BlocksRead, Count : word;
begin
  assign (Fil, FileName);
  reset (Fil, 1);
  BlockRead (Fil, Buf, 800);
  Count := 0; BlocksRead := $FFFF;
  while (not eof (Fil)) and (BlocksRead <> 0) do begin
    BlockRead (Fil, mem [seg (ScrPtr^): ofs (ScrPtr^) + Count], 1024,
BlocksRead);
    Count := Count + 1024;
  end;
  close (Fil);
end;

procedure DisableAllSprites;
var
  I : integer;
begin
  for I := 1 to MaxSprites do
    with Sprite [I] do begin
      OldX := -1;
      Active := FALSE;
    end;
end;

var
  Dum : ^byte;
begin
  DisableAllSprites;
  repeat
    new (Virtual_Screen);
    if ofs (Virtual_Screen^) <> 0 then begin
      dispose (Virtual_Screen);
      new (Dum);
    end;
  until ofs (Virtual_Screen^) = 0;
end.
