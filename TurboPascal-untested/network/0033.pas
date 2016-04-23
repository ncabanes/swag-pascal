{
From: greg.miller@shivasys.com

>Could you tell me where to get the ipx units?

I'll post the IPX source here again.  (Perhaps this should go into
the FAQ? :)  There seems to be a big demand for this unit.

{ ipx - IPX communication protocol primitives.          }
unit ipx;

interface uses DOS;

type
     MessageStr          = String;
     IPX_REGS            = Registers;
     Byte4               = array[0..3] of byte;
     NetworkNumber       = Byte4;
     NetworkNode         = array[0..5] of byte;

     ECB                 = record
                            link_address          : Pointer;
                            event_service_routine : Pointer;
                            in_use                : byte;
                            completion_code       : byte;
                            socket_number         : word;
                            ipx_workspace         : Byte4;
                            driver_workspace      : array[0..11] of 
byte;
                            immediate_address     : NetworkNode;
                            fragment_count          : word;
                            fragment                : array [0..1] of 
record
                                                          address : 
pointer;
                                                          length  : 
word;
                                                    end;
                           end;

     IPXHEADER           = record
                            checksum              : word;
                            length                : word;
                            transport_control     : byte;
                            packet_type           : byte;
                            dest_network_number   : NetworkNumber;
                            dest_network_node     : NetworkNode;
                            dest_network_socket   : word;
                            source_network_number : NetworkNumber;
                            source_network_node   : NetworkNode;
                            source_network_socket : word;
                           end;

{ ZeroEcb - store zeros in all ecb fields.
 Pre: e is an ECB.
        Post: e is fully zeroed. }
procedure ZeroEcb( var e : ECB );

{ ZeroHeader - Store zeros in all header fields.
 Pre: h is an IPXHEADER.
        Post: h is fulled zeroed. }
procedure ZeroHeader( var h : IPXHEADER );

{ Get1stConnectionNumber - Return first connection number for user name
 Pre: username is valid Novell user name
        Post: Returns first connection number username is logged on or
         0 if not logged on. }
function Get1stConnectionNumber( username : string ) : word;
 
{ GetInternetAddress - Get the network:node address for a connection.
 Pre: connection_number is valid for a logged on user.
        Post: network_number is valid number of network.
         physical_node is valid station node.             
 }
function GetInternetAddress(    connection_number : byte;
                            var network_number : NetworkNumber; {hi:lo}
                            var physical_node : NetworkNode ) : integer;

{ IPXSPXNotLoaded - Executed when ipxspx called but not loaded.
 Pre: IPX not loaded.
        Post: Execution aborted. }
procedure IPXSPXNotLoaded(var NovRegs : Registers);

{ IPXInstalled - Determine if IPX is installed on workstation.
 Pre: Either IPX is or is not installed.
        Post:   If IPX installed initialize global IPXLocation to IPX 
entry
         point and return TRUE.
                Otherwise initialize global IPXLocation to 
IPXSPXNotLoaded
                entry point and return FALSE.  }
function IPXInstalled : Boolean;

{ IPXSPX - Call ipxspx at address in IPXLocation.
 Pre: IPXInstalled has been called.
         IPX is installed and NovRegs assigned IPX or SPX function
         and parameter values. Not checking is done.
        Post:  IPX or SPX function is called.
         NovRegs assigned by call. }
procedure IPXSPX(var NovRegs:Registers);

{ IPXRelinquishControl - Give ipx momentary control of CPU.
 Pre: IPX loaded.
        Post: IPX execution done. }
procedure IPXRelinquishControl;

{ IPXCancelEvent - Cancels pending event associated with ECB.
            Pre:  e is valid ECB.
                   Post: 00 - Success.
                     F9 - ECB cannot be canceled.
                         FF - ECB not in use. }
function IPXCancelEvent( var e : ECB ) : byte;

{ IPXDisconnectFromTarget - Notify listening node that communications 
woth
       specified socket are being terminated.
 Pre: number:node:socket are valid.
        Post: Node notified.   }
procedure IPXDisconnectFromTarget( network_number : NetWorkNumber;
                                   network_node   : NetWorkNode;
                                   network_socket : word );

{ IPXScheduleEvent - Schedule processing of ECB after timer ticks.
 Pre: ticks is number of 18.2 per second ticks.
                e is a valid ECB at the time processing occurs.
        Post: e is processed after timer ticks. }
procedure IPXScheduleEvent( ticks : word; var e : ECB );

{ IPXOpenSocket - Open an application socket.
 Pre: socket to use (BBA-7FFF). All assumed short-lived.
        Post: 00 - Success.
         FE - Socket table full.
                FF - Socket already open.  }
function IPXOpenSocket( socket : word ) : byte;
 
{ IPXCloseSocket - Close socket. No harm if already closed.
 Pre: socket to close.
        Post: socket is closed. }
procedure IPXCloseSocket( socket : word );

{ IPXListenForPacket - Submit an ECB for use when packet received. Must
                       have ECB available when packet received by IPX.
 Pre: e storage is available when ECB processed by IPX.
         e.socket_number opened.
                e.event_svc-routine valid routine or NULL.
                e.fragment_count normally 2.
                e.fragment[0].address to IPX Header buffer.
                e.fragment[0].length = 30.
                e.fragment[1].address to data area <=546 bytes long.
                e.fragment[1].length = length of data area.
        Post: If socket opened, e is added to pool and return TRUE.
         Otherwise return FALSE.    }
function IPXListenForPacket( var e : ECB ) : Boolean;

{ IPXSendPacket - Send packet using given ECB.
 Pre: e storage is available when ECB processed by IPX.
         e.socket_number opened.
                e.event_svc-routine valid routine or NULL.
                e.immediate_address is address of destination 
workstation.
                e.fragment_count normally 2.
                e.fragment[0].address to IPX Header buffer.
                e.fragment[0].length = 30.
                e.fragment[1].address to data area <=546 bytes long.
                e.fragment[1].length = length of data area.
        Post: e.completion_code of: 00 - Message sent.
            FC - Event canceled.
                                        FD - Bad packet.   }

{ IPXGetLocalTarget - Get the bridge address (or node if not bridged) 
for
        network:node address.
  Pre: dest_network - network number of workstation.
         dest_node    - network node of workstation.
                dest_socket  - network socket of workstation.
        Post: bridge_address is routing information used by 
IPXSendPacket.
         Return 00 - Success.
                       FA - No path to destination. }
function IPXGetLocalTarget( var dest_network   : NetworkNumber;
                            var dest_node      : NetworkNode;
                                dest_socket    : word;
                            var bridge_address : NetworkNode ) : byte;

{ IPXGetIntervalMarker - Return time marker measured in 18.2/sec ticks.
 Pre: None.
        Post: Return time marker. }
function IPXGetIntervalMarker : word;

{ IPXSend -  Send a packet to network:node:socket using send_ecb and
             send_header. send_ecb/send_header should be defined outside of
             IPXSend as both may be in use by ipx after IPXSend completes,
             releasing any local variables.
    Pre: dest_network - network number of destination.
                dest_node    - network node of destination.
                dest_socket  - socket of destination.
                packet_ptr   - pointer to send packet.
  packet_len   - length of send packet
  send_ecb     - ECB to use for sending.
                send_header  - IPXHEADER to use for sending.
                send_socket  - socket to use for sending.
        Post:   If destination reachable, packet is sent. }
procedure IPXSend(  var dest_network   : NetworkNumber;
                    var dest_node      : NetworkNode;
                        dest_socket    : word; { hi:lo }
                        packet_ptr     : Pointer;
                        packet_len     : integer;
                    var send_ecb       : ECB;
                    var send_header    : IPXHEADER;
                     send_socket    : word );

{ IPXReceive - Submit an ECB/header and storage buffer for a received
         message.
    Pre:    receive_ecb    - ECB allocated for recieving.
  receive_header - IPXHEADER allocated for receiving.
                receive_socket - socket to receive on.
 Post: message        - area allocated for received message
            holds data.
                message_size   - size of message area in bytes.  
  }
procedure IPXReceive(  var receive_ecb    : ECB;
                       var receive_header : IPXHEADER;
                           receive_socket : word;
                           message        : Pointer;
                           message_size   : word );
{ IPXReceivedFrame - Returns TRUE if message frame received in ECB.
    Pre:    receive_ecb    - ECB allocated for recieving.
 Post: Returns TRUE if message frame received in ECB.  
}
function IPXReceivedFrame( receive_ecb : ECB ) : Boolean;

   
{_________________________________________________________________________}

implementation
   type
     REQUESTBUFFER       = record
                            dest_network_number   : NetWorkNumber;
                            dest_network_node     : NetworkNode;
                            dest_network_socket   : word;
                           end;
     REPLYBUFFER         = record
                            node_address          : NetworkNode;
                           end;
   var IPXLocation : Pointer;              { Address of ipx }

{ abort - Display message and halt.
   Pre:  message is a string. }
procedure abort( message : string );
begin
     writeln( message );
     Halt(1);
end;

{$F+}
{ Get1stConnectionNumber - Return first connection number for user name
 Pre: username is valid Novell user name
        Post: Returns first connection number username is logged on or
         0 if not logged on. }
function Get1stConnectionNumber( username : string ) : word;
var
  NovRegs          : Registers;
  Request          : record
                       len            : Word;
                       buffer_type    : Byte;
                       object_type    : Word;
                       name           : string[47];
                     end;
  Reply            : record
                       len                : Word;
                       number_connections : byte;
                       connection_num     : array[0..99] of byte;
                     end;
begin
  with Request do begin
    len  := 51;
    buffer_type := $15;
    object_type := $0100;
    name := username;
  end;

  Reply.len := 101;     { Maximum number of user connections }

  with NovRegs do begin
    AH := $E3;
    DS := Seg(Request);  {DS:SI points to request}
    SI := Ofs(Request);
    ES := Seg(Reply);    {ES:DI points to reply}
    DI := Ofs(Reply);
    MsDos(NovRegs);

    if (Al <> 0) or (Reply.number_connections = 0)
       then Get1stConnectionNumber := 0
       else Get1stConnectionNumber := Reply.connection_num[0];
  end;
end;
 
{ GetInternetAddress - Get the network:node address for a connection.
 Pre: connection_number is valid for a logged on user.
        Post: network_number is valid number of network.
         physical_node is valid station node.             
 }
function GetInternetAddress(    connection_number : byte;
                            var network_number : NetworkNumber; {hi:lo}
                            var physical_node : NetworkNode ) : integer;
var
  NovRegs          : Registers;
  Request          : record
                       len               : word;
                       buffer_type       : byte;
                       connection_number : byte;
                     end;
  Reply            : record
                       len            : word;
                       network_number : NetworkNumber;
                       physical_node  : NetworkNode;
                       server_socket  : word;
                     end;
begin
  with Request do begin
    len  := 2;
    buffer_type := $13;
  end;
  Request.connection_number := connection_number;
  Reply.len := 12;
  with NovRegs do begin
    AH := $E3;
    DS := Seg(Request);  {DS:SI points to request}
    SI := Ofs(Request);
    ES := Seg(Reply);    {ES:DI points to reply}
    DI := Ofs(Reply);
    MsDos(NovRegs);
    Ah := 0;
    GetInternetAddress := Ax;
  end;
  network_number := Reply.network_number;
  physical_node := Reply.physical_node;
end;

{ IPXSPXNotLoaded - Executed when ipxspx called but not loaded.
 Pre: IPX not loaded.
        Post: Execution aborted. }
procedure IPXSPXNotLoaded(var NovRegs : Registers);
begin
     abort('IPX not loaded');
end;

 { ZeroEcb - store zeros in all ecb fields.
 Pre: e is an ECB.
        Post: e is fully zeroed. }
procedure ZeroEcb( var e : ECB );
var i : byte;
begin
     with e do begin
          link_address := Ptr(0,0);
          event_service_routine := Ptr(0,0);
          in_use := 0;
          completion_code := 0;
          socket_number   := 0;
          for i := 0 to 3 do
              ipx_workspace[i] := 0;
          for i := 0 to 11 do
              driver_workspace[i] := 0;
          for i := 0 to 5 do
              immediate_address[i] := 0;
          fragment_count := 0;
          for i := 0 to 1 do begin
              fragment[i].address := Ptr(0,0);
              fragment[i].length  := 0;
          end;
     end;
end;

{ ZeroHeader - Store zeros in all header fields.
 Pre: h is an IPXHEADER.
        Post: h is fulled zeroed. }
procedure ZeroHeader( var h : IPXHEADER );
var i : byte;
begin
   with h do begin
     checksum              := 0;
     length                := 0;
     transport_control     := 0;
     packet_type           := 0;
     for i := 0 to 3 do
         dest_network_number[i] := 0;
     for i := 0 to 5 do
         dest_network_node[i] := 0;
     dest_network_socket   := 0;
     for i := 0 to 3 do
         source_network_number[i] := 0;
     for i := 0 to 5 do
         source_network_node[i] := 0;
     source_network_socket := 0;
  end;
end;

 { IPXInstalled - Determine if IPX is installed on workstation.
 Pre: Either IPX is or is not installed.
        Post:   If IPX installed initialize global IPXLocation to IPX 
entry
         point and return TRUE.
                Otherwise initialize global IPXLocation to 
IPXSPXNotLoaded
                entry point and return FALSE.  }
function IPXInstalled : Boolean;
var NovRegs          : IPX_REGS;
begin
  with NovRegs do begin
    AX := $7A00;             {func 7Ah of int 2Fh is used to detect IPX}
    Intr($2F,NovRegs);
    if AL = $FF then begin   {if AL is FFh then IPX is loaded and 
available}
      IPXInstalled := TRUE;
      IPXLocation := Ptr(ES,DI); {pointer to IPX entry point in ES:DI}
    end
    else begin
      IPXInstalled := FALSE; {no IPX installed}
      IPXLocation := @IPXSPXNotLoaded;
    end;
  end;
end;

{ IPXSPX - Call ipxspx at address in IPXLocation.
 Pre: IPXInstalled has been called.
         IPX is installed and NovRegs assigned IPX or SPX 
function
         and parameter values. Not checking is done.
        Post:  IPX or SPX function is called.
         NovRegs assigned by call. }
procedure IPXSPX(var NovRegs:Registers);
var   Ax_, Bx_, Dx_, Di_, Si_, Es_ : word;
begin
     with NovRegs do begin  { Assign simple variables record field 
values }
          Ax_ := Ax;
          Bx_ := Bx;
          Dx_ := Dx;
          Di_ := Di;
          Si_ := Si;
          Es_ := Es;
     end;

     asm                            { Assembler instructions. }
        mov   Ax, Ax_               { Initialize CPU registers.}
        mov   Bx, Bx_
        mov   Dx, Dx_
        mov   Di, Di_
        mov   Si, Si_
        mov   Es, Es_

        push  Bp
        call  dword ptr IPXLocation { Call IPX via address at 
IPXLocation. }
        pop   Bp
        mov   Ax_, Ax
        mov   Dx_, Dx
     end;

     NovRegs.Ax := Ax_;             { Return register values to caller }
     NovRegs.Dx := Dx_;
end;
 
{ IPXRelinquishControl - Give ipx momentary control of CPU.
 Pre: IPX loaded.
        Post: IPX execution done. }
procedure IPXRelinquishControl;
var NovRegs : IPX_REGS;
begin
     with NovRegs do begin
          Bx := $0a;
          IPXSPX(NovRegs);
     end
end;

{ IPXCancelEvent - Cancels pending event associated with ECB.
            Pre:  e is valid ECB.
                   Post: 00 - Success.
                     F9 - ECB cannot be canceled.
                         FF - ECB not in use. }
function IPXCancelEvent( var e : ECB ) : byte;
var NovRegs : IPX_REGS;
begin
     with NovRegs do begin
          Bx := $06;
          ES := Seg(e);    {ES:SI points to ecb}
          SI := Ofs(e);
          IPXSPX(NovRegs);
          IPXCancelEvent := AL;
     end
end;

{ IPXDisconnectFromTarget - Notify listening node that communications 
woth
       specified socket are being terminated.
 Pre: number:node:socket are valid.
        Post: Node notified.   }
procedure IPXDisconnectFromTarget( network_number : NetWorkNumber;
                                   network_node   : NetWorkNode;
                                   network_socket : word );
var NovRegs : IPX_REGS;
    request_buffer : REQUESTBUFFER;
begin
     with request_buffer do begin
          dest_network_number := network_number;
          dest_network_node   := network_node;
   dest_network_socket := network_socket;
     end;

     with NovRegs do begin
          Bx := $0B;
          ES := Seg(request_buffer);    {ES:SI points to ecb}
          SI := Ofs(request_buffer);
          IPXSPX(NovRegs);
     end
end;
 
{ IPXScheduleEvent - Schedule processing of ECB after timer ticks.
 Pre: ticks is number of 18.2 per second ticks.
                e is a valid ECB at the time processing occurs.
        Post: e is processed after timer ticks. }
procedure IPXScheduleEvent( ticks : word; var e : ECB );
var NovRegs : IPX_REGS;
begin
     with NovRegs do begin
          Bx := $05;
          Ax := ticks;
          ES := Seg(e);
          SI := Ofs(e);
          IPXSPX(NovRegs);
     end;
end;

{ IPXOpenSocket - Open an application socket.
 Pre: socket to use (BBA-7FFF). All assumed short-lived.
        Post: 00 - Success.
         FE - Socket table full.
                FF - Socket already open.  }
function IPXOpenSocket( socket : word ) : byte;
var NovRegs : IPX_REGS;
begin
     with NovRegs do begin
          Dx := socket;
          Bx := 0;
          Al := 0;
          IPXSPX(NovRegs);
          Ah := 0;
          IPXOpenSocket := Ax;
     end
end;

{ IPXCloseSocket - Close socket. No harm if already closed.
 Pre: socket to close.
        Post: socket is closed. }
procedure IPXCloseSocket( socket : word );
var NovRegs : IPX_REGS;
begin
     with NovRegs do begin
          Dx := socket;
          Bx := $0001;
          IPXSPX(NovRegs);
     end
end;

 { IPXListenForPacket - Submit an ECB for use when packet received. Must
                       have ECB available when packet received by IPX.
 Pre: e storage is available when ECB processed by IPX.
          e.socket_number opened.
                e.event_svc-routine valid routine or NULL.
                e.fragment_count normally 2.
                e.fragment[0].address to IPX Header buffer.
                e.fragment[0].length = 30.
                e.fragment[1].address to data area <=546 bytes long.
                e.fragment[1].length = length of data area.
        Post: If socket opened, e is added to pool and return TRUE.
         Otherwise return FALSE.    }
function IPXListenForPacket( var e : ECB ) : Boolean;
var NovRegs : IPX_REGS;
begin
     with NovRegs do begin
          BX := $0004;
          ES := Seg(e);    {ES:SI points to ecb}
          SI := Ofs(e);
          IPXSPX(NovRegs);
          IPXListenForPacket := Al = 00;
     end
end;

{ IPXSendPacket - Send packet using given ECB.
 Pre: e storage is available when ECB processed by IPX.
         e.socket_number opened.
                e.event_svc-routine valid routine or NULL.
                e.immediate_address is address of destination 
workstation.
                e.fragment_count normally 2.
                e.fragment[0].address to IPX Header buffer.
                e.fragment[0].length = 30.
                e.fragment[1].address to data area <=546 bytes long.
                e.fragment[1].length = length of data area.
        Post: e.completion_code of: 00 - Message sent.
            FC - Event canceled.
                                        FD - Bad packet.   }
procedure IPXSendPacket( var e: ECB );
var NovRegs : IPX_REGS;
begin
     with NovRegs do begin
          ES := Seg(e);    {ES:SI points to ecb}
          SI := Ofs(e);
          BX := $0003;
          IPXSPX(NovRegs);
     end
end;

 { IPXGetLocalTarget - Get the bridge address (or node if not bridged) 
for
        network:node address.
  Pre: dest_network - network number of workstation.
         dest_node    - network node of workstation.
                dest_socket  - network socket of workstation.
        Post: bridge_address is routing information used by 
IPXSendPacket.
         Return 00 - Success.
                       FA - No path to destination. }
function IPXGetLocalTarget( var dest_network   : NetworkNumber;
                            var dest_node      : NetworkNode;
                                dest_socket    : word;
                            var bridge_address : NetworkNode ) : byte;
var
  NovRegs          : Registers;
  Request          : record
                       network_number    : NetworkNumber;
                       physical_node     : NetworkNode;
                       socket            : word;
                     end;
  Reply            : record
                       local_target      : NetworkNode;
                     end;
begin
     with Request do begin
          network_number := dest_network;
          physical_node := dest_node;
          socket := dest_socket;
     end;
     with NovRegs do begin
          Es := Seg(Request);
          Si := Ofs(Request);
          Di := Ofs(Reply);
          Bx := $0002;
          IPXSPX(NovRegs);
          Ah := 0;
          IPXGetLocalTarget := Ax;
          bridge_address := Reply.local_target;
     end
end;

{ IPXGetIntervalMarker - Return time marker measured in 18.2/sec ticks.
 Pre: None.
        Post: Return time marker. }
function IPXGetIntervalMarker : word;
var
  NovRegs          : Registers;
begin

     with NovRegs do begin
          Bx := $0008;
          IPXSPX(NovRegs);
          IPXGetIntervalMarker := Ax;
     end
end;

 { IPXSend - Send a packet to network:node:socket using send_ecb and
             send_header. send_ecb/send_header should be defined outside 
of
             IPXSend as both may be in use by ipx after IPXSend 
completes,
             releasing any local variables.
    Pre: dest_network - network number of destination.
                dest_node    - network node of destination.
                dest_socket  - socket of destination.
                packet_ptr   - pointer to send packet.
  packet_len   - length of send packet
  send_ecb     - ECB to use for sending.
                send_header  - IPXHEADER to use for sending.
                send_socket  - socket to use for sending.
        Post:   If destination reachable, packet is sent. }
procedure IPXSend(  var dest_network   : NetworkNumber;
                    var dest_node      : NetworkNode;
                        dest_socket    : word; { hi:lo }
                        packet_ptr     : Pointer;
                        packet_len     : integer;
                    var send_ecb       : ECB;
                    var send_header    : IPXHEADER;
                     send_socket    : word );
begin
     ZeroEcb(send_ecb);
     ZeroHeader(send_header);
     send_ecb.socket_number := send_socket;  { Socket used for sending }
     if IPXGetLocalTarget( dest_network,
           dest_node,
                           dest_socket,
                           send_ecb.immediate_address ) = 0
        then begin
             with send_ecb do begin
                  fragment_count := 2;
                  fragment[0].address := @send_header;
                  fragment[0].length  := sizeof(IPXHEADER);
                  fragment[1].address := packet_ptr;
                  fragment[1].length  := packet_len;
             end;
             with send_header do begin
                  packet_type         := 4;
                  dest_network_number := dest_network;
                  dest_network_node   := dest_node;
                  dest_network_socket := dest_socket;
             end;
             IPXSendPacket( send_ecb );
        end;
end;

 { IPXReceive - Submit an ECB/header and storage buffer for a received
         message.
    Pre:    receive_ecb    - ECB allocated for recieving.
  receive_header - IPXHEADER allocated for receiving.
                receive_socket - socket to receive on.
 Post: message        - area allocated for received message
            holds data.
                message_size   - size of message area in bytes.  
  }
procedure IPXReceive(  var receive_ecb    : ECB;
                       var receive_header : IPXHEADER;
                           receive_socket : word;
                           message        : Pointer;
                           message_size   : word );
begin
   ZeroEcb(receive_ecb);
   ZeroHeader(receive_header);
   with receive_ecb do begin
        socket_number := receive_socket; { Socket used for receiving }
        fragment_count := 2;
        fragment[0].address := @receive_header;
        fragment[0].length  := sizeof(IPXHEADER);
        fragment[1].address := message;
        fragment[1].length  := message_size;
   end;
    if not IPXListenForPacket( receive_ecb ) then
     abort('IPX Error - Failure initializing.');
   IPXRelinquishControl;              { Give ipx opportunity to process 
}
end;

{ IPXReceivedFrame - Returns TRUE if message frame received in ECB.
    Pre:    receive_ecb    - ECB allocated for recieving.
 Post: Returns TRUE if message frame received in ECB.  
}
function IPXReceivedFrame( receive_ecb : ECB ) : Boolean;
begin
 IPXReceivedFrame := (receive_ecb.completion_code = 0) and
                            (receive_ecb.in_use = 0);

end;

begin
end.
