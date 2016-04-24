(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0125.PAS
  Description: Fading Textscreen
  Author: BAS VAN GAALEN
  Date: 08-24-94  14:00
*)

{
 AK> howdie, nice fader! i was wandering if you would be able
 AK> to comment the   program and repost it. i.e what the ports
 AK> are etc for us less experienced   programmers...

Okay, if you don't quote so much next time.

}

program copper;
{ bar-fade in, copper v7.0, by Bas van Gaalen, Holland, PD }
uses crt;
const size=20; { number of text-lines }
var pal:array[0..3*size-1] of byte;

{ increase first value in the pal-array (the one representing red), and scroll
that in the array }
procedure incbars;
var i:word;
begin
  if pal[0]<63 then inc(pal[0]);
  for i:=3*size-2 downto 0 do pal[i+1]:=pal[i];
end;

procedure copperbars;
var cc,l,j:word;
begin
  asm cli end;
  while (port[$3da] and 8)<>0 do; { vertical retrace }
  while (port[$3da] and 8)=0 do;
  cc:=0;
  for l:=0 to size-1 do begin
    port[$3c8]:=1; { set pal-idx number (1=blue) }
    port[$3c9]:=pal[cc]; { set first two pal-value's (red and green }
    port[$3c9]:=pal[cc+1]; { intensities }
    for j:=0 to 15 do begin { 16 vertical retraces = one text line }
      while (port[$3da] and 1)<>0 do;
      while (port[$3da] and 1)=0 do;
    end;
    port[$3c9]:=pal[cc+2]; { set last pal-value (blue), and thus activate
                             new palette }
    inc(cc,3);
  end;
  asm sti end;
end;

var i:byte;
begin
  textmode(co80); { 25 lines mode }
  fillchar(pal,sizeof(pal),0); { clear palette array }
  copperbars; { default = black -> otherwise flash of blue will appear }
  textcolor(1); { set text to blue (now black, 'cos pal changed) }
  writeln;
  writeln('Is this what you mean?'); writeln;
  for i:=1 to 15 do writeln('Test line ',i);
  repeat
    incbars;
    copperbars;
  until keypressed; { do stuff until keypressed... }
  textmode(lastmode); { back to last mode }
end.


