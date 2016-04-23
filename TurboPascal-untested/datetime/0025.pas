{$R-,S+,I+,D+,T-,F-,V+,B-,N-,L+ }
{$M 16384,0,1024 }
program ifday;
{
***********************************************************************

IFDAY.PAS
8/18/93
by Bryan Valencia.

Shows use of the EXEC Command to run Command.com with a command line
taken from user entered parameters.

Include IFDAY in Batch Files to Run lines only on certain days.


***********************************************************************
}
uses DOS, CRT;
var
        y,m,d,dow:word;

procedure help;
begin
        textattr:=yellow;
        gotoxy(1,wherey); ClrEOL;
        Writeln('IFDAY by Bryan Valencia [71553,3102]');
        Writeln('SYNTAX');
        textattr:=lightgreen;
        Writeln('IFDAY [DAYOFWEEK,DAYNO] COMMAND');
        WRiteln('IFDAY 4 MIRROR c:  (if today is the 4th, mirror the C: drive).');
        WRiteln('IFDAY MON SD C: /Unfrag  (if today is Monday, run speed disk).');
        Halt;
end;

Procedure PerformCommand;
var
        s:string;
        t:byte;
Begin
        s:='';
        for t:=2 to paramcount do s:=s+paramstr(t)+' ';
        Writeln(s);
        Exec('c:\Command.Com','/c '+s);
        Halt;
end;

Function Checknum(i:integer):boolean;
var
        y,m,d,dow:word;
begin
        Getdate(y,m,d,dow);
        if i=d then Checknum:=true else Checknum:=False;
end;
Function CheckDay(S:String):boolean;
var
        y,m,d,dow:word;
        ss:string[3];
begin
        Getdate(y,m,d,dow);
        Case dow of
                0:SS:='SU';
                1:SS:='MO';
                2:SS:='TU';
                3:SS:='WE';
                4:SS:='TH';
                5:SS:='FR';
                6:SS:='SA';
        end;
        if S=SS then CheckDay:=true else CheckDay:=False;
end;


Procedure GO;
var
        s:string[2];
        v,t:byte;
        e:integer;

Begin
        s:=paramstr(1);
        for t:=1 to 2 do s[t]:=upcase(s[t]);
        Val(s,v,e);
        if e=0 then if Checknum(v) then PerformCommand;
        if e<>0 then if CheckDay(S) then PerformCommand;
end;

Begin
        if paramcount<2 then help else GO;
End.