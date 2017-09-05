(*
  Category: SWAG Title: 16/32 BIT CRC ROUTINES
  Original name: 0003.PAS
  Description: 16 BIT CRC
  Author: GREG VIGNEAULT
  Date: 05-28-93  13:35
*)

{
 The following is a Turbo/Quick Pascal Implementation of calculating
 the XModem Type of 16-bit cyclic redundancy checking (CRC).

 Is there a preference For the language of the next CRC-16 example
 (80x86 Assembly, BASIC, or C) ?
}

(*******************************************************************)
Program TPCRC16;    { Compiler: TurboPascal 4.0+ & QuickPascal 1.0+ }
{ Turbo Pascal 16-bit Cyclic Redundancy Checking (CRC) a.la. XModem }
{ Greg Vigneault, Box 7169, Station A, toronto, Canada M5W 1X8.     }

Const   Beep        = #7;                       { ASCII bell tone   }
Type    bArray      = Array [1..$4000] of Byte; { define buffer     }
        bPointer    = ^bArray;                  { Pointer to buffer }
Var     DataPtr     : bPointer;                 { Pointer to data   }
        fName       : String;                   { File name         }
        fHandle     : File;                     { File handle       }
        BytesIn     : Word;                     { For counting data }
        CRC16       : Integer;                  { running CRC-16    }

{-------------------------------------------------------------------}
 Procedure WriteHex( raw : Integer );   { display hexadecimal value }
    Var ch      : Char;
        shft    : Byte;
    begin
        if (raw = 0) then Write('0')            { if zero           }
        else begin
            shft := 16;                         { bit count         }
            Repeat  { isolate each hex nibble, and convert to ASCII }
                DEC( shft, 4 );                 { shift by nibble   }
                ch := CHR( raw SHR shft and $F or orD('0') ); {0..9 }
                if (ch > '9') then inC( ch, 7 );              {A..F }
                Write( ch );                    { display the digit }
            Until (shft = 0);
        end;
    end {WriteHex};

{-------------------------------------------------------------------}
 Function UpdateCRC16(CRC       : Integer;      { CRC-16 to update  }
                      InBuf     : bPointer;     { Pointer to data   }
                      InLen     : Integer) :Integer;  { data count  }
    Var Bit, ByteCount          : Integer;
        Carry                   : Boolean;      { catch overflow    }
    begin
    For ByteCount := 1 to InLen do              { all data Bytes    }
        For Bit := 7 doWNto 0 do begin          { 8 bits per Byte   }
            Carry := CRC and $8000 <> 0;        { shift overlow?    }
            CRC := CRC SHL 1 or InBuf^[ByteCount] SHR Bit and 1;
            if Carry then CRC := CRC xor $1021; { apply polynomial  }
        end; { For Bit & ByteCount }            { all Bytes & bits  }
    UpdateCRC16 := CRC;                         { updated CRC-16    }
    end {UpdateCRC16};

{-------------------------------------------------------------------}
begin
    { check For memory  }
    {
    if ( MaxAvail < Sizeof(bArray) ) then begin 
        WriteLn( 'not enough memory!', Beep );
        Halt(1);
    end;
    }
    if (ParamCount <> 1) then begin             { File name input?  }
        WriteLn( 'Use TPCRC16 <fName>', Beep );;
        Halt(2);
    end;
    fName := ParamStr(1);                       { get File name     }
    Assign( fHandle, fName );                   { open the File     }
    {$i-} Reset( fHandle, 1 ); {$i+}            { open succeeded?   }
    if (IoResult <> 0) then begin               { if not ...        }
        WriteLn( 'File access ERRor', Beep );
        Halt(3);
    end;
    New( DataPtr );                             { allocate memory   }
    CRC16 := 0;                                 { initialize CRC-16 }
    Repeat
        BlockRead( fHandle, DataPtr^[1], Sizeof(bArray), BytesIn );
        CRC16 := UpdateCRC16( CRC16, DataPtr, BytesIn );
    Until (BytesIn <> Sizeof(bArray)) or Eof(fHandle);
    Close( fHandle );                           { close input File  }
    DataPtr^[1] := 0; DataPtr^[2] := 0;         { insert two nulls  }
    CRC16 := UpdateCRC16( CRC16, DataPtr, 2 );  { For final calc    }
    Dispose( DataPtr );                         { release memory    }
    Write( 'The CRC-16 of File ', fName, ' is $' );
    WriteHex( CRC16 );  WriteLn;

end {TPCRCXMO}.
(*********************************************************************)

