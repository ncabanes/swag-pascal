(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0086.PAS
  Description: Complete HEX to BIN unit
  Author: EMIL MIKULIC
  Date: 01-02-98  07:33
*)

unit hex;

interface

const hexset : set of char = ['0'..'9','A'..'F'];
      hexChars: array [0..$F] of Char = '0123456789ABCDEF';

type bytestr=string[2];
     wordstr=string[4];
      binstr=string[8];

function Byte2Str(b: byte):bytestr;
function Word2Str(w: Word):wordstr;
function Bin2Str(b:byte):binstr;
function Str2Bin(s:binstr):byte;
function Str2Byte(s:bytestr; var c:boolean):byte;
function Str2Word(s:wordstr; var c:boolean):word;

implementation

{ --------------------------------------------------------------------
  BYTE2STR (modification of WORD2STR)
  by Emil Mikulic

  Input:
   b - a byte

  Output:
   string - the hex string of b
  -------------------------------------------------------------------- }
function Byte2Str(b: byte):bytestr;
var temp:bytestr;
begin
 temp:='00';
 temp[1]:=hexChars[b shr 4];
 temp[2]:=hexChars[b and $F];
 Byte2Str:=temp;
end;

{ --------------------------------------------------------------------
  WORD2STR (in the help)
  by Emil Mikulic

  Input:
   b - a word

  Output:
   string - the hex string of b
  -------------------------------------------------------------------- }
function Word2Str(w: Word):wordstr;
var temp:wordstr;
begin
 temp:='0000';
 temp[1]:=hexchars[hi(w) shr 4];
 temp[2]:=hexchars[hi(w) and $F];
 temp[3]:=hexchars[lo(w) shr 4];
 temp[4]:=hexchars[lo(w) and $F];
 Word2Str:=temp;
end;

{ --------------------------------------------------------------------
  BIN2STR
  by Emil Mikulic

  Input:
   b - a byte

  Output:
   string - the binary string of b
  -------------------------------------------------------------------- }
function Bin2Str(b:byte):binstr;
var temp:binstr;
begin
 temp:='00000000';
 if (b and 128>0) then temp[1]:='1';
 if (b and  64>0) then temp[2]:='1';
 if (b and  32>0) then temp[3]:='1';
 if (b and  16>0) then temp[4]:='1';
 if (b and   8>0) then temp[5]:='1';
 if (b and   4>0) then temp[6]:='1';
 if (b and   2>0) then temp[7]:='1';
 if (b and   1>0) then temp[8]:='1';
 Bin2Str:=temp;
end;

{ --------------------------------------------------------------------
  STR2BIN
  by Emil Mikulic

  Input:
   s - a string

  Output:
   byte - the numerical value of binary string s

  Notes:
   STR2BIN is the counterpart of BIN2STR
  -------------------------------------------------------------------- }
function Str2Bin(s:binstr):byte;
var y:byte;
begin
 y:=0;
 if s[1]='1' then y:=y or 128;
 if s[2]='1' then y:=y or 64;
 if s[3]='1' then y:=y or 32;
 if s[4]='1' then y:=y or 16;
 if s[5]='1' then y:=y or 8;
 if s[6]='1' then y:=y or 4;
 if s[7]='1' then y:=y or 2;
 if s[8]='1' then y:=y or 1;
 Str2Bin:=y;
end;

{ --------------------------------------------------------------------
  STR2BYTE
  by Emil Mikulic

  Input:
   s - a string
   c - a variable boolean

  Output:
   byte - the numerical value of hex (byte) s
   c - (modified) true if ok, false if error in conversion
       (such as illegal char being used)

  Notes:
   STR2BYTE is the counterpart of BYTE2STR
  -------------------------------------------------------------------- }
function Str2Byte(s:bytestr; var c:boolean):byte;
var temp:byte;
    i:integer;
begin
 temp:=0;
 c:=true;

 for i:=1 to 2 do if not (s[i] in hexset) then c:=false;

 case s[1] of
   '0': temp:=0;
   '1': temp:=1;
   '2': temp:=2;
   '3': temp:=3;
   '4': temp:=4;
   '5': temp:=5;
   '6': temp:=6;
   '7': temp:=7;
   '8': temp:=8;
   '9': temp:=9;
   'A': temp:=10;
   'B': temp:=11;
   'C': temp:=12;
   'D': temp:=13;
   'E': temp:=14;
   'F': temp:=15;
   end;

 temp:=(temp*16);

 case s[2] of
   '0': temp:=temp+0;
   '1': temp:=temp+1;
   '2': temp:=temp+2;
   '3': temp:=temp+3;
   '4': temp:=temp+4;
   '5': temp:=temp+5;
   '6': temp:=temp+6;
   '7': temp:=temp+7;
   '8': temp:=temp+8;
   '9': temp:=temp+9;
   'A': temp:=temp+10;
   'B': temp:=temp+11;
   'C': temp:=temp+12;
   'D': temp:=temp+13;
   'E': temp:=temp+14;
   'F': temp:=temp+15;
   end;

 Str2Byte:=temp;
end;

{ --------------------------------------------------------------------
  STR2WORD
  by Emil Mikulic

  Input:
   s - a string
   c - a variable boolean

  Output:
   word - the numerical value of hex (word) s
   c - (modified) true if ok, false if error in conversion
       (such as illegal char being used)

  Notes:
   STR2WORD is the counterpart of WORD2STR
  -------------------------------------------------------------------- }
function Str2Word(s:wordstr; var c:boolean):word;
var temp:byte;
    temp2:byte;
    temp3:word;
    i:integer;
begin
 temp:=0;
 temp2:=0;
 temp3:=0;
 c:=true;

 for i:=1 to 4 do if not (s[i] in hexset) then c:=false;

 case s[1] of
   '0': temp:=0;
   '1': temp:=1;
   '2': temp:=2;
   '3': temp:=3;
   '4': temp:=4;
   '5': temp:=5;
   '6': temp:=6;
   '7': temp:=7;
   '8': temp:=8;
   '9': temp:=9;
   'A': temp:=10;
   'B': temp:=11;
   'C': temp:=12;
   'D': temp:=13;
   'E': temp:=14;
   'F': temp:=15;
   end;

 temp:=(temp*16);

 case s[2] of
   '0': temp:=temp+0;
   '1': temp:=temp+1;
   '2': temp:=temp+2;
   '3': temp:=temp+3;
   '4': temp:=temp+4;
   '5': temp:=temp+5;
   '6': temp:=temp+6;
   '7': temp:=temp+7;
   '8': temp:=temp+8;
   '9': temp:=temp+9;
   'A': temp:=temp+10;
   'B': temp:=temp+11;
   'C': temp:=temp+12;
   'D': temp:=temp+13;
   'E': temp:=temp+14;
   'F': temp:=temp+15;
   end;

 case s[3] of
   '0': temp2:=0;
   '1': temp2:=1;
   '2': temp2:=2;
   '3': temp2:=3;
   '4': temp2:=4;
   '5': temp2:=5;
   '6': temp2:=6;
   '7': temp2:=7;
   '8': temp2:=8;
   '9': temp2:=9;
   'A': temp2:=10;
   'B': temp2:=11;
   'C': temp2:=12;
   'D': temp2:=13;
   'E': temp2:=14;
   'F': temp2:=15;
   end;

 temp2:=temp2*16;

 case s[4] of
   '0': temp2:=temp2+0;
   '1': temp2:=temp2+1;
   '2': temp2:=temp2+2;
   '3': temp2:=temp2+3;
   '4': temp2:=temp2+4;
   '5': temp2:=temp2+5;
   '6': temp2:=temp2+6;
   '7': temp2:=temp2+7;
   '8': temp2:=temp2+8;
   '9': temp2:=temp2+9;
   'A': temp2:=temp2+10;
   'B': temp2:=temp2+11;
   'C': temp2:=temp2+12;
   'D': temp2:=temp2+13;
   'E': temp2:=temp2+14;
   'F': temp2:=temp2+15;
   end;

 temp3:=temp*256+temp2;

 Str2Word:=temp3;
end;

{var x:boolean;
begin
 clrscr;
 writeln(word2str($1234));
 writeln(word2str($ABCD));
 writeln(byte2str($CA));
 writeln(bin2str(255));
 writeln(bin2str(128));
 writeln(bin2str(15));
 writeln(bin2str(16));
 writeln;
 writeln(Byte2Str(Str2Bin(Bin2Str(255))));
 writeln;
 writeln(Str2Byte('AB',x));
 writeln;
 writeln(Str2Word('1234',x));}
end.
