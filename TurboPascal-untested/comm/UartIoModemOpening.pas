(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0074.PAS
  Description: Uart IO / Modem Opening
  Author: THOMAS FINK
  Date: 11-26-94  05:05
*)

{
From: Thomas.Fink@User.AenF.WAU.NL

>If anyone has ANY source code for Opening and closing and basic
>I/O to Modems.  PLEASE send it to me.

You asked for it..............
It's pretty lengthy and comments are in german!  :-)
I did it myself and use it for several years now:

File:   V24UART.PAS

Typ:    Unit, universell.

Autor:  T.Fink

Zweck:  Hardwarenaher Zugriff auf die V24-Schnittstelle.

Copyr.: Thomas Fink, Graurheindorfer Straße 81, 5300 Bonn 1.

  Datum  I Modifikation                                             I durch:
---------+----------------------------------------------------------+---------
09.06.89 I Erstellung                                               I TF
02.02.92 I Header                                                   I
21.05.93 I COM3 & 4                                                 I
}
unit V24UART;

interface

uses
  ST,                   { Str80 }
  TIME;                 { StartTicks, ReadTicks, TicksperSecond }


{ Konfiguration der Schnittstelle }
type
  V24Kanal   = ( V24COM1, V24COM2, V24COM3, V24COM4, V24COMNone );
  V24Baud    = ( V24B2, V24B300, V24B1200, V24B2400,
                 V24B4800, V24B9600, V24B19200
               );
  V24Data    = ( V24D5, V24D6, V24D7, V24D8 );
  V24Parity  = ( V24None, V24Odd, V24Even, V24Zero, V24One );
  V24Stop    = ( V24S1, V24S2 );


{ Stati und Fehlermeldungen }
type
  V24Stati    = ( V24RData, V24OverrunErr, V24ParityErr, V24FrameErr,
                  V24Break, V24Bufempty,   V24TFree,     V24X,
                  V24DCTS,  V24DDSR,       V24TRI,       V24DDCD,
                  V24CTS,   V24noDSR,      V24RI,        V24DCD,
                  V24Timeout
                );
  V24Status   = set of V24Stati;
  V24Controls = ( V24DTR,   V24RTS,        V24Out1,      V24Out2,
                  V24Loop
                );
  V24Control  = set of V24Controls;

function  V24RStat:boolean;                     { ob Zeichen empfangen wurde }
function  V24TStat:boolean;                     { ob Sende.Reg. & H.S. frei }
function  V24RByte:byte;                        { Wartet, bis Ch empfangen }
procedure V24TByte( B:byte );                   { Wartet, bis Ch gesendet }
function  V24ReceiveByte:byte;                  { Bricht mit Timeout ab }
procedure V24TransmitByte( B:byte );            { Bricht mit Timeout ab }
procedure V24Select( K:V24Kanal );              { Wählt Schnittstelle aus }
procedure V24Init( B:V24Baud; D:V24Data; P:V24Parity; S:V24Stop; ds:word );
function  V24Error( var E:V24Status ):boolean;  { ob Fehler aufgetreten ist }
procedure V24SetControl( C:V24Control );        { setzt DTR&CTS               }
function  V24THand:boolean;                     { ob Handshake Senden erlaubt }
procedure V24RHand( B:boolean );                { setzt Handshake für Partner }
procedure V24TBreak;                            { sendet ein Break }
procedure V24Config;                            { interaktive Konfiguration }
function  V24StatusString(S:V24Status):string;  { gibt Status an }
function  V24ErrorString(S:V24Status):Str80;    { nur die Fehler }
procedure V24StatusDump;                        { gibt momentanen Status aus }
function  V24GetDSR:boolean;                    { schneller }
function  V24GetDCD:boolean;

var
  V24KanalStatus     : V24Kanal;


(*

Beschreibung der Pins der V24-Schnittstelle:

Typ: DTE (Terminal), männlich.

DB25 DB9
 Pin Pin Name  Richtung  Verwendung
  2   3  TD    Out       Gesendete Daten
  3   2  RD    In        Empfangene Daten
  4   7  RTS   Out       Handshake, Sendeerlaubnis                      *1
  5   8  CTS   In        Handshake, Empfangsbereitschaft der Gegenseite *2
  6   6  DSR   In        Betriebsbereitschaft der Gegenstelle
  7   5  GND   ---       Erde
  8   1  DCD   In        ---
 20   4  DTR   Out       Betriebsbereitschaft der Software              *3

*1 : Diese Leitung kann abweichend von der V24-Norm betrieben werden,
     z.B. um um ein bidirektionales Handshake oder eine Gerätesteuerung
     zu ermoeglichen.
*2 : Ermöglicht die Sendefreigabe innerhalb des UARTs.
*3 : Kann als +12V zum Kurzschließen des Handshakes (CTS,DSR) dienen.
*)


implementation

const
  V24KanalMax     = 3;
  V24BaudMax      = 6;
  V24DataMax      = 3;
  V24ParityMax    = 4;
  V24StopMax      = 1;

  V24KanalId    : array[ V24Kanal ] of string[4]
                = ( 'COM1', 'COM2', 'COM3', 'COM4', 'None' );
  V24BaudId     : array[ V24Baud ] of string[5]
                = ( '2', '300', '1200', '2400', '4800', '9600', '19200' );
  V24DataId     : array[ V24Data ] of char
                = ( '5', '6', '7', '8' );
  V24ParityId   : array[ V24Parity ] of string[4]
                = ( 'none', 'odd', 'even', 'zero', 'one' );
  V24StopId     : array[ V24Stop ] of char
                = ( '1', '2' );

  V24BaudDat    : array[V24Baud] of word
                = ( 2, 300, 1200, 2400, 4800, 9600, 19200 );
  V24ParityDat : array[V24Parity] of byte
                = ( 0, 1, 3, 5, 7 );


{ Stati und Fehlermeldungen }

const
  V24StatusId     : array[V24Stati] of string[14]
                  = ( 'Data_received',  'Overrun_Error',    { $01, $02 }
                      'Parity_Error',   'Frame_Error',      { $04, $08 }
                      'Break_received', 'Buffer_empty',     { $10, $20 }
                      'Transmit_free',  '',                 { $40, $80 }
                      'CTS_changed',    'DSR_changed',      { $01, $02 }
                      'Ring_started',   'DCD_changed',      { $04, $08 }
                      'CTS',            'noDSR',            { $10, $20 }
                      'Ring',           'DCD',              { $40, $80 }
                      'Timeout'
                    );
  V24ControlId    : array[V24Controls] of string[9]
                  = ( 'DTR', 'RTS', 'IRQ1', 'IRQ2', 'Loop_Mode' );

  V24Errors       : V24Status
                  = [ V24FrameErr, V24ParityErr,
                      V24OverrunErr, V24Timeout
                      { V24noDSR }
                    ];

{.FF}

{ Register }
const
  V24PortAdr         : array[ V24Kanal ] of word
                     = ( $3F8, $2F8, $3E8, $2E8, 0 );   { COM1, COM2, COM3,
COM4 }
  V24DataReg         = 0;
  V24IRQEnReg        = 1;
  V24RateLReg        = 0;
  V24RateHReg        = 1;
  V24IRQIdReg        = 2;
  V24ModeReg         = 3;
  V24ModemControlReg = 4;
  V24StatusReg       = 5;
  V24ModemStatusReg  = 6;
  V24ScratchReg      = 7;


{ Software-Status Variablen }
const
  V24Port            : word    = $3F8;
  V24KanalSelected   : boolean = false;
var
  V24PortStatus : record case boolean of
                    true  : ( S : V24Status );
                    false : ( B0,B1,B2 : byte );
                  end;
  V24Timed      : boolean;
  V24TimeOutVal : longint;
  V24TimeOutArr : array[ V24Kanal ] of longint;
  V24Time       : Ticker;

{****************************************************************************}

{ Simple Chipzugriffe }

function V24RStat:boolean;   { true wenn Zeichen empfangen }
begin
  V24RStat:= ( port[V24Port+V24StatusReg] and $01 <> 0 );
end;

{ true wenn Senderegister leer }
function V24TStat:boolean;
begin
  V24TStat:=     ( port[V24Port+V24StatusReg] and $40 <> 0 )
{            and ( port[V24Port+V24ModemStatusReg] and $30 = $30 ) CTS und DSR
}
             ;
end;

function V24RByte:byte;             { Wartet, bis Ch empfangen }
begin
  repeat until V24RStat;
  V24RByte:=port[V24Port+V24DataReg];
end;

procedure V24TByte(B: byte);        { Wartet, bis Ch gesendet }
begin
  repeat until V24TStat;
  port[V24Port+V24DataReg]:=B;
end;

{*****************************************************************************}

var
  I : integer;

function V24ReceiveByte:byte;          { Bricht mit Timeout ab }
begin
  for I:=1 to 1000 do                  { bei hohen Baudraten notwendig }
    if V24RStat then
      begin
        V24ReceiveByte:= port[ V24Port + V24DataReg ];
        exit;
      end
    ;
  ;

  StartTicker( V24Time );
  while not V24RStat do
    if ReadTicker( V24Time )>V24TimeOutVal then    { 20 us }
      begin
        V24Timed:=true;
        V24ReceiveByte:=0;
        exit;
      end
    ;
  ;
  V24ReceiveByte:= port[V24Port+V24DataReg];
end;

procedure V24TransmitByte(B: byte);    { Bricht mit Timeout ab }
begin
  for I:=1 to 1000 do
    if V24TStat then
      begin
        port[V24Port+V24DataReg]:=B;
        exit;
      end
    ;
  ;

  StartTicker( V24Time );
  while not V24TStat do
    if ReadTicker( V24Time )>V24TimeOutVal then
      begin
        V24Timed:=true;
        exit;
      end
    ;
  ;
  port[V24Port+V24DataReg]:=B;
end;

{****************************************************************************}

procedure V24Select( K:V24Kanal );
begin
  if K=V24COMNone then exit;
  V24KanalStatus:=K;
  V24Port:=V24PortAdr[ K ];
  V24TimeOutVal:=V24TimeOutArr[ K ];
  V24KanalSelected:=true;
end;



{
  Initialisieren der Baudrate, der Datenbitzahl, der Parität, der Stopbitzahl
  und der Zeit in 1/10 sec, die die Receive- &Transmit-routinen warten dürfen.
}
procedure V24Init( B:V24Baud; D:V24Data; P:V24Parity; S:V24Stop; ds:word );
const
  V24Clock = 115200;  { 1843200/16 Hertz  Quarztakt }
var
  Rate : word;
  Data : byte;
begin
  if not V24KanalSelected then
    begin
      writeln( 'V24Kanal nicht selektiert!' ); halt;
    end
  ;

  V24Timed:=false;
  V24TimeOutVal:=(longint(ds) * 18) div 10;
  V24TimeOutArr[ V24KanalStatus ] := V24TimeOutVal;

  port[V24Port+V24ModeReg]:=$80;               { select Rate Register }
  Rate := V24Clock div V24BaudDat[B];
  port[V24Port+V24RateLReg] := lo(Rate);
  port[V24Port+V24RateHReg] := hi(Rate);
  port[V24Port+V24ModeReg]  :=    ord(D)
                               or ord(S) shl 2
                               or V24ParityDat[P] shl 3
                               ;
  port[V24Port+V24IRQEnReg] := 0;
  port[V24Port+V24ModemControlReg]:= $01; { DTR };
  port[V24Port+V24StatusReg]:= 0;
  Data:=port[V24Port+V24DataReg];
end;

function V24Error(var E:V24Status):boolean;
var
  B    : boolean;
  Data : byte;
begin
  V24PortStatus.B0 := port[ V24Port+V24StatusReg ];
  V24PortStatus.B1 := port[ V24Port+V24ModemStatusReg ] xor $20; { inv DSR }
  V24PortStatus.B2 := ord( V24Timed );
  V24Timed := false;
  E        := V24PortStatus.S;
  B        := ( E * V24Errors <> [] );
  if B then Data:=port[ V24Port+V24DataReg ];
  V24Error := B;
end;

function V24GetDSR:boolean;
begin
  V24GetDSR:=(  port[ V24Port+V24ModemStatusReg ] and $20 )>0;
end;

function V24GetDCD:boolean;
begin
  V24GetDCD:=(  port[ V24Port+V24ModemStatusReg ] and $80 )>0;
end;

{****************************************************************************}

procedure V24SetControl( C:V24Control );        { setzt DTR&CTS               }
begin
  port[ V24Port+V24ModemControlReg ] := byte( C );
end;

function V24THand:boolean;
begin
  V24THand:=( port[V24Port+V24ModemStatusReg] and $30 = $30 );
  { V24DSR, V24CTS }
end;

procedure V24RHand(B:boolean);                { Pin 5 }
begin
  if B
  then V24SetControl( [ V24DTR, V24RTS ] )
  else V24SetControl( [ V24DTR ] )
  ;
end;

procedure V24TBreak;
begin
  port[V24Port+V24ModeReg] := port[V24Port+V24ModeReg] or $40;
  V24TByte(0);
  port[V24Port+V24ModeReg] := port[V24Port+V24ModeReg] and $BF;
end;

{****************************************************************************}

procedure V24Config;
var
  H,I,J,K,L : byte;
  T         : word;
begin

  repeat
    writeln; writeln( 'V24-Kanal:' );
    for H:=0 to V24KanalMax do
      writeln( succ( H ), ') ', V24KanalId[ V24Kanal( H ) ] )
    ;
    write( 'Ihre Wahl? ' );  readln( H );
  until ( H>0 ) and ( H<=succ(V24KanalMax) );

  repeat
    writeln; writeln( 'V24-Baudrate:' );
    for I:=0 to V24BaudMax do
      writeln( succ(I), ') ', V24BaudId[V24Baud(I)] )
    ;
    write( 'Ihre Wahl? ' );  readln(I);
  until (I>0) and ( I<=succ(V24BaudMax) );

  repeat
    writeln; writeln( 'V24-Datenbits:' );
    for J:=0 to V24DataMax do
      writeln(succ(J), ') ', V24DataId[V24Data(J)] )
    ;
    write('Ihre Wahl? ');  readln(J);
  until (J>0) and ( J<=succ(V24DataMax) );

  repeat
    writeln; writeln('V24-Parity:');
    for K:=0 to V24ParityMax do
      writeln(succ(K), ') ', V24ParityId[V24Parity(K)] )
    ;
    write('Ihre Wahl? ');  readln(K);
  until (K>0) and ( K<=succ(V24ParityMax) );

  repeat
    writeln; writeln('V24-Stopbits:');
    for L:=0 to V24StopMax do
      writeln(succ(L), ') ', V24StopId[V24Stop(L)] )
    ;
    write('Ihre Wahl? ');  readln(L);
  until (L>0) and ( L<=succ(V24StopMax) );

  repeat
    writeln; writeln( 'V24-Timeout Zeit (0s..6500s)' );
    write( 'Zeit in 1/10 Sekunden? ' );
    readln( T );
  until T<=6500;

  V24Select( V24Kanal( pred( H ) ) );
  V24Init( V24Baud(pred(I)), V24Data(pred(J)),
           V24Parity(pred(K)), V24Stop(pred(L)),
           T
         );

end;

function V24StatusString(S:V24Status):string;
var
  T : string;
  F : V24Stati;
begin
  T:='Error: ';
  if (S*V24Errors<>[]) then T:='Error!' else T:='OK.';
  T:='  Flags:';
  for F:=V24RData to V24Timeout do
    if F in S then
      T:=T+' '+V24StatusId[F]
    ;
  ;
  V24StatusString:=T;
end;

function V24ErrorString(S:V24Status):Str80;
var
  T : Str80;
  F : V24Stati;
begin
  S:=S*V24Errors;
  T:='';
  for F:=V24OverrunErr to V24Timeout do
    if F in S then
      T:=T+' '+V24StatusId[F]
    ;
  ;
  V24ErrorString:=T;
end;

procedure V24StatusDump;
var
  H : boolean;
  S : V24Status;
begin
  H:=V24Error(S);
  writeln( V24StatusString(S) );
end;

procedure Test;
var
  B : byte;
begin
  V24Select( V24COM1 );
  V24Init( V24B19200, V24D8, V24None, V24S1, 100 );   { 9.78sec }
  write( 'OK? ' ); readln;
  B:=V24ReceiveByte;
  writeln( 'Fertig!' );
end;

end. { V24UART.PAS }

