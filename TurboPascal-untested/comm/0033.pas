{
I created the following purly from my observations of the Bluewave files that
I have reiceived. There are parts that I believe to be incorrect, such as the
last five variables in the MIXRec record. I have worked very hard on this, so
if you use the following please give me my due creidit in the program or
documentation.

The BBSNAME.FTI file is made up of FTIRec records.

The BBSNAME.INF file is made up of one INFRec record and an unknown number
of ConfRec records.

The BBSNAME.MIX file is made up of an unknown number of MIXRec records.

The BBSNAME.DAT file is a file of char indexed by the FTIRec records.
}

  FTIRec = Record
    FromName : Array[1..36] of Char;
    ToName   : Array[1..36] of Char;
    Subject  : Array[1..72] of Char;
    Date     : Array[1..10] of Char;
    Time     : Array[1..10] of Char;
    MsgNum        : Word;
    BackThread    : Word; { I'm not sure if this is the offset in }
    ForwardThread : Word; { the FTI file or the message number }
    MsgOfs    : LongInt; { Offset in DAT file (bytes) }
    MsgLength : LongInt; { Length of msg in DAT file (bytes) }
    Flags  : Word; { Bit 1  = Private
                     Bit 2  = Crash
                     Bit 3  = Rec'd
                     Bit 4  = Sent
                     Bit 5  = File Attach
                     Bit 6  =
                     Bit 7  =
                     Bit 8  = Kill Sent
                     Bit 9  = Local
                     Bit 10 =
                     Bit 12 =
                     Bit 13 = Req Receipt
                     Bit 14 =
                     Bit 15 = Return Receipt
                     Bit 16 = Audit Req }
    Zone   : Word; { Fidonet Zone }
    Net    : Word; { Fidonet Net }
    Node   : Word; { Fidonet Node }
  end; { Total length of record is 186 }

  INFRec = Record
    UnKnown    : Byte; { I don't know what this is seems to always be 2 }
    InfoFiles  : Array[1..5] of Array[1..15] of Char;
    UserName   : Array[1..43] of Char;
    UserAlias  : Array[1..65] of Char;
    Zone, Net, Node, Point : Word; { The BBS's fidonet address }
    SysOpName  : Array[1..43] of Char;
    SystemName : Array[1..65] of Char;
    { The rest of this record is just a shot in the dark }
    NumMacros  : Word; { The number of macros allowed by the door }
    Extra1     : Array[1..7] of Char;
    KeyWords   : Array[1..10] of Array[1..21] of Char; { The keywords }
    Filters    : Array[1..10] of Array[1..21] of Char; { The filters }
    Macros     : Array[1..3]  of Array[1..75] of Char; { The macros }
  end;

  ConfRec = Record
    Number   : Array[1..6] of Char;
    Label    : Array[1..21] of Char;
    Title    : Array[1..50] of Char;
    ConfType : Byte;
    Extra    : Word;
  end;

  MIXRec = Record
    AreaNumber   : Array[1..6] of Char;
    NumMsgs      : Word;
    PersonalMsgs : Word;
    OffsetInFTI  : LongInt;
  end;
