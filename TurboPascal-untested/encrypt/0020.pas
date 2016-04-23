{
            HIDESTR -- Rich Veraa's Anti-hack string hider.

                    Released to the Public Domaim
                          22 April, 1992
                        by Richard P. Veraa


INTRODUCTION

     The purpose of HIDESTR is to encrypt string variables in a Turbo
     Pascal <tm> program so that they will be hidden in the .EXE file
     and will make things a bit more difficult for hackers.

     HIDESTR reads an ASCII list of text strings used in the program and
     creates Turbo Pascal <tm> source code for a TPU unit that includes
     the strings encrypted as constant arrays of bytes. There is a
     decrypting procedure to be used at run time to return the decrypted
     strings as functions.

     To use HIDESTR, just

     1. list the text strings to be used by the program in a text file
     named LIST with numbered lines, as follows:

1   Myprog
2   Version 1.0
3   by John Doe
4   Enter velocity, mph:
5   Enter time of trip, hours:
6   The distance traveled is
7   miles.
8   Do you wish to go on [Y/n]?
9   Done
10  Thank you for using MYPROG

     2. Then write your program using str1, str2, str3, etc in place of
     the strings.

     4. Place the TPU name "STRLIST" in your "uses" statement. The
     following is code for a typical small program:

Program Myprog;
uses strlist;

var
   v, t, d : real;
   ch : char;

begin
   ch := 'y';
   writeln (srt1,' ',srt2);
   writeln(str3);
   writeln;
   while not ch in ['n','N'] do
      begin
         write(str4,' ');
         readln(v);
         write(str5,' ');
         readln(t);
         writeln;
         d := v * t;
         writeln(str6,' ',d);
      end;
   writeln;
   write(str8,' ');
   readln(ch);
   writeln;
   writeln(str9);
   writeln(str10);
end.


     5. Run HIDESTR in the same directory as the file LIST, with any
     valid longint on the command line. The longint is the key for
     encrypting the strings, and functions as randseed for the Turbo
     random number generator, whose output is added to the strings to
     encode them byte by byte;

     HIDESTR will generate TP source code for the STRLIST.TPU, which may
     be compiled with the program. The strings will appear in the
     resulting EXE file as arrays of random-appearing bytes.

     The encryption technique is admittedly crude, and you may wish to
     improve on it, but It would take a very determined hacker to take
     the trouble to unscramble this.

program hidestr;  {v 1.2}
{       By Richard Veraa                                        }
{       Villa Maria, Room 211                                   }
{       1050 NE 125 Street                                      }
{       N. Miami, FL  33161                                     }
{          released into the public domain, April 23, 1992      }
uses crt;
const
   key : longint = 1111111;       {default encryption key}
                                   {change to any number}
type
   stringptr = ^string;
   byteptr = ^byte;
   bytearray = array[1..255] of byte;

var
   str : array[1..255] of stringptr;
   l : array[1..255] of byteptr;
   th : array[1..255] of boolean;
   n : integer;
   ba : bytearray;
   i, j : integer;
   f2 : text;
   spacecount : integer;
   x, y : byte;
   keystring : string;
   code : integer;

   procedure crypt(var b : bytearray; l : byte);
    {Add random number to each byte}
      var
         i : integer;
         r : byte;
         save : byte;
      begin
         randseed := key;
         for i := 1 to l do
            begin
               r := random(255);
               b[i] := b[i] + r;
            end;
      end;

   procedure decrypt(var b : bytearray; l : byte);
    {Subtract number from each byte}
      var
         i : integer;
         r : byte;
      begin
         randseed := key;
         for i := 1 to l do
            begin
               r := random(255);
               b[i] := b[i] - r
            end;
      end;

   procedure readfile;
      var
         f : text;
         s : string;
         len, i : integer;
      begin
         n := 0;
         assign(f,'list');
         reset(f);
         while not eof(f) do
            begin
               inc(n);
               read(f,i);   {read line number}
               if i <> n then
                  begin
                     Writeln('Error in LIST.');
                     Writeln('  -- Numbering incorrect at line ',n);
                     Writeln;
                     Halt(n);
                  end;
               readln(f,s);      {read string}
               while s[1] = chr( $20) do  {remove leading blanks}
                  begin
                       len := length(s);
                       dec(len);
                       for i := 1 to len do
                          s[i] := s[i+1];
                       s[0] := chr(len);
                  end;
               str[n]^ := s;
               l[n]^ := length(str[n]^)
            end;
         close(f);
      end;


var
   s : string;

begin
   clrscr;
   writeln('Rich Veraa''s little string hider unit maker');
   writeln('Version 1.2');

   writeln;
   if paramcount > 0 then     {check for key on command line}
      begin
         keystring := paramstr(1);
         val(keystring,key,code);
         if code <> 0 then
            begin
               writeln('Parameter should be key in form longint');
               writeln(' * * * Parameter error ',code,' * * * ');
               writeln;
               halt(code);
            end;
      end;
   x := wherex;
   y := wherey;
   for i := 1 to 255 do   {allocate memory}
      begin
         new(str[i]);
         new(l[i]);
      end;
   for i := 1 to 255 do    {initialize}
      begin
         th[i] := false;
         l[i]^ := 0;
         str[i]^ :='';
      end;
   readfile;              {read LIST}
   for i := 1 to 255 do   {set lengths for arrays to hold strings}
      begin
         for j := 1 to 255 do
            if l[i]^ = j then th[j] := true;
      end;
   assign(f2,'strlist.pas');    {write source code for strlist.pas}
   rewrite(f2);
   writeln(f2,'unit strlist;');

   writeln(f2,'interface');

   writeln(f2,'type');           {type statement}
   writeln(f2,'   bytearray = array[1..255] of byte;');
   for i := 1 to 255 do          {type arrays for encrypted strings}
   if th[i] then  writeln(f2,'   t',i,' = string[',i,'];');

   writeln(f2,'const');
   writeln(f2,'     n = ',n,';');
   writeln(f2,'   key = ',key,';');
   for i := 1 to n do if l[i]^ > 1 then
      begin
        for j := 1 to l[i]^ do      {place string in array of byte}
           ba[j] := ord(str[i]^[j]);
         crypt(ba,l[i]^);           {encrypt bytes in array}
         gotoxy(x,y);
         write('Encrypted ',i,' strings.');
         spacecount := 34;
         write(f2,'   cr',i,' : array[1..',l[i]^,'] of byte = (');
         for j := 1 to l[i]^ do     {list array as constant in strlist.pas}
            begin
               write(f2,ba[j]);
               inc(spacecount,2);
               if ba[j] > 9 then inc(spacecount);
               if ba[j] > 99 then inc(spacecount);
               if (spacecount > 72) and (j < l[i]^) then
                  begin
                     writeln(f2,',');
                     write(f2,'        ');
                     spacecount := 10;
                  end
                     else if j < l[i]^ then write(f2,',');
            end;  {for j}
         writeln(f2,');');
      end;  {for i}
   writeln;
   writeln;
   x := wherex;
   y := wherey;

   writeln(f2,'   procedure decrypt(var b : bytearray; l : byte);');
   for i := 1 to n do if l[i]^ > 1 then
      begin
         writeln(f2,'   function str',i,' : t',l[i]^,';');
      end;

   writeln(f2,'implementation');
                 {write source code for decrypt procedure}

   writeln(f2,'   procedure decrypt(var b : bytearray; l : byte);');
   writeln(f2,'   var');
   writeln(f2,'      i : integer;');
   writeln(f2,'      r : byte;');
   writeln(f2,'   begin');
   writeln(f2,'      randseed := key;');
   writeln(f2,'      for i := 1 to l do');
   writeln(f2,'         begin');
   writeln(f2,'            r := random(255);');
   writeln(f2,'            b[i] := b[i] - r;');

   writeln(f2,'         end;');
   writeln(f2,'   end;');

   for i := 1 to n do if l[i]^ > 1 then
      begin
          {write source code for function to return string}
         writeln(f2,'   function str',i,' : t',l[i]^,';');
         writeln(f2,'      var');
         writeln(f2,'         ba : bytearray;');
         writeln(f2,'         j : integer;');
         writeln(f2,'         s : string;');
         writeln(f2,'      begin');
         writeln(f2,'        for j := 1 to ',l[i]^,' do');
         writeln(f2,'          ba[j] := cr',i,'[j];');
         writeln(f2,'        decrypt(ba, ',l[i]^,');');
         writeln(f2,'        for j := 1 to ',l[i]^,' do');
         writeln(f2,'          s[j] := chr(ba[j]);');
         writeln(f2,'        s[0] := chr(',l[i]^,');');
         writeln(f2,'        str',i,' := s;');
         writeln(f2,'      end;');
         gotoxy(x,y);
         write('String functions coded: ',i);

      end;
   gotoxy(x,y);
   writeln;
   writeln;

   writeln(f2,'begin');

   writeln(f2,'end.');
   close(f2);
   writeln('DONE');
   for i := 1 to 255 do      {dispose}
      begin
         dispose(str[i]);
         dispose(l[i]);
      end;
   writeln;
end.
