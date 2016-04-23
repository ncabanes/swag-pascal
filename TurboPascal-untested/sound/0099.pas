{
        There is two files, wich contains unit(s) and a demo program:
       One to play big vocs (bigger than 64 KB) on SoudnBlatser, without
drivers (SBXMS).
       Another to play same files in Protected Mode. (SBDPMI).
       I hope that you can include those files in the next update of your SWAGS.

Greatings,
Gael of Kilobug.
}

{$IFDEF DPMI}
'This program run only in DOS Real Mode (Compile - Target - Real)!'
{$ENDIF}
{$IFDEF WINDOWS}
'This is a DOS program (Compile - Target - Real)!'
{$ENDIF}
Unit sbxms;
(*
  A simple unit to play VOC files via DMA using XMS memory.

  WARNING! This file can be compile only by Pascal 6.00 or higher in DOS
  Real Mode. It don't work in any protected mode!

  Remember: Pascal do NOT free XMS memory when halted program.
            Please don't forget the "StopPlay" procedure.

  Donnated by LE MIGNOT Ga=89l to SWAGS and the Public Domain.

  For any questions, bugs or commenatry: kilobug@mail.planetepc.fr

  Great thanks to: PC-Interdit (c) Micro Application, 1995
                   DOS Interrupt List, by Ralf Brown

  For informations please see SBDPMI, I didn't retype all commentaries.

  There is three files: SBXMS unit         line 1
                        XMS unit           line 350
                        And a demo program line 521
*)


Interface
uses crt, dos, xms; (* Please see xms unit below *)
type str70=string[70];
const sbirq:byte=$7;
      sbdma:byte=1;
      sbport:word=$220;
      sb:boolean=false; (* Is there a soundcard? *)

var t_w:word;        (* Simple tempory variables *)
    t_b:byte;
    t_l:longint;

Function InitSb:boolean;  (* Allocate memory, reset DSP, set the IRQ. *)
Procedure SendBlock(seg_,ofs_,size:word);
Procedure LoadVoc(n:str70); (* Load a VOC file into memory *)
Procedure PlayVoc(n:str70); (* Load a Voc and then play it *)
Procedure PlayLoadedVoc; (* Play the loaded VOC *)
Procedure PausePlay; (* Pause the VOC Playing *)
Procedure ContinuePlay; (* Contiune playing after a pause *)
Procedure StopPlay; (* Stop VOC Playing, free memory and restore sb IRQ *)
Procedure RestoreSb; (* Restore SB IRQ and reset the DSP *)
Procedure SetSample(sr:word); (* Set the sampling rate (legal values: 4000 -=
 44000) *)
Procedure SpeakOn;
Procedure SpeakOff;
Procedure AllocateSbMem; (* Allocate memory, called by INITSB *)

type pt=record
     ofs,sg:word;
     end;

var blk1:pointer;
    xmspos,xmssize:longint;
    xmshdl:word;
    wasinit,nbloc,ready,playing,paused,lastone:boolean;
    oldirq:pointer;
    value:byte;
    irqmsk:byte;
    vocsample:word;

Implementation
const dma_page:array[0..3] of byte=($87,$83,$81,$81);
var   f:file;

Procedure NewSBIrq;interrupt;
begin
     ASM
     mov dx,20h
     mov ax,dx
     out dx,al
     mov cl,100
     mov bx,sbport
     add bx,0Ah
     @bcl:
     dec cl
     mov dx,bx
     in al,dx
     add dx,4
     in al,dx
     or cl,cl
     jz @finb
     cmp al,0AAh
     jnz @bcl
     @finb:
     end;
     ready:=true;if(lastone)then begin
 playing:=false;ready:=true;exit;end;
     if(xmspos+32000<xmssize)then t_w:=32000 else t_w:=xmssize-xmspos;
     if(xmspos= xmssize)or(t_w<32000)then lastone:= true;
     MoveFromXms(xmshdl,blk1^,xmspos,t_w);xmspos:= xmspos+t_w;
     SendBlock(seg(blk1^),ofs(blk1^),t_w);
     if(lastone)then playing:= false else begin
     end;
     nbloc:= true;
end;

Procedure WDsp;assembler;
ASM
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,value
   out dx,al
end;


Function InitSb:boolean;
begin
     AllocateSbMem;
     getintvec($8+sbirq,oldirq);
     port[sbport+$6]:= 1;
     for t_b:= 1 to 100 do begin end;
     port[sbport+$6]:= 0;

     for t_b:= 1 to 100 do begin
     value:= port[sbport+$E];value:= port[sbport+$A];if(value= $AA)then=
 break;end;

     ready:= value= $AA;initsb:= ready;wasinit:= true;
     if(ready)then setintvec($8+sbirq,addr(newsbirq));
     irqmsk :=  1 shl sbirq;
     port[$21] :=  port[$21] and not irqmsk;
end;

Procedure SendBlock(seg_,ofs_,size:word);
begin
     t_l:= seg_; (* Computing paged adress *)
     t_l :=  t_l*16+ofs_;
     seg_:= pt(t_l).sg;ofs_:= pt(t_l).ofs;
     ASM
     mov al,ready
     or al,al
     jz @fin
     mov dx,0Ah
     mov al,sbdma
     add al,4
     out dx,al

     mov dx,0Ch
     xor al,al
     out dx,al

     mov dx,0Bh
     mov al,sbdma
     add al,48h
     out dx,al

     xor dx,dx
     mov ax,ofs_
     mov dl,sbdma
     shl dl,1
     out dx,al

     mov al,ah
     out dx,al

     inc dx
     mov ax,size
     dec ax
     mov cx,ax
     out dx,al

     mov al,ah
     out dx,al

     xor bx,bx
     mov bl,sbdma
     xor dx,dx
     mov dl,byte ptr dma_page[bx]
     mov ax,seg_
     out dx,ax

     mov dx,sbport
     add dx,0ch
     @bcl1:
     in al,dx
     and al,80h
     jnz @bcl1
     mov al,14h
     out dx,al
     @bcl2:
     in al,dx
     and al,80h
     jnz @bcl2
     mov ax,cx
     out dx,al
     @bcl3:
     in al,dx
     and al,80h
     jnz @bcl3
     mov al,ch
     out dx,al

     mov dx,0Ah
     mov al,sbdma
     out dx,al

     mov playing,1
     mov ready,0
     @fin:
     end;
end;

Procedure LoadVoc(n:str70);
begin
     if(xmshdl<>0)then begin FreeXMS(xmshdl);xmshdl:= 0;end;
     assign(f,n+'.voc');xmssize:= 0;reset(f,1);
     seek(f,26);
     repeat
     blockread(f,value,1);
     until (value= 1);
     seek(f,filepos(f)+3);blockread(f,value,1);
     xmspos:= round(-1000000/(longint(value)-256));
     vocsample:= xmspos;
     xmshdl:= GetXms(filesize(f) div 1024+1);
     while not(eof(f)) do begin
     blockread(f,blk1^,32000,t_w);t_w:= t_w+byte(odd(t_w));
     moveToXms(blk1^,xmshdl,xmssize,t_w);
     xmssize:= xmssize+t_w;
     end;xmspos:= 0;close(f);
end;

Procedure PlayVoc(n:str70);
begin
     LoadVoc(n);PlayLoadedVoc;
end;

Procedure PlayLoadedVoc;
begin
     lastone:= false;ready:= true;playing:= true;
     xmspos:= 0;
     if(xmspos+32000<xmssize)then t_w:= 32000 else t_w:= xmssize-xmspos;
     MoveFromXms(xmshdl,blk1^,xmspos,t_w);xmspos:= xmspos+t_w;
     if(xmspos= xmssize)or(t_w<32000)then lastone:= true;
     SetSample(vocsample);
     SendBlock(seg(blk1^),ofs(blk1^),t_w);
end;

Procedure PausePlay;assembler;
ASM
   mov al,playing
   or al,al
   jz @fin
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,0D0h
   out dx,al
   mov paused,1
   @fin:
end;

Procedure StopPlay;
begin
     if(not(wasinit))then exit;
     PausePlay;if(xmshdl<>0)then FreeXMS(xmshdl);xmshdl:= 0;
     port[sbport+$6]:= 1;
     for t_b:= 1 to 100 do port[sbport+$6]:= 0;
     for t_b:= 1 to 100 do begin
     value:= port[sbport+$E];value:= port[sbport+$A];if(value= $AA)then=
 break;end;
     RestoreSb;wasinit:= false;ready:= false;
end;

Procedure RestoreSb;
begin
     setintvec($8+sbirq,oldirq);
     playing:= false;paused:= false;ready:= false;wasinit:= false;
end;

Procedure ContinuePlay;assembler;
ASM
   mov al,playing
   or al,al
   jz @fin
   mov al,paused
   or al,al
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,0D4h
   out dx,al
   mov paused,0
   @fin:
end;

Procedure SetSample(sr:word);
var btc:byte;
begin
   bTC  :=  Byte ( 256 - ( ( 1000000 + ( sr div 2 ) ) div sr ) );
   value:= $40;
   WDSP;value:= btc;WDSP;
end;

Procedure SpeakOn;assembler;
ASM
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,0D1h
   out dx,al
end;

Procedure SpeakOff;assembler;
ASM
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,0D3h
   out dx,al
end;

Procedure AllocateSbMem;
var p:pointer;
begin
     t_w:= 65535;
     getmem(blk1,32000);
     repeat
     freemem(blk1,32000);
     inc(t_w);if(t_w<>0)then getmem(p,t_w);
     getmem(blk1,32000);
     t_l:= seg(blk1^);
     t_l :=  t_l*16+ofs(blk1^);
     if(t_w<>0)then freemem(p,t_w);
     until(pt(t_l).ofs<32000);
end;

begin
     ready:= false;playing:= false;paused:= false;xmshdl:= 0;nbloc:= fa=
lse;
     wasinit:= false;
end.

(* XMS Unit *)

Unit xms;
(*
  Simple xms unit for SBXMS.

  Donnated by LE MIGNOT Ga=89l to SWAGS and the Public Domain.

  For any questions, bugs or commenatry: kilobug@mail.planetepc.fr

  Special thanks: DOS Interrupt List by Ralf Brown.
*)
Interface
uses crt, dos;
Function XMSFree:word;  (* Return the number of KB of free xms *)
Function GetXMS(size:word):word; (* Allocate XMS Memory *)
Procedure FreeXMS(hdl:word); (* Free XMS Memory *)
Procedure MoveToXMS(var source;hdl:word;ofs_,size:longint);
Procedure MoveFromXMS(hdl:word;var dest;ofs_,size:longint);
Procedure MoveInXMS(hdls,hdlt:word;ofss,ofsd,size:longint);

var IsXms:boolean;
    version:word;
    xmserr:byte;

Implementation
type xmpart= record
                  size:longint;
                  shdl:word;
                  sof:longint;
                  thdl:word;
                  tof:longint;
            end;
var xmsdrva:pointer;
    segx,ofsx:word;
    xmpar:xmpart;

Procedure InitXmsUnit;assembler;
ASM
mov ax,4300h
int 2fh
cmp al,80h
jnz @error
mov ax,4310h
int 2fh
mov segx,es
mov ofsx,bx
mov isxms,1
jmp @fin
@error:
mov isxms,0
@fin:
end;

{$F+}
Procedure GetVersion;assembler;
ASM
     xor ah,ah
     call xmsdrva
     mov version,ax
end;

Function XMSFree:word;assembler;
ASM
   mov ah,08h
   xor bx,bx
   call xmsdrva
   mov ax,dx
   mov xmserr,bl
end;

Function GetXMS(size:word):word;assembler;
ASM
   mov ah,09h
   mov dx,size
   call xmsdrva
   or ax,ax
   jz @error
   mov xmserr,0
   mov ax,dx
   jmp @fin
   @error:
   mov xmserr,bl
   xor ax,ax
   @fin:
end;

Procedure FreeXMS(hdl:word);assembler;
ASM
   mov ah,0Ah
   mov dx,hdl
   call xmsdrva
   or ax,ax
   jz @error
   mov xmserr,0
   jmp @fin
   @error:
   mov xmserr,bl
   @fin:
end;

Procedure MoveInXMS(hdls,hdlt:word;ofss,ofsd,size:longint);
begin
     xmpar.size:= size;
     xmpar.shdl:= hdls;
     xmpar.sof:= ofss;
     xmpar.thdl:= hdlt;
     xmpar.tof:= ofsd;
     ASM
     mov ah,0Bh
     mov si,offset xmpar
     call xmsdrva
     or ax,ax
     jz @error
     mov xmserr,0
     jmp @fin
     @error:
     mov xmserr,bl
     @fin:
     end;
end;

Procedure MoveToXMS(var source;hdl:word;ofs_,size:longint);
begin
     xmpar.size:= size;
     xmpar.shdl:= 0;
     xmpar.sof:= longint(ptr(seg(source),ofs(source)));
     xmpar.thdl:= hdl;
     xmpar.tof:= ofs_;
     ASM
     mov ah,0Bh
     mov si,offset xmpar
     call xmsdrva
     or ax,ax
     jz @error
     mov xmserr,0
     jmp @fin
     @error:
     mov xmserr,bl
     @fin:
     end;
end;

Procedure MoveFromXMS(hdl:word;var dest;ofs_,size:longint);
begin
     xmpar.size:= size;
     xmpar.shdl:= hdl;
     xmpar.sof:= ofs_;
     xmpar.thdl:= 0;
     xmpar.tof:= longint(ptr(seg(dest),ofs(dest)));
     ASM
     mov ah,0Bh
     mov si,offset xmpar
     call xmsdrva
     or ax,ax
     jz @error
     mov xmserr,0
     jmp @fin
     @error:
     mov xmserr,bl
     @fin:
     end;
end;

{$F-}

begin
     InitXmsUnit;if(isxms)then begin xmsdrva:= ptr(segx,ofsx);
     GetVersion;end;
end.

(* A simple program to play vocs with this unit *)

uses crt, sbxms;

begin
     writeln('XMS Voc-Player, by The Kilogub Team, 1996');
     writeln;
     InitSb;
     LoadVoc(paramstr(1));writeln('Voc loaded. Press any key to exit.');
     repeat
     PlayLoadedVoc;
     repeat until (ready)or(keypressed);
     if(ready)then writeln('Voc played!');
     until keypressed;
     StopPlay;
     while keypressed do readkey;
end.

--=====================_836029223==_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="SBDPMI.PAS"

{$IFNDEF DPMI}
'This program run only in DOS Protected Mode (Compile - Target -=
 Protected)!'
{$ENDIF}
Unit sbdpmi; {SBDPMI Unit, by GLM, release 1.1}
(*
  A simple unit to play VOC files via DMA in Protected mode.

  WARNING! This file can be compile only by Borland Pascal 7.00 in DOS
  Protected Mode. It needs the RTM.EXE and DPMI16BI.OVL!

  Note that this program use a buffer. That's not for better quality but=
 only
  because the DMA can't access memory above 640 KB. We must allocate 32 KB=
 of
  standard DOS memory and use this buffer.

  Donnated by LE MIGNOT Ga=89l to SWAGS and the Public Domain.

  For any questions, bugs or commenatry: kilobug@mail.planetepc.fr

  Great thanks to: PC-Interdit (c) Micro Application, 1995

  There is two files:   SBSPMI unit        line 1
                        And a demo program line 378
*)

Interface
uses crt, dos, winapi; (* WINAPI =  DPMI Memory Unit for MS-DOS *)
type str70= string[70];
const sbirq:byte= $7;
      sbdma:byte= 1;
      sbport:word= $220;
      sb:boolean= false; (* Is there a soundcard? *)

var t_w:word;        (* Simple tempory variables *)
    t_b:byte;
    t_l:longint;

Function InitSb:boolean;  (* Allocate memory, reset DSP, set the IRQ. *)
Procedure SendBlock(size:word); (* Send the blk1 block to the DMA. *)
Procedure LoadVoc(n:str70); (* Load a VOC file into memory *)
Procedure PlayVoc(n:str70); (* Load a Voc and then play it *)
Procedure PlayLoadedVoc; (* Play the loaded VOC *)
Procedure PausePlay; (* Pause the VOC Playing *)
Procedure ContinuePlay; (* Contiune playing after a pause *)
Procedure StopPlay; (* Stop VOC Playing and free VOC memory *)
Procedure RestoreSb; (* Release all memory, restore SB IRQ and reset the DSP=
 *)
Procedure SetSample(sr:word); (* Set the sampling rate (legal values: 4000 -=
 44000) *)
Procedure SpeakOn;
Procedure SpeakOff;
Procedure AllocateSbMem; (* Allocate memory, called by INITSB *)

type pt= record     (* A simple way to adress pointers *)
     ofs,sg:word;
     end;

var blk1:pointer;  (* Memory block to send to the DMA *)
    size:longint;  (* Size of VOC File *)
    cbloc,nbbloc:byte; (* Number of blocks in VOC File *)
    buff:array[1..200]of pointer; (* Buffer to load VOC. Limited to 6 MO *)
    wasinit, (* Is the soundcard initialised ? *)
    nbloc,
    ready, (* Is the soundcard ready? (false while playing) *)
    playing, (* Is the soundcard playing anything? *)
    paused, (* Is the VOC paused? *)
    lastone (* Are we sending the lastest block? *) :boolean;
    oldirq:pointer; (* Save the old IRQ value *)
    value:byte; (* Wich value to send to the DSP? *)
    irqmsk:byte;
    vocsample:word; (* Sample rate of the vco *)
    sndhdl:longint; (* Physical adress of BLK1 *)

Implementation
const dma_page:array[0..3] of byte= ($87,$83,$81,$81);
var   f:file;

Procedure NewSBIrq;interrupt; (* This will be called each time the SB has
                                      played a block *)
begin
     ASM  (* Preparing the sound card *)
     mov dx,20h
     mov ax,dx
     out dx,al
     mov cl,100
     mov bx,sbport
     add bx,0Ah
     @bcl:
     dec cl
     mov dx,bx
     in al,dx
     add dx,4
     in al,dx
     or cl,cl
     jz @finb
     cmp al,0AAh
     jnz @bcl
     @finb:
     end;
     ready:= true;
     if(lastone)then begin playing:= false;ready:= true;exit;end;
     (* If we have played the last block, exiting procedure *)
     if(cbloc<nbbloc)then t_w:= 32000
     else begin t_w:= size mod 32000;lastone:= true;end;
     if(t_w= 0)then t_w:= 32000;
     (* t_w is size of the next block *)
     inc(cbloc);Move(buff[cbloc]^,blk1^,t_w);
     SendBlock(t_w);
     nbloc:= true;
end;

Procedure WDsp;assembler;  (* This procedure write "value" to the DSP *)
ASM
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,value
   out dx,al
   (* Equivalent to Pascal code:
   repeat until (port[sbport+$C]<>$80);
   port[sbport+$c]:= value;
   *)
end;


Function InitSb:boolean;
begin
     AllocateSbMem;
     getintvec($8+sbirq,oldirq); (* Saving the old interrupt vector *)
     (* Reset the DSP *)
     port[sbport+$6]:= 1;
     for t_b:= 1 to 100 do begin end;
     port[sbport+$6]:= 0;

     (* Waiting until DSP ready *)
     for t_b:= 1 to 100 do begin
     value:= port[sbport+$E];value:= port[sbport+$A];if(value= $AA)then=
 break;end;

     (* DSP never ready? May be bad port! *)
     ready:= value= $AA;initsb:= ready;wasinit:= true;
     if(ready)then setintvec($8+sbirq,addr(newsbirq));
     irqmsk :=  1 shl sbirq;
     port[$21] :=  port[$21] and not irqmsk;
end;

Procedure SendBlock(size:word); (* Send blk1 to the SB card, via DMA *)
var seg_,ofs_:word;
begin
     sndhdl:= GetSelectorBase(seg(blk1^)); (* Physical adresse *)
     seg_:= pt(sndhdl).sg; (* Computing segment and offset for the DMA *)
     ofs_:= pt(sndhdl).ofs;

     ASM
     mov al,ready
     or al,al
     jz @fin

     mov dx,0Ah  (* Sending Blk1 to the DMA *)
     mov al,sbdma  (* Pascal corresponding code: *)
     add al,4      (* port[$0A]:= sbdma+4 *)
     out dx,al

     add dx,2      (* port[$0C]:= sbdma+4 *)
     xor al,al
     out dx,al

     dec dx        (* port[$0B]:= sbdma+$48 *)
     mov al,sbdma
     add al,48h
     out dx,al

     xor dx,dx     (* port[sbdma*2]:= lo(ofs_) *)
     mov ax,ofs_
     mov dl,sbdma
     shl dl,1
     out dx,al

     mov al,ah     (* port[sbdma*2]:= hi(ofs_) *)
     out dx,al

     inc dx        (* port[sbdma*2+1]:= lo(size) *)
     mov ax,size
     dec ax
     mov cx,ax
     out dx,al

     mov al,ah     (* port[sbdma*2+1]:= hi(size) *)
     out dx,al

     xor bx,bx     (* portw[sma_page[sbdma]]:= seg_ *)
     mov bl,sbdma
     xor dx,dx
     mov dl,byte ptr dma_page[bx]
     mov ax,seg_
     out dx,ax

     mov dx,sbport {Envoie de la commande au DSP}
     add dx,0ch
     @bcl1:
     in al,dx
     and al,80h
     jnz @bcl1
     mov al,14h
     out dx,al
     @bcl2:
     in al,dx
     and al,80h
     jnz @bcl2
     mov ax,cx
     out dx,al
     @bcl3:
     in al,dx
     and al,80h
     jnz @bcl3
     mov al,ch
     out dx,al

     mov dx,0Ah
     mov al,sbdma
     out dx,al

     mov playing,1
     mov ready,0
     @fin:
     end;
end;

Procedure LoadVoc(n:str70);
begin
     (* Desalocating all memory *)
     while(nbbloc>0)do begin freemem(buff[nbbloc],32000);dec(nbbloc);end;
     nbbloc:= 0;
     (* Openning file *)
     assign(f,n+'.voc');size:= 0;reset(f,1);
     seek(f,26);
     (* Finding first block *)
     repeat
     blockread(f,value,1);
     until (value= 1);
     (* Reading and computing sample rate *)
     seek(f,filepos(f)+3);blockread(f,value,1);
     sndhdl:= round(-1000000/(longint(value)-256));
     vocsample:= sndhdl;
     (* Loading VOC to memory and allocating note that with DPMI we can=
 acces
        all the memory with getmem *)
     while not(eof(f)) do begin
     inc(nbbloc);getmem(buff[nbbloc],32000);
     blockread(f,buff[nbbloc]^,32000,t_w);
     size:= size+t_w;
     end;dec(nbbloc);
     (* And then close file. Voc is ready to be played. *)
     close(f);
end;

Procedure PlayVoc(n:str70);
begin
     (* You understand??? *)
     LoadVoc(n);PlayLoadedVoc;
end;

Procedure PlayLoadedVoc;
begin
     (* Initializing values *)
     lastone:= false;ready:= true;playing:= true;
     cbloc:= 1;if(nbbloc<1)then exit;
     (* Only one block ??? *)
     if(nbbloc>1)then t_w:= 32000 else t_w:= size;
     (* Moving VOC to sound buffer *)
     Move(buff[cbloc]^,blk1^,t_w);
     if(cbloc= nbbloc)then lastone:= true;
     SetSample(vocsample);
     SendBlock(t_w);
end;

Procedure PausePlay;assembler; (* Stop playing but keep the VOC in memory=
 and
                                  the current position *)
ASM
   mov al,playing
   or al,al
   jz @fin
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,0D0h
   out dx,al
   mov paused,1
   @fin:
end;

Procedure StopPlay; (* Stop playing, restore SB, disallocate memory *)
begin
     if(not(wasinit))then exit;
     PausePlay;
     while(nbbloc>0)do begin freemem(buff[nbbloc],32000);dec(nbbloc);end;
     nbbloc:= 0;
     ready:= true;playing:= false;
end;

Procedure RestoreSb; (* Restore SB IRQ *)
begin
     StopPlay;
     port[sbport+$6]:= 1;
     for t_b:= 1 to 100 do port[sbport+$6]:= 0;
     for t_b:= 1 to 100 do begin
     value:= port[sbport+$E];value:= port[sbport+$A];if(value= $AA)then=
 break;end;
     setintvec($8+sbirq,oldirq);
    =
 globaldosfree(seg(blk1^));wasinit:= false;playing:= false;paused:= false=
;ready:= false;
end;

Procedure ContinuePlay;assembler; (* Continue a VOC after PausePlay *)
ASM
   mov al,playing
   or al,al
   jz @fin
   mov al,paused
   or al,al
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,0D4h
   out dx,al
   mov paused,0
   @fin:
end;

Procedure SetSample(sr:word); (* Change the sampling rate.
                                 It normaly run with values lower than=
 22000,
                                 but should work with higher rate (up to=
 44000)
                               *)
var btc:byte;
begin
   bTC  :=  Byte ( 256 - ( ( 1000000 + ( sr div 2 ) ) div sr ) );
   value:= $40;
   WDSP;value:= btc;WDSP;
end;

Procedure SpeakOn;assembler; (* Turn on the sound output *)
ASM
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,0D1h
   out dx,al
end;

Procedure SpeakOff;assembler; (* Turn off the sound output *)
ASM
   mov dx,sbport
   add dx,0ch
   @bcl:
   in al,dx
   and al,80h
   jnz @bcl
   mov al,0D3h
   out dx,al
end;

Procedure AllocateSbMem; (* Allocate 32KB of memory below 640 KB*)
var _t_l:longint;
    _t_w:word;
begin
     _t_l:= GlobalDosAlloc(32000);
     _t_w:= _t_l and $0FFFF;
     blk1:= ptr(_t_w,0);
end;

begin
     ready:= false;playing:= false;paused:= false;{xmshdl:= 0;}nbloc:= =
false;
     wasinit:= false;nbbloc:= 0;cbloc:=0;
end.

(* A simple program to play vocs with this unit *)

uses crt, sbdpmi;

begin
     writeln('DPMI Voc-Player, by The Kilogub Team, 1996');
     writeln;
     InitSb;
     LoadVoc(paramstr(1));writeln('Voc loaded. Press any key to exit.');
     repeat
     PlayLoadedVoc;
     repeat until (ready)or(keypressed);
     if(ready)then writeln('Voc played!');
     until keypressed;
     StopPlay;
     while keypressed do readkey;
end.
