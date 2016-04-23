Unit FWizard;

{/
      Fossil Wizard Unit v1.0 by Steve Connet - Tuesday, Jan. 19, 1993

       This program provides an easy interface to access the routines
       provided by a fossil driver.
//}

INTERFACE
Function SetBaud(Port, Baud : Word; Parms : Byte) : Boolean;
Function OutBufferFull(Port : Word) : Boolean;
Function CharWaiting(Port : Word) : Boolean;
Function ComReadChar(Port : Word) : Char;
Function CarrierDetected(Port : Word) : Boolean;
Function ModemRinging(Port : Word) : Boolean;
Function FossilPresent : Boolean;
Function RemoteAnsiDetected(Port : Word) : Boolean;
Function LocalAnsiDetected : Boolean;
Function RemoteAvatarDetected(Port : Word) : Boolean;

Procedure ActivatePort(Port : Word);
Procedure DTR(Port : Word; Action : Byte);
Procedure ReBoot(Action : Byte);
Procedure DeActivatePort(Port : Word);
Procedure ComWriteChar(Port : Word; Ch : Char);
Procedure ClearOutBuffer(Port : Word);
Procedure ClearInBuffer(Port : Word);
Procedure FlowControl(Port : Word; XON_XOFFR, XON_XOFFT, RTS_CTS : Boolean);
Procedure WatchDog(Port : Word; Action : Byte);
Procedure Chat(Port : Word);
Procedure ComWrite(Port : Word; Msg : String);
Procedure ComWriteln(Port : Word; Msg : String);
Procedure Wait(Seconds : Word);
Procedure GetCursor(VAR x, y : Byte);
Procedure SetCursor(Port : Word; x, y : Byte);
Procedure SendBreak(Port : Word);
Procedure ComReadln(Port : Word; VAR Msg : String; Count : Byte);
Procedure CLS(Port : Word);

CONST
  N81=$03; E81 =$1b; O81 =$0b; LOWER=$00; CTS =$10; RDA =$01; XONR=$01;
  N82=$07; E82 =$1f; O82 =$0f; RAISE=$01; DSR =$20; THRE=$20; XONT=$08;
  N71=$02; E71 =$1a; O71 =$0a; COLD =$00; RI  =$40; TSRE=$40; RTS =$02;
  N72=$06; E72 =$1e; O72 =$0e; WARM =$01; DCD =$80; ON  =$01; OFF =$00;
  Esc=#27; COM1=$00; COM2=$01; COM3 =$02; COM4=$03;

IMPLEMENTATION
Uses Crt;

Function SetBaud(Port, Baud : Word; Parms : Byte) : Boolean;
VAR Dummy : Word;
Begin
  Case Baud of
    300:   Baud := $40;    { 01000000 }
    600:   Baud := $60;    { 01100000 }
    1200:  Baud := $80;    { 10000000 }
    2400:  Baud := $a0;    { 10100000 }
    4800:  Baud := $c0;    { 11000000 }
    9600:  Baud := $e0;    { 11100000 }
    19200: Baud := $00;    { 00000000 }
    38400,
    14400,
    16800: Baud := $20;    { 00100000 }
  End;
  Parms := Parms OR Baud;  { merge baud bits with parm bits }
  Asm
    mov ah,00h
    mov al,parms
    mov dx,port
    int 14h
    mov dummy,ax
  End;
  SetBaud := ((Dummy AND CTS) = CTS) or     { clear to send }
             ((Dummy AND DSR) = DSR) or     { data set ready }
             ((Dummy AND RI)  = RI)  or     { ring indicator }
             ((Dummy AND DCD) = DCD)        { data carrier detect }
End;

Function OutBufferFull(Port : Word) : Boolean;
VAR Dummy : Byte;
Begin
  Asm
    mov ah,03h
    mov dx,port
    int 14h
    mov dummy,ah
  End;
  OutBufferFull := ((Dummy AND THRE) <> THRE) or  { room in out buffer }
                   ((Dummy AND TSRE) <> TSRE)     { out buffer empty }
End;

Function CharWaiting(Port : Word) : Boolean;
VAR Dummy : Byte;
Begin
  Asm
    mov ah,03h
    mov dx,port
    int 14h
    mov dummy,ah
  End;
  CharWaiting := (Dummy AND RDA) = RDA        { character waiting }
End;

Function ComReadChar(Port : Word) : Char;
VAR Dummy : Byte;
Begin
  Asm
    mov ah,02h
    mov dx,port
    int 14h
    mov dummy,al
  End;
  ComReadChar := Char(Dummy)
End;

Function CarrierDetected(Port : Word) : Boolean;
VAR Dummy : Byte;
Begin
  Asm
    mov ah,03h
    mov dx,port
    int 14h
    mov dummy,al
  End;
  CarrierDetected := (Dummy AND DCD) = DCD       { carrier detected }
End;

Function ModemRinging(Port : Word) : Boolean;
VAR Dummy : Byte;
Begin
  Asm
    mov ah,03h
    mov dx,port
    int 14h
    mov dummy,al
  End;
  ModemRinging := (Dummy AND RI) = RI       { ring indicated }
End;

Function FossilPresent : Boolean;
VAR Dummy : Word;
Begin
  Asm
    mov ah,04h
    mov dx,00ffh
    int 14h
    mov dummy,ax
  End;
  FossilPresent := Dummy = $1954;
End;

Function RemoteAnsiDetected(Port : Word) : Boolean;
VAR Dummy : Char;
Begin
  If Not OutBufferFull(Port) then
  Begin
    ComWriteChar(Port, #27); ComWriteChar(Port, '[');
    ComWriteChar(Port, '6'); ComWriteChar(Port, 'n')
  End;
  If CharWaiting(Port) then
     RemoteAnsiDetected := ComReadChar(Port) in [#27,'0'..'9','[','H'] else
     RemoteAnsiDetected := False;
  ClearInBuffer(Port)
End;

Function LocalAnsiDetected : Boolean;
VAR Dummy : Byte;
Begin
  Asm
    mov ah,1ah                { detect ANSI.SYS device driver }
    mov al,00h
    int 2fh
    mov dummy,al
  End;
  LocalAnsiDetected := Dummy = $FF
End;

Function RemoteAvatarDetected(Port : Word) : Boolean;
Begin
  If Not OutBufferFull(Port) then
  Begin
    ComWriteChar(Port, ' '); ComWriteChar(Port, ' ');
    ComWriteChar(Port, ' ');
  End;
  If CharWaiting(Port) then
     RemoteAvatarDetected := ComReadChar(Port) in ['A','V','T'] else
     RemoteAvatarDetected := False;
  ClearInBuffer(Port)
End;


Procedure ActivatePort(Port : Word); Assembler;
Asm
  mov ah,04h
  mov dx,port
  int 14h
End;

Procedure DTR(Port : Word; Action : Byte); Assembler;
Asm
  mov ah,06h
  mov al,action
  mov dx,port
  int 14h
End;

Procedure ReBoot(Action : Byte); Assembler;
Asm
  mov ah,17h
  mov al,action
  int 14h
End;

Procedure DeActivatePort(Port : Word); Assembler;
Asm
  mov ax,05h
  mov dx,port
  int 14h
End;

Procedure ComWriteChar(Port : Word; Ch : Char);
VAR Dummy : Byte;
Begin
  Dummy := Ord(Ch);
  Asm
    mov ah,01h
    mov al,dummy
    mov dx,port
    int 14h
  End;
End;

Procedure ClearOutBuffer(Port : Word); Assembler;
Asm
  mov ah,09h
  mov dx,port
  int 14h
End;

Procedure ClearInBuffer(Port : Word); Assembler;
Asm
  mov ah,0ah
  mov dx,port
  int 14h
End;

Procedure FlowControl(Port : Word; XON_XOFFR, XON_XOFFT, RTS_CTS : Boolean);
VAR Dummy : Byte;
Begin
  Dummy := $00;
  If XON_XOFFR then                 { Xon/Xoff receive enable }
     Dummy := Dummy OR XONR else    { set bit 0 on }
     Dummy := Dummy AND XONR;       { set bit 0 off }
  If XON_XOFFT then                 { Xon/Xoff transmit enable }
     Dummy := Dummy OR XONT else    { set bit 3 on }
     Dummy := Dummy AND XONT;       { set bit 3 off }
  If RTS_CTS then                   { RTS_CTS enabled }
     Dummy := Dummy OR RTS else     { set bit 1 on }
     Dummy := Dummy AND RTS;        { set bit 1 off }
  Asm
    mov ah,0fh
    mov al,dummy
    mov dx,port
    int 14h
  End
End;

Procedure WatchDog(Port : Word; Action : Byte); Assembler;
Asm
  mov ah,14h
  mov al,action
  mov dx,port
  int 14h
End;

Procedure Chat(Port : Word);

VAR Ch,
  AnsiCh : Char;
  Ansi   : Text;
Begin
  Assign(Ansi,'');
  ReWrite(Ansi);
  Repeat
     If Keypressed then
     Begin
       Ch := Readkey;
       If Ch <> Esc then
          ComWriteChar(Port,ch)
     End;
     If CharWaiting(Port) then
     Begin
        AnsiCh := ComReadChar(Port);
        If FossilPresent then
        Asm
          mov ah,13h
          mov al,ansich
          int 14h
        End else
        Write(Ansi,AnsiCh)          { no fossil driver }
     End
  Until Ch = Esc;
  Close(Ansi)
End;

Procedure ComWrite(Port : Word; Msg : String);
VAR Dummy, x,
    SegMsg,
    OfsMsg : Word;
    Ansich : Char;
    Ansi   : Text;
Begin
  Assign(Ansi,'');
  ReWrite(Ansi);
  Dummy := Ord(Msg[0]);             { length (msg) }
  If FossilPresent then
  Begin
    SegMsg := Seg(Msg);
    OfsMsg := Ofs(Msg) + 1;           { don't include length of msg }
    Asm                               { use fossil driver }
      mov ah,19h
      mov dx,port
      mov cx,dummy
      mov es,SegMsg
      mov di,OfsMsg
      int 14h
    End;
    While CharWaiting(Port) do
    Begin
      AnsiCh := ComReadChar(Port);
      Asm
        mov ah,13h
        mov al,ansich
        int 14h
      End
    End
  End else
  For x := 1 to dummy do
  Begin
    ComWriteChar(Port,Msg[x]);
    If CharWaiting(Port) then
      Write(Ansi,ComReadChar(Port))
  End;
  Close(Ansi)
End;

Procedure ComWriteln(Port : Word; Msg : String);
Begin
   Msg := Msg + #13 + #10;
   ComWrite(Port, Msg)
End;

Procedure Wait(Seconds : Word);
VAR Delay : Word;
Begin
   Delay := ((976 SHL 10) * Seconds) SHR 16;  { (976*1024*seconds)/65536 }
   Asm
     mov ah,86h
     mov cx,delay
     mov dx,0
     int 15h
   End
End;

Procedure GetCursor(VAR x, y : Byte);
VAR x1, y1 : Byte;
Begin
  If FossilPresent then
  Asm
    mov ah,12h
    int 14h
    mov x1,dl
    mov y1,dh
  End else
  Asm
    mov ah,03h
    mov bh,00h
    int 10h
    mov x1,dl
    mov y1,dh
  End;
  x := x1; y := y1
End;

Procedure SetCursor(Port : Word; x, y : Byte);
VAR x1,y1 : String;
Begin
  If FossilPresent then
  Asm
    mov ah,11h
    mov dh,y
    mov dl,x
    int 14h
  End else
  Asm
    mov ah,02h
    mov bh,00h
    mov dh,y
    mov dl,x
    int 10h
  End;
  If (CarrierDetected(port)) and (RemoteAnsiDetected(Port)) then
  Begin
    Str(x,x1);
    Str(y,y1);
    ComWrite(Port,' ['+y1+';'+x1+'H')     { ESC[y;xH }
  End
End;

Procedure SendBreak(Port : Word); Assembler;
Asm
  mov ah,1ah             {; start sending break }
  mov al,01h
  mov dx,port
  int 14h
  mov ah,86h             {; wait 1 second }
  mov cx,0fh
  mov dx,00h
  int 15h
  mov ah,1ah             {; stop sending break }
  mov al,00h
  mov dx,port
  int 14h
  mov ah,0ah             {; purge input buffer }
  mov dx,port
  int 14h
End;

Procedure ComReadln(Port : Word; VAR Msg : String; Count : Byte);
VAR WLength,
    SegMsg,
    OfsMsg : Word;
Begin
   SegMsg := Seg(Msg);
   OfsMsg := Ofs(Msg);
   WLength := Count;
   Asm
     mov ah,18h
     mov di,ofsmsg
     mov es,segmsg
     mov cx,wlength
     mov dx,port
     int 14h
   End;
End;

Procedure CLS(Port : Word);
Begin
  ClrScr;
  If CarrierDetected(Port) then
     If RemoteAnsiDetected(Port) then
        ComWrite(Port,' [2J') else
        ComWriteChar(Port,' ');
End;

Begin
   Writeln('Fossil Wizard v1.0 by Steve Connet - Jan. 19, 1993');
   Writeln('This is removed when you register.');
   Wait(2)
End.


(* This is an example of how to use Fossil Wizard *)

Uses FWizard, Crt;

VAR
         Ch : Char;
       Baud : Word;

Begin
  Baud := 2400;    { change this to the appropriate baud }
  ClrScr;

  SetCursor(Com2,50,19);
  If FossilPresent then
  Begin
    ActivatePort(Com2);                { wake up fossil driver }
    Write('[FOSSIL PRESENT]')
  End else
  Write('[FOSSIL NOT PRESENT]');

  SetCursor(Com2,50,20);
  If SetBaud(Com2,Baud,N81) then       { set baud rate }
     Write('[MODEM READY]') else
     Write('[MODEM NOT RESPONDING]');

  SetCursor(Com2,50,21);
  If CarrierDetected(Com2) then
     Write('[CARRIER DETECTED]') else
     Write('[NO CARRIER]');

  SetCursor(Com2,50,22);
  If (CarrierDetected(Com2)) and (RemoteAvatarDetected(Com2)) then
    Write('[REMOTE AVATAR DETECTED]') else
    Write('[REMOTE AVATAR NOT DETECTED]');

  SetCursor(Com2,50,23);
  If (CarrierDetected(Com2)) and (RemoteAnsiDetected(Com2)) then
    Write('[REMOTE ANSI DETECTED]') else
    Write('[REMOTE ANSI NOT DETECTED]');

  SetCursor(Com2,50,24);
  If LocalAnsiDetected then
     Write('[LOCAL ANSI DETECTED]') else
     Write('[LOCAL ANSI NOT DETECTED]');

  SetCursor(Com2,0,0);
  Chat(Com2);              { built in chat mode }
  DTR(Com2,Lower);         { lower data terminal ready }
  DeActivatePort(Com2);    { put fossil driver to sleep }
  ClrScr
End.
