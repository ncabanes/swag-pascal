(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0012.PAS
  Description: DPMI GetCharAttrib
  Author: BRIAN DAUGHERTY
  Date: 03-04-97  13:18
*)

{
Following is the solution to my problem derived from responses on the
pascal newsgroups.

All SWAG snippets that dealt with grabbing screen chars and attributes
would crash under DPMI.

The following is the solution, thanks to everybody for politely pointing
out my misunderstanding of how DPMI works!!
}

function GetCharAttrib(x, y: byte; var a: byte): char;
VAR
   UseSeg, VModeSeg, Ofs :WORD;
   MonoSystem: boolean;
BEGIN
{ NOTE: Change the Segment from $B800 }
{       to $B000 for MonoChrome.      }

    VModeSeg := seg0040;
    MonoSystem := (MEM[VModeSeg:$0049] = 7);

    if MonoSystem then UseSeg := segB000 else UseSeg := SegB800;

    Ofs := ((Y-1) * 160) + ((X SHL 1) - 1);
    A := MEM[UseSeg:Ofs];
    GetCharAttrib := CHR( MEM[UseSeg:Ofs-1] );
END;


