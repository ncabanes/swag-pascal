(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0004.PAS
  Description: Directory With FileSpec
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
>Is there any easy way do turn *.* wildcards into a bunch of Filenames?
>This may be confusing, so here's what I want to do:
>I know C, basic, pascal, and batch.  (but not too well)
>I want to make a Program to read Files from c:\ece\ and, according to my
>Filespecs ( *.* *.dwg plot???.plt hw1-1.c) I want the Program to take
>each File individually, and Compress it and put it on b:.  I also want
>the Program to work in reverse.  I.E.:  unpack Filespecs from b: and
>into c:.  I want this because I take so many disks to school, and I
>don't like packing and unpacking each File individually.  I also don't
>want one big archive.  Any suggestions as to how to do it, or what I
>could do is appreciated.

The easiest way would be to use the findfirst() and findnext()
Procedures. Here's a stub Program in TP. You'll need to put code in
the main routine to handle command line arguments, and call fsplit()
to split up the Filenames to pass to searchDir() or searchAllDirs().
then just put whatever processing you want to do With each File in
the process() Procedure.
}

Uses
  Dos, Crt;

Var
  Path      : PathStr;
  Dir       : DirStr;
  Name      : NameStr;
  Ext       : ExtStr;
  FullName  : PathStr;
  F         : SearchRec;
  Ch        : Char;
  I         : Integer;

Procedure Process(dir : DirStr; s : SearchRec);
begin
  Writeln(dir, s.name);
end;


{
 Both searchDir and searchAllDirs require the following parameters
 path  - the path to the File, which must end With a backslash.
         if there is no ending backslash these won't work.
 fspec - the File specification.
}

Procedure SearchDir(Path : PathStr; fspec : String);
Var
  f : SearchRec;
begin
  Findfirst(Path + fspec, AnyFile, f);
  While DosError = 0 do
  begin
    Process(path, f);
    Findnext(f);
  end;
end;

Procedure searchAllDirs(path : pathStr; fspec : String);
Var
  d : SearchRec;
begin
  SearchDir(Path, fspec);
  FindFirst(Path + '*.*', Directory, d);
  While DosError = 0 do
  begin
    if (d.Attr and Directory = Directory) and (d.name[1] <> '.') then
    begin
      SearchAllDirs(Path + d.name + '\', fspec);
    end;
    Findnext(d);
  end;
end;

begin
  SearchAllDirs( '\', '*.*' );
end.

