{
  Since it looks like things are moving quite slowly here, I thought I'd
post a text viewer that I wrote. Actually, A guy named Jon Merkel
posted the original code that showed me how to smoothly scroll text. I
just modified it to read files and keep track of where in the file it's
at and stuff. I was going to make it read straight binary files so it
would display all those extended ascii characters, but I figured it'd
be a lot easier this way.
    Basically, it just reads the file 102 lines at a time. It starts out
by filling the video memory with 204 lines of text and then updates it
as needed. I guess there really isn't a fliesize limit.. Actually there
would be   ummm  FilePs is a longint so it'd be 2147483647*80. Well,
by the time you got that size file, it'd take a couple years to scroll
becuase my method of seeking a text file leaves MUCH to be desired!
    Please modify this and make it faster! I didn't spend much time on it,
and if i worked on it again, I'd probably load more than 204 lines of the
file into some temp array and then just use MOVE to transfer that data
to video memory.
    Anyways, do what you wish, but please don't dis me for bad code becuase
as I said, I didn't spend much time on this.. just thought you'd all like
to see it.. Enjoy!
 BTW, I already posted this in the FIDO pascal echo.
}
{----------------------------------------------------------------------------}
program View;
const
    DownKey = $50;                          { Scan code for the down arrow }
    UpKey   = $48;                          { Scan code for the up arrow   }
    EscKey  = $1;                           { Scan code for the escape key }
    done: boolean = false;
    start: integer = 0;
    velocity: integer = 0;

Var
  Tfile : text;                           {Text File to read in duh!}
  FilePs,OldPs : LongInt;                 {File Positions maybe?}
  StLoad,EndFile : Boolean;               {Tell if at end or start of file}
  character: record ch:char; attr:byte; end;   {Jon's Record GLOBALLY}

Procedure Error(num:byte);                {Returns error if used wrong}
 Begin
   Writeln;
   Case Num of
     1 : Writeln('Error 1 !  Proper usage is:  VIEW <FileName>');
     2 : Writeln('Invalid File! Be sure full name/path/ext is included.');
   End;
   Writeln;  Halt;
 End;

procedure Initialize;                           { Initialize the program    }
var
  j, k, offset : word;                         {counters and video offset}
  z,x          : byte;                         {Counters and stuff}
  s            : string;                       {Read file into this}
begin
  asm mov ax,3; int 10h; end;                     { Set 80x25 text mode   }
  asm in al,21h; or al,2; out 21h,al; end;        { Disable the keyboard  }
  asm mov ax,0100h; mov cx,2000h; int 10h; end;   { Hide the cursor       }
  FillChar(mem[$B800:0], 32768, 0);               { clear video memory    }
  j:=0;  StLoad := TRUE;  FilePs := 1;
  While (j<203) and (not eof(Tfile)) do begin
    z:=1;  x:=0;  s:='';                          {Init variables}
    Readln(TFile,s);
    offset := j*160;
    character.attr := 7;
    for k := 1 to length(s) do begin
      character.ch := s[k];
      memw[$B800:offset] := word(character);  {display character and Attr}
      inc(offset, 2);
    end;
    inc(j);
  end;
  If Eof(Tfile) Then EndFile := TRUE Else EndFIle := FALSE;
  OldPs := 0; FilePs:=204;        {Init file positions}
end;

procedure SetScreenStart(ScanLine:word);            { MAIN PROCEDURE !!!!   }
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

Procedure Forwards;                   {Reads next 102 lines in the file}
 Var
   s : string;      z,x : byte;            {junk}
   offset : word;                      {didn't we already go thru this one?}
 Begin
   StLoad := FALSE;                    {no longer start of file}
   Move(Mem[$B800:102*160],Mem[$B800:0],16320);

    {This procedure is done so that when we reach the end of video mem,
      we move the last half of memory to the top and load 102 more lines
      neat huh? Actually it's VERY SLow.. especially if your dealing with
      a file that's ohh say more than a meg!}
   SetScreenStart(start);
   FillChar(Mem[$b800:16320],16320,0);
   z:=0;   OldPs := FilePs-102;  {Preserve File Position in OldPs}
   While (not Eof(Tfile)) and (z<102) do Begin
     Inc(z);  Inc(FilePs);
     Readln(Tfile,s);
     offset := (z+102)*160;
     character.attr := 7;
     for x := 1 to length(s) do begin
       character.ch := s[x];
       memw[$B800:offset] := word(character);
       inc(offset, 2);
     end;
   End;
   If eof(Tfile) then EndFile := TRUE;   {We have reached the end!}
 End;

Procedure Backwards;                   {Backs up 102 lines in file}
 Var
   s : string;        x,z : byte;
   cnt : longint;     Offset : word;
 Begin
   Move(mem[$B800:0],mem[$B800:102*160],16320);
   SetScreenStart(start);
   FillChar(Mem[$B800:0],16320,0);
   Reset(Tfile);
   cnt:=0;
   While cnt < (OldPs-102) do Begin  {slow way to seek a text file}
     inc(cnt);
     Readln(Tfile);
   End;
   Dec(FilePs,102); Dec(OldPs,102);   {get our file position right!}
   If OldPs = 0 then StLoad := TRUE;
   z:=0;                                 {De ja vu!}
   While z<102 do Begin
     Inc(z);
     Readln(Tfile,S);
     offset := (z-1)*160;
     Character.attr := 7;
     for x := 1 to length(s) do begin
       character.ch := s[x];
       memw[$B800:offset] := word(character);
       inc(offset, 2);
     end;
   End;
   For z := 1 to 102 do Readln(Tfile,s);   {get back to right position}
 End;

{/////////////// Main Program//////////////////////////////////////////////}
begin
    If ParamCount < 1 Then Error(1);
    Assign(Tfile,Paramstr(1));                  {load our text file}
    {$I-} Reset(Tfile);  {$I+}
    If IoResult <> 0 Then Error(2);
    Initialize;
    repeat
        case port[$60] of                               { Check keypress    }
            DownKey : inc(velocity,2);
            UpKey   : dec(velocity,2);
            EscKey  : done := true;
        end;
        inc(start, velocity);                   { update screen position    }
        if word(start) > (203-24)*16 then
            if start < 0 then begin   {Hit top}
                If not StLoad Then Begin
                  start := (102)*16-velocity;    {kinda glitchy}
                  BackWards;
                End Else Begin
                  Start := 0;
                  velocity := 0;
                End;
            end
            else begin      {hit bottom}
                If Not EndFile Then Begin
                  start := (102-25)*16+velocity;   {same as   ^^^^}
                  Forwards;
                End Else Begin
                  start := (203-24)*16;
                  velocity := 0;
                End;
            end;
        if velocity > 0 then dec(velocity)
        else if velocity < 0 then inc(velocity);
        SetScreenStart(start);                      { set screen position   }
    until done;
    asm in al,21h; and al,253; out 21h,al; end;         { enable keyboard   }
    asm mov ax,3; int 10h; end;                         { reset text mode   }
end.
