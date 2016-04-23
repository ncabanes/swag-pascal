{
From: edwin@mavetju.iaehv.nl (Edwin Groothuis)

> Anybody know the structure to FrontDoor's INBOUND.HIS and
> OUTBOUND.HIS files? Thanks..
}

program   MailHistory;
uses      crt,dos;

TYPE
  MailHistRec = RECORD
    Year,                        (* 1990 - xxxx *)
    Month,                       (* 1 - 12 *)
    Day,                         (* 1 - 31 *)
    Hour,                        (* 0 - 23 *)
    Minute,                      (* 0 - 59 *)
    Second,                      (* 0 - 59 *)
    Zone,
    Net,
    Node,
    Point     : word;
    SystemName: string[30];
    Location  : string[38];
    TimeOnLine: word;            (* Seconds spent on-line *)
    RcvdBytes,
    SentBytes : longint;
    Cost      : word;
  End;

var       fin:file of mailhistrec;
          fout:text;
          hist:mailhistrec;
          rcvd,send:longint;

begin
  assign(fout,paramstr(1));rewrite(fout);
  assign(fin,'outbound.his');{$I-}reset(fin);{$I+}
  if ioresult=0 then
  begin
    read(fin,hist);
    if not eof(fin) then
    begin
      writeln(fout,'OUTBOUND   | nodenumber              | rcvd    | send   
|');

writeln(fout,'-----------+-------------------------+---------+---------+');
      rcvd:=0;send:=0;
      while not eof(fin) do
      begin
        read(fin,hist);
        with hist do
        begin
          writeln(fout,day:2,'/',month:2,'/',year:2,' |
',zone:5,':',net:5,'/',node:5,'.',point:5,' | ',
                  rcvdbytes:7,' | ',sentbytes:7,' |');
          inc(rcvd,rcvdbytes);inc(send,sentbytes);
        end;
      end;
     
writeln(fout,'-----------+-------------------------+---------+---------+');
      writeln(fout,'                                     | ',rcvd:7,' |
',send:7,' |');
      writeln(fout,' ');
    end;
  end;
  close(fin);


  assign(fin,'inbound.his');{$I-}reset(fin);{$I+}
  if ioresult=0 then
  begin
    read(fin,hist);
    if not eof(fin) then
    begin
      writeln(fout,'INBOUND    | nodenumber              | rcvd    | send   
|');
     
writeln(fout,'-----------+-------------------------+---------+---------+');
      rcvd:=0;send:=0;
      while not eof(fin) do
      begin
        read(fin,hist);
        with hist do
        begin
          writeln(fout,day:2,'/',month:2,'/',year:2,' |
',zone:5,':',net:5,'/',node:5,'.',point:5,' | ',
                  rcvdbytes:7,' | ',sentbytes:7,' |');
          inc(rcvd,rcvdbytes);inc(send,sentbytes);
        end;
      end;
     
writeln(fout,'-----------+-------------------------+---------+---------+');
      writeln(fout,'                                     | ',rcvd:7,' |
',send:7,' |');
      writeln(fout,' ');
    end;
  end;
  close(fin);
  close(fout);
end.
