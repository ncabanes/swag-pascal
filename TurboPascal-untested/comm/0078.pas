{
> Does anyone have any units that will allow me to use a fossil in my
> programs?  If so, are these units preset for printing to the screen and
> the modem?  I would VERY much apprecieate any help.

Here  is  a  copy of my very own fossil interface, I made them because I
couldn't find simple/good enough code out  there.  I like 'em because of
their simplicity.  Only the basic commands are here, if you want to  add
more  then download X00 (or the fido specs) for a chart of the functions
and add your own.
}

Unit FComm;
interface

function  Comm_Init(port:byte):boolean;{Inits the port for communications,
returns true if successfull}procedure Comm_DeInit;{DeInits the port}

procedure Comm_Baud(baud:word);{Sets the speed of the port (not needed), always
uses 8N1}procedure Comm_DTR(DTR_Up:boolean);{raises/lowers DTR}
function  Comm_Carrier:boolean;{TRUE if Carrier detected}

procedure Comm_Tx(sendbyte:byte);{Send a byte to port}
function  Comm_Rx_Ready:boolean;{TRUE if char waiting in buffer}
function  Comm_Rx:byte;{Get a byte from port}


implementation

var Comm_Port:word;{Port to use, in FOSSIL format. ie. COM1=0}
    StatBit:Word;{Status Bit}


function Comm_Init(port:byte):boolean;
var t:word;
begin
     Comm_Port:=port-1;
     asm
        mov ah, 4h
        mov dx, Comm_Port
        int 14h
        mov t, ax
     end;
     Comm_Init:=t=$1954
end;

procedure Comm_DeInit;
begin
     asm
        mov ah, 5h
        mov dx, Comm_Port
        int 14h
     end;
end;

procedure Comm_Baud(baud:word);
var Newbaud:byte;
begin
     Case Baud div 10 of        {finds the bit value version of the baud}
          30:  Newbaud:=$43;
          60:  Newbaud:=$63;
          120: Newbaud:=$83;
          240: Newbaud:=$A3;
          480: Newbaud:=$C3;
          960: Newbaud:=$E3;
          1920:Newbaud:=$03;
          3840:Newbaud:=$23;
   end;
     asm
        mov ah, 0h
        mov al, Newbaud
        mov dx, Comm_Port
        int 14h
     end;
end;

procedure Comm_DTR(DTR_Up:boolean);
var DTRBit:byte;
begin
     If DTR_Up
        then DTRBit:=1
        else DTRBit:=0;
     asm
        mov ah, 6h
        mov al, DTRBit
        mov dx, Comm_Port
        int 14h
     end;
end;

function Comm_Carrier:boolean;
begin
     asm
        mov ah, 3h
        mov dx, Comm_Port
        int 14h
        mov StatBit, ax
     end;
     Comm_Carrier:=(StatBit and 128) <> 0;      {Bit 7=CD Signal}
end;

procedure Comm_Tx(sendbyte:byte);
begin
     asm
        mov ah, 1h
        mov al, SendByte
        mov dx, Comm_Port
        int 14h
     end;
end;

function  Comm_Rx_Ready:boolean;
begin
     asm
        mov ah, 3h
        mov dx, Comm_Port
        int 14h
        mov StatBit, ax
     end;
     Comm_Rx_Ready:=(StatBit and $100) <> 0;{Bit 0 of AH!}
end;

function  Comm_Rx:byte;
var temp:byte;
begin
     asm
        mov ah, 2h
        mov dx, Comm_Port
        int 14h
        mov temp, al
     end;
     Comm_Rx:=temp;
end;


end .{Unit}

