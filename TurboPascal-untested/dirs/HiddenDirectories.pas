(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0044.PAS
  Description: Hidden Directories
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:51
*)


{Hidden Directory Secrets }
 program DirHide;
 uses dos;
 var f: File;
     Attr: Word;

 begin
   if ParamCount < 1 then
   begin
     writeln('Usage: DirHide directory');
     Halt
   end;

   Assign(f,ParamStr(1));
   GetfAttr(f, Attr);

   if (DosError = 0) AND
     ((Attr AND Directory) = Directory) then
   begin         { v vvvvvvvvv }
     Attr := (Attr - Directory) XOR Hidden; { TOGGLE HIDDEN BIT }
     SetfAttr(f, Attr);

     if DosError = 0 then
       if (Attr AND Hidden) = Hidden then
         writeln(ParamStr(1),' hidden')
       else
         writeln(ParamStr(1),' shown')
   end
 end.
