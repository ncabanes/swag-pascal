(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0091.PAS
  Description: TSR Ring Detect
  Author: LEO TULLY
  Date: 09-04-95  11:56
*)

{
> I know this been asked a lot, but I still can't seem to figure it out:
> how do I detect a 'RING' signal from the modem at COMx?  (I want to
> write a tsr that makes the monitor flash red (like fading color 0 from
> black to red and
> back - that would be no problem, but the TSR and the modem part sure is)

This will do the trick for you.
}
Program RingDetector;  { TSR to detect telephone ring via modem    }
{$M $400,0,0}
Uses   Dos;            { import GetIntVec, SetIntVec               }
Const  COMport     = $3FE;             { COM1 = $3FE, COM2 = $2FE  }
       RingMsg     : Array [0..7] of Byte =
                   ( $52,$40,$49,$40,$4E,$40,$47,$40 );   { "RinG" }
Var    OldClock    : Procedure;        { For previous int vector   }
       GSpot       : Byte Absolute $B800:$072C;    { display area  }
       OldScreen   : Array [0..7] of Byte; { to save display are   }
{$F+}
Procedure RingDetect; Interrupt;
   begin
       if ODD(Port[COMport] SHR 6)
       then begin
           Move( GSpot, OldScreen, 8 );        { save screen area  }
           While ODD(PorT[COMport] SHR 6)
               do Move( RingMsg, GSpot, 8 );   { display "RinG"    }
           Move( OldScreen, GSpot, 8 );        { restore screen    }
       end; {if}
       InLine($9C);                            { to fake an inT    }
       OldClock;                               { chain ticker      }
   end {RingDetect};
{$F-}

begin
       GetIntVec($1C,@OldClock);               { save current isr  }
       SetIntVec($1C,ADDR(RingDetect));        { install this isr  }
       Keep(0);                                { tsr               }
end {RingDetector}.


