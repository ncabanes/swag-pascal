unit dosfax;

(* UNIT DosFax: Faxen unter DOS *)
(* Erstellt von:
   Stefan Cordes
   Am Kockshof 24
   40882 Ratingen
   02102 895 816
   Fax: 02561-91371-7324
   e-mail: 100331.3700@Compuserve.com
   www: http://ourworld.compuserve.com/homepages/Cordes/ *)

interface

Procedure InitModem(comNr:Word;TelNr:String);

Procedure Dial(tp:char;nr:String);

Procedure Sendline(hstr:string);

procedure EndPage;

implementation

uses dos,crt;

const ModemPort:Word=0;
      wartetick=40;

Procedure Sendchar(c:char);
var reg:registers;
begin
  repeat
    reg.ax := $300;
    reg.dx := ModemPort;
    intr($14,reg);
  until (reg.ah and $20)<>0;
  repeat
    reg.ah := $1;
    reg.al := ord(c);
    reg.dx := ModemPort;
    intr($14,reg);
  until (reg.ah and $80)=0;
end;

function Getchar:char;
var reg:registers;
begin
  reg.ax := $200;
  reg.dx := ModemPort;
  intr($14,reg);
  GetChar := chr(reg.al);
(*  highvideo; write(chr(reg.al)); lowvideo;
  if reg.al = 13 then writeln;              *)
end;


function charavail:Boolean;
var reg:registers;
begin
  reg.ax := $300;
  reg.dx := ModemPort;
  intr($14,reg);
  charavail := (reg.ah and $1)=1;
end;

Procedure SendStr(s:String);
var i1:Word;
begin
  delline;
  write(s);
  delay(50);
  for i1 := 1 to length(s) do
  begin
    sendchar(s[i1]);
  end;
end;

var tick:longint absolute $40:$6c;

function GetString:String;
var hstr:String;
    ende:Boolean;
    endzeit:longint;
    c:char;
begin
  hstr := '';
  endzeit := tick+40;
  ende := false;
  repeat
    if charavail then
    begin
      c := getchar;
      endzeit := tick+40;
      if (c=#13) and (hstr<>'') then ende := true;
      if c>=#32 then hstr := hstr+c;
    end;
    if endzeit<tick then ende := true;
  until ende;
  getstring := hstr;
end;

Procedure Timeout;
begin
  writeln('Modem timeout');
  delay(1000);
  sendstr('+++');
  delay(1000);
  sendstr('ATH'+#13);
  halt(10);
end;

Procedure InitModem(comNr:Word;TelNr:String);
var reg:registers;
    endzeit:Longint;
    hstr:String;
begin
  Writeln('Init Com',comNr);
  ModemPort := ComNr-1;
  reg.ah := 0;
  reg.al := $80+$40+$20+3; (* Baud = 9600, 8n1 *)
  reg.dx := ModemPort;
  intr($14,reg);
  sendstr('AT&FE0'+#13);
  endzeit:=tick+WarteTick;
  repeat
    repeat
      if endzeit<tick then Timeout;
    until charavail;
    hstr := getstring;
  until pos('OK',hstr)>0;
  sendstr('AT+FCLASS=2'+#13);
  endzeit:=tick+WarteTick;
  repeat
    repeat
      if endzeit<tick then Timeout;
    until charavail;
    hstr := getstring;
  until pos('OK',hstr)>0;
  sendstr('AT+FLID="'+TelNr+'"'+#13);
  endzeit:=tick+WarteTick;
  repeat
    repeat
      if endzeit<tick then Timeout;
    until charavail;
    hstr := getstring;
  until pos('OK',hstr)>0;
  sendstr('AT+FDCC=0,3,0,2'+#13);
  endzeit:=tick+WarteTick;
  repeat
    repeat
      if endzeit<tick then Timeout;
    until charavail;
    hstr := getstring;
  until pos('OK',hstr)>0;
end;

Procedure Dial(tp:char;nr:String);
var endzeit:Longint;
    hstr:String;
begin
  tp := upcase(tp);
  if (tp<>'T') and (tp<>'P') then tp := 'P';
  sendstr('ATD'+tp+nr+#13);
  endzeit:=tick+60*18;
  repeat
    repeat
      if endzeit<tick then Timeout;
    until charavail;
    hstr := getstring;
  until pos('OK',hstr)>0;
  sendstr('AT+FDT'+#13);
  endzeit:=tick+30*18;
  repeat
    repeat
      if endzeit<tick then Timeout;
    until charavail;
    hstr := getstring;
  until pos('CONNECT',hstr)>0;
end;

procedure EndPage;
var endzeit:longint;
    hstr:string;
begin
  sendstr(#16+#3);
  endzeit:=tick+WarteTick;
  repeat
    repeat
      if endzeit<tick then Timeout;
    until charavail;
    hstr := getstring;
  until pos('OK',hstr)>0;
  sendstr('AT+FET=2'+#13);
  endzeit:=tick+30*18;
  repeat
    repeat
      if endzeit<tick then Timeout;
    until charavail;
    hstr := getstring;
  until pos('OK',hstr)>0;
end;

const TerminatingWhiteCodes:
  array[0..63] of array[1..2] of Byte=(
(*      00110101 *) ( 53, 8), (* 0 *)
(*        000111 *) (  7, 6), (* 1 *)
(*          0111 *) (  7, 4), (* 2 *)
(*          1000 *) (  8, 4), (* 3 *)
(*          1011 *) ( 11, 4), (* 4 *)
(*          1100 *) ( 12, 4), (* 5 *)
(*          1110 *) ( 14, 4), (* 6 *)
(*          1111 *) ( 15, 4), (* 7 *)
(*         10011 *) ( 19, 5), (* 8 *)
(*         10100 *) ( 20, 5), (* 9 *)
(*         00111 *) (  7, 5), (* 10 *)
(*         01000 *) (  8, 5), (* 11 *)
(*        001000 *) (  8, 6), (* 12 *)
(*        000011 *) (  3, 6), (* 13 *)
(*        110100 *) ( 52, 6), (* 14 *)
(*        110101 *) ( 53, 6), (* 15 *)
(*        101010 *) ( 42, 6), (* 16 *)
(*        101011 *) ( 43, 6), (* 17 *)
(*       0100111 *) ( 39, 7), (* 18 *)
(*       0001100 *) ( 12, 7), (* 19 *)
(*       0001000 *) (  8, 7), (* 20 *)
(*       0010111 *) ( 23, 7), (* 21 *)
(*       0000011 *) (  3, 7), (* 22 *)
(*       0000100 *) (  4, 7), (* 23 *)
(*       0101000 *) ( 40, 7), (* 24 *)
(*       0101011 *) ( 43, 7), (* 25 *)
(*       0010011 *) ( 19, 7), (* 26 *)
(*       0100100 *) ( 36, 7), (* 27 *)
(*       0011000 *) ( 24, 7), (* 28 *)
(*      00000010 *) (  2, 8), (* 29 *)
(*      00000011 *) (  3, 8), (* 30 *)
(*      00011010 *) ( 26, 8), (* 31 *)
(*      00011011 *) ( 27, 8), (* 32 *)
(*      00010010 *) ( 18, 8), (* 33 *)
(*      00010011 *) ( 19, 8), (* 34 *)
(*      00010100 *) ( 20, 8), (* 35 *)
(*      00010101 *) ( 21, 8), (* 36 *)
(*      00010110 *) ( 22, 8), (* 37 *)
(*      00010111 *) ( 23, 8), (* 38 *)
(*      00101000 *) ( 40, 8), (* 39 *)
(*      00101001 *) ( 41, 8), (* 40 *)
(*      00101010 *) ( 42, 8), (* 41 *)
(*      00101011 *) ( 43, 8), (* 42 *)
(*      00101100 *) ( 44, 8), (* 43 *)
(*      00101101 *) ( 45, 8), (* 44 *)
(*      00000100 *) (  4, 8), (* 45 *)
(*      00000101 *) (  5, 8), (* 46 *)
(*      00001010 *) ( 10, 8), (* 47 *)
(*      00001011 *) ( 11, 8), (* 48 *)
(*      01010010 *) ( 82, 8), (* 49 *)
(*      01010011 *) ( 83, 8), (* 50 *)
(*      01010100 *) ( 84, 8), (* 51 *)
(*      01010101 *) ( 85, 8), (* 52 *)
(*      00100100 *) ( 36, 8), (* 53 *)
(*      00100101 *) ( 37, 8), (* 54 *)
(*      01011000 *) ( 88, 8), (* 55 *)
(*      01011001 *) ( 89, 8), (* 56 *)
(*      01011010 *) ( 90, 8), (* 57 *)
(*      01011011 *) ( 91, 8), (* 58 *)
(*      01001010 *) ( 74, 8), (* 59 *)
(*      01001011 *) ( 75, 8), (* 60 *)
(*      00110010 *) ( 50, 8), (* 61 *)
(*      00110011 *) ( 51, 8), (* 62 *)
(*      00110100 *) ( 52, 8));(* 63 *)

MakeUpWhiteCodes:
  array[1..27] of array[1..2] of Byte=(
(*         11011 *) ( 27, 5), (* 64 *)
(*         10010 *) ( 18, 5), (* 128 *)
(*        010111 *) ( 23, 6), (* 192 *)
(*       0110111 *) ( 55, 7), (* 256 *)
(*      00110110 *) ( 54, 8), (* 320 *)
(*      00110111 *) ( 55, 8), (* 384 *)
(*      01100100 *) (100, 8), (* 448 *)
(*      01100101 *) (101, 8), (* 512 *)
(*      01101000 *) (104, 8), (* 576 *)
(*      01100111 *) (103, 8), (* 640 *)
(*     011001100 *) (204, 9), (* 704 *)
(*     011001101 *) (205, 9), (* 768 *)
(*     011010010 *) (210, 9), (* 832 *)
(*     011010011 *) (211, 9), (* 896 *)
(*     011010100 *) (212, 9), (* 960 *)
(*     011010101 *) (213, 9), (* 1024 *)
(*     011010110 *) (214, 9), (* 1088 *)
(*     011010111 *) (215, 9), (* 1152 *)
(*     011011000 *) (216, 9), (* 1216 *)
(*     011011001 *) (217, 9), (* 1280 *)
(*     011011010 *) (218, 9), (* 1344 *)
(*     011011011 *) (219, 9), (* 1408 *)
(*     010011000 *) (152, 9), (* 1472 *)
(*     010011001 *) (153, 9), (* 1536 *)
(*     010011010 *) (154, 9), (* 1600 *)
(*        011000 *) ( 24, 6), (* 1664 *)
(*     010011011 *) (155, 9));(* 1728 *)

TerminatingBlackCodes:
  array[0..63] of array[1..2] of Byte=(
(*    0000110111 *) ( 55,10), (* 0 *)
(*           010 *) (  2, 3), (* 1 *)
(*            11 *) (  3, 2), (* 2 *)
(*            10 *) (  2, 2), (* 3 *)
(*           011 *) (  3, 3), (* 4 *)
(*          0011 *) (  3, 4), (* 5 *)
(*          0010 *) (  2, 4), (* 6 *)
(*         00011 *) (  3, 5), (* 7 *)
(*        000101 *) (  5, 6), (* 8 *)
(*        000100 *) (  4, 6), (* 9 *)
(*       0000100 *) (  4, 7), (* 10 *)
(*       0000101 *) (  5, 7), (* 11 *)
(*       0000111 *) (  7, 7), (* 12 *)
(*      00000100 *) (  4, 8), (* 13 *)
(*      00000111 *) (  7, 8), (* 14 *)
(*     000011000 *) ( 24, 9), (* 15 *)
(*    0000010111 *) ( 23,10), (* 16 *)
(*    0000011000 *) ( 24,10), (* 17 *)
(*    0000001000 *) (  8,10), (* 18 *)
(*   00001100111 *) (103,11), (* 19 *)
(*   00001101000 *) (104,11), (* 20 *)
(*   00001101100 *) (108,11), (* 21 *)
(*   00000110111 *) ( 55,11), (* 22 *)
(*   00000101000 *) ( 40,11), (* 23 *)
(*   00000010111 *) ( 23,11), (* 24 *)
(*   00000011000 *) ( 24,11), (* 25 *)
(*  000011001010 *) (202,12), (* 26 *)
(*  000011001011 *) (203,12), (* 27 *)
(*  000011001100 *) (204,12), (* 28 *)
(*  000011001101 *) (205,12), (* 29 *)
(*  000001101000 *) (104,12), (* 30 *)
(*  000001101001 *) (105,12), (* 31 *)
(*  000001101010 *) (106,12), (* 32 *)
(*  000001101011 *) (107,12), (* 33 *)
(*  000011010010 *) (210,12), (* 34 *)
(*  000011010011 *) (211,12), (* 35 *)
(*  000011010100 *) (212,12), (* 36 *)
(*  000011010101 *) (213,12), (* 37 *)
(*  000011010110 *) (214,12), (* 38 *)
(*  000011010111 *) (215,12), (* 39 *)
(*  000001101100 *) (108,12), (* 40 *)
(*  000001101101 *) (109,12), (* 41 *)
(*  000011011010 *) (218,12), (* 42 *)
(*  000011011011 *) (219,12), (* 43 *)
(*  000001010100 *) ( 84,12), (* 44 *)
(*  000001010101 *) ( 85,12), (* 45 *)
(*  000001010110 *) ( 86,12), (* 46 *)
(*  000001010111 *) ( 87,12), (* 47 *)
(*  000001100100 *) (100,12), (* 48 *)
(*  000001100101 *) (101,12), (* 49 *)
(*  000001010010 *) ( 82,12), (* 50 *)
(*  000001010011 *) ( 83,12), (* 51 *)
(*  000000100100 *) ( 36,12), (* 52 *)
(*  000000110111 *) ( 55,12), (* 53 *)
(*  000000111000 *) ( 56,12), (* 54 *)
(*  000000100111 *) ( 39,12), (* 55 *)
(*  000000101000 *) ( 40,12), (* 56 *)
(*  000001011000 *) ( 88,12), (* 57 *)
(*  000001011001 *) ( 89,12), (* 58 *)
(*  000000101011 *) ( 43,12), (* 59 *)
(*  000000101100 *) ( 44,12), (* 60 *)
(*  000001011010 *) ( 90,12), (* 61 *)
(*  000001100110 *) (102,12), (* 62 *)
(*  000001100111 *) (103,12));(* 63 *)

MakeUpBlackCodes:
  array[1..27] of array[1..2] of Byte=(
(*    0000001111 *) ( 15,10), (* 64 *)
(*  000011001000 *) (200,12), (* 128 *)
(*  000011001001 *) (201,12), (* 192 *)
(*  000001011011 *) ( 91,12), (* 256 *)
(*  000000110011 *) ( 51,12), (* 320 *)
(*  000000110100 *) ( 52,12), (* 384 *)
(*  000000110101 *) ( 53,12), (* 448 *)
(* 0000001101100 *) (108,13), (* 512 *)
(* 0000001101101 *) (109,13), (* 576 *)
(* 0000001001010 *) ( 74,13), (* 640 *)
(* 0000001001011 *) ( 75,13), (* 704 *)
(* 0000001001100 *) ( 76,13), (* 768 *)
(* 0000001001101 *) ( 77,13), (* 832 *)
(* 0000001110010 *) (114,13), (* 896 *)
(* 0000001110011 *) (115,13), (* 960 *)
(* 0000001110100 *) (116,13), (* 1024 *)
(* 0000001110101 *) (117,13), (* 1088 *)
(* 0000001110110 *) (118,13), (* 1152 *)
(* 0000001110111 *) (119,13), (* 1216 *)
(* 0000001010010 *) ( 82,13), (* 1280 *)
(* 0000001010011 *) ( 83,13), (* 1344 *)
(* 0000001010100 *) ( 84,13), (* 1408 *)
(* 0000001010101 *) ( 85,13), (* 1472 *)
(* 0000001011010 *) ( 90,13), (* 1536 *)
(* 0000001011011 *) ( 91,13), (* 1600 *)
(* 0000001100100 *) (100,13), (* 1664 *)
(* 0000001100101 *) (101,13));(* 1728 *)

Procedure Sendline(hstr:string);

var
    faxrow:Array[1..1000] of Byte;
    faxbit:Word; (* Aktuelles Bit in Faxzeile *)
    faxmask:Word;

Procedure AddBits(bits,laenge:Word);
var mask:Word;
begin
  mask := 1;
  while laenge>1 do
  begin
    mask := mask*2;
    dec(laenge);
  end;
  while mask>0 do
  begin
    faxmask := faxmask*2;
    if (faxmask = 0) or (faxmask=$100) then
    begin
      faxmask := $1;
      inc(faxbit);
    end;
    if (bits and mask)<>0 then
    begin
      faxrow[faxbit] := faxrow[faxbit] or faxmask;
    end;
    mask := mask div 2;
  end;
end;

procedure AddWhitetoFax(anz:Word);
begin
  if anz>=64 then
  begin (* Startup Char *)
    AddBits(MakeUpWhiteCodes[anz div 64,1],MakeUpWhiteCodes[anz div 64,2]);
    anz := anz mod 64;
  end;
  AddBits(TerminatingWhiteCodes[anz,1],TerminatingWhiteCodes[anz,2]);
end;

procedure AddBlacktoFax(anz:Word);
var bits:word;
    laenge:Byte;
    mask:Word;
begin
  if anz>=64 then
  begin (* Startup Char *)
    AddBits(MakeUpBlackCodes[anz div 64,1],MakeUpBlackCodes[anz div 64,2]);
    anz := anz mod 64;
  end;
  AddBits(TerminatingBlackCodes[anz,1],TerminatingBlackCodes[anz,2]);
end;

procedure SendEol;
begin
  if faxbit<20 then faxbit := 20;
  inc(faxbit,4);
  faxrow[faxbit] := $80;
end;


var
    white,black,sw:Word;
    iswhite:boolean;
    mat:array[1..80,1..16] of byte;
    reg:registers;
    i1,zl,bit,bitmehrfach:Word;

begin
  while length(hstr)>80 do
  begin
    sendline(copy(hstr,1,80));
    delete(hstr,1,80);
    hstr := ' '+hstr;
  end;
  writeln(hstr);
  reg.ax := $1130;
  reg.bh := $06;  (* 06h ROM 8x16 font (MCGA, VGA) *)
  intr($10,reg);
  fillchar(faxrow,sizeof(faxrow),0);
  fillchar(mat,sizeof(mat),0);
  for i1 := 1 to length(hstr) do
  begin
    move(ptr(reg.es,reg.bp+ord(hstr[i1])*16)^,mat[i1],16);
  end;
  (* Matrix in Faxzeile konvertieren *)
  bitMehrfach := 1;
  for zl := 1 to 16 do
  begin
    iswhite := true;
    white := 30;
    black := 0;
    i1 := 1;
    bit := $80;
    faxbit := 0;
    faxmask := 0;
    while i1<=length(hstr) do
    begin
      if (mat[i1,zl] and bit)=0 then
      begin
        (* Weiß *)
        if iswhite then inc(white)
        else
        begin  (* Schwarz abschließen *)
          AddBlackToFax(black);
          inc(sw,black);
          iswhite := true;
          white := 1;
        end;
      end
      else
      begin
        (* Schwarz *)
        if not iswhite then inc(black)
        else
        begin (* Weiß abschließen *)
          AddWhiteToFax(white);
          inc(sw,white);
          iswhite := false;
          black := 1;
        end;
      end;
      if bitmehrfach>0 then dec(bitmehrfach)
                       else
                       begin
                         bit := bit div 2;
                         bitMehrfach := 1;
                       end;
      if bit=0 then
      begin
        inc(i1);
        bit := $80;
      end;
    end;
    if not iswhite then
    begin
      AddBlackToFax(1);
      inc(sw);
    end;
    if sw<1728 then
    begin
      AddWhiteToFax(1728-sw);
    end;
    SendEol;
    sw := 0;
    (* Faxrow zum Modem senden *)
    for i1 := 1 to faxbit do
    begin
      if faxrow[i1]=16 then
      begin
        sendchar(chr(faxrow[i1]));
      end;
      sendchar(chr(faxrow[i1]));
    end;
    delay(40);
    fillchar(faxrow,sizeof(faxrow),0);
    if charavail then getstring;
  end;
end;

end.

{ --------------------   DEMO PROGRAM   -------------------- }

uses dosfax,crt;


var txt:text;
    hstr:string;
    i1:Word;

begin
  clrscr;

  InitModem(1,'02561/91371-7324');
  Dial('T','02561913717324'); (*  474168 *)

  assign(txt,'text.txt');
  reset(txt);
  while not eof(txt) do
  begin
    readln(txt,hstr);
    Sendline(hstr);
  end;
  for i1 := 1 to 12 do
  begin
    Sendline('');
  end;

  EndPage;

  close(txt);
end.