{
This code has been slightly shrunk to fit into one message.
}

Program input;
Uses
  Dos, Crt;

Const
  Word_wrap = 50;

Var
  tick,
  mlines  : Integer;
  modem   : String[1];
  incom,
  waiting : String[128];

Procedure outread(avr1, avr2, avr3 : Integer);

Var                      { avr1= 1=passWord, 2=normal                   }
  i,y,o,                 { avr2= 1=none, 2=Word wrap                    }
  count:Integer;         { avr3= 1=pull from String, 2=none             }
  Word:String[10]; Charout:Char;

begin
  incom:=''; count:=0; mlines:=0;
  if avr3=2 then waiting:='';
  if avr3=1 then if waiting<>'' then
    begin
      incom:=waiting;
      waiting:='';
      Write(incom);
      count:=length(incom);
    end;
  modem:=''; TextColor(3);
  While modem<>chr(13) do
    begin
      Charout:=ReadKey; modem:=Charout;
      Case ord(modem[1]) of
        13:begin             { return }
             Writeln; Exit;
           end;
         8:begin             { backspace }
             if count>0 then
               begin
                 Write(chr(8)+chr(32)+chr(8));
                 delete(incom,count,1);
                 count:=count-1;
               end;
             modem:='';
           end;
         9:begin             { tab }
             Write('     '); incom:=incom+'     '; count:=count+5;
             modem:='';
           end;
        10:modem:='';        { line feed }
    1..26,
   28..31,
  128..255:begin             { inappropriate Characters }
             modem:='';
           end;
      end;
      if modem<>'' then
        begin
          count:=count+1;
          if count<Word_wrap then
            begin
              incom:=incom+modem;
              Case avr1 of
                1:Write('?');
                5:Write;
                else Write(modem);
              end;
            end else if avr2=2 then
              begin
                waiting:='';
                For i:=length(incom) DownTo 1 do
                  begin
                    Write(chr(8)+chr(32)+chr(8));
                    Word:=copy(incom,i,1);
                    if Word=chr(32) then
                      begin
                        waiting:=copy(incom,i+1,length(incom));
                        waiting:=waiting+modem;
                        delete(incom,i,length(incom)); Writeln; Exit;
                      end;
                   end;
              end;
        end;
    end; { waiting For modem to = chr(13) }
  if avr1 <> 5 then Writeln;
end; { end of Procedure }

begin
  ClrScr;
  TextColor(15);
  Write('This is a passWord input: ');
  outread(1,1,2);
  TextColor(11);
  Writeln('Return = ',incom);
  TextColor(15);
  Write('This is a normal input: ');
  outread(2,1,2);
  TextColor(11);
  Writeln('Return = ',incom);
  TextColor(15);
  Writeln('This is a controlled Word-wrap input at length 50:');
  Writeln;
  tick := 0;
  For tick := 1 to 5 do
    outread(2, 2, 1);
end.
