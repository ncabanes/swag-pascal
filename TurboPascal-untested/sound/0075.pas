{
This is for all the people who wanted a program to play wavs or so over
the internal beeper. (This was taken from a German computer magazine; it
has not been tested by me)
}
Program Speaker;
{
 Frei nach DOS-International 11/94 (SPEAKER.PAS)
}
uses dos,crt;

const OldInt : Word = 103;
      max = 50000;

var oldV : Pointer;
    buf : array[0..max] of byte;
    f   : file;
    Rate,I,res,Leng : Word;
    dir : searchrec;
    indos : ^byte;

  procedure New; Interrupt;
    begin
      if I <= Leng then
        if buf[I] > $80 then
          Sound(rate) else NoSound;
      port[$20] := $20;
      Inc(I);
    end;


  procedure getindos;
    var r : registers;
    begin
      r.AH := $34;
      MsDos(r);
      indos := ptr(r.es,r.bx);
    end;

  procedure NewTimer(Freq:Word);
    var w : word;
    begin
      inline($FA); {CLI}
      w := 1193180 DIV Freq;
      Port[$43] := $36;
      Port[$40] := Lo(w);
      Port[$40] := Hi(w);

      GetIntVec(8,OldV);
      SetIntVec(8,@New);

      inline($FB); {STI}
    end;

  procedure OldTimer;
    begin
      inline($FA); {CLI}
      Port[$43] := $36;
      Port[$40] := 0;
      Port[$40] := 0;
      SetIntVec(8,OldV);
      inline($FB); {STI}
    end;

var b : byte;

begin
  getindos;
  if Paramcount = 2 then begin
    Assign(f,Paramstr(1)); reset(f,1);
    leng := filesize(f);
    if leng > max then leng := max;
    Blockread(f,buf,leng,res);
    I := 0;
    Val(ParamStr(2),Rate,res);
    NewTimer(Rate);
    Writeln('Playing ',paramstr(1));
    repeat
      b := buf[i];
      TextColor(10);
      if (b and 1 <> 0) then Write('■');
      if (b and 2 <> 0) then Write('■');
      if (b and 4 <> 0) then Write('■');
      if (b and 8 <> 0) then Write('■');
      if (b and 16 <> 0) then Write('■');
      if (b and 32 <> 0) then Write('■');
      TextColor(12);
      if (b and 64 <> 0) then Write('■');
      if (b and 128 <> 0) then Write('■');
      Write('        '#13);
      delay(40);
      if not (I <= Leng) then
        if (indos^ <= 1) then begin
          inline($FA); {CLI}
          i := 0;
          Blockread(f,buf,max,res);
          leng := res;
          inline($FB); {STI}
          end;
    until (I > Leng) or (port[$60] < $80);
    OldTimer; nosound;
    Close(f);
    end else begin
      Writeln('SPEAKER.PAS (c) by ?');
      Writeln;
      Writeln('Usage: SPEAKER <samplename> <samplingrate>');
      Writeln('Samplingrate sollte zwischen 8000 und 22000 liegen.');
      end;
end.
