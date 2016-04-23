{ Gets the number of fixed disks attached to the system.
  Part of the Heartware Toolkit v2.00 (HTdisk.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

FUNCTION Fixed_Disks : byte;
{ DESCRIPTION:
    Gets the number of fixed disks attached to the system.
  SAMPLE CALL:
    NB := Fixed_Disks;
  RETURNS:
    The numbers of fixed disks attached to the system. }

BEGIN { Fixed_Disks }
  Fixed_Disks := Mem[$0000:$0475];
END; { Fixed_Disks }
