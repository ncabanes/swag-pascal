(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0044.PAS
  Description: Available Drives
  Author: KENT BRIGGS
  Date: 09-26-93  10:11
*)

(*
===========================================================================
 BBS: Canada Remote Systems
Date: 08-29-93 (15:41)             Number: 36579
From: KENT BRIGGS                  Refer#: NONE
  To: HOWARD HUANG                  Recvd: NO
Subj: CHECK AVAILABLE DRIVES         Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 -=> Quoting Howard Huang to All <=-

 HH> Does anyone know how to check if a drive is valid without accessing
 HH> it to see? For example, if the available drives on a system are: A, B,
 HH> C, E. How do you check if drive A is installed without having the
 HH> floppy drive lights go on. I use TP6, so if you include a sample code,
 HH> could you make it compatible with it.

 Howard, here's what I use:
*)
program show_drives;
uses dos;
var
  reg: registers;
  drv: array[1..3] of byte;
  drvlist: string[26];
  fcb: array[1..37] of byte;
  i: integer;
begin
  drvlist:='';
  for i:=1 to 26 do         {Try drives A..Z}
  begin
    drv[1]:=i+64;           {A=ASCII 65, etc}
    drv[2]:=ord(':');
    drv[3]:=0;
    reg.ax:=$2906;          {DOS function 29h = Parse Filename}
    reg.si:=ofs(drv[1]);    {Point to drive string}
    reg.di:=ofs(fcb[1]);    {Point to File Control Block}
    reg.ds:=dseg;
    reg.es:=dseg;
    msdos(reg);             {DOS Interrupt}
    if reg.al<>$ff then drvlist:=drvlist+chr(i+64);
  end;
  writeln('Available drives = ',drvlist);
end.

___ Blue Wave/QWK v2.12
--- Renegade v07-17 Beta
 * Origin: Snipe's Castle BBS, Waco TX   (817)-757-0169 (1:388/26)

