(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0003.PAS
  Description: Search All Dirs & Subs #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

AH>>Hi everyone.  I have a small problem.  How does one go about accessing
  >>EVERY File in every directory, sub-directory on a drive? I guess this is
  >>part of the last question, but how do you access every sub-directory?

Unit FindFile;
{$R-}
Interface

Uses Dos;

Type
  FileProc = Procedure ( x : PathStr );

Procedure FindFiles (DirPath : PathStr;      (* initial path           *)
                     Mask : String;          (* mask to look For       *)
                     Recurse : Boolean;      (* recurse into sub-dirs? *)
                     FileDoer : FileProc);   (* what to do With found  *)

(* Starting at <DirPath>, FindFiles will pass the path of all the Files
   it finds that match <Mask> to the <FileDoer> Procedure.  if <Recurse>
   is True, all such Files in subdirectories beneath <DirPath> will be
   visited as well.  if <Recurse> is False, the names of subdirectories
   in <DirPath> will be passed as well. *)

Implementation

Procedure FindFiles (DirPath : PathStr;      (* initial path           *)
                     Mask : String;          (* mask to look For       *)
                     Recurse : Boolean;      (* recurse into sub-dirs? *)
                     FileDoer : FileProc);   (* what to do With found  *)

  Procedure SubVisit ( DirPath : PathStr );
  Var
    Looking4 : SearchRec;

  begin
    FindFirst ( Concat ( DirPath, Mask ), AnyFile, looking4);
    While ( DosError = 0 ) Do begin
      if ( looking4.attr and ( VolumeID + Directory ) ) = 0
       then FileDoer ( Concat ( DirPath, looking4.name ) );
      FindNext ( Looking4 );
      end;   (* While *)
    if Recurse
     then begin
      FindFirst ( Concat ( DirPath, '*.*' ), AnyFile, looking4);
      While ( DosError = 0 ) and ( looking4.name [1] = '.' ) Do
        FindNext (looking4);   (* skip . and .. directories *)
      While ( DosError = 0 ) Do begin
        if ( ( looking4.attr and Directory ) = Directory )
         then SubVisit ( Concat ( DirPath, looking4.name, '\' ) );
        FindNext ( Looking4 );
        end;   (* While *)
      end;   (* if recursing *)
  end;   (* SubVisit *)


begin   (* FindFiles *)
  SubVisit ( DirPath );
end;   (* FindFiles *)

end.

   --------------------------------------------------------------------

Program Visit;

Uses Dos, FindFile;

{$F+}
Procedure FoundOne ( Path : PathStr );  (* MUST be Compiled With $F+ *)
{$F-}
begin
  WriteLn ( Path );
end;

begin
  WriteLn ( '-------------------------------------------------------------');
  FindFiles ( '\', '*.*', True, FoundOne );
  WriteLn ( '-------------------------------------------------------------');
end.

   -----------------------------------------------------------------------

FoundOne will be passed every File & subdirectory.  if you just want the
subdirectories, ignore any name that doesn't end in a '\' Character!

