{

> Is there a way to play WAV files with TP7.0 for DOS (on SB) ?

I once posted my routine in the german PASCALecho.

Sblast... UNIT for digital Soundeffects in games by DMA and a complete test
of the SB-configs by Dirk Hoeschen (_aptain |-|eadcrash
}

UNIT SBlast;

interface
Uses Crt,Dos;

Const
   DMA_ADDX_REG  = $02;
   DMA_COUNT_REG = $03;
   DMA_MASK_REG  = $0A;
   DMA_MODE_REG  = $0B;
   DMA_FF_REG    = $0C;
   DMA_PAGE_REG  = $83;
   DMA_Mode      = $49;
   DMA_BufSize   = $1000-1;
   DMA_activ : Boolean=false;
   SbregDetected : Boolean = false;
   psound : Boolean = true;
   dsp_adr : word =$0;
   dsp_irq : byte =$0;
   DMA_CH  : byte =$1; {don't change it if you'r not shure}

 function  Detect_Reg_Sb : Boolean;
 { Find Sbadress! Adresse nachher in dsp_adr.
   false if no SBcard availiable}

 function  Reset_Sb : Boolean;

 Function  GetDSPversion: String;
 { Get Versionsnummer the Yamaha OPL}

 Procedure Find_DSP_Irq(Mode: Byte; VAR irq : byte);
 { If IRQ=0 then no interrupt was found.
   if Mode=1 FIND_IRQ only tests the Interrupt in IRQ}

 function  wr_dsp_adr : String; {writes the address on the screen}

 procedure wr_dsp(v : byte);
 function  Sbreadbyte : byte;
 procedure Sb_Befehl110h(v : byte);

 procedure Set_frequence(freq : Word);

 Procedure Lautsprecher_Ein;
 Procedure Lautsprecher_Aus;

 procedure Play_DMA(count : Word);
 Procedure Play_Wave(fname : pathstr);

 Procedure Stop_DMA;
 Procedure Continue_DMA;
 Procedure Stop_Playing;

implementation
Type
    Page = Array [0..64000] of byte;
    Page_point = ^Page;
    Wave_head = ReCord
         TypeID : Longint; {normally Riff}
         Length : Longint; {Length of file }
         WaveID : Array[0..3] of byte;{WAVE}
         fmtID  : Array[0..3] of byte;{fmt}
         CHlength : Longint;{Laenge des Chunks}
         Wformat : Word;{0=Left /1=Right /2 Stereo}
         Wchannels: Word;{# of channels 2=Stereo}
         Wrate : Longint;{frequence}
         Wbps  : Longint;{Bits per second}
         BytespSample : Word;
         BitspSample : Word;
         DataID : Array[0..3] of byte;{Data}
         Filler : Longint;
    end;

Var
   Tbuf, SbintSave : Pointer;
   Soundbuf : Page_point;
   Rem_size : Word;
   ppage, pofs :Word;
   frate : Word;
   IRQ_found: Boolean;

function Reset_Sb : Boolean;
const ready = $AA;
var ct,Stat : byte;
BEGIN
  port[dsp_adr+$6]:=1;
  delay(100);
  port[dsp_adr+$6]:=0;
  stat:=0;
  ct  :=0;
  while (stat <> ready) and (Ct< 100) do begin
   Stat:=port[dsp_adr+$E];
   Stat:=port[dsp_adr+$A];
   Inc(ct);
  end;
  Reset_Sb := (Stat = ready);
END;

function wr_dsp_adr : String;
BEGIN
  case dsp_adr of
    $210 : wr_dsp_adr := '210 Hex';
    $220 : wr_dsp_adr := '220 Hex';
    $230 : wr_dsp_adr := '230 Hex';
    $240 : wr_dsp_adr := '240 Hex';
    $250 : wr_dsp_adr := '250 Hex';
    $260 : wr_dsp_adr := '260 Hex';
    $270 : wr_dsp_adr := '270 Hex';
    $280 : wr_dsp_adr := '280 Hex';
  end;
END;

function Detect_Reg_Sb : Boolean;
var Port, Lst : Word;
BEGIN
  Detect_Reg_Sb := SBRegDetected;
  Port := $210;
  Lst := $280;
  while (not SBRegDetected) and (Port <= Lst) do begin
    Dsp_adr:=Port;
    SbRegDetected:= Reset_Sb;
    if not SBRegDetected then inc(Port,$10);
  end;
  Detect_Reg_Sb := SBRegDetected;
END;

procedure wr_dsp(v : byte);
BEGIN
  While port[dsp_adr+$c] >= 128 do;
  port[dsp_adr+$c] := v;
END;

function SbReadByte: Byte;
BEGIN
  While port[dsp_adr+$a] = $AA do;
  SbReadByte := port[dsp_adr+$a];
END;

procedure Sb_Befehl110h(v : byte);
BEGIN
  wr_dsp($10);
  wr_dsp(v);
END;

procedure Set_frequence(freq : Word);
var tc: byte;
BEGIN
  tc := trunc(256-(1000000/freq));
  {Die samplefrequenz berechnet sich aus
   256-10000000/Hz}
  wr_dsp($40); {40h set frequence}
  wr_dsp(tc);
END;

Procedure Lautsprecher_Ein;
BEGIN  wr_dsp($D1); END;

Procedure Lautsprecher_Aus;
BEGIN  wr_dsp($D3); END;

Procedure Stop_DMA;
BEGIN  wr_dsp($D0); END;

Procedure Continue_DMA;
BEGIN  wr_dsp($D4); END;

Function GetDSPversion: String;
var s : String[2];
    SbVersMaj : byte;
    SbVersMin : byte;
    SbVersStr : String[5];
BEGIN
  GetDSPVersion:=';-)';
  wr_dsp($E1);
  SbVersMaj := SbreadByte;
  SbVersMin := SbreadByte;
  Str(SbversMaj , SbVersStr);
  SbVersStr:= SbVersStr + '.';
  Str(SbversMin , s);
  If Sbversmin > 9 then
    SbVersStr:= SbVersStr + s
  else
    SbVersStr:= SbVersStr + '0' + s;
  GetDSPVersion:=SBversStr;
END;

Procedure Start_DMA_transfer(len : word);
{ Wie gesagt, hier wird der DMA-controller initialisiert
  und der Befehl $14=Play 8Bit uncompressed via DMA an
  die SB-karte gesendet. Sobald die laenge und die Adresse
  uebergeben ist, startet der Transfer. }
type pt = record
       ofs, sgm : Word;
    end;
var L : Longint;
    pn, ofs :Word;
    dummy: byte;
BEGIN
   dummy:=Port[DSP_adr+$0E];
   l := 16*longint(ppage)+pofs;
   pn := Pt(l).sgm; {Man beachte die Berechnung der Page}
   ofs := Pt(l).ofs;
   Port[DMA_MAsk_Reg]:=DMA_CH+4;
   Port[DMA_FF_Reg]:=0;
   Port[DMA_Mode_Reg]:=Dma_Mode;
   Port[DMA_ADDX_Reg]:=Lo(ofs);
   Port[DMA_ADDX_Reg]:=hi(ofs);
   Port[DMA_PAGE_Reg]:=pn;
   Port[DMA_COUNT_Reg]:=Lo(len);
   Port[DMA_COUNT_Reg]:=hi(len);
   Port[DMA_MAsk_Reg]:=DMA_CH; {DMA 1 freigeben};
   wr_dsp($14);
   wr_dsp(Lo(len));
   wr_dsp(hi(len));
END;

Procedure Stop_Playing;
begin
 if psound then begin
   Stop_DMA;
   Port[DMA_MAsk_Reg]:=DMA_CH+4;
   Port[$21]:=Port[$21] or (1 shl DSP_Irq);
   Port[$20]:=$20;
   SetIntVec($8+ DSP_Irq,SBIntSave);
 end;
end;

Procedure DummySBint ; Interrupt;
Begin
   IRQ_found:=True;
end;

Procedure Find_DSP_Irq(Mode: Byte; VAR irq : byte);
const possible_IRQs : Array[1..5] Of Byte = ($7,$5,$2,$3,$10); { Das System
dieser Routine ist einfach, aber auch nicht ganz  ungefaerlich. DummySBint wird
nacheinander in die moeglichen  Soundblasterinterrupts eingeklinkt. Dannach ein
kurzer DMA-  transfer gestartet. Wenn der IRQ stimmt, dann setzt der dummy
  interrupt ein flag.}
var c : byte;
BEGIN
  getmem(tbuf,100);
  Ppage:=seg(tBuf^);
  Pofs:=Ofs(tBuf^);
  Lautsprecher_Aus;
  Set_Frequence(1000);
  IRQ_found:=false;
  If mode=1 then Begin
      GetIntVec($8+Irq,SBIntSave);
      SetIntVec($8+IRQ,@DummySBInt);
      Port[$21]:=Port[$21] and not (1 shl IRQ);
      wr_dsp($D0);
      Start_DMA_transfer(20);
      Delay(200);
      Stop_Playing;
      Port[$21]:=Port[$21] or (1 shl IRQ);
      Port[$20]:=$20;
      SetIntVec($8+Irq,SBIntSave);
  end else begin
    c:=1;
    Repeat
      IRQ:=Possible_IRQs[c];
      GetIntVec($8+Irq,SBIntSave);
      SetIntVec($8+IRQ,@DummySBInt);
      Port[$21]:=Port[$21] and not (1 shl IRQ);
      wr_dsp($D0);
      Start_DMA_transfer(20);
      Delay(200);
      Inc(c);
      Stop_Playing;
      Port[$21]:=Port[$21] or (1 shl IRQ);
      Port[$20]:=$20;
      SetIntVec($8+Irq,SBIntSave);
    Until (IRQ_found) or (c=6);
  end;
  If not IRQ_found then IRQ:=0;
  Lautsprecher_Ein;
  freemem(tbuf,100);
END;

Procedure SBint ; Interrupt;
{ Diese procedure wird in den SB-interrupt eingeklinkt und
  angesprungen, wenn der DMA-Block vollstaendig ausgegeben
  wurde}
Begin
  If Rem_Size<50 then begin
     DMA_ACtiv:=False  {End of dma_transfer}
     Dispose(Soundbuff);
  end else If Rem_size<= DMA_bufsize then begin
     Pofs:=Pofs+DMA_Bufsize;
     Start_DMA_transfer(Rem_size);
     Rem_Size:=0;     {nix mehr uebrig}
    end else begin
     Pofs:=Pofs+DMA_Bufsize;
     Start_DMA_transfer(DMA_bufsize);
     Rem_Size:=Rem_Size-DMA_bufsize;
   end;
   Port[$20]:=$20;
end;

procedure Play_DMA(count : Word);
var
    L : Longint;
    hbyte : byte;
    a : word;
    Oldv, Newv, Hilfe :byte;
Begin
   Ppage:=Seg(Soundbuff^);
   Pofs:=Ofs(Soundbuff^);
   a:=Count;
   If a<= DMA_bufsize then begin
      Rem_Size:=0;
   end else begin
      Rem_Size:=a-DMA_bufsize;
      a:=DMA_bufsize;
   end;
   Lautsprecher_Ein;
   Set_Frequence(Frate);
   GetIntVec($8+DSP_Irq,SBIntSave);
   SetIntVec($8+DSP_Irq,@SBInt);
   Port[$21]:=Port[$21] and not (1 shl DSP_Irq);
   wr_dsp($D0);
   Start_DMA_TRANSFER(a);
   DMA_activ:=True;
end;

Procedure Play_Wave(fname :Pathstr);
Var
   size : LongInt;
   IdStr : String[4];
   Header : Wave_Head;
   F : File;
begin
  if psound then begin
   size := 0;
   Assign(f,Fname);
   reset(f,1);
   With Header do begin
    blockread(f,Header,sizeOf(Header));
    IdStr:=chr(WaveID[0])+chr(WaveID[1])+chr(WaveID[2])+chr(WaveID[3]);
    if IdStr = 'WAVE' then begin
     size := Length-Sizeof(header);
     If size>50 then begin
        frate:=Wrate;
        New(Soundbuff);
        blockread(f,Soundbuff^,size);
{Soundbuff^ is an ARRAY to buffer the WAVe. I know, that the
 unit is very dirty here, but its only do demonstrate how
 it works.}
        Play_DMA(size);
     end;
    end;
   end;
   close(f);
  end;
end;

BEGIN;
END.
