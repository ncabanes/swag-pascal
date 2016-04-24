(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0003.PAS
  Description: Finding the Default Drive
  Author: LEE BARKER
  Date: 05-28-93  13:38
*)

*--*  03-31-93  -  21:49:00  *--*
/. Date: 03-31-93 (09:51)              Number: 24032 of 24035
  To: IOANNIS HADJIIOANNOU          Refer#: 23844
From: LEE BARKER                      Read: NO
Subj: Current Drive                 Status: PUBLIC MESSAGE
Conf: R-TP (552)                 Read Type: GENERAL (A) (+)

┌─┬───────────────    Ioannis Hadjiioannou    ───────────────┬─╖
│o│ How can I find which drive is  the default drive?        │o║
╘═╧══════════════════════════════════════════════════════════╧═╝
While X may mark the spot, period marks/inhibits the drive.

Uses Dos;
begin
  Writeln(fexpand('.'));
end.

As For getting the drive Label look up findfirst With an
attribute of "directory".
---
 ■ Tags τ Us ■  Operator! Trace this call and tell me where I am
 * Suburban Software - Home of King of the Board(tm) - 708-636-6694
 * PostLink(tm) v1.05  SUBSOFT (#715) : RelayNet(tm) Hub

(61 min left), (H)elp, end of Message Command? 
