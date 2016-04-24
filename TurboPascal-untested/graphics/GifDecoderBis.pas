(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0201.PAS
  Description: GIF DECODER
  Author: ARNE DE BRUIJN
  Date: 11-22-95  13:32
*)


{Well, I've also written (rewritten from something in SWAG) a GIF decoder, but
converted it to ASM, so it's quite fast :-)I know GIF should be ignored, but I
wanted to write an asm version, after understanding the LZW algorithm, to see
how fast it could be (however it isn't much optimized). }

=== UNGIF.PAS
{ Decode a standard 320x200, non interlaced, no local color map GIF }
{ Arne de Bruijn, 1995, PD }
{$G+}
const MaxBufSize=32768;
var
 H:file;
 BufPtr,CPtr:pointer; BufEnd:word; { Read data pointers }
 WasLastBlock:boolean;
 MYBuf,MBPtr:pointer; MBEnd:word;  { Unblocked data pointers }

procedure ReadBuf;
{ Read from file into BufPtr and set CPtr the begin buffer, and BufEnd to end
}var
 BufSize:word;
begin
 CPtr:=BufPtr;
 BlockRead(H,BufPtr^,MaxBufSize,BufSize);
 BufEnd:=word(BufPtr)+BufSize;
 WasLastBlock:=BufSize<MaxBufSize;
end;

procedure UnBlock;
{ Convert <1 byte blocklen> <block> stream in CPtr-BufEnd to }
{ 'normal' stream in MyBuf }
const
 InBlockLast:byte=0;
var
 InBlock:word;
begin
 InBlock:=InBlockLast;
 InBlockLast:=0;
 MBPtr:=MyBuf;
 repeat
  if word(CPtr)+InBlock>BufEnd then
   begin
    InBlockLast:=InBlock;
    InBlock:=BufEnd-word(CPtr);
    Dec(InBlockLast,InBlock);
   end;
  Move(CPtr^,MBPtr^,InBlock);
  Inc(word(CPtr),InBlock); Inc(word(MBPtr),InBlock);
  InBlock:=0;
  if word(CPtr)<BufEnd then
   begin
    InBlock:=byte(CPtr^); Inc(word(CPtr));
   end;
 until (InBlock=0) and (word(CPtr)=BufEnd);
 MBEnd:=word(MBPtr);
 MBPtr:=MyBuf;
end;

procedure DecodeGIF(XOff,YOff,XLen,YLen:word; IBits:byte);
{ XOff,YOff,XLen,YLen ignored }
var
 MaxCode,OldCode,FirstItem,FreeItem,InCode,LastCode:word;
 StartCodeSize,CodeSize:byte;
 PixelBuf:array[0..1023] of byte;
 HashVal:array[0..4095] of byte;
 HashPrev:array[0..4095] of word;
 VioP:pointer;
 MBitMask:byte; MMBPtr:pointer; MMBEnd:word;
 L:longint;
begin
 StartCodeSize:=byte(CPtr^); Inc(word(CPtr));
 FirstItem:=1 shl StartCodeSize; Inc(StartCodeSize);
 GetMem(MyBuf,MaxBufSize); UnBlock;
 { Copy vars to local vars, so they can be accessed if ds is modified }
 LastCode:=0; VioP:=ptr($a000,0); MBitMask:=0; MMBPtr:=MBPtr; MMBEnd:=MBEnd;
 asm
  push ds
  push ss; pop es;
 @DoClr:
  mov cl,StartCodeSize   { Initialize vars }
  mov [CodeSize],cl; mov ax,1; shl ax,cl; mov [MaxCode],ax
  mov ax,[FirstItem]; add ax,2; mov [FreeItem],ax
  mov [OldCode],-1
 @LoopIt:                { Start loop }
  lds si,MMBPtr
  lea di,PixelBuf
  mov ax,[si]; mov dx,[si+2]
 @ReLdCont:
  mov cl,[MBitMask]      { Get CodeSize bits }
  mov bx,-1; shr bx,cl; shr ax,cl; not bx
  ror dx,cl; mov ch,CodeSize
  and bx,dx; or ax,bx
  xor bx,bx; add cl,ch; mov bl,cl; and cl,7; shr bx,3; add si,bx
  cmp si,[MMBEnd]; jae @Reload   { Buffer empty? Yes -> Reload }
  mov word ptr [MMBPtr],si; mov [MBitMask],cl
  mov cl,ch; mov bx,1; shl bx,cl; dec bx; and ax,bx
  mov cx,[FirstItem]     { Is it a clear code }
  sub cx,ax; je @DoClr   { Yes -> Initialize vars }
  inc cx; je @End        { Is it an end code (=clear code +1) ?  Yes -> End}
  mov [InCode],ax
  cmp ax,[FreeItem]      { Is it an unknown code ? }
  jb @Known
  mov ax,[OldCode]       { Append last code to output, and use prev code }
  mov cl,byte ptr [LastCode]
  mov es:[di],cl; inc di
 @Known:
  mov si,ax
 @ScanCode:              { Scan through codes loop }
  cmp si,[FirstItem]     { Is it a normal code? (= 1 output byte) }
  jb @EndPut             { Yes -> end loop }
  cmp si,[FreeItem]      { Is it an unknown code? }
  jae @Abort             { Yes -> abort }
  mov al,byte ptr [HashVal+si]
  mov es:[di],al; inc di
  shl si,1; mov si,word ptr [HashPrev+si]
  jmp @ScanCode
 @EndPut:
  mov ax,si; mov [LastCode],ax
  mov es:[di],al; inc di
  cmp byte ptr [OldCode+1],255; je @SkipStore
  mov si,[FreeItem];
  cmp si,4095; ja @SkipStore
  mov byte ptr [HashVal+si],al
  mov ax,[OldCode]
  mov bx,si; shl si,1; mov word ptr [HashPrev+si],ax
  inc bx; mov [FreeItem],bx
 @SkipStore:             { Check if codesize must be incremented }
  cmp bx,[MaxCode]; jb @NoNewCode
  cmp [CodeSize],12; jae @NoNewCode
  inc [CodeSize]; shl [MaxCode],1
 @NoNewCode:
  mov ax,[InCode]; mov [OldCode],ax
  lea cx,PixelBuf        { Write stored output to screen }
  neg cx; add cx,di
  lds si,VioP
 @PutIt:
  dec di                 { Output stored reversed }
  mov al,es:[di]; mov [si],al
  inc si; dec cx
  jnz @PutIt
  mov word ptr [VioP],si
  jmp @LoopIt
 @Abort:                 { Labels here to allow short jumps }
 @End:
  jmp @REnd
 @Reload:
  mov si,word ptr [MMBPtr]; mov bx,[MMBEnd]; sub bx,si
  mov ax,[si]; add si,2
  mov word ptr [L],ax    { Save last 4 bytes of buffer }
  mov ax,[si]; mov word ptr [L+2],ax
  pop ds
  cmp [WasLastBlock],0   { Already at eof? }
  jne @AbortNoPop        { Yes -> Abort }
  push bx
  call ReadBuf
  call Unblock
  mov ax,[MBEnd]; mov [MMBEnd],ax
  mov si,word ptr [MBPtr]
  pop bx
  push ds
  mov ds,word ptr [MMBPtr+2]
  push ss; pop es        { Overwrite temp buf (L) with new values }
  lea di,L               { at the right place }
  add di,bx; mov ax,si; sub ax,bx; mov cx,4; sub cx,bx
  cld;  rep movsb
  mov si,ax              { Initialize vars for @ReLDCont }
  lea di,PixelBuf
  mov ax,word ptr [L]; mov dx,word ptr [L+2]
  jmp @ReLDCont
 @REnd:
  pop ds
 @AbortNoPop:
 end;
 FreeMem(MyBuf,MaxBufSize);
end;

type
 TGifID=array[0..5] of char;
 TGifScrDesc=record ScrWidth,ScrHeight:word; Misc,Background,Zero:byte; end;
const GifID:TGifID='GIF87a';
var
 IBits,I,Misc:byte;
 IWidth,IHeight,IColors:word; XOff,YOff,XLen,YLen:word;
 GifPal:pointer;
begin
 if ParamCount=0 then begin WriteLn('Specify filename!'); Halt(1); end;
 assign(H,ParamStr(1)); reset(H,1);
 if IOResult<>0 then begin WriteLn('Open error'); Halt; end;
 GetMem(BufPtr,MaxBufSize); ReadBuf;
 if TGifID(BufPtr^)<>GifID then begin WriteLn('Bad image!'); Halt; end;
 Inc(word(CPtr),SizeOf(TGifID));
 IWidth:=TGifScrDesc(CPtr^).ScrWidth; IHeight:=TGifScrDesc(CPtr^).ScrHeight;
 IBits:=TGifScrDesc(CPtr^).Misc and 7+1; IColors:=1 shl IBits;
 IWidth:=TGifScrDesc(CPtr^).ScrWidth;
 if TGifScrDesc(CPtr^).Misc and 128<>128 then
  begin WriteLn('No GCT in GIF!'); Halt; end;
 Inc(word(CPtr),SizeOf(TGifScrDesc));
 asm
  mov ax,13h; int 10h  { Enter graphics mode }
  cld                  
  push ds
  mov ax,IColors; mov cx,ax; add ax,ax; add cx,ax  { cx:=IColors*3 }
  lds si,CPtr
  mov dx,3c8h; xor al,al; out dx,al; inc dx        { Set port, start color }
 @AdjCol: lodsb; shr al,2; out dx,al; loop @AdjCol { Set palette }
  pop ds
 end;
 Inc(word(CPtr),IColors*3);
 repeat
  I:=byte(CPtr^); Inc(word(CPtr));
  if I=44 then begin
    XOff:=word(CPtr^);Inc(word(CPtr),2); YOff:=word(CPtr^);Inc(word(CPtr),2);
    XLen:=word(CPtr^);Inc(word(CPtr),2); YLen:=word(CPtr^);Inc(word(CPtr),2);
    Misc:=byte(CPtr^);Inc(word(CPtr),1);
    DecodeGIF(XOff,YOff,XLen,YLen,IBits);
   end;
 until (I<>44) or (word(CPtr)>=BufEnd);
 Close(H);
 FreeMem(BufPtr,MaxBufSize);
 asm mov ah,0; int 16h; end; { Wait for key }
 asm mov ax,3; int 10h; end; { Set text mode }
end.

