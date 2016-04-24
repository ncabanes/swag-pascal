(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0085.PAS
  Description: Renaming Dos Files
  Author: RANDON SPACKMAN
  Date: 02-21-96  21:04
*)


program renamer;
uses crt,dos;
var
   f:file;
   s,s2,s3:string;
   on:integer;
   found:searchrec;
begin
     on:=1;
     write('Start of name: ');
     readln(s);
     findfirst('*.*',anyfile,found);
     while doserror=0 do begin
           if found.attr and directory=0 then begin
              assign(f,found.name);
              str(on,s2);
              while length(s2)+length(s)<8 do s2:='0'+s2;
              s2:=s+s2;
              s3:=found.name;
              if pos('.',s3)=0 then s3:=s3+'.';
              s2:=s2+copy(s3,pos('.',s3),length(s3));
              rename(f,s2);
              inc(on);
              end;
           findnext(found);
           end;
     end.


