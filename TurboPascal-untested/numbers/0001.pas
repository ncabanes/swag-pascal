{
 Sean Palmer

> What if I want to just access a bit?  Say I have a Byte, to store
> Various access levels (if it does/doesn't have this, that, or the
> other).  How can I

> 1)  Access, say, bit 4?
> 2)  Give, say, bit 4, a value of 1?

> I have a simple routine that does "GetBit:= Value SHR 1;" to return
> a value, but how can I *SET* a value?  And is the above a good
> method? I only have TP5.5, so I can't do the Asm keyWord (yet..).

You COULD use TP sets to do it...
}

Type
  tByte = set of 0..7;
Var
  b : Byte;

{to get:
  Write('Bit 0 is ',Boolean(0 in tByte(b)));

to set:
  tByte(b):=tByte(b)+[1,3,4]-[0,2];
}

Type
  bitNum = 0..7;
  bit    = 0..1;

Function getBit(b : Byte; n : bitNum) : bit;
begin
  getBit := bit(odd(b shr n));
end;

Function setBit( b : Byte; n : bitNum) : Byte;
begin
  setBit := b or (1 shl n);
end;

Function clrBit(b : Byte; n : bitNum) : Byte;
begin
  clrBit := b and hi($FEFF shl n);
end;

{
 OR.....using Inline() code  (the fastest)
 These are untested but I'm getting fairly good at assembling by hand...8)
}

Function getBit(b : Byte; n : bitNum) : bit;
Inline(
  $59/      {pop cx}
  $58/      {pop ax}
  $D2/$E8/  {shr al,cl}
  $24/$01); {and al,1}

Function setBit(b : Byte; n : bitNum) : Byte;
Inline(
  $59/      {pop cx}
  $58/      {pop ax}
  $B3/$01/  {mov bl,1}
  $D2/$E3/  {shl bl,cl}
  $0A/$C3); {or al,bl}

Function clrBit(b : Byte; n : bitNum) : Byte;
Inline(
  $59/      {pop cx}
  $58/      {pop ax}
  $B3/$FE/  {mov bl,$FE}
  $D2/$C3/  {rol bl,cl}
  $22/$C3); {or al,bl}
