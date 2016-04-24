(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0019.PAS
  Description: Novell Detection
  Author: NORBERT IGL
  Date: 02-18-94  06:59
*)


{
 MB> First - How can I detect if Novell netware is running on a
 MB> computer? and if you can tell me that... how can I get the
 MB> current version? }

uses  dos ;
var   Regs : registers ;
      ReplyBuffer : array[1..40] of char ;


function IPX_Loaded:boolean;
begin
   Regs.AX := $7A00 ;
   intr($2F,Regs) ;
   IPX_Loaded := (Regs.AL = $FF)
end;

function Netbios_Loaded:Boolean;
begin
 Regs.AH := $35; (* DOS function that checks an interrupt vector *)
 Regs.AL := $5C; (* Interrupt vector to be checked *)
 NetBios_Installed := True;
 msdos(Regs) ;
 if ((Regs.ES = 0) or (Regs.ES = $F000))
   then  NetBios_Installed := False
end;


function NetShell_Installed:Boolean;
begin
   with Regs do begin
      AH := $EA ;
      AL := 1 ;
      BX := 0 ;
      ES := seg(ReplyBuffer) ;
      DI := ofs(ReplyBuffer) ;
   end ; (* with do begin *)
   msdos(regs) ;
   NetShell_Installed := (Regs.BX = 0)
end.


