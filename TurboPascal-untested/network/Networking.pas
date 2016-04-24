(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0027.PAS
  Description: Networking
  Author: MICHAEL HOENIE
  Date: 08-25-94  09:09
*)

{
I'm still looking for help with these networking routines. I've revised
them again to make a full standing unit. This NETWORK unit will compile
stand-alone with TP 6.0. I still get an error 162 when using these
routines, which from the manual says MACHINE FAILURE or hardware. I have
run it on at least 10 different machines and get the same problem.

If *ANYONE* has a better way of keeping another node from accessing a
file, please, PLEASE let me know! I have an ENTIRE project (10,000+
lines) on hold until I get these networking routines done.
}
  UNIT NETWORK;

  interface uses dos;

  const
    max_timeout=10; { seconds to time out on network timeout }
    max_nodes=25;

  type
    string80=string[80];
    networkrecord=record { basic makeup of the actual user }
      x_username:string[5];           { network name of user }
      x_active:boolean;               { * IMPORTANT * : if node is active }
    end;

  var
    netfile:file of networkrecord;
    netdata:networkrecord;
    network_node:integer;
    time1,time2,time3,date1,date2,date3:string[15];
    incom,incom1,out,out1:string[255];
    _retval:integer;
    _retbol:boolean;

    function  network_exist(filename1:string80):byte;
    procedure node_status(filename1:string80);
    procedure lock_file(filename2:string80);
    procedure unlock_file(filename3:string80);
    procedure make_nodes;
    procedure update_node;
    procedure log_node;
    procedure log_off_node;

  implementation

(*═════════════════════════════════════════════════════════════════════════*)

   procedure timedate;
   var
     ax1,ax2,ax3,ax4:word;
     year,month,mil,day,hour,hour1,minute,second:string[20];
   begin
     time1:=''; { 22:00:00 }
     date1:=''; { 03/03/88 }
     time2:=''; { 02:03am  }
     time3:=''; { 00:00 }
     date2:=''; { wednesday, january 25th, 1988 }
     gettime(ax1,{ hour } ax2,{ minute } ax3, { second }ax4); { milli-second }
     str(ax1,hour);
     if ax1<=12 then str(ax1,hour1) else str(ax1-12,hour1);
     if length(hour1)=1 then insert('0',hour1,1);
     str(ax2,minute);
     str(ax3,second);
     if length(minute)=1 then insert('0',minute,1);
     if length(second)=1 then insert('0',second,1);
     if length(hour)=1 then insert('0',hour,1);
     time1:=hour+':'+minute+':'+second;
     case ax1 of
       0..11:out1:='AM'
         else out1:='PM';
     end;
     time2:=hour1+':'+minute+' '+out1;
     time3:=hour1+':'+minute;
     getdate(ax1, { year  }ax2, { month }ax3, { day }ax4);{ day of week }
     str(ax3,day);
     if length(day)=1 then insert('0',day,1);
     str(ax1,year);
     str(ax2,month);
     if length(month)=1 then insert('0',month,1);
     date1:=month+'-'+day+'-'+copy(year,3,2);
   end;

(*═════════════════════════════════════════════════════════════════════════*)

    function network_exist(filename1:string80):byte;
    var
      net_file:file;
    begin
      network_exist:=$0;
      assign(net_file,filename1);
      {$i-} reset(net_file) {$i+};
      case ioresult of
        0:close(net_file);
        1:network_exist:=$1; { nothing }
        2:network_exist:=$2; { file not found }
        5:network_exist:=$5; { access denied }
      end;
    end;

(*═════════════════════════════════════════════════════════════════════════*)

    procedure node_status(filename1:string80);
    var
      do_wait:boolean;
      s_time,c_time:string[2];
      d_timeout,d_wait,d_count:integer;
      _retbyte:byte;
      erfile:text;
    begin
      filename1:=filename1+'.lck';
      do_wait:=false;
      timedate;
      s_time:=copy(time1,7,2);
      d_wait:=0;
      d_timeout:=0;
      while not do_wait do
        begin
          _retbyte:=network_exist('LOCK\'+filename1);
          case _retbyte of
            $0:write('.');
            $5:write('.');
            $1:do_wait:=true;
            $2:do_wait:=true;
          end;
          if do_wait=true then d_timeout:=0;
          timedate;
          c_time:=copy(time1,7,2);
          if c_time<>s_time then
            begin
              s_time:=c_time;
              d_count:=d_count+1;
              d_timeout:=d_timeout+1;
            end;
          if d_timeout>max_timeout then
            begin
              writeln('NETWORK TIMEOUT...   NOTE_STATUS');
              halt;
            end;
        end;
    end;

(*═════════════════════════════════════════════════════════════════════════*)

    procedure lock_file(filename2:string80);
    var
      fvar2:text;
    begin
      if pos('.',filename2)>0 then
        delete(filename2,pos('.',filename2),length(filename2));
      filename2:=filename2+'.LCK';
      node_status(filename2);
      assign(fvar2,'LOCK\'+filename2);
      rewrite(fvar2);
      write(fvar2,'A');
      close(fvar2);
    end;

(*═════════════════════════════════════════════════════════════════════════*)

    procedure unlock_file(filename3:string80);
    var
      fvar3:text;
    begin
      if pos('.',filename3)>0 then
        delete(filename3,pos('.',filename3),length(filename3));
      filename3:=filename3+'.LCK';
      if network_exist('LOCK\'+filename3)=$0 then
        begin
          assign(fvar3,'LOCK\'+filename3);
          erase(fvar3);
        end;
    end;

(*═════════════════════════════════════════════════════════════════════════*)

    procedure make_nodes;
    begin
      case network_exist('LOCK\'+'NETWORK.SYS') of
        $2:begin
             lock_file('NETWORK');
             assign(netfile,'LOCK\'+'NETWORK.SYS');
             rewrite(netfile);
             netdata.x_username:='';
             netdata.x_active:=false;
             for _retval:=0 to max_nodes do
               begin
                 seek(netfile,_retval);
                 write(netfile,netdata);
               end;
             close(netfile);
             unlock_file('NETWORK');
           end;
      end;
    end;

(*═════════════════════════════════════════════════════════════════════════*)

    procedure update_node;
    begin
      with netdata do
        begin
          x_username:='MSH';
          x_active:=true;
        end;
      lock_file('NETWORK');
      assign(netfile,'LOCK\'+'NETWORK.SYS');
      {$i-} reset(netfile); {$i+}
      if ioresult>=1 then
        begin
          writeln('NETWORK ERROR: UPDATE_NODE');
          halt;
        end;
      seek(netfile,network_node);
      write(netfile,netdata);
      close(netfile);
      unlock_file('NETWORK');
    end;

(*═════════════════════════════════════════════════════════════════════════*)

    procedure log_node;
    begin
      network_node:=-1;
      lock_file('NETWORK');
      assign(netfile,'LOCK\'+'NETWORK.SYS');
      {$i-} reset(netfile) {$i+};
      if ioresult>=1 then
        begin
          writeln('NETWORK ERROR: LOG_NODE');
          halt;
        end;
      for _retval:=filesize(netfile)-1 downto 0 do
        begin
          seek(netfile,_retval);
          {$i-} read(netfile,netdata); {$i+}
          if ioresult>=1 then
            begin
              writeln('NETWORK ERROR: LOG_NODE');
              halt;
            end;
          if NOT netdata.x_active then network_node:=_retval;
        end;
      if network_node=-1 then
        begin
          writeln('NETWORK ERROR: LOG_NODE');
          halt;
        end;
      seek(netfile,network_node);
      write(netfile,netdata);
      close(netfile);
      unlock_file('NETWORK');
    end;

(*═════════════════════════════════════════════════════════════════════════*)

    procedure log_off_node;
    begin
      lock_file('NETWORK');
      assign(netfile,'LOCK\'+'NETWORK.SYS');
      {$i-} reset(netfile) {$i+};
      if ioresult>=1 then
        begin
          writeln('NETWORK ERROR: LOG_OFF_NODE');
          halt;
        end;
      netdata.x_username:='';
      netdata.x_active:=false;
      seek(netfile,network_node);
      write(netfile,netdata);
      close(netfile);
      unlock_file('NETWORK');
    end;

(*═════════════════════════════════════════════════════════════════════════*)

  END.

