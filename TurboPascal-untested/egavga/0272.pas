UNIT VESAdrv;
INTERFACE
const ProgName   :string[80] = 'VESA driver interface by Pε'#$0D#$0A'$';
	  ProgVersion:word = $0102;  { programmed for VESA version 1.2 }
	  MaxVertical =      480*2;       { max. vertical lines you need }
									  { double if 2 pages required }

	  VesaSign   :longint = $41534556; { = 'VESA' }
	  StatusOk   :WORD    = $004f;     { default ok response after int 10 }
											  {.........!.........!.........!}
	  VesaErrors :ARRAY[0..5] OF STRING[30] =('Vesa init ok.                 ',
											  '?Error getting vesainfo.      ',
											  '?Vesa not detected.           ',
											  '?Vesa not detected.           ',
											  '?Error getting vesamodeinfo.  ',
											  '?Error opening vesamode.      ');
	  MaxBanks = 256;    { maximum bank switch }

type
 TVerticalPosInfo = ARRAY[0..MaxVertical-1] OF RECORD { extra help for finding}
							 Address :Word;             { memory addres }
							 Bank:Byte;             { memory bank }
							 reserved:byte;
							 end;

 TVesaInfoBlock = record
		VESASignature      : longint; {'VESA' check as number}
		VESAVersion        : word;    { version hi.lo }
		OEMStringPtr       : pointer; { pointer to OEM string }
		Capabilities       : longint; { Capabilities field }
		VideoModePtr       : pointer; { pointer to supported modes }
		TotalMemory        : word;    { x64k available memory }
		reserved           : array[1..236] of byte; {unused yet}
		end;

 TVesaModeInfoBlock = record
		ModeAttributes     : word;    { mode attributes                    }
		WinAAttributes     : byte;    { window A attributes                }
		WinBAttributes     : byte;    { window B attributes                }
		WinGranularity     : word;    { window granularity                 }
		WinSize            : word;    { window size                        }
		WinASegment        : word;    { window A start segment             }
		WinBSegment        : word;    { window B start segment             }
		WinFuncPtr         : pointer; { pointer to windor function         }
		BytesPerScanLine   : word;    { bytes per scan line                }
		XResolution        : word;    { horizontal resolution              }
		YResolution        : word;    { vertical resolution                }
		XCharSize          : byte;    { character cell width               }
		YCharSize          : byte;    { character cell height              }
		NumberOfPlanes     : byte;    { number of memory planes            }
		BitsPerPixel       : byte;    { bits per pixel                     }
		NumberOfBanks      : byte;    { number of banks                    }
		MemoryModel        : byte;    { memory model type                  }
		BankSize           : byte;    { bank size in kb                    }
		NumberOfImagePages : byte;    { number of images                   }
		Reserved           : byte;    { reserved for page function         }
		RedMaskSize        : byte;    { size of direct color red mask      }
		RedFieldPosition   : byte;    { bit position of LSB of red mask    }
		GreenMaskSize      : byte;    { size of direct color green mask    }
		GreenFieldPosition : byte;    { bit position of LSB of green mask  }
		BlueMaskSize       : byte;    { size of direct color blue mask     }
		BlueFieldPosition  : byte;    { bit position of LSB of blue mask   }
		RsvdMaskSize       : byte;    { size of direct color reserved mask }
		DirectColorModeInfo: byte;    { Direct Color mode attributes       }
		Reserved2          : array[1..216] of byte; { remainder            }
	   end;

  function InitVesaMode(RequestMode:word;ClearScreen:BOOLEAN):word;
  procedure PutPixel(X,Y:Integer; C:Word);
  procedure DrawBitMap(X,Y, XS,YS:Integer;ImageData:Pointer);
  procedure Draw0BitMap(X,Y, XS,YS:Integer;ImageData:Pointer);
  procedure SetDisplayStart(X,Y:Word);
  procedure CloseVesaMode;

var
 VesaInfo       : TVesaInfoBlock;     { get your own info here }
 VesaModeInfo   : TVesaModeInfoBlock; { get your own info here }
 VerticalPosInfo: TVerticalPosInfo;   { get your own info here }
 BankTable      : ARRAY[0..MaxBanks] OF Word;

 CurrentBank,
 WritePage,
 VisualPage       : word;
 WinSizeBytes     : word;  { winsize in bytes..   0 = 64k }

IMPLEMENTATION
{==== initialize video mode ====}
function InitVesaMode(RequestMode:word;ClearScreen:BOOLEAN):word; assembler;
asm
   xor  si,si        { Error step value }
   inc  si           { start with one }

   mov  ax,ds
   mov  es,ax
   mov  ax,$4f00;    { return SuperVGA information }
   mov  di, OFFSET VesaInfo; { into buffer VesaInfo }
   int  $10;

   cmp  ax,StatusOk; { Status okay ? }
{1}   jnz @ErrorInit;    { no, then halt init }

   inc  si            { next check }
   mov  ax, WORD PTR VesaInfo.VESASignature;  { check first two chars }
   cmp  ax, WORD PTR VesaSign
{2}   jnz @ErrorInit

   inc  si            { next check }
   mov  ax, WORD PTR VesaInfo.VESASignature+2;  { check next two chars }
   cmp  ax, WORD PTR VesaSign+2
{3}   jnz @ErrorInit

   { primary test for VESA done, try to get videomode info }
   inc  si            { next check }
   mov  ax, $4f01               { return videomode information }
   mov  cx, RequestMode         { requested mode }
   mov  di, OFFSET VesaModeInfo { into buffer VesaModeInfo }
   int  $10;

   cmp  ax, StatusOk;           { did this work out good? }
{4}   jnz @ErrorInit

   { start opening videomode }
   inc  si            { next check }
   mov  ax, $4f02;
   mov  bh, ClearScreen;        { must clear screen }
   xor  bh, $01;                { invert bit }
   shl  bh, 7;                  { move bit to d15 }
   xor  bl, bl;                 { clear lower byte }
   or   bx, RequestMode;        { combine with videomode }
   int  $10;

   cmp  ax, StatusOk            { did this work out good? }
{5}   jnz @ErrorInit

   { build vertical pos info block }
   inc  si               { next check }
   mov  cx, MaxVertical  { how many times }
   mov  di, OFFSET VerticalPosInfo;

   xor  bx, bx;                 { startbank=0 }
   xor  ax, ax;                 { address  =0 }
   mov  dx, WORD PTR VesaModeInfo.WinSize;
   mov  WinSizeBytes, dx
   xchg dl, dh                  { multiply this with 1024 }
   shl  dh, 2
(*    mov  dx, $1000 *)

   { set info }
@VPosLoop:
   mov  ds:[di+0],ax            { place addres in vpos infoblock}
   mov  ds:[di+2],bl            { place bank in vpos infoblock }
   mov  ds:[di+3],bh            { place bank in vpos infoblock }

   add  di,4                    { add to next pos. in array}
   add  ax, WORD PTR VesaModeInfo.XResolution { increment address}
   jc   @IncBank                { in case 64k buffer carry is gen. here! }

   cmp  ax, dx                  { check if bank is passed}
   jb  @DoLoop;

   sub  ax, dx                  { decrement ax with size to start again 4k-buf}
@IncBank:
   inc  bx;

@DoLoop:
   Loop @VPosLoop;

   { built bankswitchtable }

   mov  di, OFFSET BankTable
   xor  bx, bx        { start at bank 0 }

@BankLoop:
   mov   ax,bx        { get banknr }

   mov   cx, 64
   mul   cx
	mov   cx, WORD PTR VesaModeInfo.WinGranularity
   jcxz    @@be
   div   cx
@@be:
   mov   ds:[di],ax   { save value }
   inc   di
   inc   di

   inc   bx
   cmp   bx,MaxBanks
   jb    @BankLoop

   { buffer has been built for easy use! }
   XOR  CX,CX
   mov  CurrentBank, CX   { clear current bank to 0 first time}
   mov  WritePage,   CX   { write to page 0 }
   mov  VisualPage,  CX   { visual page = 0 }
   xor  bx,bx;            { perpare for int.}
   mov  dx,cx;            { get banknr from cx }
   mov  ax,$4f05;         { irq init }
   int $10;

(*    jmp  @okinit; *)

{ all ok part }
@OkInit:
   XOR  AX,AX
@ErrorInit:
@End:
end;

{====}
procedure PutPixel(X,Y:Integer; C:Word); assembler;
asm
		 mov     ax,Y
		 add     ax,WritePage

		 mov     di,X
		 mov     dx,VesaModeInfo.BytesPerScanLine
		 mul     dx
		 add     di,ax
		 adc     dx,0
		 cmp     dx,CurrentBank         { out of current window boundary? }
		 je      @@1                    { no }
{==== bankswitch ====}
	   MOV     BX,DX
		 MOV     CurrentBank,BX

	   ADD     BX, BX
	   ADD     BX, OFFSET BankTable
	   mov     DX, DS:[BX]
	   mov     AX, $4F05
	   xor     BX, BX
	   int     10h
@@1:
	   mov     AX ,c
	   mov     es,SegA000
	   mov     es:[di], al
end;

(*asm
	mov  ax,y
	add  ax,WritePage
	shl  ax,2
	mov  si, OFFSET VerticalPosInfo
   add  si, ax

   mov  ax, ds:[si] { get address }
   mov  es,SegA000  { get video segment }
   mov  di,ax       { get video address }

   mov  ax, ds:[si+2] { get bank }
   add  di,x          { add x coordinate to address }
   adc  ax,0          { perhaps bank add }

   cmp  ax, CurrentBank;  { check if bank is same }
   jz @PutPix;            { bank is already ok! }

   mov  CurrentBank,ax;   { set new bank }
   xor  bx,bx;            { perpare for int.}
	mov  dx,ax;            { get banknr from ax }
   mov  ax,$4f05;         { irq init }
   int $10;

@PutPix:
   mov  ax,C;             { get color}
   mov  es:[di],ax;       { finally put the pixel}
   end;
*)

procedure SetBank; near;assembler;
{ IN: BX = Which bank }
asm
   ADD  BX, BX
   ADD  BX, OFFSET BankTable
   mov  DX, DS:[BX]
   mov  AX, $4F05
   xor  BX, BX
   int  10h
end;

procedure DrawBitMap(X,Y, XS,YS:Integer;ImageData:Pointer); assembler;
var
	SaveDS, MemInc,CurBank : word;
	Count,BPLine, WinGran : word;
asm
		 cld
		 mov     SaveDS,ds
		 mov     ax,CurrentBank
		 mov     CurBank,ax
	   mov     ax,VesaModeInfo.WinGranularity
	   mov     WinGran,ax
		 mov     ax,Y
		 add     ax,WritePage

		 mov     di,X
		 mov     dx,VesaModeInfo.BytesPerScanLine
		 mul     dx
		 add     di,ax
		 adc     dx,0
		 cmp     dx,CurBank            { out of current window boundary? }
		 je      @@1                    { no }
{==== bankswitch ====}
	   MOV     BX,DX
		 MOV     CurBank,BX

	   ADD     BX, BX
	   ADD     BX, OFFSET BankTable
	   mov     DX, DS:[BX]
	   mov     AX, $4F05
	   xor     BX, BX
	   int     10h

@@1:   mov     bx,VesaModeInfo.BytesPerScanLine
{ move from buffer to video memory }
		 mov     es,SegA000
		 lds     si, ImageData
		 mov     cx, XS
		 mov     BPLine,cx
		 sub     bx,cx
		 mov     MemInc,bx
		 mov     ax, YS
		 mov     Count,ax

	   { check if switch is necessary, for one line! }
@@2:   mov     ax,di
	   add     ax,CX  { BPLine }
	   jnc     @one_row  { no carry so one full row }

	   { check what's before }
	   xor     cx,cx
	   sub     cx,di

	   shr     cx,1         { copy partially line directly }
	   rep     movsw
	   jnc     @pfini       { ready with one partial line }
	   movsb                { just one byte with copy , no rep is slow start }

@pfini:
	   push    ax           { save rest for later }
	   inc     CurBank

{==== bankswitch ====}
	   mov     ax,CurBank
	   mov     cx, 64
	   mul     cx
		mov     cx, WinGran
(*        or      cx,cx *)
	   jcxz      @@e2
	   div     cx
		mov     dx, ax
	   mov     ax, $4F05
	   xor     bx, bx
	   int     10h
@@e2:

	   pop     ax
@@2_1: { switch done, do other half }
	   mov     cx,ax

@One_Row:
	   shr     cx,1         { copy partially line directly, part 2 after switch }
	   rep     movsw
	   jnc     @fini       { ready with one partial line }
	   movsb                { just one byte with copy , no rep is slow start }

@fini:  { Finished, add for next line }
	   add     di,MemInc
	   jc      @@2_2sw
	   mov     cx,BPLine
	   dec     Count
	   jnz     @@2
	   jmp     @@EndDrw
@@2_2sw:
	   inc     CurBank

{==== bankswitch ====}
	   mov     ax, CurBank
	   mov     cx, 64
	   mul     cx
		mov     cx, WinGran
(*        or      cx,cx *)
	   jcxz      @@e3
	   div     cx
		mov     dx, ax
	   mov     ax, $4F05
	   xor     bx, bx
	   int     10h
@@e3:

	   mov     cx,BPLine
	   dec     Count
	   jnz     @@2

@@EndDrw:
	   mov     ds,SaveDS
	   mov     ax,CurBank
	   mov     CurrentBank,ax
end;

procedure Draw0BitMap(X,Y, XS,YS:Integer;ImageData:Pointer); assembler;
var
	SaveDS : word;
	MemInc : word;
	OldBank,CurBank : word;
	Count,BPLine : word;
asm
		 cld
		 mov     SaveDS,ds
		 mov     ax,CurrentBank
		 mov     CurBank,ax
		 mov     ax,Y
		 add     ax,WritePage

		 mov     di,X
		 mov     dx,VesaModeInfo.BytesPerScanLine
		 mul     dx
		 add     di,ax
		 adc     dx,0
		 cmp     dx,CurBank            { out of current window boundary? }
		 je      @@1                    { no }
		 mov     CurBank,dx
	   mov     bx,dx
		 call    SetBank               { move memory window to new position }

@@1:   mov     bx,VesaModeInfo.BytesPerScanLine
{ move from buffer to video memory }
		 mov     es,SegA000
		 lds     si, ImageData
		 mov     cx, XS
		 mov     BPLine,cx
		 sub     bx,cx
		 mov     MemInc,bx
		 mov     ax, YS
		 mov     Count,ax

	   { check if switch is necessary, for one line! }
@@2:   mov     ax,di
	   add     ax,CX   {BPLine}
	   jnc     @One_row  { no carry so one full row }

@no_one_row:   { there is a switch now in this line }
	   { check what's before }
	   push    ax           { save rest for later }
	   xor     cx,cx
	   sub     cx,di
	   jcxz    @pfini

	   xor     ah,ah
@part1opnieuw:
	   lodsb
	   cmp     al,ah
	   jz      @part1zero    { a zero value, so don't put this}
	   mov     es:[di],al
@part1zero:
	   inc     di
	   dec     cx
	   jnz     @part1opnieuw

@pfini:
	   inc     CurBank
	   push    ds
	   mov     bx,CurBank
	   mov     ds,SaveDs
	   call    SetBank
	   pop     ds

@@2_1: { switch done, do other half }
	   pop     cx
	   jcxz    @fini
@One_row:
	   xor     ah,ah
@part2opnieuw:
	   lodsb
	   cmp     al,ah
	   jz      @part2zero    { a zero value, so don't put this}
	   mov     es:[di],al
@part2zero:
	   inc     di
	   dec     cx
	   jnz     @part2opnieuw

@fini:  { Finished, add for next line }
	   add     di,MemInc
	   jc      @@2_2sw
	   mov     cx,BPLine
	   dec     Count
	   jnz     @@2
	   jmp     @@EndDrw
@@2_2sw:
	   inc     CurBank

	   push    ds
	   mov     bx,CurBank
	   mov     ds,SaveDs
	   call    SetBank

	   pop     ds
	   mov     cx,BPLine
	   dec     Count
	   jnz     @@2

@@EndDrw:
	   mov     ds,SaveDS
end;

{====}
procedure SetDisplayStart(X,Y:Word); assembler;
asm
   mov  ax,$4f07;
   xor  bx,bx
   mov  cx,x
   mov  dx,y
   int  $10;
end;
{===}
procedure CloseVesaMode; assembler;
asm
   mov  ax,$4f03;   { standard way of reseting videocard }
   int  $10;
   mov  ax,$0003;   { standard way of reseting videocard }
   int  $10;
end;


begin

end.
