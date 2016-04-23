                         QWK Mail Packet File Layout
                              by Patrick Y. Lee
                       Version 1.0 - February 23, 1992

This document is Copyright 1992 by Patrick Y. Lee.

The QWK-format is Copyright 1987 by Sparkware.

All Program names mentioned in this document are either Copyright
or Trade- mark of respective owner(s).

The author provides this File as-is without warranty of any kind,
either expressed or implied.  You are using the information in
this File at your own discretion.  The author assumes no
responsibilities For damages, either physically or financially,
from the use of this information.

This document may be freely distributed by any means
(electronically, pa- per, etc.), provided that it is distributed
in its entirety.  Portions of this document may be reproduced
without credit.

                              Table of Contents

1.  Introduction
    1.1.  Intent
    1.2.  History
    1.3.  Questions, corrections, etc.
2.  Conventions & overview
    2.1.  The BBS ID
    2.2.  Packet compression
    2.3.  Packet transfer & protocols
    2.4.  Limitations
3.  QWK Files
    3.1.  Naming convention
    3.2.  Control File (CONTROL.DAT)
    3.3.  Welcome File
    3.4.  Goodbye File
    3.5.  News File
    3.6.  Qmail DeLuxe menu File
    3.7.  New uploads listing (NEWFileS.DAT)
    3.8.  Bulletin File(s) (BLT-x.y)
    3.9.  Message File (MESSAGES.DAT)
    3.10.  Index Files (*.NDX)
        3.10.1.  Conference indices
        3.10.2.  Personal index (PERSONAL.NDX)
    3.11.  Pointer File
    3.12.  SESSION.TXT
4.  REP Files
    4.1.  Naming convention
    4.2.  Message File (BBSID.MSG)
    4.3.  Door control messages
    4.3.1.  DOOR.ID File
    4.3.2.  Qmail
    4.3.3.  MarkMail
    4.3.4.  KMail
    4.3.5.  RoseMail
    4.3.6.  Complete Mail Door
    4.4.  Turning off the echo flag
    4.5.  Tag-lines
5.  Net mail
A.  Credits & contributions
B.  Sample Turbo Pascal and C code
C.  Sample message
D.  Sample index File

                        -=-=-=-=-=-=-<>-=-=-=-=-=-=-

To search For a specific section, look For "[x.x]" using your
editor or viewer.  For example, to jump to the tag-lines portion
of this File, search For "[4.5]" With your editor or Text viewer.

                        -=-=-=-=-=-=-<>-=-=-=-=-=-=-

[1]  Introduction

[1.1]  Intent

This document is written to facilitate Programmers who want to
Write QWK-format mail doors or readers.  It is intended to be a
comprehen- sive reference covering all areas of QWK-format mail
processing.  De- tailed break down of each File is included, as
are Implementation information.  In addition, door and reader
specific information may be included, when such information are
available to me.

[1.2]  History

The QWK-format was invented by Mark "Sparky" Herring in 1987.  It
was based on Clark Development Corporation's PCBoard version 12.0
message base format.  Off-line mail reading has become popular
only in recent years.  Prior to summer of 1990, there were only
two QWK-format off- line mail reader Programs.  They were Qmail
DeLuxe by Mark Herring and EZ-Reader by Eric Cockrell.  Similarly
for the doors, there were only two -- Qmail by Mark Herring and
MarkMail by Mark Turner.  They were both For PCBoard systems.

A lot has changed in both off-line reader and mail door markets
since summer 1990.  Now, there are more than a dozen off-line
mail readers For the PC.  Readers For the Macintosh, Amiga, and
Atari exist as well.  There are over a half dozen doors for
PCBoard, and QWK-format doors exist For virtually all of the
popular BBS softwares.  All of these happened in less than two
years!  More readers and doors are in development as I Write
this, keep up the excellent work.  In addition to doors, some BBS
softwares has QWK-format mail facility built in.

Off-line mail reading is an integral part of BBS calling.
Conference traffic and selection on all networks have grown
dramatically in re- cent years that on-line reading is a thing of
the past.  Off-line mail reading offers an alternative to reading
mail on-line -- It offers speed that cannot be achieved with
on-line mail reading.

The reason why QWK-format readers and doors seem to have gained
popu- larity is probably dued to its openness.  The format is
readily avail- able to any Programmer who wishes to Write a
Program that utilize it. Proprietary is a thing of the past, it
does not work!  Openness is here to stay and QWK-format is a part
of it.

[1.3]  Questions, corrections, etc.

Most of the message networks today have a conference/echo devoted
to discussion of off-line readers and mail doors.  The ones I
know are on FidoNet, ILink, Intelec, and RIME.  If you have
questions after read- ing anything in here, feel free to drop by
any of the above confer- ence/echo and I am sure other QWK
authors will try to help.

I can be reached in the Off-line conferences on RIME, ILink, and
Intelec, as well as the Common conference on RIME.  Mail can be
routed to node RUNNINGB.  I can be reached on the Internet at
"p.lee@green.cooper.edu".  Any corrections, extensions, comments,
and criticisms are welcomed.

[2]  Conventions & overview
All offsets referenced in this document will be relative to 1.  I
am not a computer, I start counting at one, not zero!

Words which are enclosed in quotes should be entered as-is.  The
quo- tations are not part of the String unless noted.

You may have noticed I use the phrase "mail Program" or "mail
facili- ty" instead of mail doors.  This is because some BBS
softwares offer the option of creating QWK-format mail packets
right from the BBS. With those, there is no need For an external
mail door.

[2.1]  The BBS ID

The BBS ID (denoted as BBSID) is a 1-8 Characters Word that
identifies a particular BBS.  This identifier should be obtained
from line 5 of the CONTROL.DAT File (see section 3.2.1).

[2.2]  Packet compression

Most mail packets are compressed when created by the mail door in
order to save download time and disk space.  However, many
off-line reader Programs allow the user to unarchive a mail
packet outside of the reader Program, so the reader will not have
to unarchive it.  Upon Exit, the reader will not call the
archiver to save it.  It is up to the user to archive the
replies.  This is useful if the user has lim- ited memory and
cannot shell out to Dos to run the unarchive Program. For readers
based on non-PC equipment, the user may be using less common
compression Program that does not have command line equivalent.

[2.3]  Packet transfer & protocols

There is no set rule on what transfer protocol should be used.
Howev- er, it would be nice For the mail Program on the BBS to
provide the Sysop With options as to what to offer.  This should
be a configura- tion option For the user.

[2.4]  Specifications & limitations

There aren't many known limits in the QWK specification.
However, Various networks seem to impose artificial limits.  On
many of the PC- based networks, 99-lines appears to be the upper
limit For some softwares.  However, most of the readers can
handle more than that. Reader authors reading this may want to
offer the option to split replies into n lines each (the actual
length should be user definable so when the network software
permits, the user can increase this num- ber).

[3]  QWK Files

[3.1]  Naming convention

Generally, the name of the mail packet is BBSID.QWK.  However,
this does not have to be the case.  When the user downloads more
than one mail packet at one time, either the mail Program or the
transfer pro- tocol Program will rename the second and subsequent
mail packets to other names.  They will either change the File
extension or add a number to the end of the Filename.  In either
case, you should not rely on the name of the QWK File as the
BBSID.  The BBSID, as men- tioned before, should be obtained from
line 5 of the CONTROL.DAT File. In addition, mail packets do not
have to end With QWK extension ei- ther.  The user may choose to
name them With other File extensions.

[3.2]  Control File (CONTROL.DAT)

The CONTROL.DAT File is a simple ASCII File.  Each line is
terminated With a carriage return and line feed combination.  All
lines should start on the first column.

Line #
 1   My BBS                   BBS name
 2   New York, NY             BBS city and state
 3   212-555-1212             BBS phone number
 4   John Doe, Sysop          BBS Sysop name
 5   20052,MYBBS              Mail door registration #, BBSID
 6   01-01-1991,23:59:59      Mail packet creation time
 7   JANE DOE                 User name (upper case)
 8                            Name of menu For Qmail, blank if none
 9   0                        ? Seem to be always zero
10   0                        ? Seem to be always zero
11   121                      Total number of conference minus 1
12   0                        1st conf. number
13   Main Board               1st conf. name (13 Characters or less)
14   1                        2nd conf. number
15   General                  2nd conf. name
..   3                        etc. onward Until it hits max. conf.
..   123                      Last conf. number
..   Amiga_I                  Last conf. name
..   HELLO                    Welcome screen File
..   NEWS                     BBS news File
..   SCRIPT0                  Log off screen

Some mail doors, such as MarkMail, will send additional
information about the user from here on.

0                             ?
25                            Screen length on the BBS
JANE DOE                      User name in uppercase
Jane                          User first name in mixed case
NEW YORK, NY                  User city information
718 555-1212                  User data phone number
718 555-1212                  User home phone number
108                           Security level
00-00-00                      Expiration date
01-01-91                      Last log on date
23:59                         Last log on time
999                           Log on count
0                             Current conference number on the BBS
0                             Total KB downloaded
999                           Download count
0                             Total KB uploaded
999                           Upload count
999                           Minutes per day
999                           Minutes remaining today
999                           Minutes used this call
32767                         Max. download KB per day
32767                         Remaining KB today
0                             KB downloaded today
23:59                         Current time on BBS
01-01-91                      Current date on BBS
My BBS                        BBS network tag-line
0                             ?

Some mail doors will offer the option of sending an abbreviated
con- ference list.  That means the list will contain only
conferences the user has selected.  This is done because some
mail readers cannot handle more than n conferences at this time.
Users using those read- ers will need this option if the BBS they
call have too many confer- ences.

[3.3]  Welcome File

This File usually contains the log on screen from the BBS.  The
exact Filename is specified in the CONTROL.DAT File, after the
conference list.  This File may be in any format the Sysop
chooses it be -- usu- ally either in plain ASCII or With ANSI
screen control code.  Some Sysops (notably PCBoard Sysops) may
use BBS-specific color change code in this File as well.  Current
mail Programs seem to handle the trans- lations between
BBS-specific code to ANSI based screen control codes.
Even if the CONTROL.DAT File contains the Filename of this File,
it may not actually exist in the mail packet.  Sometimes, users
will manually delete this File before entering the mail reader.
Some off- line readers offer the option to not display this
welcome screen; some will display this File regardless.  Some
doors, similarly, will offer option to the user to not send this
File.

[3.4]  Goodbye File

Similar to the welcome File above, the Filename to the goodbye
File is in the CONTROL.DAT File.  This is the File the BBS
displays when the user logs off the board.  It is optional, as
always, to send this File or to display it.

[3.5]  News File

Many mail doors offer the option to send the news File from the
BBS. Most will only send this when it has been updated.  Like the
welcome and goodbye Files, the Filename to the news File is found
in the CON- TROL.DAT File.  It can be in any format the Sysop
chooses, but usually in either ASCII or ANSI.  Like the welcome
screen, current mail facil- ities seem to handle translation
between BBS-specific control codes to ANSI screen control codes.

[3.6]  Qmail DeLuxe menu File

This File is of use only For Qmail DeLuxe mail reader by
Sparkware. The Filename is found on line 8 of the CONTROL.DAT
File.

[3.7]  New uploads listing (NEWFileS.DAT)

Most mail Programs on the BBS will offer the option to scan new
Files uploaded to the BBS.  The result is found in a File named
NEWFileS.DAT.  The mail Program, if implementing this, should
update the last File scan field in the user's proFile, if there
is such a field, as well as other information required by the
BBS.  The mail Program should, of course, scan new Files only in
those areas the user is allowed access.

[3.8]  Bulletin Files (BLT-x.y)

Most mail Programs will also offer the option to include updated
bul- letin Files found on the BBS in the mail packet.  The
bulletins are named BLT-x.y, where x is the conference/echo the
bulletin came from, and y the bulletin's actual number.  The mail
Program will have to take care of updating the last read date on
the bulletins in the user Record.

[3.9]  Message File (MESSAGES.DAT)

The MESSAGES.DAT File is the most important.  This is where all
of the messages are contained in.  The QWK File format is based
on PCBoard 12.0 message base format from Clark Development
Corporation (maker of PCBoard BBS software).

The File has a logical Record length of 128-Bytes.  The first
Record of MESSAGES.DAT always contain a copyright notice saying
"Produced by Qmail...Copyright (c) 1987 by Sparkware.  All Rights
Reserved".  The rest of the Record is space filled.  Actual
messages consist of a 128- Bytes header, plus one or more
128-Bytes block With the message Text. Actual messages start in
Record 2.  The header block is layed out as follows:

Offset  Length  Description
------  ------  ----------------------------------------------------
    1       1   Message status flag (unsigned Character)
                ' ' = public, unread
                '-' = public, read
                '+' = private, unread
                '*' = private, read
                '~' = comment to Sysop, unread
                '`' = comment to Sysop, read
                '%' = passWord protected, unread
                '^' = passWord protected, read
                '!' = group passWord, unread
                '#' = group passWord, read
                '$' = group passWord to all
    2       7   Message number (in ASCII)
    9       8   Date (mm-dd-yy, in ASCII)
   17       5   Time (24 hour hh:mm, in ASCII)
   22      25   To (uppercase, left justified)
   47      25   From (uppercase, left justified)
   72      25   Subject of message (mixed case)
   97      12   PassWord (space filled)
  109       8   Reference message number (in ASCII)
  117       6   Number of 128-Bytes blocks in message (including the
                header, in ASCII; the lowest value should be 2, header
                plus one block message; this number may not be left
                flushed within the field)
  123       1   Flag (ASCII 225 means message is active; ASCII 226
                means this message is to be killed)
  124       2   Conference number (unsigned Word)
  126       2   Not used (usually filled With spaces or nulls)
  128       1   Indicates whether the message has a network tag-line
                or not.  A value of '*' indicates that a network tag-
                line is present; a value of ' ' (space) indicates
                there isn't one.  Messages sent to readers (non-net-
                status) generally leave this as a space.  Only network
                softwares need this information.

Fields such as To, From, Subject, Message #, Reference #, and the
like are space padded if they are shorter than the field's
length.

The message Text starts in the next Record.  You can find out how
many blocks make up one message by looking at the value of
"Number of 128 Byte blocks".  Instead of carriage return and line
feed combination, each line in the message end With an ASCII 227
(pi Character) symbol. There are reports that some (buggy)
readers have problems With mes- sages which do not end the last
line in the message With an ASCII 227. If a message does not
completely occupy the 128-Bytes block, the re- mainder of the
block is padded With space or null.

Note that there seems to exist old doors which will use one Byte
to represent the conference number and pad the other one With an
ASCII 32 Character.  The Program reading this information will
have to deter- mine whether the ASCII 32 in Byte 125 of the
header is a filler or part of the unsigned Word.  One method is
to look in the CONTROL.DAT File to determine the highest
conference number.

Even though most mail Programs will generate MESSAGES.DAT Files
that appear in conference order, this is not always the case.
Tomcat! (mail door For Wildcat! BBS) generates MESSAGES.DAT that
is not in conference order.  This is due to how Wildcat! itself
stores mail on the BBS.

Note that some mail doors offer the option of sending a mail
packet even though there may be no messages to send -- thus an
empty MESSAG- ES.DAT File.  This was tested With Qmail 4.0 door
and it sent a MES- SAGES.DAT File that contains a few empty
128-Bytes blocks.

[3.10]  Index Files (*.NDX)

[3.10.1]  Conference indices

The index Files contain a list of Pointers pointing to the
beginning of messages in the MESSAGES.DAT File.  The Pointer is
in terms of the 128-Bytes block logical Record that the
MESSAGES.DAT File is in.  Each conference has its own xxx.NDX
File, where xxx is the conference num- ber left padded with
zeroes.  Some mail Programs offer the user the option to not
generate index Files.  So the mail readers need to cre- ate the
index Files if they are missing.
EZ-Reader 1.xx versions will convert the NDX Files from Microsoft
MKS format into IEEE long Integer format.  The bad part about
this is that the user may store those index Files back into the
QWK File.  When another reader reads the index Files, it will be
very confused!

Special note For BBSes With more than 999 conferences: Index
Files For conferences With four digit conference numbers is named
xxxx.NDX, where xxxx is the conference number (left padded with
zeroes).  The Filenames For three digit conferences are still
named xxx.NDX on these boards.  I would assume Filenames for
conferences in the five digit range is xxxxx.NDX, but I have not
seen a BBS With 10,000 or more conferences yet!

Each NDX File Uses a five Bytes logical Record length and is
formatted to:

Offset  Length  Description
------  ------  ------------------------------------------------------
    1       4   Record number pointing to corresponding message in
                MESSAGES.DAT.  This number is in the Microsoft MKS$
                BASIC format.
    5       1   Conference number of the message.  This Byte should
                not be used because it duplicates both the Filename of
                the index File and the conference # in the header.  It
                is also one Byte long, which is insufficient to handle
                conferences over 255.

Please refer to appendix B For routines to deal With MKS numbers.

[3.10.2]  Personal index (PERSONAL.NDX)

There is a special index File named PERSONAL.NDX.  This File
contains Pointers to messages which are addressed to the user,
i.e. personal messages.  Some mail door and utility Programs also
allow the selec- tion of other messages to be flagged as personal
messages.

[3.11]  Pointer File

Pointer File is generally included so that the user can reset the
last read Pointers on the mail Program, in Case there is a crash
on the BBS or some other mishaps.  There should be little reason
for the reader Program to access the Pointer File.

The Pointer Files I have seen are:

Qmail          BBSID.PTR
MarkMail       BBSID.PNT
KMail          BBSID.PNT
SFMailQwk      BBSID.SFP

Additions to this list are welcomed.

[3.12]  SESSION.TXT

This File, if included, will contain the message scanning screen
the user sees from the door.

[4]  REP Files

[4.1]  Naming convention

The reply File is named BBSID.MSG, where BBSID is the ID code for
the BBS found on line 5 of the CONTROL.DAT File.  Once this File
has been created, the mail reader can archive it up into a File
with REP exten- sion.

[4.2]  Message File (BBSID.MSG)

Replies use the same format as the MESSAGES.DAT File, except that
mes- sage number field will contain the conference number
instead.  In other Words, the conference number will be placed in
the two Bytes (binary) starting at offset 124, as well as the
message number field (ASCII) at offset 2.

The first 128-Bytes Record of the File is the header.  Instead of
the copyright notice, it contains the BBSID of the BBS.  This 1-8
Charac- ter BBSID must start at the very first Byte and must
match what the BBS has.  The rest of the Record is space padded.
The replies start at Record 2.  Each reply message will have a
128-Bytes header, plus one or more For the message Text; followed
by another header, and so on.

The mail Program must check to make sure the BBSID in the first
block of the BBSID.MSG File matches what the BBS has!

[4.3]  Door control messages

These messages allow the user to change their setup on the BBS by
simply entering a message.  The goal is to allow the user to be
able to control most areas of the BBS via the mail door.
Different mail doors have different capabilities.  Most all of
them offer the ability to add and drop a conference, as well as
reset the last read Pointers in a conference.

[4.3.1]  DOOR.ID File

The DOOR.ID File was first introduced by Greg Hewgill with
Tomcat! mail door and SLMR mail reader.  Since then, many other
authors have picked up this idea and use the format.  This File
provides the neces- sary identifiers a reader needs to send add,
drop, etc. messages to the mail door.  It tells the reader who to
address the message to and what can be put in the subject line.

DOOR = <doorname>             This is the name of the door that creat-
                              ed the QWK packet, i.e. <doorname> =
                              Tomcat.
VERSION = <doorversion>       This is the version number of the door
                              that created the packet, i.e.
                              <doorversion> = 2.9.
SYSTEM = <systemType>         This is the underlying BBS system Type
                              and version, i.e. <systemType> = Wildcat
                              2.55.
CONTROLNAME = <controlname>   This is the name to which the reader
                              should send control messages, eg.
                              <controlname> = TOMCAT.
CONTROLType = <controlType>   This can be one of ADD, DROP, REQUEST,
                              or others.  ADD and DROP are pretty
                              obvious (they work as in MarkMail), and
                              REQUEST is For use With BBS systems that
                              support File attachments.  Try out SLMR
                              With CONTROLType = REQUEST and use the Q
                              Function.  (This seems to be a Wildcat!
                              BBS feature.)
RECEIPT                       This flag indicates that the door/BBS is
                              capable of return receipts when a mes-
                              sage is received.  If the first three
                              letters of the subject are RRR, then the
                              door should strip the RRR and set the
                              'return-receipt-requested' flag on the
                              corresponding message.

None of the lines are actually required and they may appear in
any order.  Of course, you would need a CONTROLNAME if you have
any CONTROLType lines.

[4.3.2]  Qmail

Send a message addressed to "QMAIL" With a subject of "CONFIG".
Then, enter any of the commands listed below inside the Text of
your mes- sage.  Remember to use one command per line.
ADD <confnum>            Add a conference into the Qmail Door scanning
                         list.  "YOURS" can also be added to the com-
                         mand if the user wishes to receive messages
                         only addressed them.  i.e. "ADD 1 YOURS"
DROP <confnum>           Drop a conference from the Qmail Door scan-
                         ning list.
RESET <confnum> <value>  Resets a conference to a particular value.
                         The user can use "HIGH-xxx" to set the con-
                         ference to the highest message in the base.
CITY <value>             Changes the "city" field in the user's
                         PCBoard entry.
PASSWord <value>         Changes the user's login passWord.
BPHONE <value>           Business/data phone number
HPHONE <value>           Home/voice phone number
PCBEXPERT <on|off>       Turns the PCBoard expert mode ON or OFF.
PCBPROT <value>          PCBoard File transfer protocol (A-Z).
PAGELEN <value>          Set page length inside PCBoard.
PCBCOMMENT <value>       Set user maintained comment.
AUTOSTART <value>        Qmail Door autostart command.
PROTOCOL <value>         Qmail Door File transfer protocol (A-Z).
EXPERT <ON or OFF>       Turns the Qmail Door expert mode ON or OFF.
MAXSIZE <value>          Maximum size of the user's .QWK packet (in
                         Bytes)
MAXNUMBER <value>        Maximum number of messages per conference.

[4.3.3]  MarkMail

Send a message addressed to "MARKMAIL" With the subject line saying:

ADD [value]         in the conference you want to add
DROP                in the conference you want to drop
YOUR [value]        in the conference you want only your mail sent
YA [value]          in the conference you want only your mail + mail
                    addressed to "ALL"
FileS ON or OFF     in any conference to tell MarkMail whether to scan
                    For new Files or not.
BLTS ON or OFF      to turn on and off, respectively, of receiving
                    bulletins.
OWN ON or OFF       to turn on and off, respectively, of receiving
                    messages you sent
DELUXE ON or OFF    to turn on and off, respectively, of receiving
                    DeLuxe menu
LIMIT <size>        to set the maximum size of MESSAGES.DAT File can
                    be, it cannot exceed what the Sysop has set up

An optional number can be added onto the commands "ADD", "YOUR",
and "YA".  If this number is positive, then it will be treated as
an abso- lute message number.  MarkMail will set your last read
Pointer to that number.  If it is negative, MarkMail will set
your last read Pointer to the highest minus that number.  For
example: "ADD -50" will add the conference and set the last read
Pointer to the highest in the confer- ence minus 50.

[4.3.4]  KMail

Send a private message addressed to "KMAIL" in the conference
that you want to add, drop, or reset.  The commands are "ADD",
"DROP", and "RESET #", respectively.  The "#" is the message
number you want your last read Pointer in the conference be set
to.

[4.3.5]  RoseMail

The RoseMail door allows configuration information be placed in
either the subject line or message Text.  The message must be
addressed to "ROSEMAIL".  For only one command, it can be placed
in the subject line.  For more than one changes, the subject line
must say "CONFIG" and each change be placed in the message Text.
Every line should be left justified.  Valid commands are:

Command                                           Example

ADD <Conference> [<Message #>] [<Yours>]          ADD 2 -3 Y
DROP <Conference>                                 DROP 2
RESET <Conference> <Message #>                    RESET 12 5000
PCBEXPERT <ON | OFF> - PCBoard expert mode        PCBEXPERT ON
EXPERT <ON | OFF>    - RoseMail expert mode       EXPERT OFF
PCBPROT <A - Z>      - PCBoard protocol           PCBPROT Z
PROT <A - Z>         - RoseMail protocol          PROT G
PAGELEN <Number>     - Page length                PAGELEN 20
MAXSIZE <KBytes>     - Max packet size in Kb      MAXSIZE 100
MAXNUMBER <max msgs/conference>                   MAXNUMBER 100
JUMPSTART <Sequence or OFF>                       JUMPSTART D;Y;Q
MAXPACKET <max msgs/packet>                       MAXPACKET 500
AUTOSTART <Sequence or OFF> - same as jumpstart   AUTOSTART OFF
OPT <##> <ON | OFF>  - set door option            OPT 2 OFF

[4.3.6]  Complete Mail Door

Send message to "CMPMAIL", the commands are "ADD" and "DROP".
This message must be sent in the conference that you want to add
or drop.

[4.4]  Turning off the echo flag

In order to send a non-echoed message (not send out to other
BBSes), a user can enter "NE:" in front of the subject line.  The
mail Program will strip this "NE:" and turn off the echo flag.
This feature may not be offered in all mail doors.

[4.5]  Tag-lines

The most common format For a reader tag-line is:

[---
 * My reader v1.00 * The rest of the tag-line.

The three dashes is called a tear-line.  The tag-line is appended
to the end of the message and is usually one line only.  It is
preferred that tag-lines conform to this format so that
networking softwares such as QNet and RNet will not add another
tearline to the message when they process it.

Softwares on FidoNet does not like mail readers adding a
tear-line of their own, so if your mail reader offers a FidoNet
mode, you will need to get rid of the tear-line.  Another item
which differs between the FidoNet and PC-based networks is that
FidoNet does not like extended ASCII Characters.  So your reader
may want to strip high ASCII if the user has FidoNet mode on.
Acceptable tag-line style, I believe, is just this:

 * My Reader v1.00 * The rest of the tag-line.

[5]  Net mail

I do not have complete information of net-mail Implementation
using QWK-format.  Someone please fill me in the details.

                     -=-=-=-=-=-=-<>-=-=-=-=-=-=-

[A]  Credits and Contributions

Mark "Sparky" Herring, who originated the QWK-format.

Tim Farley, who started this documentation back in the summer of
1990. The general outline here is the work of Tim.  I filled in
the blanks.

Jeffery Foy, who gave us the format For Microsoft single binary
versus IEEE format.

Greg Hewgill, who (if I remember correctly) wrote the Turbo
Pascal routines (included in here) to convert between MKS and TP
LongInt.
Dennis McCunney, who is the host of the Off-line conference on
RIME, is very knowledgeable in off-line reading concept and
Programs.  His goal is to have one reader that can read mail
packet from any source.

All those who have been around the Off-line conferences on ILink
(the oldest of the three I participate), RIME, and Intelec, who
have pro- vided great help over the past two years.  The bulk of
the information presented here are from messages in those
conferences.  These people include, but are no limited to, the
followings: Dane Beko, Joseph Carnage, Marcos Della, Joey Lizzi,
Mark May, and Jim Smith.

[B]  Sample Turbo Pascal and C code

Here are a few routines in Turbo Pascal and C to convert
Microsoft BASIC MKS format to usable IEEE long Integer.  These
are collected over the networks and there is no guarantee that
they will work For you!

Turbo Pascal (Greg Hewgill ?):

Type
     bsingle = Array [0..3] of Byte;

{ converts TP Real to Microsoft 4 Bytes single }

Procedure Real_to_msb (pReal : Real; Var b : bsingle);
Var
     r : Array [0 .. 5] of Byte Absolute pReal;
begin
     b [3] := r [0];
     move (r [3], b [0], 3);
end; { Procedure Real_to_msb }

{ converts Microsoft 4 Bytes single to TP Real }

Function msb_to_Real(b : bsingle) : Real;
Var
     pReal : Real;
     r : Array [0..5] of Byte Absolute pReal;
begin
     r [0] := b [3];
     r [1] := 0;
     r [2] := 0;
     move (b [0], r [3], 3);
     msb_to_Real := pReal;
end; { Procedure msb_to_Real }

C (identify yourself if you originated this routine):

/* converts 4 Bytes Microsoft MKS format to long Integer */

unsigned long mbf_to_int (m1, m2, m3, exp)
unsigned int m1, m2, m3, exp;
{
     return (((m1 + ((unsigned long) m2 << 8) + ((unsigned long) m3 <<
     16)) | 0x800000L) >> (24 - (exp - 0x80)));
}

Microsoft binary (by Jeffery Foy):

   31 - 24    23     22 - 0        <-- bit position
+-----------------+----------+
| exponent | sign | mantissa |
+----------+------+----------+

IEEE (C/Pascal/etc.):

   31     30 - 23    22 - 0        <-- bit position
+----------------------------+
| sign | exponent | mantissa |
+------+----------+----------+

In both cases, the sign is one bit, the exponent is 8 bits, and the
mantissa is 23 bits.  You can Write your own, optimized, routine to
convert between the two formats using the above bit layout.

[C]  Sample message

Here is a sample message in hex and ASCII format:

019780  20 34 32 33 32 20 20 20 30 32 2D 31 35 2D 39 32   4232   02-15-92
019790  31 33 3A 34 35 52 49 43 48 41 52 44 20 42 4C 41  13:45RICharD BLA
0197A0  43 4B 42 55 52 4E 20 20 20 20 20 20 20 20 53 54  CKBURN        ST
0197B0  45 56 45 20 43 4F 4C 45 54 54 49 20 20 20 20 20  EVE COLETTI
0197C0  20 20 20 20 20 20 20 51 45 44 49 54 20 48 41 43         QEDIT HAC
0197D0  4B 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20  K
0197E0  20 20 20 20 20 20 20 20 20 20 20 20 34 30 33 36              4036
0197F0  20 20 20 20 37 20 20 20 20 20 E1 0A 01 00 00 20      7
019800  2A 20 49 6E 20 61 20 6D 65 73 73 61 67 65 20 64  * In a message d
019810  61 74 65 64 20 30 32 2D 30 39 2D 39 32 20 74 6F  ated 02-09-92 to
019820  20 53 74 65 76 65 20 43 6F 6C 65 74 74 69 2C 20   Steve Coletti,
019830  52 69 63 68 61 72 64 20 42 6C 61 63 6B 62 75 72  RiChard Blackbur
019840  6E 20 73 61 69 64 3A E3 E3 52 42 3E 53 43 20 AF  n said:

RB>SC
019850  20 65 64 69 74 6F 72 20 69 6E 20 74 68 65 20 28   editor in the (
019860  6D 61 69 6E 66 72 61 6D 65 29 20 56 4D 2F 43 4D  mainframe) VM/CM
019870  53 20 70 72 6F 64 75 63 74 20 6C 69 6E 65 20 69  S product line i
[ etc. ]
019A00  6E 6F 74 20 61 20 44 6F 63 74 6F 72 2C 20 62 75  not a Doctor, bu
019A10  74 20 49 20 70 6C 61 79 20 6F 6E 65 20 61 74 20  t I play one at
019A20  74 68 65 20 48 6F 73 70 69 74 61 6C 2E E3 20 20  the Hospital.

019A30  20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
019A40  20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
019A50  20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
019A60  20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
019A70  20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20
019A80  E3 50 43 52 65 6C 61 79 3A 4D 4F 4F 4E 44 4F 47
PCRelay:MOONDOG
019A90  20 2D 3E 20 23 33 35 20 52 65 6C 61 79 4E 65 74   -> #35 RelayNet
019AA0  20 28 74 6D 29 E3 34 2E 31 30 20 20 20 20 20 20   (tm)
4.10
019AB0  20 20 20 20 20 20 20 20 20 48 55 42 4D 4F 4F 4E           HUBMOON
019AC0  2D 4D 6F 6F 6E 44 6F 67 20 42 42 53 2C 20 42 72  -MoonDog BBS, Br
019AD0  6F 6F 6B 6C 79 6E 2C 4E 59 20 37 31 38 20 36 39  ooklyn,NY 718 69
019AE0  32 2D 32 34 39 38 E3 20 20 20 20 20 20 20 20 20  2-2498

019AF0  20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20

[D]  Sample index File

Here is a sample index File in hex format:

000000  00 00 28 87 19 00 00 30 87 19 00 00 38 87 19 00
000010  00 7E 87 19 00 00 07 88 19 00 00 0B 88 19 00 00
000020  0F 88 19 00 00 14 88 19 00 00 19 88 19 00 00 1E
000030  88 19 00 00 22 88 19 00 00 27 88 19 00 00 2C 88
000040  19 00 00 31 88 19 00 00 3B 88 19 00 00 40 88 19
000050  00 00 46 88 19 00 00 49 88 19 00 00 4D 88 19 00
000060  00 52 88 19 00 00 55 88 19 00 00 59 88 19 00 00
000070  60 88 19 00 00 66 88 19 00 00 70 88 19


