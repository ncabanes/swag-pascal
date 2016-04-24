(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0115.PAS
  Description: Pcx Viewer!
  Author: JAMES COOK
  Date: 08-24-94  13:50
*)


Uses Crt;
{ Sample program to display a 320x200x256 PCX in
  mode 13h.  PCX source copied from MCGA07, a MCGA
  graphics unit written by James Cook in his MCGA
  programming tutorial on Quantum Leap BBS }

TYPE
  TPalette = array[0..767] of Byte;
  PalettePtr = ^TPalette;
{ PCX stuff }
  PCXHeaderPtr=  ^PCXHeader;
  PCXHeader   =  record
                   Signature      :  Char;
                   Version        :  Char;
                   Encoding       :  Char;
                   BitsPerPixel   :  Char;
                   XMin,YMin,
                   XMax,YMax      :  Integer;
                   HRes,VRes      :  Integer;
                   Palette        :  Array [0..47] of byte;
                   Reserved       :  Char;
                   Planes         :  Char;
                   BytesPerLine   :  Integer;
                   PaletteType    :  Integer;
                   Filler         :  Array [0..57] of byte;
                 end;

Procedure ExtractLineASM (BytesWide:Integer;Var Source,Dest:Pointer);
var
  DestSeg,
  DestOfs,
  SourceSeg,
  SourceOfs   :  Word;
begin
  SourceSeg := Seg (Source^);
  SourceOfs := Ofs (Source^);
  DestSeg   := Seg (Dest^);
  DestOfs   := Ofs (Dest^);

  asm
    push  ds
    push  si

    cld

    mov   ax,DestSeg
    mov   es,ax
    mov   di,DestOfs     { es:di -> destination pointer }
    mov   ax,SourceSeg
    mov   ds,ax
    mov   si,SourceOfs   { ds:si -> source buffer }

    mov   bx,di
    add   bx,BytesWide   { bx holds position to stop for this row }
    xor   cx,cx

  @@GetNextByte:
    cmp   bx,di          { are we done with the line }
    jbe   @@ExitHere

    lodsb                { al contains next byte }

    mov   ah,al
    and   ah,0C0h
    cmp   ah,0C0h

    jne    @@SingleByte
                         { must be a run of bytes }
    mov   cl,al
    and   cl,3Fh
    lodsb
    rep   stosb
    jmp   @@GetNextByte

  @@SingleByte:
    stosb
    jmp   @@GetNextByte

  @@ExitHere:
    mov   SourceSeg,ds
    mov   SourceOfs,si
    mov   DestSeg,es
    mov   DestOfs,di

    pop   si
    pop   ds
  end;

  Source := Ptr (SourceSeg,SourceOfs);
  Dest   := Ptr (DestSeg,DestOfs);
end;

Procedure DisplayPCX (X,Y:Integer;Buf:Pointer);
var
  I,NumRows,
  BytesWide   :  Integer;
  Header      :  PCXHeaderPtr;
  DestPtr     :  Pointer;
  Offset      :  Word;

begin
  Header    := Ptr (Seg(Buf^),Ofs(Buf^));
  Buf       := Ptr (Seg(Buf^),Ofs(Buf^)+128);
  Offset    := Y * 320 + X;
  NumRows   := Header^.YMax - Header^.YMin + 1;
  BytesWide := Header^.XMax - Header^.XMin + 1;
  If Odd (BytesWide) then Inc (BytesWide);

  For I := 1 to NumRows do begin
    DestPtr := Ptr ($A000,Offset);
    ExtractLineASM (BytesWide,Buf,DestPtr);
    Inc (Offset,320);
    end;
end;
{ end PCX stuff }

Procedure Graph13h; assembler;
asm
  mov al,$13
  mov ah,0
  int 10h
end;

VAR
  F: File;           { PCX file }
  Hdr: PCXHeaderPtr; { PCX header structure & file }
  Pal: PalettePtr;   { PCX palette }
  Shade, Size: Word; { RGB shade, file size }

BEGIN
  Graph13h;                          { set mode 13h }
  Assign(F, 'filename.pcx');         { open PCX file }
  Reset(F,1);
  Size := FileSize(F);
  GetMem(Hdr, Size);                 { load PCX into memory }
  Blockread(F, Hdr^, Size);
  Close(F);
  Pal := Ptr( Seg(Hdr^), Ofs(Hdr^) + Size - 768);    { get palette location }
  Port[968] := 0;                                    { set palette }
  FOR Shade := 0 TO 767 DO
    Port[969] := Pal^[Shade] SHR 2;
  DisplayPCX(0, 0, Hdr);                             { decode PCX to screen }
  WHILE Readkey <> #13 DO;                           { wait for return key }
  TextMode(CO80);
END.

