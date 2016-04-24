(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0043.PAS
  Description: Reading UART baud rate...
  Author: GREG VIGNEAULT
  Date: 05-25-94  08:14
*)


{
 Here's a TP function that will report the current UART baud rate for
 any serial port device (modem, mouse, etc.) ...
}

(*************************** GETBAUD.PAS ***************************)
PROGRAM GetBaud;                      { compiler: Turbo Pascal 4.0+ }
                                      { Mar.23.94 Greg Vigneault    }

(*-----------------------------------------------------------------*)
{ get the current baud rate of a serial i/o port (reads the UART)...}

FUNCTION SioRate (ComPort :WORD; VAR Baud :LONGINT) :BOOLEAN;
  CONST DLAB = $80;                   { divisor latch access bit    }
  VAR   BaseIO,                       { COM base i/o port address   }
        BRGdiv,                       { baud rate generator divisor }
        regDLL,                       { BRG divisor, latched LSB    }
        regDLM,                       { BRG divisor, latched MSB    }
        regLCR :WORD;                 { line control register       }
  BEGIN
    Baud := 0;                                { assume nothing      }
    IF (ComPort IN [1..4]) THEN BEGIN         { must be 1..4        }
      BaseIO := MemW[$40:(ComPort-1) SHL 1];  { fetch base i/o port }
      IF (BaseIO <> 0) THEN BEGIN             { has BIOS seen it?   }
        regDLL := BaseIO;                     { BRGdiv, latched LSB }
        regDLM := BaseIO + 1;                 { BRGdiv, latched MSB }
        regLCR := BaseIO + 3;                 { line control reg    }
        Port[regLCR] := Port[regLCR] OR DLAB;         { set DLAB    }
        BRGdiv := WORD(Port[regDLL]);                 { BRGdiv LSB  }
        BRGdiv := BRGdiv OR WORD(Port[regDLM]) SHL 8; { BRGdiv MSB  }
        Port[regLCR] := Port[regLCR] AND NOT DLAB;    { reset DLAB  }
        IF (BRGdiv <> 0) THEN
          Baud := 1843200 DIV (LONGINT(BRGdiv) SHL 4);  { calc bps  }
      END; {IF BaseIO}
    END; {IF ComPort}
    SioRate := (Baud <> 0);                   { success || failure  }
  END {SioRate};

(*-----------------------------------------------------------------*)

VAR ComPort : WORD;                         { will be 1..4          }
    Baud    : LONGINT;                      { as high as 115200 bps }

BEGIN {GetBaud}

  REPEAT
    WriteLn; Write ('Read baud rate for which COM port [1..4] ?: ');
    ReadLn (ComPort);
    IF NOT SioRate (ComPort, Baud) THEN BEGIN
      Write ('!',CHR(7)); {!beep}
      CASE ComPort OF
        1..4 : WriteLn ('COM',ComPort,' is absent; try another...');
        ELSE WriteLn ('Choose a number: 1 through 4...');
      END; {CASE}
    END; {IF}
  UNTIL (Baud <> 0);

  WriteLn ('-> COM',ComPort,' is set for ',Baud,' bits-per-second');

END {GetBaud}.

