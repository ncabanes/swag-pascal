{
I am using a PCCOM 4-port serial card and this unit works with a small test
program but when I use it in a larger program (executable approx 48k) I only
get some of the characters from the port.
The serial card is 16450 based with vector at $02BF..
I have done very little interrupt programming so I don't know if that is the
problem.

Thanks........
}
unit mycom;

interface

procedure Async_ISR; interrupt;
procedure XmitChar(Serial_IOPort:byte;C: char);  { Uses variable and constant declarations from}
function  RemoteReadKey(Serial_IOPort:byte): char;  { Uses var and const from above }
function  RemoteKeyPressed(Serial_IOPort:byte):boolean;  { Uses vars and consts from above }
procedure InitPort(Serial_IOPort:byte);
procedure InitInter;
procedure TerminateInter;
function  COM_BufSize (Serial_IOPort:byte):byte;

implementation


USES DOS,crt;

var COM_mask:byte;
    COM_Buffer: array [0..3] of array[0 .. 129] of char;  { A buffer for input}
    COM_Temp,  { Varible to hold various modem statuses }
    COM_CommPort: byte;  { Comm Port in use }
    COM_Head : array [0..3] of byte;  { Size of the buffer }
    OldInt0Dh :pointer;
    OldPIC:byte;

const COM_IRQ_Number = $07;
      COM_IRQ_Vector = $0F;


const
  BaseAddr: array[0 .. 3] of word = ($02A0, $02A8, $02B0, $02B8);
  Baud=38400;                     { Speed required }
  Divisor:word = 115200 div Baud; { or 1843200 / (16 * Baud) }
                                  {    ^   UART clock speed  }

procedure Async_ISR;
   CONST Buf_Pnt:POINTER=@COM_Buffer;

  begin
{  WRITE('*'); }
  asm
  STI { STI - Disable interrupts }
  PUSHA
  PUSH SS
  MOV CL,00           { Com Port Counter 0 - 3 => COM5 - COM8}
@NextVector:
  MOV DX, 02BFh               { WHO WANTED AN INTERRUPT ? }
  MOV BL,01
  SHL BL,CL
  IN AL,DX
  TEST AL,BL
  JNZ @CheckNextVector
  MOV DX, 02A0h               { BASE OF FIRST PORT }
  MOV AL,08
  MUL CL
  ADD DX,AX                  { GOT BASE ADDRESS IN DX }
@GoBackForMore:
  ADD DX,02h
  IN AL,DX                   { CHECK INTERRUPT ID REGISTER }
  SUB DX,02h
  TEST AL,01h                { NO IRQ PENDING }
  JNZ @CheckNextVector
  AND AL,06h
  CMP AL,04h                  { DID WE RECEIVE A CHARACTER }
  JNZ @CheckMore               { NO ? THEN WHAT ELSE }
  IN AL,DX                    { READ INPUT FROM PORT }
  MOV BH,AL                   { PUT DATA IN BH FOR LATER }
  LDS SI,Buf_Pnt
  LES DI,Buf_Pnt
  MOV AL,130            { SIZE OF BUFFER + 2 for size & tail pointer }
  MUL CL
  ADD SI,AX
  ADD DI,AX                    { FOUND BUFFER[COM_PORT] }
  LODSB
  CMP AL,127                  { IF BUFFER FULL IGNORE CHARACTER }
  JA @CheckForAnotherIRQ
  INC AL                      { INC SIZE IF ROOM }
  STOSB                       { WRITE BACK TO SIZE COUNTER }
  LODSB                        { tail pointer }
  MOV BL,AL                    { PUT TAIL POINTER IN BL }
  INC AL
  CMP AL,128
  JB @WriteTail
  MOV AL,0
@WriteTail:
  STOSB
  MOV AL,BH                    { GET BACK DATA FROM BH }
  MOV BH,0
  ADD DI,BX                    { ADD CONTENTS OF TAIL POINTER TO POINTER }
  STOSB                        { WRITE DATA TO BUFFER }
  JMP @CheckForAnotherIRQ
@CheckMore:
  CMP AH,02h                  { THD EMPTY }
  JNZ @CheckMore2

  
  { FOR LATER ADDITION OF INTERRUPT SEND ROUTINE }


  JMP @CheckForAnotherIRQ
@CheckMore2:
  CMP AH,06h                  { ERROR OR BREAK }
  JNZ @CheckForAnotherIRQ
  IN AL,DX                    { READ FROM PORT TO CLEAR OVERRUNS }
  ADD DX,05h
  IN AL,DX                    { READ LINE STATUS REGISTER }
  SUB DX,05h
@CheckForAnotherIRQ:
  JMP @GoBackForMore        { ANOTHER INTERRUPT ON THIS PORT }

@CheckNextVector:
  INC CL
  CMP CL,04h
  JNZ @NextVector
  MOV DX,0020h
  MOV AL,20h
  OUT DX,AL    { RESET PIC }
  POP SS
  POPA
  CLI          { CLI - Enable interrupts }

  end;
end;



procedure XmitChar(Serial_IOPort:byte;C: char);  { Uses variable and constant declarations from}
begin                         {  the previous example }
  repeat
{  write ('.');}
  until (port[BaseAddr[Serial_IOPort] + $05] and $20 = $20);  { Wait for THR }

  port[BaseAddr[Serial_IOPort]] := Ord(C);  { Send character }

{  textcolor(red);
  write(ord(c));
  write('.');
  textcolor(lightgray);}
end;


function RemoteReadKey(Serial_IOPort:byte): char;  { Uses var and const from above }
begin
  if ord(COM_Buffer[Serial_IOPort][0]) > 0 then begin
RemoteReadKey := COM_Buffer[Serial_IOPort][COM_Head[Serial_IOPort]+2];  {Get the character }
inc(COM_Head[Serial_IOPort]);  { Move Head to the nextcharacter }
if COM_Head[Serial_IOPort] > 127 then COM_Head[Serial_IOPort] := 0;  { Wrap Head around if necessary }
dec(COM_Buffer[Serial_IOPort][0]);  {Remove the character }  end
  else RemoteReadKey:=chr(0);
end;


function RemoteKeyPressed(Serial_IOPort:byte): boolean;  { Uses vars and consts from above }
begin
  RemoteKeyPressed := ord(COM_Buffer[Serial_IOPort][0]) > 0;  { A key was pressed if there is data in}
  end;                             {  the buffer }

procedure InitPort(Serial_IOPort:byte);
          var COM_tt:byte;
          begin
          inline($FB); { STI - Disable interrupts }
          Port[BaseAddr[Serial_IOPort]+$03]:=Port[BaseAddr[Serial_IOPort]+$03] or 128;
          { Ready to set Port speed }
          Port[BaseAddr[Serial_IOPort]]:= Lo(Divisor);
          Port[BaseAddr[Serial_IOPort]+$01]:= Hi(Divisor);  { Set Speed to 38400 }
          Port[BaseAddr[Serial_IOPort]+$03]:= $03 or $08 or $00;
                  { end set port speed and set 8  -   O  -   1 }
          Port[BaseAddr[Serial_IOPort]+$01]:= $01;
                   { set Interrupt enable on Rx Data }
          COM_tt:=Port[BaseAddr[Serial_IOPort]];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+1];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+2];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+3];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+4];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+5];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+6];
          Port[BaseAddr[Serial_IOPort]]:=0;

  COM_Head[Serial_IOPort]:=0;
  COM_Buffer[Serial_IOPort][1]:=CHR(0);  { tail }
  COM_Buffer[Serial_IOPort][0]:=chr(0);  { size }

  inline($FA);  { CLI - Enable interrupts }
          end;


procedure InitInter;
           begin
           InitPort (0);
           InitPort (1);
           InitPort (2);
           InitPort (3);
               Port[$02BF]:=$ff;
               GetIntVec(COM_IRQ_vector, OldInt0Dh);
               SetIntVec(COM_IRQ_vector, @Async_ISR);
               COM_mask := (1 shl (COM_IRQ_number)) xor $00FF;
               OldPic:=Port[$21];
               Port[$21] := OldPIC and COM_mask;
           end;

procedure TerminateInter;
          var Serial_IOPort,com_tt:byte;
          begin
{             COM_mask := 1 shl (COM_IRQ_number);}
             SetIntVec(COM_IRQ_vector, OldInt0Dh);
          for Serial_IOPort := 0 to 3 do begin
                   { set Interrupt enable off }
          COM_tt:=Port[BaseAddr[Serial_IOPort]];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+1];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+2];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+3];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+4];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+5];
          COM_tt:=Port[BaseAddr[Serial_IOPort]+6];
          Port[BaseAddr[Serial_IOPort]]:=0;
          Port[BaseAddr[Serial_IOPort]+$01]:= $00;
             Port[$21] := Port[$21] and OldPIC;
          end;
             END;

function COM_BufSize (Serial_IOPort:byte):byte;
         begin
         COM_BufSize:=ord(COM_Buffer[Serial_IOPort][0]);
         end;

end.


Com_Buffer Structure:
Byte 0 -  number of characters in buffer
Byte 1 -  tail ponter in buffer
2-129  -  128 bytes (the buffer)
