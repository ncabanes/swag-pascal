(*
From: KENT BRIGGS                  Refer#: NONE
Subj: TP 7.0 RANDOM GENERATOR        Conf: (1221) F-PASCAL
*)

const
  rseed: longint = 0;

procedure randomize67;      {TP 6.0 & 7.0 seed generator}
begin
  reg.ah:=$2c;
  msdos(reg);    {get time: ch=hour,cl=min,dh=sec,dl=sec/100}
  rseed:=reg.dx;
  rseed:=(rseed shl 16) or reg.cx;
end;

function rand_word6(x: word): word;    {TP 6.0 RNG: word}
begin
  rseed:=rseed*134775813+1;
  rand_word6:=(rseed shr 16) mod x;
end;

function rand_word7(x: word): word;    {TP 7.0 RNG: word}
begin
  rseed:=rseed*134775813+1;
  rand_word7:=((rseed shr 16)*x+((rseed and $ffff)*x shr 16)) shr 16;
end;

function rand_real67: real;    {TP 6.0 & 7.0 RNG: real}
begin
  rseed:=rseed*134775813+1;
  if rseed<0 then rand_real67:=rseed/4294967296.0+1.0 else
  rand_real67:=rseed/4294967296.0;
end;
