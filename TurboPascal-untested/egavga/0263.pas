{
 KB> Hello.  I was wondering if someone could tell me how to read in PCX
 KB> files in Turbo Pascal using either resolution (320 X 200, 640 X 480
 KB> etc.) with 256 colours. I was using a program called clip but it does
 KB> not read PCX files that are in 256 colours.  Any help is appreciated.

I can help you with the 320x200x256 mode.

Here come a little program (mostly in asm) to display a PCX-image in that
resulution.

To load a PCX-image, use the procedure PCX_LOAD(PicName, Init), where 
PicName = Path+Filename of image to be displayed.
Init    = Should the procedure init mode 13h before displaying the pic?

Hope you can use this.
}

program PCX_LOAD;

{$G+}

Var
 Pic:Array [0..63999] Of Byte;
 Pcx:File;
 Read_Result:Integer;

Procedure Load_Pcx(Name:String; Init:Boolean);
begin
  If Init Then
   Asm
     Mov  AX, 13h
     Int  10h
   End;
   Asm
     Mov  AL, 0
     Mov  DX, 03C8h
     Out  DX, AL
     Inc  DX
     Mov  CX, 1023
@l1: Out  DX, AL
     Loop @l1
  End;
  Assign(PCX, name);
  Reset(PCX, 1);
  BlockRead(PCX, Pic, SizeOf(Pic), Read_Result);
  Close(PCX);
  Asm
     Cld
     Mov  AX, 0A000h
     Mov  ES, AX
     Lea  BX, Pic
     Add  BX, 128
     Xor  DI, DI
     Xor  DX, DX
     Xor  AX, AX
     Xor  CX, CX
@l2: Mov  AL, [BX]
     Inc  BX
     Cmp  AL, 0C0h
     Ja   @r1
     Stosb
     Inc  DX
     Jmp  @r3
@r1: Sub  AL, 0C0h
     Mov  CL, AL
     Add  DX, AX
     Mov  AL, [BX]
     Inc  BX
 Rep Stosb
@r3: Cmp  DX, 64000
     Jnz  @l2
     Inc  BX
     Mov  DX, 03C8h
     Mov  AL, 00h
     Out  DX, AL
     Inc  DX
     Mov  CX, 255
@r4: Mov  AL, [BX]
     Shr  AL, 2
     Out  DX, AL
     Mov  AL, [BX+1]
     Shr  AL, 2
     Out  DX, AL
     Mov  AL, [BX+2]
     Shr  AL, 2
     Out  DX, AL
     Add  BX, 3
     Loop @r4
  End;
End;

begin
  load_pcx('D:\artpack\esilogo.PCX', True);
  Asm
   Mov AH, 000h
   Int 16h
   Mov AX, 003h
   Int 10h
  End;
end.

Oh, btw. this program can't handle a picture larger than 64000 bytes, but i
hope you can find a way around that. If not, write a mail to me, and i will
see what i can do...

TTYL
   Allan Bang Andersen
