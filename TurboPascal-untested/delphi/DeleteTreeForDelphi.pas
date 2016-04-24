(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0126.PAS
  Description: Delete Tree for DELPHI
  Author: DUNCAN MCNIVEN
  Date: 02-21-96  21:04
*)

{
>I still need some help writing a program similar to MS-DOS DELTREE.
>Even though I RTFM, I aparrently don't understand the syntax for
>FindFirst and FindNext.

I was just playing with this yesterday.  The following is not pretty,
but it should work.  Hope it helps.
}
procedure DelTree(const RootDir  : String);
var
  SearchRec : TSearchRec;
begin

Try

    ChDir(RootDir);  {Path to the directory  given as parameter }

    FindFirst('*.*',faAnyFile,SearchRec);

    Erc := 0;
    while Erc = 0 do  begin

        { Ignore higher level markers }
        if      ((SearchRec.Name <> '.' )
        and  (SearchRec.Name <> '..')) then begin

              if  (SearchRec.Attr and faDirectory>0) then begin
                    { Have found a directory, not a file.
                       Recusively call ouselves to delete its files }
                     DelTree(SearchRec.Name);
                     end
              else begin
                    {Found a file.  Delete it or whatever
                     you want to do here }
                     end;
         end;

          Erc := FindNext (SearchRec);
          { Erc is zero if FindNext successful,
            otherwise Erc = negative DOS error }

           {Give someone else a chance to run}
            Application.ProcessMessages;

    end;

finally
      { If we are not at the root of the disk, back up a level }
      if Length(RootDir) > 3 then
          ChDir('..');
      { I guess you would remove directory RootDir here }
end;

end;

