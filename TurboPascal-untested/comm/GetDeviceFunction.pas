(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0021.PAS
  Description: Get Device Function
  Author: ERIC GIVLER
  Date: 08-23-93  09:16
*)

{
===========================================================================
 BBS: Canada Remote Systems
Date: 08-16-93 (19:59)             Number: 34567
From: ERIC GIVLER                  Refer#: NONE
  To: ALL                           Recvd: NO
Subj: PROBLEM                        Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
When I start up the BBS and it has the wrong port# (ie Com1 instead of 2),
the machine will lockup trying to write to the modem.  If the port is
correct, there are NO problems as long as the modem is on.  Is there a
graceful way of detecting this and remedying it - ie.  Even an abort
to DOS with an errorlevel would be nicer than a LOCKUP!  The following
idea is what I've tried.  It DOES appear to work!
}
USES CRT,DOS;

function is_device_ready( devicename:string) : boolean;
var r      : registers; handle : word; ready  : byte;
begin
     ready := 0;
     r.ds := seg(devicename);
     r.dx := ofs(devicename[1]);
     r.ax := $3d01;
     msdos(r);
     if (r.flags and fCarry) <> fCarry then
     begin
         handle := r.ax;
         ready  := 1;
         r.ax := $4407;
         r.bx := handle;
         msdos(r);
         ready := ready and r.AL;
         r.ah := $3e;
         r.bx := handle;
         msdos(r);
     end;
     is_device_ready := ( ready = 1 );
end; { is_device_ready }

begin
   ClrScr;
   writeln('COM2 is ready ..', is_device_ready('COM2'+#00) );
   writeln('COM1 is ready ..', is_device_ready('COM1'+#00) );
   writeln('LPT1 is ready ..', is_device_ready('PRN' + #00) );
end.

--- msgedsq 2.1
 * Origin: Noname Consultants (717)561-8033 (1:270/101.15)

