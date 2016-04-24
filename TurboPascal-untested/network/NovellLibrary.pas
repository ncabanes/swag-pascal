(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0021.PAS
  Description: NOVELL Library
  Author: MARK BRAMWELL
  Date: 05-26-94  06:20
*)


UNIT Novell;
{---------------------------------------------------------------------------}
{                                                                           }
{  This UNIT provides a method of obtaining Novell information from a user  }
{  written program.  This UNIT was tested on an IBM AT running DOS 5.0 &    }
{  using Netware 2.15.  The unit compiled cleanly under Turbo Pascal 6.0    }
{                                                                           }
{  The UNIT has been updated to compile and run under Turbo Pascal for      }
{  Windows.                                                                 }
{                                                                           }
{  *** Tested ok with Netware 386 3.11  Sept/91                             }
{                                                                           }
{  Last Update:   11 Dec 91                                                 }
{                                                                           }
{---------------------------------------------------------------------------}
{                                                                           }
{  Any questions can be directed to:                                        }
{                                                                           }
{  Mark Bramwell                                                            }
{  University of Western Ontario                                            }
{  London, Ontario, N6A 3K7                                                 }
{                                                                           }
{  Phone:  519-473-3618 [work]              519-473-3618 [home]             }
{                                                                           }
{  Bitnet: mark@hamster.business.uwo.ca     Packet: ve3pzr @ ve3gyq         }
{                                                                           }
{  Anonymous FTP Server Internet Address: 129.100.22.100                    }
{                                                                           }
{---------------------------------------------------------------------------}

{ Any other Novell UNITS gladly accepted. }


{
mods February 1 1991, Ross Lazarus (rml@extro.ucc.su.AU.OZ)
     var retcodes in procedure getservername, get_broadcast_message,
     verify_object_password comments, password conversion to upper case,

Seems to work fine on a Netware 3.00 and on 3.01 servers -
}


INTERFACE

{$IFDEF WINDOWS}
Uses WinDos;
{$ENDIF WINDOWS}

{$IFNDEF WINDOWS}
Uses Dos;
{$ENDIF WINDOWS}

Const
  Months : Array [1..12] of String[3] = ('JAN','FEB','MAR','APR','MAY','JUN',
                                         'JUL','AUG','SEP','OCT','NOV','DEC');

  HEXDIGITS : Array [0..15] of char = '0123456789ABCDEF';

Type    byte4 = array [1..4] of byte;

        byte6 = array [1..6] of byte;

VAR

{----------------------------------------------------------------------}
{  The following values can be pulled from an user written application }
{                                                                      }
{  The programmer would first call   GetServerInfo.                    }
{  Then he could   writeln(serverinfo.name)   to print the server name }
{----------------------------------------------------------------------}

      ServerInfo    : Record
                     ReturnLength    : Integer;
                     Server          : Packed Array [1..48] of Byte;
                     NetwareVers     : Byte;
                     NetwareSubV     : Byte;
                     ConnectionMax   : array [1..2] of byte;
                     ConnectionUse   : array [1..2] of byte;
                     MaxConVol       : array [1..2] of byte; {}
                     OS_revision     : byte;
                     SFT_level       : byte;
                     TTS_level       : byte;
                     peak_used       : array [1..2] of byte;
                  accounting_version : byte;
                     vap_version     : byte;
                     queuing_version : byte;
                print_server_version : byte;
             virtual_console_version : byte;
       security_restrictions_version : byte;
        Internetwork_version_version : byte;
                        Undefined    : Packed Array [1..60] of Byte;
               peak_connections_used : integer;
                     Connections_max : integer;
                  Connections_in_use : integer;
               Max_connected_volumes : integer;
                                name : string;
                   End;


procedure get_server_lan_driver_information(var _lan_board_number : integer;
{ This will return info on what }           var _text1,_text2:string;
{ type of network cards are being }         var _network_address : byte4;
{ used in the server. }                     var _host_address : byte6;
                                            var _driver_installed,
                                                _option_number,
                                                _retcode : integer);

procedure GetConnectionInfo(var LogicalStationNo: integer;
                            var name,hex_id:string;
                            var conntype:integer;
                            var datetime:string;
                            var retcode:integer);
{ returns username and login date/time when you supply the station number. }

procedure clear_connection(connection_number : integer; var retcode :
integer);
{ kicks the workstation off the server}

procedure GetHexID(var userid,hexid: string;
                   var retcode: integer);
{ returns the novell hexid of an username when you supply the username. }

procedure GetServerInfo;
{ returns various info of the default server }

procedure GetUser( var _station: integer;
                   var _username: string;
                   var retcode:integer);
{ returns logged-in station username when you supply the station number. }

procedure GetNode( var hex_addr: string;
                   var retcode: integer);
{ returns your physical network node in hex. }

procedure GetStation( var _station: integer;
                      var retcode: integer);
{ returns the station number of your workstation }

procedure GetServerName(var servername : string;
                        var retcode : integer);

{ returns the name of the current server }

procedure Send_Message_to_Username(username,message : string;
                                   var retcode: integer);
{ Sends a novell message to the userid's workstation }

procedure Send_Message_to_Station(station:integer;
                                  message : string;
                                  var retcode: integer);
{ Sends a message to the workstation station # }

procedure Get_Volume_Name(var volume_name: string;
                          volume_number: integer;
                          var retcode:integer);
{ Gets the Volume name from Novell network drive }
{ Example:  SYS    Note: default drive must be a }
{ network drive.                                 }

procedure get_realname(var userid:string;
                       var realname:string;
                       var retcode:integer);
{ You supply the userid, and it returns the realname as stored by syscon. }
{ Example:  userid=mbramwel   realname=Mark Bramwell }

procedure get_broadcast_mode(var bmode:integer);

procedure set_broadcast_mode(bmode:integer);

procedure get_broadcast_message(var bmessage: string;
                                var retcode : integer);

procedure get_server_datetime(var _year,_month,_day,_hour,_min,_sec,_dow:integer);
{ pulls from the server the date, time and Day Of Week }

procedure set_date_from_server;
{ pulls the date from the server and updates the workstation's clock }

procedure set_time_from_server;
{ pulls the time from the server and updates the workstation's clock }

procedure get_server_version(var _version : string);

procedure open_message_pipe(var _connection, retcode : integer);

procedure close_message_pipe(var _connection, retcode : integer);

procedure check_message_pipe(var _connection, retcode : integer);

procedure send_personal_message(var _connection : integer; var _message :
string; var retcode : integer);

procedure get_personal_message(var _connection : integer; var _message :
string; var retcode : integer);

procedure get_drive_connection_id(var drive_number,
                                  server_number : integer);
{pass the drive number - it returns the server number if a network volume}

procedure get_file_server_name(var server_number : integer;
                               var server_name : string);

procedure get_directory_path(var handle : integer;
                             var pathname : string;
                             var retcode : integer);

procedure get_drive_handle_id(var drive_number, handle_number : integer);

procedure set_preferred_connection_id(server_num : integer);

procedure get_preferred_connection_id(var server_num : integer);

procedure set_primary_connection_id(server_num : integer);

procedure get_primary_connection_id(var server_num : integer);

procedure get_default_connection_id(var server_num : integer);

procedure Get_Internet_Address(station : integer;
                               var net_number, node_addr, socket_number :
string;
                               var retcode : integer);

procedure login_to_file_server(obj_type:integer; _name,_password : string;var
retcode:integer);

procedure logout;

procedure logout_from_file_server(var id: integer);

procedure down_file_server(flag:integer;var retcode : integer);

procedure detach_from_file_server(var id,retcode:integer);

procedure disable_file_server_login(var retcode : integer);

procedure enable_file_server_login(var retcode : integer);

procedure alloc_permanent_directory_handle(var _dir_handle : integer;
                                           var _drive_letter : string;
                                           var _dir_path_name : string;
                                           var _new_dir_handle : integer;
                                           var _effective_rights: byte;
                                           var _retcode : integer);

procedure map(var drive_spec:string;
              var _rights:byte;
              var _retcode : integer);

procedure scan_object(var last_object: longint;
                      var search_object_type: integer;
                      var search_object : string;
                      var replyid : longint;
                      var replytype : integer; var replyname : string;
                      var replyflag : integer; var replysecurity : byte;
                      var replyproperties : integer; var retcode : integer);

procedure verify_object_password(var object_type:integer; var
object_name,password : string; var retcode : integer);

{--------------------------------------------------------------------------}
{ file locking routines }
{-----------------------}

procedure log_file(lock_directive:integer; log_filename: string;
log_timeout:integer; var retcode:integer);

procedure clear_file_set;

procedure lock_file_set(lock_timeout:integer; var retcode:integer);

procedure release_file_set;

procedure release_file(log_filename: string; var retcode:integer);

procedure clear_file(log_filename: string; var retcode:integer);

{--------------------------------------------------------------------------
---}

procedure open_semaphore( _name:string;
                          _initial_value:shortint;
                          var _open_count:integer;
                          var _handle:longint;
                          var retcode:integer);

procedure close_semaphore(var _handle:longint; var retcode:integer);

procedure examine_semaphore(var _handle:longint; var _value:shortint; var
_count, retcode:integer);

procedure signal_semaphore(var _handle:longint; var retcode:integer);

procedure wait_on_semaphore(var _handle:longint; _timeout:integer; var
retcode:integer);

procedure purge_all_erased_files(var retcode:integer);

procedure purge_erased_files(var retcode:integer);
{--------------------------------------------------------------------------
---}


IMPLEMENTATION

const
     zero = '0';

var
   retcode : byte; { return code for all functions }

{$IFDEF WINDOWS}
  regs : TRegisters;   { Turbo Pascal for Windows }
{$ENDIF WINDOWS}

{$IFNDEF WINDOWS}
  regs : registers;    { Turbo Pascal for Dos }
{$ENDIF WINDOWS}

procedure get_volume_name(var volume_name: string; volume_number: integer;
                          var retcode:integer);
{
pulls volume names from default server.  Use set_preferred_connection_id to
set the default server.
retcodes:  0=ok, 1=no volume assigned  98h= # out of range
}

VAR
   count,count1  : integer;

   requestbuffer : record
      len        : integer;
      func       : byte;
      vol_num    : byte;
      end;

    replybuffer  : record
      len        : integer;
      vol_length : byte;
      name       : packed array [1..16] of byte;
      end;

begin
With Regs do
begin
  ah := $E2;
  ds := seg(requestbuffer);
  si := ofs(requestbuffer);
  es := seg(replybuffer);
  di := ofs(replybuffer);
 end;
 With requestbuffer do
 begin
  len  := 2;
  func := 6;
  vol_num := volume_number;  {passed from calling program}
 end;
 With replybuffer do
 begin
  len :=  17;
  vol_length := 0;
  for count := 1 to 16 do name[count] := $00;
 end;
 msdos(Regs);
 volume_name := '';
 if replybuffer.vol_length > 0 then
    for count := 1 to replybuffer.vol_length do
        volume_name := volume_name + chr(replybuffer.name[count]);
 retcode := Regs.al;
end;

procedure verify_object_password(var object_type:integer; var
object_name,password : string; var retcode : integer);
{
for netware 3.xx remember to have previously (eg in the autoexec file )
set allow unencrypted passwords = on
on the console, otherwise this call always fails !
Note that intruder lockout status is affected by this call !
Netware security isn't that stupid....
Passwords appear to need to be converted to upper case

retcode      apparent meaning as far as I can work out....

0            verification of object_name/password combination
197          account disabled due to intrusion lockout
214          unencrypted password calls not allowed on this v3+ server
252          no such object_name on this server
255          failure to verify object_name/password combination

}
var  request_buffer : record
      buffer_length : integer;
        subfunction : byte;
           obj_type : array [1..2] of byte;
    obj_name_length : byte;
           obj_name : array [1..47] of byte;
    password_length : byte;
       obj_password : array [1..127] of byte;
                end;

       reply_buffer : record
      buffer_length : integer;
                end;

              count : integer;

begin
     With request_buffer do
     begin
          buffer_length := 179;
          subfunction := $3F;
          obj_type[1] := 0;
          obj_type[2] := object_type;
          obj_name_length := 47;
          for count := 1 to 47 do
              obj_name[count] := $00;
          for count := 1 to length(object_name) do
          obj_name[count] := ord(object_name[count]);
          password_length := length(password);
          for count := 1 to 127 do
              obj_password[count] := $00;
          if password_length > 0 then
             for count := 1 to password_length do
                 obj_password[count] := ord(upcase(password[count]));
       end;
       With reply_buffer do
            buffer_length := 0;
       With regs do
       begin
            Ah := $E3;
            Ds := Seg(Request_Buffer);
            Si := Ofs(Request_Buffer);
            Es := Seg(Reply_Buffer);
            Di := Ofs(Reply_Buffer);
       End;
       msdos(regs);
       retcode := regs.al;
end; { verify_object_password }



procedure scan_object(var last_object: longint; var search_object_type:
integer;
                      var search_object : string; var replyid : longint;
                      var replytype : integer; var replyname : string;
                      var replyflag : integer; var replysecurity : byte;
                      var replyproperties : integer; var retcode : integer);
var
    request_buffer : record
     buffer_length : integer;
       subfunction : byte;
         last_seen : longint;
       search_type : array [1..2] of byte;
       name_length : byte;
       search_name : array [1..47] of byte;
               end;

      reply_buffer : record
     buffer_length : integer;
         object_id : longint;
       object_type : array [1..2] of byte;
       object_name : array [1..48] of byte;
       object_flag : byte;
          security : byte;
        properties : byte;
               end;

             count : integer;

begin
with request_buffer do
begin
 buffer_length := 55;
 subfunction := $37;
 last_seen := last_object;
 if search_object_type = -1 then { -1 = wildcard }
   begin
   search_type[1] := $ff;
   search_type[2] := $ff;
   end else
   begin
   search_type[1] := 0;
   search_type[2] := search_object_type;
   end;
name_length := length(search_object);
for count := 1 to 47 do search_name[count] := $00;
if name_length > 0 then for count := 1 to name_length do
   search_name[count] := ord(upcase(search_object[count]));
end;
With reply_buffer do
begin
 buffer_length := 57;
 object_id:= 0;
 object_type[1] := 0;
 object_type[2] := 0;
 for count := 1 to 48 do object_name[count] := $00;
 object_flag := 0;
 security := 0;
 properties := 0;
end;
With Regs Do Begin
 Ah := $E3;
 Ds := Seg(Request_Buffer);
 Si := Ofs(Request_Buffer);
 Es := Seg(Reply_Buffer);
 Di := Ofs(Reply_Buffer);
End;
msdos(regs);
retcode := regs.al;
With reply_buffer do
begin
 replyflag := object_flag;
 replyproperties := properties;
 replysecurity := security;
 replytype := object_type[2];
 replyid := object_id;
end;
count := 1;
replyname := '';
While (count <= 48)  and (reply_buffer.Object_Name[count] <> 0) Do Begin
    replyName := replyname + Chr(reply_buffer.Object_name[count]);
    count := count + 1;
    End { while };
end;


procedure alloc_permanent_directory_handle
  (var _dir_handle : integer; var _drive_letter : string;
   var _dir_path_name : string; var _new_dir_handle : integer;
   var _effective_rights: byte; var _retcode : integer);

var request_buffer : record
     buffer_length : integer;
       subfunction : byte;
        dir_handle : byte;
      drive_letter : byte;
   dir_path_length : byte;
     dir_path_name : packed array [1..255] of byte;
               end;

      reply_buffer : record
     buffer_length : integer;
    new_dir_handle : byte;
  effective_rights : byte;
               end;

  count : integer;

begin
With request_buffer do
begin
 buffer_length := 259;
 subfunction := $12;
 dir_handle := _dir_handle;
 drive_letter := ord(upcase(_drive_letter[1]));
 dir_path_length := length(_dir_path_name);
 for count := 1 to 255 do dir_path_name[count] := $0;
 if dir_path_length > 0 then for count := 1 to dir_path_length do
    dir_path_name[count] := ord(upcase(_dir_path_name[count]));
end;
With reply_buffer do
begin
 buffer_length := 2;
 new_dir_handle := 0;
 effective_rights := 0;
end;
With Regs Do Begin
 Ah := $E2;
 Ds := Seg(Request_Buffer);
 Si := Ofs(Request_Buffer);
 Es := Seg(Reply_Buffer);
 Di := Ofs(Reply_Buffer);
End;
msdos(regs);
_retcode := regs.al;
_effective_rights := $0;
_new_dir_handle := $0;
if _retcode = 0 then
begin
 _effective_rights := reply_buffer.effective_rights;
 _new_dir_handle := reply_buffer.new_dir_handle;
end;
end;

procedure map(var drive_spec:string; var _rights:byte; var _retcode :
integer);
var
    dir_handle : integer;
     path_name : string;
        rights : byte;
  drive_number : integer;
  drive_letter : string;
    new_handle : integer;
       retcode : integer;

begin
 {first thing is we strip leading and trailing blanks}
 while drive_spec[1]=' ' do  drive_spec :=
copy(drive_spec,2,length(drive_spec));
 while drive_spec[length(drive_spec)]=' ' do  drive_spec :=
copy(drive_spec,1,length(drive_spec)-1);
 drive_number := ord(upcase(drive_spec[1]))-65;
 drive_letter := upcase(drive_spec[1]);
 path_name := copy(drive_spec,4,length(drive_spec));
 get_drive_handle_id(drive_number,dir_handle);
 alloc_permanent_directory_handle(dir_handle,drive_letter,path_name,new_handle,
 rights,retcode);
 _retcode := retcode;
 _rights := rights;
end;




procedure down_file_server(flag:integer;var retcode : integer);
var

request_buffer : record
 buffer_length : integer;
   subfunction : byte;
     down_flag : byte;
           end;

  reply_buffer : record
 buffer_length : integer;
           end;

begin
With request_buffer do
begin
 buffer_length := 2;
 subfunction := $D3;
 down_flag := flag;
end;
reply_buffer.buffer_length := 0;
With Regs Do Begin
 Ah := $E3;
 Ds := Seg(Request_Buffer);
 Si := Ofs(Request_Buffer);
 Es := Seg(Reply_Buffer);
 Di := Ofs(Reply_Buffer);
End;
msdos(regs);
retcode := regs.al;
end;


procedure set_preferred_connection_id(server_num : integer);
begin
 regs.ah := $F0;
 regs.al := $00;
 regs.ds := 0;
 regs.es := 0;
 regs.dl := server_num;
 msdos(regs);
end;

procedure set_primary_connection_id(server_num : integer);
begin
 regs.ah := $F0;
 regs.al := $04;
 regs.ds := 0;
 regs.es := 0;
 regs.dl := server_num;
 msdos(regs);
end;

procedure get_primary_connection_id(var server_num : integer);
begin
 regs.ah := $F0;
 regs.al := $05;
 regs.es := 0;
 regs.ds := 0;
 msdos(regs);
 server_num := regs.al;
end;

procedure get_default_connection_id(var server_num : integer);
begin
 regs.ah := $F0;
 regs.al := $02;
 regs.es := 0;
 regs.ds := 0;
 msdos(regs);
 server_num := regs.al;
end;

procedure get_preferred_connection_id(var server_num : integer);
begin
 regs.ah := $F0;
 regs.al := $02;
 regs.ds := 0;
 regs.es := 0;
 msdos(regs);
 server_num := regs.al;
end;


procedure get_drive_connection_id(var drive_number, server_number : integer);
var

 drive_table : array [1..32] of byte;
       count : integer;
           p : ^byte;

begin
  regs.ah := $EF;
  regs.al := $02;
  regs.es := 0;
  regs.ds := 0;
  msdos(regs);
  p := ptr(regs.es, regs.si);
  move(p^,drive_table,32);
  if ((drive_number < 0) or (drive_number > 32))  then drive_number := 1;
  server_number := drive_table[drive_number];
end;

procedure get_drive_handle_id(var drive_number, handle_number : integer);
var
 drive_table : array [1..32] of byte;
       count : integer;
           p : ^byte;

begin
  regs.ah := $EF;
  regs.al := $00;
  regs.ds := 0;
  regs.es := 0;
  msdos(regs);
  p := ptr(regs.es, regs.si);
  move(p^,drive_table,32);
  if ((drive_number < 0) or (drive_number > 32))  then drive_number := 1;
  handle_number := drive_table[drive_number];
end;


procedure get_file_server_name(var server_number : integer; var server_name :
string);
var
  name_table : array [1..8*48] of byte;
      server : array [1..8] of string;
       count : integer;
      count2 : integer;
           p : ^byte;
     no_more : integer;

begin
  regs.ah := $EF;
  regs.al := $04;
  regs.ds := 0;
  regs.es := 0;
  msdos(regs);
  no_more := 0;
  p := ptr(regs.es, regs.si);
  move(p^,name_table,8*48);
  for count := 1 to 8 do server[count] := '';
  for count := 0 to 7 do
  begin
    no_more := 0;
    for count2 := (count*48)+1 to (count*48)+48 do if name_table[count2] <>
$00
        then
        begin
        if no_more=0 then server[count+1] := server[count+1] +
chr(name_table[count2]);
        end else no_more:=1; {scan until 00h is found}
  end;
  if ((server_number<1) or (server_number>8)) then server_number := 1;
  server_name := server[server_number];
end;

procedure disable_file_server_login(var retcode : integer);
var  request_buffer : record
      buffer_length : integer;
        subfunction : byte
                end;

  reply_buffer : record
 buffer_length : integer;
           end;

begin
  With Regs Do Begin
    Ah := $E3;
    Ds := Seg(Request_Buffer);
    Si := Ofs(Request_Buffer);
    Es := Seg(Reply_Buffer);
    Di := Ofs(Reply_Buffer);
  End;
  With request_buffer do
   begin
   buffer_length := 1;
   subfunction := $CB;
   end;
 reply_buffer.buffer_length := 0;
 msdos(regs);
 retcode := regs.al;
end;

procedure enable_file_server_login(var retcode : integer);
var request_buffer : record
     buffer_length : integer;
       subfunction : byte
               end;

  reply_buffer : record
 buffer_length : integer;
           end;

begin
  With Regs Do Begin
    Ah := $E3;
    Ds := Seg(Request_Buffer);
    Si := Ofs(Request_Buffer);
    Es := Seg(Reply_Buffer);
    Di := Ofs(Reply_Buffer);
  End;
  With request_buffer do
   begin
   buffer_length := 1;
   subfunction := $CC;
   end;
 reply_buffer.buffer_length := 0;
 msdos(regs);
 retcode := regs.al;
end;


procedure get_directory_path(var handle : integer; var pathname : string; var
retcode : integer);
var count : integer;

   request_buffer : record
              len : integer;
      subfunction : byte;
       dir_handle : byte;
              end;

     reply_buffer : record
              len : integer;
         path_len : byte;
        path_name : array [1..255] of byte;
              end;

begin
  With Regs Do Begin
    Ah := $e2;
    Ds := Seg(Request_Buffer);
    Si := Ofs(Request_Buffer);
    Es := Seg(Reply_Buffer);
    Di := Ofs(Reply_Buffer);
  End;
  With request_buffer do
   begin
   len := 2;
   subfunction := $01;
   dir_handle := handle;
   end;
  With reply_buffer do
   begin
   len := 256;
   path_len := 0;
   for count := 1 to 255 do path_name[count] := $00;
   end;
  msdos(regs);
  retcode := regs.al;
  pathname := '';
  if reply_buffer.path_len > 0 then for count := 1 to reply_buffer.path_len do
     pathname := pathname + chr(reply_buffer.path_name[count]);
end;

procedure detach_from_file_server(var id,retcode:integer);
begin
 regs.ah := $F1;
 regs.al := $01;
 regs.dl := id;
 msdos(regs);
 retcode := regs.al;
end;


procedure getstation( var _station: integer; var retcode: integer);
begin
   With Regs do
   begin
    ah := $DC;
    ds := 0;
    si := 0;
   end;
   MsDos( Regs );
   _station := Regs.al;
   retcode := 0;
   end;


procedure GetHexID( var userid,hexid: string; var retcode: integer);
var
    i,x           : integer;
    hex_id        : string;
    requestbuffer : record
      len      : integer;
      func     : byte;
      conntype : packed array [1..2] of byte;
      name_len : byte;
      name     : packed array [1..47] of char;
      end;
    replybuffer   : record
      len      : integer;
      uniqueid1: packed array [1..2] of byte;
      uniqueid2: packed array [1..2] of byte;
      conntype : word;
      name     : packed array [1..48] of byte;
      end;

begin
  regs.ah := $E3;
  requestbuffer.func := $35;
  regs.ds := seg(requestbuffer);
  regs.si := ofs(requestbuffer);
  regs.es := seg(replybuffer);
  regs.di := ofs(replybuffer);
  requestbuffer.len := 52;
  replybuffer.len := 55;
  requestbuffer.name_len := length(userid);
  for i := 1 to length(userid) do requestbuffer.name[i] := userid[i];
  requestbuffer.conntype[2] := $1;
  requestbuffer.conntype[1] := $0;
  replybuffer.conntype := 1;
  msdos(regs);
  retcode := regs.al;   {
  if retcode = $96 then writeln('Server out of memory');
  if retcode = $EF then writeln('Invalid name');
  if retcode = $F0 then writeln('Wildcard not allowed');
  if retcode = $FC then writeln('No such object *',userid,'*');
  if retcode = $FE then writeln('Server bindery locked');
  if retcode = $FF then writeln('Bindery failure'); }
  hex_id := '';
  if retcode = 0 then
  begin
   hex_id := hexdigits[replybuffer.uniqueid1[1] shr 4];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid1[1] and $0F];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid1[2] shr 4];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid1[2] and $0F];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid2[1] shr 4];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid2[1] and $0F];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid2[2] shr 4];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid2[2] and $0F];
   { Now we chop off leading zeros }
   while hex_id[1] = '0' do hex_id := copy(hex_id,2,length(hex_id));
  end;
   hexid := hex_id;
end;


Procedure GetConnectionInfo
(Var LogicalStationNo: Integer; Var Name: String; Var HEX_ID: String;
 Var ConnType : Integer; Var DateTime : String; Var retcode:integer);

Var
  I,X            : Integer;
  RequestBuffer  : Record
                     PacketLength : Integer;
                     FunctionVal  : Byte;
                     ConnectionNo : Byte;
                   End;
  ReplyBuffer    : Record
                     ReturnLength : Integer;
                     UniqueID1    : Packed Array [1..2] of byte;
                     UniqueID2    : Packed Array [1..2] of byte;
                     NWConnType   : Packed Array [1..2] of byte;
                     ObjectName   : Packed Array [1..48] of Byte;
                     LoginTime    : Packed Array [1..8] of Byte;
                   End;
  Month          : String[3];
  Year,
  Day,
  Hour,
  Minute         : String[2];

Begin
  With RequestBuffer Do Begin
    PacketLength := 2;
    FunctionVal := 22;  { 22 = Get Station Info }
    ConnectionNo := LogicalStationNo;
  End;
  ReplyBuffer.ReturnLength := 62;
  With Regs Do Begin
    Ah := $e3;
    ds := 0;
    es := 0;
    Ds := Seg(RequestBuffer);
    Si := Ofs(RequestBuffer);
    Es := Seg(ReplyBuffer);
    Di := Ofs(ReplyBuffer);
  End;
  MsDos(Regs);
  retcode := regs.al;
  name := '';
  hex_id := hexdigits[replybuffer.uniqueid1[1] shr 4];
  hex_id := hex_id + hexdigits[replybuffer.uniqueid1[1] and $0F];
  hex_id := hex_id + hexdigits[replybuffer.uniqueid1[2] shr 4];
  hex_id := hex_id + hexdigits[replybuffer.uniqueid1[2] and $0F];
  hex_id := hex_id + hexdigits[replybuffer.uniqueid2[1] shr 4];
  hex_id := hex_id + hexdigits[replybuffer.uniqueid2[1] and $0F];
  hex_id := hex_id + hexdigits[replybuffer.uniqueid2[2] shr 4];
  hex_id := hex_id + hexdigits[replybuffer.uniqueid2[2] and $0F];
  { Now we chop off leading zeros }
    while ( (hex_id[1]='0') and (length(hex_id) > 1) )
             do hex_id := copy(hex_id,2,length(hex_id));
  ConnType := replybuffer.nwconntype[2];
  datetime := '';
  If hex_id <> '0' Then Begin {Grab username}
    With ReplyBuffer Do Begin
      I := 1;
      While (I <= 48)  and (ObjectName[I] <> 0) Do
        Begin
        Name[I] := Chr(Objectname[I]);
        I := I + 1;
        End { while };
     Name[0] := Chr(I - 1);
   End; {With} End; {if}
   If hex_id <> '0' then With replybuffer do {Grab login time}
   begin
     Str(LoginTime[1]:2,Year);
     Month := Months[LoginTime[2]];
     Str(LoginTime[3]:2,Day);
     Str(LoginTime[4]:2,Hour);
     Str(LoginTime[5]:2,Minute);
     If Day[1] = ' ' Then Day[1] := '0';
     If Hour[1] = ' ' Then Hour[1] := '0';
     If Minute[1] = ' ' Then Minute[1] := '0';
     DateTime := Day+'-'+Month+'-'+Year+' ' + Hour + ':' + Minute;
     End;
End { GetConnectInfo };

procedure login_to_file_server(obj_type:integer;_name,_password : string;var
retcode:integer);
var   request_buffer : record
            B_length : integer;
         subfunction : byte;
              o_type : packed array [1..2] of byte;
         name_length : byte;
            obj_name : packed array [1..47] of byte;
     password_length : byte;
            password : packed array [1..27] of byte;
                 end;

        reply_buffer : record
            R_length : integer;
                 end;

               count : integer;

begin
With request_buffer do
begin
 B_length := 79;
 subfunction := $14;
 o_type[1] := 0;
 o_type[2] := obj_type;
 for count := 1 to 47 do obj_name[count] := $0;
 for count := 1 to 27 do password[count] := $0;
 if length(_name) > 0 then
    for count := 1 to length(_name) do
obj_name[count]:=ord(upcase(_name[count]));
 if length(_password) > 0 then
    for count := 1 to length(_password) do
password[count]:=ord(upcase(_password[count]));
 {set to full length of field}
 name_length := 47;
 password_length := 27;
end;
With reply_buffer do
begin
 R_length := 0;
end;
  With Regs Do Begin
    Ah := $e3;
    Ds := Seg(Request_Buffer);
    Si := Ofs(Request_Buffer);
    Es := Seg(reply_buffer);
    Di := Ofs(reply_buffer);
  End;
  MsDos(Regs);
  retcode := regs.al
end;

procedure logout;
{logout from all file servers}
begin
 regs.ah := $D7;
 msdos(regs);
end;

procedure logout_from_file_server(var id: integer);
{logout from one file server}
begin
 regs.ah := $F1;
 regs.al := $02;
 regs.dl := id;
 msdos(regs);
end;




procedure send_message_to_username(username,message : string; var retcode:
integer);
VAR
   count1     : byte;
   userid     : string;
   stationid  : integer;
   ret_code   : integer;

begin
   ret_code := 1;
   for count1:= 1 to length(username) do
       username[count1]:=upcase(username[count1]); { Convert to upper case }
   getserverinfo;
   for count1:= 1 to serverinfo.connections_max do
   begin
     stationid := count1;
     getuser( stationid, userid, retcode);
      if userid = username then
        begin
        ret_code := 0;
        send_message_to_station(stationid, message, retcode);
      end;
     end; { end of count }
     retcode := ret_code;
     { retcode = 0 if sent,  1 if userid not found }
end; { end of procedure }


Procedure GetServerInfo;
Var
  RequestBuffer  : Record
                     PacketLength : Integer;
                     FunctionVal  : Byte;
                   End;
  I              : Integer;

Begin
  With RequestBuffer Do Begin
    PacketLength := 1;
    FunctionVal := 17;  { 17 = Get Server Info }
  End;
  ServerInfo.ReturnLength := 128;
  With Regs Do Begin
    Ah := $e3;
    Ds := Seg(RequestBuffer);
    Si := Ofs(RequestBuffer);
    Es := Seg(ServerInfo);
    Di := Ofs(ServerInfo);
  End;
  MsDos(Regs);
  With serverinfo do
  begin
   connections_max := connectionmax[1]*256 + connectionmax[2];
   connections_in_use := connectionuse[1]*256 + connectionuse[2];
   max_connected_volumes := maxconvol[1]*256 + maxconvol[2];
   peak_connections_used := peak_used[1]*256 + peak_used[2];
   name := '';
   i := 1;
   while ((server[i] <> 0) and (i<>48)) do
    begin
    name := name + chr(server[i]);
    i := i + 1;
    end;
   end;
End;

procedure GetServerName(var servername : string; var retcode : integer);
{-----------------------------------------------------------------}
{ This routine returns the same as GetServerInfo.  This routine   }
{ was kept to maintain compatibility with the older  novell unit. }
{-----------------------------------------------------------------}
begin
  getserverinfo;
  servername := serverinfo.name;
  retcode := 0;
  end;

procedure send_message_to_station(station:integer; message : string; var retcode : integer);
VAR
   req_buffer : record
   buffer_len : integer;
   subfunction: byte;
      c_count : byte;
       c_list : byte;
   msg_length : byte;
          msg : packed array [1..55] of byte;
          end;

   rep_buffer : record
   buffer_len : integer;
      c_count : byte;
       r_list : byte;
          end;

   count1     : integer;

begin
        if length(message) > 55 then message:=copy(message,1,55);
        With Regs do
        begin
         ah := $E1;
         ds:=seg(req_buffer);
         si:=ofs(req_buffer);
         es:=seg(rep_buffer);
         di:=ofs(rep_buffer);
        End;
        With req_buffer do
        begin
         buffer_len := 59;
         subfunction := 00;
         c_count := 1;
         c_list := station;
         for count1:= 1 to 55 do msg[count1]:= $00; { zero the buffer }
         msg_length := length(message); { message length }
         for count1:= 1 to length(message) do
msg[count1]:=ord(message[count1]);
        End;
        With rep_buffer do
        begin
         buffer_len := 2;
         c_count := 1;
         r_list := 0;
        End;
        msdos( Regs );
        retcode:= rep_buffer.r_list;
   end;


procedure getuser( var _station: integer; var  _username: string; var retcode:
integer);
{This procedure provides a shorter method of obtaining just the USERID.}
var
     gu_hexid : string;
  gu_conntype : integer;
  gu_datetime : string;

begin
  getconnectioninfo(_station,_username,gu_hexid,gu_conntype,gu_datetime,retcode);
end;


PROCEDURE GetNode( var hex_addr: string; var retcode: integer );
{ get the physical station address }

Const
   Hex_Set  :packed array[0..15] of char = '0123456789ABCDEF';

Begin { GetNode }
   {Get the physical address from the Network Card}
   Regs.Ah := $EE;
   regs.ds := 0;
   regs.es := 0;
   MsDos(Regs);
   hex_addr := '';
   hex_addr := hex_addr + hex_set[(regs.ch shr 4)];
   hex_addr := hex_addr + hex_set[(regs.ch and $0f)];
   hex_addr := hex_addr + hex_set[(regs.cl shr 4) ];
   hex_addr := hex_addr + hex_set[(regs.cl and $0f)];
   hex_addr := hex_addr + hex_set[(regs.bh shr 4)];
   hex_addr := hex_addr + hex_set[(regs.bh and $0f)];
   hex_addr := hex_addr + hex_set[(regs.bl shr 4)];
   hex_addr := hex_addr + hex_set[(regs.bl and $0f)];
   hex_addr := hex_addr + hex_set[(regs.ah shr 4)];
   hex_addr := hex_addr + hex_set[(regs.ah and $0f)];
   hex_addr := hex_addr + hex_set[(regs.al shr 4)];
   hex_addr := hex_addr + hex_set[(regs.al and $0f)];
   retcode := 0;
End; { Getnode }


PROCEDURE Get_Internet_Address(station : integer; var net_number, node_addr,
socket_number : string; var retcode : integer);


Const
   Hex_Set  :packed array[0..15] of char = '0123456789ABCDEF';

Var   Request_buffer : record
              length : integer;
         subfunction : byte;
          connection : byte;
                 end;

    Reply_Buffer : record
          length : integer;
         network : array [1..4] of byte;
            node : array [1..6] of byte;
          socket : array [1..2] of byte;
             end;

           count : integer;
      _node_addr : string;
  _socket_number : string;
     _net_number : string;

begin
 With Regs do
 begin
  ah := $E3;
  ds:=seg(request_buffer);
  si:=ofs(request_buffer);
  es:=seg(reply_buffer);
  di:=ofs(reply_buffer);
 End;
 With request_buffer do
 begin
  length := 2;
  subfunction := $13;
  connection := station;
 end;
 With reply_buffer do
 begin
  length := 12;
  for count := 1 to 4 do network[count] := 0;
  for count := 1 to 6 do node[count] := 0;
  for count := 1 to 2 do socket[count] := 0;
 end;
 msdos(regs);
 retcode := regs.al;
 _net_number := '';
 _node_addr := '';
 _socket_number := '';
 if retcode = 0 then
 begin
 for count := 1 to 4 do
     begin
     _net_number := _net_number + hex_set[ (reply_buffer.network[count] shr 4)
];
     _net_number := _net_number + hex_set[ (reply_buffer.network[count] and
$0F) ];
     end;
 for count := 1 to 6 do
     begin
     _node_addr := _node_addr + (hex_set[ (reply_buffer.node[count] shr 4) ]);
     _node_addr := _node_addr + (hex_set[ (reply_buffer.node[count] and $0F)
]);
     end;
 for count := 1 to 2 do
     begin
     _socket_number := _socket_number + (hex_set[ (reply_buffer.socket[count]
shr 4) ]);
     _socket_number := _socket_number + (hex_set[ (reply_buffer.socket[count]
and $0F) ]);
     end;
 end; {end of retcode=0}
 net_number := _net_number;
 node_addr := _node_addr;
 socket_number := _socket_number;
 end;

procedure get_realname(var userid,realname:string; var retcode:integer);
var
    requestbuffer : record
    buffer_length : array [1..2] of byte;
      subfunction : byte;
      object_type : array [1..2] of byte;
    object_length : byte;
      object_name : array [1..47] of byte;
          segment : byte;
  property_length : byte;
    property_name : array [1..14] of byte;
    end;

      replybuffer : record
    buffer_length : array [1..2] of byte;
   property_value : array [1..128] of byte;
    more_segments : byte;
   property_flags : byte;
   end;

   count    : integer;
   id       : string;
   fullname : string;

begin
  id := 'IDENTIFICATION';
  With requestbuffer do begin
     buffer_length[2] := 0;
     buffer_length[1] := 69;
     subfunction  := $3d;
     object_type[1]:= 0;
     object_type[2]:= 01;
     segment := 1;
     object_length := 47;
     property_length := length(id);
     for count := 1 to 47 do object_name[count] := $0;
     for count := 1 to length(userid) do object_name[count] :=
ord(userid[count]);
     for count := 1 to 14 do property_name[count] := $0;
     for count := 1 to length(id) do property_name[count] := ord(id[count]);
     end;
  With replybuffer do begin
     buffer_length[1] := 130;
     buffer_length[2] := 0;
     for count := 1 to 128 do property_value[count] := $0;
     more_segments := 1;
     property_flags := 0;
     end;
  With Regs do begin
     Ah := $e3;
     Ds := Seg(requestbuffer);
     Si := Ofs(requestbuffer);
     Es := Seg(replybuffer);
     Di := Ofs(replybuffer);
     end;
  MSDOS(Regs);
  retcode := Regs.al;
  fullname := '';
  count := 1;
  if replybuffer.property_value[1] <> 0 then
  repeat
   begin
   if replybuffer.property_value[count]<>0
      then fullname := fullname + chr(replybuffer.property_value[count]);
   count := count + 1;
   end;
   until ((count=128) or (replybuffer.property_value[count]=0));
  {if regs.al = $96 then writeln('server out of memory');
  if regs.al = $ec then writeln('no such segment');
  if regs.al = $f0 then writeln('wilcard not allowed');
  if regs.al = $f1 then writeln('invalid bindery security');
  if regs.al = $f9 then writeln('no property read priv');
  if regs.al = $fb then writeln('no such property');
  if regs.al = $fc then writeln('no such object');}
  if retcode=0 then realname := fullname else realname:='';
end;

procedure get_broadcast_mode(var bmode:integer);
begin
 regs.ah := $de;
 regs.dl := $04;
 msdos(regs);
 bmode := regs.al;
end;

procedure set_broadcast_mode(bmode:integer);
begin
 if ((bmode > 3) or (bmode < 0)) then bmode := 0;
 regs.ah := $de;
 regs.dl := bmode;
 msdos(regs);
 bmode := regs.al;
end;

procedure get_broadcast_message(var bmessage: string; var retcode : integer);
var requestbuffer : record
     bufferlength : array [1..2] of byte;
      subfunction : byte;
      end;

      replybuffer : record
     bufferlength : array [1..2] of byte;
    messagelength : byte;
          message : array [1..58] of byte;
          end;
    count : integer;

begin
  With Requestbuffer do begin
     bufferlength[1] := 1;
     bufferlength[2] := 0;
     subfunction := 1;
     end;
  With replybuffer do begin
     bufferlength[1] := 59;
     bufferlength[2] := 0;
     messagelength := 0;
     end;
     for count := 1 to 58 do replybuffer.message[count] := $0;

  With Regs do begin
     Ah := $e1;
     Ds := Seg(requestbuffer);
     Si := Ofs(requestbuffer);
     Es := Seg(replybuffer);
     Di := Ofs(replybuffer);
     end;
  MSDOS(Regs);
  retcode := Regs.al;
  bmessage := '';
  count := 0;
  if replybuffer.messagelength > 58 then replybuffer.messagelength := 58;
  if replybuffer.messagelength > 0 then
     for count := 1 to replybuffer.messagelength do
     bmessage := bmessage + chr(replybuffer.message[count]);
  { retcode = 0 if no message,  1 if message was retreived }
  if length(bmessage) = 0 then retcode := 1 else retcode := 0;
  end;

procedure get_server_datetime(var _year,_month,_day,_hour,_min,_sec,_dow:integer);
var replybuffer : record
           year : byte;
          month : byte;
            day : byte;
           hour : byte;
         minute : byte;
         second : byte;
            dow : byte;
            end;

begin
  With Regs do begin
     Ah := $e7;
     Ds := Seg(replybuffer);
     Dx := Ofs(replybuffer);
     end;
  MSDOS(Regs);
  retcode := Regs.al;
  _year := replybuffer.year;
  _month := replybuffer.month;
  _day := replybuffer.day;
  _hour := replybuffer.hour;
  _min := replybuffer.minute;
  _sec := replybuffer.second;
  _dow := replybuffer.dow;
end;

procedure set_date_from_server;
var replybuffer : record
           year : byte;
          month : byte;
            day : byte;
           hour : byte;
         minute : byte;
         second : byte;
            dow : byte;
            end;

begin
  With Regs do begin
     Ah := $e7;
     Ds := Seg(replybuffer);
     Dx := Ofs(replybuffer);
     end;
  MSDOS(Regs);
  setdate(replybuffer.year+1900,replybuffer.month,replybuffer.day);
end;

procedure set_time_from_server;
var replybuffer : record
           year : byte;
          month : byte;
            day : byte;
           hour : byte;
         minute : byte;
         second : byte;
            dow : byte;
            end;

begin
  With Regs do begin
     Ah := $e7;
     Ds := Seg(replybuffer);
     Dx := Ofs(replybuffer);
     end;
  MSDOS(Regs);
  settime(replybuffer.hour,replybuffer.minute,replybuffer.second,0);
end;

procedure get_server_version(var _version : string);
var  count,x : integer;

       request_buffer : record
        buffer_length : integer;
          subfunction : byte;
          end;

         reply_buffer : record
        buffer_length : integer;
                stuff : array [1..512] of byte;
                end;

        strings : array [1..3] of string;
begin
  With Regs do begin
     Ah := $e3;
     Ds := Seg(request_buffer);
     Si := Ofs(request_buffer);
     Es := Seg(reply_buffer);
     Di := Ofs(reply_buffer);
     end;
  With request_buffer do
  begin
     buffer_length := 1;
     subfunction := $c9;
  end;
  With reply_buffer do
  begin
     buffer_length := 512;
     for count := 1 to 512 do stuff[count] := $00;
  end;
  MSDOS(Regs);
  for count := 1 to 3 do strings[count] := '';
  x := 1;
  With reply_buffer do
  begin
    for count := 1 to 256 do
    begin
     if stuff[count] <> $0 then
        begin
         if not ((stuff[count]=32) and (strings[x]='')) then strings[x] :=
strings[x] + chr(stuff[count]);
        end;
     if stuff[count] = $0 then if x <> 3 then x := x + 1;
    end;
  End; { end of with }
  _version := strings[2];
end;

procedure open_message_pipe(var _connection, retcode : integer);
var  request_buffer : record
      buffer_length : integer;
        subfunction : byte;
   connection_count : byte;
    connection_list : byte;
                end;

      reply_buffer : record
     buffer_length : integer;
  connection_count : byte;
       result_list : byte;
               end;
begin
  With Regs do begin
     Ah := $e1;
     Ds := Seg(request_buffer);
     Si := Ofs(request_buffer);
     Es := Seg(reply_buffer);
     Di := Ofs(reply_buffer);
     end;
  With request_buffer do
  begin
     buffer_length := 3;
     subfunction := $06;
     connection_count := $01;
     connection_list := _connection;
  end;
  With reply_buffer do
  begin
     buffer_length := 2;
     connection_count := 0;
     result_list := 0;
  end;
  MSDOS(Regs);
  retcode := reply_buffer.result_list;
end;

procedure close_message_pipe(var _connection, retcode : integer);
var  request_buffer : record
      buffer_length : integer;
        subfunction : byte;
   connection_count : byte;
    connection_list : byte;
                end;

      reply_buffer : record
     buffer_length : integer;
  connection_count : byte;
       result_list : byte;
               end;
begin
  With Regs do begin
     Ah := $e1;
     Ds := Seg(request_buffer);
     Si := Ofs(request_buffer);
     Es := Seg(reply_buffer);
     Di := Ofs(reply_buffer);
     end;
  With request_buffer do
  begin
     buffer_length := 3;
     subfunction := $07;
     connection_count := $01;
     connection_list := _connection;
  end;
  With reply_buffer do
  begin
     buffer_length := 2;
     connection_count := 0;
     result_list := 0;
  end;
  MSDOS(Regs);
  retcode := reply_buffer.result_list;
end;

procedure check_message_pipe(var _connection, retcode : integer);
var request_buffer : record
     buffer_length : integer;
       subfunction : byte;
  connection_count : byte;
   connection_list : byte;
               end;

      reply_buffer : record
     buffer_length : integer;
  connection_count : byte;
       result_list : byte;
               end;
begin
  With Regs do begin
     Ah := $e1;
     Ds := Seg(request_buffer);
     Si := Ofs(request_buffer);
     Es := Seg(reply_buffer);
     Di := Ofs(reply_buffer);
     end;
  With request_buffer do
  begin
     buffer_length := 3;
     subfunction := $08;
     connection_count := $01;
     connection_list := _connection;
  end;
  With reply_buffer do
  begin
     buffer_length := 2;
     connection_count := 0;
     result_list := 0;
  end;
  MSDOS(Regs);
  retcode := reply_buffer.result_list;
end;


procedure send_personal_message(var _connection : integer; var _message :
string; var retcode : integer);
var count : integer;

      request_buffer : record
       buffer_length : integer;
         subfunction : byte;
    connection_count : byte;
     connection_list : byte;
      message_length : byte;
             message : array [1..126] of byte;
                 end;

        reply_buffer : record
       buffer_length : integer;
    connection_count : byte;
         result_list : byte;
                 end;

begin
  With Regs do begin
     Ah := $e1;
     Ds := Seg(request_buffer);
     Si := Ofs(request_buffer);
     Es := Seg(reply_buffer);
     Di := Ofs(reply_buffer);
     end;
  With request_buffer do
  begin
     subfunction := $04;
     connection_count := $01;
     connection_list := _connection;
     message_length := length(_message);
     buffer_length := length(_message) + 4;
     for count := 1 to 126 do message[count] := $00;
     if message_length > 0 then for count := 1 to message_length do
        message[count] := ord(_message[count]);
  end;
  With reply_buffer do
  begin
     buffer_length := 2;
     connection_count := 0;
     result_list := 0;
  end;
  MSDOS(Regs);
  retcode := reply_buffer.result_list;
end;

procedure purge_erased_files(var retcode:integer);
var  request_buffer : record
      buffer_length : integer;
        subfunction : byte;
                end;

       reply_buffer : record
      buffer_length : integer;
                end;
begin
  With request_buffer do
    begin
    buffer_length := 1;
    subfunction := $10;
    end;
  With reply_buffer do buffer_length := 0;
  With Regs do begin
   Ah := $E2;
   Ds := Seg(request_buffer);
   Si := Ofs(request_buffer);
   Es := Seg(reply_buffer);
   Di := Ofs(reply_buffer);
   end;
  msdos(regs);
  retcode := regs.al;
end;

procedure purge_all_erased_files(var retcode:integer);
var  request_buffer : record
      buffer_length : integer;
        subfunction : byte;
                end;

       reply_buffer : record
      buffer_length : integer;
                end;
begin
  With request_buffer do
    begin
    buffer_length := 1;
    subfunction := $CE;
    end;
  With reply_buffer do buffer_length := 0;
  With Regs do begin
   Ah := $E3;
   Ds := Seg(request_buffer);
   Si := Ofs(request_buffer);
   Es := Seg(reply_buffer);
   Di := Ofs(reply_buffer);
   end;
  msdos(regs);
  retcode := regs.al;
end;


procedure get_personal_message(var _connection : integer; var _message :
string; var retcode : integer);
var count : integer;

      request_buffer : record
       buffer_length : integer;
         subfunction : byte;
                 end;

        reply_buffer : record
       buffer_length : integer;
   source_connection : byte;
      message_length : byte;
      message_buffer : array [1..126] of byte;
                 end;

begin
    With Regs do begin
     Ah := $e1;
     Ds := Seg(request_buffer);
     Si := Ofs(request_buffer);
     Es := Seg(reply_buffer);
     Di := Ofs(reply_buffer);
     end;
  With request_buffer do
  begin
     buffer_length := 1;
     subfunction := $05;
  end;
  With reply_buffer do
  begin
     buffer_length := 128;
     source_connection := 0;
     message_length := 0;
     for count := 1 to 126 do message_buffer[count] := $0;
  end;
  MSDOS(Regs);
  _connection := reply_buffer.source_connection;
  _message := '';
  retcode := reply_buffer.message_length;
  if retcode > 0 then for count := 1 to retcode do
     _message := _message + chr(reply_buffer.message_buffer[count]);
end;

procedure log_file(lock_directive:integer; log_filename: string;
log_timeout:integer; var retcode:integer);
begin
    With Regs do begin
     Ah := $eb;
     Ds := Seg(log_filename);
     Dx := Ofs(log_filename);
     BP := log_timeout;
     end;
msdos(regs);
retcode := regs.al;
end;

procedure release_file(log_filename: string; var retcode:integer);
begin
    With Regs do begin
     Ah := $ec;
     Ds := Seg(log_filename);
     Dx := Ofs(log_filename);
     end;
msdos(regs);
retcode := regs.al;
end;

procedure clear_file(log_filename: string; var retcode:integer);
begin
    With Regs do begin
     Ah := $ed;
     Ds := Seg(log_filename);
     Dx := Ofs(log_filename);
     end;
msdos(regs);
retcode := regs.al;
end;

procedure clear_file_set;
begin
 regs.Ah := $cf;
 msdos(regs);
 retcode := regs.al;
end;

procedure lock_file_set(lock_timeout:integer; var retcode:integer);
begin
 regs.ah := $CB;
 regs.bp := lock_timeout;
 msdos(regs);
 retcode := regs.al;
end;

procedure release_file_set;
begin
 regs.ah := $CD;
 msdos(regs);
end;

procedure open_semaphore( _name:string;
                          _initial_value:shortint;
                          var _open_count:integer;
                          var _handle:longint;
                          var retcode:integer);
var s_name : array [1..129] of byte;
    count : integer;
    semaphore_handle : array [1..2] of word;
begin
  if (_initial_value < 0) or (_initial_value > 127) then _initial_value := 0;
  for count := 1 to 129 do s_name[count] := $00; {zero buffer}
  if length(_name) > 127 then _name := copy(_name,1,127); {limit name length}
  if length(_name) > 0 then for count := 1 to length(_name) do s_name[count+1]
:= ord(_name[count]);
  s_name[1] := length(_name);
  regs.ah := $C5;
  regs.al := $00;
  move(_initial_value, regs.cl, 1);
  regs.ds := seg(s_name);
  regs.dx := ofs(s_name);
  regs.es := 0;
  msdos(regs);
  retcode := regs.al;
  if retcode = 0 then _open_count := regs.bl else _open_count := 0;
  semaphore_handle[1]:=regs.cx;
  semaphore_handle[2]:=regs.dx;
  move(semaphore_handle,_handle,4);
end;

procedure close_semaphore(var _handle:longint; var retcode:integer);
var semaphore_handle : array [1..2] of word;
begin
 move(_handle,semaphore_handle,4);
 regs.ah := $C5;
 regs.al := $04;
 regs.ds := 0;
 regs.es := 0;
 regs.cx := semaphore_handle[1];
 regs.dx := semaphore_handle[2];
 msdos(regs);
 retcode := regs.al;  { 00h=successful   FFh=Invalid handle}
end;

procedure examine_semaphore(var _handle:longint; var _value:shortint; var
_count, retcode:integer);
var semaphore_handle : array [1..2] of word;
begin
    move(_handle,semaphore_handle,4);
    regs.ah := $C5;
    regs.al := $01;
    regs.ds := 0;
    regs.es := 0;
    regs.cx := semaphore_handle[1];
    regs.dx := semaphore_handle[2];
    msdos(regs);
    retcode := regs.al; {00h=successful FFh=invalid handle}
    move(regs.cx, _value, 1);
    _count := regs.dl;
end;

procedure signal_semaphore(var _handle:longint; var retcode:integer);
var semaphore_handle : array [1..2] of word;
begin
    move(_handle,semaphore_handle,4);
    regs.ah := $C5;
    regs.al := $03;
    regs.ds := 0;
    regs.es := 0;
    regs.cx := semaphore_handle[1];
    regs.dx := semaphore_handle[2];
    msdos(regs);
    retcode := regs.al;
    {00h=successful   01h=overflow value > 127   FFh=invalid handle}
end;

procedure wait_on_semaphore(var _handle:longint; _timeout:integer; var
retcode:integer);
var semaphore_handle : array [1..2] of word;
begin
    move(_handle,semaphore_handle,4);
    regs.ah := $C5;
    regs.al := $02;
    regs.ds := 0;
    regs.es := 0;
    regs.bp := _timeout; {units in 1/18 of second,   0 = no wait}
    regs.cx := semaphore_handle[1];
    regs.dx := semaphore_handle[2];
    msdos(regs);
    retcode := regs.al;
    {00h=successful   FEh=timeout failure   FFh=invalid handle}
end;

procedure clear_connection(connection_number : integer; var retcode :
integer);
var con_num : byte;

    request_buffer : record
            length : integer;
       subfunction : byte;
           con_num : byte;
               end;

      reply_buffer : record
            length : integer;
               end;

begin
  with request_buffer do begin
     length := 4;
     con_num := connection_number;
     subfunction := $D2;
     end;
  reply_buffer.length := 0;
  with regs do begin
     Ah := $e3;
     Ds := Seg(request_buffer);
     Si := Ofs(request_buffer);
     Es := Seg(reply_buffer);
     Di := Ofs(reply_buffer);
     end;
  msdos(regs);
  retcode := regs.al;
end;


procedure get_server_lan_driver_information(var _lan_board_number : integer;
{ This will return info on what }           var _text1,_text2:string;
{ type of network cards are being }         var _network_address : byte4;
{ used in the server. }                     var _host_address : byte6;
                                            var _driver_installed,
                                                _option_number,
                                                _retcode : integer);

var      count : integer;
          text : array [1..3] of string;
            x1 : integer;

         request_buffer : record
                 length : integer;
            subfunction : byte;
              lan_board : byte;
                     end;

           reply_buffer : record
                 length : integer;
        network_address : byte4;
           host_address : byte6;
   lan_driver_installed : byte;
          option_number : byte;
     configuration_text : array [1..160] of byte;
                     end;
begin
 with request_buffer do begin
      length := 2;
      subfunction := $E3;
      lan_board := _lan_board_number; { 0 to 3 }
      end;
 with reply_buffer do begin
      length := 174;
      for count := 1 to 4 do network_address[count] := $0;
      for count := 1 to 6 do host_address[count] := $0;
      lan_driver_installed := 0;
      option_number := 0;
      for count := 1 to 160 do configuration_text[count] := $0;
      end;
  with regs do begin
     Ah := $E3;
     Ds := Seg(request_buffer);
     Si := Ofs(request_buffer);
     Es := Seg(reply_buffer);
     Di := Ofs(reply_buffer);
     end;
  msdos(regs);
  retcode := regs.al;
  _text1 := '';
  _text2 := '';
  if retcode <> 0 then exit;
  _driver_installed := reply_buffer.lan_driver_installed;
  if reply_buffer.lan_driver_installed = 0 then exit;
  {-- set some values ---}
  for count := 1 to 3 do text[count] := '';
  x1 := 1;
    with reply_buffer do begin
      _network_address := network_address;
      _host_address := host_address;
      _option_number := option_number;
      for count := 1 to 160 do
      begin
      if ((configuration_text[count] = 0) and (x1 <> 3)) then x1 := x1+1;
      if configuration_text[count] <> 0 then
         text[x1] := text[x1] + chr(configuration_text[count]);
      end;
    end;
  _text1 := text[1];
  _text2 := text[2];
end;

end. { end of unit novell }

