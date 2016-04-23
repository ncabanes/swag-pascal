Procedure TheDate(Var Date:String;Var doW:Integer);
 Var
  D,M,Y : Integer;
 begin
  GetDate(Y,M,D,doW);
  Date:=chr((M div 10)+48)+chr((M mod 10)+48)+'-'+chr((D div 10)+48+
        chr((D mod 10)+48)+'-'+chr(((Y mod 100) div 10)+48)+
        chr(((Y mod 100) mod 10)+48);
  if Date[1]='0' then Date[1]:=' ';
 end;
