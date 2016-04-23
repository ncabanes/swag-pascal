{ Gets or puts information in the Intra-Application Communications Area (ICA).
  Part of the Heartware Toolkit v2.00 (HTmemory.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

PROCEDURE ICA(GetPut : boolean;
      var SourceDest);
{ DESCRIPTION:
    Gets or puts information in the Intra-Application Communications Area (ICA).
  SAMPLE CALL:
    ICA(True,MyVar);
    or
    ICA(False,MyVar);
  RETURNS:
    See notes (bellow).
  NOTES:
    These sixteen bytes, called the Intra-Application Communications Area
      (ICA) can be used by any program for any purpose, Usually it is used
      to pass data betwenn two or more programs. Not many programs use this
      area. If you wish to use this area, make sure checksums and signatures
      are used to insure the reliability of your data, since another program
      may also decide to use this area.
           [in The Assembly Language Database, Peter Norton]
    The incomming SourceDir variable may be of any type.
    Nevertheless, the size of that variable MUST be at least 16 bytes long,
      or unpredictable results may occur...
    The programer before changing this area contents, should keep its
      contents in a variable for later restore. It is not a very good ideia
      to not restore the contents before the program end, because that
      area may being used by another program. }

BEGIN { ICA }
  if GetPut then
    Move(Mem[$0000:$04F0],SourceDest,16)
  else
    Move(SourceDest,Mem[$0000:$04F0],16)
END; { ICA }
