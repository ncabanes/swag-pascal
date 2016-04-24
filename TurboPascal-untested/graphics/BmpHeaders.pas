(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0193.PAS
  Description: BMP headers
  Author: HERMAN DULLINK
  Date: 11-22-95  13:22
*)


{Still wan't that BMP header info? Well, here's a small BMP shower that
uses VESA modes (up to 1280x1024, 256 colours). It can only show 4-bit and
8-bit BMP's, and it's written using Turbo Pascal 6.0. }

program bmp;

{ Variables }

var bitmap : record
     bfType          : word;
     bfSize          : longint;
     bfReserved1     : word;
     bfReserved2     : word;
     bfOffBits       : longint;
     biSize          : longint;
     biWidth         : longint;
     biHeight        : longint;
     biPlanes        : word;
     biBitCount      : word;
     biCompression   : longint;
     biSizeImage     : longint;
     biXPelsPerMeter : longint;
     biYPelsPerMeter : longint;
     biClrUsed       : longint;
     biClrImportant  : longint
    end;

    palette : array[0..255] of record B, G, R, alpha : byte end;

    VbeInfoBlock : record
     VbeSignature      : longint;
     VbeVersion        : word;
     OemStringPtr      : pointer;
     Capabilities      : longint;
     VideoModePtr      : pointer;
     TotalMemory       : word;
    { Added for VBE 2.0 }
     OemSoftwareRev    : word;
     OemVendorNamePtr  : pointer;
     OemProductNamePtr : pointer;
     OemProductRevPtr  : pointer;
     Reserved          : array[0..221] of byte;
     OemData           : array[0..255] of byte
    end;

    ModeInfoBlock : record
    { Mandatory information for all VBE revisions }
     ModeAttributes      : word;
     WinAAttributes      : byte;
     WinBAttributes      : byte;
     WinGranularity      : word;
     WinSize             : word;
     WinASegment         : word;
     WinBSegment         : word;
     WinFuncPtr          : pointer;
     BytesPerScanLine    : word;
    { Mandatory information for VBE 1.2 and above }
     XResolution         : word;
     YResolution         : word;
     XCharSize           : byte;
     YCharSize           : byte;
     NumberOfPlanes      : byte;
     BitsPerPixel        : byte;
     NumberOfBanks       : byte;
     MemoryModel         : byte;
     BankSize            : byte;
     NumberOfImagePages  : byte;
     Reserved1           : byte;
    { Direct Color fields (required for direct/6 and YUV/7 memory models) }
     RedMaskSize         : byte;
     RedFieldPosition    : byte;
     GreenMaskSize       : byte;
     GreenFieldPosition  : byte;
     BlueMaskSize        : byte;
     BlueFieldPosition   : byte;
     RsvdMaskSize        : byte;
     RsvdFieldPosition   : byte;
     DirectColorModeInfo : byte;
    { Mandatory information for VBE 2.0 and above }
     PhysBasePtr         : longint;
     OffScreenMemOffset  : longint;
     OffScreenMemSize    : word;
     Reserved2           : array[0..205] of byte
    end;

    bmpfile : file;
    buf : array[0..1279] of byte;

    OldMode, Mode, Window, Segment, Units, Offset : word;
    Size, Address : longint;
    x,y : word;


{ VESA interface }

function ReturnVBEInfo(var VbeInfoBlockPtr) : word; assembler;
asm mov ax,4F00h; les di,VbeInfoBlockPtr; int 10h end;

function ReturnModeInfo(Mode : word; var ModeInfoBlockPtr) : word; assembler;
asm mov ax,4F01h; mov cx,Mode; les di,ModeInfoBlockPtr; int 10h end;

function SetVBEMode(Mode : word) : word; assembler;
asm mov ax,4F02h; mov bx,Mode; int 10h end;

function ReturnVBEMode : word; assembler;
asm mov ax,4F03h; int 10h; mov ax,bx end;

function SetWindow(Window, Units : word) : word; assembler;
asm mov ax,4F05h; mov bx,Window; mov dx,Units; int 10h end;

{ Palette... }

procedure SetPalette(First, N : word; var Palette); assembler;
asm
 pushf
 push ds
 mov al,byte ptr First
 mov dx,3C8h
 out dx,al
 inc dx
 std
 mov cx,N
 lds si,Palette
 add si,2
@SP:
 lodsb
 shr al,2
 out dx,al
 lodsb
 shr al,2
 out dx,al
 lodsb
 shr al,2
 out dx,al
 add si,7
 loop @SP
 pop ds
 popf
end;

begin
{ Open bitmap file }
 if ParamCount = 1 then with bitmap do begin
  assign(bmpfile,ParamStr(1)); reset(bmpfile,1);
  blockread(bmpfile, bitmap, sizeof(bitmap));
  if bfType = $4D42 then begin

{ Show details }
   writeln(#10'Bitmap   : ', ParamStr(1));
   writeln(   ' width   : ',biWidth);
   writeln(   ' height  : ',biHeight);
   writeln(   ' bits    : ',biBitCount);
   if biClrUsed = 0 then biClrUsed := 1 shl biBitCount;
   writeln(   ' colours : ',biClrUsed);
   if ((biBitCount = 4) or (biBitCount = 8)) and (biWidth > 0) and (biHeight >
0)   and (biWidth <= 1280) and (biHeight <= 1024) then begin
    if biBitCount = 4 then
     biWidth := (biWidth + 7) and $FFF8
    else
     biWidth := (biWidth + 3) and $FFFC;

{ Get VESA interface }
    if ReturnVBEInfo(VbeInfoBlock) = $004F then with VbeInfoBlock do begin
     writeln(#10'VBE version  : ', hi(VbeVersion), '.', lo(VbeVersion), '0');
     case biWidth of
        1.. 640:Mode:=$100; 641.. 800:Mode:=$103;
      801..1024:Mode:=$105;1025..1280:Mode:=$107
     end;
     case biHeight of
          1..400:x :=$100;401.. 480:x :=$101;481..600:x :=$103;
        601..768:x :=$105;769..1024:x :=$107
     end;
     if Mode < x then Mode := x;
     if (ReturnModeInfo(Mode, ModeInfoBlock) = $004F)
     and odd(ModeInfoBlock.ModeAttributes) then with ModeInfoBlock do begin

{ Show details}
      writeln(' mode        : ', Mode, 'd');
      writeln(' granularity : ', WinGranularity,'KB');
      writeln(' window size : ', WinSize,'KB');
      if (WinAAttributes and 4) = 4 then begin
       Window := 0; Segment := WinASegment
      end else begin
       Window := 1; Segment := WinBSegment
      end;
      writeln(' window      : ', chr(ord('A') + window));
      writeln(' segment     : ', Segment, 'd');
      writeln(' bytes/line  : ', BytesPerScanLine);
      Units := WinSize div WinGranularity;
      Size := longint(WinSize) shl 10;
      writeln(#10'Press <Enter> to display bitmap'); readln;
      OldMode := ReturnVBEMode;
      if SetVBEMode(Mode) = $004F then begin

{ Read and set palette }
       blockread(bmpfile, palette, biClrUsed shl 2);
       SetPalette(0,biClrUsed,Palette);

{ Show bitmap}
       for y := pred(biHeight) downto 0 do begin
        Address := longint(y) * BytesPerScanLine;
        SetWindow(Window, Address div Size);
        Offset := Address mod Size;
        if biBitCount = 4 then begin

{ Show 4-bit bitmap }
         blockread(bmpfile, buf, biWidth shr 1);
         for x := pred(biWidth shr 1) downto 0 do begin
          buf[succ(x shl 1)] := buf[x] and $0F;
          buf[x shl 1] := buf[x] shr 4
         end;
         if Offset <= (Size - biWidth) then
          move(buf, mem[Segment:Offset], biWidth)
         else begin
          move(buf, mem[Segment:Offset], Size - Offset);
          SetWindow(Window, succ(Address div Size));
          move(buf, mem[Segment:0], biWidth - Size + Offset)
         end
        end else

{ Show 8-bit bitmap }
         if Offset <= (Size - biWidth) then
          blockread(bmpfile, mem[Segment:Offset], biWidth)
         else begin
          blockread(bmpfile, mem[Segment:Offset], Size - Offset);
          SetWindow(Window, succ(Address div Size));
          blockread(bmpfile, mem[Segment:0], biWidth - Size + Offset)
        end
       end;
       readln; SetVBEMode(OldMode)
      end else writeln('VESA mode could not be set')
     end else writeln('VESA mode not supported in hardware')
    end else writeln('No VESA BIOS found')
   end else writeln('Unable to display bitmap')
  end else writeln('File is not a BMP file');
  close(bmpfile)
 end else writeln('Usage : BMP <filename>.BMP')
end.

