
{I have written a program that searches for a specific directory on the
disk. The sourcecode is included. }

program XD;

uses Dos, Crt,strings;

var
  fdir, Sdir: array[0..255] of Char;
  Scherm     : Text ;
  vlag : byte;
  ch : char;
  i,l,x,y : integer;
  temp,found,dir : string;

procedure CursorOff; assembler;
     asm
     mov   ah,1                         { turn off cursor }
     mov   cx,2304h
     int   10h
     end; {CursorOff}

procedure CursorOn; assembler;
     asm
     mov   ah,1                         { turn off cursor }
     mov   cx,0304h
     int   10h
     end; {CursorOn}

 procedure Show( Direct : String ) ;
  var
   {
    Info must be a local parameter of Show. This way the information in the
    SearchRec is saved when a subdirectory is explored using recursion.
   }
   Info : SearchRec ;
  begin
    { We have to search the directory in Direct, build the search-path }
   if ( Direct[Length(Direct)] <> '\' ) THEN Direct := Direct + '\' ;
   ch := '1';
   FindFirst( Direct+'*.*', AnyFile, Info ) ;
   { As long as we have 'things' in the Direct directory, look at them }
   while ( DosError = 0 ) do
    begin
     if ( (Info.Name <> '.') and (Info.Name <> '..') and
          ( (Info.Attr and Directory) = Directory) )
      then
       begin
        gotoxy(x,y);
        clreol;
        Write(Direct+Info.Name) ;
         for i:= 0 to l-1 do fdir[i] := info.name[i+1];
         i:= StrComp(fdir, sDir);
         if keypressed then ch := readkey;
         IF ch=#27 THEN BEGIN
                             writeln;
                             writeln;
                             Writeln('  ...User Break...');
                             writeln;
                             cursoron;
                             HALT(1);
                            END;
         if i=0 then begin
                                     found := direct+info.name;
                                     writeln;
                                     vlag := 1;
                                     break;
                                    end;
        { We will now search that directory }
        Show(Direct+Info.Name ) ;
       end ;
     { Are there any more things out there ? If so, look at them }
     if vlag = 1 then break;
     FindNext( Info ) ;
    end ;
  end ;

procedure help;
begin
writeln;
writeln('Syntax : XD.EXE [dir]');
writeln;
cursoron;
halt(1);
end;

 begin
 cursoroff;
 vlag := 0;
 found := ' ';
 dir := paramstr(1);
 l := length(paramstr(1));
 Writeln;
 WRITELN (' X',chr(68),' v1.3 By ',chr(72),'arol',chr(100),'M',chr(97),'ss',chr(101),'link ');
 if paramcount<1 then help;
for i := 0 to l do
  begin
   dir[i+1] := UpCase(dir[i+1]);
   sdir[i] := dir[i+1];
  end;
 Writeln;
 writeln ('  Searching for  : [',DIR,'*]');;
 Write ('  Current : ');
 x := wherex;
 y := wherey;
 GetDir(0,temp);
 show(temp);
 gotoxy(1,y-1);
 if vlag=1 then chdir(found) else begin
                                   chdir(temp);
                                   writeln;
                                   clreol;
                                   Writeln('  Could not find : [',Dir,'*]');
                                  end;

 writeln;
 cursoron;
end.



