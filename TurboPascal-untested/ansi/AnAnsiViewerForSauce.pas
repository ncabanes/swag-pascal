(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0044.PAS
  Description: An ANSi Viewer for SAUCE
  Author: JONATHAN DOWNES
  Date: 11-22-95  13:10
*)

{Ok, I was inspired by whoever posted that smooth scrolling text file viewer,
I wanted to add ANSi support and also a File Finder which displays SAUCE info.
So here it is...
The main SmoothScroll routine I pulled from this echo, the ANSI3 TPU started
out as a ANSI tpu in the SWAG, except i rewerote it so that it doesnt use
the standard WRITE routine, which would generate a scroll after 25 lines.
This just keeps filling up video ram for 255 lines, so you can scroll up
and down.

About the only original bit was the file finder, which comes in 2 parts -
ReadDir which makes up a data structure, and GetFile which lets you move
through that structure.

The dodgy.pas is just a TheDraw saved screen.

There is at least one bug I know of, certain ansimation screens dont work
properly, if anyone can tell me why I would be majorly pleased!

any comments, etc, you can get me at
mammoth@sydney.DIALix.OZ.au

cya

Slack Mammoth
}

Program AnsiView;

{$i-}
uses dos,crt,Ansi3;   { ANSI3 also found in the ANSI.SWG file }


{$i dodgey.pas}
{the screen template}


TYPE T_SAUCEREC = RECORD                {pulled from ACiD's SAUCE.TXT}
     ID       : Array[1..5] of Char;
     Version  : Array[1..2] of Char;
     Title    : Array[1..35] of Char;
     Author   : Array[1..20] of Char;
     Group    : Array[1..20] of Char;
     Date     : Array[1..8] of Char;
     FileSize : Longint;
     DataType : Byte;
     FileType : Byte;
     TInfo1   : Word;
     TInfo2   : Word;
     TInfo3   : Word;
     TInfo4   : Word;
     Comments : Byte;
     Flags    : Byte;
     Filler   : Array[1..22] of Char;
END;





type T_EntryType =(Drive,Dir,Sauce,Normal,None);
                 {ie is this entry a Drive, a Directory, a file with SAUCE
                 code, a file without, or the end marker}

type T_DirEntry = record

     Name         : String[12];       {12 chars - filename.ext}
     EntryType    : T_EntryType;
     Tested       : boolean;           {have we checked if its got sauce?}
     SAUCErec     : T_SAUCEREC;

end;

Var

DIR_INFO : array[0..255] of T_DirEntry; {the whole dir structure}
mask     : string[14];   {file mask}
OldPath     : PathStr;   {the file path to here}
OldMode     : Byte;      {old video mode}
Num_Entries : Byte;      {number of entries in the dir}
FileToView    : string[14]; { the file to view, or '*' to exit - set by
getfile}selected    : integer;           {the record currently selected}
Top, Bottom : integer;          {current top and bottom of section of list}
HighDrive   : char;             {letter of the highest disk found}

{---------------------------------------------------------------------------}

procedure shuffle(n : byte);
{make a space at position 'n' by moving top to n up one}
var
loop : byte;

begin
for loop:=255 downto n+1 do
    DIR_INFO[loop]:=DIR_INFO[Loop-1];
end;

{---------------------------------------------------------------------------}

function DiskExist(disk : char) : boolean;
{is there a disk with letter 'disk'?}
var
result  : byte;
d       : byte; {turn letter A-Z into a number 1..255}

begin
     disk:=UpCase(disk);
     d:=ord(disk);
     d:=d-ord('A')+1;
     DiskExist:=(DiskSize(d)>0);

end; {diskexist}



{--------------------------------------------------------------------------}
procedure cls;assembler;
{clears a whole chunk of video ram, not just the current page}
asm
   mov  cx,$8000
   mov  ax,$b800
   mov  es,ax
   xor  di,di
   xor  ax,ax
   rep  stosw

end;


{---------------------------------------------------------------------------}
procedure SetScreenStart(ScanLine:word);
var
StartAddress: word;
begin
  StartAddress := (ScanLine div 16)*80;
  portw[$3D4] := hi(StartAddress) shl 8 + $0C;    { Set start address     }
  portw[$3D4] := lo(StartAddress) shl 8 + $0D;
  repeat until port[$3DA] and 8<>0;               { wait for retrace      }
  portw[$3D4] := (ScanLine mod 16) shl 8 + 8;     { Set start scanline    }
  repeat until port[$3DA] and 8=0;                { wait out retrace      }
end;



{--------------------------------------------------------------------------}

procedure ReadDir; {reads in the current dir, makes the DIR_INFO table}
Var
ThisFileRec : FileRec;     {alias for the file we are working on}
RecNum      : byte;        {tracks number of records built}
f           : File;        {the actual file, which we open to do the SAUCE}
S           : SearchRec;   {info used during the search}
ThisEntry   : T_DirEntry;    {used to alias one entry}
n              : byte;   {counter to find place to insert}
loop           : byte;
loopchar       : char;
begin
     Recnum:=0;             {init the vars}
     for loop:=0 to 255 do DIR_INFO[loop].Entrytype:=none;

     {first find all the directories}

     findfirst('*.*', (Directory),S);     {find all dirs}
     if IOresult >0 then
     begin
          chdir(oldpath);               {if go to a dud disk}
          findfirst(mask, (Directory),S);
     end;


      while ((DosError<>18) and (RecNum<225)) do
      begin
           ThisEntry.Name:=S.Name;

           If (((s.Attr and directory)>0) and (S.name<>'.'))then
           begin
                ThisEntry.EntryType:=dir;
              {ie its a directory}

{Now insert it in the right place}

               if recnum=0 then DIR_INFO[0]:=ThisEntry
               else
               begin
                    n:=0;
                     while ((ThisEntry.Name>DIR_INFO[n].Name) and (n<RecNum)
and (DIR_INFO[n].entrytype=DIR))                           do inc(n);
                {now n points to the right spot}
                shuffle(n); {make the gap};
                DIR_INFO[n]:=ThisEntry;


                end; {insert at right place}
               inc(RecNum);
           end; {if its a dir, and not '.'}

           FindNext(s); {get the next file}
           end ; {while not end of file, or to many files}


     findfirst(mask, (01),S);     {find all normal files}

     while ((DosError<>18) and (RecNum<225)) {ie end of file, or to many
files}     do begin
           ThisEntry.Name:=S.Name;
           ThisEntry.EntryType:=Normal;         {if its SAUCE we will change}
           ThisEntry.Tested:=false;

           {Now insert it in the right place}


           if recnum=0 then DIR_INFO[0]:=ThisEntry
           else
           begin
                n:=0;
                while (DIR_INFO[n].EntryType=DIR)
                      do inc(n);
                while ((ThisEntry.Name>DIR_INFO[n].Name) and (n<RecNum))
                      do inc(n);
                {now n points to the right spot}
                shuffle(n); {make the gap};
                DIR_INFO[n]:=ThisEntry;


           end; {insert at right place}
           inc(recnum);
           FindNext(s); {get the next file}
     end; {while}


     {now do the drives}
     for loopchar:='A' to HighDrive do
     begin
          with DIR_INFO[recnum] do
          begin
               Name:=LoopChar+':';
               EntryType:=drive;

          end; {with this record}
          inc(recnum);

     end;



     Num_Entries:=RecNum;                   {Num_Entries-1 is the last valid}

end; {procedure ReadDir}

{--------------------------------------------------------------------------}
Procedure GetFile;
{lets the user move around, finding the file - sets FileToView to the
file to view, or '*' if exit.
Use the DIR_INFO array created by ReadDir}

var
ThisEntry   : T_DirEntry;    {used to alias one entry}
RecNum      : Byte;          {loops through the array}
done        : boolean;       {escape pressed}
loop        : byte;
FKey        : Char;
ThisKey     : Char;
ThisLine    : String[74];         {string built up to display}
ThisLineY   : Byte;               {Y pos of this line}
Loop2       : byte;
Movement    : shortint;               {how does selected change ?}
f           : file;                   {file opened for SAUCE}
size        : integer;                {size of the file}
thisSAUCE   : T_SAUCErec;             {recored loaded in}


begin
     done:=false;


      {draw the screen}
      MOVE(IMAGEDATA,mem[$b800:0000],sizeof(IMAGEDATA));
      TextBackground(Black);


     repeat
           if Top < 0 then Top:=0;
           Bottom:=Top+6;         {to display 8}
           if bottom > Num_Entries-1 then bottom:=Num_Entries-1;
           if selected< top then selected:=top;
           if selected> bottom then selected:=bottom;
                  {boundary checking}
           ThisLineY:=15; { first entry goes on line 15}
           TextBackground(black);

           for loop:= Top to top + 6 do
           {this builds up a string called 'ThisLine' and writes it, seven
times}
           begin

                ThisLine:=' ';
                for loop2:=1 to 74 do ThisLine:=ThisLine+' ';
                {now ThisLine is empty}
                if loop<=Bottom then
                {make sure we dont go past the good elements}
                begin
                     with DIR_INFO[loop] do
                     begin
                          if ((EntryType=Normal) and (Tested=False))
                          {ok, this file we havnt checked for SAUCE, so
                          look now}
                          then begin
                               Tested:=True;
                               Assign(f,Name);            {alias the file}
                               Reset(f,1);                       {get ready to
read it}                               if IOresult=0 then
                               begin
                                    size:=filesize(f);
                                    if (size >128) then                  {cant
be sauce if <=128}                                    begin

                                         Seek(f,(size-sizeof(thisSAUCE)));
{where the SAUCE record MIGHT be}
blockread(f,ThisSAUCE,SizeOf(ThisSAUCE));  {read in the SAUCE info}
                                         SAUCErec:=ThisSAUCE;
                                         if SAUCErec.ID='SAUCE' then {is it
valid?}                                               EntryType:=SAUCE;

                                    end; {if filesize >128}
                                    Close(f);
                               end; {if no error}
                          end; {if need to check for SAUCE}


                          for loop2:=1 to length(NAME) do
                              ThisLine[loop2]:=NAME[loop2];
                           {copy the name into ThisLine}

                              if EntryType=DIR then
                              Begin
                                   ThisLine[17]:='D';
                                   ThisLine[18]:='I';    {clumsy }
                                   ThisLine[19]:='R';
                              end {if its a dir}

                              else if EntryType=Drive then
                              Begin
                                   ThisLine[17]:='D';
                                   ThisLine[18]:='r';
                                   ThisLine[19]:='i';
                                   ThisLine[20]:='v';
                                   ThisLine[21]:='e';
                              end {if its a drive}

                              else if EntryType=SAUCE then
                              begin
                                   for loop2:=1 to length(SAUCErec.Title) do

ThisLine[loop2+16]:=SAUCErec.Title[Loop2];
for loop2:=1 to length(SAUCErec.Author) do
ThisLine[loop2+53]:=SAUCErec.Author[Loop2];                              end;
{else if its sauce}                     end; {with}
                end; {if loop <= bottom}
                {now ThisLine has been built}
                GotoXY(4,ThisLineY); {position the cursor}

                {now do the lightbar/highlight etc}
                if (loop=selected)
                then begin
                     TextColor(White);
                     TextBackground(green);
                end
                else if ((loop=selected-1) or (loop=selected+1))
                then begin
                     TextColor(LightGray);
                     TextBackground(Black);
                end
                else TextColor(DarkGray);

                {write it!}
                Write(ThisLine);

                 inc(ThisLineY);
           end; {for loop}


           {now get a key press}
           FKey:=#0;
           ThisKey:=Readkey;


           if (ThisKey=#0) then FKey:=ReadKey;
           If ThisKey=#27 then
           begin
                done:=true;
                FileToView:='*';
                {so that the main loop knows to exit}
           end;
           movement:=0;
           if FKey=#$48 then movement:=-1;      {up arrow}
           if FKey=#$49 then movement:=-7;      {page up}
           if FKey=#$50 then movement:=1;       {down arrow}
           if FKey=#$51 then movement:=7;       {page down}
           selected:=selected+movement;
           if selected<0 then selected:=0;
           if selected>Num_Entries-1 then selected:=Num_Entries-1;
           if top>selected then top:=top+movement;
           if bottom<selected then top:=top+(movement);

           if Fkey=#$47 then
           begin
                top:=0;             {home}
                selected:=0;
           end;
           if Fkey=#$4F then
           begin
                top:=Num_Entries-7;    {end}
                selected:=Num_Entries;
           end;
           if ThisKey=#13 then
           begin
                ThisEntry:=Dir_Info[Selected];
                if ((ThisEntry.EntryType=dir) or ((ThisEntry.EntryType=drive)
))then                begin
                     {ok, we have changed drives or directories so read in
                     the new info}
                     ChDir(ThisEntry.Name);
                     if IOresult>0 then chdir(oldpath);
                     ReadDir;
                     Top:=0;
                     selected:=0;
                end
           else {we have a file!}
           begin
                done:=true;
                FileToView:=Dir_Info[selected].NAME;
           end;
           {f its a dir}
           end; {if enter pressed}



     until done;
end; {procedure showdir}
{--------------------------------------------------------------------------}
procedure ViewFile;
{view the file in FileToView, treat it as an ANSi file}
var

f  : text; {the actual file}
ThisLine : string;     {line just readin}
ThisChar : char;
velocity: shortint;    {how fast are we scrolling?}
ScreenStart : longint;    {what  is the start of the screen in scanlines}
ThisKey, Fkey : char;                 {used to get characters}
loop : word;
skip : boolean;         {skip the scroll down?}
done : boolean;
frames : byte;          {number of retraces before decreasing velocity}

begin
     assign(f,FileToView);
     reset(f);
     textColor(LightGray);
     TextBackground(Black);
     screen_bottom:=0;
     My_gotoxy(1,1);
     while ((not EOF(f)) and (screen_bottom<255)) do
     begin
          ThisLine:='';
          repeat
                read(f,ThisChar);
                if thischar<>#12 then ThisLine:=ThisLine+ThisChar;
          until ((eoln(f)) or (thischar=' ')or (thischar='m'));
          {this is cos some lines in ansi files have 2000+ chars before a cr,
          so if you just go readln you lose heaps}

          AnsiWriteLn(ThisLine);

          if ((eoln(f)) and (not eof(f))) then
          begin
                  readln(f);
                  inc(My_WhereY);
                  My_WhereX:=1;
          end;
     end;
     close(f);


     {now the file is in memory, so lets go scrolling!}

     velocity:=0;
     screenStart:=0;

   {scroll to the bottom}

   if screen_bottom>25 then
   begin
           skip:=false;
           done:=false;
           for loop :=0 to (screen_bottom-25)*1 do
           begin
                if keypressed then
                begin
                     screenstart:=loop*16;
                     skip:=true;
                end;
                if not skip then setscreenstart(loop*16)
                else loop:=(screen_bottom-25)*1
           end;


   {and back up}

           if not skip then for loop :=(screen_bottom-25)*1 downto 0 do
           begin
                if not keypressed then setscreenstart(loop*16);
                {if loop>2 then dec(loop);}
                if keypressed then
                begin
                     screenstart:=loop*16;
                     loop:=0;
                end;
           end;
   end; {if screen bottom is off the screen}

   if keypressed then thiskey:=readkey else thiskey:=#0;

   {now if theres more than 25 lines let the user scroll}

 if (screen_bottom >25) then repeat
        setscreenstart(screenstart);

        fkey:=#0;
        if keypressed then
        begin
             thiskey:=readkey;
             if thiskey=#0 then fkey:=readkey;
        end;

        if thiskey=#27 then done:=true;        {escape}

        if thiskey=#13 then velocity:=0;         {freeze on enter}

        if thiskey=#32 then velocity:=0;        {freeze on space}

        if fkey=#$47 then
         begin
              velocity:=0;
              screenstart:=0;
        end;                    {home key}

        if fkey=#$4f then
         begin
              velocity:=0;
              screenstart:=(screen_bottom-25)*16;
        end;                    {end key}


        if fkey=#$48 then dec(velocity,3);  {up}
        if ((fkey=#$49) and (screenstart>160)) then dec(velocity,16);  {page
up}        if ((fkey=#$49) and (screenstart<=160)) then dec(velocity,6);
{page up}        if fkey=#$50 then inc(velocity,3);  {down}
        if ((fkey=#$51) and (screenstart<((screen_bottom-30)*16) ))then
inc(velocity,16);  {page down}        if ((fkey=#$51) and
(screenstart>=((screen_bottom-30)*16) ))then inc(velocity,6);  {page down}



        inc(screenstart, velocity);                   { update screen position
}
         inc(frames);
         if frames=3 then
         begin
         {ie only reduce the velocity every 4 times through = 4 retraces}
              frames:=0;
              if velocity >0 then dec(velocity);
              if velocity <0 then inc(velocity);
         end; {if frame =10}

         {if we hit the top or bootm, reverse velocity}
         if screenstart>(screen_bottom-25)*16 then
         begin
              screenstart:=(screen_bottom-25)*16;
              velocity:=0-(velocity div 2);
         end;

         if screenstart<0 then
         begin
              screenstart:=0;
              velocity:=-0-(velocity div 2);
         end;





   until (thisKey=#27)

   else  {if the file is less than 25 lines, just wait for a keypress}
   repeat
         thiskey:=readkey;
   until (thiskey=#27);

   if keypressed then thiskey:=readkey;
   {just kill that char}


      setscreenstart(0);
end; {procedure ViewFile}



{--------------------------------------------------------------------------}


procedure ShutDown;
begin

     {restore old mode}
     asm
         mov    al,OldMode
         mov    ah,0
         int    $10
     end; {restore old mode}

     chdir(OldPath); {restore the path}


      {now turn on the cursor}
      asm
         mov    cx,$0708
         mov    ah,$01
         int    $10
      end; {turn on cursor}




end; {shutdown}
{--------------------------------------------------------------------------}

procedure SetUp;
{misc stuff to get set}
var
path  : string;
d     : dirstr;
n     : namestr;
e     : extstr;
s     : searchrec;
begin

      {get the current drive}

      GetDir(0,OldPath);

      cls;
      mask:='*.*';


      {grab the old video mode}
      asm
         mov    ah,$0f
         int    $10
         mov    oldmode,al
      end; {asm}

      {new mode}

{      TextMode(CO80);}

      {now turn of the cursor}
      asm
         mov    ch,$20
         mov    ah,$01
         int    $10
      end; {turn off cursor}





      {find the highest drive}
      HighDrive:='C';
      while DiskExist(HighDrive) do
      begin
           HighDrive:=char(ord(HighDrive)+1);
      end;
      HighDrive:=char(ord(HighDrive)-1);


      Top:=0;
     selected:=0;

{now, if there is a command line parameter, use it as a path.
if there is only one match, then just display that file and exit.
so av *.ans will mean dirs will only show .ans files, but av file.ans
will display file.ans and then exit}

      if paramcount > 0 then
      begin
           path:=paramstr(1);
           {check if only one file matches}

           findfirst(path, (01),S);
           if doserror=0 then
           begin
                FindNext(s);
                if doserror=18 {ie no more matches} then
                begin
                     FileToView:=path;
                     ViewFile;
                     shutdown;
                     Halt(0); {we are all done!}
                end;
           end;



           fsplit(path,d,n,e);
           if n='' then n:='*';
           if e='' then e:='.*';
           mask:=n+e;
           chdir(d);

      end;




end;

{--------------------------------------------------------------------------}
var loop1 : byte;
begin {main}


      Setup;
      ReadDir;
      repeat

            GetFile;

            if FileToView<>'*' then
            begin
                 cls;
                 ViewFile;
            end;
      until FileToView='*'; {thats the sentinel}
      ShutDown;


end.

