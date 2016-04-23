{
The example that changes color and echos '*'s is nice, but does it compensate
for delete/backspace/enter keypresses?

The one I posted was intended when I wrote it to be a UNIX like password
input, where the cursor just sits there and doesn't react.

Does anyone want a simple password entry/encryption unit?

(I'll give it to you anyways.. ) :)

--CUT HERE-- }
unit crypt;
{AmoebOS v1.0 - Password/Cryyptography unit}

{Simple password entry and encryption routines}
{(C)1994 Matt Sottile/RAMSoft! Freeware}
{Please notify the author if you use or modify this unit in any way}
{Internet mail : matts@caeser.geog.pdx.edu or matts@psg.com}
{                ramsoft@industrial.com}

interface

function noecho(pmt : string) : string;
function pwcrypt(op : string) : string;

implementation

uses Crt, Dos;

function noecho(pmt : string) : string;
var
 ch : char;
 d : boolean;
 temp, st : string;
begin
 write(pmt);
 d := false;
 temp := '';
 st := '';
 repeat
  temp := st;
  repeat until keypressed;
  ch := readkey;
  if (ch = chr(8)) then st := temp;
  if (ch = chr(13)) then d := true;
  if not ((ch = chr(8)) and (ch = chr(13))) then st := st+ch; 
 until d = true;
 noecho := temp;
 writeln;
end;

function pwcrypt(op : string) : string;
var
 ptr : integer;
 ip : string;
begin
 ip := '';
 ptr := 1;
 repeat
  ip := ip+chr(((ord(op[ptr])+ord(op[length(op)-ptr]) xor length(op))));
  ip[ptr] := chr(ord(ip[ptr])+2);
  inc(ptr);
 until ptr = length(op)+1;
 pwcrypt := ip;
end;

begin
end.

