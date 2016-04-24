(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0008.PAS
  Description: QWK File format
  Author: KELLY SMALL
  Date: 09-26-93  10:51
*)

*)
From: KELLY SMALL                  Refer#: NONE
Subj: QWK stuff                      Conf: (1221) F-PASCAL
*)

Type Array25 = Array[1..25] of Char;
     HdrRec = Record
       MessageStatus : Char;
       MessageNumber : Array[1..7] of Char;
       MessageDate   : Array[1..8] of Char;
       MessageTime   : Array[1..5] of Char;
       MessageTo     : Array25;
       MessageFrom   : Array25;
       MessageSubject: Array25;
       MessagePS     : Array[1..12] of Char;
       MessageRefer  : Array8;
       TotalBlock    : Array[1..6] of Char;
       MessageKilled : Char;
       Conference    : Integer;
       Dummy         : Array[1..3] of Char;
       End;

Var Header : HdrRec;
    F      : File;

begin
  assign(f,'message.dat');
  reset(f);
  read(f,header);
end.

But this is only the begining, you will need to read in all the
message as 128 byte blocks and convert it for editing.  It's an
array of char, not strings, and it uses #227 for an End of Line,
rather then the conventional carriage return/line feed.


