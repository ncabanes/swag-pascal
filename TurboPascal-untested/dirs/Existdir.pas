(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0036.PAS
  Description: ExistDir
  Author: JOSE CAMPIONE
  Date: 08-25-94  09:07
*)

(*

  Here are three functions that I wrote to detect directories. The first 
  one uses findfirst, the second uses chdir and the third uses getfattr.
  According to my benchmarkings the third one is the fastest (and the one 
  I preffer) . All of them need the DOS unit and will do the job as 
  requested, however, they are not exactly equivalent: The first function
  will return false for d:= '<disk>:\', '\' or '..\'. They all return true 
  if the drive has been SUBSTituted.

  Here are the results with some extreme strings (T = true, F = false)...

         Function --->      1      2      3 
         -----------------------------------
          d:=  ''           F      F      F
          d:=  '.'          T      T      T
          d:=  '..'         F      T      T    (*)
          d:=  '.\'         F      F (@)  T
          d:=  '..\'        F      T      T    (*)
          d:=  '\'          F      T      T
          d:=  '/'          F      T (#)  F  
          d:=  'c:\'        F      T      T
          d:=  'c:\.'       F      T      T

      (*)  while logged in a non-root directory.
      (@)  chdir('.\') is not recognized as a valid change!
      (#)  chdir('/') switches to the root!

  In all other situations the three functions return the same result.
    
  ---------------[cut]-----------------------------------------------
  
  function direxist1(d:pathstr): boolean;
  var
    dirinfo: searchrec;
    len : byte;
  begin
    len:= length(d);
    if (d[len] = '\') and          {if d has a trailing slash and is...  }
    (len > 3) then                 {other than "<disk>:\", "..\"...      }
      dec(d[0]);                   {remove the trailing slash.           }
    findfirst(d,directory,dirinfo);{call findfirst.                      }
    direxist1:= doserror = 0;      {report boolean result                }
  end;

  function direxist2(d:pathstr) : boolean;
  var
    curdir: pathstr;
    exist : boolean;
    len   : byte;
  begin
    len:= length(d);
    if (d[len] = '\') and          {if d has a trailing slash and is...  }
    (len > 3) then                 {other than "<disk>:\" or "..\"...    }
      dec(d[0]);                   {remove the trailing slash.           }
    getdir(0,curdir);              {get current dir                      }
    {$I-} chdir(d); {$I+}          {attempt changing directory           }
    exist := IOResult = 0;         {test IOResult                        }
    if exist then chdir(curdir);   {if exist then go back to current dir }
    direxist2:= (d <> '') and exist;
  end;

  function direxist3(d: pathstr): boolean;
  var
    f   : file;
    attr: word;
    len : byte;
  begin
    len:= length(d);
    if (d[len] = '\') then         {if d has a trailing slash...         }
      dec(d[0]);                   {remove the trailing slash.           }
    d:= d + '\.';                  {add '\.' to d                        }
    assign(f,d);                   {assign d to f                        }
    getfattr(f,attr);              {get the attribute word               }
    direxist3 := ((attr and directory)=directory);
                                   {return true if attr is directory     }
  end;


