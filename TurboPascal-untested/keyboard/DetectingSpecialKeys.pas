(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0065.PAS
  Description: Detecting special keys
  Author: GREG VIGNEAULT
  Date: 01-27-94  13:32
*)

(*******************************************************************)
 PROGRAM xKeys;     { test detecting shift/alt/ctrl/sysreq keys     }
                    { Turbo/Quick Pascal  Oct.1992 Greg Vigneault   }
 USES Crt;          { import for ClrScr and KeyPressed              }
{-------------------------------------------------------------------}
 TYPE LockKey = ( RShift,LShift,Ctrl,Alt,Scroll,NumLock,Caps,Insert,
                  RightAlt,LeftAlt,RightCtrl,LeftCtrl,SysReq );
 VAR  KeyByte1 : BYTE Absolute $40:$17; { data maintained by BIOS }
      KeyByte2 : BYTE Absolute $40:$18;
      KeyByte3 : BYTE Absolute $40:$96;
{-------------------------------------------------------------------}
 FUNCTION KeyOn( xkey : LockKey ) : BOOLEAN;   { TRUE if LockKey on }
    BEGIN
    CASE xkey OF
     RShift..Insert : KeyOn:=BOOLEAN( KeyByte1 SHR ORD(xkey) AND 1);
     RightAlt       : KeyOn:=BOOLEAN( KeyByte3 SHR 3 AND 1 );
     LeftAlt        : KeyOn:=BOOLEAN( KeyByte2 SHR 1 AND 1 );
     RightCtrl      : KeyOn:=BOOLEAN( KeyByte3 SHR 2 AND 1 );
     LeftCtrl       : KeyOn:=BOOLEAN( KeyByte2 AND 1 );
     SysReq         : KeyOn:=BOOLEAN( KeyByte2 SHR 2 AND 1 );
    END; {case}
    END;
{-------------------------------------------------------------------}
 FUNCTION Keyboard101 : BOOLEAN;    { TRUE for 101/102-key kybd     }
    BEGIN KeyBoard101 := BOOLEAN( KeyByte3 SHR 4 AND 1 );   END;
{-------------------------------------------------------------------}
 VAR xkey : LockKey;
 BEGIN
    REPEAT  gotoxy(1,1);  WriteLn('Press any of...');

    Write('Shifts: ');
    IF KeyOn(LShift) OR KeyOn(RShift)       { either shift down?    }
        THEN BEGIN
                IF KeyOn(LShift) THEN Write('LEFT ');
                IF KeyOn(RShift) THEN Write('RIGHT');
                WriteLn;
             END
        ELSE    WriteLn('none');                    { neither shift }

    Write('Controls: ');
    IF KeyOn(Ctrl)                              { either ctrl down? }
        THEN BEGIN
                IF KeyOn(LeftCtrl)  THEN Write('LEFT ');
                IF KeyOn(RightCtrl) THEN Write('RIGHT');
                WriteLn;
             END
        ELSE    WriteLn('none');                    { neither ctrl  }

    Write('Alt keys: ');
    IF KeyOn(Alt)                               { either Alt down?  }
        THEN BEGIN
                IF KeyOn(LeftAlt)  THEN Write('LEFT ');
                IF KeyON(RightAlt) THEN Write('RIGHT');
                WriteLn;
             END
        ELSE    WriteLn('none');                    { neither alt   }

    FOR xkey := Scroll TO Insert                { check other keys  }
        DO BEGIN
        CASE xkey OF
            Scroll  : Write('Scroll: ');
            NumLock : Write('NumLock: ');
            Caps    : Write('CapsLock: ');
            Insert  : Write('Insert: ');
            END; {case}
        IF KeyOn(xkey) THEN WriteLn('ON') ELSE WriteLn('OFF');
        END;

    IF KeyBoard101
        THEN BEGIN
            Write('SysReq: ');
            IF KeyOn(SysReq) THEN WriteLn('ON') ELSE WriteLn('OFF');
        END;

    UNTIL KeyPressed;

 END {xKeys}.
(*******************************************************************)

