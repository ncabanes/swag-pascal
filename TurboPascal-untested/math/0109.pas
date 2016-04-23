{
I have made a program that calculates Primes, I think it is quite
fast and would like to have it included in SWAG.
On a P120 it calculates all primes up to 1.000.000 in 10.3 s.

And if somebody knows how to optimize it please tell me. }

program prime;

uses dos,crt;

var      prmtal         : array[1..16142] of longint;
         a              : longint;
         sq,qq,x,tst    : longint;
         h,m,s,hu       : word;    {time}
         xx             : longint;
         b              : word;
         till           : longint;  {check primes up to..}
         g              : string[10];


procedure Putstr(s:string);assembler;   {This routine was made by}
asm                                     {     JAMIE MORTIMER     }
  push ds

  mov ax,$b800
  mov es,ax
  xor di,di

  lds si,s
  mov cl,byte ptr [si]
  inc si
  mov ah,7
@1:
  mov al,byte ptr [si]
  mov word ptr es:[di],ax

  inc si
  add di,2
  dec cl
  jnz @1

  pop ds
end;


procedure prm1;
begin
  tst:=121;
  repeat
    repeat
      inc(a,4);
      if tst<a then begin
        inc(qq);
        tst:=prmtal[qq]*prmtal[qq];
      end;
      if(a mod 5=0)or(a mod 7=0)or(a mod 11=0)or (a mod 13=0) then break;
      for b:=5 to qq do
        if (a mod prmtal[b])=0 then break;
      if b<(qq)  then break;
      str(a,g);
      putstr(g);
      inc(x);
      prmtal[x]:=a;
    until 1=1;
    repeat
      inc(a,2);
      if (a mod 5 = 0)or (a mod 7=0)or(a mod 11=0)or(a mod 13=0) then break;
      for b:=5 to qq+1 do
        if (a mod prmtal[b])=0 then break;
      if b<qq+1 then break;
      str(a,g);
      putstr(g);
      inc(x);
      prmtal[x]:=a;
    until 1=1;
  until x>16100;

  repeat
    repeat
      inc(a,4);
      if tst<a then begin
        inc(qq);
        tst:=prmtal[qq]*prmtal[qq];
      end;
      if (a mod 5 = 0)or (a mod 7=0)or(a mod 11=0)or(a mod 13=0) then break;
      for b:=5 to qq  do
        if (a mod prmtal[b])=0 then break;
      if b<qq then break;
      str(a,g);
      putstr(g);
      inc(x);
    until 1=1;
    repeat
      inc(a,2);
      if (a mod 5 = 0)or (a mod 7=0)or(a mod 11=0)or(a mod 13=0) then break;
      for b:=5 to qq+1 do
        if (a mod prmtal[b])=0 then break;
      if b<qq+1 then break;
      str(a,g);
      putstr(g);
      inc(x);
    until 1=1
  until a>till;
end;

begin
  prmtal[16142]:=3;
  xx:=0;
  a:=25;
  qq:=5;

  gettime(h,m,s,hu);
  sq:=hu+100*s+6000*m+360000*h;
  prmtal[1]:=5;    {2 and 3 is not included..}
  prmtal[2]:=7;
  prmtal[3]:=11;
  prmtal[4]:=13;
  prmtal[5]:=17;
  prmtal[6]:=19;
  prmtal[7]:=23;
  till:=1000000;
  x:=7;
  clrscr;

  prm1;     {begin testing}

  writeln;
  Writeln('Primes found:',x,'   ');
  Gettime(h,m,s,hu);
  sq:=(hu+100*s+m*6000+h*360000)-sq;
  writeln('Time ',round(int(sq/100)),'.',round(100*frac(sq/100)),'s');
  writeln;
  writeln(' Dx/33  = 53.34s');
  writeln(' Dx/40  = 43.61s');
  writeln('Dx4/75  = 23.53s');
  writeln('Dx4/100 = 17.67s');
  writeln('Dx4/120 = 14.71s');
  writeln(' P120   = 10.32s');
end.
