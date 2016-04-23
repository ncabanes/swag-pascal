{
     A while back I posted a unit which allows one to interrface Pascal
programs to IPX.  Since I've had several people ask about how to use it,
I'll post this short example program now.  It should be enough to get
anyone started on sending packets.
     NOTE:  You must already have the IPX.PAS unit posted earlier in
this conference in order to use this program.  Also, this program uses
two NetWare functions to get the address of the remote user, so both
users must be logged in on the same server (but don't have to be on the
same network) to get the program to work.  The title of the program is
TALK.PAS.  In order to run the program you type TALK <username> from the
command line.

From: greg.miller@shivasys.com

 This program sends packets between two users logged in
 to the same server.  This program is meant to be an example
 of how to send IPX packets over an IPX network and is not
 meant to be an actual utility.
}
program send;
uses crt,ipx;

const
 receive_socket = $7777; {Arbitrary socket numbers are chosen}
 send_socket = $6666;

procedure abort(message:string);
begin
 writeln(message);
 halt(1);
end;

var
 connection_number:word;
 network_number:networkNumber;
 network_node:networkNode;
 receive_ecb,send_ecb:ECB;
 receive_header,send_header:IPXHeader;
 receive_message,send_message:MessageSTR;
 done,stop : boolean;

 begin
  {Make sure IPX is installed, otherwise don't continue}
  if not IPXinstalled then abort('IPX not loaded');

  {Get the username from the command line, and use it to get the users
   connection number}
  connection_number := Get1stConnectionNumber(paramstr(1));
  {0 is returned, if the user isn't logged in}
  if connection_number = 0 then abort(paramstr(1) + ' not found. ');

  {Use the connection number obtained from above to get the users 
address}
  if GetINternetAddress(connection_number,network_number,network_node) 
<> 0
      then abort(paramstr(1) + 'network error.');

  {Initialize IPX sockets for communication}
  IpxCloseSocket(send_socket);
  if IPXOpenSocket(send_socket) <> 0 then abort('Socket error.');
  IPXCloseSocket(receive_socket);
  if IPXOpenSocket(receive_socket) <> 0 then abort('Socket error.');

{The chat program}
stop := false;
writeln('Attempting to enter chat (^ to stop)');
while (receive_message <> 'ack') and (not stop) do
 begin
  if keypressed then
   if readkey = '^' then stop := true;
  send_message := 'ack';
  IPXSend(network_number,
          network_node,
          receive_socket,
          @send_message,
          length(send_message)+1,
          send_ecb,
          send_header,
          send_socket);

  IPXReceive(receive_ecb, receive_header, receive_socket,
             @receive_message, sizeof(receive_message));
 end;

if stop = true then
 else
  begin
  writeln('Entering Chat mode: type ^ to exit');
  done := false;
  repeat
   if (receive_ecb.completion_code = 0) and (receive_ecb.in_use = 0)
        then
         begin
          textcolor(lightgreen);
          write(receive_message);
          if receive_message=chr(13) then writeln;
          IPXReceive(receive_ecb, receive_header, receive_socket,
          @receive_message, sizeof(receive_message));
         end;

   IPXRelinquishControl; {This line allows IPX to do computation}
   if KeyPressed
    then
     begin
      send_message := '';
      send_message := ReadKey;
      textcolor(yellow);
      write(send_message);
      if send_message=chr(13) then writeln;
      IPXSend(network_number,
              network_node,
              receive_socket,
              @send_message,
              length(send_message)+1,
              send_ecb,
              send_header,
              send_socket);
     end;
   if (send_message = '^') or (receive_message= '^') then
    begin
     writeln('Exiting Chat mode');
     done := true;
     IPXCloseSocket(send_socket);
     IPXCloseSocket(receive_socket);
    end;
  until done;
 end;
 end.

