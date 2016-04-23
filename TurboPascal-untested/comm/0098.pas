UNIT PKTDRVR;
{
╔════════════════════════════════╤═════════════════════════════════════╗
║ Filename       : PKTDRVR.PAS   │  Program / Unit : [U]               ║
║ Description    : Turbo Pascal  └─────────────────────────────────────╢
║                  Object to interface with Crynrware packet drivers.  ║
║                                                                      ║
╟──────────────────────────────────────────────────────────────────────╢
║ Compiler       : Turbo Pascal 7.0                                    ║
║ OS-Version     : MS-DOS 6.0                                          ║
║ Last edit      : 08-Oct-93                                           ║
║ Version        : 1.0                                                 ║
╟──────────────────────────────────────────────────────────────────────╢
║ Author         : Oliver Rehmann                                      ║
║ Copyright      : (C) 1993 Oliver Rehmann                             ║
║                                                                      ║
║ Released to public domain.                                           ║
║ The author can not be held responsible for any damages resulting     ║
║ from the use of this software.                                       ║
╚══════════════════════════════════════════════════════════════════════╝
}

INTERFACE

USES
  DOS,OBJECTS;

CONST
  { Packet driver interface classes }
  CL_NONE           = 0;
  CL_ETHERNET     = 1;
  CL_PRONET_10    = 2;
  CL_IEEE8025       = 3;
  CL_OMNINET        = 4;
  CL_APPLETALK    = 5;
  CL_SERIAL_LINE    = 6;
  CL_STARLAN        = 7;
  CL_ARCNET       = 8;
  CL_AX25             = 9;
  CL_KISS             = 10;
  CL_IEEE8023       = 11;
  CL_FDDI         = 12;
  CL_INTERNET_X25 = 13;
  CL_LANSTAR        = 14;
  CL_SLFP         = 15;
  CL_NETROM       = 16;
  NCLASS              = 17;

  { Packet driver interface types (not a complete list) }
  TC500             = 1;
  PC2000              = 10;
  WD8003              = 14;
  PC8250              = 15;
  ANYTYPE             = $ffff;

  { Packet driver function call numbers. From Appendix B. }
  DRIVER_INFO         = 1;
  ACCESS_TYPE         = 2;
  RELEASE_TYPE      = 3;
  SEND_PKT          = 4;
  TERMINATE         = 5;
  GET_ADDRESS         = 6;
  RESET_INTERFACE   = 7;
  GET_PARAMETERS    = 10;
  AS_SEND_PKT         = 11;
  SET_RCV_MODE      = 20;
  GET_RCV_MODE      = 21;
  SET_MULTICAST_LIST    = 22;
  GET_MULTICAST_LIST    = 23;
  GET_STATISTICS          = 24;
  SET_ADDRESS             = 25;

  { Packet driver error return codes. From Appendix C. }
  NO_ERROR        = 0;
  BAD_HANDLE        = 1;    { invalid handle number }
  NO_CLASS        = 2;  { no interfaces of specified class found }
  NO_TYPE             = 3;  { no interfaces of specified type found }
  NO_NUMBER       = 4;  { no interfaces of specified number found }
  BAD_TYPE        = 5;  { bad packet type specified }
  NO_MULTICAST    = 6;  { this interface does not support multicast }
  CANT_TERMINATE    = 7;    { this packet driver cannot terminate }
  BAD_MODE        = 8;  { an invalid receiver mode was specified }
  NO_SPACE        = 9;  { operation failed because of insufficient space }
  TYPE_INUSE        = 10;   { the type had previously been accessed, and not
released } BAD_COMMAND       = 11;   { the command was out of range, or not 
implemented } CANT_SEND       = 12; { the packet couldn't be sent (usually 
hardware error) } CANT_SET        = 13; { hardware address couldn't be changed
(> 1 handle open) } BAD_ADDRESS       = 14;   { hardware address has bad
length or format } CANT_RESET        = 15;   { couldn't reset interface (> 1
handle open) }

  CARRY_FLAG        = 1;

CONST
  Pkt_Sig  : String[08] = 'PKT DRVR';
  ParamLen : Byte       = 14;

TYPE
  TPKTSTATUS  = (NO_PKTDRVR,INITIALIZED,NOT_INITIALIZED);
  TACCESSTYPE = RECORD
      if_class      : Byte;    { Interface class  }
        if_type       : Word;    { Interface Type   }
        if_number     : Byte;    { Interface number }
        type_         : Pointer;
        typelen       : Word;    { length of type_, set to 0 if
                                   you want to receive all pkts }
        receiver      : Pointer; { receive handler }
    END;

  TPKTPARAMS   = RECORD
      major_rev     : Byte; { Major revision ID of packet specs }
        minor_rev     : Byte; { Minor revision ID of packet specs }
        length        : Byte; { Length of structure in Bytes      }
        addr_len      : Byte; { Length of a MAC address           }
        mtu           : Word; { MTU, including MAC headers        }
        multicast_aval: Word; { buffer size for multicast addr.   }
        rcv_bufs      : Word; { (# of back-to-back MTU rcvs) - 1  }
        xmt_bufs      : Word; { (# of successive xmits) - 1       }
        int_num       : Word; { Interrupt # to hook for post-EOI
                                      processing, 0 == none }
  END;

  TDRVRINFO    = RECORD
      Version       : Word; { Packet driver version   }
        Class         : Byte; { Driver class  }
        Type_         : Word; { Driver type   }
        Number        : Byte; { Driver number }
        pName         : Pointer;
        Functionality : Byte; { How good is this driver }
    END;

  TSTATISTICS = RECORD
      packets_in    : LongInt;
        packets_out   : LongInt;
        bytes_in      : LongInt;
        bytes_out     : LongInt;
        errors_in     : LongInt;
        errors_out    : LongInt;
        packets_lost  : LongInt;
    END;

  TPKTDRVR = OBJECT(TOBJECT)
    private
        pktInt         : Integer;
        pktHandle      : Integer;
        pktRecvHandler : Pointer;
        pktStatus      : TPKTSTATUS;
        pktError       : Byte;
        pktRegs        : Registers;

        pktAccessInfo  : TACCESSTYPE;

        PROCEDURE   TestForPktDriver;

    public
        CONSTRUCTOR Init(IntNo : Integer);
        DESTRUCTOR  Done; VIRTUAL;

        PROCEDURE   ScanForPktDriver;

        FUNCTION    GetStatus                          : TPKTSTATUS;
        FUNCTION    GetError                           : Byte;
        FUNCTION    GetHandle                          : Word;

        PROCEDURE   GetAccessType   (VAR pktAccessType : TACCESSTYPE);
        PROCEDURE   DriverInfo      (VAR pktInfo       : TDRVRINFO  );

        PROCEDURE   AccessType      (VAR pktAccessType : TACCESSTYPE);
        PROCEDURE   ReleaseType;
        PROCEDURE   TerminateDriver;

        PROCEDURE   GetAddress      (Buffer : Pointer;BufLen : Word; VAR
BufCopied : Word); PROCEDURE ResetInterface; PROCEDURE   GetParameters   (VAR
pktParams : TPKTPARAMS);

        PROCEDURE   SendPkt         (Buffer : Pointer;BufLen : Word );
        PROCEDURE   As_SendPkt      (Buffer : Pointer;BufLen : Word;Upcall :
Pointer     );

        PROCEDURE   SetRCVmode      (Mode   : Word);
        FUNCTION    GetRCVmode              : Word;

        PROCEDURE   SetMulticastList(VAR mcList : Pointer; VAR mcLen : Word);
        PROCEDURE   GetMulticastList(VAR mcList : Pointer; VAR mcLen : Word);

        PROCEDURE   GetStatistics   (VAR pktStatistics : TSTATISTICS       );
        PROCEDURE   SetAddress      (Address : Pointer; VAR AddrLen  : Word);
  END;


IMPLEMENTATION
CONSTRUCTOR TPKTDRVR.Init(IntNo : Integer);
BEGIN
  Inherited Init;

  pktInt    := IntNo;
  pktStatus := NOT_INITIALIZED;
  FillChar(pktAccessInfo,SizeOf(pktAccessInfo),#00);

  TestForPktDriver;
END;


DESTRUCTOR TPKTDRVR.Done;
BEGIN
  { Release allocated handle }
  IF (pktStatus = INITIALIZED) THEN
  BEGIN
    ReleaseType;
  END;

  Inherited Done;
END;


FUNCTION TPKTDRVR.GetStatus : TPKTSTATUS;
BEGIN
  GetStatus := pktStatus;
END;

PROCEDURE TPKTDRVR.GetAccessType(VAR pktAccessType : TACCESSTYPE);
BEGIN
  pktAccessType := pktAccessInfo;
END;

PROCEDURE TPKTDRVR.TestForPktDriver;
(* Tests if the assigned interrupt points to a valid packet driver. *)
VAR tPointer  : Pointer;
    Signature : String[08];
    I         : Integer;
BEGIN
  Signature := '';
  GetIntVec(pktInt,tPointer);
  FOR I := 3 TO 10 DO
  BEGIN
    Signature := Signature + Chr(Mem[Seg(tPointer^):Ofs(tPointer^)+I]);
  END;
  IF (POS(Pkt_Sig,Signature) = 0) THEN
    pktStatus := NO_PKTDRVR
  ELSE
    pktStatus := INITIALIZED;
END;

PROCEDURE TPKTDRVR.ScanForPktDriver;
(* Scans interrupts ($60-$7F) for a packet driver. *)
(* Stops if it has found a valid driver.           *)
VAR I : Integer;
BEGIN
  I := $60; { Lower range of possible pktdrvr interrupt }
  REPEAT
    pktInt := I;
    TestForPktDriver;
    Inc(I);
  UNTIL (I = $80) OR (pktStatus = INITIALIZED);
END;

PROCEDURE TPKTDRVR.DriverInfo(VAR pktInfo : TDRVRINFO);
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := DRIVER_INFO;
    AL := $FF;
    BX := pktHandle;
    Intr(pktInt,pktRegs); { Call Packet Driver }
    IF (pktRegs.Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
    BEGIN
      pktError := 0;
      IF (pktError = NO_ERROR) THEN
      BEGIN
    pktInfo.Version       := BX;
    pktInfo.Class         := CH;
    pktInfo.Type_         := DX;
    pktInfo.Number        := CL;
    pktInfo.pName         := Ptr(DS,SI);
    pktInfo.Functionality := AL;
      END;
    END;
  END;
END;

PROCEDURE TPKTDRVR.AccessType(VAR pktAccessType : TACCESSTYPE);
(* Accesses the packet driver.  *)
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := ACCESS_TYPE;
    AL := pktAccessType.if_class;
    BX := pktAccessType.if_type;
    CX := pktAccessType.typelen;
    DL := pktAccessType.if_number;
    DS := Seg(pktAccessType.type_^);
    SI := Ofs(pktAccessType.type_^);
    ES := Seg(pktAccessType.receiver^);
    DI := Ofs(pktAccessType.receiver^);
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError      := DH
    ELSE
    BEGIN
      pktError      := 0;
      pktHandle     := AX;
      pktAccessInfo := pktAccessType;
    END;
  END;
END;

PROCEDURE TPKTDRVR.ReleaseType;
(* Releases a specific type handle *)
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := RELEASE_TYPE;
    BX := pktHandle;
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
      pktError := 0;
  END;
END;

PROCEDURE TPKTDRVR.SendPkt(Buffer : Pointer;BufLen : Word);
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := SEND_PKT;
    CX := BufLen;
    DS := Seg(Buffer^);
    ES := DS;
    SI := Ofs(Buffer^);
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
      pktError := 0;
  END;
END;

PROCEDURE   TPKTDRVR.TerminateDriver;
(* Terminates the Driver associated with pktHandle *)
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := TERMINATE;
    BX := pktHandle;
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
      pktError := 0;
  END;
END;

PROCEDURE TPKTDRVR.GetAddress (Buffer : Pointer;BufLen : Word; VAR BufCopied :
Word);
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := GET_ADDRESS;
    BX := pktHandle;
    CX := BufLen;
    ES := Seg(Buffer^);
    DI := Ofs(Buffer^);
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError  := DH
    ELSE
    BEGIN
      pktError  := 0;
      BufCopied := CX;
    END;
  END;
END;

PROCEDURE TPKTDRVR.ResetInterface;
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := RESET_INTERFACE;
    BX := pktHandle;
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
      pktError := 0;
  END;
END;

PROCEDURE TPKTDRVR.GetParameters(VAR pktParams : TPKTPARAMS);
(* Description   : │ Gets specific parameters from the driver. *)
(* Not all drivers support this function.                      *)
VAR b : Byte;
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := GET_PARAMETERS;
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
    BEGIN
      pktError := 0;
      FOR b := 0 TO ParamLen-1 DO  { Copy contents of structure }
    Mem[Seg(pktParams):Ofs(PktParams)+b] := Mem[ES:DI+b];
    END;
  END;
END;


PROCEDURE TPKTDRVR.As_SendPkt(Buffer : Pointer;BufLen : Word;Upcall :
Pointer);
(* Sends a data packet by accessing the packet driver.  *)
(* Upcall is called when order was placed.              *)
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := AS_SEND_PKT;
    CX := BufLen;
    DS := Seg(Buffer);
    SI := Ofs(Buffer);
    ES := Seg(Upcall^);
    DI := Ofs(Upcall^);
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
      pktError := 0;
  END;
END;

PROCEDURE TPKTDRVR.SetRCVmode(Mode : Word);

BEGIN
  WITH pktRegs DO
  BEGIN
    AH := SET_RCV_MODE;
    BX := pktHandle;
    CX := Mode;
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
      pktError := 0;
  END;
END;

FUNCTION TPKTDRVR.GetRCVmode : Word;
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := GET_RCV_MODE;
    BX := pktHandle;
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError   := DH
    ELSE
    BEGIN
      pktError   := 0;
      GetRCVmode := AX;
    END;
  END;
END;

PROCEDURE TPKTDRVR.SetMulticastList(VAR mcList : Pointer; VAR mcLen : Word);
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := SET_MULTICAST_LIST;
    CX := mcLen;
    ES := Seg(mcList^);
    DI := Ofs(mcList^);
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
      pktError := 0;
  END;
END;

PROCEDURE TPKTDRVR.GetMulticastList(VAR mcList : Pointer; VAR mcLen : Word);
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := GET_MULTICAST_LIST;
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
    BEGIN
      pktError := 0;
      mcList   := Ptr(ES,DI);
      mcLen    := CX;
    END;
  END;
END;

PROCEDURE TPKTDRVR.GetStatistics(VAR pktStatistics : TSTATISTICS);
VAR b : Byte;
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := GET_STATISTICS;
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
    BEGIN
      pktError := 0;
      FOR b := 0 TO SizeOf(TSTATISTICS)-1 DO  { Copy contents of structure }
    Mem[Seg(pktStatistics):Ofs(pktStatistics)+b] := Mem[DS:SI+b];
    END;
  END;
END;

PROCEDURE TPKTDRVR.SetAddress(Address : Pointer; VAR AddrLen : Word);
BEGIN
  WITH pktRegs DO
  BEGIN
    AH := SET_ADDRESS;
    CX := AddrLen;
    ES := Seg(Address^);
    DI := Ofs(Address^);
    Intr(pktInt,pktRegs);
    IF (Flags AND Carry_Flag) = Carry_Flag THEN
      pktError := DH
    ELSE
    BEGIN
      pktError := 0;
      AddrLen  := CX;
    END;
  END;
END;

FUNCTION TPKTDRVR.GetError  : Byte;
BEGIN
  GetError := pktError;
END;

FUNCTION TPKTDRVR.GetHandle : Word;
BEGIN
  GetHandle := pktHandle;
END;

BEGIN
END.
{end}
