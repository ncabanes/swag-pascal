{
   Here's my solution to your "contest". The first I'm rather proud
   of, it incorporates bAsm to beat your devilshly efficient CASE
   Implementation by a factor of 2x.

   The second, I am rather disappointed With as it doesn't even come
   CLOSE to TP's inbuilt STR Function. (The reason, I have found, is
   because TP's implementaion Uses a table based approach that would
   be hard to duplicate With Variable radixes. I am working on a
   Variable radix table now)


  ****************************************************************
  Converts String pointed to by S into unsigned Integer V. No
  range or error checking is performed. Caller is responsible for
  ensuring that Radix is in proper range of 2-36, and that no
  invalid Characters exist in the String.
  ****************************************************************
}
Type
  pChar      = ^chr_Array;
  chr_Array  = Array[0..255] of Char;
  Byte_arry  = Array[Char] of Byte;

Const
  sym_tab : Byte_arry = (
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,
              0,0,0,0,0,0,0,10,11,12,13,14,15,16,17,
              18,19,20,21,22,23,24,25,26,27,28,29,30,
              31,32,33,34,35,0,0,0,0,0,0,10,11,12,13,
              14,15,16,17,18,19,20,21,22,23,24,25,26,
              27,28,29,30,31,32,33,34,35,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0
                        );

Procedure RadixVal(Var V:LongInt; S:PChar;Radix:Byte);
Var
  digit        :Byte;
  p,    p2     :Pointer;
  hiwd, lowd   :Word;
begin
  V  := 0;
  p  := @S^[0];
  p2 := @V;
  Asm
    les  bx, p2
    push ds
    pop  es
    lds  si, p
  @loop3:
    lea  di, [sym_tab]
    xor  ah, ah
    lodsb
    cmp  al, 0
    je   @quit
    add  di, ax             { index to Char position in table }
    mov  al, Byte PTR [di]
    mov  digit, al
    xor  ah, ah
    mov  al, Radix
    mov  cx, ax
    mul  Word PTR [bx]
    mov  lowd, ax
    mov  hiwd, dx
    mov  ax, cx
    mul  Word PTR [bx+2] { mutliply high Word With radix }
    add  hiwd, ax        { add result to previous result - assume hi result 0 }
    mov  ax, lowd
    mov  dx, hiwd
    add  al, digit     { add digit value }
    adc  ah, 0         { resolve any carry }
    mov  [bx], ax      { store final values }
    mov  [bx+2], dx
    jmp  @loop3
  @quit:
  end;
end;

{
  ****************************************************************
  Convert unsigned Integer in V to String pointed to by S.
  Radix determines the base to use in the conversion. No range
  checking is performed, the caller is responsible For ensuring
  the radix is in the proper range (2-36), and that V is positive.
  ****************************************************************
}
Type
  Char_arry = Array[0..35] of Char;

Const
  symbols :Char_arry = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

Procedure RadixStr(V:LongInt; S:PChar; Radix:Byte);
Var
  digit, c :Byte;
  ts       :String;
  p, p2    :Pointer;
begin
  c := 255;
  ts[255] := #0;
  p  := @V;
  p2 := @ts[0];
  Asm
    push ds
    lea  si, [symbols]
    les  bx, p
    les  di, p2
    add  di, 255
    std
    xor  cx, cx
    mov  cl, Radix
  @loop:
  SEGES mov  ax, Word PTR [bx]
  SEGES mov  dx, Word PTR [bx+2]
    div  cx
  SEGES mov  Word PTR [bx], ax
  SEGES mov  Word PTR [bx+2], 0
    mov  digit, dl
    push si
    xor  ah, ah
    mov  al, digit
    add  si, ax
    movsb
    pop  si
    dec  c
  SEGES cmp  Word PTR [bx], 0
    je   @done
  SEGES cmp  Word PTR [bx+2], 0
    je   @loop
  @done:
    pop  ds
  end;
  ts[c] := Chr(255-c);
  p  := @S^[0];
  Asm
    push ds
    cld
    lds  si, p2
    les  di, p
    xor  bx, bx
    mov  bl, c
    add  si, bx
    mov  cx, 256
    sub  cl, c
    sbb  ch, 0
    rep movsb
    pop  ds
  end;
end;
