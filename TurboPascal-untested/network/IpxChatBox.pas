(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0032.PAS
  Description: IPX Chat Box
  Author: WILLEM VAN DE VIS
  Date: 05-26-95  23:21
*)

{
From: S0730076@let.rug.nl (ill)

I wrote a chatbox with one of those ipx units. Pretty standard but funny
because you can send the other guy screentrashes and beeps and buzzes etc.

I dare not post it here cause Timo is gonna flame me with that standard
'don't post any binaries' file so mail me if you want it. I'll include
source from the main file here, but you can't compile it without some
other units I'm afraid.
}

{$R+}
uses ipx, crt,ill,win, novell, strings;


const
     receive_socket = $7713;
     send_socket = $6613;
     starty = 7;
     maxy = 9;
     maxlen = 77;
     versie = 'Nag 0.81';

procedure abort(message:string);
begin
     writeln(message);
     halt(1);
end;

var
   i                          : byte;
   x,y,xx                     : word;
   connection_number          : word;
   network_number             : networkNumber;
   network_node               : networkNode;
   receive_ecb,send_ecb       : ECB;
   receive_header,send_header : IPXHeader;
   send_message, receive_message : MessageSTR;
   done                        : boolean;
   message,naam                : string;
   code, station               : integer;
   InStrings                   : array[1..maxy] of string[maxlen];
   blinking          : boolean;


procedure info(txt : string);
begin
 txt := '─'+txt +
'─────────────────────────────────────────────────────────────────────────────'
 writeline(copy(txt,1,78), 1, 16, black, lightgray);
end;
procedure writeInStrings;
var q: integer;
    col : word;
begin
col := lightgray;
if blinking then col := col + blink;
for q := 1 to maxy do
     writeline(InStrings[q], 1, q + starty-1,col, black);
end;


procedure wipe;
var q : integer;
begin
blinking := false;
info('Your screen is being wiped');
for q := 1 to maxy do
begin
    inStrings[q] :=
'                                                                             
';
writeInstrings;
clrscr;
x := 0;
y := 1;
end;
end;

procedure shit(ki : keytype; var shitty : char);
begin
     shitty := #0;
     case ki of
          f1 : begin
                   info('Sending BUZZ to '+paramstr(1));
                   shitty := #201;
              end;
          f2 :   begin
                     info('Sending BEEP to '+paramstr(1));
                     shitty := #202;
                end;
          f3 : begin
                   info('Sending FLASH to '+paramstr(1));
                   shitty := #203;
              end;
          f4: begin
                  info('Calling '+paramstr(1)+' a sucker');
                  shitty := #204;
             end;
         f5: begin
                  info('Blinking your text on '+paramstr(1)+'''s screen');
                  shitty := #205;
             end;
         f6: begin
                  info('Trashing the other guy''s screen');
                  shitty := #206;
             end;
          f10: wipe;

     end;
end;

procedure flash;
var q : integer;
begin
     info('The other guy is making your screen flash!');
for q := 1 to 10 do
begin
     open_win(1,1,80,24, white, white);
     delay(10);
     close_win;
end;
end;

procedure init;
begin
  if paramcount < 1 then abort('Usage: Nag <username>');
  if not IPXinstalled then abort('IPX not loaded');
  connection_number := Get1stConnectionNumber(paramstr(1));
  if connection_number = 0 then abort(paramstr(1) + ' not found. ');
  if GetInternetAddress(connection_number,network_number,network_node)
    <> 0 then abort(paramstr(1) + 'network error.');
  IpxCloseSocket(send_socket);
  if IPXOpenSocket(send_socket) <> 0 then abort('Socket error.');
  IPXCloseSocket(receive_socket);
  if IPXOpenSocket(receive_socket) <> 0 then abort('Socket error.');
  done := false;
  zeroecb(receive_ecb);
  zeroecb(send_ecb);
  y := 1;
  xx := 1;
  getstation(station,code);
  getuser(station, naam, code);
  message := naam + ' wants to nag. Type Nag '+naam;
  send_message_to_username(paramstr(1), message, code);
  wipe;
end;

procedure funkysound;
var q : integer;
begin
     info('Receiving birdnoise');
     q := 3000;
     while q > 20 do
     begin
          sound(q);
          delay(1);
          dec(q,100);
     end;
     nosound;
end;

procedure trash;
var q,x,y : word;
begin
     randomize;
     for q := 1 to 50 do
     begin
         x := random(76)+2;
         y := random(25-starty) + starty;
         fastwrite(x,y,'#',x, y);
         sound(8000);
         delay(1);
         nosound;
     end;
end;


procedure receive_shit(i : integer);
begin
     case i - 200 of
          1 : begin info(paramstr(1)+' is buzzing');
              sound(50); delay(500); nosound; end;
          2 : funkysound;
          3 : flash;
          4 : info('SUCKER!');
          5 : blinking := true;
          6 : trash;
      end;
end;


procedure receive;
var q : integer;
begin
if (receive_ecb.completion_code = 0) and (receive_ecb.in_use = 0) then
begin
     IPXReceive(receive_ecb, receive_header, receive_socket,
            @receive_message, sizeof(receive_message));
      if (receive_message < #210) and (receive_message > #200) then
      begin
         receive_shit(ord(receive_message[1]));
         exit;
      end;

      if (receive_message = chr(8)) then
      begin
           InStrings[y][x] := ' ';
           if x > 0 then
              dec(x);
      end else
           begin
               inc(x);

              if receive_message <> chr(13)  then
                    InStrings[y][x] := receive_message[1];
              if (receive_message = chr(13)) or (x >= maxlen) then
               begin
                    inc(y);
                    x := 0;
               end;
               if y =  maxy then
               begin
                    y := maxy - 1;
                    x := 0;
                    for q := 1 to maxy - 1 do
                        instrings[q] := instrings[q+1]+
'                                                                            ';
               end;
          end;
          writeInStrings;
  end;
end;
 
procedure send;
var special : boolean;
    skey    : keytype;
    r, sr       : char;
begin
     inkey(special, skey,r);
     if ord(r) > 200 then
        exit;
     shit(skey, sr);
     if (sr = #0) and (special) and (skey <> cr) and (skey <> bksp)
        and (skey <> esc) then
            exit;
          if sr = #0 then
          begin
              send_message := r;
              write(send_message);
          end
          else
              send_message := sr;
          if send_message = #8 then
          begin
               write(' ');
               write(chr(8));
          end;
          if send_message = #13 then writeln;
          IPXSend(network_number, network_node, receive_socket, @send_message,
              length(send_message)+1, send_ecb,  send_header, send_socket);
          if (send_message = chr(27)) or (receive_message= chr(27)) then
          done := true;
end;


begin
 ini_win;
  open_win(1,1,80,24,black,black);
  init;
  receive;
  x := 0;
  clrscr;
 open_win(1,starty,80,24, lightgray, black);
 open_win(1,17,80,24, black, lightgray);
 info(versie+' 1995 Willem van de Vis   Esc to quit.');
 writeline('F1 buzz F2 bird F3 flash F4 sucker F5 blink F6 trash F10 clear',
               2, starty-1, black, lightgray);

 textcolor(black);
  repeat
    receive;
  IPXRelinquishControl;
  if keypressed then
   send;
 until done;
 IPXCloseSocket(send_socket);
 IPXCloseSocket(receive_socket);
 end_win;
 writeln('no more nagging.');
end.


