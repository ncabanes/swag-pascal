{
-> I'm having alot of trouble trying to stop people breaking out of my
-> programs.  I've been trying to figure out how to stop the
-> <ctrl>-<break>, <ctrl>-<c> , but with no luck...  Can't seem to find
-> anything in the help menu's....
-> ---

If you are using CRT, use CHECKBREAK:=FALSE.  Also, you can disble it
permenantly like this:
}
Program TTXBREAK_Which_Means_TobinTech_ControlBreak_Disabler_Program;


Uses DOS,CRT;

{$M 2000,0,0}
{$R-,S-,I-,F+,V-,B-}

Const ControlCInt=$23;
      ControlBreakInt=$1B;


Var
 OldControlCVec:Pointer;
 OldControlBreakVec:Pointer;

Procedure STI;
Inline($FB);

Procedure CLI;
Inline($FA);

Procedure CallOldInt(Sub:Pointer);
begin
 Inline($9C/                    { PUSHF }
        $FF/$5E/$06);
end;

Procedure BlockInterrupt; Interrupt;
 {BlockInterrupt is a generic procedure for blocking an interrupt}
begin
 STI;
end;


begin
 Writeln('TobinTech Control-C disable program            ');
 GetIntVec(ControlCInt, OldControlCVec);
 SetIntVec(ControlCInt, @BlockInterrupt);
 Writeln(' > CONTROL-C disabled.                         ');
 GetIntVec(ControlBreakInt, OldControlBreakVec);
 SetIntVec(ControlBreakInt, @BlockInterrupt);
 Writeln(' > CONTROL-BREAK disabled.                     ');
 Writeln(' Terminating, but Staying Resident in memory...');
 Keep(0);
End.
