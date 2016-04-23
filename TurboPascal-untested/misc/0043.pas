(*
From: DAVID DANIEL ANDERSON        Refer#: NONE
Subj: QUIET USING BLOCKREAD
*)

uses dos ;
const
     bufsize  = 16384;
     progdata = 'QUIET- Free DOS utility: quiets noisy programs.';
{!}  progdat2 =
'V1.00: August 27, 1993. (c) 1993 by David Daniel Anderson - Reign Ware.';
{!}  usage   =
     'Usage:  QUIET noisy_prog  {will OVERWRITE the file - use a backup!!!}';
     outname = 'o$_$_$$!.DDA';
     tmpname = 't$_$_$$!.DDA';
type
   buffer       = array [1..bufsize] of char;
var
   buf          : buffer ;
   infile,
   outfile      : file ;
   bytesread,
   byteswritten : word ;

   nextchar     : char ;

   checknext,
   extra_char,
   lastbyte     : boolean ;

   fdt          : longint ;

   dirinfo       : searchrec ;   { contains filespec info.    }
   spath         : pathstr ;     { source file path,          }
   sdir          : dirstr ;      {             directory,     }
   sname         : namestr ;     {             name,          }
   sext          : extstr ;      {             extension.     }
   sfn, dfn, tfn : string [64];  { Source/ Dest/ Temp FileName, including dir }
   filesdone     : array [1..512] of string [64];   { table of each dir+name  }
   done          : boolean ;  { done is used so a file is not processed twice }
                              { used with the array "filesdone" because a bug }
                              { (in DOS I think) causes files to be selected  }
                              { based on FAT placement, rather than name when }
                              { wildcards are implemented.  The BUG allows    }
                              { files to be done repeatedly, every time they  }
                              { are encountered.                              }

   i, nmdone      : word ;    { i is a counter,  }
                              { nmdone is number of files wrapped }


procedure showhelp ( errornum : byte );
var
    message : string [80];
begin
    writeln ( progdata );
    writeln ( progdat2 );
    writeln ;
    writeln ( usage );
    writeln ;
                       {!}  { all of the case messages got reformatted }
    case errornum of
      1 : message :=
'you must specify -exactly- one filespec (wildcards are OK).';
      2 : message :=
'could not open the "noisy" file: ' + sfn + ' (may be read-only).';
      3 : message :=
'could not open the temp file (does ' + outname + ' already exist?).';
      4 : message :=
'the blockread procedure failed ( error reading "noisy" file: ' + sfn + '.';
      5 : message :=
'rename procedure failed, "quiet" file is ' + outname + '.';
      6 : message :=
'original file was read only, is renamed to ' + tmpname + '.';
      7 : message :=
'you cannot just specify a path, add "*.*" or "\*.*" for all files.';
      8 : message :=
'could not find any matching files.';
    end;
    writeln ( 'ERROR: (#',errornum,') - ', message );
    halt ( errornum );
end;
procedure openfiles(var ofl, nfl : file; name1, name2 : string);
begin
{$i-}
     assign ( ofl, name1 );
     reset ( ofl,1 );
     if ioresult <> 0 then
        showhelp (2);                          { unable to open ??? }

     assign ( nfl, name2 );
     reset ( nfl );
     if ( ioresult <> 0 ) then begin       {  if file does -NOT- exist  }
        rewrite ( nfl,1 );                 { yet, it is save to proceed }
        if ioresult <> 0 then                  { unable to open ??? }
           showhelp (3) ;
     end
     else
        showhelp (3) ;
{$i+}
end;

{!} procedure quietbuf
     ( var bufr : buffer; var chknext : boolean ; var noises : word );
const
     noisea  = 'µ';
     noiseb  = 'a';
     NOPChar = 'É';
var
     bf_indx  : word ;
begin
     for bf_indx := 1 to ( sizeof ( bufr ) - 1 ) do
         if ( ( bufr [ bf_indx ]    = noisea ) and
              ( bufr [ bf_indx +1 ] = noiseb ) ) then begin

                noises := noises + 1 ;
                bufr [ bf_indx ]    := NOPChar;
                bufr [ bf_indx +1 ] := NOPChar;
         end;
     chknext := ( bufr [ sizeof ( bufr ) ] = noisea );
end;

procedure quietfile ( var infile, outfile : file );
var
     noises : word ;
begin
     noises := 0;
     repeat
{$i-}     blockread  ( infile, buf, bufsize, bytesread );   {$i+}
          if ioresult <> 0 then
             showhelp (4) ;
          quietbuf ( buf, checknext, noises );

          if ( checknext and ( not eof ( infile ))) then begin
             blockread ( infile, nextchar, 1 );
             extra_char := true ;
             if nextchar = 'a' then begin
                noises := noises + 1 ;
                buf [ sizeof ( buf ) ] := 'É';
                nextchar := 'É';
             end;
          end
          else extra_char := false ;

          blockwrite ( outfile, buf, bytesread, byteswritten );
          if extra_char then
             blockwrite ( outfile, nextchar, 1 );
          lastbyte := (( bytesread = 0 ) or ( bytesread <> byteswritten ));
     until lastbyte ;
     writeln ( noises, ' noises found.' );
end;

begin  { MAIN }
     if paramcount <> 1 then showhelp (1);
     nmdone := 1;                       { initialize number done to one since }
                                    { count is incremented after process ends }

     for i := 1 to 512 do               { initialize array                    }
         filesdone[i] := '';            { (I'm not sure if this is needed)    }

     spath := paramstr (1);             { source path is first parameter      }

  fsplit ( fexpand (spath),sdir,sname,sext); { break up path into components  }
     if (sname = '') then               { - but quit if only a path and no    }
         showhelp(7);                   { name is given                       }

     findfirst (spath, archive, dirinfo); { find the first match of filespec  }
     if doserror <> 0 then
        showhelp(8);

     while doserror = 0 do              { process all specified files         }
     begin
          sfn := sdir+dirinfo.name;    { should have dir info so we are not   }
                                       { confused with current directory (?)  }
                                      { IS needed for dest and temp filenames }

          done := false;               { initialize for each "new" file found }
          for i := 1 to 512 do
              if sfn = filesdone[i] then { check entire array to see if we    }
              done := true;              { have done this file already        }

          if not done then begin        { if not, then                        }
              filesdone[nmdone] := sfn; { say we have now                     }
              dfn := sdir+outname;      { give both dest and                  }
              tfn := sdir+tmpname;      {       and temp files unique names   }

              openfiles ( infile, outfile, sfn, dfn );
              write ( 'Quieting ', sfn, ', ' );
              quietfile ( infile, outfile );

              getftime ( infile, fdt );
              setftime ( outfile, fdt );

              close (infile);           { close in                            }
              close (outfile);          {   and out files                     }

{i-}
              rename ( infile, tfn );   { rename in to temp and then   }
              if ioresult <> 0 then
                 showhelp (5);
              rename ( outfile, sfn );  { out to in, thereby SWITCHING  }
              erase ( infile );         { in with out so we can erase in (!)  }
              if ioresult <> 0 then
                 showhelp (6);
{$i+}
              nmdone := nmdone + 1;     { increment number processed          }
          end;  { if not done }
          findnext(dirinfo);            { go to next (until no more)          }
     end;  { while }
end.


                                     QUIET
                    Free DOS utility: quiets noisy programs
                         Version 1.00 - August 27, 1993
                                    (c) 1993
                                       by
                             David Daniel Anderson
                                   Reign Ware





QUIET quiets noisy programs, by replacing certain noisemaking program
codes.

WARNING!!! QUIET OVERWRITES THE INPUT FILE, SO MAKE SURE THAT YOU
EITHER WORK ON A -COPY- OF YOUR FILE(S) OR YOU KNOW WHAT YOU ARE
DOING BEFORE YOU START.

Usage:  QUIET noisy_prog

Examples:

   QUIET hangman.com
   QUIET *.exe
   QUIET pac*.*
   QUIET d:\games\fire.com

QUIET needs one and only one parameter on the command line: the file
to be silenced.  By using wildcards (* and ?), multiple files can be
processed in one pass.  (See the DOS manual for wildcard info.)

QUIET will maintain the original date and time of the file(s).


                             How it works:

QUIET simply replaces the two-byte sequence: µa  with: ÉÉ
In hex, that is:   E6 61   and:   90  90.
In decimal it is: 230 97   and:  144 144.

The E6 61 code is simply an instruction to activate the speaker, and
the 90 90 code is simply an instruction to do nothing.


              Possible complications/ reasons for failure:

1) Some programs check themselves, and will not work at all if they
have been changed.

2) Many programs make noise by other methods, and will not be silenced.

3) If the file was read-only, it cannot be processed.

4) Some virus detectors will complain if you try this on a file which
you have told the watch dog program to monitor.

Note: other errors are mentioned by the program when it encounters them.

---
 ■ SLMR 2.1a ■
 ■ RNET 2.00m: ILink: Channel 1(R) ■ Cambridge, MA ■ 617-354-7077
