(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0032.PAS
  Description: Modify EXE constants
  Author: GABE KRUPA
  Date: 08-27-93  20:55
*)

(*
GABE KRUPA

> I need to add some information to the end of an EXE file and be able
> Say a PCX image for example.  I'm concerned about the EXE file alread
> open due to being executed.  Does info tacked to the end of an EXE ge
> into memory automatically, etc.  I haven't tried this yet but am abou
> hoping someone who has tried it can assist me to avoid some of the pi
> they may have encountered.  Thanks.  (BTW, I am experienced in Pas &

  Well, I made a unit for that purpose, but my unit only tacks on 1K of
storage space... You can make it as large as you want it, but it'll be a
REAL time consumer and it might push your text editor to the limits (I'm
not sure if the IDE has a file size limit).

  Here it is (in a VERY shortened version )
}
unit inject1k;

interface
implementation
const doesnt_matter_what_this_is_called : boolean = false;

procedure never_really_call_this_procedure;
begin
  if doesnt_matter_what_this_is_called then
    inline( 228/229/230/231/231/233/234/  { this I use for a ID string }
            234/234/234/234/234/234/234/
            234/234/234/234/243/234/234/
{ repeat as many times until you get enough .. each '234/' is 1 byte }
            234/234/234/234/234/234/234/
            234/234/234/234/234/234/234/  { this is the actual 'junk' }
           ); { inline }
end; { procedure }

end. { unit }
{
  I only inject 1024 into my EXE file... If you want, you can make
identical units like that, but the DATA area will NOT be in one long
string unless all the bytes are in one unit.
  I use the ID string to correctly place the file pointer. Just open the
EXE, read in bytes until you get a 228. Read another, if it's a 229
etc.. Keep looping until you get a 228-229-230-231-232-233-234 and then
you can start reading/writing. It's by no means the easiest way, but I
prefer it over trying to append to the end. I tried that, but I kept
getting errors and such. As long as the PCX file is fairly small, you
won't have too much of a problem.
  I'm not sure what the chances are, they must be pretty slim to find a
string (228-234) one after the other in an EXE. If you think they are
higher, or whatever, just put your own in. You could probably even put
text in like this:
}
inline('D'/'A'/'T'/'A'/' '/'S'/'T'/'A'/'R'/'T'/'S'/' '/'H'/'E'/'R'/'E'/
111/111/111/111  { etc... } );
{
         I hope this helps, or gives you some ideas. Note, the unit will
be about TWICE as large as the number of bytes you inject (maybe 1000
more), but the EXE will only increse by the number you add. I'm pretty
sure that the extra bytes are just data/debug info in the TPU file.
*)

{
MARK LEWIS

> I need to add some information to the end of an EXE file and be able
> Say a PCX image for example.  I'm concerned about the EXE file alread

[... trim ...]

> Well, I made a unit for that purpose, but my unit only tacks on
> 1K of storage space... You can make it as large as you want it,
> but it'll be a REAL time consumer and it might push your text
> editor to the limits (I'm not sure if the IDE has a file size
> limit). Here it is (in a VERY shortened version )
> unit inject1k;

[... trim ...]

interesting<<smile>>... i never thought of doing it like that.. hehe.. here's
a unit i got from this echo or the other PASCAL echo several years ago.. i've
used it in self-limiting programs (ones that only run a certain number of
times) and other programs that may be subject to hacking of various forms...
i've modified it slightly for my purposes...
}
unit selfmod;

{ Allows a program to self modify a typed constant in the .exe file.  It     }
{ also performs an automatic checksum type .exe file integrity check.        }
{ A longint value is added to the end of the exe file.  This can be read by  }
{ a separate configuration program to enable it to determine the start of    }
{ the programs configuration data area.  To use this the configuration       }
{ typed constant should be added immediately following the declaration of    }
{ ExeData.                                                                   }
{ Where this unit is used, it should always be the FIRST unit listed in the  }
{ uses declaration area of the main program.                                 }
{ Requires DOS 3.3 or later.  Program must not be used with PKLite or LZExe  }
{ or any similar exe file compression programs.                              }
{ The stack size needed is at least 9,000 bytes.                             }

interface

type
  ExeDatatype    = record
                     IDStr      : string[8];
                     FirstTime  : boolean;
                     Hsize      : word;
                     ExeSize    : longint;
                     CheckSum   : longint;
                     StartConst : longint;
                   end;

const
  ExeData : ExeDatatype = (IDStr     : 'IDSTRING';
                           FirstTime : true;
                           Hsize     : 0;
                           ExeSize   : 0;
                           CheckSum  : 0;
                           StartConst: 0);

{ IMPORTANT: Put any config data typed constants here }

procedure Write2Exec(var data; size: word);

{============================================================================}

implementation

procedure InitConstants;
  var
    f           : file;
    tbuff       : array[0..1] of word;

  function GetCheckSum : longint;
    { Performs a checksum calculation on the exe file }
    var
      finished  : boolean;
      x,
      CSum      : longint;
      BytesRead : word;
      buffer    : array[0..4095] of word;
    begin
      {$I-}
      seek(f,0);
      finished := false;  CSum := 0;  x := 0;
      BlockRead(f,buffer,sizeof(buffer),BytesRead);
      while not finished do begin             { do the checksum calculations }
        repeat         { until file has been read up to start of config area }
          inc(CSum,buffer[x mod 4096]);
          inc(x);
          finished := ((x shl 1) >= ExeData.StartConst);
        until ((x mod 4096) = 0) or finished;
        if not finished then                { data area has not been reached }
          BlockRead(f,buffer,sizeof(buffer),BytesRead);
      end;
      GetCheckSum := CSum;
    end;

  begin
    assign(f, ParamStr(0));
    {$I-} Reset(f,1);
    with ExeData do begin
      if FirstTime and (IOResult = 0) then begin
        Seek(f,2);                  { this location has the executable size }
        BlockRead(f,tbuff,4);
        ExeSize := tbuff[0]+(pred(tbuff[1]) shl 9);
        seek(f,8);                                   {  get the header size }
        BlockRead(f,hsize,2);
        FirstTime := false;
        StartConst := longint(hsize+Seg(ExeData)-PrefixSeg) shl 4 +
                      Ofs(ExeData) - 256;
        CheckSum := GetCheckSum;
        Seek(f,StartConst);
        BlockWrite(f,ExeData,sizeof(ExeData));
        seek(f,FileSize(f));
        BlockWrite(f,StartConst,4);
      end
      else
        if GetCheckSum <> CheckSum then begin
          writeln;
          writeln(#7,#7,'Program file has been UNLAWFULLY modified!',#7,#7);
          writeln;
          writeln('It may have a Virus attached or someone may have made');
          writeln('an attempt to HACK it. You should check your system for');
          writeln('virus'' before continuing....');
          writeln;
          writeln('Please reinstall the .EXE file from the original archive.');
          writeln('Aborting....');
          halt(255);
        end
        else
          begin
            writeln;
            writeln('Integrity Validated.');
          end;
    end;  { with }
    Close(f); {$I+}
    if IOResult <> 0 then begin
      writeln('Unable to initialise program');
      halt;
    end;
  end; { InitConstants }

procedure Write2Exec(var data; size: word);
 { writes a new typed constant into the executable file. }
  var
     f          : file;
  begin
    assign(f, ParamStr(0));
    {$I-} Reset(f,1);
    Seek(f,longint(ExeData.Hsize+Seg(data)-PrefixSeg) shl 4 + Ofs(data)- 256);
    BlockWrite(f,data,size);
    Close(f); {$I+}
    if IOResult <> 0 then;
  end; { Write2Exec }

begin
  writeln('Please Standby...');
  InitConstants;
end.


