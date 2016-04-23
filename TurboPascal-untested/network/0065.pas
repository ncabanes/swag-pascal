
                         How to program IPX on Netware systems
                              Written By Kenneth Johnson
                                     July 29th 1996
                                  Updated Dec 5th 1997

      Table of contents

      Section 0. General Info
      Section 1. Network addresses and socket numbers
      Section 2. Data types and packet format.
      Section 3. The information in Section 2 in Pascal record types.
      Section 4. The routines.
      Section 5. Program flow
      Section 6. Common questions.
      Section 7. Other stuff.
      Section 8. About Kenneth Johnson.
      Section 9. Future works.

      Hello! I wrote this document to give programmers a basic
      understanding of the use of IPX, and what it can do. The
      following information may work well, or may not work at all. If I
      didn't think it would work then I probably wouldn't write this. I
      can't test my IPX stuff because I am currently not on a network.
      But it worked ok when I was in school so I am assuming it works now.
      If you are a fairly good programmer, and understand networks and
      interrupts then you should not have much trouble writing your own
      routines from this text. You should have a good idea of record
      types, and very basic assembly language. I've included the code you need
      for the routines.
           Another thing I should explain is that some data fields have
      (hi-low) beside them. That means that the most
      significant byte should be switched with the least significant
      byte. If the variable X must be switched in this manner it would
      look like this (in pascal): X := swap(X);

      Section 0. General info

      What does IPX stand for?

      IPX stands for (I)nternetwork (P)acket E(x)change Protocol, it is
      used by networks to send and receive information quickly to and
      from the server and other computers.


      Why use IPX and not SPX?

      The reason I have wrote IPX routines and not SPX is that IPX is
      faster. The problem with IPX is that it just sends the packet to
      the destination computer. It may not necessarily get there, and
      if you send multiple packets sequentially, the third packet may
      get there before the first, whereas SPX (S)equenced (P)acket
      E(x)change makes sure that they are delivered in the proper
      order. These problems are easily overcome.


      Section 1. Network addresses.

      ■ What is an address ■

      A network address is comprised of a Network Number, and
      a Node Number within a Network. This is how Netware recognizes
      you on the network.

      The format of a netware address:
      1. Network number (hi-low) : =long integer=
      2. node address   (hi-low) : =array of six bytes=
      3. Socket number  (hi-low) : =word=

      A socket is a "highway" or connection that this
      information should be sent on. You can pick any number for the
      socket, but Netware has some reserved. Also games like DOOM send
      packets via IPX during a net game. DOOM sends on socket number
      $869C. If you really want to ruin a net DOOM game, start sending
      packets on this socket. (And see how unpopular you'll become!)
      Getting your address and others is fairly simple.


      Section 2. Data types and packet format

      ■ Inside IPX ■

      I will now discuss some of the parts of IPX. This is the hardest
      part in understanding IPX. To send information from one computer
      to another, or to all computers that are on the network IPX uses
      PACKETS. Packets are  "pieces" of information.  To send
      a packet, you must set up something called an ECB or (E)vent
      (C)ontrol (B)lock with an IPX header and datagram. This is what
      IPX uses as information to send data. What are all these things?
      Keep reading and I'll explain. The numbers beside each data field
      correspond to the information that follows the format listing.

      ■ Format of IPX header ■

      (1) Checksum (hi-low) : =word=
      (2) Length of packet (hi-low) : =word=
      (3) Transport control : =byte=
      (4) packet type (hi-low) : =byte=
      (5) Destination address : (address record type discussed above)
      (6) The source address  : (address record type discussed above)

      1. Just set this to zero (don't worry about the hi-low stuff)
      2. The length of the packet you are going to send. Just
         Sizeof(IPXHEADER). (the size of the ipx header)
      3. Just set to zero.
      4. The type of packet you are going to send. I just set to zero,
         but different values have different uses. You can also use
         four.
      5. The filled destination address, the computer(s) you want to
         send this packet to. You must also fill in the socket number,
         a value you choose for the socket that you are sending on, and
         the other computer(s) are listening on.
      6. The filled source address (your address) with the socket to
         send on filled.


      ■ Format of ECB ■

      Here's the format for an IPX Event Control Block.

      (1)  Link                             : =long integer=
      (2)  Pointer To Event Service Routine : =long integer=
      (3)  In-Use-Flag                      : =byte=
      (4)  Completion Code                  : =byte=
      (5)  Socket Number (hi-low)           : =word=
      (6)  workspace                        : =four bytes=
      (7)  driver workspace                 : =twelve bytes=
      (8)  Immediate Local Node Address     : =six bytes=
      (9)  Fragment Count                   : =word=
      (10) Data Fragments                   : =array[1..2] of
                                              fragments= (see below)


      ■ Format of a fragment record (Data Fragments) ■

      Format for the fragments of data found in the ECB. This does not
      necessarily have to be an array of two fragments, it could be
      more, but this is what I use and I can guarantee that it works.

      Pointer to Fragment : =pointer=
      Size of fragment    : =word=

      Explanation of the ECB data fields:

      1.When setting up an ECB I don't even bother with the "link".
        I'm not even sure about it's purpose.

      2.You don't have to fill this field either. This is an address
        to the event service routine. When the ECB you have given to
        IPX has been handled, it calls this procedure. You don't really
        need it, but I guess it would make life easier.

      3.The In-Use-Flag is used to determine whether or not IPX has
        gotten around to actually sending the data off to the other
        computer(s). If it has sent the packet then this is set as $0,
        if IPX did not send it, it will be $ff. The in-use-flag could
        have other values which will be discussed later. These two are
        the ones that are important right now.

      4.If the completion code is 0h then IPX delivered the packet
        with no problems, if it is anything else then it did not send
        it.

      5. The socket that you are going to send the packet on.

      6. Just fill with zeros.

      7. Just fill with zeros.

      8. Your local node address. We will be looking at routines that
         get your network address (including node address)

      9. Your fragment count. (In this document, we'll use 2)

      10. You're information that you want IPX to send. It is contained
          in DATAGRAMS. Datagrams is the actual information you want to
          send, whether it's part of a file, for a chatting program, or
          any other type of format.
          A datagram can be maximum 546 bytes long. I assume that the
          minimum would be 1 or 0, but that doesn't really matter. I
          have the datagram as an array of bytes:
          Datagram : array[1..546]  of byte;
          In the fragment pointer of TFRAG, you give it the datagram
          segment and offset and in the Size field you give it the size
          of the datagram, in this case 546 bytes.
          What is interesting about IPX is that instead of giving IPX
          variables to put information in, you give it their addresses,
          and IPX will take care of everything.
          In the Fragment array you must include the IPX header in the
          first fragment. So you copy the stuff in the IPX
          header into the datagram, and then your other info into the
          second datagram and IPX handles it.



      Section 3. The information in Section 2 in Pascal record types.

      Here's what I babbled on about in section two in Pascal
      Record Types. These are the actual things you send IPX so that it
      can work:


      type

      {The datagram record type}

       datagramRec = array[1..546] of Byte;   {where you put the data
                                             you want to send}
      {IPX record type}

       tipxheader = record         {IPX uses this to determine where }
         checksum : word;          {it's going, from who and on}
         Len      : word;          {which socket}
         control  : byte;
         packettype : byte;
         dest,
         source : tinternetworkaddress;
       end;

      {network address record type without socket number}
        networkaddressREC = record
          network : longint;
          nodeaddr : array[1..6] of byte;
        end;

      {network address record type with socket number}
        tinternetworkaddressREC = record {full network address and socket}
          network : longint;
          nodeaddr : array[1..6] of byte;

          socket : word;
        end;

      {the data fragment record type}

        tfrag = record     {where the data pointers goes}
          FragPtr : pointer;
          Size : Word;
        end;

      {Event control block record type}

        Tecb = record {what you send to IPX}
          Link         : pointer;
          ESR          : pointer;
          inuse        : byte;
          code         : byte;
          socketnum    : word;
          ipxworkspace : array[1..4]  of byte;
          driver       : array[1..12] of byte;
          localnode    : array[1..6]  of byte;
          fragcount    : word;
          fragdata     : array[1..2]  of tfrag;{the first TFRAG should have}
        end;                                   {the IPX header}


      Section 4.

      The routines

      Here's all the routines that you will be using to send packets,
      listen for packets, get your address and others.

      ■ essential routines ■
      {------------------------------------------------------------------------}
      {sending a packet: ecbpointer is an ecb record type}
      procedure sendpacket(var ecbpointer);assembler;
        asm
          push bp  {if this isn't saved then the program will crash}
          mov bx,0003h
          les si,ecbpointer
          int $7a
          pop bp
        end;
      {------------------------------------------------------------------------}
      {listen for a packet: ecb is an ecb record type}
      procedure listenforpacket(Var ecb);assembler;
        asm
          push bp
          Push si
          mov bx,$0004
          les si,ecb
          int $7a
          mov [byte ptr result],al
          Pop si
          pop bp
        end;
      {------------------------------------------------------------------------}
      {check to see if IPX is installed}
      function IPXinstalled : Boolean;
      var stat : byte;
        begin
          asm
            mov ax,7a00h
            int $2f
            mov stat,al
          end;
          if stat = $ff then ipxinstalled := true else
          ipxinstalled := false;
        end;
      {------------------------------------------------------------------------}
      {closes an open socket}
      procedure closesocket(socketnum : word);
      var sock : word;
        begin
         sock := swap(Socketnum);
           asm
             mov bx,0001h
             mov dx,sock
             int $7a
           end;
        end;
      {------------------------------------------------------------------------}
      {Opens a socket, (SocketType is the type of socket you want to
      open:
      00h = open until close or terminate
      FFh = open until close}
      procedure opensocket(socketnum : word);
      var i : word;
        begin
          i := swap(socketnum);
            asm
              mov bx,0000h
              mov dx,i
              mov al,sockettype
              int $7a
              mov [byte ptr result],al
            end;
        end;
      {------------------------------------------------------------------------}
      {tells IPX that the program is idle and it can do some work}
      Procedure RelinquishControl;assembler;
        asm
          mov bx,$000a
          int $7a
        end;
      {------------------------------------------------------------------------}

      ■ Other routines ■

      {------------------------------------------------------------------------}
      {some of these routines use this.}
      procedure Callint(Ahreg : byte;Var bufferin,bufferout;
                        Var error : Byte);assembler;
      asm
        push ds
        mov ah,ahreg
        lds si,bufferin
        les di,bufferout
        int 21h
        mov [byte ptr error],al
        pop  ds
      end;
      {------------------------------------------------------------------------}
      procedure getinternetaddress(Connect : byte;
                                   Var net : tinternetworkaddressrec);
      type
        request = record
          len : word;
          sub : byte;
          c: byte;
        end;
        reply = record
          len : word;
          n : tinternetworkaddressREC;
        end;
      var  bufferin  : request;
        bufferout : reply;
        i : byte;
        begin
          fillchar(Bufferout,sizeof(Bufferout),0);
          bufferin.len := 2;
          bufferin.sub := $13;
          bufferin.c := connect;
          bufferout.len := sizeof(Bufferout)-2;

          callint($e3,bufferin,bufferout,error);


          net.networkaddr := bufferout.n.networkaddr;
          for i := 1 to 6 do
          net.nodeaddr[i] := bufferout.n.nodeaddr[i];
          net.socket := bufferout.n.socket;

        end;
      {------------------------------------------------------------------------}
      procedure myaddrASM(var bufferout);assembler;
        asm
          mov bx,0009h
          les si,bufferout
          int $7a
        end;
      {------------------------------------------------------------------------}
      {get your own address}
      Procedure myaddress(Var n : tinternetworkaddressrec);
      type
        reply = record
          net : longint;
          node : array[1..6] of byte;
        end;
      var
        bufferout : reply;
        begin
          fillchar(Bufferout,sizeof(Bufferout),0);
          myaddrasm(Bufferout);
          move(bufferout.node,n.nodeaddr,sizeof(N.nodeaddr));
          n.networkaddr := bufferout.net;
        end;
      {------------------------------------------------------------------------}
      Other routines that you should write are things that set up the ECB for
      sending and receiving packets. I'll show you what you should be
      doing for those routines.



      Section 5.

      Program flow

      In this section I will show you the basic program flow for sending and
      receiving an IPX packet.

      For the socket numbers I just use the same socket for sending/receiving
      data. A better way to do this would be to have one socket for receiving
      and one for sending packets. (that gets a bit complicated)


      SEND PACKET

      The program flow is this:
      variables used:
       ecb : tecb;
       IPX : tipxheader;
       D   : datagram;


      1.  Open socket your going to send on.
      2.  Setup your IPX header. (The fields listed here MUST be filled)
           ==> Get destination address & put it in IPX.dest
               If you want to send a broadcast packet (to all computers)
               then just leave the ipx.dest filled with zeros and the
               ipx.dest.nodeaddr filled with $FF.
           ==> IPX.checksum must equal zero (hi-low)
           ==> IPX.len = Sizeof(ipx) (size of the ipx header) (hi-low)
           ==> IPX.dest.socket equals socket number that destination (hi-low)
               computer is using to receive data. (I think)
           ==> the rest of the IPX header should be all zeros.
               The fields with "hi-low" must have their bytes SWAPED.

      3.   Put whatever data you want to send into the datagram.
           as an example:
           S := 'This is a test!'
           Move(S,D,Sizeof(S));
           Now the datagram (D) contains the string "This is a test!".
           When we set up the ECB and actually send the packet, this is what
           we would be sending.
           You can put ANY type of data in the datagram.


      4.   Setup your Event Control Block (ECB)
           These fields must be filled:
           ==> ecb.socketnum equals socket your sending on (hi-low)
           ==> Fragcount equals the amount of data fragments you have.
               In this document we are using two.
           ==> Fragdata[1].size := sizeof(IPX)
           ==> Fragdata[1].fragptr := @(IPX) (pointer to IPX header)
           N.B The first fragment must always contain the ipx header
               data.
           ==> fragdata[2].size := sizeof(D)
           ==> fragdata[2].fragptr := @(D)
               The second fragment contains the datagram.
               (the stuff your actually sending)


      5.  Send the packet.
          You are now ready to send the packet on it's speedy little voyage
          through the network to reach it's destination computer(s).
          This is just a call to the routine Sendpacket. You give the
          routine the filled ecb and it takes care of the rest.

          SendPakcet(ecb);

          repeat
            relinquishcontrol;
          until ecb.inuse = $00;

          What is that "relinquishcontrol" stuff?
          That's a routine to tell IPX that it can go ahead and send the packet.
          Usually you repeat that routine until the ecb.inuse flag is set to
          zero, which means that the packet was sent. If ECB.code is something
          other than zero then the packet did not send successfully.


      That's how an IPX packet is sent. You should probably write some procedures
      that will set up the IPX header and ECB header by just sending up a
      connection number and the header. In my IPXSETUP procedure, a connection
      number that is zero tells it to set up the header's dest address as a
      broadcast packet. Note that setting up ipx for receiving a packet is a bit
      different. (A lot easier!)


      RECEIVE PACKET (same variables used)

      Basic program flow:

      1.  Fill IPX header with zeros

      2.  Setup ECB.
          ==> ecb.socketnum := swap(listensocket)
          ==> ecb.fragcount = 2
          ==> fragdata[1].size := sizeof(ipx);
              fragdata[1].fragprt := @ipx;
          ==> fragdata[2].size := sizeof(d);
          ==> fragdata[2].fragptr := @d;

      3.  Wait for a packet to arrive.
          Listenforpacket(ecB);
          repeat
            relinquishcontrol;
          until ecb.inuse = 00;

      4.  data is now in Datagram


      Notice in step 3 that the routine "listenforpacket" does not wait for a
      packet to be send. Rather, you call that routine and then repeat
      "relinquishcontrol" until a packet does arrive. When a packet is received
      then IPX puts the packet information into the pointers specified. In this
      case "IPX" and "D". Now you know who send the packet (you have their
      address) and what they sent.


      Section 6.

      Common questions

      Q. Why isn't my program working?

      A. Could be a number of reasons. Step through your program and see exactly
         what you are putting in the IPX header and ECB. (If your using Pascal
         press ctrl-f4) Also, if you are setting up an ECB or header, any fields
         that do not have to be filled with a value should be set to zero.
         Make sure the socket you are sending on is open. (check the error code)

      If you e-mail me with a question then it will probably end up in this
      section.


      Section 7.

      Other stuff

      Here's a list of the inuse flag codes,completion codes and values for
      IPX packet types:

      Values for ECB in-use flag:

      00h available
      E0h AES temporary
      F6h \special IPX/SPX processing for v3.02+
      F7h /
      F8h IPX in critical section
      F9h SPX listening
      FAh processing
      FBh holding
      FCh AES waiting
      FDh AES counting down delay time
      FEh awaiting packet reception
      FFh senfing packet

      Values for ECB completion code:

      00h success
      ECh remote terminated connection without acknowledging packet
      EDh abnormal connection termination
      EEh invalid connection ID
      EFh SPX connection table full
      F9h event should not be canceled
      FAh cannot establish connection with specified destination
      FCh cancelled
      FDh malformed packet
      FEh packet undeliverable
      FFh physical error

      Values for IPX packet type:

      00h     unknown packet type
      01h     routing information packet
      02h     echo packet
      03h     error packet
      04h     packet exchange packet
      05h     SPX packet
      11h     Netware Core Protocol
      14h     Propagated Packet (for Netware), NetBIOS name packet
      15h-1Eh experimental protocols

      Section 8

      About Ken Johnson

      Hello! My name is Ken Johnson and I am a student at Carleton
      University in Ottawa Ont. Canada. Currently I am in my first
      year of a Computer Mathmatics degree.
      You can visit my website at: wabakimi.carleton.ca/~kjohnso3
      or email me at kjohnso3@chat.carleton.ca


      Section 9

      Future works
      Hopefully somemore TCP/IP stuff but I haven't had the time to
      do so. If you are interested in IPX/SPX code for C++ then send
      me some mail.
      
