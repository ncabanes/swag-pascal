(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0071.PAS
  Description: Misc. String Functions
  Author: J. TAL
  Date: 01-27-94  17:41
*)

Unit Funcs;

(* previously  All_Func.Inc *)

(*    05/02/1988     J Tal
                     Rollins Medical/Dental Systems
        
                     Public Domain
*)


Interface
  Uses Dos,Crt;


  TYPE
    st255 = string[255];

  Function Word_Int(r: REAL) : INTEGER;

  Function Word_Real(i: INTEGER) : REAL;

  Function Real_Mod(a,b: REAL) : REAL;
    (*  modulus for two real numbers  

        Real_Mod(15.0,2.0)  =  1.0

    *)

  function lowcase(c : char) : char;
    (*  opposite of upcase 

        lowcase('A') = 'a'
        lowcase('b') = 'b'
        
    *)

  function f_buf_conv( x : st255) : st255;
    (*  convert a file buffer into a string *)

  procedure prog_chain(prog : st255); (* dummy *)

  function spaces(num : integer) : st255;
    (*  like basic space$ 

        spaces(10) = '          '

    *)

  function bakfile( name : st255) : st255;
    (*  takes filename and returns .BAK version of that name 

        bakfile('test.dat')  = 'test.bak'

    *)

  function bool(x : boolean) : integer;
    (*  True becomes -1, False becomes 0 

        bool(true) = -1
        bool(false) = 0

    *)

  function center ( line : st255) : integer;
    (*  returns x location to print the line/string at to center it 

        center('HELP') = 38
        gotoxy(center(message),y);  write(message);


    *)      

  function fill(n,char : integer) : st255;
    (*  fill string to n characters with chr(char)  
        like basic string$  

        fill(10,65) = 'AAAAAAAAAA'

    *)

  function fnline( curline : st255) : st255;
    (*  isolate leading number from a line 

        fnline('255  IF X = 255 THEN GOTO')  = 255

    *)

  function fnmax(a,b : integer) : integer;
    (*   max of two integers 

         fnmax(4,5) = 5

    *)

  function fnmin(a,b : integer) : integer;
    (*   min of two integers

         fnmin(-9,5) = -9

    *)

  function lpad(ch : st255; num : integer) : st255;
    (*   left pad the string ch with spaces to num length 


         lpad('HELP',10) = '      HELP'

   *)

  function ltrm ( curline : st255) : st255;
    (*   remove leading spaces from curline  

         ltrm('        HELP') = 'HELP'

    *)

  function peek(seg,ofs : integer) : integer;
    (*   like basic peek 

         x := peek(segment,offset);
    
    *)

  procedure poke(seg,ofs,v : integer);
    (*   like basic poke  

         poke(screen_seg,ofs,character)

    *)

  function power(x,n : integer) : integer;
    (*   x^n

          power(2,4) = 16

    *)

  function rpad(ch : st255; num : integer) : st255;
    (*   right pad ch to num length with spaces  

         rpad('THIS',10) = 'THIS      '

    *)

  function rpt(num,ch : integer) : st255;
    (*   like basic string$  

         rpt(10,67) = 'CCCCCCCCCC'

    *)

  function rtrm(ch : st255) : st255;
    (*    remove trailing spaces from string ch 

          rtrm('ROYAL    ') = 'ROYAL'

    *)

  function srep(ch,dh,eh : st255): st255;
    (*    srep=string replace
          replace all occurances of string dh with eh in string ch  


          srep('THE CAT','CAT','FAT') = 'THE FAT'

    *)
  
  procedure s_swap(var a1,a2 : st255);
    (*    string swap, swap a1 & a2 

          a1 = 'MAMA'
          a2 = 'DADDY'

          s_swap(a1,a2)

          a1 = 'DADDY'
          a2 = 'MAMA'

    *)

  function fnxtrm( s : st255) : st255;
    (*    if string s is all blanks, then returns '' null string 

           fnxtrm('      g   ') = ' '
           fnxtrm('          ') = ''

    *)

  function fnval( curline : st255) : integer;
    (*    converts string representation of number to integer 

          fnval('123 ') = 123

    *)

  function fns ( a1 : integer) : st255;
    (*   converts integer to string representation  

         fns(1234) = '1234'

   *)

  function left_str( curline : st255; i : integer) : st255;
    (*   take i characters from curline starting at the left 

         left_str('THE QUICK BROWN',9) = 'THE QUICK'

    *)

  function right_str( curline : st255; i : integer) : st255;
    (*   take i characters from curline starting at the right 

         right_str('THE QUICK BROWN',9) = 'ICK BROWN'
    *)

  procedure mid_str_assign( var modify_string : st255; s_start,s_len : integer; ins_string : st255);
    (*   mid string assignment
         mid_str_assign('flemish',1,2,'bl') = 'blemish';  
                                  ^ starting a character 1
                                    ^ for a length of two 
                                       ^ make those chars 'bl'

         mid_str_assign('abcdefg',2,2,'BC') = 'aBCdefg'
    *)
   
  function hex_str(hex: INTEGER) : st255;
     (*  hexadecimal string representation of decimal integer 

         hex_str(123) = '7B'

     *)

  function hex_val(hex: st255) : INTEGER;
     (*  reverse of hex_str,  integer representation of hexadecimal string 

         hex_val('7B') = 123

     *)

  function bin_str(bin: INTEGER) : st255;
     (*  binary string representation of integer  

         bin_str(123) = '1111011';
     *)

  FUNCTION InKey(VAR Special : BOOLEAN; VAR Keychar : CHAR) : BOOLEAN;
     (*  checks for keypressed, returns type and character *)

  function fnzero (num : st255 ; places : integer) : st255;
     (*  left '0' pad a number into a string 

         fnzero('123',10) = '0000000123'

     *)

  function fns_z(n : integer) : st255;
     (*  left '0' pad a number into a 2 digit string 

           fns_z(1) = '01'
         fns_z(45) = '45'
     *)

  Function bit_blast(bit_stream: st255) : INTEGER;
     (*  reverse of bin_str, integer representation of binary string 

         bit_blast('1110001') = 113
     *)

  Function printusing (mask : st255; number : real) : st255;
     (*

             printusing('###,###.##',19.95) = '     19.95'
           printusing('###,###.##CR,-19.95) = '     19.95CR'

     *)


  Procedure UpStr(VAR a: st255);
     (*  Upcase a whole string 

         UpStr('The cat Mildred') = 'THE CAT MILDRED'

     *)



Implementation




Function Word_Int;
(*  (r: REAL) : INTEGER; *)

BEGIN  
  IF r > 32767.0 THEN
    Word_int := Trunc(r - 65536.0)
  ELSE
    Word_int := Trunc(r);
END;


Function Word_Real;
(* (i: INTEGER) : REAL; *)
BEGIN
  IF i < 0 THEN
    Word_Real := i + 32767.0
  ELSE
    Word_Real := i;
END;


Function Real_Mod;
(*  (a,b: REAL) : REAL; *)
BEGIN
  WHILE a > b DO begin
     a := a - b;
  END;
  Real_Mod := a;
END; (* Real_Mod *)


function lowcase;
(* (c : char) : char; *)
var
c1 : integer;
begin
c1 := ord(c);
 if (c1 > 64) and (c1 < 91)  {only change A-Z to a-z}
  then
   c1 := c1 + 32;
lowcase := chr(c1);
end;


function f_buf_conv;
(*  ( x : st255) : st255; *)
var
 i : integer;
 temp : st255;
begin
 temp := '';
 temp := x[0] + copy(x,1,length(x));
 f_buf_conv := temp;
end;


procedure prog_chain;
(* (prog : st255); *) (* dummy *) 
begin
halt;
end;


function spaces;
(* (num : integer) : st255; *)
  var
    sp1 : integer;
    space : st255;
  begin
    space := '';
    for sp1 := 1 to num do
        space := space + ' ';
    spaces := space;
  end;

  { ------------------- }

function bakfile;
(* ( name : st255) : st255; *)
var
  a1 : integer;
begin
  a1 := pos('.',name);
  if a1 = 0 then
    bakfile := name + '.BAK'
   else
  bakfile := copy(name,1,a1) + 'BAK';
end;

  { ------------------- }

function bool;
(* (x : boolean) : integer; *)
begin
   if x then bool := -1
      else bool := 0
end;

  { ------------------- }

function center;
(*  ( line : st255) : integer; *)
var
  a1 : integer;
begin
  a1 := length(line);
  center := trunc(39-(a1 div 2));
end;

  { ------------------- }

function fill;
(* (n,char : integer) : st255; *)
var i : integer;
begin
    for i := 1 to n do
        fill[i] := chr(char)
end;

  { ------------------- }

function fnline;
(*  ( curline : st255) : st255; *)
var
a1 : integer;
a1s : st255;
begin
 a1 := pos(' ',curline);
 a1s := copy(curline,1,a1);
 fnline := a1s;
end;

  { ------------------- }

function fnmax;
(* (a,b : integer) : integer; *)
begin
   fnmax := a-bool(b>a)*(b-a)
end;

  { ------------------- }

function fnmin;
(* (a,b : integer) : integer; *)
begin
   fnmin := a+bool(a>b)*(a-b)
end;

  { ------------------- }

function lpad;
(* (ch : st255; num : integer) : st255; *)
  var
    sp1 : integer;
    sp2 : integer;
  begin
    sp1 := length(ch);
    sp2 := num - sp1;
    lpad := spaces(sp2) + ch;
  end;

  { ------------------- }

function ltrm;
(*  ( curline : st255) : st255; *)
begin
 while curline[1] = ' ' do
  curline := copy(curline,2,255);
ltrm := curline;
end;

  { ------------------- }

function peek;
(* (seg,ofs : integer) : integer; *)
begin
 peek := mem[seg:ofs];
end;

  { ------------------- }

procedure poke;
(* (seg,ofs,v : integer); *)
begin
 mem[seg:ofs] := v;
end;

  { ------------------- }

function power;
(* (x,n : integer) : integer; *)
begin
   if n = 1
      then power := x
      else power := x*power(x,n-1)
end;


  { ------------------- }

function rpad;
(* (ch : st255; num : integer) : st255;        *)
  begin
    rpad := copy(ch + spaces(num),1,num);
  end;

  { ------------------- }

function rpt;
(* (num,ch : integer) : st255; *)
  var
    sp1 : integer;
    space : st255;
  begin
    space := '';
    for sp1 := 1 to num do
        space := space + chr(ch);
    rpt := space;
  end;

  { ------------------- }

function rtrm;
(* (ch : st255) : st255; *)
  var
    sp1 : integer;
    sp2 : integer;
  begin
    sp1 := length(ch);
    sp2 := sp1;
    while (ch[sp2] = ' ') and (sp2 <> 0) do
        sp2 := sp2 - 1;
    rtrm := copy(ch,1,sp2);
  end;

  { ------------------- }


function srep;
(* (ch,dh,eh : st255): st255; *)
  var
    sp1 : integer;
    sp2 : integer;
    sp3 : integer;
    sp4 : integer;
    sp5 : integer;
    atemp : st255;
    btemp : st255;
    ctemp : st255;
  begin
    sp1 := length(ch);
    sp2 := length(dh);
    sp3 := length(eh);
    while pos(dh,ch) <> 0 do
    begin
      sp4 := pos(dh,ch);
      sp5 := sp1 - (sp4 + sp2) + 1;
         atemp := copy(ch,1,sp4-1);
         btemp := copy(ch,sp4+sp2,sp5);
         ctemp := atemp + eh + btemp;
         ch := ctemp;
   end;
srep := ch;
end;

  { ------------------- }

procedure s_swap;
(* (var a1,a2 : st255);        *)
var
  temp : st255;
begin
  temp := a1;
  a1 := a2;
  a2 := temp;
end;

  { ------------------- }

function fnxtrm;
(* ( s : st255) : st255; *)
 begin
  fnxtrm := spaces(1+bool(s = spaces(length(s))))
 end;

  { ------------------- }

function fnval;
(* ( curline : st255) : integer; *)
var
 err,a1 : integer;
begin
 while copy(curline,1,1) = '' do
   curline := copy(curline,2,255);
 val(curline,a1,err);
 fnval := a1;
end;

  { ------------------- }

function fns;
(* ( a1 : integer) : st255; *)
var
 a1s : st255;
begin
 str(a1,a1s);
 fns := a1s;
end;

function left_str;
(* ( curline : st255; i : integer) : st255; *)
begin
 left_str := copy(curline,1,i);
end;

  { ------------------- }

function right_str;
(* ( curline : st255; i : integer) : st255; *)
var
 l : integer;
begin
 l := length(curline);
 right_str := copy(curline,l-i+1,i);
end;

  { ------------------- }

{
 format for mid_str_assign

 basic - mid$(s$,12,12) = mid$(f$,4,12)

 pascal -  mid_str_assign(s_str,12,12,copy(f_str,4,12));
        or
           mid_str_assign(s_str,12,12,'123456789012');
}

  { ------------------- }

procedure mid_str_assign;
(* ( var modify_string : st255; s_start,s_len : integer; ins_string : st255); *)
begin
  delete(modify_string,s_start,s_len);
  insert(ins_string,modify_string,s_start);
end;

  { ------------------- }

function hex_str(hex: INTEGER) : st255;
VAR
  hex_out: st255;
  hex_temp: INTEGER;
  hex_mas: st255;
BEGIN
  hex_mas := '0123456789ABCDEF';
  hex_out := '';
  WHILE hex > 0 DO begin
    hex_temp := hex AND 15;
    hex_out := hex_mas[hex_temp+1] + hex_out;
    hex := hex DIV 16;
  END;
  FOR hex_temp := 1 to 2 DO begin
    IF length(hex_out) < 2 then hex_out := '0' + hex_out;
  END;
  hex_str := hex_out;
END;

  { ------------------- }

function hex_val;
(* (hex: st255) : INTEGER; *)
VAR
  hex_out: INTEGER;
  hex_temp: INTEGER;
  hex_mas: st255;
BEGIN
  hex_mas := '0123456789ABCDEF';
  hex_out := 0;
  WHILE length(hex) > 0 DO begin
    hex_temp := Pos(hex[1],hex_mas);
    hex_out := hex_out * 16 + (hex_temp)-1;
    hex := copy(hex,2,255);
  END;
  hex_val := hex_out;
END;

  { ----------------- }

function bin_str;
(* (bin: INTEGER) : st255; *)
VAR
  bin_out: st255;
  bin_temp: INTEGER;
BEGIN
  bin_out := '';
  WHILE bin <> 0 DO begin
    bin_temp := bin AND 1;
    IF bin_temp = 1 THEN
       bin_out := '1' + bin_out
    ELSE
       bin_out := '0' + bin_out;

    bin := bin shr 1;
  END;
  bin_str := bin_out;
END;

  { ------------------- }

FUNCTION InKey;
(* (VAR Special : BOOLEAN; VAR Keychar : CHAR) : BOOLEAN; *)
VAR
  Dosrec : Dos.Registers;
BEGIN
  IF Crt.KeyPressed THEN begin
        Dosrec.AX := $0800;
        MSDOS(DosRec);
        KEYCHAR := CHR(LO(DOSREC.AX));
        INKEY := TRUE;
        IF ORD(KEYCHAR) = 0
           THEN
              BEGIN
                SPECIAL := TRUE;
                DOSREC.AX := $0800;
                MSDOS(DosRec);
                KEYCHAR := CHR(LO(DOSREC.AX));
              END
            ELSE SPECIAL := FALSE;
       END
      ELSE
      BEGIN
        INKEY := FALSE;
        SPECIAL := FALSE;
      END;
 END;

  { ------------------- }

function fnzero;
(* (num : st255 ; places : integer) : st255; *)
var
 a1s : st255;
 a1 : integer;
begin
 a1 := length(num);
 a1s := rpt(places-a1,48) + num;
 fnzero := a1s;
end;

  { ------------------- }


function fns_z;
(* (n : integer) : st255; *)
var
 c : st255;
begin
  c := fns(n);
  if length(c) = 1
   then
    c := '0' + c;
  fns_z := c;
end;

  { ------------------- }

Function bit_blast;
(* (bit_stream: st255) : INTEGER; *)
 (* convert string representation of bits into integer: '1001' becomes 9 *)
VAR
  i,bit_box : INTEGER;
BEGIN
  bit_box := 0;
  FOR i := Length(bit_stream) DOwnTO 1 DO  BEGIN
    IF bit_stream[i] = '1' THEN begin
       bit_box := bit_box + (1 shl ((Length(bit_stream) - i)));
    END;
  END;
  bit_blast := bit_box;
END;

  { ------------------- }

Function printusing;
(* (mask : st255; number : real) : st255; *)

const
     comma : char = ',';
     point : char = '.';
     minussign : char = '-';

VAR
     fieldwidth, IntegerLength, i, j, places,pointposition : INTEGER;
     usingcommas, decimal, negative : boolean;
     outstring, IntegerString       : string[80];

BEGIN
     negative    := number < 0;
     number      := abs(number);
     places      := 0;
     if pos('CR',mask) = 0
      then
        fieldwidth  := length(mask)
      else
        fieldwidth := length(mask) - 2;

     usingcommas := pos(comma,mask) > 0;
     decimal     := pos(point,mask) > 0;

     if decimal then
          BEGIN
              pointposition := pos(point,mask);
              places        := fieldwidth - pointposition
              END;
     str( number : 0 : places, outstring);

     if usingcommas then
         BEGIN
              j := 0;
              IntegerString := copy(outstring, 1, length( outstring ) - places );
              IntegerLength := length( IntegerString );
              if decimal then
                   IntegerLength := IntegerLength -1;
              FOR i := IntegerLength DOwnto 2 DO
                   BEGIN
                     j := j + 1;
                     if j mod 3 = 0 then
                          insert ( comma, outstring, i )
                   end
              END;


    if length(outstring) < fieldwidth
      then
        outstring := spaces(fieldwidth - length(outstring)) + outstring;

     if (negative)
      then
       if (pos('CR',mask) <> 0)
        then
          outstring := outstring + 'CR'
        else
          outstring := minussign + outstring;


    printusing := outstring;


END; (* printusing *)


Procedure UpStr;
VAR
  i : Integer;
BEGIN
  For i := 1 TO Length(a) DO
     a[i] := UpCase(a[i]);

END;

END.


