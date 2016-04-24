(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0096.PAS
  Description: Useful Serial I/O
  Author: PETER MANDRELLA
  Date: 02-21-96  21:04
*)

{ Unit UART - serielle I/O v3    07/91,08/92,01/93 }
{ by Peter Mandrella, P.Mandrella@HOT.gun.de       }
{ Dieser Quelltext ist Public Domain.              }

{$B-,R-,S-,V-,F-,I-,A+}

unit uart;

{---------------------------------------------------------------------------)
   Zu benutzende Schnittstellen sind zuerst mit SetUart zu initialisieren.
   Anschlie▀end k÷nnen sie mit ActivateCom aktiviert und mit ReleaseCom
   wieder freigegeben werden. Beim Aktivieren ist die Gr÷▀e des COM-Puffers
   anzugeben; werden mehr als BufferSize Bytes empfangen und nicht abgeholt,
   dann wird der Puffer komplett gel÷scht und der Inhalt geht verloren!
   Das Desaktivieren ist nicht unbedingt n÷tig, sondern erfolgt falls
   n÷tig auch automatisch bei Programmende.

   Das Empfangen von Daten erfolgt asynchron im Hintergrund. Mit Receive
   k÷nnen empfangene Daten abgeholt werden. Die Funktion liefert FALSE,
   falls keine Daten vorhanden waren. Wahlweise kann auch mit Received
   getestet werden, ob Daten anliegen, ohne diese zu lesen, oder mit
   Peek ein Byte - falls vorhanden - abgeholt, aber nicht aus dem Puffer
   entfernt werden.

   Das Senden von Daten erfolgt mit SendByte (ohne CTS-Handshake) oder
   mit HSendByte (mit CTS-Handshake).

   ▄ber die Funktionen RRing und Carrier kann getestet werden, ob ein
   Klingelzeichen bzw. ein Carrier am Modem anliegt.

   Da fⁿr COM3 und COM4 kein Default-IRQ existiert, k÷nnen mit SetComParams
   Adresse und IRQ einzelner Schnittstellen eingestellt werden. Vor dieser
   Einstellung werden COM3 und COM4 nicht unterstⁿtzt. Default-Adressen
   sind $3e8 und $2e8. Die Parameter von COM1 und COM2 sind korrekt
   eingestellt und sollten normalerweise nicht geΣndert werden.

(---------------------------------------------------------------------------}


interface

uses dos;

{$IFNDEF DPMI}
  const Seg0040 = $40;
{$ENDIF}

const  coms       = 4;     { Anzahl der unterstⁿtzten Schnittstellen }

       ua         : array[1..coms] of word = ($3f8,$2f8,$3e8,$2e8);
       datainout  = 0;     { UART-Register-Offsets }
       intenable  = 1;
       intids     = 2;     { Read  }
       fifoctrl   = 2;     { Write }
       linectrl   = 3;
       modemctrl  = 4;
       linestat   = 5;
       modemstat  = 6;
       scratch    = 7;

       UartNone   = 0;     { Ergebnisse von ComType }
       Uart8250   = 1;
       Uart16450  = 2;
       Uart16550  = 3;
       Uart16550A = 4;

       NoFifo     = $00;   { Triggerlevel bei 16550-Chips }
       FifoTL1    = $07;
       FifoTL4    = $47;
       FifoTL8    = $87;
       FifoTL14   = $C7;

type   paritype   = (Pnone,Podd,Pxxxx,Peven);   { m÷gliche ParitΣts-Typen }


{ Parameter fⁿr Schnittstelle einstellen
{ no       : Nummer  (1-4)
  address  : I/O-Adresse, 0 -> Adresse wird beibehalten
  _irq     : Interrupt-Nummer  (z.B. 3 fⁿr IRQ3, 4 fⁿr IRQ4); 0..15 }

procedure SetComParams(no:byte; address:word; _irq:byte);

{ Schnittstellen-Parameter einstellen
  commno   : Nummer der Schnittstelle (1-4)
  baudrate : Baudrate im Klartext; auch nicht-Standard-Baudraten m÷glich!
  parity   : s.o.
  wlength  : Wort-lΣnge (7 oder 8)
  stops    : Stop-Bits (1 oder 2)   }

function ComType(no:byte):byte;     { Typ des UART-Chips ermitteln }

procedure SetUart(comno:byte; baudrate:longint; parity:paritype;
                  wlength,stops:byte);

{ Schnittstelle aktivieren
  no         : Nummer der Schnittstelle
  buffersize : Gr÷▀e des Puffers
  FifoTL     : Falls ein 16550 vorhanden ist, kann man hier die Konstanten
               fⁿr den Triggerlevel einsetzen (s.o.)}

procedure ActivateCom(no:byte; buffersize:word; FifoTL:Byte);

procedure ReleaseCom(no:byte);            { Schnitte desakt., Puffer freig. }

function  receive(no:byte; var b:byte):boolean;   { Byte holen, falls vorh. }
function  peek(no:byte; var b:byte):boolean; {dito, aber Byte bleibt im Puffer}
function  received(no:byte):boolean;      { Testen, ob Daten vorhanden }
procedure flushinput(no:byte);            { Receive-Puffer l÷schen }
procedure SendByte(no,b:byte);            { Byte senden }
procedure hsendbyte(no,b:byte);           { Byte senden, mit CTS-Handshake }
procedure putbyte(no,b:byte);             { Byte im Puffer hinterlegen }

function  rring(no:byte):boolean;         { Telefon klingelt  }
function  carrier(no:byte):boolean;       { Carrier vorhanden }
function  getCTS(no:byte):boolean;        { True = (cts=1)    }
procedure DropDtr(no:byte);               { DTR=0 setzen      }
procedure SetDtr(no:byte);                { DTR=1 setzen      }
procedure DropRts(no:byte);               { RTS=0 setzen      }
procedure SetRts(no:byte);                { RTS=1 setzen      }
procedure SendBreak(no:byte);             { Break-Signal      }


implementation  {-----------------------------------------------------}

const  active     : array[1..coms] of boolean = (false,false,false,false);
       irq        : array[1..coms] of byte = ($04,$03,0,0);
       intmask    : array[1..coms] of byte = ($10,$08,0,0);
       intcom2    : array[1..coms] of boolean = (false,false,false,false);

       MS_CTS     = $10;       { Modem-Status-Register }
       MS_DSR     = $20;
       MS_RI      = $40;       { Ring Indicator: Klingelsignal }
       MS_DCD     = $80;       { Data Carrier Detect           }
       MC_DTR     = $01;       { Modem Control Register }
       MC_RTS     = $02;

type   bufft      = array[0..65534] of byte;

var    savecom    : array[1..coms] of pointer;
       exitsave   : pointer;
       bufsize    : array[1..coms] of word;
       buffer     : array[1..coms] of ^bufft;
       bufi,bufo  : array[1..coms] of word;


procedure error(text:string);
begin
  writeln('UART Fehler: ',text);
end;

function strs(l:longint):string;
var s : string;
begin
  str(l,s);
  strs:=s;
end;


{--- Interrupt-Handler -----------------------------------------------}

procedure cli; inline($fa);            { Interrupts sperren   }
procedure sti; inline($fb);            { Interrupts freigeben }

procedure com1server; interrupt;
begin
  if intcom2[1] then port[$a0]:=$20;
  port[$20]:=$20;                      { Interrupt-Controller resetten }
  buffer[1]^[bufi[1]]:=port[ua[1]];
  inc(bufi[1]); if bufi[1]=bufsize[1] then bufi[1]:=0;
end;

procedure com2server; interrupt;
begin
  if intcom2[2] then port[$a0]:=$20;
  port[$20]:=$20;
  buffer[2]^[bufi[2]]:=port[ua[2]];
  inc(bufi[2]); if bufi[2]=bufsize[2] then bufi[2]:=0;
end;

procedure com3server; interrupt;
begin
  if intcom2[3] then port[$a0]:=$20;
  port[$20]:=$20;
  buffer[3]^[bufi[3]]:=port[ua[3]];
  inc(bufi[3]); if bufi[3]=bufsize[3] then bufi[3]:=0;
end;

procedure com4server; interrupt;
begin
  if intcom2[4] then port[$a0]:=$20;
  port[$20]:=$20;
  buffer[4]^[bufi[4]]:=port[ua[4]];
  inc(bufi[4]); if bufi[4]=bufsize[4] then bufi[4]:=0;
end;

procedure com1FIFOserver; interrupt;
begin
  if port[ua[1]+intids] and 4<>0 then
    repeat
      buffer[1]^[bufi[1]]:=port[ua[1]];
      inc(bufi[1]); if bufi[1]=bufsize[1] then bufi[1]:=0;
    until not odd(port[ua[1]+linestat]);
  if intcom2[1] then port[$a0]:=$20;
  port[$20]:=$20;                      { Interrupt-Controller resetten }
end;

procedure com2FIFOserver; interrupt;
begin
  if port[ua[2]+intids] and 4<>0 then
    repeat
      buffer[2]^[bufi[2]]:=port[ua[2]];
      inc(bufi[2]); if bufi[2]=bufsize[2] then bufi[2]:=0;
    until not odd(port[ua[2]+linestat]);
  if intcom2[2] then port[$a0]:=$20;
  port[$20]:=$20;
end;

procedure com3FIFOserver; interrupt;
begin
  if port[ua[3]+intids] and 4<>0 then
    repeat
      buffer[3]^[bufi[3]]:=port[ua[3]];
      inc(bufi[3]); if bufi[3]=bufsize[3] then bufi[3]:=0;
    until not odd(port[ua[3]+linestat]);
  if intcom2[3] then port[$a0]:=$20;
  port[$20]:=$20;
end;

procedure com4FIFOserver; interrupt;
begin
  if port[ua[4]+intids] and 4<>0 then
    repeat
      buffer[4]^[bufi[4]]:=port[ua[4]];
      inc(bufi[4]); if bufi[4]=bufsize[4] then bufi[4]:=0;
    until not odd(port[ua[4]+linestat]);
  if intcom2[4] then port[$a0]:=$20;
  port[$20]:=$20;
end;


{--- UART-Typ ermitteln ----------------------------------------------}

{ Hinweis: Die Erkennung des 16550A funktioniert nur bei Chips,  }
{          die weitgehend kompatibel zum Original-16550A von NS  }
{          sind. Das gilt allerdings fⁿr die meisten verwendeten }
{          16500A's - ich schΣtze, fⁿr ca. 97-99%                }

function ComType(no:byte):byte;     { Typ des UART-Chips ermitteln }
var uart        : word;
    lsave,ssave : byte;
    isave,iir   : byte;
begin
  uart:=ua[no];
  lsave:=port[uart+linectrl];
  port[uart+linectrl]:=lsave xor $ff;
  if port[uart+linectrl]<>lsave xor $ff then
    ComType:=UartNone
  else begin
    port[uart+linectrl]:=lsave;
    ssave:=port[uart+scratch];
    port[uart+scratch]:=$5a;
    if port[uart+scratch]<>$5a then
      ComType:=Uart8250                 { kein Scratchpad vorhanden }
    else begin
      port[uart+scratch]:=$a5;
      if port[uart+scratch]<>$a5 then
        ComType:=Uart8250               { kein Scratchpad vorhanden }
      else begin
        isave:=port[uart+intids];
        port[uart+fifoctrl]:=1;
        iir:=port[uart+intids];
        if isave and $80=0 then port[uart+fifoctrl]:=0;
        if iir and $40<>0 then ComType:=Uart16550A
        else if iir and $80<>0 then ComType:=Uart16550
        else ComType:=Uart16450;
        end;
      end;
    port[uart+scratch]:=ssave;
    end;
end;


{--- Schnitte einstellen / aktivieren / freigeben --------------------}

procedure SetComParams(no:byte; address:word; _irq:byte);
begin
  if (no>=1) and (no<=coms) then begin
    if address<>0 then ua[no]:=address;
    irq[no]:=_irq;
    intmask[no]:=(1 shl (_irq and 7));
    intcom2[no]:=(_irq>7);      { 2. Interrupt-Controller }
    end;
end;

procedure setuart(comno:byte; baudrate:longint; parity:paritype;
                  wlength,stops:byte);
var uart : word;
begin
  uart:=ua[comno];
  port[uart+linectrl]:=$80;
  port[uart+datainout]:=lo(word(115200 div baudrate));
  port[uart+datainout+1]:=hi(word(115200 div baudrate));
  port[uart+linectrl]:= (wlength-5) or (stops-1)*4 or ord(parity)*8;
  port[uart+modemctrl]:=$0b;
  if port[uart+datainout]<>0 then;      { dummy }
end;


procedure clearstatus(no:byte);
begin
  if port[ua[no]+datainout]<>0 then;               { dummy-Read }
  if port[ua[no]+linestat]<>0 then;
  if port[ua[no]+modemstat]<>0 then;
  if intcom2[no] then port[$a0]:=$20;
  port[$20]:=$20;
end;


function IntNr(no:byte):byte;
begin
  if irq[no]<8 then IntNr:=irq[no]+8
  else IntNr:=irq[no]+$68;
end;

procedure ActivateCom(no:byte; buffersize:word; FifoTL:Byte);
var p : pointer;
    i : byte;
begin
  if active[no] then begin
    error('Schnittstelle '+strs(no)+' bereits aktiviert!');
    exit;
    end
  else if (no<1) or (no>coms) or (irq[no]=0) then
    error('Schnittstelle '+strs(no)+' (noch) nicht unterstⁿtzt!')
  else
    active[no]:=true;

  bufsize[no]:=buffersize;                 { Puffer anlegen }
  getmem(buffer[no],buffersize);
  bufi[no]:=0; bufo[no]:=0;
  fillchar(buffer[no]^,bufsize[no],0);

  IF (fifotl > 0)
    THEN BEGIN
           Port[(ua[no] + fifoctrl)] := fifotl;
           IF ((Port[(ua[no] + intids)] AND $40) = 0)
             THEN BEGIN
                    Port[(ua[no] + fifoctrl)] := 0;
                    fifotl := NoFifo;
                  END;
         END;

  IF (fifotl > 0)
    THEN CASE no OF
           1 : p:=@com1FIFOserver;
           2 : p:=@com2FIFOserver;
           3 : p:=@com3FIFOserver;
           4 : p:=@com4FIFOserver;
         END {CASE}
    ELSE CASE no OF
           1 : p:=@com1server;
           2 : p:=@com2server;
           3 : p:=@com3server;
           4 : p:=@com4server;
         END; {CASE}

  getintvec(IntNr(no),savecom[no]);           { IRQ setzen }
  setintvec(IntNr(no),p);
  port[ua[no]+intenable]:=$01;                     { Int. bei Empfang }
  if intcom2[no] then
    port[$a1]:=port[$a1] and (not intmask[no])     { Ints freigeben }
  else
    port[$21]:=port[$21] and (not intmask[no]);
  clearstatus(no);
end;


procedure releasecom(no:byte);
begin
  if not active[no] then
    error('Schnittstelle '+strs(no)+' nicht aktiv!')
  else begin
    active[no]:=false;
    port[ua[no]+intenable]:=0;
    if intcom2[no] then
      port[$a1]:=port[$a1] or intmask[no]    { Controller: COMn-Ints sperren }
    else
      port[$21]:=port[$21] or intmask[no];
    port[ua[no]+fifoctrl]:=0;
    setintvec(IntNr(no),savecom[no]);
    clearstatus(no);
    freemem(buffer[no],bufsize[no]);
    end;
end;


{ Exit-Prozedur }

{$F+}
procedure comexit;
var i : byte;
begin
  for i:=1 to coms do
    if active[i] then begin
      DropDtr(i);
      releasecom(i);
      end;
  exitproc:=exitsave;
end;
{$F-}


{--- Daten senden / empfangen ----------------------------------------}

function received(no:byte):boolean;      { Testen, ob Daten vorhanden }
begin
  received:=(bufi[no]<>bufo[no]);
end;


function receive(no:byte; var b:byte):boolean;   { Byte holen, falls vorh. }
begin
  if bufi[no]=bufo[no] then
    receive:=false
  else begin
    b:=buffer[no]^[bufo[no]];
    inc(bufo[no]);
    if bufo[no]=bufsize[no] then bufo[no]:=0;
    receive:=true;
    end;
end;

function peek(no:byte; var b:byte):boolean;
begin
  if bufi[no]=bufo[no] then
    peek:=false
  else begin
    b:=buffer[no]^[bufo[no]];
    peek:=true;
    end;
end;

procedure sendbyte(no,b:byte);              { Byte senden }
begin
  while (port[ua[no]+linestat] and $20) = 0 do;
  port[ua[no]]:=b;
end;

procedure hsendbyte(no,b:byte);           { Byte senden, mit CTS-Handshake }
begin
  while (port[ua[no]+modemstat] and $10) = 0 do;
  while (port[ua[no]+linestat] and $20) = 0 do;
  port[ua[no]]:=b;
end;

procedure putbyte(no,b:byte);             { Byte im Puffer hinterlegen }
begin
  if bufo[no]=0 then bufo[no]:=bufsize[no]
  else dec(bufo[no]);
  buffer[no]^[bufo[no]]:=b;
end;

procedure flushinput(no:byte);            { Receive-Puffer l÷schen }
begin
  bufo[no]:=bufi[no];
end;


{--- Modem-Status-Lines ----------------------------------------------}

function rring(no:byte):boolean;            { Telefon klingelt  }
begin
  rring:=(port[ua[no]+modemstat] and MS_RI)<>0;
end;

function carrier(no:byte):boolean;          { Carrier vorhanden }
begin
  carrier:=(port[ua[no]+modemstat] and MS_DCD)<>0;
end;

procedure DropDtr(no:byte);                 { DTR=0 setzen      }
begin
  port[ua[no]+modemctrl]:=port[ua[no]+modemctrl] and (not MC_DTR);
end;

procedure SetDtr(no:byte);                  { DTR=1 setzen      }
begin
  port[ua[no]+modemctrl]:=port[ua[no]+modemctrl] or MC_DTR;
end;

procedure DropRts(no:byte);                 { RTS=0 setzen      }
begin
  port[ua[no]+modemctrl]:=port[ua[no]+modemctrl] and (not MC_RTS);
end;

procedure SetRts(no:byte);                  { RTS=1 setzen      }
begin
  port[ua[no]+modemctrl]:=port[ua[no]+modemctrl] or MC_RTS;
end;


{ True -> Modem (oder entsprechendes GerΣt)  ist bereit, Daten zu empfangen }

function GetCTS(no:byte):boolean;
begin
  getcts:=((port[ua[no]+modemstat] and $10)<>0) and
           ((port[ua[no]+linestat] and $20)<>0);
end;


function ticker:longint;
begin
  ticker:=meml[Seg0040:$6c];
end;

procedure SendBreak(no:byte);             { Break-Signal      }
var teiler : word;
    btime  : longint;
    t0     : longint;
begin
  CLI;
  port[ua[no]+linectrl]:=port[ua[no]+linectrl] or $80;
  teiler:=port[ua[no]] + 256*port[ua[no]+1];
  port[ua[no]+linectrl]:=port[ua[no]+linectrl] and $7f;
  STI;
  btime:=teiler DIV 200;
  IF (btime<1) THEN btime:=1;
  t0:=ticker;
  inc(btime,ticker);
  Port[ua[no]+linectrl]:=port[ua[no]+linectrl] or $40;   { set break }
  repeat
  until (ticker>btime) or (ticker<t0);
  Port[ua[no]+linectrl]:=port[ua[no]+linectrl] and $bf;  { clear break }
end;

begin
  exitsave:=exitproc;
  exitproc:=@comexit;
end.
