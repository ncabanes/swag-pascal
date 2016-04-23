 (*****************    W A I T   *************************
 * Delays NumberOfSecs seconds.  This is done by         *
 * accessing the PC clock via function $2C of DOS int    *
 * 21h.  Its accuracy is limited by the fact that the    *
 * time is calculated from the ROM BIOS tick count,      *
 * which is updated only about 18.2 times per second.    *
 * This means that Wait will be accurate to about        *
 * 1/18 second.                                          *
 *                                                       *
 * Requires "Uses DOS" if in TP4 or TP5                  *
 ******************    W A I T   ************************)

  uses dos, TpCrt, TpString;

  var
    p_cnt : integer;
    s     : string[5];
    sr    : real;
    okay  : boolean;
    ch    : char;


  PROCEDURE Wait(NumberOfSecs : Real);
  CONST
    Secs_PER_DAY = 86400.0; {60 * 60 * 24}
  VAR
    TimeIsUp : Boolean;
    StartingSecs,
    Secs : Real;

    (******************   READ CLOCK  ************************
    *                                                        *
    *  Reads the PC clock, by using service $2C of int 21h.  *
    *  This service returns information in the 8088          *
    *  registers as follows:                                 *
    *                                                        *
    *    CH      Hour                  (0 through 23)        *
    *    CL      Minute                (0 through 59)        *
    *    DH      Seconds               (0 through 59)        *
    *    DL      Hundredths of seconds (0 through 99)        *
    *******************   READ CLOCK  ***********************)

    PROCEDURE ReadClock(VAR Secs : Real);

    CONST
      Secs_PER_HOUR = 3600.0; {This must be a real constant!}
      Secs_PER_MINUTE = 60.0;
(*  TYPE {Delete this type for TP4 and TP5}
      Registers = RECORD
        CASE Boolean OF
          True : (AL,AH,BL,BH,CL,CH,DL,DH:Byte);
          False : (AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags:Integer)
        END;  *)
    VAR Regs : Registers;
    BEGIN
      Regs.AH := $2C;
      msDos(Regs);
      Secs := Secs_PER_HOUR*(Regs.CH)
                +Secs_PER_MINUTE*(Regs.CL)
                +Regs.DH
                +0.01*Regs.DL;
    END;

{ BODY OF WAIT procedure}

  BEGIN
    ReadClock(StartingSecs);
    REPEAT                                  { allow break out }
      if KeyPressed then begin
                           ch := ReadKey;   { eat the key }
                           Halt;
                         end;
      ReadClock(Secs);
      IF Secs-StartingSecs >= 0.0 THEN {Normal situation.}
        TimeIsUp := Secs-StartingSecs >= NumberOfSecs
      ELSE {During call, clock has ticked past midnight.}
        TimeIsUp := Secs_PER_DAY-StartingSecs+Secs >= NumberOfSecs
    UNTIL TimeIsUp
  END;


{  M _ A _ I _ N  }

  begin

    p_cnt := paramcount;
    if p_cnt = 0 then begin
      writeln('WAIT - a utility to wait a set number of seconds.');
      writeln('     - Is machine speed independent because it uses dos int 21h, function $2C.');
      writeln('     - can wait up to a whole day with a count of 86400.');
      writeln('     - can be interupted at any time by pressing a keyboard key.');
      writeln('     - needs a command line argument of number of seconds to wait.');
      writeln('     - IE. "wait 300" would wait for 5 minutes and then continue.');
      halt;
    end else begin
      s := paramstr(1);
      okay := false;
      okay := Str2Real(s, sr);
      if okay then begin
        writeln('WAIT - is now running for ', s ,' seconds.');
        wait(sr);
      end else
        writeln('WAIT - could not run because the parameter was invalid.');
    end;

  end.


