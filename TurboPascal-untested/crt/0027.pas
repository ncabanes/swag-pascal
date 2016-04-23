
{ I am wanting to enable Bright Background Colors in my Pascal programs.

Here's a little something:

{---cut here---}

uses Crt;

Procedure SetBlinkEGAVGA(BlinkOn : boolean); assembler;
{ Enables/disables bright background colors on EGA/VGA adapters }
Asm
  mov bl,BlinkOn
  mov ax,1003h { BIOS function to enable/disable blinking }
  int 10h
End; { SetBlinkEGAVGA }

Procedure SetBlinkCGAMDA(BlinkOn : boolean); assembler;
{ Enables/disables 16 background colors on EGA/VGA adapters }
Asm
  mov dx,03D8h { default=CGA }
{$IFDEF VER70} mov ax,Seg0040 {$ELSE} mov ax,0040h {$ENDIF}
  mov es,ax
  cmp byte ptr [es:0049h],07h   { mono mode? }
  jne @@1
  mov dx,03B8h { so its MDA }
@@1:
  mov ax,word ptr [es:0065h]
  or  BlinkOn,False
  jz  @@2
  or  ax,20h
  jmp @@3
@@2:
  and ax,0DFh
@@3:
  out dx,ax
End; { SetBlinkCGAMDA }

Function EGAInstalled : boolean; assembler;
Asm
  mov ax,1200h
  mov bx,0010h
  xor cx,cx
  int 10h
  xor al,al { mov al,False }
  or  cx,0
  jz  @noega
  inc al { al gets True }
@noega:
End; { EGAInstalled }

Begin
  if EGAInstalled then
    SetBlinkEGAVGA(False) else SetBlinkCGAMDA(False);
  TextAttr := LightGray;
  ClrScr;
  TextAttr := Blue + White shl 4;
  Write('Blue on bright White :)');
  ReadKey;
  GotoXY(1, 1);
  Write('Blue on lightgray blinking :(');
  if EGAInstalled then
    SetBlinkEGAVGA(True) else SetBlinkCGAMDA(True);
  TextAttr := LightGray;
  WriteLn;
End.
