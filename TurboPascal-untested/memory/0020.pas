===========================================================================
 BBS: Canada Remote Systems
Date: 06-12-93 (09:36)             Number: 26301
From: CHRIS JANTZEN                Refer#: NONE
  To: WILLIAM SITCH                 Recvd: NO  
Subj: RE: DETECTING EMS/XMS          Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
On Thursday June 10 1993, William Sitch wrote to All:

 WS> Does anyone know how to detect XMS/EMS?  I've used something documented in
 WS> my PC INTERRUPTS book, but I can't seem to get it to work.

The following code was *mostly* right. Go back to your original source to
compare the changes I made:

 procedure check_ems (VAR installed:boolean; VAR ver,ver2:byte); var
   regs  :  registers;
 begin
   regs.ax := $46;
   intr($67,regs);
   installed := regs.ah = $00;
   if (installed = true) then
     begin
       ver := hi(regs.al);
       ver2 := lo(regs.al);
     end;
 end;

 procedure check_xms (VAR installed:boolean; VAR ver,ver2:byte); var
   regs  :  registers;
 begin
   regs.ax := $4300;
   intr($2F,regs);
   installed := regs.al = $80;
   if (installed = true) then
     begin
       regs.ax := $4310;
       regs.ah := $00;
       intr($2F,regs);
       ver := regs.ax;
       ver2 := regs.bx;
     end;
 end;

 WS> I am pretty sure I'm calling the interrupts right, but it always returns
 WS> false, indicating that I do NOT have EMS/XMS, although I do.  Can anyone
 WS> help me out?

You were. Mostly. What you forgot was that when a real world book like PC
Interrupts says "Load the AX register with the value 4300h", it means to us
Pascal programmers "Load the AX variable with the value $4300". Note the dollar
sign. That means hexadecimal (like the little h on the end means hexadecimal to
assembly programmers).

Chris KB7RNL =->

--- GoldED 2.41
 * Origin: SlugPoint * Coos Bay, OR USA (1:356/18.2)
