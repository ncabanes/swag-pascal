(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0006.PAS
  Description: DATE5.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)
uses dos;

Procedure TheDate(Var Date:String;Var doW:Word);
 Var
  D,M,Y : Word;
 begin
  GetDate(Y,M,D,doW);
  Date:=chr((M div 10)+48)+ chr((M mod 10)+48)
        +'-'
        +chr((D div 10)+48)+ chr((D mod 10)+48)
        +'-'
        +chr(((Y mod 100) div 10)+48)+ chr(((Y mod 100) mod 10)+48);
  if Date[1]='0' then Date[1]:=' ';
 end;

var
    currentDate: string;
    dayOfWeek: word;
begin
    TheDate(currentDate, dayOfWeek);
    writeLn('Date: ', currentDate);
    writeLn('Day of the week: ', dayOfWeek);
end.
