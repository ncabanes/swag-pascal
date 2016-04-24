(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0097.PAS
  Description: VOC File Management
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

UNIT vocdecl;  { see demo at end of document }

INTERFACE

function reset_dsp(base:word):boolean;
procedure write_dac(level:byte);
function read_dac:byte;
function speaker_on:byte;

function speaker_off:byte;

procedure dma_pause;
procedure dma_continue;

procedure play_back(sound:pointer;size:word;frequency:word);
procedure play_voc(filename:string;buf:pointer);
function  done_playing:boolean;
function  play_raw(filename:string;buf:pointer):word;

IMPLEMENTATION

uses crt;

type
  iDsound=record
             dunno,
             rate,
             num_samples,
             dunno2:word;
           end;

var
  dsp_reset:word;
  dsp_read_data:word;
  dsp_write_data:word;
  dsp_write_status:word;
  dsp_data_avail:word;

  since_midnight:longint absolute $40:$6C;
  playing_till:longint;


function reset_dsp(base:word):boolean;
begin
  base:=base*$10;

  dsp_reset:=base+$206;
  dsp_read_data:=base+$20a;
  dsp_write_data:=base+$20c;
  dsp_write_status:=base+$20c;
  dsp_data_avail:=base+$20e;

  port[dsp_reset]:=1;
  delay(10);

  port[dsp_reset]:=0;
  delay(10);

  reset_dsp:=(port[dsp_data_avail]and $80=$80)and(port[dsp_read_data]=$aa);
end;

procedure write_dsp(value:byte);
begin
  while port[dsp_write_status] and $80<>0 do;
  port[dsp_write_data]:=value;
end;

function read_dsp:byte;
begin
  while port[dsp_data_avail]and $80=0 do;
  read_dsp:=port[dsp_read_data];
end;

procedure write_dac(level:byte);
begin
  write_dsp($10);
  write_dsp(level);
end;

function read_dac:byte;
begin
  write_dsp($20);
  read_dac:=read_dsp;
end;

function speaker_on:byte;
begin
  write_dsp($d1);
end;

function speaker_off:byte;
begin
  write_dsp($d3);
end;

procedure dma_continue;
begin
  playing_till:=since_midnight+playing_till;
  write_dsp($d4);
end;

procedure dma_pause;
begin
  playing_till:=playing_till-since_midnight;
  write_dsp($d0);
end;

procedure play_back(sound:pointer;size:word;frequency:word);
var
  time_constant:word;
  page:word;
  offset:word;
begin
  speaker_on;
  size:=size-1;
 { set up the dma chip }
  offset:=seg(sound^)shl 4+ofs(sound^);
  page:=(seg(sound^)+ofs(sound^)shr 4)shr 12;
  port[$0a]:=5;
  port[$0c]:=0;
  port[$0b]:=$49;
  port[$02]:=lo(offset);
  port[$02]:=hi(offset);
  port[$83]:=page;
  port[$03]:=lo(size);
  port[$03]:=hi(size);
  port[$0a]:=1;

 { set the playback frequency }
  time_constant:=256-1000000 div frequency;
  write_dsp($40);
  write_dsp(time_constant);

 { set the playback type (8-bit) }
  write_dsp($14);
  write_dsp(lo(size));
  write_dsp(hi(size));
end;

procedure play_voc(filename:string;buf:pointer);
var
  f:file;
  s:word;
  freq:word;

  h:record
      signature:array[1..20]of char;
      data_start:word;
      version:integer;
      id:integer;
    end;
  d:record
      id:byte;
      len:array[1..3]of byte;
      sr:byte;
      pack:byte;
    end;

begin
  {$i-}
{  if pos('.',filename)=0 then filename:=filename+'.voc';}
  assign(f,filename);
  reset(f,1);
  blockread(f,h,26);
  blockread(f,d,6);
  freq:=round(1000000/(256-d.sr));
  s:=ord(d.len[3])+ord(d.len[2])*256+ord(d.len[1])*256*256;
 { writeln('-----------header----------');
  writeln('signature: ', h.signature);
  writeln('data_start: ', h.data_start);
  writeln('version: ', hi(h.version), '.', lo(h.version));
  writeln('id: ', h.id);
  writeln;
  writeln('------------data-----------');
  writeln('id: ', d.id);
  writeln('len: ', s);
  writeln('sr: ', d.sr);
  writeln('freq: ', freq);
  writeln('pack: ', d.pack);}
  blockread(f,buf^,s);
  close(f);
  {$i-}
  if ioresult<>0 then
  begin
    writeln('Can''t find voc file "',filename,'".');
    halt(1);
  end;
  playing_till:=since_midnight+round(s/freq*18.20648193);
  play_back(buf,s,freq);
end;

function done_playing:boolean;
begin
  done_playing:=since_midnight>playing_till;
end;

function play_raw(filename:string;buf:pointer):word;
var
  f:file;
  s:word;
  head:idSound;
begin
  play_raw:=0;
  if pos('.',filename)=0 then filename:=filename+'.raw';
  assign(f,filename);
  {$i-} reset(f,1); {$i+}
  if(ioresult<>0)then
    exit;

  blockread(f,head,sizeof(head));
  if(maxavail<head.num_samples)then exit;

  getmem(buf,head.num_samples);

  s:=head.num_samples;
  blockread(f,buf^,s);
  close(f);

  play_back(buf,s,head.rate);
  playing_till:=since_midnight+round(s/head.rate*18.20648193);
  play_raw:=head.num_samples;
  freemem(buf,head.num_samples);
end;

begin
 if not reset_dsp(2)then
 begin
   writeln('SoundBlaster not found at 220h');
   halt(1);
 end else writeln('SoundBlaster found at 220h');
end.

{ ------------------------  DEMO --------------------- }

uses utils,vocdecl;

var
  buf:pointer;

begin
  if(paramcount<1)then
  begin
    writeln('Syntax: P [file].voc');
    halt;
  end;
  getmem(buf,fsize(paramstr(1)));
  play_voc(paramstr(1),buf);
end.
