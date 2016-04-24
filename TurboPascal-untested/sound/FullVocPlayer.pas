(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0078.PAS
  Description: Full VOC Player
  Author: ALWIN LOECKX
  Date: 05-26-95  23:32
*)

{
> A few days ago you posted a VOC file player that doesn't use CT-VOICE.DRV.
> I would like to know how to use it.  So far I have tried this.
> Uses PLAY;
>
> Var A : Pointer;
>
> Begin
>  PLAY_VOC('HI.VOC',A); End.
> End.
>
> Could you explain why this doesn't work and or give me a working demo!

You have to use "getmem" to reserve some memory before calling "play_voc".
Here follows a slightly modified unit + demo...

Alwin Loeckx - fido (2:291/754.6)
}

unit play;

interface

{ resetdsp returns true if reset was successful }
{ base should be 1 for base address 210h, 2 for 220h etc... }
function reset_dsp(base : word) : boolean;

{ write dac sets the speaker output level }
procedure write_dac(level : byte);

{ readdac reads the microphone input level }
function read_dac : byte;

{ speakeron connects the dac to the speaker }
function speaker_on: byte;

{ speakeroff disconnects the dac from the speaker, }
{ but does not affect the dac operation }
function speaker_off: byte;

{ functions to pause dma playback }
procedure dma_pause;
procedure dma_continue;

{ playback plays a sample of a given size back at a given frequency using }
{ dma channel 1. the sample must not cross a page boundry }
procedure play_back(sound : pointer; size : word; frequency : word);

{ plays voc-file }
procedure play_voc(filename : string; buf : pointer);

{ true if playing voc }
function playing_voc : boolean;


implementation

uses crt;

var dsp_reset        : word;
    dsp_read_data    : word;
    dsp_write_data   : word;
    dsp_write_status : word;
    dsp_data_avail   : word;

    since_midnight   : longint absolute $40:$6C;
    playing_till     : longint;


function reset_dsp(base : word) : boolean;

begin
 base := base * $10;

 { calculate the port addresses }
 dsp_reset        := base + $206;
 dsp_read_data    := base + $20a;
 dsp_write_data   := base + $20c;
 dsp_write_status := base + $20c;
 dsp_data_avail   := base + $20e;

 { reset the dsp, and give some nice long delays just to be safe }
 port[dsp_reset] := 1;
 delay(10);

 port[dsp_reset] := 0;
 delay(10);

 reset_dsp := (port[dsp_data_avail] and $80 = $80) and
              (port[dsp_read_data] = $aa);
end;


procedure write_dsp(value : byte);

begin
 while port[dsp_write_status] and $80 <> 0 do;
 port[dsp_write_data] := value;
end;


function read_dsp : byte;

begin
 while port[dsp_data_avail] and $80 = 0 do;
 read_dsp := port[dsp_read_data];
end;


procedure write_dac(level : byte);

begin
 write_dsp($10);
 write_dsp(level);
end;


function read_dac : byte;

begin
 write_dsp($20);
 read_dac := read_dsp;
end;


function speaker_on: byte;

begin
 write_dsp($d1);
end;


function speaker_off: byte;

begin
 write_dsp($d3);
end;


procedure dma_continue;

begin
 playing_till := since_midnight + playing_till;
 write_dsp($d4);
end;


procedure dma_pause;

begin
 playing_till := playing_till - since_midnight;
 write_dsp($d0);
end;


procedure play_back(sound : pointer; size : word; frequency : word);

var time_constant : word;
    page          : word;
    offset        : word;

begin
 speaker_on;

 size := size - 1;

 { set up the dma chip }
 offset := seg(sound^) shl 4 + ofs(sound^);
 page := (seg(sound^) + ofs(sound^) shr 4) shr 12;
 port[$0a] := 5;
 port[$0c] := 0;
 port[$0b] := $49;
 port[$02] := lo(offset);
 port[$02] := hi(offset);
 port[$83] := page;
 port[$03] := lo(size);
 port[$03] := hi(size);
 port[$0a] := 1;

 { set the playback frequency }
 time_constant := 256 - 1000000 div frequency;
 write_dsp($40);
 write_dsp(time_constant);

 { set the playback type (8-bit) }
 write_dsp($14);
 write_dsp(lo(size));
 write_dsp(hi(size));
end;




procedure play_voc(filename : string; buf : pointer);

var f : file;
    s : word;

    freq : word;

    h : record
         signature  : array[1..20] of char; { vendor's name }
         data_start : word;                 { start of data in file }
         version    : integer;              { min. driver version required }
         id         : integer;              { 1 - complement of version field
+$1234 }        end;                                { used to indentify a .voc
file }
    d : record
         id   : byte;                { = 1 }
         len  : array[1..3] of byte; { length of voice data (len data + 2) }
         sr   : byte;                { sr = 256 - (1,000,000 / sampling rate) }
         pack : byte;                { 0 : unpacked, 1 : 4-bit, 2 : 2.6 bit, 3:
2 bit packed }        end;

begin
 {$i-}
 if pos('.', filename) = 0 then filename := filename + '.voc';

 assign(f, filename);
 reset(f, 1);

 blockread(f, h, 26);

 blockread(f, d, 6);

 freq := round(1000000 / (256 - d.sr));
 s    := ord(d.len[3]) + ord(d.len[2]) * 256 + ord(d.len[1]) * 256 * 256;

 (*
 writeln('-----------header----------');
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
 writeln('pack: ', d.pack);
 *)

 blockread(f, buf^, s);

 close(f);
 {$i-}

 if ioresult <> 0 then
  begin
   writeln('Can''t find voc file "' + filename + '"');
   halt(1);
  end;

 playing_till := since_midnight + round(s / freq * 18.20648193);
 play_back(buf, s, freq);
end;



function playing_voc : boolean;

begin
 playing_voc := since_midnight > playing_till;
end;



begin
 if not reset_dsp(2) then
  begin
   writeln('SoundBlaster not found at 220h');
   halt(1);
  end
 else
  writeln('SoundBlaster found at 220h');
end.



uses crt, play;

var voc  : pointer;
    name : string;

begin
 getmem(voc, 65535);

 if paramcount = 1 then
  name := paramstr(1)
 else
  begin
   write('Play voc file (size < 65535!): ');
   readln(name);
  end;

 play_voc(name, voc);
 writeln;

 writeln('Playing, press "P" to pause...');

 repeat
  if keypressed then if (upcase(readkey) = 'P') then
   begin
    dma_pause;

    writeln('Press "C" to continue...');

    repeat
    until upcase(readkey) = 'C';

    writeln('Continuing...');
    dma_continue;
   end;
 until playing_voc;

 writeln('Done...');

 freemem(voc, 65535);
end.

