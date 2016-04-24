(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0134.PAS
  Description: SoundEx String Routine
  Author: RON NOSSAMAN
  Date: 08-30-96  09:36
*)

uses crt,dos;
var infile:text;
    instring,st1,st2,st3:string;
    letter:string[1];
    j:integer;
    h,m,s,hund,h2,m2,s2,hund2:Word;
    avail,avail2:longint;

FUNCTION SOUNDEXxx(na:string):string;
{fine, not too fast, converted from BASIC routine, has gotos}
var i,e,valcode,value:integer;
    k,ee,l,cd:string;
const
    code:string='01230120022455012623010202';
               { ABCDEFGHIJKLMNOPQRSTUVWXYZ }
label 312,314;

begin
   l:='';
   k:='';
   cd:='';
   if length(na)<2 then goto 314;
   for i:= 2 to length(na) do
   begin
      na[i]:=upcase(na[i]);
      if na[i] in ['A' .. 'Z'] then e:=ord(na[i])-64 else e:=0;
      if (e>26) or (e<1) then goto 312;
      k:=copy(code,e,1);
      if (k=l) or (k='0') then goto 312;
      cd:=concat(cd,k);
      if length(cd) >2 then goto 314;
312:  l:=k;
   end;
314:  cd:=concat(cd,'0000');
      delete(cd,4,30);
      soundexxx:=cd;
end; { SOUNDEXxx }



FUNCTION SOUNDEX3(na:string):string;
{same as soundexxx without gotos, faster}
var i,e,ll:integer;
    l,cd,k:string;

const
    code : string = '01230120022455012623010202';
    letters:string= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
     l:='';
     k:='';
     cd:='';
     if length(na)<2 then
     begin
        soundex3:='000';
        exit;
     end;
     i:=2;
     ll:=length(na);
     repeat
        na[i]:=upcase(na[i]);
        if na[i] in ['A'..'Z'] then e:=ord(na[i])-64 else e:=0;
        if e>0 then
        begin
           k:=copy(code,e,1);
           if (k<>l)and(k<>'0') then
           begin
              cd:=cd+k;
              if length(cd)>2 then i:=ll+1;
           end;
        end;
        l:=k;
        inc(i);
     until i>ll;
     cd:=cd+'000';
     soundex3:=copy(cd,1,3);
end; { SOUNDEX3 }



FUNCTION SOUNDEX3b(na:string):string;
{same as soundexxx without gotos, fastest}
var i,p,ll:integer;
    l,k,j:char;
    cd:string[3];
const code:string='901230120022455012623010202';
    letters:string='ABCDEFGHIJKLMNOPQRSTUVWXYZ';

begin
   l:=#0;
   k:=#0;
   j:=#0;
   p:=1;
   cd:='000';
   if length(na)<2 then
   begin
      soundex3b:=cd;
      exit;
   end;
   i:=2;
   ll:=length(na);
   repeat
      j:=code[succ(pos(upcase(na[i]),letters))];
      if (j<>'9')then k:=j;
      if (k<>l)and(k<>'0') then
      begin
         cd[p]:=k;
         inc(p);
         if p>3 then i:=ll+1;
      end;
      l:=k;
      inc(i);
   until i>ll;
   soundex3b:=cd;
end; { SOUNDEX3b }


function soundex_asm(var S:string):string;assembler;
const trans:array[0..25]of byte=
  (0,1,2,3,0,1,2,0,0,2,2,4,5,5,0,1,2,6,2,3,0,1,0,2,0,2);
 { a b c d e f g h i j k l m n o p q r s t u v w x y z }
asm
   cld              {set direction}
   les di,@result   {pointer to output soundex code}
   Xor ax,ax
   mov bx,di
   add bx,3         {bx=pointer last char of soundex}
   mov al,3
   stosb            {length of result}
   mov al,'0'
   push di
   mov cx,3
   repnz stosb      {pad soundex with '000'}
   pop di           {points to first byte of soundex code}
   lds si,[S]       {pointer to input string}
   Xor ax,ax
   mov al,[si]      {length of input string}
   cmp al,1         {input must be at least 2 characters long}
   jbe @quitter     {too short, or null input string - bail}
   add ax,si
   mov dx,ax        {dx=pointer last byte S}
   inc si
   inc si           {si=pointer second byte S}
                    {dx=lastchar s}
                    {bx=lastchar result}
                    {si=secondchar s}
                    {di=firstchar result}
                    {cx=last letter code rememberers}
   mov cx,0
 @nextchar:
   xor ax,ax
   lodsb            {get next char from input}
   cmp al,'Z'       {check for upper case}
   jg  @CaseOK
   cmp al,'A'
   jl  @CaseOK
   or al,$20        {make lower case}
@CaseOK:
   cmp al,'z'       {check for alphabetical range}
   jg @nocode
   cmp al,'a'
   jl @nocode
   sub al,'a'       {shift down so 'a'=0 for translation offset}
   push bx          {save pointer}
   mov bx,offset trans
   xlat             {get translation value}
   pop bx           {retreive end of input string pointer}
   mov ch,al
   cmp al,0
   je @nocode
   cmp ch,cl
   je @nocode
   add al,'0'
   stosb          {put soundex in code}
@nocode:
   mov cl,ch
   cmp di,bx
   jg @quitter
   cmp si,dx
   jbe @nextchar
 @quitter:
end;



function soundex_asm2(var S:string):string;assembler;
{works without global variable}
asm
   jmp @start
@trans: DB 0,1,2,3,0,1,2,0,0,2,2,4,5,5,0,1,2,6,2,3,0,1,0,2,0,2
         { a b c d e f g h i j k l m n o p q r s t u v w x y z }
@start:
   push ds
   cld              {set direction}
   les di,@result   {pointer to output soundex code}
   Xor ax,ax
   mov bx,di
   add bx,3         {bx=pointer last char of soundex}
   mov al,3
   stosb            {length of result}
   mov al,'0'
   push di
   mov cx,3
   repnz stosb      {pad soundex with '000'}
   pop di           {points to first byte of soundex code}
   lds si,S       {pointer to input string}
   Xor ax,ax
   lodsb
  { mov al,[si]}      {length of input string}
   cmp al,1         {input must be at least 2 characters long}
   jbe @quitter     {too short, or null input string - bail}
   add ax,si
   mov dx,ax        {dx=pointer last byte S}
   dec dx
{   inc si}
   inc si           {si=pointer second byte S}
                    {dx=lastchar s}
                    {bx=lastchar result}
                    {si=secondchar s}
                    {di=firstchar result}
                    {cx=last letter code rememberers}
   mov cx,0
 @nextchar:
   xor ax,ax
   lodsb            {get next char from input}
   cmp al,'Z'       {check for upper case}
   jg  @CaseOK
   cmp al,'A'
   jl  @CaseOK
   or al,$20        {make lower case}
@CaseOK:
   cmp al,'z'       {check for alphabetical range}
   jg @nocode
   cmp al,'a'
   jl @nocode
   sub al,'a'       {shift down so 'a'=0 for translation offset}
   push bx          {save pointer}
   mov bx,offset @trans
   SEGCS xlat             {get translation value}
   pop bx           {retreive end of input string pointer}
   mov ch,al
   cmp al,0
   je @nocode
   cmp ch,cl
   je @nocode
   add al,'0'
   stosb          {put soundex in code}
@nocode:
   mov cl,ch
   cmp di,bx
   jg @quitter
   cmp si,dx
   jbe @nextchar
 @quitter:
   pop ds
end;



function experiment(var s:string):string;
begin
   experiment:=soundex_asm2(s);
end;


procedure compare;
var istr:string;
begin
   write(letter,',');
   while not eof(infile) do
   begin
      readln(infile,instring);
      if letter[1]<>upcase(instring[1]) then
      begin
         letter[1]:=upcase(instring[1]);
         write(letter,',');
      end;
      istr:=instring;
      st2:=soundexxx(instring);
      if soundex3(instring)<>st2 then write('sx3 ');
      if soundex3b(instring)<>st2 then write('sx3b ');
{      if soundex_asm2(instring)<>st2 then write('sxasm ');}
      if experiment(instring)<>st2 then write('sxasm');
      st1:=soundex3b(instring);
      if(st1<>st2) then
         writeln(instring,' ',st1,' ',st2);
      if istr<>instring then writeln(istr,'  ',instring);
   end;
   writeln;
end;

procedure speed;
var t1,t2:real;
begin
   writeln('timing soundexxx');
   close(infile);
   reset(infile);
   GetTime(h,m,s,hund);
   while not eof(infile)do
   begin
      readln(infile,instring);
      st1:=soundexxx(instring);
   end;
   gettime(h2,m2,s2,hund2);
   t1:=(h*3600)+(m*60)+s+(hund/100);
   t2:=(h2*3600)+(m2*60)+s2+(hund2/100);
   WriteLn('Elapsed time ',(t2-t1):0:2,' seconds');
   writeln;
   writeln('timing soundex3');
   close(infile);
   reset(infile);
   GetTime(h,m,s,hund);
   while not eof(infile)do
   begin
      readln(infile,instring);
      st1:=soundex3(instring);
   end;
   gettime(h2,m2,s2,hund2);
   t1:=(h*3600)+(m*60)+s+(hund/100);
   t2:=(h2*3600)+(m2*60)+s2+(hund2/100);
   WriteLn('Elapsed time ',(t2-t1):0:2,' seconds');
   writeln;

   writeln('timing soundex3b');
   close(infile);
   reset(infile);
   GetTime(h,m,s,hund);
   while not eof(infile)do
   begin
      readln(infile,instring);
      st1:=soundex3b(instring);
   end;
   gettime(h2,m2,s2,hund2);
   t1:=(h*3600)+(m*60)+s+(hund/100);
   t2:=(h2*3600)+(m2*60)+s2+(hund2/100);
   WriteLn('Elapsed time ',(t2-t1):0:2,' seconds');
   writeln;
   writeln('timing soundex_asm');
   close(infile);
   reset(infile);
   GetTime(h,m,s,hund);
   while not eof(infile)do
   begin
      readln(infile,instring);
      st1:=soundex_asm(instring);
   end;
   gettime(h2,m2,s2,hund2);
   t1:=(h*3600)+(m*60)+s+(hund/100);
   t2:=(h2*3600)+(m2*60)+s2+(hund2/100);
   WriteLn('Elapsed time ',(t2-t1):0:2,' seconds');
end;



begin
   clrscr;
   letter:='A';
   assign(infile,'d:\spell\tmp\wookdic.asc');
   reset(infile);
   instring:='accord';
   st1:=soundex_asm(instring);
   compare;
{   speed;}
   close(infile);
end.
