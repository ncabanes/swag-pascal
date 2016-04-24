(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0090.PAS
  Description: Source For MOD Player
  Author: MARCIN BORKOWSKI
  Date: 11-22-95  13:28
*)

{$A+,B-,D+,E+,F-,G+,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y+}
{$M 16384,0,655360}

program modplay;

uses mixer,dos,crt;  { see bottom for MIXER code }

{ Program by Borek (Marcin Borkowski), Warsaw, Poland.
  You can find me in a Top Secret BBS, +48 2 6788783
  Fido 2:480/25, Pascal Net 115:4804/104

  This program needs fast machine, as it is written in
  plain vanilla Pascal. If you are looking for proffesional
  quality implementation of MOD player, keep trying
  (I'm sure you'll have to paid for that). If you are looking
  for a source to understand and start work by yourself -
  you've got what you are looking for! You may freely copy
  and use this source, as long as it is unchanged and states my
  name in the begining. If you find more profitable use of this
  code, feel free to share your profits with me! At least - let
  me know you were able to use it for your own purposes.

  This program should be accompanied by the MIXER unit source.

  Attention - this implementation of playing MOD's is BAD
  and will probably not work on some MOD's with changed
  order of playing patterns, also MOD's based on effects
  will not be played properly. Effects (and many other things -
  as sample volumes, finetuning) aren't implemented, and in
  fact that's only a sketch. Program is probably bugged, but
  for sure it plays 40% MOD's from my BBS in an acceptable way.

  Parts of code ripped from PCPGE, various sources from
  Ethan Brodsky and probably from SWAG. I can't remember
  source of every byte, but for sure 95% of code is mine.

  When this code was posted for the first time, I've got some
  stupid questions, here are stupid answers:
  1. Borland Pascal 7.0
  2. Sound Blaster 2.0
  3. Yes, I'm nearly bald. }

const
  TIMERINTR = 8;
  PIT_FREQ  = $1234DD;

type
  sampledata = array[0..65533]of byte;
  pattern    = array[0..63,0..15]of byte;
  patptr     = ^pattern;

var
  BIOSTimerHandler    : procedure;
  clock_ticks,counter : longint;

  playend : boolean;
  ticks,speed : word;
  divplayed : word;
  patplayed : word;
  patterns : array[0..255]of patptr;
  patternorder : array[0..127]of byte;
  fmod    : file;
  hdr     : array[1..1084]of byte;
  nofsamples : word;
  nofpatterns : word;
  OrigTextMode : integer;
  OldExit : pointer;
  timerset : boolean;
  samples : array[1..31]of record
                             sname : string[22];
                             length : word;
                             finet  : byte;
                             volume : byte;
                             repst,repend : word;
                           end;

function amiword(w : word): word;
{ Data in MOD files are usually in 68000 format. }
assembler;
asm
  mov ax,w
  xchg ah,al
end;

procedure nextdivision;
var
{ Sometimes data have to be treated as bytes,
  sometimes as words. Let's use some tricks! }
  divis : array[0..15]of byte;
  diwis : array[0..7]of word absolute divis;
  smp,tmp,freq : word;
  eff,arg : byte;
  i       : integer;
begin
  if divplayed=64 then
  begin
    divplayed:=0;
    inc(patplayed);
  end;
  if patplayed>=hdr[951] then
  begin
    playend:=true;
    EXIT
  end;

  gotoxy(1,43);
  write('Pattern: ',patplayed+1:2,'/',hdr[951],
        '    division: ',divplayed:2);
  move(patterns[patternorder[patplayed]]^[divplayed,0],divis,16);

  for i:=0 to 3 do
  begin
    smp:=(divis[4*i+0] and $F0)+divis[4*i+2] shr 4;  {sample number}
    tmp:=(amiword(diwis[2*i]) and $0FFF);      {sample period}
    if tmp<>0 then freq:=3546895 div tmp;
    if smp<>0 then startchannel(i+1,smp,64,freq)
              else if tmp<>0 then setchannelfrequency(i+1,freq);

    gotoxy(1,45+i);
    write(' channel ',i,': (',smp:2,') ',samples[smp].sname:22);
    if tmp<>0 then write(' Hz: ',freq:5,' ':25)
              else write(' Hz: ',' ':30);
    gotoxy(53,45+i);

    eff:=divis[4*i+2] and $0F;                 {effect number}
    arg:=divis[4*i+3];                         {effect argument}
    case eff of
      $0C : begin
              setchannelvolume(i+1,arg);
              write('volume change       ');
            end;
      $0F : if arg<>0 then
            begin
              speed:=arg;
              write('speed change        ');
            end;
      $0B : begin
              divplayed:=63;
              patplayed:=arg-1;
              write('pattern break       ');
            end;
      $0D : begin
              inc(patplayed);
              divplayed:=10*(arg shr 4)+arg and $0F-1;
              write('pattern jump        ');
            end;
      else if eff<>0 then
              write('unimplemented effect');
    end;
  end;
  inc(divplayed);
end;

procedure play;
interrupt;
begin
  inc(ticks);
  if ticks=speed then
  begin
    ticks:=0;
    nextdivision;
  end;
  clock_ticks := clock_ticks + counter;
  if clock_ticks >= $10000 then
    begin
      clock_ticks := clock_ticks - $10000;
      asm pushf end;
      BIOSTimerHandler;
    end
  else Port[$20] := $20;
end;

procedure CleanUpTimer;
begin
  Port[$43] := $34;
  Port[$40] := 0;
  Port[$40] := 0;
  SetIntVec(TIMERINTR, @BIOSTimerHandler);
end;

procedure SetTimer(TimerHandler : pointer; frequency : word);
begin
  clock_ticks := 0;
  counter := $1234DD div frequency;
  GetIntVec(TIMERINTR, @BIOSTimerHandler);
  SetIntVec(TIMERINTR, TimerHandler);
  Port[$43] := $34;
  Port[$40] := counter mod 256;
  Port[$40] := counter div 256;
  timerset:=true
end;

{$F+}
procedure shutdown;
begin
  if timerset then CleanUpTimer;
  exitproc:=oldexit
end;
{$F-}

procedure error(s : string);
begin
  textmode(OrigTextMode);
  writeln(s);
  close(fmod);
  HALT
end;

procedure openmod;
var
  s : string;
begin
  if paramcount=0 then error('Needs filename (*.mod) as parameter');
  assign(fmod,paramstr(1));
  reset(fmod,1);
  if IOResult<>0 then error('Can''t open file: '+paramstr(1));
  blockread(fmod,hdr,1084);
  move(hdr[1081],s[1],4);
  s[0]:=#4;
  if not((s='M.K.') or (s='M!K!') or (s='FLT4') or (s='4CHN')) then
    error('Invalid mod file format tag: '+s);
  nofsamples:=31;
  move(hdr[1],s[1],20);
  s[0]:=#1;
  while s[ord(s[0])]<>#0 do inc(s[0]);
  writeln('Song name: ',s);
  writeln
end;

procedure getsamples;
var
  i : integer;
  s : string;
  w : word;
  totalsamplength : longint;
  p : pointer;
begin
  writeln('Number     Name':20,'Length  Vol    RepSt   RepEnd':48);
  totalsamplength:=0;
  for i:=1 to nofsamples do with samples[i] do
  begin
    move(hdr[21+(i-1)*30],sname[1],21);
    sname[0]:=#1;
    while sname[ord(sname[0])]<>#0 do inc(sname[0]);
    move(hdr[43+30*(i-1)],w,2);    length:=amiword(w) shl 1;
    inc(totalsamplength,length);
    volume:=hdr[46+30*(i-1)];
    move(hdr[47+30*(i-1)],w,2);    repst:=amiword(w) shl 1;
    move(hdr[49+30*(i-1)],w,2);    repend:=repst+amiword(w) shl 1;
    writeln(' sample ',i:2,': ',sname:22,length:11,
            volume:5,repst:8,repend-2:8);
  end;
  nofpatterns:=(filesize(fmod)-1084-totalsamplength) div 1024;
  writeln;
  writeln('Number of different patterns in song: ',nofpatterns);
  seek(fmod,filesize(fmod)-totalsamplength);
  for i:=1 to nofsamples do
    with samples[i] do
      if length>2 then
      begin
        getmem(p,length);
        blockread(fmod,w,2);
        blockread(fmod,p^,length-2);
      { Convert sample to appropriate format. }
        for w:=0 to length-3 do inc(sampledata(p^)[w],128);
        addvoice(i,length-2,repst,repend-2,p)
      end;
  if IOResult<>0 then error('Something went wrong during samples reading.')
end;

procedure getpatterns;
var
  i : integer;
begin
  seek(fmod,1084);
  for i:=0 to nofpatterns-1 do
  begin
    new(patterns[i]);
    blockread(fmod,patterns[i]^,1024)
  end;
  seek(fmod,952);
  blockread(fmod,patternorder,128);
  close(fmod);
end;

procedure startplay;
begin
  speed:=6;
  divplayed:=0;
  patplayed:=0;
  SetTimer(@play,50);
  playend:=false;
end;

begin
  OrigTextMode:=LastMode;
  timerset:=false;
  TextMode(C80+Font8x8);
  clrscr;
  OldExit:=ExitProc;
  ExitProc:=@ShutDown;
  openmod;
  getsamples;
  getpatterns;
  startplay;
  repeat until keypressed or playend;
  textmode(OrigTextMode)
end.


{ MIXER }

{$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V+,X+,Y+}
{$M 16384,0,655360}

unit mixer;

{ Program by Borek (Marcin Borkowski), Warsaw, Poland.
  You can find me in a Top Secret BBS, +48 2 6788783
  Fido 2:480/25, Pascal Net 115:4804/104

  If you can't recognize - it is Sound Blaster version.

  You may freely copy and use this source, as long it is
  unchanged and states my name in the begining. If you find
  more profitable use of this code, fell free to share your
  profits with me! At least - let me know you were able to
  use it for your own purposes.

  This unit should be accompanied by the MODPLAY source.

  This version of mixing (even at 44 kHz) works OK on my
  UMC 40 MHz machine (that's a little bit less than 486 50 MHz).
  If you want to make it work on 386DX 33MHz, you must 'unroll'
  the main loop and put used there data into 'hardcoded' variables.
  Such a version works on my old 386 and on several other
  computers of the same class, even with QEMM.

  If you stop this program by ctrl break, you may not be able to
  restart it without resetting your computer - and that's not the
  only one bug I know in the code.

  Parts of code ripped from PCPGE, various sources from
  Ethan Brodsky and probably from SWAG. I can't remember
  source of every byte, but for sure 95% of code is mine.}

interface

procedure addvoice(voice,_samplesize,_loopstart,_loopend : word;
                   sample : pointer);
procedure startchannel(channel,voice,volume,frequency : word);
procedure stopchannel(channel : word);
procedure setchannelfrequency(channel,frequency : word);
procedure setchannelvolume(channel,volume : word);

implementation

uses crt,dos;

const
{ Mixer data }
  max_num_voices = 32; { number of voices }
  max_num_channels = 4; { number of channels }
  PlayFreq = 22222; { samples played at, at 11111 sound is very bad. }
  playbufsize = 512; { Size of play buffer}
{ SB data - change it for your card settings. }
  SBIO    : word = 2;  { 2x0 }
  SBIRQ   : word = 7;

type
  sampledata = array[0..65533]of byte;
  _channel   = record
                 nvoice,position,increment,subposition,vol : word;
                 inloop,active : boolean
               end;

var
{ Pointers to samples. }
  voicesdata : array[1..max_num_voices]of ^sampledata;
{ Sizes of voices }
  voicessize : array[1..max_num_voices]of word;
{ Those two defines begining and end of loop in sample }
  voicesloopstart : array[1..max_num_voices]of word;
  voicesloopend : array[1..max_num_voices]of word;
{ Voice ready to use? }
  voicesdefined : array[1..max_num_voices]of boolean;
{ Which voice played in this channel? }
  channelsnvoice : array[1..max_num_channels]of word;
{ Which position in sample? }
  channelsposition : array[1..max_num_channels]of word;
{ How to increment subposition? }
  channelsincrement : array[1..max_num_channels]of word;
{ Which subposistion in position - it allows to change frequencies,
  as one byte of sample can be played several times. It gives not a
  perfect sound, but it works. To improove sound quality, one should
  use interpolation (and assembler :-) }
  channelssubposition : array[1..max_num_channels]of word;
{ Volume of channel }
  channelsvol : array[1..max_num_channels]of word;
{ Is sample in this channel loop? }
  channelsinloop : array[1..max_num_channels]of boolean;
{ Channel being played? }
  channelsactive : array[1..max_num_channels]of boolean;

{ SB addresses }
  DSP_RESET        : word;
  DSP_READ_DATA    : word;
  DSP_WRITE_DATA   : word;
  DSP_WRITE_STATUS : word;
  DSP_DATA_AVAIL   : word;

  timeconst        : byte;
  playbuf          : pointer;
  oldint,oldexit   : pointer;
  firstbuff        : boolean;

function carry : boolean;
inline($B0/$01/     {  mov al,01 }
       $72/$02/     {  jc @carryset }
       $30/$C0);    {  xor al,al }
                    { @carryset: }

function ResetDSP(base : word) : boolean;
begin
  base := base * $10;
  DSP_RESET := base + $206;
  DSP_READ_DATA := base + $20A;
  DSP_WRITE_DATA := base + $20C;
  DSP_WRITE_STATUS := base + $20C;
  DSP_DATA_AVAIL := base + $20E;
  Port[DSP_RESET] := 1;
  Delay(1);
  Port[DSP_RESET] := 0;
  Delay(1);
  if (Port[DSP_DATA_AVAIL] And $80 = $80) And (Port[DSP_READ_DATA] = $AA)
     then ResetDSP := true
     else ResetDSP := false;
end;

procedure WriteDSP(value : byte);
begin
  while Port[DSP_WRITE_STATUS] And $80 <> 0 do;
  Port[DSP_WRITE_DATA] := value;
end;

function ReadDSP : byte;
begin
  while Port[DSP_DATA_AVAIL] and $80 = 0 do;
  ReadDSP := Port[DSP_READ_DATA];
end;

function SpeakerOn: byte;
begin
  WriteDSP($D1);
end;

function SpeakerOff: byte;
begin
  WriteDSP($D3);
end;

procedure Playback;
var
  page,offset,size   : word;
begin
{ SB and DMA are working in autoinit modes - but DMA buffer is
  twice as long as SB buffer. Each time SB buffer is finished an
  IRQ is generated - a signal that next part of samples should be
  mixed. Play buffer has two parts - when one is played, second
  is being filled. Simple, uh? This version of procedure was checked
  on AWE 32, on SB 16 and on several clones of SB, but for sure
  it'll not work on some cards - especially on older versions
  that are not supporting autoinit mode. }
  firstbuff:=true;
  size := playbufsize-1;
  offset := Seg(playbuf^) Shl 4 + Ofs(playbuf^);
  page := (Seg(playbuf^) + Ofs(playbuf^) shr 4) shr 12;
{ DMA programming }
  Port[$0A] := 5;
  Port[$0C] := 0;
  Port[$0B] := $59; { DMA autoinit }
  Port[$02] := Lo(offset);
  Port[$02] := Hi(offset);
  Port[$83] := page;
  Port[$03] := Lo(size);
  Port[$03] := Hi(size);
  Port[$0A] := 1;
{ SB programming }
  WriteDSP($40);
  WriteDSP(timeconst);
  WriteDSP($48); { 8-bit sample type with autoinit}
  WriteDSP(Lo(playbufsize shr 1-1));
  WriteDSP(Hi(playbufsize shr 1-1));
  WriteDSP($1C) {???? I don't know why, but it is necessary }
end;

procedure mix;
{ Main procedure - mixes samples with appropriate frequencies and
  puts mixed signal into play buffer. If it's too slow for your
  computer, don't blame me - but translate procedure into assembler
  (or buy something faster :-) }
var
  i,j : integer;
  nvoice,sw  : word;
  pombuf : ^sampledata;
begin
{ Pointer to play buffer - is it first, or second part? }
  if firstbuff then pombuf:=@sampledata(playbuf^)[playbufsize div 2]
               else pombuf:=playbuf;
  for i:=0 to playbufsize div 2-1 do
  begin
    sw:=0;
    for j:=1 to max_num_channels do
      if channelsactive[j] then
      begin
        nvoice:=channelsnvoice[j];
{ That's mixing - without interpolation. }
        inc(sw, voicesdata[nvoice]^[channelsposition[j]] * channelsvol[j]);
{ Here is the most important thing - next two lines (excluding
  remarks:) are responsible for output frequency of sample.  }
        inc(channelssubposition[j],channelsincrement[j]);
{ That's a nasty trick - but it works. You can do it other ways,
  in Pascal, Assembler and so on. }
        if carry then
        begin
          inc(channelsposition[j]);
{ Now work with looped samples. }
          if channelsinloop[j] then
            if channelsposition[j] > voicesloopend[nvoice] then
                   channelsposition[j] := voicesloopstart[nvoice];
{ Maybe we should stop playing this sample? Or put it in a loop mode? }
          if channelsposition[j] > voicessize[nvoice] then
            if voicesloopstart[nvoice]<>0 then
            begin
              channelsposition[j] := voicesloopstart[nvoice];
              channelsinloop[j]:=true
            end
            else channelsactive[j]:=false;
        end;
      end;
    pombuf^[i]:=Lo(sw shr 6);
  end;
end;

procedure inthandler;
interrupt;
var
  w : word;
begin
  w:=Port[DSP_DATA_AVAIL];
  port[$20]:=$20;
  firstbuff:=not firstbuff;
  mix;
end;

procedure enableIRQ(n : byte);
begin
  port[$21]:=port[$21] and not (1 shl n)
end;

procedure disableIRQ(n : byte);
begin
  port[$21]:=port[$21] or (1 shl n)
end;

procedure allocmem(var p : pointer);
var
  adr : longint;
begin
{ Allocates memory not crossing page boundary ($X0000) }
  repeat
    getmem(p,playbufsize);
    adr:=longint(Seg(p^)) Shl 4 + Ofs(p^);
  until (adr and $FFFF)<$FFFF-playbufsize
end;

{$F+ }
procedure MixerExit;
begin
  ExitProc:=OldExit;
  WriteDSP($D0); { ??? }
  speakeroff;
  disableIRQ(SBIRQ);
  setintvec(8+SBIRQ,oldint);
  ResetDSP(SBIO);
end;
{$F- }

procedure initplayloop;
begin
  if not ResetDSP(SBIO) then HALT;
  allocmem(playbuf);
  getintvec(8+SBIRQ,oldint);
  setintvec(8+SBIRQ,@inthandler);
  enableIRQ(SBIRQ);
  speakeron;
  timeconst:=256-1000000 div PlayFreq;
  fillchar(playbuf^,playbufsize,#0);
  playback;
  OldExit:=ExitProc;
  ExitProc:=@MixerExit
end;

procedure addvoice(voice,_samplesize,_loopstart,_loopend : word;
                   sample : pointer);
begin
  voicesdata[voice]:=sample;
  voicessize[voice]:=_samplesize;
  voicesloopstart[voice]:=_loopstart;
  voicesloopend[voice]:=_loopend;
  voicesdefined[voice]:=true
end;

procedure startchannel(channel,voice,volume,frequency : word);
begin
  asm cli end;
  if not channelsactive[channel] then channelsactive[channel]:=true;
  channelsinloop[channel]:=false;
  channelsnvoice[channel]:=voice;
  channelsincrement[channel]:=(longint(frequency) shl 16-1) div PlayFreq;
  if (volume>=0) and (volume<=16) then channelsvol[channel]:=volume
                                  else channelsvol[channel]:=16;
  channelssubposition[channel]:=0;
  channelsposition[channel]:=0;
  asm sti end;
end;

procedure stopchannel(channel : word);
begin
  channelsactive[channel]:=false;
  channelsinloop[channel]:=false
end;

procedure setchannelfrequency(channel,frequency : word);
begin
  asm cli end;
  channelsincrement[channel]:=(longint(frequency) shl 16-1) div PlayFreq;
  asm sti end;
end;

procedure setchannelvolume(channel,volume : word);
begin
  asm cli end;  {}
  if (volume>=0) and (volume<=16) then channelsvol[channel]:=volume;
  asm sti end;  {}
end;

begin
  fillchar(voicesdata,sizeof(voicesdata),#0);
  fillchar(voicessize,sizeof(voicessize),#0);
  fillchar(voicesloopstart,sizeof(voicesloopstart),#0);
  fillchar(voicesloopend,sizeof(voicesloopend),#0);
  fillchar(voicesdefined,sizeof(voicesdefined),#0);
  fillchar(channelsnvoice,sizeof(channelsnvoice),#0);
  fillchar(channelsposition,sizeof(channelsposition),#0);
  fillchar(channelsincrement,sizeof(channelsincrement),#0);
  fillchar(channelssubposition,sizeof(channelssubposition),#0);
  fillchar(channelsvol,sizeof(channelsvol),#0);
  fillchar(channelsinloop,sizeof(channelsinloop),#0);
  fillchar(channelsactive,sizeof(channelsactive),#0);
  initplayloop
end.

