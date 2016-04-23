
uses crt,dos;


{ GERA.PAS  - Global search utility to find and delete files.      }
{- drive not specified - uses the current                          }
{- always starts at the root directory and searches every          }
{  directory below it.                                             }
{ C.V. Rutherford }
{ Public domain 12/28/93 }



type
  PathRecPTR = ^PathRecord;
  PathRecord = record
                 RDir: PathStr;
                 Next: PathRecPTR;
               end;

var
  CurTop,
  TempPTR: PathRecPTR;         { Pointer to path references }
  FilesFound : Boolean;        { end of utility display     }

procedure CheckAborted( ch : char );
begin
  if ch in [#27,^C] then
     begin
       writeln(#08,'... User abort !');
       HALT(0);
     end;
end;

{ PushDir/PopDir/ClearDir }
{ are used to save and restore directories during search }

procedure PushDir( Rdir : PathStr );
begin
  New( TempPTR );
  TempPTR^.RDir:= RDir;
  TempPTR^.Next:= NIL;
  if CurTop = Nil then
     CurTop := TempPTR
  else
     begin
       TempPTR^.Next := CurTop;
       CurTop := TempPTR;
     end;
end;


procedure PopDir(Var RDir : string );
begin
  if CurTop <> NIL then
     begin
       TempPTR := CurTop;
       CurTop := CurTop^.Next;
       RDir := TempPTR^.RDir;
       Dispose( TempPTR );
       TempPTR := NIL;
     end;
end;


procedure ClearDir;
begin
  while CurTop <> NIL do
    begin
      TempPTR := CurTop;
      CurTop := CurTop^.Next;
      FreeMem( TempPTR, sizeof(PathRecord ));
      TempPTR := NIL;
   end;
end;


procedure GetDir( PathN : string );
var
  f : searchrec;

begin
  findfirst(PathN+'*.*', directory,f);
  while doserror = 0 do
    begin
      if (f.attr and directory) = directory then
         begin
           if (f.name <> '.') and (f.name <> '..') then
              pushdir( PathN +f.name+'\');
         end;
      findnext(f);
     end;
end;


procedure EraseFile( Source : string );
var
 F:  file;
 ErrorCode : word;
 ch : char;

begin
  write('Delete: ', Source+' [N]',#08+#08 );
  ch := Upcase( Readkey );
  if ch = 'Y' then
     begin
       write('Y');
       Assign(F, Source);
       {$I-} Reset(F); {$I+}
       ErrorCode := IOResult;
       if errorCode = 0 then
          begin
            Close(F);
            {$I-} Erase(F); {$I+}
            ErrorCode := IOResult
          end;
       if ErrorCode <> 0 then
          write(']    ', '... File Access denied');
     end
  else
     CheckAborted( ch );
  writeln;
end;


procedure GetFiles( PathN, FName : string );
var
  f : searchrec;

begin
  findfirst(PathN+FName, anyfile,f);

  while keypressed do CheckAborted( Readkey );   { check for user abort }

  { 18 the only error we should get since we read the directory once before }
  { indicating no more file found }

  while doserror <> 18 do
    begin
      if (F.attr and directory) <> Directory then
         begin
           erasefile(PathN+f.name);        (* ERASE REFERENCE *)
(*         writeln(PathN+F.Name);           FIND REFERENCE  *)
           FilesFound := TRUE;
         end;
      findnext(f);
     end;
end;


procedure GlobalErase(Pname, mask : string );
begin
  pushdir(Pname);                { Push the root directory }
  while curtop <> NIL do
    begin
      popdir( pname );           { get directory from list }
      getdir( pname );           { get its subdirectories  }
      write('*',#13);            {* provide an indicator   }
      getfiles(pname, mask);     { get directory files     }
      write('-',#13);            {* provide an indicator   }
    end;
  write(' ',#13);                {* clear the indicator    }
end;

var
 Dir: DirStr;
 Name: NameStr;
 Ext: ExtStr;

begin
  CheckBreak := FALSE;           { use our abort }
  FilesFound := FALSE;
  if paramcount > 0 then
     begin
       FSplit(Paramstr(1), Dir, Name, Ext);
       Dir := fexpand(Dir);               { Expand to get drive if not }
                                          { specified }
       Dir := Copy(Dir,1,1)+':\';         { Get drive or default drive }

       writeln;
       writeln('Global Erase..  '+Dir+name+Ext);

       if ( Name='') or (Ext='') or (Ext='.') then
          writeln('Invalid filename.. ?' )
       else
          begin
            GlobalErase( Dir, Name+Ext );
            if not FilesFound then
               writeln(Name+Ext+' not found ?');
          end;
     end
  else
     writeln('Filename Not Specified.. ?');
  cleardir;
end.
