{
> Oh, btw Hunking is the conversion of three binary bytes to four ascii
> bytes! Thought you should know that :)
> Hmmm... so that's 3*8 bits=24 bits, into 4 ascii bytes=6 significant
> bits, is 2^6, =64 different ascii characters needed. I think I can
> manage that...

Well.. not exactly..

I wrote the hunking routine, and your example isn't what I want, but it's
close, I want to convert a binary string to an ascii string, what I have
hear is what I'd like to have the opposite of, and possibly improvements
on it.
}

{$A+,B-,D+,E+,F-,G-,I-,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,655360}
uses crt,dos;
Const
  xtranslate: array[#0..#63] of char =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

Function Bin2Hunk(st: string): string;
var
  temp: string;
  i,j,times: byte;
begin
  temp := '';
  { Figures out how many times the hunking loop with need to be run }
  { (it truncates to the nearest 4) }
  times := (length(st) div 4)*4;
  i := 0;
  if times <> 0 then
    repeat
      temp:=temp+char(byte(st[1+i]) shr 2);
      temp:=temp+char(((byte(st[1+i]) shl 4)+(byte(st[2+i]) shr 4)) and $3F);
      temp:=temp+char(((byte(st[2+i]) shl 2)+(byte(st[3+i]) shr 6)) and $3F);
      temp:=temp+char(byte(st[3+i]) and $3F);
      inc(i,4);
    until i = times;
  case length(st) mod 3 of
   {0:; -- do nothing if nothing is to be done! }
    1: begin
      temp:=temp+char(byte(st[1+i]) shr 2);
      temp:=temp+char(((byte(st[1+i]) shl 4)) and $3F);
    end;
    2: begin
      temp:=temp+char(byte(st[1+i]) shr 2);
      temp:=temp+char(((byte(st[1+i]) shl 4)+(byte(st[2+i]) shr 4)) and $3F);
      temp:=temp+char(((byte(st[2+i]) shl 2)) and $3F);
    end;
  end;
  { Map it }
  for j := 1 to length(temp) do temp[j] := xtranslate[temp[j]];
  Bin2Hunk := temp;
end;

Function Search(subchar: char; searchstuff: array of char):byte;
var i: word;
begin
  search := 0;
  for i := 1 to sizeof(searchstuff) do
    if searchstuff[i] = subchar then search := i;
end;

Function Hunk2Bin(st: string): string;
var j,i: byte;
begin
  { Demap it }
  for j := 1 to length(st) do st[j] := char(search(st[j],xtranslate));
  hunk2bin := st;
end;

var temp: string;
begin
  clrscr;
  temp := 'Hello';
  writeln('Unhunked: ',temp);

  temp := bin2hunk(temp);
  writeln('Hunked: ',temp);

  temp := hunk2bin(temp);
  writeln('Dehunked: ',temp);
end.

{
Now if you can complete the Hunk2Bin that I started to write I'd be
much obliged, I thought the Bin2Hunk was OK, but then I started trying
to code the hunk2bin.. and.. ack!  Note this routine uses the same
radix coding as PGP without the CRC-16 :)
}