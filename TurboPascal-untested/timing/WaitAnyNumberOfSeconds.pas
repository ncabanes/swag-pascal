(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0025.PAS
  Description: WAIT any number of seconds
  Author: MICHAEL HOENIE
  Date: 11-26-94  05:04
*)

{
Here is a copy of a little program I wrote called WAIT.PAS. It will wait
for however number of seconds you wish. Good for BBS batch files & what
not.
}
  program wait; uses dos, crt;

  var out1,out,time1,time2,time3,date1,date2,date3:string[50];

   procedure timedate;
   var
     ax1,ax2,ax3,ax4:word;
     year,month,mil,day,dayofweek,hour,minute,second:string[20];
   begin
     time1:=''; { 22:00:00 }
     date1:=''; { 03/03/88 }
     time2:=''; { 02:03am  }
     date2:=''; { wednesday, january 25th, 1988 }
     gettime(ax1,{ hour } ax2,{ minute } ax3, { second }ax4);
     str(ax1,hour); str(ax2,minute); str(ax3,second);
     if length(minute)=1 then insert('0',minute,1);
     if length(second)=1 then insert('0',second,1);
     if length(hour)=1 then insert('0',hour,1);
     time1:=hour+':'+minute+':'+second;
     getdate(ax1, { year  }ax2, { month }ax3, { day }ax4);{ day of week }
     str(ax3,day); if length(day)=1 then insert('0',day,1);
     str(ax1,year); str(ax2,month);
     if length(month)=1 then insert('0',month,1);
     date1:=month+'-'+day+'-'+copy(year,3,2);
   end;

  procedure pause(secs:integer);
  var
    zit:boolean; zeek:string[15]; x9,y1:integer;
  begin
    textcolor(12);
    x9:=0;
    zit:=false;
    timedate;
    zeek:=time1;
    while not zit do
      begin
        timedate;
        if zeek<>time1 then
          begin
            zeek:=time1;
            x9:=x9+1;
            str(x9,out1);
            write(x9);
            for y1:=1 to length(out1) do write('');
          end;
        if keypressed then
          begin
            writeln;
            writeln;
            textcolor(3);
            writeln('Aborted!');
            halt;
          end;
        if x9>=secs then zit:=true;
      end;
  end;

  var
    code,xint:integer;
  begin
    writeln;
    textcolor(15);
    writeln('WAIT v1.2 - a batch file wait program.');
    textcolor(11);
    writeln;
    if paramstr(1)='' then
      begin
        write('Usage: wait <seconds> (example: "wait 2" for ');
        writeln('a 2 second delay.');
        halt;
      end;
    xint:=0;
    out:=paramstr(1);
    val(out,xint,code);
    write('Waiting ',xint,' seconds... (',xint div 60,' min.) --> ');
    pause(xint);
    writeln;
    textcolor(3);
    writeln('Done!');
  end.

