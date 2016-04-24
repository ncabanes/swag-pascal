(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0010.PAS
  Description: View Windows BMP Files
  Author: BARRY NAUJOK
  Date: 11-26-93  16:55
*)

{
-----------------------------------------------------------------------------
Program BMPView;  { by Barry Naujok, 1993, written in TP7 }
        { This information was completely derived on my own (ALL of it). }
        { If there are any errors or omisions, please let me know at ... }
        {          a1357665@cfs01.cc.monash.edu.au                       }
        { Currently only supports 3-256 colours (not monochrome or true colour) }
        { My opinion: As can be seen from decoding a BitMaP, I truly believe }
        {    that Microsoft is a bit backwards! :) (other opinions welcome) }

Uses VESA,Crt,Dos,Strings;

Const bufsize=32000; { my optimal buffer size, could be bigger for other drives }
                     { Has to be even for the RLE decompression }
Type THeader=Record
       ID    : Word;     { 'BM' for a Windows BitMaP }
       FSize : LongInt;  { Size of file }
       Ver   : LongInt;  { BMP version (?), currently 0 }
       Image : LongInt;  { Offset of image into file }
       Misc  : LongInt;  { Unknown, appears to be 40 for all files }
       Width : LongInt;  { Width of image }
       Height: LongInt;  { Height of image }
       Num   : Word;     { Not sure, possibly number of images or planes (1) }
       Bits  : Word;     { Number of bits per pixel }
       Comp  : LongInt;  { Type of compression, 0 for uncompressed, 1,2 for RLE }
       ISize : LongInt;  { Size of image in bytes }
       XRes  : LongInt;  { X dots per metre (not inches! for US, unbelievable!) }
       YRes  : LongInt;  { Y dots per metre }
       PSize : LongInt;  { Palette size (number of colours) if not zero }
       Res   : LongInt;  { Probably reserved, currently 0 }
     End;  { 54 bytes }

     PByte = ^Byte;

     TPalette = Record
       b,g,r,x : Byte;   { BMP uses a fourth byte for the palette, not used }
     End;

Var  fl     : File;
     header : THeader;
     buffer : PByte;

Procedure BlankPalette;
Var pal : Array[0..767] Of Byte;
    r   : Registers;
Begin
  FillChar(pal,768,0);
  r.ax:=$1012;
  r.bx:=0;
  r.cx:=256;
  r.dx:=Ofs(pal);
  r.es:=Seg(pal);
  Intr($10,r);
End;

Procedure SetPalette;
Const Pal16:Array[0..15]Of Byte=(0,1,2,3,4,5,20,7,56,57,58,59,60,61,62,63);
Var palette : TPalette;  { ^ Actual BIOS palette numbers for 16 colour modes }
    BIOSpal : Array[0..767] Of Byte;
    i       : Byte;
    r       : Registers;
Begin
  For i:=0 To header.PSize-1 Do Begin
    BlockRead(fl,palette,4);
    If header.PSize>16 Then Begin
      BIOSpal[i*3]:=palette.r Shr 2;
      BIOSpal[i*3+1]:=palette.g Shr 2;
      BIOSpal[i*3+2]:=palette.b Shr 2;
    End Else Begin
      BIOSpal[Pal16[i]*3]:=palette.r Shr 2;
      BIOSpal[Pal16[i]*3+1]:=palette.g Shr 2;
      BIOSpal[Pal16[i]*3+2]:=palette.b Shr 2;
    End;
  End;
  r.ax:=$1012;
  r.bx:=0;
  r.cx:=256;
  r.dx:=Ofs(BIOSpal);
  r.es:=Seg(BIOSpal);
  Intr($10,r);
End;

Procedure ShowImage256(name:PChar); Assembler;
Var dseg,width,height,bytes,rows,bank,handle,cp:Word;
Asm
        Mov     dseg,ds
        Mov     ax,header.Comp.Word[0]
        Mov     cp,ax
        Mov     ax,header.Width.Word[0]
        Test    ax,1
        Jz      @0I
        Inc     ax  { image is word aligned so adjust width if needed }
  @0I:  Mov     width,ax
        Mov     ax,header.Height.Word[0]
        Mov     height,ax
        Mov     di,ax
        Dec     di
        Mov     ax,VesaMode.Bytes
        Mov     bytes,ax
        Mov     ax,VesaMode.Height
        Mov     rows,ax
        Mov     es,VesaMode.SegA

        Mov     ax,$3D00
        Lds     dx,name
        Int     $21                     { Open the file for assembler }
        Mov     ds,dseg                 { Restore the data segment }
        Jc      @Ex
        Mov     handle,ax

        Mov     bx,ax
        Mov     ax,$4200
        Mov     cx,header.Image.Word[2]
        Mov     dx,header.Image.Word[0]
        Int     $21                     { Seek to image location }
        Call    @FR
        Jmp     @0N

  @FR:  Push    ax
        Push    cx
        Push    dx
        Mov     ds,dseg
        Mov     bx,handle
        Mov     cx,bufsize
        Lds     si,buffer
        Mov     dx,si
        Mov     ah,$3F
        Int     $21
        Mov     bx,ax                   { Bytes left to read from the buffer }
        Pop     dx
        Pop     cx
        Pop     ax
        RetN

  @0N:  Mov     ax,bytes
        Mul     di
        Mov     di,ax
        Mov     bank,dx
        Call    @B1                     { Set the last line & bank }
        Mov     dx,width

        Cmp     cp,0
        Je      @0S

        { RLE bitmap }
  @1S:  Xor     dx,dx                   { Set DX as the width count }
  @10:  Xor     ah,ah                   { Clear upper byte }
        Lodsb                           { Get "index" byte }
        Dec     bx                      { Decrement buffer count }
        Jnz     @11                     { Jump if not empty }
        Call    @FR                     { Reload buffer }
  @11:  Or      al,al
        Jz      @14                     { Jump if following is a string }
        { Repeat byte }
        Mov     cx,ax                   { else "index" is a repeat count }
        Add     dx,cx
        Lodsb                           { Load data to repeat "index" times }
        Dec     bx
        Jnz     @12                     { Jump if buffer isn't empty }
        Call    @FR
  @12:  Stosb                           { Draw byte to screen }
        Or      di,di                   { Check to see if line crosses bank }
        Jnz     @13
        Inc     bank                    { Change bank if crossed }
        Call    @B1
  @13:  Loop    @12                     { Store all repeated bytes }
        Jmp     @10
        { Dump string }
  @14:  Lodsb                           { Load "count", number of bytes in the string }
        Mov     cx,ax
        Add     dx,cx
        Dec     bx
        Jnz     @1T                     { Update buffer count (& buffer contents) }
        Call    @FR
  @1T:  Or      al,al
        Jz      @20
  @15:  Movsb                           { Transfer string to screen }
        Or      di,di
        Jnz     @16                     { bank checking }
        Inc     bank
        Call    @B1
  @16:  Dec     bx                      { Update buffer count, etc }
        Jnz     @17
        Call    @FR
  @17:  Loop    @15                     { Repeat for string }
        Test    al,1                    { See if there was an odd numbered count }
        Jz      @10                     { Jump if even }
        Lodsb                           { Clear extra byte, due to word alignment }
        Dec     bx
        Jnz     @10                     { Update buffer count, etc }
        Call    @FR
        Jmp     @10
  @20:  Sub     di,dx                   { Move screen pointer to start of line }
        Jnc     @21                     { Jump if not crossed bank }
        Dec     bank                    { Update bank if crossed }
        Call    @B1
  @21:  Sub     di,bytes                { Move to screen line above }
        Jnc     @23                     { Jump if not crossed bank }
        Dec     bank                    { Update bank if crossed }
        Call    @B1
  @23:  Dec     height                  { Update line count }
        Jnz     @1S                     { Jump to start if not end of the image }
        Jmp     @Ex                     { Exit if image drawn }

        { Un-compressed bitmap }
  @0S:  Mov     cx,dx
        Mov     ax,di
        Add     ax,cx
        Jc      @03                     { Jump if line crosses bank }
        Cmp     bx,cx
        Jle     @03                     { Jump if file buffer will run out }
        Sub     bx,cx                   { Update buffer counter }
        Shr     cx,1
        Jnc     @01
        Movsb
  @01:  Rep     Movsw                   { Show line }
        Sub     di,dx                   { Go to next line (above) }
        Sub     di,bytes
        Jnc     @02
        Dec     bank                    { See if line above is in another bank }
        Call    @B1
  @02:  Dec     height
        Jnz     @0S
        Jmp     @Ex
  @03:  Movsb
        Or      di,di
        Jnz     @04
        Inc     bank
        Call    @B1
  @04:  Dec     bx
        Jnz     @05
        Call    @FR
  @05:  Loop    @03
        Sub     di,dx
        Jnc     @06
        Dec     bank
        Call    @B1
  @06:  Sub     di,bytes
        Jnc     @07
        Dec     bank
        Call    @B1
  @07:  Dec     height
        Jnz     @0S
        Jmp     @Ex


        { Set bank }
  @B1:  Push    ax
        Push    ds
        Mov     ds,dseg
        Mov     al,vesaon
        Or      al,al
        Jz      @B3
        Push    bx
        Push    dx
        Mov     dx,bank
        Xor     bx,bx
        Mov     ax,64
        Mul     dx
        Div     VesaMode.Gran
        Mov     dx,ax
        Push    dx
        Call    VesaMode.WinFunc
        Pop     dx
        Inc     bx
        Call    VesaMode.WinFunc
        Pop     dx
        Pop     bx
  @B3:  Pop     ds
        Pop     ax
        RetN
  @Ex:  Mov     ds,dseg
        Mov     bx,handle              { Close the file }
        Mov     ah,$3E
        Int     $21
End;

Procedure ShowImage16(name:PChar); Assembler;
Var dseg,width,height,bytes,rows,bank,handle,cp,rc,bc:Word;
Asm
        Mov     dseg,ds
        Mov     ax,header.Comp.Word[0]
        Mov     cp,ax
        Mov     ax,header.Width.Word[0]
        Mov     width,ax
        Mov     ax,header.Height.Word[0]
        Mov     height,ax
        Mov     di,ax
        Dec     di
        Mov     ax,VesaMode.Bytes
        Mov     bytes,ax
        Mov     ax,VesaMode.Height
        Mov     rows,ax
        Mov     es,VesaMode.SegA

        Mov     ax,$3D00
        Lds     dx,name
        Int     $21                     { Open the file for assembler }
        Mov     ds,dseg                 { Restore the data segment }
        Jc      @Ex
        Mov     handle,ax

        Mov     bx,ax
        Mov     ax,$4200
        Mov     cx,header.Image.Word[2]
        Mov     dx,header.Image.Word[0]
        Int     $21                     { Seek to image location }
        Call    @FR
        Jmp     @0N

  @FR:  Push    ax
        Push    bx
        Push    cx
        Push    dx
        Mov     ds,dseg
        Mov     bx,handle
        Mov     cx,bufsize
        Lds     si,buffer
        Mov     dx,si
        Mov     ah,$3F
        Int     $21
        Mov     bc,ax                   { Bytes left to read from the buffer }
        Pop     dx
        Pop     cx
        Pop     bx
        Pop     ax
        RetN

  @0N:  Mov     ax,bytes
        Mul     di
        Mov     di,ax
        Mov     bank,dx
        Call    @B1                     { Set the last line & bank }
        Mov     dx,$3CE
        Mov     ax,$205
        Out     dx,ax                   { Set Write Mode 2 }
        Mov     ax,$8008                { Initial bit mask }

        Cmp     cp,0
        Je      @0S

        { RLE bitmap }
  @1S:  Mov     rc,0
        Mov     ax,$8008
  @10:  Xor     ch,ch                   { Clear upper byte }
        Mov     cl,[si]                 { Get "index" byte }
        Inc     si
        Dec     bc                      { Decrement buffer count }
        Jnz     @11                     { Jump if not empty }
        Call    @FR                     { Reload buffer }
  @11:  Or      cl,cl
        Jz      @14                     { Jump if following is a string }
        { Repeat byte }
        Shr     cl,1                    {   Divide the "index" by two }
        Mov     bl,[si]                 { Load data to repeat "index" times }
        Inc     si
        Dec     bc
        Jnz     @12                     { Jump if buffer isn't empty }
        Call    @FR
  @12:  Rol     bl,4
        Out     dx,ax
        Mov     bh,es:[di]
        Mov     es:[di],bl              { Update screen }
        Ror     ah,1
        Jnc     @1B
        Inc     di
        Jnc     @1B
        Inc     bank                    { Change bank if crossed }
        Call    @B1
  @1B:  Out     dx,ax
        Rol     bl,4
        Mov     bh,es:[di]
        Mov     es:[di],bl
        Ror     ah,1
        Jnc     @13
        Inc     di
        Inc     rc
        Jnc     @13
        Inc     bank                    { Change bank if crossed }
        Call    @B1
  @13:  Loop    @12                     { Store all repeated bytes }
        Jmp     @10
        { Dump string }
  @14:  Mov     cl,[si]                 { Load "count", number of bytes in the string }
        Inc     si
        Dec     bc
        Jnz     @1E                     { Update buffer count (& buffer contents) }
        Call    @FR
  @1E:  Or      cl,cl
        Jz      @20
        Shr     cl,1                    { Divide the "count" by 2 }
        Push    cx
  @15:  Mov     bl,[si]
        Inc     si
        Rol     bl,4
        Out     dx,ax
        Mov     bh,es:[di]
        Mov     es:[di],bl
        Ror     ah,1
        Jnc     @1A
        Inc     di
        Jnz     @1A                     { bank checking }
        Inc     bank
        Call    @B1
  @1A:  Out     dx,ax
        Rol     bl,4
        Mov     bh,es:[di]
        Mov     es:[di],bl
        Ror     ah,1
        Jnc     @16
        Inc     di
        Inc     rc
        Jnz     @16
        Inc     bank
        Call    @B1
  @16:  Dec     bc                      { Update buffer count, etc }
        Jnz     @17
        Call    @FR
  @17:  Loop    @15                     { Repeat for string }
        Pop     cx
        Test    cl,1                    { See if there was an odd numbered count }
        Jz      @10                     { Jump if even }
        Mov     cl,[si]                 { Clear extra byte, due to word alignment }
        Inc     si
        Dec     bc
        Jnz     @10                     { Update buffer count, etc }
        Call    @FR
        Jmp     @10
  @20:  Sub     di,rc                   { Move screen pointer to start of line }
        Jnc     @21                     { Jump if not crossed bank }
        Dec     bank                    { Update bank if crossed }
        Call    @B1
  @21:  Sub     di,bytes                { Move to screen line above }
        Jnc     @22                     { Jump if not crossed bank }
        Dec     bank                    { Update bank if crossed }
        Call    @B1
  @22:  Dec     height                  { Update line count }
        Jnz     @1S                     { Jump to start if not end of the image }
        Jmp     @Ex                     { Exit if image drawn }

        { Un-compressed bitmap }
  @0S:  Mov     ax,width
        Xor     bx,bx
        Mov     rc,ax                   { Initialize rowcount }
        Mov     ax,$8008
  @02:  Out     dx,ax                   { Update bit mask register }
        Mov     cl,[si]                 { Load a byte (2 pixels) }
        Inc     si                      { Update buffer pointer }
        Dec     bc                      { Updata buffer count }
        Jnz     @03
        Call    @FR                     { Reload buffer if necessary }
  @03:  Ror     cl,4                    { Move 1st pixel in low part of CL }
        Mov     ch,es:[di]              { Load latches }
        Mov     es:[di],cl              { Update latches }
        Ror     ah,1                    { Shift bit mask right a pixel }
        Out     dx,ax                   { Update bit mask register }
        Ror     cl,4                    { Move 2nd pixel in low part of CL }
        Mov     ch,es:[di]              { as above 3 steps }
        Mov     es:[di],cl              { ... }
        Sub     rc,2
        Jle     @04
        Ror     ah,1
        Jnc     @02
        Inc     di
        Inc     bx
        Jnc     @02
        Inc     bank
        Call    @B1
        Jmp     @02
  @04:  Mov     ax,si                   { Discard extra bytes for }
        Mov     cx,4                    { LongInt alignment (?) }
        And     ax,3
        Sub     cx,ax
        And     cx,3
        Add     si,cx
        Sub     bc,cx
        Sub     di,bx
        Jnc     @06
        Dec     bank
        Call    @b1
  @06:  Sub     di,bytes
        Jnc     @07
        Dec     bank
        Call    @b1
  @07:  Dec     height
        Jnz     @0S
        Jmp     @Ex

        { Set bank }
  @B1:  Push    ax
        Push    ds
        Mov     ds,dseg
        Mov     al,vesaon
        Or      al,al
        Jz      @B3
        Push    bx
        Push    dx
        Mov     dx,bank
        Xor     bx,bx
        Mov     ax,64
        Mul     dx
        Div     VesaMode.Gran
        Mov     dx,ax
        Push    dx
        Call    VesaMode.WinFunc
        Pop     dx
        Inc     bx
        Call    VesaMode.WinFunc
        Pop     dx
        Pop     bx
  @B3:  Pop     ds
        Pop     ax
        RetN
  @Ex:  Mov     ds,dseg
        Mov     bx,handle              { Close the file }
        Mov     ah,$3E
        Int     $21
End;
Procedure ShowBMP;
Var fn:Array[0..63]Of Char;
Begin
  StrPCopy(fn,ParamStr(1));
  GetMem(buffer,bufsize);
  Case header.PSize Of
    1..16: Begin
         Case header.Width Of
              0..640  : SetMode($12);
            641..800  : SetMode($102);
            801..1024 : SetMode($104);
           1025..9999 : SetMode($106);
         End;
         BlankPalette;
         ShowImage16(fn);
       End;
    17..256: Begin
         Case header.Width Of
              0..320  : SetMode($13);
            321..640  : SetMode($101);
            641..800  : SetMode($103);
            801..1024 : SetMode($105);
           1025..9999 : SetMode($107);
         End;
         BlankPalette;
         ShowImage256(fn);
       End;
  End;

  FreeMem(buffer,bufsize);
  SetPalette;
  Sound(660);
  Delay(100);
  Sound(880);
  Delay(50);
  Sound(440);
  Delay(75);
  NoSound;

  ReadKey;
  SetMode(3);
End;

Procedure SetPSize;
Begin
  If header.PSize=0 Then Case header.Bits Of
    1 : header.PSize:=2;  { These are the only valid bits in a BMP }
    4 : header.PSize:=16;
    8 : header.PSize:=256;
    24: header.PSize:=0;  { A 24 bit image does not have a palette }
  End;
End;

Begin
  If ParamCount>0 Then Begin
    Assign(fl,ParamStr(1));
    {$I-}
    Reset(fl,1);
    {$I+}
    If IOResult=0 Then Begin
      BlockRead(fl,header,54);
      If header.ID=$4D42 Then Begin
        SetPSize; { Set the PSize field in the header if not defined }
        Writeln;
        Writeln('Width  . . . . . ',header.Width,' pixels');
        Writeln('Height . . . . . ',header.Height,' pixels');
        Writeln('Bits per Pixel . ',header.Bits);
        Writeln('Palette Size . . ',header.PSize,' colours, ',header.PSize*4,' bytes');
        Write('Compression  . . type ',header.Comp);
        If header.Comp=0 Then Writeln(' (not compressed)')
          Else Writeln(' (RLE)');
        Writeln('Image Offset . . ',header.Image);
        Writeln('Image Size . . . ',header.ISize,' bytes');
        Writeln('X Resolution . . ',header.XRes,' D/m, ',header.XRes*254 Div 10000,' DPI');
        Writeln('Y Resolution . . ',header.YRes,' D/m, ',header.YRes*254 Div 10000,' DPI');
        Writeln;
        If ((header.Width<641)And(header.Height<481)And(header.PSize<17))
           Or((header.Width<321)And(header.Height<201))Or(IsVesa) Then
        If header.PSize>2 Then Begin
          Writeln('Press a key to show the image');
          ReadKey;
          ShowBMP;
        End Else Writeln('Cannot display the image without VESA graphics support');
        Close(fl);
      End Else Writeln('The file is not a Windows BitMaP file');
    End Else Writeln('File not found, try again');
  End Else Writeln('Usage: BMPVIEW <filename>');
End.
-----------------------------------------------------------------------------
Unit VESA;

Interface

Type ModeList=Array[1..32] Of Word;  { List of VESA mode numbers }

     TVesaMode=Record
       Attr     : Word;         { Mode Attributes                   }
       WinA     : Byte;         { Window A attributes               }
       WinB     : Byte;         { Window B attributes               }
       Gran     : Word;         { Window granularity in K bytes     }
       WinSiz   : Word;         { Size of window in K bytes         }
       SegA     : Word;         { Segment address of window A       }
       SegB     : Word;         { Segment address of window B       }
       WinFunc  : Procedure;    { Windows positioning function      }
       Bytes    : Word;         { Number of bytes per line          }
       Width    : Word;         { Number of horizontal pixels       }
       Height   : Word;         { Number of vertical pixels         }
       CharW    : Byte;         { Width of character cell           }
       CharH    : Byte;         { Height of character cell          }
       Planes   : Byte;         { Number of memory planes           }
       Bits     : Byte;         { Number of bits per pixel          }
       nBanks   : Byte;         { Number of banks        (not used) }
       Model    : Byte;         { Memory model type                 }
       Banks    : Byte;         { Size of bank           (not used) }
       Pages    : Byte;         { Number of image pages             }
       Reserved : Byte; { The following are for 15,16,24,32 bit colour modes }
       RedMaskSize   : Byte;    { Size of Red mask in bits          }
       RedFieldPos   : Byte;    { Bit position of LSB of Red mask   }
       GreenMaskSize : Byte;    { Size of Green mask in bits        }
       GreenFieldPos : Byte;    { Bit position of LSB of Green mask }
       BlueMaskSize  : Byte;    { Size of Blue mask in bits         }
       BlueFieldPos  : Byte;    { Bit position of LSB of Blue mask  }
       RsvdMaskSize  : Byte;    { Size of Reserved mask in bits     }
       RsvdFieldPos  : Byte;    { Bit pos. of LSB of Reserved mask  }
       DirColModeInf : Byte;    { Direct Colour mode attributes     }
       Filler   : Array[0..215] Of Byte; { Not used - filler        }
     End;

     TVesaInfo=Record
       Signature    : LongInt;   { Signature - "VESA"               }
       Version      : Word;      { VESA Version number              }
       OEMName      : PChar;     { Pointer to manufacturer name     }
       Capabilities : Longint;   { Capabilities       (Not used)    }
       List         : ^ModeList; { Pointer to list of VESA modes    }
       TotalMemory  : Word;      { Number of 64k memory blocks on card }
       Filler       : Array[1..238] of Byte;
     End; { 258 byte size due to bug in the Diamond SpeedStar 24X v1.01 BIOS }


Var  VesaMode : TVesaMode;
                { Contains all info needed for drawing on the screen }
     VesaInfo : TVesaInfo;
                { Contains info on the VESA BIOS Extensions }

     vesaon   : Byte;
                { Specifies whether a VESA mode is on or not      }

Function  IsVesa:Boolean;
          { Detects whether VESA support is present }
Procedure GetVesaInfo;
          { Get Information on VESA modes, etc }
Procedure GetVesaModeInfo(md:Word);
          { Get Information on a VESA mode (md) }
Function  SetMode(md:Word):Boolean;
          { Sets a video mode (OEM and VESA) }
Function  GetMode:Word;
          { Returns the current video mode }
Function  SizeOfVideoState:Word;
          { Returns the size of the buffer needed to save the video state }
Procedure SaveVideoState(Var buf);
          { Saves the SVGA video state in the buffer }
Procedure RestoreVideoState(Var buf);
          { Restores the SVGA video state from the buffer}
Procedure SetBank(bank:Word);
          { Set the video bank to draw on }
Function  GetBank:Word;
          { Gets the current active video bank }
Procedure SetLineLength(Var len:Word);
          { Sets the logical scan line length, returns the actual length set }
Function  GetLineLength:Word;
          { Returns the current logical scan line length }
Procedure SetDisplayStart(pixel,line:Word);
          { Sets the first pixel and line on the display }
Procedure GetDisplayStart(Var pixel,line:Word);
          { Returns the first pixel and line on the display }

{---------------------------------------------------------------------------}
{-----------------------------} Implementation {----------------------------}
{---------------------------------------------------------------------------}

Uses Dos;

Var  rp : Registers;

Function IsVesa:Boolean;
Begin
  rp.ax:=$4F03;
  Intr($10,rp);
  IsVesa:=(rp.al=$4F);
End;

Procedure GetVesaInfo;
Begin
  rp.ax:=$4F00;
  rp.di:=Ofs(VesaInfo);
  rp.es:=Seg(VesaInfo);
  Intr($10,rp);
End;

Procedure GetVesaModeInfo(md:Word);
Begin
  rp.ax:=$4F01;
  rp.cx:=md;
  rp.di:=Ofs(VesaMode);
  rp.es:=Seg(VesaMode);
  Intr($10,rp);
End;

Function SetMode(md:Word):Boolean;
Begin
  SetMode:=True; vesaon:=1;
  If md>$FF Then Begin
    rp.bx:=md;
    rp.ax:=$4F02;
    Intr($10,rp);
    If rp.ax<>$4F Then SetMode:=False Else GetVesaModeInfo(md);
  End Else Begin
    rp.ax:=md;
    Intr($10,rp);
    VesaMode.Gran:=64; vesaon:=0;
    VesaMode.SegA:=$A000;
    Case md Of  { OEM (standard) video modes }
      1..3,7 : Begin { Text modes }
                 VesaMode.Width:=80;  VesaMode.Height:=25;
                 If md=7 Then Begin
                   VesaMode.Bits:=1;  VesaMode.SegA:=$B000;
                 End Else Begin
                   VesaMode.Bits:=4;  VesaMode.SegA:=$B800;
                 End;
                 VesaMode.Bytes:=160; VesaMode.Model:=0;
               End;
      $13 : Begin  { 320 x 200 x 256 colours, VGA & MCGA }
              VesaMode.Width:=320; VesaMode.Height:=200;
              VesaMode.Bits:=8;    VesaMode.Model:=4;
              VesaMode.Bytes:=320;
            End;
      $12 : Begin  { 640 x 480 x 16 colours, VGA only }
              VesaMode.Width:=640; VesaMode.Height:=480;
              VesaMode.Bits:=4;    VesaMode.Model:=3;
              VesaMode.Bytes:=80;
            End;
      $10 : Begin  { 640 x 350 x 16 colours, VGA & EGA with 128k+ }
              VesaMode.Width:=640; VesaMode.Height:=350;
              VesaMode.Bits:=4;    VesaMode.Model:=3;
              VesaMode.Bytes:=80;
            End;
      $0E : Begin  { 640 x 200 x 16 colours, VGA & EGA }
              VesaMode.Width:=640; VesaMode.Height:=200;
              VesaMode.Bits:=4;    VesaMode.Model:=3;
              VesaMode.Bytes:=80;
            End;
      $0D : Begin  { 320 x 200 x 16 colours, VGA & EGA }
              VesaMode.Width:=320; VesaMode.Height:=200;
              VesaMode.Bits:=4;    VesaMode.Model:=3;
              VesaMode.Bytes:=40;
            End;
      Else SetMode:=False;
    End;
  End;
End;

Function GetMode:Word;
Begin
  rp.ax:=$4F03;
  Intr($10,rp);
  GetMode:=rp.bx;
End;

Function SizeOfVideoState:Word;
Begin  { Will save/restore all video states }
  rp.ax:=$4F04;
  rp.dl:=0;
  rp.cx:=$0F;  { hardware, BIOS, DAC & SVGA states }
  Intr($10,rp);
  SizeOfVideoState:=rp.bx;
End;

Procedure SaveVideoState(Var buf);
Begin
  rp.ax:=$4F04;
  rp.dl:=1;
  rp.cx:=$0F;
  rp.es:=Seg(buf);
  rp.bx:=Ofs(buf);
  Intr($10,rp);
End;

Procedure RestoreVideoState(Var buf);
Begin
  rp.ax:=$4F04;
  rp.dl:=2;
  rp.cx:=$0F;
  rp.es:=Seg(buf);
  rp.bx:=Ofs(buf);
  Intr($10,rp);
End;

Procedure SetBank(bank:Word);
Var winnum:Word;
Begin
  winnum:=bank*64 Div VesaMode.Gran;
  rp.ax:=$4F05;
  rp.bx:=0;
  rp.dx:=winnum;
  Intr($10,rp);
  rp.ax:=$4F05;
  rp.bx:=1;
  rp.dx:=winnum;
  Intr($10,rp);
End;

Function GetBank:Word;
Begin
  rp.ax:=$4F05;
  rp.bx:=$100;
  Intr($10,rp);
  GetBank:=rp.dx;
End;

Procedure SetLineLength(Var len:Word);
Begin
  rp.ax:=$4F06;
  rp.bl:=0;
  rp.cx:=len;
  Intr($10,rp); { dx:=maximum number of scan lines }
  len:=rp.cx;
End;

Function GetLineLength:Word;
Begin
  rp.ax:=$4F06;
  rp.bl:=1;
  Intr($10,rp); { dx:=maximum number of scan lines }
  GetLineLength:=rp.cx;
End;

Procedure SetDisplayStart(pixel,line:Word);
Begin
  rp.ax:=$4F07;
  rp.bx:=0;
  rp.cx:=pixel;
  rp.dx:=line;
  Intr($10,rp);
End;

Procedure GetDisplayStart(Var pixel,line:Word);
Begin
  rp.ax:=$4F07;
  rp.bx:=1;
  Intr($10,rp);
  pixel:=rp.cx;
  line:=rp.dx;
End;

End.

