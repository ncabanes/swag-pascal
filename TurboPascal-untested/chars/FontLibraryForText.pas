(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0008.PAS
  Description: Font Library for Text
  Author: SWAG SUPPORT TEAM
  Date: 11-26-93  18:05
*)

{
User font library for text mode.
}


{$IFDEF DPMI}
{$X+,S-}
{$ELSE}
{$X+,F+,O+}
{$ENDIF}
unit BBFont;

interface

const
  FontHeight = 16;   { 14 for EGA mode }

type
  PCharShape = ^TCharShape;
  TCharShape = array[0..FontHeight-1] of byte;

var
  points : word;


procedure ReplaceChar(c : char; NewChar : PCharShape);


implementation


{*******************************************************************}
{ Wen 03-mrt-1993 - wvl                                             }
{                                                                   }
{ Get font block index of current (resident) and alternate          }
{ character set. Up to two fonts can be active at the same time     }
{                                                                   }
{*******************************************************************}

Type
  FontBlock    = 0..7;


Procedure GetFontBlock(Var primary, secondary : FontBlock); Assembler;

ASM
  { Get character map select register:
    (VGA sequencer port 3C4h/3C5h index 3)

    7  6  5  4  3  2  1  0
          3  3  3  3  3  3
          3  3  3  3  @DDADD   Primary font   (lower 2 bits)
          3  3  @DDADDDDDDDD   Secondary font (lower 2 bits)
          3  @DDDDDDDDDDDDDD   Primary font   (high bit)
          @DDDDDDDDDDDDDDDDD   Secondary font (high bit)     }

        MOV     AL, 3
        MOV     DX, 3C4h
        OUT     DX, AL
        INC     DX
        IN      AL, DX
        MOV     BL, AL
        PUSH    AX

  { Get secondary font number: add up bits 5, 3 and 2 }

        SHR     AL, 1
        SHR     AL, 1
        AND     AL, 3
        TEST    BL, 00100000b
        JZ      @1
        ADD     AL, 4
@1:     LES     DI, secondary
        STOSB

  { Get primary font number: add up bits 4, 1 and 0 }

        POP     AX
        AND     AL, 3
        TEST    BL, 00010000b
        JZ      @2
        ADD     AL, 4
@2:     LES     DI, primary
        STOSB
end;  { GetFontBlock }



function postinc(var w : word) : word;  assembler;
asm
  les  di,w
  mov  ax,word ptr es:[di]
  inc  word ptr es:[di]
end;
{* pascal code
begin
  postinc := w;
  inc(w);
end;
*}


procedure ReplaceChar(c : char; NewChar : PCharShape);
var
  i : integer;
  off : word;
  CharPos : word;
  primfont, secfont : FontBlock;
  base : word;
begin

{* program the VGA controller *}
  asm
    pushf               { Disable interrupts }
    cli
    mov  dx, 03c4h      { Sequencer port address }
    mov  ax, 0704h      { Sequential addressing }
    out  dx, ax
    mov  dx, 03ceh      { Graphics Controller port address }
    mov  ax, 0204h      { Select map 2 for CPU reads }
    out  dx, ax
    mov  ax, 0005h      { Disable odd-even addressing }
    out  dx, ax
    mov  ax, 0406h      { Map starts at A000:0000 (64K mode) }
    out  dx, ax
    mov  dx, 03c4h      { Sequencer port address }
    mov  ax, 0402h      { CPU writes only to map 2 }
    out  dx, ax
  end;

{ first get the current font *}
  GetFontBlock(primfont, secfont);
  base := 8192*primfont;

  off := 16 - points;

  CharPos := Ord(c) * 32;

  for i := 0 to points-1 do  begin
    mem[SegA000:base+postinc(CharPos)] := NewChar^[postinc(off)];
  end;

{ Ok, put the Sequencer and Graphics Controller back to normal }

  asm

  { Program the Sequencer }
    pushf               { Disable interrupts }
    cli
    mov dx, 3c4h        { Sequencer port address }
    mov ax, 0302h       { CPU writes to maps 0 and 1 }
    out dx, ax
    mov ax, 0304h       { Odd-even addressing }
    out dx, ax

  { Program the Graphics Controller }
    mov dx, 3ceh        { Graphics Controller port address }
    mov ax, 0004h       { Select map 0 for CPU reads }
    out dx, ax
    mov ax, 1005h       { Enable odd-even addressing }
    out dx, ax;
    mov ax,Seg0040
    mov es,ax
    mov ax, 0e06h       { Map starts at B800:0000 }
    mov bl, 7
    cmp es:[49h], bl    { Get current video mode }
    jne @@notmono
    mov ax, 0806h       { Map starts at B000:0000 }
@@notmono:
    out dx, ax;
    popf;
  end;
end;


begin
  if (Mem[Seg0040:$0084] = 0)
   then  points := 8
   else  begin
     if Mem[Seg0040:$0084] in [42,49]
      then  points := 13
      else  points := Mem[Seg0040:$0085];
   end;
end.  { of unit BBFont }



program Test;

uses BBFont,...;

procedure TestFont;
const
  NewA:TCharShape = (
    $FF,  {11111111}
    $00,  {00000000}
    $FF,  {11111111}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00,  {00000000}
    $00   {00000000}
  );
begin
  ReplaceChar('A', @NewA);
end;


begin
  TestFont;
end.



