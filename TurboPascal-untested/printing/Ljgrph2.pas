(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0004.PAS
  Description: LJ-GRPH2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

>Does anyone have any code or info on how to print Graphics on an HP
>Laserjet?

   The best thing to do would be to purchase the Technical Reference
Manual through HP Support Materials (800)227-8164. (I don't know if this
is an international number since you are in Canada) I don't own a
LaserJet, but own a DeskJet and my manual sold For $21.95.  They go into
great detail on the codes For all of the Text and Graphic Functions.

   There are some books on Laser Printer Graphics you could find in a
bigger public library or university library that would be helpful
also.

   Here are a few minor HP-PCL5 commands that will give you some
capabilities to tie you over (They refer to this as Raster Graphic
Mode):

 I will give these codes in hex, if you need another Format let me know )

    Start Raster Graphics
      At leftmost position        1B 2A 72 30 41
      At current cursor position  1B 2A 72 31 41

    end Raster Graphics           1B 2A 72 62 43

    Select Resolution
      75 D.P.I.                   1B 2A 74 37 35 52
      100 D.P.I.                  1B 2A 74 31 30 30 52
      150 D.P.I.                  1B 2A 74 31 35 30 52
      300 D.P.I.                  1B 2A 74 33 30 30 52

    Transfer Raster Graphics
      Number of Bytes             1B 2A 62 #of Bytes to send# 57 #data#

   Raster Graphics can be thought of as being a one pin dot matrix
Printer to an extent... think of it as drawing a horizontal line in
binary:
             11111111      +------+
             10000001  ->  |      |
             11111111      +------+

would be:
          1B 2A 72 30 41
          1B 2A 74 31 30 30 52
          1B 2A 62 01 57 FF
          1B 2A 62 01 57 81
          1B 2A 62 01 57 FF
          1B 2A 72 62 43

at 100 DPI For example.

   My apologies to the moderator if this is off topic, I understand the
frustration resulting from buying a $500 (or $2500 in the Case of the
LaserJet) Printer and not being able to do squat With it Until you can
find the inFormation they should have put in the user's manual in the
first place! (8->)  Dave


