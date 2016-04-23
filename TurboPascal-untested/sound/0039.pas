
{
If anyone can fill me in on how to output in stereo, I'd be very
appreciative... I've heard that port $220/$221 is for left channel,
$222/$223 is for the right, but that doesn't make any sense...does it?

This code makes R2D2 noises on a SoundBlaster until you press ESC.

{adapted from SS4CH.PAS by Frank Hirsch}
USES Crt;

const sampleSize=4096;
var sampleData:array[0..sampleSize-1]of byte;
const samplePos:longint=0;
var sampleSpeed:longint;
var sampleDelta:longint;

const resetPort =$226;
const readPort  =$22A;
const writePort =$22C;
const dataAvailPort=$22E;

function readByte:byte;begin
 repeat until shortInt(port[dataAvailPort])<0;
 readByte:=port[readPort];
 end;

procedure initDSP;begin
 port[resetPort]:=1;
 delay(1);
 port[resetPort]:=0;
 repeat until readByte=$AA;
 end;

var counter:longint;

procedure timerInt;assembler;asm
  push ax
  push bx
  push dx
  push di
  push ds
  push es
  mov ax,seg @DATA
  mov ds,ax

  mov es,[segB800]
  xor byte ptr es:[0],$21

  mov bx,[word ptr samplePos+2]
  mov ah,byte ptr sampleData[bx]
  mov dx,[word ptr sampleSpeed]    {next sample byte}
  add [word ptr samplePos],dx
  adc bx,[word ptr sampleSpeed+2]
  and bx,[sampleSize-1]
  mov [word ptr samplePos+2],bx
  mov bx,[word ptr sampleDelta]
  add [word ptr sampleSpeed],bx
  mov bx,[word ptr sampleDelta+2]
  adc [word ptr sampleSpeed+2],bx
  mov dx,writePort
 @P2:              {ready for output byte?}
  in al,dx
  test al,$80
  jnz @P2
  mov al,ah
  out dx,al

  mov al,$20       {process interrupt}
  out $20,al
{  sti}
                   {prep NEXT output}
 @P1:              {ready for command?}
  in al,dx
  test al,$80
  jnz @P1
  mov al,$10       {set up a DAC output}
  out dx,al

  db $66; inc word ptr [counter]

  pop es
  pop ds
  pop di
  pop dx
  pop bx
  pop ax
  iret
  end;

var
  vec08:pointer absolute 0:8*4;
  old08:pointer;

procedure setTimerTics(tics:word);begin
  asm cli; end;
  port[$43]:=$36;
  port[$40]:=lo(tics);
  port[$40]:=hi(tics);
  asm sti end;
  end;

procedure setTimerFreq(freq:word);begin
  setTimerTics(succ(word($1234DC div freq)));
  end;

procedure stopTimer;begin setTimerTics(0); end;

procedure writeByte(b:byte);begin
  repeat until shortInt(port[writePort])>=0;
  port[writePort]:=b;
  end;

procedure speaker(onOff:boolean);begin
  if onOff then writeByte($D1)
  else writeByte($D3);
  end;

var i,j,n:word;

const rate=16384;

procedure note(freq,dur,slide:longint);
begin
  counter:=0;
  sampleSpeed:=freq*sampleSize*(65536 div rate);
  sampleDelta:=slide;
  dur:=(dur*rate)div 1000;
  repeat
    if port[$60]=$81 then break;
    until counter>=dur;
  end;


begin
 initDSP;
 for i:=0 to sampleSize-1 do
   sampleData[i]:=round(sin(i*pi/(sampleSize shr 1))*127.5+127.5);
 old08:=vec08;
 speaker(true);
 writeByte($10);  {prep sb for data}
 asm cli end;
 vec08:=@timerInt;
 asm sti end;
 setTimerFreq(rate);
 repeat
   case random(4) of
     0:note(random(1900)+60,(random(2)*80)+40,integer(random(3))-1);
     1:note(random(800)+450,(random(2)*80)+140,integer(random(2049))
                                                              -1024);
     2:note(0,(random(2)+1)*40,0);
     3:note(random(30)+15,(random(2)*80)+40,random(2));
     end;
   until port[$60]=$81;
 stopTimer;
 asm cli end;
 vec08:=old08;
 asm sti end;
 speaker(false);  {it's probably gonna eat this as data}
 speaker(false);
 end.
