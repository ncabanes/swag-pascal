(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0044.PAS
  Description: UART
  Author: JONAS MALMSTEN
  Date: 05-25-94  08:24
*)


{
I've read some questions latelly with questions about how to use a com-port in
pascal. I've written a couple of procedures for doing this. The following
routines can be improved, for example they can be satt to run on interrupts
and a few other thing, but... I'm not supposed to do all the job for you, am
I??
}

USES CRT,DOS;


CONST
     Com1 : WORD = 1;
     Com2 : WORD = 2;

type
    port = object
       port: byte;
       base: word;
       baud: longint;
       inter: byte;
       function init(comport: word; baudrate: longint): boolean;
       function sendchar(c: char): boolean;
       function getchar(var c: char): boolean;
    end;

function port.init(comport: word; baudrate: longint): boolean;
var
   tmp: word;
   bas: word;
   test: byte;
begin
     if odd(comport) then inter:=$C else inter:=$B;
                          {This is for later use with interrupts...}
     init:=false;
     if comport<5 then
     begin
          asm {get port base address}
             mov bx,40h
             mov es,bx
             mov bx,comport
             dec bx
             shl bx,1
             mov ax,es:[bx]
             mov bas,ax
          end;
          if bas=0 then
          begin
               writeln('Could''n find selected com-port!');
               exit;
          end;
     end
     else
     begin
          case comport of {don't know where to find ps/2 etd
                           bios, standard base is supposed}
            5: bas:=$4220;
            6: bas:=$4228;
            7: bas:=$5220;
            8: bas:=$5228;
          end;
     end;
     base:=bas;
     tmp:=115200 div baudrate; {baudrate divisor}
     asm {lower DTS and DSR}
        mov dx,bas
        add dx,4
        xor al,al
        out dx,al
     end;
     delay(50);
     asm {raise DTS and DSR}
        mov dx,bas
        add dx,4
        mov al,11b
        out dx,al
     end;
     asm {set baudrate and N,8,1}
        mov dx,bas
        add dx,3
        mov al,10000011b {N,8,1, set baudrate divisor}
        out dx,al
        mov ax,tmp {baudrate divisor}
        mov dx,bas
        out dx,al
        inc dx
        mov al,ah
        out dx,al
        mov dx,bas
        add dx,3
        mov al,00000011b {N,8,1}
        out dx,al
     end;
     asm {interrupt enable, no interrupts enabled --> gain time}
        mov dx,bas
        inc dx
        xor al,al
        out dx,al
     end;
     asm {raise DTS and DSR}
        mov dx,bas
        add dx,4
        mov al,11b
        out dx,al
        in al,dx
        and al,11b
        mov test,al
     end;
     if test<>3 then
     begin
          writeln('Some error....');
          exit;
     end;
     init:=true;
end;

function port.sendchar(c: char): boolean;
var
   bas: word;
   cts: byte;
label
     no_send;
begin
     cts:=0;
     bas:=base;
     asm
        mov dx,bas
        add dx,5
        in al,dx
        and al,00100000b {test CTS (Clear To Send status)}
        jz no_send
        mov cts,1
        mov dx,bas
        mov al,c
        out dx,al
     no_send:
     end;
     if cts=0 then sendchar:=false else sendchar:=true;
end;

function port.getchar(var c: char): boolean;
var
   bas: word;
   rts: byte;
   c2: char;
label
     no_data;
begin
     rts:=0;
     bas:=base;
     asm
        mov dx,bas
        add dx,5
        in al,dx
        and al,00000001b {test for data ready}
        jz no_data
        mov rts,1
        mov dx,bas
        in al,dx
     no_data:
        mov c2,al
     end;
     c:=c2;
     if rts=0 then getchar:=false else getchar:=true;
end;


var
   modem: port;
   s: string;
   a: byte;
   c : Char;

begin
     if not modem.init(com2,38400) then
     begin
          writeln('Couldn''t initialize modem...');
          halt;
     end;
     s:='atz'+#13;
     for a:=1 to length(s) do modem.sendchar(s[a]);

end.


If you think these routines are just great and you decide to use them as they
are I wouldn't mind if you gave me a credit.

