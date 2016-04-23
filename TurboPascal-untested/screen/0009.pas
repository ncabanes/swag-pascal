Uses
  Crt;

Procedure ScrollTextLine (x1, x2 : Integer ; y : Integer ; St : String) ;
begin
  While Length(St)<(x2-x1+1) Do
    St:=St+' ' ;
  While not KeyPressed Do
    begin
      GotoXY(x1, y) ;
      Write(Copy(St, 1, x2-x1+1)) ;
      Delay(100) ;
      St:=Copy(St, 2, Length(St)-1)+St[1] ;
    end ;
end ;

begin
  ClrScr;
  TextColor(lightgreen);
  scrollTextline(10,60,12,'Hello There!');
end.