(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0024.PAS
  Description: PKT File Format
  Author: DAN GIESE
  Date: 05-26-95  23:24
*)

{
> do you know the format the .PKT files have?

From FSC-0039.  There may have been a few changes since this doc so you may
need to play with it a little.

Type-2 Packet Format (proposed, but currently in use)
-----------------------------------------------------
  Field    Ofs Siz Type  Description                Expected value(s)
  -------  --- --- ----  -------------------------- -----------------
  OrgNode  0x0   2 Word  Origination node address   0-65535
  DstNode    2   2 Word  Destination node address   1-65535
  Year       4   2  Int  Year packet generated      19??-2???
  Month      6   2  Int  Month  "        "          0-11 (0=Jan)
  Day        8   2  Int  Day    "        "          1-31
  Hour       A   2  Int  Hour   "        "          0-23
  Min        C   2  Int  Minute "        "          0-59
  Sec        E   2  Int  Second "        "          0-59
  Baud      10   2  Int  Baud Rate (not in use)     ????
  PktVer    12   2  Int  Packet Version             Always 2
  OrgNet    14   2 Word  Origination net address    1-65535
  DstNet    16   2 Word  Destination net address    1-65535
  PrdCodL   18   1 Byte  FTSC Product Code     (lo) 1-255
* PVMajor   19   1 Byte  FTSC Product Rev   (major) 1-255
  Password  1A   8 Char  Packet password            A-Z,0-9
* QOrgZone  22   2  Int  Orig Zone (ZMailQ,QMail)   1-65535
* QDstZone  24   2  Int  Dest Zone (ZMailQ,QMail)   1-65535
  Filler    26   4 Byte  Spare Change               ?
* PrdCodH   2A   1 Byte  FTSC Product Code     (hi) 1-255
* PVMinor   2B   1 Byte  FTSC Product Rev   (minor) 1-255
* CapWord   2C   2 Word  Capability Word            BitField
* OrigZone  2E   2  Int  Origination Zone           1-65535
* DestZone  30   2  Int  Destination Zone           1-65535
* OrigPoint 32   2  Int  Origination Point          1-65535
* DestPoint 34   2  Int  Destination Point          1-65535
* ProdData  36   4 Long  Product-specific data      Whatever
  PktTerm   3A   2 Word  Packet terminator          0000

* - extensions to FTS-0001

Ofs, Siz are in hex, other values are decimal.


Zone/Point Aware Mail Processors (probably a partial list)
----------------------------------------------------------
  Prod
  Code Name - Uses QOrg/QDstZone Orig/DestZone Orig/DestPoint
  ---- ----------- ------------- ------------- --------------
  0x0C  FrontDoor  Reads/Updates      Yes           Yes
  0x1A  DBridge        ?????          Yes           Yes
  0x23  XRS        Reads/Updates      Yes           Yes
  0x29  QMail           Yes          ?????      Not point-aware
  0x35  ZMailQ          Yes          ?????      Not point-aware
  0x3F  TosScan    Reads/Updates      Yes           Yes

}
