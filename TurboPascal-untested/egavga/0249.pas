Unit PCX;

INTERFACE

TYPE
  TPalette = array[0..767] of Byte;
  PalettePtr = ^TPalette;

VAR
  Pal: PalettePtr;   { PCX palette }

PROCEDURE Show_PCX(Filename: String);

IMPLEMENTATION

TYPE
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

VAR
  Hdr: PCXHeaderPtr; { PCX header structure & file }
  F: File;           { PCX file }
  Shade, Size: Word; { RGB shade, file size }

PROCEDURE Show_PCX(Filename: String);
Begin
  Assign(F, filename);         { open PCX file }
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
  FreeMem(Hdr, Size);
End;

BEGIN
END.