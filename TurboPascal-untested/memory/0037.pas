{
│>anybody know how I can determine the size of the driver in
│>memory?
│ I would assume they take the Drivers name and search through the
│ Memory Control Blocks maintained by DOS and seeing if the driver
│ owns any of them.  But there might be an easier way.

There is.  An undocumented DOS function (52h) gives you the "list of
lists", which contains the first device driver in a linked list, which
you can then traverse.  (See Schulman's _Undocumented DOS_.)

Take the address of the device driver header, and look at the 0 offset
in the "segment" which is 1 segment address unit before the beginning
of the device driver header.  For example, if the device driver header
is at $1234:$0000, look at address $1233:0.  If the byte at that
address is "M", "Z", or "D", we have either a valid memory control
block header ("M" or "Z"), or a "device driver subheader" ("D") which
follows the same format.  In either case, the word at <segment>:0003
gives the number of 16-byte paragraphs used by that memory block;
multiply by 16 to get the size in bytes.  The following TP code should
illustrate this (*only* HexW is used from OPString; substitute your
own or any PD/Shareware hex conversion routine if you don't have OPro):
}

USES DOS, OPString;
TYPE
  PMCBhdr = ^TMCBhdr;
  TMCBhdr = RECORD
    Signature: CHAR;  { 'M', 'Z', or one of the valid 'subblock' letters}
    OwnerSeg:  WORD;  { Segment of "owner" of this block }
    SizeParas: WORD;  { Size of block, in 16-byte paragraphs }
    Unused:    ARRAY [1..3] OF CHAR;
    Name:      ARRAY [1..8] OF CHAR; {Name of owner program (DOS 4+)}
  END;
  PDevHdr = ^TDevHdr;
  TDevHdr = RECORD
    NextDriver: POINTER;              { Next driver in device chain }
    Attr:       WORD;                 { Driver attribute word }
    Strategy:   WORD;                 { Offset within this segment }
    Interrupt:  WORD;                 {   of the driver strategy & }
                                      {   interrupt routines.      }
    Name:       ARRAY [1..8] OF CHAR; { Device name for char devs; }
                 {   for block devices, first byte is # of logical }
                 {   devices associated with this driver, others   }
                 {   are unused.                                   }
  END;

PROCEDURE DisplayDeviceHeader( DevHdr: PDevHdr );
  VAR
    MCBptr: ^TMCBhdr;
    Size:   LONGINT;
  BEGIN
    { The line to be displayed will look something like this:      }
    { ssss:oooo dev_name mem_size owner_name                       }
    { The last two columns are displayed only under DOS 4+, and    }
    { only when the information is found -- may fail under 386^Max }
    Write( HexW( Seg( DevHdr^ ) ), ':', HexW( Ofs( DevHdr^ ) ), ' ' );

    { See if it's a character device.  If it is, then it has a name }
    { to display.                                                   }
    IF (DevHdr^.Attr AND $8000) <> 0 THEN
      Write( DevHdr^.Name:12, ' ' )
    ELSE  { Block device -- write # of logical drives }
      Write( Ord( DevHdr^.Name[1] ):3, ' drive(s) ' );

    { See if the DOS version supports the 'sub-MCBs' introduced for }
    { device drivers in the first MCB in DOS version 4, and/or the  }
    { Name field in the MCB introduced in v4.                       }
    IF Lo( DosVersion ) >= 4 THEN BEGIN
      MCBptr := Ptr( Seg( DevHdr^ ) - 1, 0 );

      { Check for MCB sig., and make sure the MCB "owns itself" }
      IF (MCBptr^.Signature IN ['M', 'Z', 'D']) AND
         (MCBptr^.OwnerSeg = Seg( DevHdr^ ) ) THEN BEGIN
        Size := MCBptr^.SizeParas * 16;
        Write( Size:6, MCBptr^.Name:9 );
      END; { IF MCB signature }
    END; { IF DosVersion }
    WriteLn;
  END; {DisplayDeviceHeader}

VAR
  Regs: REGISTERS;  CurDevice: PDevHdr;
BEGIN { main program }
  Regs.AH := $52;
  MSDos( Regs );
  IF Lo( DosVersion ) < 3 THEN                { Get first device in list; }
    CurDevice := Ptr( Regs.ES, Regs.BX+$17 )  { location varies by DOS    }
  ELSE                                        { version.                  }
    CurDevice := Ptr( Regs.ES, Regs.BX+$22 );
  REPEAT
    DisplayDeviceHeader( CurDevice );
    CurDevice := CurDevice^.NextDriver;
  UNTIL Ofs( CurDevice^ ) = $FFFF;
END.
