(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0049.PAS
  Description: GIF Code
  Author: THORSTEN BARTH
  Date: 01-27-94  12:07
*)

{
> Does anyone have ANY source, on how to display a gif in VGA mode

It's as bad as ... but it works.

--- VGA gif loader part 1 of 3 ---
}

{$X+}

Uses Graph,Dos;

Var
  Gd,Gm: Integer;
  Datei: File;
  palette: array[0..767] of byte;
  buffer: array[0..1279] of byte;
  prefix,tail: array[0..4095] OF WORD;
  keller: array[0..640] of Word;

Function LoadGif(N: String; VersX,VersY: Word): Integer;

Function GetChar: Char;
Var C: Char;
Begin
  BlockRead(Datei,C,1);
  GetChar:=C;
End;

Function GetByte: Byte;
Var B: Byte;
Begin
  BlockRead(Datei,B,1);
  GetByte:=B;
End;

Function GetWord: Word;
Var W: Word;
Begin
  BlockRead(Datei,W,2);
  Getword:=W;
End;

Procedure AGetBytes(Anz: Word);
Begin
  BlockRead(Datei,Buffer,Anz);
End;

Var
  lokal_farbtafel: Integer;
  mask,restbytes,pp,lbyte,blocklen,code,oldcode,sonderfall,
  incode,freepos,kanz,pass,clearcode,eofcode,maxcode,infobyte,
  globalfarbtafel,backcolor,interlace,bilddef,abslinks,absoben: word;
  bits,restbits,codesize: Byte;
  rot,gruen,blau,by,bpp: Byte;
  z,i,x1,y1,x2,y2: integer;
  bem: string[6];
  farben: integer;
  x,y,xa,ya,dy: word;
begin
  loadgif:=0;
  Assign(Datei,N);
  reset(Datei,1);
  if ioresult>0 then begin loadgif:=1; exit; end;
  bem:='';
  for i:=1 to 6 do bem:=bem+getchar;
  if copy(bem,1,3)<>'GIF' then begin loadgif:=2; exit; end;
  x2:=getword;
  y2:=getword;
  infobyte:=getbyte;
  globalfarbtafel:=infobyte and 128;
  bpp:=(infobyte and 7)+1;
  farben:=1 shl bpp;
  backcolor:=getbyte;
  by:=getbyte;
  if globalfarbtafel<>0 then
    for i:=0 to (3*farben)-1 do
      palette[i]:=getbyte shr 2;
  bilddef:=getbyte;
  while bilddef=$21 do begin
    by:=getbyte; z:=getbyte;
    for i:=1 to z do by:=getbyte;
    by:=getbyte;
    bilddef:=getbyte;
  end;


  if bilddef<>$2c then begin loadgif:=3; exit; end;
  abslinks:=getword+VersX;
  absoben:=getword+VersY;
  x2:=getword;
  y2:=getword;
  by:=getbyte;
  lokal_farbtafel:=by and 128;
  interlace:=by and 64;
  by:=getbyte;
  x1:=0; y1:=0; xa:=x2; Ya:=Y2;
  if farben<16 then begin loadgif:=4; exit; end;
  if lokal_farbtafel<>0 then
    for i:=0 to 3*Farben-1 do
      palette[I]:=getbyte shr 2;
  asm
    mov ax,$1012
    push ds
    pop es
    xor bx,bx
    mov cx,256
    lea dx,palette
    int $10
    mov pass,0
    MOV CL,bpp
    MOV AX,1
    SHL AX,CL
    MOV clearcode,AX
    INC AX
    MOV eofcode,AX
    INC AX
    MOV freepos,AX
    MOV AL,bpp
    MOV AH,0
    INC AX
    MOV codesize,AL
    MOV CX,AX
    MOV AX,1
    SHL AX,CL
    DEC AX
    MOV maxcode,AX
    MOV kanz,0
    MOV dy,8
    MOV restbits,0
    MOV restbytes,0
    MOV x,0
    MOV y,0
@gif0: CALL FAR PTR @getgifbyte
    CMP AX,eofcode
    je @ende1
@gif1: CMP AX,clearcode
    je @reset1
@gif3: MOV AX,code
    MOV incode,AX
    CMP ax,freepos
    jb @gif4
    MOV AX,oldcode
    MOV code,AX
    MOV BX,kanz
    MOV CX,sonderfall
    SHL BX,1
    MOV [OFFSET keller+BX],CX
    INC kanz
@gif4: CMP AX,clearcode
    JB @gif6
@gif5: MOV BX,code
    SHL BX,1
    PUSH BX
    MOV AX,[Offset tail+BX]
    MOV BX,kanz
    SHL BX,1
    MOV [OFFSET keller+BX],AX
    INC kanz
    POP BX
    MOV AX,[Offset prefix+BX]
    MOV code,AX
    CMP AX,clearcode
    ja @gif5
@gif6: MOV BX,kanz
    SHL BX,1
    MOV [Offset keller+BX],AX
    MOV sonderfall,AX
    INC kanz
@gif7: MOV AX,[Offset keller+BX]
    CALL FAR PTR @pixel
    CMP BX,0
    JE @gif8
    DEC BX
    DEC BX
    JMP @gif7

@gif8: MOV kanz,0
    MOV BX,freepos
    SHL BX,1
    MOV AX,oldcode
    MOV [Offset prefix+BX],AX
    MOV AX,code
    MOV [Offset tail+BX],AX
    MOV AX,incode
    MOV oldcode,AX
    INC freepos
    MOV AX,freepos
    CMP AX,maxcode
    JBE @gif2
    CMP codesize,12
    JAE @gif2
    INC codesize
    MOV CL,codesize
    MOV AX,1
    SHL AX,CL
    DEC AX
    MOV maxcode,AX
@gif2: JMP @gif0
@ende1: JMP @ende
@reset1: MOV AL,bpp
    MOV AH,0
    INC AX
    MOV codesize,AL
    MOV CX,AX
    MOV AX,1
    SHL AX,CL
    DEC AX
    MOV maxcode,AX
    MOV AX,clearcode
    ADD AX,2
    MOV freepos,AX
    CALL FAR PTR @getgifbyte
    MOV sonderfall,AX
    MOV oldcode,AX
    CALL FAR PTR @pixel
    JMP @gif2
@getgifbyte: MOV DI,0
    MOV mask,1
    MOV bits,0
@g1: MOV AL,bits
    CMP AL,codesize
    JAE @g0
    CMP restbits,0
    JA @g2
    CMP restbytes,0
    JNE @l2
    PUSH DI
    CALL Getbyte
    POP DI
    MOV blocklen,AX
    MOV restbytes,AX
    PUSH DI
    PUSH AX
    CALL AGetbytes
    POP DI
    MOV pp,0
@l2: MOV BX,pp
    MOV AL,[BX+Offset Buffer]
    XOR AH,AH
    INC pp
    DEC restbytes
    MOV lbyte,AX
    MOV restbits,8
@g2: SHR lbyte,1
    JNC @nocarry
    OR DI,mask
@nocarry: INC bits
    DEC restbits
    SHL mask,1
    JMP @g1
@g0:MOV bits,0
    MOV code,DI
    MOV AX,DI
    RETF
@pixel:
    PUSH BX
    MOV BX,x
    ADD BX,abslinks
    PUSH BX
    MOV BX,y
    ADD BX,absoben
    PUSH BX
    PUSH AX
    CALL Putpixel
    POP BX
    INC x
    MOV AX,x
    CMP AX,x2
    JB @s0
    MOV x,0
    CMP interlace,0
    JNE @s1
    INC y
    JMP @s0
@s1: MOV AX,dy
    ADD y,AX
    MOV AX,y
    CMP AX,y2
    JB @s0
    INC pass
    CMP pass,1
    JNE @s3
    JMP @s2
@s3: SHR dy,1
@s2: MOV AX,DY
    SHR AX,1
    MOV Y,AX
@s0: RETF
@ende:
  End;
  Close(Datei);
End;


begin

end.
