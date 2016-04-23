
{ When you change modes, you lose the contents of the screen
(cleared). It's all IBM's fault. You see, there is also a change in
resolution and available colors and how video is used. It totally changes
and that's a way of life on the PC. Sorry, no way around it but to use
full graphics mode.

 FA> use, of course...) (I can't do it on a IBM, but ask me for C64-sources,
 FA> if you want to have a look <grin>)

320 x 200 x 256c, 13h, isn't the same as the resolution required for 80x50
text (640 x 400 x 256). In that case, I have seen graphics (simple) under
text in text mode. If you're forced to change resolution, kiss it all good
bye.

Run this under text: }

{$A+,B-,E-,F-,G+,I-,L-,N-,O-,R-,S-,V-,X-}

program RedBar;

VAR
  C:Byte;
  C2,C3,C4:Word;
  SINTAB:Array[0..127] of Word;
  HeadPtr:Word absolute $40:$1A;
  TailPtr:Word absolute $40:$1C;

begin;
  for c:=0 to 127 do
    sintab[c]:=Trunc((Sin((2*Pi/128)*C)+1)*135);
  C3:=0;
  REPEAT
    INLINE($FA);

    repeat until (port[$3da] and 8)>0;
    repeat until (port[$3da] and 8)=0;
    for c4:=0 to sintab[c3 and 127] do begin
      repeat until (port[$3da] and 1)=0;
      repeat until (port[$3da] and 1)>0;
    end;
    for c:=0 to 63 do begin
      repeat until (port[$3da] and 1)>0;
      Port[$3C8]:=0;
      Port[$3C9]:=C;
      Port[$3C9]:=0;
      Port[$3C9]:=0;
      repeat until (port[$3Da] and 1)=0;
    end;

    for c:=63 downto 0 do begin;
      repeat until (port[$3Da] and 1)>0;
      Port[$3C8]:=0;
      Port[$3C9]:=C;
      Port[$3C9]:=0;
      Port[$3C9]:=0;
      Repeat until (port[$3da] and 1)=0;
    end;

    port[$3C8]:=0;
    port[$3c9]:=0;port[$3c9]:=0;Port[$3c9]:=0;
    Inc(C3);
    inline($FB);
  until headptr<>tailptr;
  headptr:=tailptr;
end.
