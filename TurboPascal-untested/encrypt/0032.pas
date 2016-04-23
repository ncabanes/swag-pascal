
Program EncryptMessageInsideExe;

{This stupid program is useful to encrypt copyright messages into executables.
 Use: Run this program
      Input message and xor value
      Write encrypted string and xor value on a sheet
      If you declare the encrypted string as a var(string)/const you can
      decrypt it on-the-fly using XorIT with the same xor value
      In this way hackers (the lamest ones) can't see/modify your string}
{Author: Salvatore Meschini - E-Mail: smeschini@ermes.it - WWW:
         http://www.ermes.it/pws/mesk . Please report bugs and suggestions}
{This program if FREE, use it copy it think me :) }

uses CRT;

var s,xs:string;
    i,xv,c:word;
    f:text;

Function XORIT(s:string):string;
  begin
   xs:='';
   for i:=1 to length(s) do
    begin
      c:=ord(s[i]) xor xv;
      xs:=xs+chr(c);
    end;
   xorit:=xs;
  end;

begin
     clrscr;
     write('Input string: ');
     readln(s);
     write('Input XOR Value: ');{Low values creates plain ASCII strings}
     readln(xv);
     clrscr;
     writeln(S);
     writeln(xorit(s));
     writeln(xorit(xs));  {Safe Check}
     writeln;
     asm {Turns cursor off}
        XOR   ax,ax
        MOV   ax,$0100;
        MOV   cx,$2607;
        INT   $10
     end;

     {IMPORTANT:}
     if paramcount > 0 then
       begin   {If parameter isn't null  you will have the encrypted
               message in a file, so ... cut and paste in your source (see
below)!}
         assign(f,paramstr(1));          {^^^^^^^^^^^^}
         rewrite(f);
         write(f,xorit(s));
         close(f);
       end;

     write('Now you can declare
''');textcolor(lightred);write(xorit(s));textcolor(7);
     write(''' as a const and decrypt it in execution time with xorit!
(Remember XORVALUE=');
     textcolor(9);write(xv);textcolor(7);writeln(')');writeln;
     if paramcount <> 0 then write('I saved ',xorit(S),' in
');textcolor(10);writeln(paramstr(1));
     readkey;
end.

{Example -------------------------------------------------------- Example}

Program Demo;

const hiddenmessage='-F,%Vdisdqjw`%H`vfmlkl'; {<- This is equal to:
                                             '(C) Salvatore Meschini' XORed
                                                 by 5}
      xorvalue=5;               {You can use your message and xorvalue}

Function XORIT(s:string):string;
  var xs:string;
      xv,i,c:word;
  begin
   xs:='';

   xv:=xorvalue;  {<-- xv:=5}

   for i:=1 to length(s) do
    begin
      c:=ord(s[i]) xor xv;
      xs:=xs+chr(c);
    end;
   xorit:=xs;
  end;


begin

writeln(xorit(hiddenmessage)); {You DON'T HAVE (C) Salvatore Meschini in .exe
                                but you CAN display it!!!}
end.

