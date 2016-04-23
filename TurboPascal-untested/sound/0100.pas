
{$IFNDEF DPMI}
'This program run only in DOS Protected Mode (Compile - Target = Protected)!'
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
uses crt, dos, winapi; (* WINAPI =3D DPMI Memory Unit for MS-DOS *)
type str70=3Dstring[70];
const sbirq:byte=3D$7;
      sbdma:byte=3D1;
      sbport:word=3D$220;
      sb:boolean=3Dfalse; (* Is there a soundcard? *)

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

type pt=3Drecord     (* A simple way to adress pointers *)
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
const dma_page:array[0..3] of byte=3D($87,$83,$81,$81);
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
     ready:=3Dtrue;
     if(lastone)then begin playing:=3Dfalse;ready:=3Dtrue;exit;end;
     (* If we have played the last block, exiting procedure *)
     if(cbloc<nbbloc)then t_w:=3D32000
     else begin t_w:=3Dsize mod 32000;lastone:=3Dtrue;end;
     if(t_w=3D0)then t_w:=3D32000;
     (* t_w is size of the next block *)
     inc(cbloc);Move(buff[cbloc]^,blk1^,t_w);
     SendBlock(t_w);
     nbloc:=3Dtrue;
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
   port[sbport+$c]:=3Dvalue;
   *)
end;


Function InitSb:boolean;
begin
     AllocateSbMem;
     getintvec($8+sbirq,oldirq); (* Saving the old interrupt vector *)
     (* Reset the DSP *)
     port[sbport+$6]:=3D1;
     for t_b:=3D1 to 100 do begin end;
     port[sbport+$6]:=3D0;

     (* Waiting until DSP ready *)
     for t_b:=3D1 to 100 do begin
     value:=3Dport[sbport+$E];value:=3Dport[sbport+$A];if(value=3D$AA)then=
 break;end;

     (* DSP never ready? May be bad port! *)
     ready:=3Dvalue=3D$AA;initsb:=3Dready;wasinit:=3Dtrue;
     if(ready)then setintvec($8+sbirq,addr(newsbirq));
     irqmsk :=3D 1 shl sbirq;
     port[$21] :=3D port[$21] and not irqmsk;
end;

Procedure SendBlock(size:word); (* Send blk1 to the SB card, via DMA *)
var seg_,ofs_:word;
begin
     sndhdl:=3DGetSelectorBase(seg(blk1^)); (* Physical adresse *)
     seg_:=3Dpt(sndhdl).sg; (* Computing segment and offset for the DMA *)
     ofs_:=3Dpt(sndhdl).ofs;

     ASM
     mov al,ready
     or al,al
     jz @fin

     mov dx,0Ah  (* Sending Blk1 to the DMA *)
     mov al,sbdma  (* Pascal corresponding code: *)
     add al,4      (* port[$0A]:=3Dsbdma+4 *)
     out dx,al

     add dx,2      (* port[$0C]:=3Dsbdma+4 *)
     xor al,al
     out dx,al

     dec dx        (* port[$0B]:=3Dsbdma+$48 *)
     mov al,sbdma
     add al,48h
     out dx,al

     xor dx,dx     (* port[sbdma*2]:=3Dlo(ofs_) *)
     mov ax,ofs_
     mov dl,sbdma
     shl dl,1
     out dx,al

     mov al,ah     (* port[sbdma*2]:=3Dhi(ofs_) *)
     out dx,al

     inc dx        (* port[sbdma*2+1]:=3Dlo(size) *)
     mov ax,size
     dec ax
     mov cx,ax
     out dx,al

     mov al,ah     (* port[sbdma*2+1]:=3Dhi(size) *)
     out dx,al

     xor bx,bx     (* portw[sma_page[sbdma]]:=3Dseg_ *)
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
     nbbloc:=3D0;
     (* Openning file *)
     assign(f,n+'.voc');size:=3D0;reset(f,1);
     seek(f,26);
     (* Finding first block *)
     repeat
     blockread(f,value,1);
     until (value=3D1);
     (* Reading and computing sample rate *)
     seek(f,filepos(f)+3);blockread(f,value,1);
     sndhdl:=3Dround(-1000000/(longint(value)-256));
     vocsample:=3Dsndhdl;
     (* Loading VOC to memory and allocating note that with DPMI we can=
 acces
        all the memory with getmem *)
     while not(eof(f)) do begin
     inc(nbbloc);getmem(buff[nbbloc],32000);
     blockread(f,buff[nbbloc]^,32000,t_w);
     size:=3Dsize+t_w;
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
     lastone:=3Dfalse;ready:=3Dtrue;playing:=3Dtrue;
     cbloc:=3D1;if(nbbloc<1)then exit;
     (* Only one block ??? *)
     if(nbbloc>1)then t_w:=3D32000 else t_w:=3Dsize;
     (* Moving VOC to sound buffer *)
     Move(buff[cbloc]^,blk1^,t_w);
     if(cbloc=3Dnbbloc)then lastone:=3Dtrue;
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
     nbbloc:=3D0;
     ready:=3Dtrue;playing:=3Dfalse;
end;

Procedure RestoreSb; (* Restore SB IRQ *)
begin
     StopPlay;
     port[sbport+$6]:=3D1;
     for t_b:=3D1 to 100 do port[sbport+$6]:=3D0;
     for t_b:=3D1 to 100 do begin
     value:=3Dport[sbport+$E];value:=3Dport[sbport+$A];if(value=3D$AA)then=
 break;end;
     setintvec($8+sbirq,oldirq);
    =
 globaldosfree(seg(blk1^));wasinit:=3Dfalse;playing:=3Dfalse;paused:=3Dfalse=
;ready:=3Dfalse;
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
   bTC  :=3D Byte ( 256 - ( ( 1000000 + ( sr div 2 ) ) div sr ) );
   value:=3D$40;
   WDSP;value:=3Dbtc;WDSP;
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
    seg_,ofs_:word;
begin
     _t_l:=3DGlobalDosAlloc(32000);
     _t_w:=3D_t_l and $0FFFF;
     blk1:=3Dptr(_t_w,0);
     sndhdl:=3DGetSelectorBase(seg(blk1^));
     seg_:=3Dpt(sndhdl).sg;
     ofs_:=3Dpt(sndhdl).ofs;
     if(ofs_>32000)then begin
     GlobalDOSFree(_t_w);
     _t_l:=3DGlobalDosAlloc((65535-ofs_)+1000);
     _t_l:=3DGlobalDosAlloc(32000);
     _t_w:=3D_t_l and $0FFFF;
     blk1:=3Dptr(_t_w,0);
     sndhdl:=3DGetSelectorBase(seg(blk1^));
     seg_:=3Dpt(sndhdl).sg;
     ofs_:=3Dpt(sndhdl).ofs;
end;

begin
     ready:=3Dfalse;playing:=3Dfalse;paused:=3Dfalse;{xmshdl:=3D0;}nbloc:=3D=
false;
     wasinit:=3Dfalse;nbbloc:=3D0;cbloc:=3D0;
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