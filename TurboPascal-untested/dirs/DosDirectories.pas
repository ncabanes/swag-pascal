(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0053.PAS
  Description: DOS Directories
  Author: DAVID VAN DRIESSCHE
  Date: 02-21-96  21:03
*)

{
 Below you'll find a program that lists all the directories on the C drive. It
 can be extended very easily but it just wanted to show the basics. (It was
 part of a program that did for dos what the DELTREE command does now. I used
 to work (good old days) with Dos 3.3 which doesn't have a DELTREE command)
 
 {-------------------------------------------------------------------------}
 { programmer : David van Driessche  (2:291/1933.13)                       }
 { language   : Borland Pascal v7.0                                        }
 { purpose    : explaining recursive directory listings                    }
 {-------------------------------------------------------------------------}

 {- This code is public domain, feel free to do with it any descent thing -}

 program GetDirInfo ;

 uses Dos, Crt ;

 var
  DirCounter : Integer ;
  Scherm     : Text ;

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
   FindFirst( Direct+'*.*', AnyFile, Info ) ;
   { As long as we have 'things' in the Direct directory, look at them }
   while ( DosError = 0 ) do
    begin
     if ( (Info.Name <> '.') and (Info.Name <> '..') and
          ( (Info.Attr and Directory) = Directory) )
      then
       begin
        { We found one directory more }
        Inc ( DirCounter ) ;
        { Show what we found }
        Writeln( Direct+Info.Name ) ;
        { We will now search that directory }
        Show( Direct+Info.Name ) ;
       end ;
     { Are there any more things out there ? If so, look at them }
     FindNext( Info ) ;
    end ;
  end ;

 begin
  AssignCrt( Scherm ) ;
  ReWrite( Scherm ) ;
  DirCounter := 0 ;
  Show ( 'C:\' ) ;
  Writeln( Scherm ) ;
  Writeln( Scherm, 'Number of directories = ', DirCounter:0 ) ;
 end.


