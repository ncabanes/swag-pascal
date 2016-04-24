(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0023.PAS
  Description: Bluewave Mail Packet File Format
  Author: MIKKO HYVARINEN
  Date: 05-26-95  22:59
*)

{
> I would like to know if there is anybody outthere who can tell me in which
> way the BWAVE packets are organized. I want to write a Windows mail
> reader, just for fun and own usage, and want to implement Bwave mail
> packets, because I am using Bwave now to and it is easy for downloading
> mail.

BlueWave mail packets
======================



        Naming conventions : BBSID.ddn
                dd - two letter abbreviation of the day of week.
                n  - digit, number of packet.
                Example : MYBBS.MO1.

        Mail packet files :

        BBSID.INF       - contains user data and BBS configuration.
Purpouse and contents of this file are similar to CONTOL.DAT in QWK
mail packets.

        BBSID.MIX       - conference index file. Contains total number,
number of personal messages in each selected conference and start of
conference in message header file.

        BBSID.FTI       - message header file. Records are grouped
by conference and also contain offset and length of message text.

        BBSID.DAT       - message text file. Text of all messages
in packet without any delimiters between messages. Lines may be
terminated with either CR alone or CR/LF pairs.



Layout of BBSID.INF file

        Size
Offset  (Count) Format          Description
___-----------------------------------------------------------------------
0000    1       BYTE            BlueWave version number
0001    13 (5)  ASCIIZ str.     Names of welcome/news files, up to 5
                        Files may not be present in packet
0042    10      n/a             Unknown
004C    43      ASCIIZ str.     User real name
0077    43      ASCIIZ str.     User alias
00A2    21      ASCIIZ str.     Password
                        Password is forced to upper case and encrypted
                        by adding decimal 10 (0Ah) to each byte
00B7    1       BYTE            Password usage
                        bit 0           Use password in door
                        bit 1           Use password in reader
00B8    2       WORD            Zone
00BA    2       WORD            Net
00BC    2       WORD            Node
00BE    2       WORD            Point
00C0    43      ASCIIZ str.     Sysop name
00EB    65      ASCIIZ str.     BBS name
                        Left-justified and padded with spaces
012C    1       BYTE            File request limit
                        0 if file requests disabled
012D    6       n/a             Unknown
0133    2       WORD            Door setup flags
                        bit 0           Use door hotkeys
                        bit 1           Use door expert mode
                        bit 2           Unknown
                        bit 3           Use door graphics
                        bit 4           Filter messages from user
0135    21 (10) ASCIIZ str.     Keywords
                        Forced to upper case
0207    21 (10) ASCIIZ str.     Filters
                        Forced to upper case
02D9    80 (3)  ASCIIZ str.     Bundling macros
03C9    2       WORD            Unknown
03CB    2       WORD            Netmail credits
03CD    2       WORD            Netmail debits
03CF    255     n/a             Unknown
04CE    80 (?)  see below       Conference description records
___-----------------------------------------------------------------------

Layout of BBSID.INF file conference description records
(one record for each BBS conference )

        Size
Offset  (Count) Format          Description
___-----------------------------------------------------------------------
0000    6       ASCIIZ str.     Conference number
0006    21      ASCIIZ str.     Conference name
001B    50      ASCIIZ str.     Conference description
004D    1       BYTE            Conference attributes
                        bit 0           Conference selected for download
                        bits 2,1        Reply From: field
                                = 00            Put user alias
                                = 01            Put user real name
                                = 10            Allow to enter any name
                        bits 4,3        Conference type
                                = 00            Local
                                = 01            Echo mail
                                = 10            Netmail
                        bit 5           Write permission
                                = 0             Read only
                                = 1             Allowed to enter messages
                        bits 7,6        Message security
                                = 00            User selected
                                = 01            Force public
                                = 10            Force private
004E    2       n/a             Unknown
___-----------------------------------------------------------------------

Layout of BBSID.MIX file records
(one record for each selected conference, regardless whether it
contains any messages)

        Size
Offset  (Count) Format          Description
___-----------------------------------------------------------------------
0000    6       ASCIIZ str.     Conference number
0006    2       WORD            Total number of messages
0008    2       WORD            Number of personal messages
000A    4       DWORD           Offset of first message in this conference
                                in message header file (BBSID.FTI)
___-----------------------------------------------------------------------


Layout of BBSID.FTI (message header) file records
(one record for each message in packet)

        Size
Offset  (Count) Format          Description
___-----------------------------------------------------------------------
0000    36      ASCIIZ str.     Name of sender ("From" field)
0024    36      ASCIIZ str.     Name of receiver ("To" field)
0048    72      ASCIIZ str.     Message subject
0090    20      ASCIIZ str.     Message date and time
                        Example: "06 Aug 92  22:45:00"
                        Format of date and time string depends
                        from door configuration.
00A4    2       WORD            Message number
00A6    2       WORD            Number of previous message in thread
                                ("Refer")
00A8    2       WORD            Number of next message in thread
                                ("See also")
00AA    4       DWORD           Offset of message text in BBSID.DAT file
00AE    4       DWORD           Length (in bytes) of message text
00B2    2       WORD            Message attributes
                        bit 0           Private
                        bit 1           Crash
                        bit 2           Received
                        bit 3           Sent
                        bit 4           File attach
                        bit 5           In transit
                        bit 6           Orphan
                        bit 7           Kill/Sent
                        bit 8           Local
                        bit 9           Hold
                        bit 10          Read
                                BlueWave mail reader updates this
                                bit to keep track of read messages
                        bit 11          File request
                        bit 12          Direct
                        bit 13          Replied
                                BlueWave mail reader updates this
                                bit to indicate user has replied to
                                this message
                        bits 15, 14     Unknown
00B4    2       WORD            Origin zone
00B6    2       WORD            Origin net
00B8    2       WORD            Origin node
___-----------------------------------------------------------------------

BlueWave reply packets
=======================

        Naming conventions : Reply packets are named BBSID.NEW.

        Reply packet files:

        BBSID.UPI       - Upload information file. Contains mail reader
registration number, possibly some other information and reply header
records, if packet contains any replies.

        Reply text files (optional)     - ASCII files containing text of
individual replies. BlueWave mail reader creates filenames from conference
number and reply number, for example, 143.001.

        BBSID.PDQ (optional)    - Offline configuration data.

        BBSID.REQ (optional)    - File requests.


Layout of BBSID.UPI file

        Size
Offset  (Count) Format          Description
___-----------------------------------------------------------------------
0000    9       ASCIIZ str.     Reader registration number
0009    46      n/a             Unknown
0037    194 (?) see below       Reply header records
___-----------------------------------------------------------------------


Layout of reply headers in BBSID.UPI file
(one for each reply in packet)

        Size
Offset  (Count) Format          Description
___-----------------------------------------------------------------------
0000    36      ASCIIZ str.     Name of sender ("From" field)
0024    36      ASCIIZ str.     Name of receiver ("To" field)
0048    72      ASCIIZ str.     Reply subject
0090    4       DWORD           Reply date and time
                        Unix time stamp (number of seconds since midnight,
                        January 1, 1970, GMT)
0094    13      ASCIIZ str.     Name of file containing reply text.
00A1    21      ASCIIZ str.     Name of conference
___-----------------------------------------------------------------------


Offline configuration
======================

        If any changes are made to door configuration offline, BlueWave
mail reader includes BBSID.PDQ file in the reply packet. This file
contains the following information:

        Size
Offset  (Count) Format          Description
___-----------------------------------------------------------------------
0000    21 (10) ASCIIZ str.     Keywords
                        Forced to upper case
00D2    21 (10) ASCIIZ str.     Filters
                        Forced to upper case
01A4    78 (3)  ASCIIZ str.     Bundling macros
028E    21      ASCIIZ str.     Password
                        Password is forced to upper case and encrypted
                        by adding decimal 10 (0Ah) to each byte
02A3    1       BYTE            Password usage
                        bit 0           Use password in door
                        bit 1           Use password in reader
02A4    2       WORD            Door setup flags
                        bit 0           Use door hotkeys
                        bit 1           Use door expert mode
                        bit 2           Unknown
                        bit 3           Use door graphics
                        bit 4           Filter messages from user
02A6    21 (?)  ASCIIZ str.     Names of selected conferences
___-----------------------------------------------------------------------


File requests
==============

        If any files are requested, BlueWave mail reader includes
BBSID.REQ file in the reply packet:

        Size
Offset  (Count) Format          Description
___-----------------------------------------------------------------------
0000    13 (?)  ASCIIZ str.     Names of requested files
___-----------------------------------------------------------------------
}
