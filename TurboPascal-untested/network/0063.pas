{
This is a quick little program that will listen for and then
display an IPX packet.


Ken Johnson Jan. 30th 1997

}


uses crt,kjipx;
var
  ecb:tecb;
  d:datagramrec;
  ipx:tipxheader;

procedure showpacket;
var x : Integer;
  begin
    clrscr;
    with ecb do
      begin
        writeln('Link:    ESR: ');
        Writeln('Inuse flag: ',Inuse,' Code: ',Code);
        Writeln('Socket #: ',SocketNUM);
        Writeln('# of fragments ',FragCount);
      end;
     writeln;writeln;
     For X := 1 to Sizeof(D) DO write(Chr(D[x]));
  end;


procedure main;
var done:boolean;
  begin
    Done:=false;
    repeat
      fillchar(d,sizeof(D),0);
      setuplistenecb(ecb,ipx,D);
      kjipx.listenforpacket(ecb);
      repeat
        relinquishcontrol;
      until (ecb.inuse = 00) or (keypressed);
      showpacket;
    until keypressed;
  end;

begin
  if not (ipxinstalled) then
    begin
      writeln('IPX not installed');
      halt(1);
    end;
  textcolor(7);textbackground(0);
  clrscr;
  OpenSocket(ListenSocket);
  Main;
  CloseSocket(ListenSocket);
end.