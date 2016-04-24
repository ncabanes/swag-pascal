(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0204.PAS
  Description: Various Useful Routines
  Author: ZAK SMITH
  Date: 08-30-97  10:09
*)


{ Unit for Common Interface Routines }

Unit ETC;
{$O+}

(************) interface (*************)

type carriertype = function:boolean;

 var
    ANSI       : Boolean;
    useinsert  : boolean;
    CapsOn     : Boolean;
    PortCheck  : Boolean;
    carrierfunc: carriertype;




Type pwtype = array[1..3] of word;

type dofiletype = function(fn:string):boolean;

attribtype = 1..24;
attribset = set of attribtype;    { access attribute set A-X }

function trimch(s:string;c:char):string;

function sizeoffilespec(s:string):longint;

procedure CopyFile(s,d:string);

function Rows:byte;
function columns:byte;

procedure ungetch(key:word);

function xpos(sub:char;main:string;x:byte):byte;
function StripSpaces(s:string):string;

procedure printscreen;
function AttribStr(a:attribset):string;

function rjustify(s:string;l:byte):string;

{Function HexStr(n:longint):string;}

Procedure KillFileSpec(p:string);

function Byte2Hex(numb : byte): string;       { Converts byte to hex string }
function Word2Hex(numb: word): string;        { Converts word to hex string.}
function Long2Hex(L: longint): string;     { Converts longint to hex string }

function base36(n:longint):string;
function SplitFilePath(s:string):string;
function SplitFileExt (s:string):string;
function SplitFileName(s:string):string;
procedure Longhash(s:string;var r:pwtype);

function  numtowords(n:word):string;
procedure prunedir(p:string);
function  DtTmStamp: string;

function  tostr2(s:longint;b:byte):string;

procedure movefile(fp:string;td:string);
function  ToStr(s: longint): string;

function  tostrb(var s:byte):string;
function  CurTimestr: string;
procedure PR(t: string);
procedure Newline;
procedure ColorFG(c: byte);
procedure ColorBG(c: byte);
procedure PhoneEditor(var AnswerForMain: string; prestring: string;fgc,bgc:byte);
procedure Editor(maxlen: byte; var Answerformain: string; prestring: string;fgc,bgc:byte);
procedure Setup_Output;
procedure ShowMC(Ch: char);
procedure GetChoice(numofchoices: byte; Choices: string;fgc,bgc,oc:byte; var Reply: byte);
procedure ClearScreen;
function  Key: char;
function  lowcase(ch: char): char;
function  casestr(s: string): string;
function  Ltab(n: integer;m:integer):string;
function  Ltabc(n,m:integer;c:char):string;

function  UpcaseStr(s:string):String;
function  lowcasestr(s:string):string;

function  ExistFile(s: string;flags:word): Boolean;

function  compare(s1,s2:string):byte;
Procedure CursorOff;
Procedure CursorOn;
function  Rtrim(s:string):string;
function  ltrim(s:string):string;
procedure beep(Hz,Ms:word);
{function  carrier_on:boolean;}
procedure CurTime(var h:word; var m: word;var s:word);
function  SecondsSinceMidnight(h,m,s:word):longint;
function  nowsecondssincemidnight: longint;
function ShortPath(s:string):string;

function nowmins: word;

function toint(s:string):word;

function tolong(s:string):longint;

function CRC32Array(p:pointer;l:longint):longint;

FUNCTION UpdCrc(cp: BYTE; crc: WORD): WORD;
FUNCTION UpdC32(octet: BYTE; crc: LONGINT) : LONGINT;

function DVLoaded:boolean;

function Hex2Byte(s:string):byte;


function int2comma(l:longint;b:byte):string;

Procedure wordCrypt(P: pointer;l:word;progcode:string);

procedure throughfiles(filespec:string;df:dofiletype);

function FindStrInarRay(var buf;l:word;fs:string):word;

Function Power(b,e:longint):longint;

function C2Pas(var s):string;

function nthoc(c:char;b:byte;s:string):byte;

procedure SetFlag(i:word;var a);

function readflag(i:word;var a):boolean;

function barepasswdinput(m:byte): string;


(************) Implementation (***************)

uses crt,dos;


function barepasswdinput(m:byte): string;
  var s:string;
      c:char;
  begin
  s:='';

  repeat
    begin
    repeat
      if portcheck then
        if not carrierfunc then
         begin
         Exit;
         end
    until keypressed;
    c:=readkey;
    case c of
      #8: if length(s)>0 then
            begin
            write(#8+' '+#8);
            dec(byte(s[0]));
            end;

      ' '..'~': if length(s)<m then
                  begin
                  s:=s+c;
                  write('.');
                  end;
      end
    end
  until c=#13;
  barepasswdinput:=s;
  end;


procedure SetFlag(i:word;var a);
 var temp: byte;
begin { i is bit to be set }
i:=i-1; { 1st bit is offset 0 }
temp := i DIV (1 * 8);
mem[seg(a):ofs(a)+temp] := mem[seg(a):ofs(a)+temp] OR Power(2,i);
end;


function readflag(i:word;var a):boolean;
 var temp: byte;
begin { i is bit to be set }
i:=i-1; { 1st bit is offset 0 }
temp := i DIV (1 * 8);
readflag := (mem[seg(a):ofs(a)+temp]) AND Power(2,i) = power(2,i);
end;






function nthoc(c:char;b:byte;s:string):byte;
 var i:byte;
     cnt:byte;
 begin
 cnt:=0;
 for i:=1 to length(s) do
   begin
   if s[i]=c then inc(cnt);
   if cnt=b then
     begin
     nthoc:=i;
     exit;
     end;
   end;
 end;

procedure CopyFile(s,d:string);
 const bs=16384;
 type bt=array[1..bs] of byte;
 var sf,df:file;
     b:^bt;
     i:word;
     fs:longint;

 begin
 new(b);
 assign(sf,s);
 reset(sf,1);
 assign(df,d);
 rewrite(df,1);

 fs:=filesize(sf);

 for i:=1 to (fs div bs) do
   begin
   blockread(sf,b^,bs);
   blockwrite(df,b^,bs);
   end;

 blockread(sf,b^,fs mod bs);
 blockwrite(df,b^,fs mod bs);

 dispose(b);

 close(sf);
 close(df);

 end;


function c2pas(var s):string;
var b :^String;
 begin
 b:= ptr(seg(s),ofs(s)-1);
 b^[0]:=#255;
 b^[0]:=char(pos(#0,b^));
 c2pas:=b^;
 end;

 Function Power(b,e:longint):longint;
   var t,c:longint;
   begin
   t:=b;
   if e=0 then begin power:=1 ; exit end;
   for c:=1 to e-1 do t:=t*b;
   power:=t;
   end;

function FindStrInarRay(var buf;l:word;fs:string):word;
 type bigbuft = array[1..65535] of char;
 var buffer: bigbuft absolute buf;
     p:word;
     sscrc:longint;

 procedure loop;
  var c:word;
      ts:string;
  begin

  ts[0]:=fs[0];

  for c:=1 to l-length(fs) do
    begin
    move(buffer[c],ts[1],length(fs));
    if ts=fs then
     begin
     p:=c;
     exit;
     end;

    {if sscrc=crc32array(@buffer[c],length(fs)) then
      begin
      p:=c;
      exit;
      end;
    }




    end;
  end;


 begin

 if l<length(fs) then
  begin
  findstrinarray:=$ffff;
  exit;
  end;

{ sscrc:=Crc32Array(@fs[1],length(fs));}

 p:=$FFFF;

 loop;

 FindStrInArray:=p;
 end;


procedure throughfiles(filespec:string;df:dofiletype);
 var s:searchrec;
     p:string;

 begin
 p:=splitfilepath(filespec);

 FindFirst(FileSpec,AnyFile XOR Directory XOR SysFile XOR ReadOnly,S);

 while DosError=0 do
   begin
   if not df(p+s.name) then exit;
   findnext(S)
   end

 end;


function sizeoffilespec(s:string):longint;
  var sr:searchrec;
       t:longint;
  begin
  t:=0;

  FindFirst(s,AnyFile,sr);
  while DosError=0 do
   begin
   if sr.name[1]<>'.' then inc(t,sr.size);

   findnext(Sr)
   end;

  sizeoffilespec:=t;
  end;

function rows:byte;
 type BiosType = Array[0..$A1] of byte;
 var Bios: BiosType absolute $40:0;
 begin
 Rows := Bios[$84] + 1;
 end;

function columns:byte;
 type BiosType = Array[0..$A1] of byte;
 var Bios: BiosType absolute $40:0;
 begin
 columns := Bios[$4A];
 end;


{procedure ungetch(c:char);
 begin
  memw[$40:$1a]:=$1e;
  memw[$40:$1c]:=$1e+2;
  memw[$40:$1c+2]:=ord(c);
 end;}

{procedure ungetch(c:char);
 var nread: word absolute $40:$1a;
     npush: word absolute $40:$1c;
 begin
  if (npush-nread)<30 then
    begin
    memw[$40:npush]:=ord(c);
    inc(npush,2);
    end
 end;}

PROCEDURE ungetch( Key : WORD ); ASSEMBLER;
asm
  mov ah, $05
  mov cx, Key
  int $16
End;

Procedure wordCrypt(P: pointer;l:word;progcode:string);
 var i:word;
 begin
 for i:=0 to l-1 do
  begin
  mem[seg(p^):ofs(p^)+i]:=mem[seg(p^):ofs(p^)+i] xor Byte(ProgCode[i mod ord (ProgCode [0])+1])
  end;
 end;

function trimch(s:string;c:char):string;
 begin
 trimch:=ltrim(copy(s,pos(c,s)+1,length(s)-pos(c,s)));
 end;

function StripSpaces(s:string):string;
var a:byte;
 begin
 a:=pos(' ',s);
 while a<>0 do begin
   delete(s,a,1);
   a:=pos(' ',s) end;
 StripSpaces:=s;
 end;

function xpos(sub:char;main:string;x:byte):byte;
 var i:byte;
     n:byte;
     p:byte;
 begin
 n:=0;
 for i:=1 to x do
   begin
   p:=pos(sub,main);
   if p=0 then
     begin
     xpos:=0;
     exit;
     end
   else
    begin
    delete(main,1,p);
    n:=p;
    end;
   end;
 xpos:=n;
 end;

function Byte2Hex(numb : byte): string;       { Converts byte to hex string }
  const
    HexChars : array[0..15] of char = '0123456789ABCDEF';
  begin
    Byte2Hex[0] := #2;
    Byte2Hex[1] := HexChars[numb shr  4];
    Byte2Hex[2] := HexChars[numb and 15];
  end; { Byte2Hex }

function Word2Hex(numb: word): string;        { Converts word to hex string.}
  begin
    Word2Hex := Byte2Hex(hi(numb))+Byte2Hex(lo(numb));
  end; { Numb2Hex }

function Long2Hex(L: longint): string;     { Converts longint to hex string }
  begin
    Long2Hex :=Word2Hex(L shr 16)+ Word2Hex(word(L)) ;
  end; { Long2Hex }

Function AttribStr(a:attribset):string;
 var i:word;
     s:string;
 begin
 s[0]:=chr(0);
 for i:=1 to 24 do
   if i in a then
     begin
     s[0]:=chr(ord(s[0])+1);
     s[i]:=chr(64+i);
     end;

{ for i:=1 to ord(s[0]) do
   begin



   end;}
 attribstr:=s;

 end;

function rjustify(s:string;l:byte):string;
 var i:byte;
     a:string;

 begin
 a:=s;
 while length(a)<l do insert(' ',a,1);
 rjustify:=a;
 end;


procedure movefile(fp:string;td:string);
 var f:file;

 begin
 assign(f,fp);
 rename(f,td+'\'+SplitFileName(fp));

 end;


function int2comma(l:longint;b:byte):string;
 var s:string;
     i:integer;
 begin

 str(l:b,s);

 i:=length(s)-2;
 while i>1 do
   begin

   if s[i-1]<> ' ' then insert(',',s,i) else insert(' ',s,i);

   dec(i,3);
   end;
 int2comma:=s;
 end;

function DVloaded:boolean;
var in_dv:boolean;
begin
in_dv:=false;
  asm
    mov cx,'DE'
    mov dx,'SQ'
    mov ax,$2b01
    int $21
    cmp al,$ff
    je @No_Desqview
    mov In_DV,true
    @No_Desqview:
  end;
dvloaded:= in_dv;
end;

function Hex2Byte(s:string):byte;
const val: array[0..15] of char = '0123456789ABCDEF';
var i:byte;
    t:byte;
  begin
  if length(s)=1 then s:='0'+s;
  s:=upcasestr(copy(s,1,2));
  for i:=0 to 15 do if s[1]=val[i] then t:=i*$10;
  for i:=0 to 15 do if s[2]=val[i] then inc(t,i);
  Hex2Byte:=t;
  end;

function base36(n:longint):string;
var t:string;
    i:byte;

 const d36:array[0..35] of char =' 123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 begin
  
  t:=d36[    n div (36*36*36*36*36)]+
     d36[   (n mod (36*36*36*36*36)) div (36*36*36*36)]+
     d36[  ((n mod (36*36*36*36*36)) mod (36*36*36*36)) div (36*36*36)]+
     d36[ (((n mod (36*36*36*36*36)) mod (36*36*36*36)) mod (36*36*36)) div (36*36)]+
     d36[((((n mod (36*36*36*36*36)) mod (36*36*36*36)) mod (36*36*36)) mod (36*36)) div 36]+
     d36[((((n mod (36*36*36*36*36)) mod (36*36*36*36)) mod (36*36*36)) mod (36*36)) mod 36];

  t:=ltrim(t);
  for i:=1 to length(t) do if t[i]=' ' then t[i]:='0';
  base36:=t;
  end;

Function HexStr(n:longint):string;
var t:string;
    i:byte;

 const d16:array[0..15] of char =' 123456789ABCDEF';
 begin
  t:=d16[      n div $1000000]+
     d16[     (n mod $1000000) div $100000]+
     d16[    ((n mod $1000000) mod $100000) div $10000]+
     d16[   (((n mod $1000000) mod $100000) mod $10000) div $1000]+
     d16[  ((((n mod $1000000) mod $100000) mod $10000) mod $1000) div $100]+
     d16[ (((((n mod $1000000) mod $100000) mod $10000) mod $1000) mod $100) div $10]+
     d16[ (((((n mod $1000000) mod $100000) mod $10000) mod $1000) mod $100) mod $10];

  t:=ltrim(t);
  for i:=1 to length(t) do if t[i]=' ' then t[i]:='0';
  hexstr:=t;
  end;


function CRC32Array(p:pointer;l:longint):longint;
 var i   :longint;crc :longint;
 begin
 CRC:=$FfFfFfFf;
 for i:= 1 to l do CRC:=UpDC32(mem[seg(p^):ofs(p^)+i-1],crc);
 CRC32ARRAY:=crc;
 end;


(* crctab calculated by Mark G. Mendel, Network Systems Corporation *)
CONST crctab: ARRAY[0..255] OF WORD = (
    $0000,  $1021,  $2042,  $3063,  $4084,  $50a5,  $60c6,  $70e7,
    $8108,  $9129,  $a14a,  $b16b,  $c18c,  $d1ad,  $e1ce,  $f1ef,
    $1231,  $0210,  $3273,  $2252,  $52b5,  $4294,  $72f7,  $62d6,
    $9339,  $8318,  $b37b,  $a35a,  $d3bd,  $c39c,  $f3ff,  $e3de,
    $2462,  $3443,  $0420,  $1401,  $64e6,  $74c7,  $44a4,  $5485,
    $a56a,  $b54b,  $8528,  $9509,  $e5ee,  $f5cf,  $c5ac,  $d58d,
    $3653,  $2672,  $1611,  $0630,  $76d7,  $66f6,  $5695,  $46b4,
    $b75b,  $a77a,  $9719,  $8738,  $f7df,  $e7fe,  $d79d,  $c7bc,
    $48c4,  $58e5,  $6886,  $78a7,  $0840,  $1861,  $2802,  $3823,
    $c9cc,  $d9ed,  $e98e,  $f9af,  $8948,  $9969,  $a90a,  $b92b,
    $5af5,  $4ad4,  $7ab7,  $6a96,  $1a71,  $0a50,  $3a33,  $2a12,
    $dbfd,  $cbdc,  $fbbf,  $eb9e,  $9b79,  $8b58,  $bb3b,  $ab1a,
    $6ca6,  $7c87,  $4ce4,  $5cc5,  $2c22,  $3c03,  $0c60,  $1c41,
    $edae,  $fd8f,  $cdec,  $ddcd,  $ad2a,  $bd0b,  $8d68,  $9d49,
    $7e97,  $6eb6,  $5ed5,  $4ef4,  $3e13,  $2e32,  $1e51,  $0e70,
    $ff9f,  $efbe,  $dfdd,  $cffc,  $bf1b,  $af3a,  $9f59,  $8f78,
    $9188,  $81a9,  $b1ca,  $a1eb,  $d10c,  $c12d,  $f14e,  $e16f,
    $1080,  $00a1,  $30c2,  $20e3,  $5004,  $4025,  $7046,  $6067,
    $83b9,  $9398,  $a3fb,  $b3da,  $c33d,  $d31c,  $e37f,  $f35e,
    $02b1,  $1290,  $22f3,  $32d2,  $4235,  $5214,  $6277,  $7256,
    $b5ea,  $a5cb,  $95a8,  $8589,  $f56e,  $e54f,  $d52c,  $c50d,
    $34e2,  $24c3,  $14a0,  $0481,  $7466,  $6447,  $5424,  $4405,
    $a7db,  $b7fa,  $8799,  $97b8,  $e75f,  $f77e,  $c71d,  $d73c,
    $26d3,  $36f2,  $0691,  $16b0,  $6657,  $7676,  $4615,  $5634,
    $d94c,  $c96d,  $f90e,  $e92f,  $99c8,  $89e9,  $b98a,  $a9ab,
    $5844,  $4865,  $7806,  $6827,  $18c0,  $08e1,  $3882,  $28a3,
    $cb7d,  $db5c,  $eb3f,  $fb1e,  $8bf9,  $9bd8,  $abbb,  $bb9a,
    $4a75,  $5a54,  $6a37,  $7a16,  $0af1,  $1ad0,  $2ab3,  $3a92,
    $fd2e,  $ed0f,  $dd6c,  $cd4d,  $bdaa,  $ad8b,  $9de8,  $8dc9,
    $7c26,  $6c07,  $5c64,  $4c45,  $3ca2,  $2c83,  $1ce0,  $0cc1,
    $ef1f,  $ff3e,  $cf5d,  $df7c,  $af9b,  $bfba,  $8fd9,  $9ff8,
    $6e17,  $7e36,  $4e55,  $5e74,  $2e93,  $3eb2,  $0ed1,  $1ef0
);

FUNCTION UpdCrc(cp: BYTE; crc: WORD): WORD;
BEGIN { UpdCrc }
   UpdCrc := crctab[((crc SHR 8) AND 255)] XOR (crc SHL 8) XOR cp
END;

CONST crc_32_tab: ARRAY[0..255] OF LONGINT = (
$00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3,
$0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91,
$1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
$136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63, $8d080df5,
$3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
$35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59,
$26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
$2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d,
$76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433,
$7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
$6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457,
$65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65,
$4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb,
$4369e96a, $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
$5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
$5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad,
$edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683,
$e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1,
$f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7,
$fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
$d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
$d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79,
$cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f,
$c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
$9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
$95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21,
$86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777,
$88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
$a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db,
$aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
$bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf,
$b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
);

FUNCTION UpdC32(octet: BYTE; crc: LONGINT) : LONGINT;
BEGIN { UpdC32 }
   UpdC32 := crc_32_tab[BYTE(crc XOR LONGINT(octet))] XOR ((crc SHR 8) AND $00FFFFFF)
END;

Procedure LongHash (s: string; var r: pwtype);
  { return modified 3-byte checksum }
var i,j: integer;
 Begin
  for i:=1 to 3 do r[i]:=0;
  j:=1;
  for i:=1 to length(s) do
    begin
    r[j]:=r[j]+ord(s[i]);
    if (r[j] mod 2)=0 then
      begin
      j:=j+1;
      if (j=4) then j:=1;
      end;
    end;
 end;



function numtowords(n:word):string;
 const Eng: Array[0..9] of string[6] = ('Zero ','One ','Two ','Three ',
                                        'Four ','Five ','Six ','Seven ',
                                        'Eight ','Nine ');
 var ts:string;
     ns:string;
     i :byte;
     cn:byte;
     c :integer;
 begin
 str(n,ns);
 ts:='';

 for i:=1 to length(ns) do
   begin
   val(ns[i],cn,c);
   ts:=ts+eng[cn];
   end;

 numtowords:=rtrim(ts);
 end;


function ShortPath(s:string):string;
 var t,u:string;

 function lastslash:byte;
  var a:integer;
  begin
  u:=s;
  for a:=length(u) downto 1 do
   begin
   if u[a]='\' then begin lastslash:=a; exit end;
   end;
  end;
 var a:integer;
 begin
 if length(s)>30 then
  begin
  a:=lastslash;
  t:=copy(s,1,pos('\',s))+'∙∙∙'+copy(s,a,length(s));
  shortpath:=t;
  end
 else shortpath:=s;
 end;


function SplitFilePath(s:string):string;
    var
     D: DirStr;
     N: NameStr;
     E: ExtStr;
begin
fsplit(s,d,n,e);
splitfilepath:=d;
end;

function splitFileExt (s:string):string;
    var
     D: DirStr;
     N: NameStr;
     E: ExtStr;begin
fsplit(s,d,n,e);
splitfileext:=e;
end;

function splitFileName(s:string):string;
    var
     D: DirStr;
     N: NameStr;
     E: ExtStr;begin
fsplit(s,d,n,e);
splitfilename:=n;
end;

Procedure KillFileSpec(p:string);
 var s:searchrec;
     f:file;
 begin
 FindFirst(p,anyfile XOR directory,s);
 While DosError=0 do
  begin
  assign(f,splitfilepath(p)+s.name);
  erase(f);
  FindNext(s);
  end;
 end;

procedure killallindir(p:string);
 var s:searchrec;
     f:file;
 begin
 FindFirst(p+'\*.*',anyfile XOR directory,s);
 While DosError=0 do
  begin
  assign(f,p+'\'+s.name);
  erase(f);
  FindNext(s);
  end;
 end;


Procedure PruneDir(p:string);

 var s:searchrec;
 begin
 if (p[1]=char('.')) and (p[2]=char('\')) then delete(p,1,2);
 killallindir(p);

 FindFirst(p+'\*.*',directory,s);
 While DosError=0 do
  begin
  if not ((s.name='.') or (s.name='..')) then
    begin
    killallindir(p+'\'+s.name);

    prunedir(p+'\'+s.name);

    {$I-}
    rmdir(fexpand(p+'\'+s.name));
    {$I+}
    end;
  FindNext(s);
  end;

 {$I-}
 rmdir(p);
 {$I+}
 end;


function nowsecondssincemidnight: longint;
 var h,m,s: word;
 begin
 curtime(h,m,s);
 nowsecondssincemidnight:=secondssincemidnight(h,m,s);
 end;

function nowmins: word;
 var h,m,s: word;
 begin
 curtime(h,m,s);
 nowmins:=h*60+m;
 end;


(*
function LineWrapInput(var s:string):boolean;
  var t:char;
      i:byte;

  begin
  s:='';
  repeat until keypressed;
  t:=readkey;
  case t of
    {KEY} #32..#126:
    { BS} #8: if ord(s[0])>0 then
                begin
                s[0]:=chr(ord(s[0])-1);
                case ansi of
                  true : begin
                         gotoxy(wherex-1),wherey);
                         write(' ');
                         gotoxy(wherex-1,wherey);
                         end;
                  false: begin
                         pr(#8+' '+#8);
                         end;
                  end;
                end;
    end;
  end;
*)

function DtTmStamp: string;
 var m,d,y,dw: word;
     sm,sd: string[2];
     sy:string[4];

     ts:string;
     i:byte;
 begin
 getdate(y,m,d,dw);

 str(m:2,sm);
 str(d:2,sd);
 str(y:4,sy);

 sy:=copy(sy,3,2);

 ts:=concat(sy,'-',sm,'-',sd);

 for i:=1 to ord(ts[0]) do if ts[i]=' ' then ts[i]:='0';

 ts:=ts+' '+curtimestr;

 DtTmStamp:=ts;

 end;


(*
Function Carrier_On:boolean;          {TRUE if carrier present}
     var a:word;
     begin

     case PortNum of
       1: A := $3F8;
       2: A := $2F8;
       3: A := $3E8;
       4: A := $2E8;
       end;

     Carrier_On:=odd ( Port[ A + $06 ] shr 7 )

     end;
*)

function ToStr(s: longint): string;
  var a: string;
  begin
  str(S,A);
  ToStr:=A;
  end;

function ToStr2(s: longint;b:byte): string;
  var a: string;
  begin
  str(S:b,A);
  if a[1]=' ' then a[1]:='0';
  ToStr2:=A;
  end;

function ToInt(s: string): word;
  var a: word;
      c:integer;

  begin
  val(S,A,c);
  ToInt:=a;
  end;

function Tolong(s: string): longint;
  var a:longint;
      c:integer;

  begin
  val(S,A,c);
  Tolong:=a;
  end;




function ToStrb(var s: byte): string;
  var a: string;
  begin
  str(S,A);
  ToStrb:=A;
  end;

function SecondsSinceMidnight(h,m,s:word):longint;
  begin
  SecondsSinceMidnight := (longint(h)*3600)+(longint(m)*60)+longint(s)
  end;

function CurTimeStr: string;
 Var Hour,Min,Sec,Sec100:word;
     HourS,MinS,SecS,Sec100s:string[2];
     i:byte;
     t:string;
 begin
 GetTime(Hour,Min,Sec,Sec100);

 Str(Hour:2,HourS);
 Str(Min:2,MinS);
 Str(Sec:2,Secs);

 t:=concat(HourS,':',MinS,':',SecS);
 for i:=1 to ord(t[0]) do
  if t[i]=' ' then t[i]:='0';
 CurTimeStr:=t;
 end;

procedure CurTime(var h:word; var m: word;var s:word);
 Var Hour,Min,Sec,Sec100:word;
 begin
 GetTime(Hour,Min,Sec,Sec100);
 h:=hour;
 m:=min;
 s:=sec;
 end;

function ltrim(s:string):string;
  begin
  if s='' then begin ltrim:=''; exit end;
  repeat
    begin
    if s[1]=' ' then delete(s,1,1);
    end;
  until s[1]<>' ';
  ltrim:=s;
  end;

Procedure CursorOff;
  var regs:registers;
  Begin
  Regs.Ax := $0100;
  Regs.Cx := $2807;
  Intr($10,Regs);
  End;

Procedure CursorOn;
  var regs:registers;
  Begin
  Regs.Ax := $0100;
  If LastMode = Mono Then
    Regs.Cx := $090A
  Else
    Regs.Cx := $0607;
  Intr($10,Regs);
  End;

procedure beep(hz,ms:word);
 begin
 sound(hz);
 delay(ms);
 nosound;
 end;

function rtrim(s:string):string;
  var a: byte;d:boolean;
  begin
  if s='' then begin rtrim:=''; exit end;

  d:=false;
  a:= ord(s[0]);
  repeat
   if s[a]=#32 then
    begin
    s[0] := chr(ord(s[0])-1);
    dec(a);
    end
  else d:=true;
  until d;
  rtrim:=s;
  end;

{
Procedure CursorOff;
Begin
  Inline($50/$51/$B4/$01/$B5/$FF/$B1/$0C/$CD/$10/$59/$58);
End;



Procedure CursorOn;
Begin
  Inline($50/$51/$B4/$01/$B5/$0C/$B1/$0D/$CD/$10/$59/$58);
End;
}

function compare(s1,s2:string):byte;
 begin
 s1:=upcasestr(s1);
 s2:=upcasestr(s2);

 if s1 = s2 then compare:=0;
 if s1 < s2 then compare:=2;
 if s1 > s2 then compare:=1;

 end;

function ExistFile(s:string;flags:word):boolean;
  var re:searchrec;
  begin
  FindFirst(s,flags,re);
  ExistFile := not((DosError=18) or (DosError=2) or (DosError=3));
  end;

function UpcaseStr(s:string):string;
  var a:byte;
  begin
  for a:=1 to ord(s[0]) do s[a] := upcase(s[a]);
  UpCaseStr := s;
  end;

function LowcaseStr(s:string):string;
  var a:byte;
  begin
  for a:=1 to ord(s[0]) do s[a] := lowcase(s[a]);
  lowCaseStr := s;
  end;

Function LTab(n: integer;m:integer):string;
  var a: string;
      b: integer;
  begin
  a := '';
  for b := n+1 to m do a:=a+' ';
  Ltab := a;
  end;

function  Ltabc(n,m:integer;c:char):string;
  var a: string;
      b: integer;
  begin
  a := '';
  for b := n+1 to m do a:=a+c;
  Ltabc := a;
  end;


function Key:char;
   begin
   Key := ReadKey;
   end;

procedure ClearScreen;
   begin
   if ANSI then ClrScr;
   end;


function CaseStr(s: string): string;
   var i: byte;

   begin
   s[1] := upcase(s[1]);
   for i := 2 to ord(s[0]) do
       begin
       case ord(s[i-1]) of

        32..46,58..64,91..96,132..126
          :  s[i] := upcase(s[i]);
        else s[i] := lowcase(s[i]);
        end;
       end;
   CaseStr := s;
   end;

function lowcase(ch: char): char;
  begin
  ch := upcase(Ch);
  case ord(ch) of
  65..90: Lowcase := chr(ord(ch)+32);
  else Lowcase := Ch;
  end;
  end;

procedure PR(t: string);
   begin
   if ANSI then write(t) else Write(output, t);
   end;

procedure Newline;
   begin
   if ANSI then writeln else write(output, #13,#10);
   end;

procedure ColorFG(c: byte);
    begin
    if ANSI then textcolor(c);
    end;

procedure ColorBG(c: byte);
    begin
    if ANSI then textbackground(c);
    end;

procedure PhoneEditor(var answerformain: string; prestring: string;fgc,bgc:byte);
    var
 tempkey      : char;
 stringtempkey: string[1];
  baseX       : byte;
  answer      : string[10];
  done        : boolean;
  i           : byte;
    begin
    done := false;
    baseX := whereX;
    answer := '';
    {
    if length(prestring) <> 0 then
      begin
      answer := prestring;
      for i:=1 to (10 - length(prestring)) do answer := answer + #32;
      ord(answer[0]) := length(prestring);
      end;
    }
    colorFG(fgc);
    colorBG(bgc);
    if ANSI then begin PR(' (   )    -     '); gotoXY(baseX+2, wherey); end
    else PR(' (');
    repeat
    tempkey := readkey;
    case tempkey of
       '0'..'9':if ord(answer[0]) < 10 then
                 begin
                   answer := answer + tempkey;
                   case ord(answer[0]) of
                     1,2,4,5,7,8,9,10:PR(tempkey);
                     3:
                       begin
                       if ANSI then begin pr(tempkey);gotoXY(basex+7, whereY) end
                       else PR(tempkey+') ');
                       end;
                     6:
                       begin
                       if ANSI then begin pr(tempkey);gotoXY(baseX+11, wherey) end
                       else PR(tempkey+'-');
                       end;
                   end;
                 end;

       #8: if ord(answer[0]) > 0 then
          begin
          delete(answer,ord(answer[0]),1);
          {dec(ord(answer[0]));}
          {answer := copy(answer, 1, ord(answer[0]));}
          case ord(answer[0]) of
               0,1,3,4,6,7,8,9,10: if ANSI then begin
                                               gotoXY(whereX-1, wherey);
                                               PR(' ');
                                               gotoXY(whereX-1, wherey);
                                               end
                                  else
                                               begin
                                               PR(#8+#32+#8);
                                               end;

               2: if ANSI then
                      begin
                      gotoXY(wherex-3, whereY);
                      PR(' ');
                      gotoXY(wherex-1, whereY);
                      end
                   else
                       begin
                       PR(#8+#8+#8+#32+#8);
                       end;

               5: if ANSI then
                      begin
                      gotoXY(whereX-2, wherey);
                      PR(' ');
                      gotoXY(wherex-1, whereY);
                      end
                  else
                      begin
                      PR(#8+#8+#32+#8);
                      end;
               end;
          end;
       #13:done := true;

       end;
    until done;
    colorBG(black);
    answerformain := answer;
    end;

procedure Editor(maxlen: byte; var answerformain: string; prestring: string;fgc,bgc:byte);
   var
       tempkey : char;
       done    : boolean;
       index   : byte;
       answer  : string;
       baseX   : byte;
       i       : byte;
     insertmode: boolean;
  stringtempkey: string[1];

   begin
   baseX := whereX;
   done := false;

   insertmode:=useinsert;
   if not(ansi) then useinsert:=false;

   index := 0;
   answer := '';
   if length(prestring) <> 0 then
      begin
      answer := prestring;
      index := length(prestring);
      end;

   if (ANSI and insertmode) then
     begin
     gotoXY(baseX+maxlen+2, whereY);
     ColorFG(lightred);ColorBG(black);
     PR('i');
     gotoxy(basex, wherey);
     end;

   ColorFG(fgc);
   ColorBG(bgc);


   PR(' '+Prestring);

   if ANSI then
     begin
     for i:=length(prestring)+1 to maxlen+1 do PR(' ');
     gotoXY(basex+1+index,wherey);
     end;

   { functions ... backspace, right, left, overwrite mode for L, R }
   {               enter, delete                                   }

   repeat
      repeat
       If portcheck then if not carrierfunc then
         begin
         Exit;
         end;
      until keypressed;

      tempkey := readkey;
      case tempkey of
        #32,

             {'A'..'Z', 'a'..'z','0'..'9', ',' , '.':}

             ' '..'~':

             begin
              if ord(answer[0]) < maxlen then
               begin
               inc(index);
               if index <= maxlen then
               begin
               if CapsOn then
   {for upcase} if (answer[index-1] = #32) or (Answer[index-1] = #0) then
   {checking}     begin
                  tempkey := upcase(tempkey);
                  end
                else tempkey := lowcase(tempkey);

               if insertmode and ansi then
                  begin
                  if ord(answer[0]) < maxlen then
                    begin
                    stringtempkey := tempkey;
                    insert(stringtempkey, answer, index);
                    if CapsOn then Answer := CaseStr(Answer);
                    if index <> ord(answer[0]) then
                     begin
                     gotoxy(baseX+1, wherey);
                     PR(answer);
                     gotoxy(baseX+index+1, wherey);
                     end
                    else pr(tempkey);
                    end;
                  end
               else
                  begin
                  if index < ord(answer[0])+1 then answer[index] := tempkey
                  else answer := answer + tempkey;
                  PR(tempkey)
                  end;
               end;
              end;
             end;
        #13:
             begin
             done := true;
             end;
        #8:
             begin

             if (index > 0)  then
              begin
              dec(index);
              delete(answer, Index+1, 1);
              if ANSI then
                  begin

                  gotoXY(BaseX+Index+1, whereY);
                  PR(copy(answer, index+1, ord(answer[0])-index)+' ');
                  gotoXY(BaseX+index+1, whereY);

                   end
              else PR(#8+' '+#8);
              end;
             end;
        #0:                         { test for extended characters }
             begin
             case readkey of        { poll for extended part }
               #75:                 { left arrow }
                   begin
                   if ANSI then
                    begin
                    if index >= 1 then
                     begin
                     dec(index);
                     gotoxy(whereX-1, wherey);
                     end;
                    end;
                   end;
               #77:                 { right arrow }
                  begin
                  if ANSI then
                   begin
                   if index < ord(answer[0]) then
                     begin
                     inc(index);
                     gotoxy(whereX+1, whereY);
                     end;
                   end;
                  end;
               #71:                 { home }
                  begin
                  if ANSI then
                     begin
                     index := 0;
                     gotoxy(baseX+1, wherey);
                     end;
                  end;

               #79: IF ANSI then
                  begin
                  index := ord(answer[0]);
                  gotoXY(BaseX+Ord(answer[0])+1, whereY);

                  end;

               #82:      { ins }
                if useinsert then
                  begin
                  gotoXY(baseX+maxlen+2, whereY);
                  ColorFG(lightred);ColorBG(black);
                  if insertmode then begin insertmode := false; PR(' ') end
                  else begin insertmode := true; PR('i'); end;
                  GotoXY(BaseX+Index+1, whereY);
                  ColorFG(white);ColorBG(blue);
                  end;

               #83:         { del }
                  begin
                  if ANSI then
                    begin
                    delete(answer,index+1,1);
                    If CapsOn then Answer := CaseStr(Answer);
                    gotoXY(baseX+1, whereY);
                    for i:=1 to ord(answer[0]) do PR(Answer[i]);
                    PR(' ');

                    gotoxy(baseX+index+1, wherey);
                    end;
                  end;

               end;                           { end of 'case readkey of' }
             end;                             { end of '#0: begin' }
        end;                                  { end of 'case tempkey of' }
   until done;

   {answer[0] := chr(ord(answer[0]));}
   answerformain := answer;
   if ANSI then gotoXY(baseX+maxlen+2, wherey) else
     for i := index to maxlen+1 do PR(' ');
   colorBG(black);PR(' '+#8+' ');
   end;


procedure setup_output;
   begin
   if ANSI = false then
      begin
      assign(output, '');
      rewrite(output);
      end;
   end;


procedure showmc(ch: char);
    begin
    colorFG(blue);PR('[');colorFG(white);PR(CH);colorFG(blue);PR(']');
    colorFG(cyan);PR(' ');
    end;


procedure GetChoice(numofchoices:byte; Choices:string;fgc,bgc,oc:byte; var Reply: byte);
   { last char of choices must NOT be #32 }

   type
       datatype = record
         beginpos: byte;
         text    : string;
         end;
        choicetype = array[1..10] of datatype;

   var
      i      : byte;
      c      : choicetype;
      incr   : byte;
      done   : boolean;
      baseX  : byte;
      tempkey: char;
      last   : byte;
      curc   : byte;
      oldc   : byte;

   begin
   if ANSI then
    Begin
    baseX := whereX;
    done := false;
    choices := choices+' ';
    last := 1;
    incr := 0;
    for i := 1 to length(choices) do
        if choices[i] = ' ' then
           begin
           inc(incr);
           c[incr].beginpos := (incr+last-2) ;
           c[incr].text := ' '+copy(choices,last,i-last)+' ';
           last := i+1;
           end;
    textcolor(oc);
    for i := 1 to incr do
         begin
         write(c[i].text);
         end;

    OldC := 1;
    CurC := 1;

    Textcolor(fgc);
    textbackground(bgc);
    gotoXY(baseX+c[CurC].beginpos, whereY);
    write(c[CurC].text);

    repeat
       begin
      repeat
       if portcheck then
        if not carrierfunc then
         begin
         Exit;
         end;
      until keypressed;


       tempkey := readkey;
       case upcase(tempkey) of
          #0:
             case readkey of
               #77:
                   begin
                   inc(CurC);
                   if CurC = numofchoices+1 then CurC := 1;
                   end;
                #75:
                   begin
                   dec(CurC);
                   if CurC = 0 then CurC := numofchoices;
                   end;
               end;

          #32:begin
              CurC := CurC +1;
              if CurC = numofchoices+1 then CurC := 1
              end;

          #13: done := true;
          else
               for i := 1 to numofchoices do
                   if upcase(tempkey) = c[i].text[2] then
                                      begin
                                      CurC := i;
                                      done := true;
                                      end;

          end;
       if OldC <> CurC then
         begin
         textcolor(oc);
         textbackground(black);
         gotoXY(baseX+c[oldc].beginpos, wherey);
         write(c[oldc].text);

         textbackground(bgc);
         textcolor(fgc);
         gotoXY(basex+c[curc].beginpos, wherey);
         write(c[curc].text);
         end;

       OldC := CurC
       end;
    until done;

    colorBG(black);PR(' '+#8+' ');
    Reply := CurC;

    end

   else

    begin
    incr := 0;
    last := 1;
    done := false;
    choices := Choices + ' ';

    for i := 1 to length(choices) do
     if choices[i] = ' ' then
        begin
        inc(incr);
        c[incr].text := copy(choices, last, i-last);
        {writeln(c[incr].text);}
        c[incr].text := '['+c[incr].text[1]+']'+copy(c[incr].text,2,ord(c[incr].text[0])-1)+' ';
        last := i+1;
        end;
    For i := 1 to numofchoices do PR(c[i].text);
    PR('-> ');
    repeat
        begin
        tempkey := upcase(readkey);
        for i := 1 to numofchoices do
            begin
            if tempkey = c[i].text[2] then begin done := true; Reply := i;end
            end;
        end;
    until done;
    PR(c[reply].text[2] + copy(c[reply].text,4,length(c[reply].text)-4));
    end;
   end;

procedure PrintScreen;
 begin
  InLine ($CD/$05)
 end;


begin   {initialize the global variables }
    ANSI := true;
    carrierfunc:=nil;
    useinsert := true;
    CapsOn := true;
    PortCheck := false;
end.


