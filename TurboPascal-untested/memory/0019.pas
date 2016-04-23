{*************************** EMS.PAS ************************
*** Demonstrate calls to Extended memory manager          ***
************************************************************}

USES

  Crt,Dos;

{***************************************************************}

TYPE
  PtrType = RECORD                  {Define a pointer record    }
    Offset  : Word;                 {  type so we can access the}
    Segment : Word                  {  individual pointer fields}
    END;
  DeviceName = ARRAY[1..8] OF Char; {Defined to test device Name}

CONST

  EmsInt      = $67;                {EMS Interrupt number       }
  IOCtlFunc   = $44;                {IOCtl DOS Function number  }
  PageLen     = 16384;              {Length of memory page      }
  MsgLen      = 16;                 {Message len plus len byte  }
  MsgsPerPage = PageLen DIV MsgLen; {Number of messages in page }
  NumMsgs     = 5000;               {Number EMS messages        }

  {*** Emm functions ***}

  GetStatus        = $40;
  GetPageFrameAddr = $41;
  GetUnallocPages  = $42;
  GetEmmVersion    = $46;
  AllocatePages    = $43;
  MapHandlePage    = $44;
  DeallocatePages  = $45;

VAR
  P0, P1, P2, P3 : Pointer;     {Pointers to physical pages     }
  EmmHandle      : Integer;     {Handle for EMM allocated pages }
  Tmp            : FILE;        {Temp file to test if EMM exists}
  MsgBuf         : Pointer;     {Pointer into mapped memory     }
  Buff           : String[15];  {Buffer for msg stored in EM    }
  I              : Integer;     {Dummy variable                 }
  EmmRegs        : Registers;   {Registers for interrupt calls  }
  Page,Index     : Integer;     {Used to address page frame     }
  EmsVector      : Pointer;     {EMM address from Int $67       }
  StrNum         : String[4];   {Holds record # for EMM msg     }

{******** Function to convert word value to Hex string *********}

FUNCTION Hex(IntNbr : Word): String;
CONST
  HexDigit :ARRAY[0..15] OF Char = '0123456789ABCDEF';
VAR
  S        : String[2];         {Temporary String}
  TempByte : Byte;
BEGIN
  TempByte := Hi(IntNbr);                  {Convert upper nibble}
  S := HexDigit[TempByte DIV 16] +
       HexDigit[TempByte MOD 16];
  TempByte := Lo(IntNbr);                  {Convert lower nibble}
  Hex := S + HexDigit[TempByte DIV 16] +
             HexDigit[TempByte MOD 16];
END;

{******** Create a string that contains a pointer value ********}

FUNCTION PrintPointer(P : Pointer): String;

BEGIN
  PrintPointer := Hex(PtrType(P).Segment) + ':' +
                  Hex(PtrType(P).Offset);
  END;

{*********** Print the EMM Status to the screen ****************}

PROCEDURE EmmPrintStatus(Status: Byte);

CONST
  EmmStatus : ARRAY [$80..$8F] OF String =
    ('Driver malfunction',
     'Hardware malfunction',
     '',
     'Bad Handle',
     'Undefined FUNCTION',
     'No free handles',
     'Page map context Error',
     'Insufficient memory pages',
     'Not enough free pages',
     'Can''t allocate zero (0) pages',
     'Logical page out of range',
     'Physical page out of range',
     'Page map hardware RAM full',
     'Page map already has a Handle',
     'Page map not mapped to Handle',
     'Undefined subfunction number');

BEGIN
  CASE Status OF
    0        : WriteLn('Ok');
    $80..$8F : WriteLn('EMM: ',EmmStatus[Status])
    ELSE WriteLn('EMM: Unknown status = $',Hex(Status))
    END
END;



{******** Generic procedure to call the EMM interrupt **********}

PROCEDURE CallEmm(EmmFunction : Byte; VAR R : Registers);

BEGIN
  R.AH := EmmFunction;
  Intr(EmsInt,R);
  IF (R.AH <> 0) THEN BEGIN
    EmmPrintStatus(EmmRegs.AH);
    Halt(EmmRegs.AH)
    END
  END;

{******************  Main Program  *****************************}


BEGIN

  ClrScr;

{$DEFINE CheckFile}              {Undefine to test second method}

{$IFDEF CheckFile}                  {Check EMM driver - Method 1}

  GetIntVec(EmsInt,EmsVector);
  PtrType(EmsVector).Offset := 10;
  IF (DeviceName(EmsVector^) <> 'EMMXXXX0') THEN BEGIN
    WriteLn('No EMM driver present');
    Halt(1)
    END;

{$ELSE}                             {Check EMM driver - Method 2}

  {***** Determine if EMM is installed by opening EMMXXXX0 *****}

  {$I-}
  Assign(Tmp,'EMMXXXX0');
  Reset(Tmp);
  {$I+}
  IF (IOResult <> 0) THEN BEGIN      {Opened file without error?}
    WriteLn('No EMM driver present');
    WriteLn('IO error #',IOResult:3);
    Halt(1)
    END;

  EmmRegs.AH := IOCtlFun              {Call IOCtl function to   }
  EmmRegs.AL := $00;                  { test whether EMMXXXX0 is}
  EmmRegs.BX := FileRec(Tmp).Handle;  { a file or a device      }

  MsDos(EmmRegs);
  Close(Tmp);

  IF (EmmRegs.Flags AND 1) = 0 THEN            {Call successfull}
    IF (EmmRegs.DX AND $80) = $80 THEN   {Handle is for a device}
      WriteLn('Handle refers to a device')
    ELSE BEGIN
      WriteLn('Handle refers to a FILE');
      WriteLn('Unable to contact EMM driver if present');
      Halt(1)
      END
  ELSE BEGIN                                 {Call unsuccessfull}
    CASE EmmRegs.AX OF
      1 : WriteLn('Invalid IOCTL subfunction');
      5 : WriteLn('Access to IOCTL denied');
      6 : WriteLn('Invalid Handle')
      ELSE WriteLn('Unknown error # ',Hex(EmmRegs.AX))
      END;
    WriteLn('Unable to contact EMM driver');
    Halt(1)
    END;


{$ENDIF}

  WriteLn('EMM driver present');

  {********  Print the current status of the EMM driver ********}

  CallEmm(GetStatus,EmmRegs);
  WriteLn('EMM Status Ok');

  {******** Print the version number of EMM driver *************}

  CallEmm(GetEmmVersion,EmmRegs);

  WriteLn('EMS driver version = ',
           (EmmRegs.AL SHR 4):1,'.',
           (EmmRegs.AL AND $0F):1);

  IF EmmRegs.AL < $32 THEN BEGIN
    WriteLn('Error - EMM is version is earlier than 3.2');
    Halt(1)
    END;

  {***** Print the page frame & physical window addresses ******}

  CallEmm(GetPageFrameAddr,EmmRegs);

  PtrType(P0).Segment := EmmRegs.BX; { Window 0 -> P0 = BX:0000 }
  PtrType(P0).Offset := $0;
  PtrType(P1).Segment := EmmRegs.BX; { Window 1 -> P1 = BX:4000 }
  PtrType(P1).Offset := $4000;
  PtrType(P2).Segment := EmmRegs.BX; { Window 2 -> P2 = BX:8000 }
  PtrType(P2).Offset := $8000;
  PtrType(P3).Segment := EmmRegs.BX; { Window 3 -> P3 = BX:C000 }
  PtrType(P3).Offset := $C000;

  WriteLn('Page frame segment address = ',Hex(EmmRegs.BX));
  WriteLn('Physical page 0 address = ',PrintPointer(P0));
  WriteLn('Physical page 1 address = ',PrintPointer(P1));
  WriteLn('Physical page 2 address = ',PrintPointer(P2));
  WriteLn('Physical page 3 address = ',PrintPointer(P3));

  {***** Print # of unallocated pages and total # of pages *****}

  CallEmm(GetUnallocPages,EmmRegs);
  WriteLn('Total EMS pages = ',EmmRegs.DX:4);
  WriteLn('Unused EMS pages = ',EmmRegs.BX:4);

  {***** Allocate some pages of expanded memory *****}

  EmmRegs.BX := (NumMsgs + MsgsPerPage) DIV MsgsPerPage;
  CallEmm(AllocatePages,EmmRegs);
  WriteLn('Allocated ',EmmRegs.BX,
          ' pages to handle # ',EmmRegs.DX);
  EmmHandle := EmmRegs.DX;

  {***** Load EMS RAM with data *****}

  MsgBuf := P0;               {* Set Message pointer to Page 0 *}

  FOR I := 0 TO NumMsgs-1 DO BEGIN
    Str(I:4,StrNum);                       {Create msg string   }
    Buff := ' EMS msg # ' + StrNum;
    IF (I MOD 100) = 0 THEN Write('.');    {Dsp status on screen}
    Page := I DIV MsgsPerPage;
    Index := I MOD MsgsPerPage;
    PtrType(MsgBuf).Offset := Index * SizeOf(Buff);

     {**** Map indicated logical page into physical page 0 ****}

    EmmRegs.AH := MapHandlePage;           {Map EMS page cmd    }
    EmmRegs.BX := Page;                    {Logical page number }
    EmmRegs.AL := 0;                       {Physical page 0     }
    EmmRegs.DX := EmmHandle;               {EMM RAM handle      }

    Intr(EmsInt,EmmRegs);

    IF EmmRegs.AH = 0 THEN
      Move(Buff[0],MsgBuf^,SizeOf(Buff))   {Set message into mem}
    ELSE BEGIN
      EmmPrintStatus(EmmRegs.AH);
      I := NumMsgs
      END
    END;

    WriteLn;

  {******  Allow user to access any message in the buffer ******}

  I := $FF;
  WHILE I <> -1 DO BEGIN
    MsgBuf := P3;                 {Set MsgBuf to physical page 3}
    Write('Enter message # to retrieve, or -1 to quit: ');
    ReadLn(I);
    IF (I >= 0) AND (I < NumMsgs) THEN BEGIN
      Page := I DIV MsgsPerPage;
      Index := I MOD MsgsPerPage;

        {**** Map indicated page into physical page 3 ****}

      EmmRegs.AH := MapHandlePage;         {Map EMM page command}
      EmmRegs.BX := Page;                  {Logical page number }
      EmmRegs.AL := 3;                     {Physical page 3     }
      EmmRegs.DX := EmmHandle;             {EMM RAM handle      }

      Intr(EmsInt,EmmRegs);

      IF EmmRegs.AH = 0 THEN BEGIN
        Inc(PtrType(MsgBuf).Offset,Index * SizeOf(Buff));
        Move(MsgBuf^,Buff[0],SizeOf(Buff));
        Write('Retrieved message -> ',Buff);
        WriteLn(' from page #',Page:2,' Index',Index:5);
        END
      ELSE BEGIN
        EmmPrintStatus(EmmRegs.AH);
        I := -1;
        END
      END
    END;

     {***** Free the EMS RAM back to the EMM driver ****}

  EmmRegs.DX := EmmHandle;
  CallEmm(DeallocatePages,EmmRegs);
  WriteLn('Released all memory for handle ',EmmRegs.DX:2);
END.
