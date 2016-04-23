{
After quite some time of working on fossil routines, and using examples
from the swag, I've come up with this unit for interfacing with the modem.
However, on testing it remotely, the display doesn't appear the same as
the local one.    Is there anyone who can help with this one?

I'm real stuck on this....and would LOVE it if someone could help me.

Thanks,
▒▒▓▓░░ David Reilly ░░▓▓▒▒
dodo@rip.it.bond.edu.au

}
Unit FossilDrv;

interface

Uses Crt;

Type
    Colours = (Black, Red, Green, Brown, Blue, Magenta, Cyan, LightGrey,
               Grey, BrightRed, BrightGreen, Yellow, BrightBlue,
               BrightMagenta, BrightCyan, BrightWhite);


Var
   Local : BOOLEAN;

Procedure Colour ( Col : Colours);      { Changes colour (both locally and
                                          remotely), by sending ansi codes
                                          and changing text colour }
procedure WriteChar ( c : char );       { Writes a character directly to the
                                          comport }
procedure WriteLine;                    { Writes a <CR> to the comport }
procedure WriteString ( s : string );   { Writes a string to the comport }
procedure WriteInt ( number : integer );{ writes an integer to the comport }

procedure ReadChar ( VAR c : char );    { Reads a character, either locally
                                          or from comport }
procedure ReadString ( VAR s : string); { Reads a string, either locally or
                                          from comport }
procedure ReadInt ( VAR number:integer);{ reads an integer from the comport }
procedure Init ( port : byte);          { Initialises DLSFos routines }
procedure Finish;                       { De-initialises DLSFos routines}
function  Carrier:boolean;              { TRUE if Carrier detected }

procedure Goto_XY ( X, Y : integer);    { Goto position X, Y on ansi }
procedure Home;                         { Clears screen }
procedure Comm_Tx(sendbyte:byte);       { Send a byte to port }
function  Comm_Rx_Ready:boolean;        { TRUE if char waiting in buffer }
function  Comm_Rx:byte;                 { Get a byte from port }


implementation

var Comm_Port:word;{Port to use, in FOSSIL format. ie. COM1=0}
    StatBit:Word;{Status Bit}


function OpenFos(port:byte):boolean;
var t:word;
begin
     Comm_Port:=port-1;
     asm
        mov ah, 4h
        mov dx, Comm_Port
        int 14h
        mov t, ax
     end;
     OpenFos:=t=$1954
end;

procedure CloseFos;
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

function Carrier:boolean;
begin
     asm
        mov ah, 3h
        mov dx, Comm_Port
        int 14h
        mov StatBit, ax
     end;
     Carrier:=(StatBit and 128) <> 0;      {Bit 7=CD Signal}
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

Procedure WriteChar ( C : CHAR );
BEGIN
     if c = chr(13) then writeln
     else Write(C);
     IF Not(Local) THEN Comm_Tx ( ORD ( C ) ); { if remote, then print remote
}end;

Procedure WriteLine;
Begin
     If not(local) then Comm_Tx (13); { CARRIAGE RETURN }
     Writeln;
end;

Procedure WriteString ( S : String );
VAR
 I : Integer;
BEGIN
     FOR I := 1 to Length(S) DO
         WriteChar( S[i] );
END;

procedure home;
begin
     WriteString ('[40m[2J');
     ClrScr;
end;

Procedure ReadChar(VAR C : CHAR);
Begin
     IF Not(Local) THEN
     Begin
     REPEAT
     UNTIL Keypressed or Comm_Rx_Ready;
     IF Keypressed THEN C:= Readkey
     ELSE c := CHR(Comm_Rx);
     end
     else
     begin
          repeat
          until keypressed;
          c := Readkey;
     end;
     WriteChar ( C );
end;

Procedure Init( port : byte);
var
   Paramater : String;
Begin
     Paramater := Paramstr(1);
     Local := FALSE; { by default - unless carrier detected its local }
     if (paramater = 'local') or (paramater = 'LOCAL') THEN
        Local := TRUE
     Else if not(Carrier) then Local := True; { is local login or remote? }

     IF OpenFos( Port ) THEN
        Writeln ('Communications port opened successfully');
     IF Carrier THEN Writeln ('Carrier detected')
     ELSE Writeln ('Carrier not detected');
     Delay (500);


end;

Procedure Finish;
Var
   I : integer;
Begin
     Write (' Closing communications port ');
     For I := 1 to 5 DO Begin
          Delay (500);
          Write ('.');
     End;
     CloseFos;
end;

Procedure ReadString ( VAR S : String);

Procedure Strip ( VAR g : String );
{ removes 1 char }
Var L : Integer;
    Temp : string;
Begin
     temp := '';
     IF Length(g) >1 THEN
     Begin
     For L :=1 TO Length( g)-1 DO
         Temp := Temp + g[L];
     g := Temp;
     END
     ELSE g := '';
End;


VAR
   I : Integer;
   Character : CHAR;

Begin
     I:= 1;
     S := '';

     REPEAT
           ReadChar (Character);
           INC (I);
           IF Character = CHR(8) THEN Strip(S)
           ELSE IF Character <>Chr(13) THEN S:=S+ Character;
     UNTIL (I=255) or (Character = CHR(13));
END;

Procedure WriteInt ( Number : Integer);
Var
   NumStr : String;

Begin
   { Convert from number to string }

   Str ( Number, NumStr );

   WriteString ( NumStr );
End;

Procedure ReadInt ( VAR Number : Integer);
Var
   NumStr : String;
   Valid : Integer;

Begin
     ReadString ( NumStr );
     Val ( NumStr, Number , Valid );
     IF Not( Valid =0) THEN
     BEGIN
          Number := 0;
          WriteChar (Chr(7));
     END;
end;

Procedure Goto_XY ( X, Y : Integer);
VAR
   PosString : String;
   Position : String;
   I : Integer;
(*   debug : text;*)
BEGIN
     GotoXY(X,Y);
     if not(Local) THEN BEGIN
     PosString := CHR(27) + '[';

     Str(Y, Position);
     PosString := PosString+ Position +';';
     Str(X, Position);
     PosString := PosString + Position +'f';
(*     repeat
     until keypressed;
     assign (debug, 'debug.ans');
     append (debug);
     write (debug, posstring);
     close(debug);*)
     FOR I := 1 to Length(PosString) DO
         Comm_Tx ( ORD (PosString[i] ) ); { Print each character of ANSI
sequence }     END; { Remote at X,Y }
end;

Procedure Colour ( Col : Colours);
{    Colours = (Black, Red, Green, Brown, Blue, Magenta, Cyan, LightGrey,
               Grey, BrightRed, BrightGreen, Yellow, BrightBlue,
               BrightMagenta, BrightCyan, BrightWhite);}



Var
   ColourString : string;
   i : Integer;

Begin
     { Process local colour change }
     CASE Col   of
          { Low intesity colours}

          Black  : TextColor(0);
          Red    : TextColor(4);
          Green  : TextColor(2);
          Brown  : TextColor(6);
          Blue   : TextColor(1);
          Magenta: TextColor(5);
          Cyan   : TextColor(3);
          LightGrey : TextColor(7);

          { High intensity colours }
          Grey          : TextColor(8);
          BrightRed     : TextColor(12);
          BrightGreen   : TextColor(10);
          Yellow        : TextColor(14);
          BrightBlue    : TextColor(9);
          BrightMagenta : TextColor(13);
          BrightCyan    : TextColor(11);
          BrightWhite   : TextColor(15);

     end;

     IF not(Local) THEN BEGIN
     ColourString := CHR(27) + '['; { 27 = esc }
     CASE Col   of
          { Low intesity colours}
          Black  : ColourString := ColourString + '0;30m';
          Red    : ColourString := ColourString + '0;31m';
          Green  : ColourString := ColourString + '0;32m';
          Yellow : ColourString := ColourString + '0;33m';
          Blue   : ColourString := ColourString + '0;34m';
          Magenta: ColourString := ColourString + '0;35m';
          Cyan   : ColourString := ColourString + '0;36m';
          LightGrey : ColourString := ColourString + '0;37m';

          { High intensity colours }
          Grey          : ColourString := ColourString + '1;30m';
          BrightRed     : ColourString := ColourString + '1;31m';
          BrightGreen   : ColourString := ColourString + '1;32m';
          Yellow  : ColourString := ColourString + '1;33m';
          BrightBlue    : ColourString := ColourString + '1;34m';
          BrightMagenta : ColourString := ColourString + '1;35m';
          BrightCyan    : ColourString := ColourString + '1;36m';
          BrightWhite   : ColourString := ColourString + '1;37m';

     end;
{     WriteString (ColourString);  (* Prob. ansi written to local term *)}
     FOR I := 1 to Length(ColourString) DO
         Comm_Tx ( ORD ( ColourString[i] ) ); { Print each character }

     END; { finish remote ANSI colour change }
end;



end. {Unit}
