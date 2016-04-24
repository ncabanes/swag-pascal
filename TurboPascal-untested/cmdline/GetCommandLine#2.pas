(*
  Category: SWAG Title: COMMAND LINE ROUTINES
  Original name: 0003.PAS
  Description: Get Command Line #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

{
 In TP there is, of course, ParamCount and ParamStr.

 The actual command line can be found in the PSP segment, at offset
 $80 (hexadecimal).  The Byte at $80 contains the count of Characters,
 including the leading delimiter Character (usually a space).

 In TP the PSP segment may be accessed using PrefixSeg.  Note that TP
 omits the carriage-return that normally appends the input Character
 line.  This is a problem For Programs that look For it as the end of
 the String.

 If you're using a non-TP compiler, you'll need to get the PSP segment
 value via a Dos Function $62 call.

 Here's a simple TP Program to illustrate.  Compile it, then invoke
 it With some command-line input...
}
(*********************************************************************)
Program CommandLine;    { CL.PAS }
Var
  CharCount, i : Word;
begin
  CharCount := Mem[PrefixSeg:$80];  { number of input Characters }
  WriteLn('Input Characters: ', CharCount );
  For i := 1 to CharCount DO
    Write( CHR( Mem[PrefixSeg:$80+i] ));
  WriteLn;
end.
(*********************************************************************)

