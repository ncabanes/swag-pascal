(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0006.PAS
  Description: FLOPSIZE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

{
>Does anybody know how to determine the size of a disk drive.  I mean
>whether it is a 360 K drive or 720 K, 1.4 M or 1.2 M drive.  I'm
>working on a Program which has the ability to Format diskettes and
>I want it to be able to come up With the size of a disk drive as a
>default.  I have looked at the equipment flag in the BIOS and the
>only thing I can get out of that is the Type of a disk drive not the
>size.
}
Function VarCMOS(i : Byte) : Byte ;
begin
     port[$70]:=i;
     VarCMOS:=port[$71]
end;

Var  b    : Byte ;

begin
     b:=VarCMOS($10);
     if b and $f0<>0 then
     begin
          Write('Drive A: = ');
          Case (b and $f0) shr 4 of
               1 : Write('5" 360 Ko');
               2 : Write('5" 1,2 Mo');
               3 : Write('3" 720 Ko');
               4 : Write('3" 1,44 Mo')
          end;
     end;
     if b and $f<>0 then
     begin
          Write(', B: = ');
          Case b and $f of
               1 : Writeln('5" 360 Ko');
               2 : Writeln('5" 1,2 Mo');
               3 : Writeln('3" 720 Ko');
               4 : Writeln('3" 1,44 Mo')
          end;
     end else WriteLn ;
end.

