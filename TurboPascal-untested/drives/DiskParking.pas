(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0027.PAS
  Description: Disk Parking
  Author: JAN DOGGEN
  Date: 08-17-93  08:47
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 07-11-93 (20:49)             Number: 30503
From: JAN DOGGEN                   Refer#: NONE
  To: MARK STEPHEN                  Recvd: NO  
Subj: RE: PARK IT!                   Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 -=> Quoting Mark Stephen to Herb Brown <=-

 HB> Anybody have any suggestions, experiences, trials, tribulations,
 HB> videos, and/or code examples on how to park a hard drive?

 MS> Trouble is, I have no idea of how to find out if the code has actually
 MS> done what I want it to, and there seems to be a real possibility of

 Yep, took me some time to figure out you can't test where the head is
 (i.e. if the park was succesful).
 I always assume that it won't do any harm on self-parking drives
 (they just park twice).
 Here's some code for Herb too; I guess he reads this too.

PROCEDURE ParkDisk;
  VAR Regs: Registers;
  BEGIN
    Regs.AH := $08;                { 'Return drive parameters' function }
    Regs.DL := $80;           { Physical drive number - first hard disk }
    Regs.AL := $00;
    Intr($13,Regs);
    Assert((Regs.Flags AND FCarry) = 0,
      'Error getting disk parameters - AL returns '+IntToStr(Regs.AL,0));
    { Now: DL = Number of drives responding                             }
    {      DH = Maximum head number (# heads - 1)                       }
    {      CH = Maximum cylinders/tracks (# tracks - 1) - lower 8 bits  }
    {      CL = Higher 2 bits: high 2 bits of max cyl/tr                }
    {           Lower 6 bits: Maximum sector number                     }
    { We now position the heads using the BIOS Seek service. We can use }
    { the returned registers again if we set DL back to $80.            }
    Regs.AH := $0C;
    Regs.DL := $80;
    Intr($13,Regs);
    Assert((Regs.Flags AND FCarry) = 0,
      'Error parking disk - AL returns '+IntToStr(Regs.AL,0));
  END; { ParkDisk }

 MS> How about ignoring the problem, and if trouble develops, blaming it on
 MS> the hardware? (I believe this is the traditional approach?) The code

 Some approach!

 Jan
___ Blue Wave/QWK v2.10

--- Maximus 2.01
 * Origin: *** DOSBoss Zuid *** (2:500/131)

