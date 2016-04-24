(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0076.PAS
  Description: Re: Hex --> LongInt
  Author: VARIOUS AUTHORS
  Date: 11-25-95  09:26
*)


program hexlong;

const hexstr = '7fffffff';
const hexstr1 = '80000000';

  function Hex2Long(S: string): Longint;
  var
    Temp: Longint;
    Err: Integer;
  begin
    Insert('$',S,1);
    Val(S, Temp, Err);
    Hex2Long := Temp;
  end;

begin
  writeln (hexstr, ' = ', hex2long(hexstr));
  writeln ('MAXLONGINT = ', maxlongint);
  writeln (hexstr1, ' = ', hex2long(hexstr1));
  readln;
end.

------------------------------------------------------------------------

7fffffff = 2147483647
MAXLONGINT = 2147483647
80000000 = -2147483648

------------------------------------------------------------------------

The values output are 100% correct.

Mike Phillips
INTERNET:  phil4086@utdallas.edu


procedure UnsignedStr(L:longint; var S:string); assembler;
var
 TS:array[0..9] of char; { Temp string, it's stored backwards }
asm
 mov di,ds     { Save DS }
 mov si,ss     { Set DS:SI to TS }
 mov ds,si
 lea si,TS[10]
 mov bx,10     { Divide by 10 }
 mov cx,word ptr [L]    { Get L to ax:cx }
 mov ax,word ptr [L+2]
@NotFin:
 xor dx,dx     { Divide ax:cx by 10 to cx:ax, remainder in dx }
 div bx
 xchg ax,cx
 div bx
 add dl,48     { Convert remainder to ASCII }
 dec si
 mov [si],dl   { Save in TS }
 xchg ax,cx    { Swap ax and cx to prepare for next divide }
 or ax,ax      { Already zero? }
 jnz @NotFin   { No -> continue }
 or cx,cx      { Also for high word... }
 jnz @NotFin
 lea cx,TS[10] { Get length of string }
 sub cx,si
 mov dx,di     { Move saved DS to dx }
 les di,S      { Get pointer of result string }
 cld
 mov al,cl     { Store length }
 stosb
 rep movsb     { Copy ASCII string }
 mov ds,dx     { Restore DS }
end;

var
 I:longint;
 J:integer;
 S:string;
begin
 Val('$FFFFFFFF',I,J);
 UnsignedStr(I,S);
 WriteLn(S,',',J);
end.

Function Hex2Long(S:String):LongInt; Assembler; 
 
Asm 
           les di,[S]
           xor bx,bx 
           mov dx,bx 
           mov cl,[es:di] 
           inc di 
@@CnvLoop: mov al,[es:di]
           inc di 
           mov ah,'0' 
           cmp al,'9' 
           jbe @@Cnv2Num 
                  mov ah,'a'+10     
                  cmp al,'a' 
                  jae @@Cnv2Num 
           mov ah,'A'+10
@@Cnv2Num: sub al,ah 
           shl dx,4 
           mov ch,bh 
           shr ch,4
           add dl,ch 
           shl bx,4 
           add bl,al 
           dec cl 
           jnz @@CnvLoop 
           mov ax,bx 
End; 
 
This is untested, off-the-top-of-my-head code, but it should work.  If
it doesn't just let me know and I will write a tested version for you.

John Baldwin
jbaldwin@freedomnet.com

{----------------------------------------------------------------}

PROGRAM Hexadecimal_To_Long_Converter;

USES Crt;

FUNCTION IsXDigit(CONST c: char): boolean;
{ -- TRUE iff C is a hexadecimal digit, i.e.
  -- C IN ['A' .. 'F', 'a' .. 'f', '0' .. '9']. }
INLINE($5B/$80/$FB/$30/$72/$21/$80/$FB/$39/$77/$02/$EB/$16/$80/$FB/$41/$72/
       $07/$80/$FB/$46/$77/$02/$EB/$0A/$80/$FB/$61/$72/$09/$80/$FB/$66/$77/
       $04/$B0/$01/$EB/$02/$B0/$00);

{ -- Oh alright, I copied the above routine from one of my units ... }

FUNCTION HexChar2Byte(CONST c: char): byte;
{ -- Convert a hex digit to its decimal value.
  -- Note: no argument checking. }
BEGIN IF c IN ['0' .. '9']
      THEN HexChar2Byte:=byte(c) - 48
      ELSE HexChar2Byte:=byte(upcase(c)) - 55
END;

TYPE str8 = STRING[8];  { -- Hex strings in TP cannot exceed 8 characters. }

FUNCTION Hex2Long(CONST St: str8; VAR longvalue: longint): boolean;
{ -- Will attempt to convert a hexadecimal string to its decimal value.
  -- If this is succesful, the function result is TRUE, and the computed
  -- value is in LONGVALUE.
  -- If the routine fails (i.e, ST contains bad characters), FALSE is
  -- returned and LONGVALUE is undefined. }
VAR power_of_16: longint;
    j          : byte;
BEGIN Hex2Long:=FALSE;  { -- Assume failure. }
      FOR j:=1 TO length(St) DO IF NOT IsXDigit(St[j]) THEN exit;

      {$Q-  -- Necessary but harmless. }
      longvalue:=0; power_of_16:=1;
      FOR j:=length(St) DOWNTO 1
      DO BEGIN inc(longvalue, HexChar2Byte(St[j]) * power_of_16);
               power_of_16:=power_of_16 * 16
         END;
      {$Q+  -- "Pop all your pushes". }

      Hex2Long:=TRUE
END;

{ -- Main: }

VAR St: str8;
    L : longint;

BEGIN clrscr;
      REPEAT gotoxy(1, 2); ClrEol;
             write('Hex-string: '); readln(St);
             gotoxy(20, 2);
             IF Hex2Long(St, L)
             THEN write(' --> ', L:1)
             ELSE write(#7'Not a hex number ...');
             readkey
      UNTIL St = ''
END.

The principle is this:

decimal: 357 = 7*10^0 + 5*10^1 + 3*10^2
hex    : a9f = f*16^0 + 9*16^1 + a*16^2

in which "^" is the exponentiation operator.

For the mathematically challenged among you:
X^0 = 1 (any X), and X^1 = X (ditto).

{-------------------------------------   LEE BARKER -------------------- }
function hex2bin (s:string):longint;
  const h : array[0..15] of char = '0123456789ABCDEF';
        i,j : integer;
        x : longint;
  begin
    x := 0;
    for i := 1 to length(s) do
    begin
      j := pos(upcase(s[i]),h) -1;
        if j<0 then exit;             { error in str }
        if x and $F0000000 <> 0 then exit; { overflo }
      x := (x shl 4) + j;
    end;
    hex2bin := x;
  end;

