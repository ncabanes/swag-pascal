{
> I want to know if it's possible to get the BIOS Serial number and how to
> get it in pascal.

I dunno about BIOS serial number, i know how to get a BIOS date, thats true.
Here's the source (that is also welcome to place in SWAG):
}

Function GetBiosDate : string; assembler;
Asm
  push ds
  {$IFDEF DPMI}  { look, it works with DPMI too }
  mov ax,2
  mov bx,0FFFFh
  int 31h
  {$ELSE}
  mov ax,0FFFFh
  {$ENDIF}
  mov ds,ax
  mov si,0005h
  les di,@Result
  cld
  mov ax,8
  stosb
  mov cx,ax
  rep movsb
  pop ds
End; { GetBiosDate }

Begin
  WriteLn('BIOS date: ', GetBiosDate) { Simple, eh? }
End.
