(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0032.PAS
  Description: Recursing ALL Dirs
  Author: STEVE ROGERS
  Date: 08-24-94  13:19
*)


  uses dos;
  procedure ProcessAllFiles(dir : dirstr);
  var
    d : searchrec;

  begin
    while (dir[length(dir)] = '\') do dec(dir[0]);

    { this gets the files }
    findfirst(dir+'\*.*',anyfile+hidden+system+readonly,d);
    while (doserror = 0) do begin
      process(d.name);
      findnext(d);
    end;

    { this gets the subs, recursively }
    findfirst(dir+'\*.*',directory,d);
    while (doserror = 0) do begin
      if (d.attr and directory = directory) then
        ProcessAllFiles(dir+'\'+d.name);
      findnext(d);
    end;

  end;

