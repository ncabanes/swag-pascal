{
Hi all, I just wanted to leave a note of congratulations and appreciation on
your efforts at the SWAG archive.  The reader is a great little app (I did
the screen saver!) and I've just found quite a few cool things that I hadn't
even thought of trying before in the hardware archive.

I don't know if it's be useful to anyone but I'd like to contribute
something as pretty much everything else I've ever done is already here.
This is the source to a command interpreter with some unix functionality I
call Shell which I've been playing with on and off over the past few years.
I haven't released the source until now but I felt that seeing so many other
people contribute I should do so as well in return.  Shell is available on
SimTel and Oak and is quite widely used.  I don't mind the code being
distributed.

Thanks
Tim
}

{$DEFINE qdebug}

{$IFDEF debug}
{$A-,B-,D+,E-,F-,G+,I+,L+,N-,O-,Q+,R+,S+,V-,X-,M 2700,0,0}
{$ELSE}
{$A-,B-,D-,E-,F-,G+,I-,L-,N-,O-,Q-,R-,S-,V-,X-,M 2300,0,0}
{$ENDIF}

program Shell;
uses crt,dos;
const
     BACKSPACE=#8;                             {Keyboard character codes}
     CTRLD=#4;
     CTRLU=#21;
     CTRLBACKSPACE=#127;
     TAB=#9;
     ENTER=#13;
     ESCAPE=#27;
     KHOME=#71;
     UP=#72;
     KPGUP=#73;
     LEFT=#75;
     RIGHT=#77;
     KEND=#79;
     DOWN=#80;
     KPGDN=#81;
     INSERTKEY=#82;
     DELKEY=#83;
     F1=#59;
     F2=#60;
     F3=#61;
     F7=#65;
     F8=#66;
     F10=#68;
     GUP=TRUE;                                  {Scrolling}
     GDOWN=FALSE;
     QUITCMD='exit';                            {Quit command}
     IOINT=$10;                                 {DOS IO interrupt}
     DOSINT=$21;                                {DOS function interrupt}
     MOUSEINT=$33;                              {Mouse interrupt number}
     SCREEN=$B800;                              {Screen memory address}
     KEYBSTATUS=$417;                           {Keyboard status offset}
     ALLFILES=$37;                              {File mask minus volumeid}
var
   tvdos:pathstr;                               {TVDOS envvar}
   path:pathstr;                                {PATH envvar}
   ppos:byte;                                   {Path pointer for GFN}
   history:array[1..21]of comstr;               {History}
   comcount:byte;                               {History list counter}
   {The following are only globals to save parameter space}
   firstagain:boolean;                          {Look for 1st file again}
   tabflag:boolean;                             {Has tab been pressed}
   command:comstr;                              {The command line}
   promptcolor:byte;                            {Prompt color}
   dummy:integer;                               {Local dummy}

procedure Initialize;
begin
     checkbreak:=false;
     directvideo:=false;                        {For speech assistants}
     tvdos:=getenv('TVDOS');
     { tvdos := 'c:'; }
     if tvdos=''then
        begin
             writeln('SHELL: no TVDOS environment variable');
             halt;
        end;{if}
     path:=getenv('PATH');
     {Add curdir to the path for GFN}
     if pos('.\',path)=0 then path:='.\;'+path;
     if paramcount>0 then
        val(paramstr(1),promptcolor,dummy)
     else
        promptcolor:=lightblue;
     writeln(#13+'SHELL V1.9.1 by Tim Villa');
     writeln('Type "'+QUITCMD+'" to escape to DOS');
     {Initialize the history}
     for comcount:=19 downto 0 do history[comcount+1]:='';
     {Initialize the mouse}
     asm
        mov ax,0                                {Reset mouse}
        int MOUSEINT
        mov dummy,ax
        mov ax,7                                {Set X range}
        mov cx,1
        mov dx,632;
        int MOUSEINT
        mov ax,8                                {Set Y range}
        mov cx,1
        mov dx,392
        int MOUSEINT
     end;{asm}
     write('Mouse ');
     if dummy=0 then write('not ');
     writeln('detected');
end;{Initialize}

function WhereX:byte;
{Returns x pos on screen}
var
   temp:byte;
begin
     asm
        mov bh,0                                {"Graphics" page}
        mov ah,3                                {Read cursor position}
        int IOINT
        inc dl                                  {To preserve 0..79}
        mov temp,dl                             {Mov x result to temp}
     end;
     WhereX:=temp;
end;{WhereX}

procedure GotoX(x:byte);
{Move cursor to x,wherey}
begin
     asm
        mov bh,0                                {"Graphics" page}
        mov ah,3                                {Read cursor position}
        int IOINT
        mov ah,2                                {Set cursor position}
        dec x                                   {Columns starts at 0, !1}
        mov dl,x
        int IOINT
     end;{asm}
end;{GotoX}

function Button(which:char):boolean;
{True if left button down}
label
     LButton,TrueRes,FalseRes;
begin
     asm
        mov ax,3                                {Get mouse state}
        int MOUSEINT
        cmp bx,3
        je TrueRes                              {bx 3 if any button down}
        cmp which,LEFT
        je LButton                              {Check right utton}
        cmp bx,2
        je TrueRes
        jmp FalseRes                            {Nope}
        LButton:
        cmp bx,1
        je TrueRes                              {...else dropout to FalseRes}
     end;{asm}
     FalseRes:Button:=false;
     exit;
     TrueRes:Button:=true;
end;{Button}

function GetFileName(sofar:string):string;
{Responds to TAB to finish command line.
 Returns the remainder of the filename [or whole filename if none given]}
var
   filerec:searchrec;                           {For findfirst}
   prefix:pathstr;                              {Directory to look in}
   filename:pathstr;                            {Name we found}
   i:byte;                                      {Index}
   dircmd:boolean;                              {Is this a directory command}
   cmd:boolean;                                 {Is this a command}

   procedure GetDirEntry;
   {Skips all non directory entries}
   begin writeln(filerec.name,'',filerec.attr);
        while ((filerec.attr and DIRECTORY)<>DIRECTORY) and (doserror<>18) do
              findnext(filerec);
        if doserror=18 then filerec.name:='';
   end;{GetDirEntry}

   procedure GetCmdEntry;
   {Skips all non .EXE .COM .BAT files}
   begin
        while (pos('.EXE',filerec.name)=0) and (pos('.COM',filerec.name)=0) and
              (pos('.BAT',filerec.name)=0) and ((filerec.attr and DIRECTORY) <> DIRECTORY) and
              (doserror<>18) do
              findnext(filerec);
        if doserror=18 then firstagain:=true;
   end;{GetCmdEntry}

begin {GetFileName}
     {Convert command to lowercase (everything here is in lowercase)}
     for i:=1 to length(sofar) do
         if sofar[i] in ['A'..'Z'] then
            sofar[i]:=chr(ord(sofar[i])+32);
     {Check for a directory oriented command.  Use "prefix" to save memory}
     prefix:=copy(sofar,1,pos(' ',sofar)-1);
     dircmd:=(prefix='cd') or (prefix='rd') or
             (prefix='chdir') or (prefix='rmdir');
     cmd:=pos(' ',sofar)=0;
     {Eliminate everything before the current "word"}
     while pos(' ',sofar)>0 do delete(sofar,1,pos(' ',sofar));
     {And convert forward slashes to backslashes}
     while pos('/',sofar)>0 do sofar[pos('/',sofar)]:='\';
     if firstagain then
        begin
             {We're starting from scratch.  The current directory is in the
              path as set in Initialize so we search the path from the start}
             GetFileName:='';
             repeat
                   prefix:='';
                   i:=pos(';',copy(path,ppos,79));
                   if i=0 then i:=255;
                   if (pos('\',sofar)=0) and (pos(':',sofar)=0) then
                      begin
                           {No drive/path has been specified by the user}
                           prefix:=copy(path,ppos,i-1);
                           if prefix[length(prefix)]<>'\'then
                              prefix:=prefix+'\';
                      end;{if}
                   filerec.name:='';
                   findfirst(prefix+sofar+'*.*',ALLFILES,filerec);
                   {Ignore . and .. filenames}
                   while (filerec.name[1]='.') and (doserror<>18) do
                         findnext(filerec);
                   {Now ignore all but directories if DIRCMD}
                   if dircmd then GetDirEntry;
                   if cmd then GetCmdEntry;
                   tabflag:=true;
                   if i<255 then ppos:=ppos+i;
             until (i=255) or (doserror<>18);
             {If i is 255 we have run out of subdirs- 255>length(pathstr)
              doserror<>18 means we have found a match somewhere}
             if i=255 then ppos:=1;
             if doserror=18 then exit;          {No file.  Return ''}
             filename:=filerec.name;
             firstagain:=false;
        end{if}
     else
        begin
             {Set filename to what we found here last time}
             {Ignore all but directories if DIRCMD}
             if dircmd then GetDirEntry;
             if cmd then GetCmdEntry;
             filename:=filerec.name;
        end;{else}
     {Convert result to lowercase}
     for i:=1 to length(filename) do
         if filename[i] in ['A'..'Z'] then
            filename[i]:=chr(ord(filename[i])+32);
     {Set up for next TAB}
     findnext(filerec);
     {If no more files, start again}
     if doserror=18 then firstagain:=true;
     {We need to extract the command line entered so far so we can return
      only the remainder, ie the rest of the filename.  First we find the
      last occurrence of a : or \ so we know the where the last instance of
      a filename begins}
     i:=length(sofar)+1;
     repeat
           dec(i);
     until (sofar[i] in ['\',':']) or (i=0);
     {Establish h/m chars we are tacking on}
     i:=length(sofar)-i;
     {Extract these chars to get result}
     GetFileName:=copy(filename,1+i,12);
end;{GetFileName}

function GetCmdLine:string;
const
     keymap='qwertyuiop!!!!asdfghjkl!!!!!zxcvbnm';
var
   index,c:byte;                                {String index, counter}
   key:char;                                    {User}
   cmdline:COMSTR;                              {Command line}
   lasttabname:string[12];                      {Last name from tab press}
   comscroll:byte;                              {For DOSKEY command scrolling}
   gotnull:boolean;                             {Has a ctrl char been pressed}
   start,stop:byte;                             {Sel start/end, line#}
   linenum:integer;                             {Line number mouse is on}
   mtext:string[80];                            {C&P text from mouse}
   attrline:array[1..80]of byte;                {Original attr b/4 highlight}
   inson:boolean;                               {Insert on or off}
   dirlen:byte;                                 {Length of dirname}
   m,s,s100,oldtime,time:word;                  {For double click test}
   firstscroll:boolean;
label
     MyLabel1;                                  {Dummy label}

   procedure ToggleInsert;
   begin
        inson:=not inson;
        if inson then
           asm
              mov ah,1                          {Set cursor type}
              mov ch,1
              mov cl,4
              int IOINT
           end{asm}
        else
           asm
              mov ah,1                          {Set cursor type}
              mov ch,4
              mov cl,5
              int IOINT;
           end;{asm}
   end;{ToggleInsert}

   procedure ScrollLastCommand(up:boolean);
   {DOSKEY up arrow}
   begin
        if comcount=0 then exit;
        if firstscroll then
           begin
                firstscroll:=false;
                comscroll:=comscroll+1;
           end;{if}
        if up then
           begin
                dec(comscroll);
                if comscroll=0 then comscroll:=comcount;
           end{if}
        else
           begin
                inc(comscroll);
                if comscroll>comcount then comscroll:=1;
           end;{else}
        GotoX(dirlen+2);                        {Go to start of cmdline}
        clreol;
        cmdline:=history[comscroll];
        write(cmdline);
        index:=length(cmdline)+1;
   end;{ScrollLastCommand}

   procedure NormalKey;
   {Normal alphanumerics}
   begin
        tabflag:=false;
        firstagain:=true;
        firstscroll:=true;
        ppos:=1;
        if gotnull then exit;
        if key=CTRLD then
           begin
                {We have a ^D character}
                while pos(' ',cmdline)>0 do delete(cmdline,1,pos(' ',cmdline));
                cmdline:=tvdos+'\LISTNAME.EXE '+cmdline;
                key:=#13;
                exit;
           end;{if}
        if inson then
           begin
                {Insert the char}
                insert(key,cmdline,index);
                inc(index);
                {Write what we got now}
                GotoX(dirlen+2);
                write(cmdline);
                {Move one pos to the right of old pos}
                GotoX(dirlen+index+1);
                exit;
           end;{if}
        if index>length(cmdline) then cmdline:=cmdline+key
        else cmdline[index]:=key;
        write(key);
        inc(index);
   end;{NormalKey}

   procedure GetOldAttr;
   {Saves original chacter attributes}
   var
      c:byte;                                   {Counter}
   begin
        {We don't want the area under the mouse so hide it}
        asm
           mov ax,2                             {Hide mouse cursor}
           int MOUSEINT
        end;{asm}
        for c:=1 to 80 do
            attrline[c]:=mem[SCREEN:linenum+(2*c-1)];
        asm
           mov ax,1                             {Show mouse cursor}
           int MOUSEINT
        end;{asm}
   end;{GetOldAttr}

   procedure RestoreOldAttr(start:byte);
   {Restores old attributes to highlighted text}
   var
      c:byte;                                   {Counter}
   begin
        if linenum=-maxint then exit;
        for c:=start to 80 do
            mem[SCREEN:linenum+2*c-1]:=attrline[c];
   end;{RestoreOldAttr}

   function GetCutAndPaste:string;
   {Returns text selected with mouse}
   var
      xpos:byte;                                {Mouse x pos ; dummy byte}
      c,offs:integer;                           {Counter, offset of start}
      cutstr:string[80];                        {Selected text}
   begin
        asm
           mov ax,2                             {Hide mouse cursor}
           int MOUSEINT
        end;{asm}
        RestoreOldAttr(1);                      {Clear old highlighted text}
        {Get the initial pos}
        asm
           mov ax,3                             {Get mouse state}
           int MOUSEINT
           mov ax,cx                            {Load divisor: x coord}
           add ax,8
           mov bl,8                             {Set dividend}
           div bl
           mov xpos,al                          {Use xpos to save mem}
           mov ax,dx                            {Load divisor: y coord}
           add ax,8
           div bl
           dec al                               {Now calculate (al-1)*160}
           mov dh,160
           mul dh
           mov offs,ax                          {Use offs to save mem}
        end;{asm}
        {Linenum represents (linenum-1)*160 for offset}
        linenum:=offs;
        start:=xpos;
        GetOldAttr;
        {Ok highlight etc until the button is released}
        repeat
              asm
                 mov ax,3                       {Get mouse state}
                 int MOUSEINT
                 mov ax,cx
                 add ax,8
                 mov bl,8
                 div bl
                 mov xpos,al
              end;{asm}
              for c:=linenum+(start*2-1) to linenum+(xpos*2-2) do
                  if odd(c) then mem[SCREEN:c]:=black+lightgray*16;
              RestoreOldAttr(xpos);
        until not Button(LEFT);
        asm
           mov ax,1                             {Show mouse cursor}
           int MOUSEINT
        end;{asm}
        {Might have to get new mouse x here?}
        {Get our new position and calulate the initial offset}
        stop:=xpos-1;
        offs:=linenum+(start*2-2);
        {Fill in the string from memory}
        cutstr:='';
        for c:=0 to (stop-start)*2 do
            if not odd(c) then cutstr:=cutstr+chr(mem[SCREEN:offs+c]);
        if start>=stop then GetCutAndPaste:='' else GetCutAndPaste:=cutstr;
   end;{GetCutAndPaste}

   function GetWord:string;
   {Gets current word as indicated by double clicking}
   var
      xpos:byte;                                {Mouse x,y coords}
      offs:integer;
      cutstr:string[80];                        {Selected text}
      c:integer;
   begin
        asm
           mov ax,2                             {Hide mouse cursor}
           int MOUSEINT
        end;{asm}
        {Get the initial pos}
        asm
           mov ax,3                             {Get mouse state}
           int MOUSEINT
           mov ax,cx                            {Load divisor: x coord}
           add ax,8
           mov bl,8                             {Set dividend}
           div bl
           mov xpos,al                          {x coord}
           mov ax,dx                            {Load divisor: y coord}
           add ax,8
           div bl
           dec al                               {Now calculate (al-1)*160}
           mov dh,160
           mul dh
           mov offs,ax                          {This is the memory offset}
        end;{asm}
        {Go back to closest space or SOLN}
        while (mem[SCREEN:offs+(xpos-1)*2]<>32) and (xpos<>0) do
              xpos:=xpos-1;
        {Now move to the right, adding characters until space or EOLN}
        cutstr:='';
        while (mem[SCREEN:offs+(xpos)*2]<>32) and (xpos<80) do
              begin
                   cutstr:=cutstr+chr(mem[SCREEN:offs+xpos*2]);
                   {Highlight character}
                   mem[SCREEN:offs+xpos*2+1]:=black+lightgray*16;
                   xpos:=xpos+1;
              end;{while}
        asm
           mov ax,1                             {Show mouse cursor}
           int MOUSEINT
        end;{asm}
        GetWord:=cutstr;
   end;{GetWord}

   procedure FinishCommand;
   {DOSKEY F8}
   var
      i:byte;
   begin
        if comcount=0 then exit;
        for i:=comcount downto 1 do
            if pos(cmdline,history[i])=1 then
               begin
                    cmdline:=history[i];
                    GotoX(dirlen+2);
                    write(cmdline);
                    index:=length(cmdline)+1;
                    exit;
               end;{if}
   end;{FinishCommand}

begin {GetCmdLine}
     if WhereX<>1 then writeln;
     getdir(0,cmdline);                         {Var used to save memory}
     textcolor(promptcolor);
     write(cmdline+'>');
     textattr:=lightgray;
     clreol;
     dirlen:=length(cmdline);
     cmdline:='';
     comscroll:=comcount;                       {Reset scroller}
     index:=1;
     tabflag:=false;                            {Reset TAB assoc variables}
     firstagain:=true;
     lasttabname:='';
     ppos:=1;
     gotnull:=false;
     inson:=true;
     ToggleInsert;                              {Sets to false, reset cursor}
     start:=0;                                  {Reset cut & paste}
     stop:=0;
     mtext:='';
     linenum:=-maxint;
     time:=65535;
     repeat
           repeat
                 if Button(LEFT) then
                    begin
                         oldtime:=time;
                         gettime(s,m,s,s100);
                         mtext:=GetCutAndPaste;
                         time:=m*60000+s*100+s100;
                         if time-oldtime<20 then mtext:=GetWord;
                    end;{if}
                 if Button(RIGHT) then
                    begin
                         RestoreOldAttr(1);
                         inc(index,length(mtext));
                         {Gotta check for len here}
                         cmdline:=cmdline+mtext;
                         write(mtext);
                         repeat until not Button(RIGHT)
                    end;{if}
           until keypressed;
           key:=readkey;
           if gotnull then
              begin
                   gotnull:=false;
                   case key of
                       UP:ScrollLastCommand(GUP); {DOH2}
                       DOWN:ScrollLastCommand(GDOWN);
                       LEFT:
                          if index>1 then
                             begin
                                  write(BACKSPACE);
                                  dec(index);
                             end;{KLEFT}
                       RIGHT:
                          if index<length(cmdline) then
                             begin
                                  GotoX(WhereX+1);
                                  inc(index);
                             end;{KRIGHT}
                       KHOME:
                          begin
                               GotoX(dirlen+2);
                               index:=1;
                          end;{KHOME}
                       KEND:
                          begin
                               GotoX(dirlen+2+length(cmdline));
                               index:=length(cmdline)+1;
                          end;{KEND}
                       KPGUP,KPGDN:;
                       F8:FinishCommand;
                       F1:
                          begin
                               asm
                                  cmp comcount,0
                                  je MyLabel1
                               end;{asm}
                               if length(history[comcount])<index then
                                  goto MyLabel1;
                               inc(index);
                               c:=ord(history[comcount,index-1]);
                               cmdline:=cmdline+chr(c);
                               write(chr(c));
                               MyLabel1:;
                          end;{F1}
                       F3:
                          begin
                               history[21]:=cmdline;            {Temp}
                               c:=WhereX;                       {Save pos}
                               ScrollLastCommand(GUP);
                               GotoX(dirlen+2);
                               write(history[21]);
                               GotoX(index+dirlen+1);
                               cmdline:=history[21]+
                                        copy(cmdline,
                                             length(history[21])+1,128);
                          end;{F3}
                       F7:
                          begin
                               cmdline:='HISTORY';
                               writeln;
                               key:=ENTER;
                          end;{F7}
                       INSERTKEY:ToggleInsert;
                       DELKEY:
                          if index<=length(cmdline) then
                             begin
                                  if index=1 then
                                     cmdline:=copy(cmdline,2,127)
                                  else
                                     cmdline:=copy(cmdline,1,index-1)+
                                              copy(cmdline,index+1,127);
                                  GotoX(dirlen+2);
                                  write(cmdline+' ');
                                  GotoX(dirlen+index+1);
                             end;{DELKEY:if}
                       #16..#25,
                       #30..#38,
                       #44..#50:
                          begin
                               writeln;
                               cmdline:=tvdos+'\SH_'+
                                        copy(keymap,ord(key)-15,1)+'.BAT';
                               key:=ENTER;
                          end;{ALT keys}
                   end;{if gotnull}
              end
           else
           case key of BACKSPACE:
                          begin
                               gotnull:=false;
                               if index>1 then
                                  begin
                                       if copy(cmdline,length(cmdline),1)=' 'then
                                          begin
                                               tabflag:=false;
                                               firstagain:=true;
                                          end;{if}
                                       if index<length(cmdline) then
                                          begin
                                               {Backspace inside command line}
                                               cmdline:=copy(cmdline,1,index-2)+copy(cmdline,index,127);
                                               GotoX(dirlen+2);
                                               write(cmdline+' ');
                                               GotoX(dirlen+index);
                                          end{if}
                                       else
                                          begin
                                               {Backspace over last character}
                                               cmdline[0]:=chr(ord(cmdline[0])-1);
                                               write(key+' '+key);
                                          end;{else}
                                       dec(index);
                                       if tabflag then
                                          begin
                                               if length(lasttabname)>0 then
                                                  lasttabname[0]:=chr(ord(lasttabname[0])-1);
                                               firstagain:=true;
                                          end;{if}
                                  end;{else}
                          end;{BACKSPACE}
                       TAB:
                          begin
                               gotnull:=false;
                               if tabflag then
                                  begin
                                       {Erase all signs of existence the last
                                        TAB caused}
                                       c:=length(lasttabname);
                                       GotoX(WhereX-c);
                                       clreol;
                                       index:=index-c;
                                       cmdline:=copy(cmdline,1,
                                                     length(cmdline)-c);
                                  end;{if}
                               lasttabname:=GetFileName(cmdline);
                                cmdline:=cmdline+lasttabname;
                               GotoX(WhereX-index+1);
                               write(cmdline);
                               index:=index+length(lasttabname);
                          end;{TAB}
                       ESCAPE,CTRLU:
                          begin
                               GotoX(1);                {So can redraw prompt}
                               clreol;
                               GetCmdLine:='';
                               firstscroll:=true;
                               exit;
                          end;{ESCAPE}
                       ENTER:
                          begin
                               firstscroll:=true;
                               RestoreOldAttr(1);
                               asm
                                  mov ax,2              {Hide mouse cursor}
                                  int 51
                               end;{asm}
                               writeln;
                          end;{ENTER}
                       CTRLBACKSPACE:halt;
                       #0:gotnull:=true;
                       #3:;                             {Ignore leftover ^C}
                       else NormalKey;
           end;{case}
     until key=ENTER;
     while copy(cmdline,1,1)=' 'do delete(cmdline,1,1);
     GetCmdLine:=cmdline;
end;{GetCmdLine}

function Exclusions(temp:string):boolean;
{Determines whether command is valid}
{Also executes SHELL commands}
var
   i:byte;                                              {Index}
begin
     Exclusions:=false;
     for i:=1 to length(temp) do temp[i]:=upcase(temp[i]);
     if copy(temp,1,4)='SET ' then
        writeln('SHELL: Cannot set environment variables');
     if temp='HISTORY' then
        begin
             for i:=1 to comcount do writeln(i:2,' ',history[i]);
             Exclusions:=true;
        end;{if}
end;{Exclusions}

procedure UpdateCommands;
{Adds latest command to command list}
var
   i,j:byte;                                            {Counter/index}
begin
     inc(comcount);
     i:=1;
     while (i<=comcount) and (command<>history[i]) do inc(i);
     if i<comcount then
        begin
             {"Remove" this instance and add it to end}
             for j:=i to comcount-1 do history[j]:=history[j+1];
             history[comcount]:=command;
             dec(comcount);
        end;{if}
     if comcount=21 then
     {Move all commands "down" one}
        for comcount:=1 to 20 do
            history[comcount]:=history[comcount+1];
     {Add new command to end of array}
     history[comcount]:=command;
end;{UpdateCommands}

procedure BuildLastCommand;
{Gets last command using UNIX ! syntax}
var
   i:byte;                                              {Counter}
begin
     command:=copy(command,2,79);
     val(command,i,dummy);
     if (i>0) and (i<comcount+1) then
        begin
             command:=history[i];
             exit;
        end;{if}
     if comcount>0 then
        for i:=comcount downto 1 do
            if pos(command,history[i])=1 then
               begin
                    command:=history[i];
                    exit;
               end;{if}
     command:='';
end;{BuildLastCommand}

procedure DoCommands;
{Reads and executes commands}
begin
     repeat
           repeat
                 asm
                    mov ax,1                            {Show mouse cursor}
                    int 51
                    mov ax,8                            {Set Y range}
                    mov cx,1
                    mov dx,392
                    int MOUSEINT
                 end;{asm}
                 command:=GetCmdLine;
                 if command[1]='!'then BuildLastCommand;
           until command<>'';
           if copy(command,1,12)<>'C:\TVDOS\SH_' then
              UpdateCommands;
           if (command<>QUITCMD) and (not Exclusions(command)) then
              begin
                   swapvectors;
                   exec(tvdos+'\COMMAND.COM','/C '+command);
                   swapvectors;
                   case doserror of 0:;
                                    1:writeln('SHELL: Cannot use root directory for TVDOS');
                                    2:writeln('SHELL: Command interpreter missing');
                                    3:writeln('SHELL: Bad TVDOS directory');
                                    8:writeln('SHELL: Out of memory or system error');
                                    else writeln('SHELL: error ',doserror);
                   end;{case}
              end;{if}
     until command=QUITCMD;
end;{DoCommands}

begin
     Initialize;
     DoCommands;
     writeln('SHELL: Terminating');
end.

NOTES

We get a stack overflow every time NormalKey is pressed when DEBUG is on.
There don't appear to be any problems with the stack but bear this in mind!

Check to see if there is a * around here somewhere so we can find partly
specified extensions}

Use mem[$0:$417]:=0; to switch off all key locks

Taken from Exclusions:

     if (pos('SHELL',temp)>0) and ((pos('DEL',temp)>0) or (pos('REN',temp)>0)) then
        begin
             writeln('SHELL: Access denied');
             Exclusions:=true;
        end;{if}

QUIRKS

8.  The stack is unstable.  Don't make it any smaller
11. Pressing F3 to recall a shorter command.  No bug but hmmm...

BUGS

12. Use of TAB after starting a new line causes error 201
13. Use of TAB after a . is on the command line screws up GFN
14. Can't cd TAB for directories with A bit set-check (attr && DIRECTORY)

ERROR CODES

01: (Not sure why) $TVDOS is in a root directory.  Probably C:\\ I guess
02: File not found-$TVDOS \COMMAND.COM is missing
08: Not enough memory.  No memory or system error

VERSION

1.8.2  Fixed bug where prompt color is used by DOS command
1.9.0
1.9.1  Get network directory names completing properly
