(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0175.PAS
  Description: Creating a Log Diary
  Author: HARRY MARX
  Date: 05-31-96  09:16
*)

{
I wrote a similar little program, to register who are using a particular
program on the network. I think you can get the same done using a
simple batch file system - since this is only for statistical information.
I would use the following batch commands in STUDENT.BAT:
LOGIN %1
REGISTER H:\wherever\LOG.REG %1

It assumes your login script makes an enviroment variable called
NAME=usersname
But used like above it doen't matter.
Call STUDENT.BAT with
STUDENT studentloginname

All that register.exe needs to do is to take it's parameter, add a date and
time stamp (GetDate & GetTime) and writeln everything to a text file.

Yes, there is no protection again normal, unregistered logins, but then that
is not what you asked for?
BTW, I edited it a bit in the mailer - there may be a sintax error...

Cheers,
Harry.
* }
{------------------------------------------------------------------------}
program Register;
{   Used to register users of a program. }
uses Dos;
var
   F:text;
   FN,Remark:string;
   YY,MM,DD,DOW,H,M,S,ss,Retry:word;

function D0(i:word):string;
   var S:string;
   begin
      str(I,S);
      if length(S)=1 then S:='0'+S;
      D0:=S;
   end;

begin
   if ParamCount<1 then begin
      writeln('Use: REGISTER  path\filename.REG  remark');
      writeln('   where path\file.REG is a text file where the user will be logged.');
      writeln('   The user must have read/write access to this path.');
      writeln('   The remark can be anything, ex.: "logging_in" or "logging_out"');
   end else begin
      FN:=ParamStr(1);
      if ParamCount>=2 then Remark:=paramstr(2) else Remark:='';
      if copy(FN,length(FN)-3,4)<>'.REG' then
         writeln('Invalid log file: ',FN)
      else begin
         assign(F,ParamStr(1));
         {$I-}
         if FSearch(ParamStr(1),'')<>ParamStr(1) then rewrite(F);
         retry:=255;
         repeat append(F); dec(retry); until (retry=0) or (IOResult=0);
         {This is only for if the program tries to register two users at
          the same time}
         if IOResult<>0 then begin
            writeln('Log file not found/accesable.');
            halt;
         end;
         {$I+}
         GetDate(YY,MM,DD,DOW);
         GetTime(H,M,S,ss);
         writeln(F,D0(YY),'/',D0(MM),'/',D0(DD),', ',
                   D0(H),'h',D0(M),':',D0(S),',  ',
                   GetEnv('NAME'),',  ',Remark);
         close(F);
      end;
   end;
end.
