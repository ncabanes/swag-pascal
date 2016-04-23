{
This is a simple IPX demonstration that will send out
broadcast packets.

Ken Johnson Jan. 30th 1997
}

uses crt,kjipx;

var
  ecb:tecb;
  d:datagramrec;
  ipx:tipxheader;

procedure main;
var s:string;
  begin
    fillchar(d,sizeof(D),0);
    S:='This is sending broadcast packets';
    Move(S,D,Ord(s[0])+1);
    repeat
      setupIPXhead(0,ipx);
      setupecb(0,ecb,ipx,D);{if connection is 0 then send}
      kjipx.Sendpacket(ecb);{broadcast packets}
      repeat
        relinquishcontrol;
      until (ecb.inuse = 00) or (keypressed);
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