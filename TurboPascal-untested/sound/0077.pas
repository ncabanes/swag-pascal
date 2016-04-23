{
Well, I saw your message and so I thought that you could use this.  It
is a .VOC player that doesn't use CT-Voice.DRV.  If you don't have a
copy of DSP (It has been posted here many times before) then just mail
me and I'll post a copy of it for you.  This program should work fine
(at least it does on my computer).  Hope you like it...
}

program play_voc; { without ct-voice.drv }
uses DSP, crt;
Type SoundBufType = Array[1..65528] of byte;
var SoundDat: ^SoundBufType;
    Filename: String;
    f : file;
    s : word;
    freq : word;
    h : record
         signature  : array[1..19] of char;  { vendor's name }
         Terminator : Byte;
         data_start : word;          { start of data in file }
         version    : integer; { min. driver version required }
         id         : integer; { 1-complement of version field+$1234 }
        end;                      { used to indentify a .voc file }
    d : record
         id   : byte; { = 1 }
         len  : array[1..3] of byte; { length of voice data (len data +
2)}
         sr   : byte; { sr = 256 - (1,000,000 / sampling rate) }
         pack : byte; { 0: unpacked, 1: 4-bit, 2: 2.6 bit, 3: 2 bit
packed}    end;

begin
 {$i-}
 clrscr;
 New(SoundDat);
 ResetDSP(2);
 SpeakerOn;
 Filename:=ParamStr(1);
 if pos('.', filename) = 0 then filename := filename + '.voc';
 assign(f, filename);
 reset(f, 1);
 blockread(f, h, 26);
 blockread(f, d, 6);
 seek(f,h.data_start);
 freq := round(1000000 / (256 - d.sr));
 s    := ord(d.len[3]) + ord(d.len[2]) * 256 + ord(d.len[1]) * 256 * 256;
 blockread(F, SoundDat^, S);
 writeln('-----------header----------');
 writeln('signature: ', h.signature);
 writeln('data_start: ', h.data_start);
 writeln('version: ', hi(h.version), '.', lo(h.version));
 writeln('id: ', h.id);
 writeln;
 writeln('------------data-----------');
 writeln('len: ', s);
 writeln('freq: ', freq);
 writeln('pack: ', d.pack);
 writeln('Filepos: ', FilePos(F));
 readkey;



 close(f);
 {$i-}

 if ioresult <> 0 then
  begin
   writeln('Can''t play voc file "' + filename + '".');
   halt(1);
  end;

 playback(SoundDat, s, freq);
end.

