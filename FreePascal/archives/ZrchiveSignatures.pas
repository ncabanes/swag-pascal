(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0031.PAS
  Description: Zrchive Signatures
  Author: SERGE PAQUIN
  Date: 05-26-95  22:58
*)


{ Updated ARCHIVES.SWG on May 26, 1995 }

{
> Therefore I need the fileformats of all
> known archive types. And in special:

  Here are the ones I know there OffSet in the File and the Sig.

  Format        OffSet           ASCII Sequence
  ------        ------           --------------

   ZIP            1               #80 + #75 + #3 + #4
   ARJ            1               #96 + #232
   LHA            3               #45 + #108 + #104
   ZOO            1               #90 + #79 + #79
   SQZ            1               #72 + #76 + #83 + #81 + #90
   PAK            1               #26 + #10
   ARC            1               #26
}

