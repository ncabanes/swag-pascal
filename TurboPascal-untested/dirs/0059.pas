
Remove all files and subdirectories
Q:
Has anyone run across a function that will recursively remove files and
directories given a starting subdirectory path. Failing that I would
settle for a simple RemoveDirectory function that will just remove a
given directory.

A:
This doesn't check for attributes being set, which might preclude deletion
of a file. Put a {$I-} {$I+} pair around the functions that cause the problem.

procedure removeTree (DirName: string);
var
   FileSearch:  SearchRec;
begin
   { first, go through and delete all the directories }
   chDir (DirName);
   FindFirst ('*.*', Directory, FileSearch);
   while (DosError = 0) do begin
      if (FileSearch.name <> '.') AND (FileSearch.name <> '..') AND
         ( (FileSearch.attr AND Directory) <> 0)
      then begin
         if DirName[length(DirName)] = '\' then
            removeTree (DirName+FileSearch.Name)
         else
            removeTree (DirName+'\'+FileSearch.Name);
         ChDir (DirName);
      end;
      FindNext (FileSearch)
   end;

   { then, go through and delete all the files }
   FindFirst ('*.*', AnyFile, FileSearch);
   while (DosError = 0) do begin
      if (FileSearch.name <> '.') AND (FileSearch.name <> '..') then
         Remove (workdir);
      end;
      FindNext (FileSearch)
   end;
   rmDir (DirName)
end;