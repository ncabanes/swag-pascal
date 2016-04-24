(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0024.PAS
  Description: Encryped logins
  Author: NORBERT IGL
  Date: 08-24-94  13:49
*)

{
 SM> Have you got any idea on how to do a login under Novell 3.11+?

 SM> I have some source (SWAG has source for a great TPU), but
 SM> unfortunatly it doesn't do encrypted logins.. I managed to find
 SM> *some* reference to it in the interrupt list (int 21h, the F2h
 SM> multiplexor functions 17h/18h), but it didn't give any details on
 SM> how this is done...

 hmmm. Novell never released any informations about Password Encrytion !

 You got two choices (:-)

1.   do a "Set Allow Unencrypted Passwords = ON" on the server console,
     use the following, ripped from an old src "Novapi.zip:Novell.pas"

------------------------------------------------------------------------}
uses dos;
[...]

{ obj_type:   User = 1, group =2 printserver = 3 }

procedure login_to_file_server( obj_type:integer;
                              _name,
                              _password : string;
                          var retcode:integer);
var
      regs : registers;

      request_buffer : record
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
    Ah := $e3;                 { moved to $F2 for v3.x ??? }
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
var regs : registers;
begin
 regs.ah := $D7;
 msdos(regs);
end;

procedure logout_from_file_server(var id: integer);
{logout from one file server}
var regs : registers;
begin
 regs.ah := $F1;
 regs.al := $02;
 regs.dl := id;
 msdos(regs);
end;

------------------------------------------------------------------------

2.   get a copy of "Charles Rose: Netware Programming". There are some
     <obj> for "C", and in my German version  TPU's for Turbo/BP" !


