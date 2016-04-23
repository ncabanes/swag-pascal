(*
  Written by Yuval Melamed <melamed@star.net.il>, 25-Oct-1997.

  This is a very fast implementation of digit plotting on mode 13h.
  Infact, I could have made the array to include not only digits, but
  the whole ASCII table. The reason I didn't do that, is none but lack
  of time. I just showed you the basics, now go on and develope !

  One of the great things in this implementation, is the ability to use
  different colors, unlike standard bitmaps used in most games and stuff.

  As I always like to do, I have optimized this to work with 386+
  proccessors. I cannot believe someone still has his XT, right? :)
*)

var
  X, Y : Word;
  Color,
  Time : Byte;
  Count : Longint;

const
  (* The bitmap of the digits, $FF represent pixel: *)
  DigitMap : array[0..9, 1..5] of Longint =
    (($FFFFFF00, $FF00FF00, $FF00FF00, $FF00FF00, $FFFFFF00),  {0}
     ($FF000000, $FF000000, $FF000000, $FF000000, $FF000000),  {1}
     ($FFFFFF00, $FF000000, $FFFFFF00, $0000FF00, $FFFFFF00),  {2}
     ($FFFFFF00, $FF000000, $FFFFFF00, $FF000000, $FFFFFF00),  {3}
     ($FF00FF00, $FF00FF00, $FFFFFF00, $FF000000, $FF000000),  {4}
     ($FFFFFF00, $0000FF00, $FFFFFF00, $FF000000, $FFFFFF00),  {5}
     ($FFFFFF00, $0000FF00, $FFFFFF00, $FF00FF00, $FFFFFF00),  {6}
     ($FFFFFF00, $FF000000, $FF000000, $FF000000, $FF000000),  {7}
     ($FFFFFF00, $FF00FF00, $FFFFFF00, $FF00FF00, $FFFFFF00),  {8}
     ($FFFFFF00, $FF00FF00, $FFFFFF00, $FF000000, $FFFFFF00)); {9}

(* 386-optimized procedure to draw a digit on global X,Y, using the
   global Color. The only parameter to this procedure is the digit
   itself, in order to avoid confusions.                            *)
procedure PutDigit(Digit : Byte); assembler;
asm
  mov ax,0A000h {the video segment}
  mov es,ax

  mov ax,Y  {get Y}
  mov di,ax {copy Y}
  shl ax,6  {Y * 64}
  shl di,8  {Y * 256}
  add di,ax {Y * 64 + Y * 256 = Y * 320}
  add di,X  {Y * 320 + X = offset of (X,Y) in video segment}

  lea bx,DigitMap {get offset of digit's bitmap}
  mov al,20       {20 = SizeOf(Longint) * 5 = bytes in digit}
  mul Digit       {calculate offset of the digit's pixels}
  add bx,ax       {add offset to BX}

  mov cl,Color
  mov ch,cl
  db 66h; shl cx,16
  mov cl,Color
  mov ch,cl         {all bytes of ECX now contain the color value}

  db 66h; mov ax,cx          (* mov eax,ecx                              *)
  db 66h; and ax,[bx]        (* and eax,[bx]         {mask digit's line} *)
  dw 6626h; mov [di],ax      (* mov es:[di],eax      {draw digit's line} *)
  db 66h; mov ax,cx          (* mov eax,ecx                              *)
  db 66h; and ax,[bx+4]      (* and eax,[bx+4]                           *)
  dw 6626h; mov [di+320],ax  (* mov es:[di+320],eax  {draw 2nd line}     *)
  db 66h; mov ax,cx          (* mov eax,ecx                              *)
  db 66h; and ax,[bx+8]      (* and eax,[bx+8]                           *)
  dw 6626h; mov [di+640],ax  (* mov es:[di+640],eax  {draw 3rd line}     *)
  db 66h; mov ax,cx          (* mov eax,ecx                              *)
  db 66h; and ax,[bx+12]     (* and eax,[bx+12]                          *)
  dw 6626h; mov [di+960],ax  (* mov es:[di+960],eax  {draw 4th line}     *)
  db 66h; mov ax,cx          (* mov eax,ecx                              *)
  db 66h; and ax,[bx+16]     (* and eax,[bx+16]                          *)
  dw 6626h; mov [di+1280],ax (* mov es:[di+1280],eax {draw 5th line}     *)
end;

begin
  MemW[$0040:$001A] := MemW[$0040:$001C];
  asm
    mov ax,13h
    int 10h
  end;
  Randomize;
  X := 0;
  Y := 0;
  Color := 0;
  Count := 0;
  Time := Mem[$0040:$006C];
  while Mem[$0040:$006C] = Time do;
  Time := Mem[$0040:$006C];
  while Mem[$0040:$006C] = Time do begin
    PutDigit(Random(10));
    Inc(Count);
  end;
  Count := Trunc(Count * 18.217);
  Color := 15;
  X := (Trunc(Ln(Count) / Ln(10)) + 1) * 4;
  repeat
    PutDigit(Count mod 10);
    Count := Count div 10;
    Dec(X, 4);
  until Count = 0;
  Writeln;
  Writeln(' Random digits per second');
  Writeln(' (inside loop)');
  while MemW[$0040:$001A] = MemW[$0040:$001C] do;
  asm
    mov ax,3h
    int 10h
  end;
end.