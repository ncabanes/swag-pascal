{
RH>I am looking for source to catch someone who is debugging my program.

What do you think about this ...

I don't write it and sorry for the German, but it works OK.
Just include it into your included units, when someone tries to debug your
program, it reboots.
}

UNIT NoDebug;

{ ************************* }
{ Aus c't 2/90 Seite 186    }
{ (c) by Karl Heinz Kremer  }
{ ************************* }

INTERFACE

{ Hier gibt's nichts zu exportieren }

IMPLEMENTATION

USES DOS,CRT;

VAR
  OldInt1, OldInt3,        { Die alten Interruptvektoren }
  ExitSave : POINTER;      { Speicher für die alte Exit-Prozedur }


PROCEDURE REBOOT;
BEGIN
  Inline($b8/$00/$f0/
         $50/
         $b8/$5b/$e0/
         $50/
         $b8/$40/$00/
         $8e/$d8/
         $c7/$06/$72/$00/$34/$12/$cb);
END;

PROCEDURE DoNotDebug; INTERRUPT;       { neue Int1 und Int3 Prozedur }
BEGIN
  reboot;
END;

{$F+}
PROCEDURE ResetNoDebug;
{$F-}
BEGIN                           { Neue Exit-Prozedur }
  SetIntVec(1,OldInt1);         { Interruptvektoren zurücksetzen }
  SetIntVec(3,OldInt3);
  ExitProc:=ExitSave;           { Zeiger auf alte Exit-Prozedur }
END;

BEGIN
  ExitSave:=ExitProc;           { alte Exit Prozedur speichern }
  ExitProc:=@ResetNoDebug;      { neue Exit Prozedur setzen }
  GetIntVec(1,OldInt1);         { Int-Vektoren speichern }
  GetIntVec(3,OldInt3);
  SetIntVec(3,@DoNotdebug);     { Int-Vektoren neu setzen }
  SetIntVec(1,@DoNotdebug);
END.
