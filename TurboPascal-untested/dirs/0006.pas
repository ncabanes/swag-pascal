Procedure ClrDir ( path : pathStr );

Var FileInfo : searchRec;
    f        : File;
    path2    : pathStr;
    s        : String;

begin FindFirst ( path + '\*.*', AnyFile, FileInfo );
      While DosError = 0 Do
      begin if (FileInfo.Name[1] <> '.') and (FileInfo.attr <> VolumeId) then
              if ( (FileInfo.Attr and Directory) = Directory ) then
                begin Path2 := Path + '\' + FileInfo.Name;
                      ClrDir ( path2 );
                end
            else
              if ((FileInfo.Attr and VolumeID) <> VolumeID) then begin
                Assign ( f, path + '\' + FileInfo.Name );
                Erase ( f );
              end;

            FindNext ( FileInfo );
      end;

      if (DosError = 18) and not ((Length(path) = 2)
                                   and ( path[2] = ':')) then
        RmDir ( path );

end;
