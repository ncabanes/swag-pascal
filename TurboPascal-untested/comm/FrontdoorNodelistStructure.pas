(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0063.PAS
  Description: FrontDoor Nodelist Structure
  Author: FRANCOIS THUNUS
  Date: 11-26-94  05:05
*)

{
>  Although I dont have it anymore, there IS a frontdoor
> developer's kit floating around here somewhere..

See my previous intervention about the dev kit used by JoHo. But here is some
more:I checked with the latest public version of the development
kit (fddev220) and found
}
(*
**  nodelist.inc
**
**  Structure for the FrontDoor Nodelist Database
**
**  Copyright 1993 Joaquim Homrighausen; All rights reserved.
**
**  Last revised: 93-06-28                    FrontDoor 2.11+
**
**  -------------------------------------------------------------------------
**  This information is not necessarily final and is subject to change at any
**  given time without further notice
**  -------------------------------------------------------------------------
*)

(*
**  The FrontDoor Nodelist Database (FDND) uses a Pascal product from
**  Borland that has, unfortunately, been discontinued. It is called
**  "Turbo Database Toolkit" and works in a similar fashion to that of
**  many B+ filer toolkits.
**
**  This header file does not make an attempt to document the B+ file
**  structures, but only those fixed structures used by FrontDoor. For
**  owners of the Borland toolkit, the "TACCESS parameters" are listed
**  below.
**
**    NodeRecSize       = 178
**    FileHeaderSize    = 14
**    MinDataRecSize    = 14
**    MaxHeight         = 5
**    MaxDataRecSize    = 178
**    MaxKeyLen         = 24
**    PageSize          = 32
**    Order             = 16
**    PageStackSize     = 5
**    ItemOverhead      = 9
**    PageOverhead      = 5
*)

(*
**  NODEFILE.FDX contains some information about the Nodelist Database.
**
**  The information starts at offset 0x100 and is as follows:
**
**    Current nodelist extension          4 chars         (Pascal)
**    Nodelist Database revision         16 bit
**    Swedish pulse dial translation      1 byte
**
**  At offset 0x110, a set of the currently compiled zones is listed.
*)

(*
**  The private Nodelist Database (FDNODE.FDA) has the following record
**  format.
*)

  { Status }

CONST
  ISZC        =1;
  ISRC        =2;
  ISNC        =3;
  ISHUB       =4;
  ISPVT       =5;
  ISHOLD      =6;
  ISDOWN      =7;
  ISPOINT     =9;

  { Capability flags }

  CMflag      =$00000002;
  MOflag      =$00000004;
  HSTflag     =$00000008;
  H96flag     =$00000010;
  PEPflag     =$00000020;
  MAXflag     =$00000040;
  XXflag      =$00000080;
  XBflag      =$00000100;
  XRflag      =$00000200;
  XPflag      =$00000400;
  XWflag      =$00000800;
  MNPflag     =$00001000;
  HST14flag   =$00002000;
  V32flag     =$00004000;
  V33flag     =$00008000;
  V34flag     =$00010000;
  V42flag     =$00020000;
  XCflag      =$00040000;
  XAflag      =$00080000;
  V42bflag    =$00100000;
  V32bflag    =$00200000;
  HST16flag   =$00400000;
  LOflag      =$00800000;
  ZYXflag     =$01000000;
  UISDNAflag  =$02000000;
  UISDNBflag  =$04000000;
  UISDNCflag  =$08000000;
  FAXflag     =$10000000;

  { MaxBaud field }

  ISBAUD300   =2;
  ISBAUD1200  =4;
  ISBAUD2400  =5;
  ISBAUD4800  =6;
  ISBAUD7200  =10;
  ISBAUD9600  =7;
  ISBAUD12000 =11;
  ISBAUD14400 =12;
  ISBAUD16800 =13;
  ISBAUD19200 =14;
  ISBAUD38400 =15;
  ISBAUD57600 =16;
  ISBAUD64000 =17;
  ISBAUD76800 =18;
  ISBAUD115200=19;

  { Record structure }

  { Note that while the private database can only hold a fixed amount of
    information about a system's capabilities (nodelist flags), FrontDoor
    is capable of using the actual string present in FidoNet-style node-
    lists for routing and other lookup purposes. }

TYPE
  NODEREC = RECORD
    Erased            : LONGINT;                {Used to signal erased status}
    Status            : BYTE;                          {Zone, host, hub, etc.}
    NodeNo,                                                  {Network address}
    NetNo,
    Zone,
    Point,
    RoutNode,                                    {Default routing within zone}
    RoutNet,
    Cost              : WORD;                     {Cost per minute for system}
    Capability        : LONGINT;                            {Capability flags}
    MaxBaud           : BYTE;                              {Maximum baud rate}
    Name              : STRING[30];                           {Name of system}
    Telephone         : STRING[40];                     {Raw telephone number}
    Location          : STRING[40];                       {Location of system}
    User              : STRING[36];                               {SysOp name}
    SelectTag         : STRING[3];                               {Group field}
  END;{NODEREC}

(*
**  The telephone number database (FDPHONE.FDA) has the following record
**  format.
*)
  PHONEREC = RECORD
    Erase             : LONGINT;                {Used to signal erased status}
    Telephone         : STRING[40];                 {Phone number translation}
    Cost              : WORD;                       {Cost per minute of calls}
    Baudrate          : WORD;                     {Max baudrate for this area}
  END;{PHONEREC}

(*
**  The nodelist index file (NODELIST.FDX) has the following record
**  format.
*)
  NODEIDXREC = RECORD
    Length            : BYTE;                     {Length byte for key string}
    Zone,                                           {Swapped zone for sorting}
    Net,                                             {Swapped net for sorting}
    Node,                                           {Swapped node for sorting}
    Point,                                         {Swapped point for sorting}
    RoutNet,                                     {Default routing within zone}
    RoutNode          : WORD;
    Status            : BYTE;                                      {See above}
    RESERVED          : BYTE;                                       {Reserved}
  END;{NODEIDXREC}

(*
**  The userlist index file (USERLIST.FDX) has the following record
**  format.
*)
  USERIDXREC = RECORD CASE INTEGER OF
    1:  (NameIt       : STRING[36]);              {To facilitate use of moves}
    2:  (User         : STRING[15];                   {Actual name key length}
         Zone,                                        {To return address info}
         Net,
         Node,
         Point        : WORD;
         Status       : BYTE);                        {Node status, see above}
  END;{USERIDXREC}

(* end of file "nodelist.inc" *)

