{
 JB> myself as a test and it wouldn't  detect ANSI for me either.  So I
 JB> tried that other SWAG method of just spewing the #27[6n out and waiting
 JB> for the code to return and trap it using a  keypressed type of thing,
 JB> but that failed.  All I saw was the raw ESC[6n on the screen itself

It works here! Try this tested code. }


USES  Dos;
VAR
   reg : registers;
   ANSI: Boolean;

PROCEDURE ClearBuffer;
begin
repeat
   reg.ah := $6;                            { flush keyboard buffer }
   reg.dl := $ff;
   intr($21,reg)
until reg.flags and fzero <> 0;
end;

Procedure Help;
begin
writeln;
writeln(' ANSIHERE    - Check to see if ANSI is loaded and display message.
');writeln('               Exit with errorlevel = 1 if ANSI is loaded, 0 if
not. ');writeln;
writeln(' SYNTAX:     - ANSIHERE [S] ');
writeln('               The ''S'' parameter will suppress output of the status
');writeln('               message when ANSIHERE is used in batch files. ');
writeln;
writeln(' This program checks for ANSI by writing the ANSI Device Status
Report ');writeln(' (DSR) sequence to the display.  If ANSI is loaded, it will
output a ');writeln(' Cursor Position Report (CPR) to the standard input
device (the keyboard). ');writeln(' Therefore, if you issue a DSR and find
anything in the keyboard buffer, ');writeln(' you can assume it''s a CPR and
that ANSI is loaded.  Conversely, if the ');writeln(' keyboard buffer is
empty, then ANSI is not loaded. ');writeln;
end;

FUNCTION UpString(S:String):String;
var                                         
  Index:byte;
begin
  For Index:=1 to Length(S) do
    S[index]:=UpCase(S[Index]);
  UpString:=S;
end; { UpString }

begin
if (ParamStr(1) = '/?') or (ParamStr(1) = '-?') then Help;
clearbuffer;
write(#27,'[6n');                         {ask ANSI for cursor report}
reg.ah :=$b;                              {check for char in keyboard buffer}
intr($21,reg);
if reg.al = $ff then ANSI := True else ANSI := False;
clearbuffer;
write(#13,#32,#32,#32,#32,#13);               { errase screen }

if (UpString(ParamStr(1)) <> 'S') and (ANSI = True) then
     writeln(' ANSIHERE');                 { if al= FFh then yes, al = 0  no}
if (UpString(ParamStr(1)) <> 'S') and (ANSI = False) then
   writeln(' ANSI not here ');

if ANSI then Halt(1);
end.
