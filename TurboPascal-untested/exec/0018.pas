{ A bit wordy - but easy to include in an application - three "hooks" in }
{ the form of the first three internal procedures to customize the code. }
{ NOTE! MaxHeap must be limited to allow the EXEC procedure to function. }
{ By Carl York with code by Neil J. Rubenking and Richard S. Sandowsky.  }

UNIT DOSShell;

INTERFACE
procedure ShellToDOS;

IMPLEMENTATION
USES CRT, DOS;

procedure ShellToDOS;
const
  SmallestAllowableRam = 5;                   { Set   }
  Normal               = 7;                   { to    }
  Reverse              = 112;                 { your  }
  ApplicationName      = 'MY OWN PROGRAM';    { specs }
var
  ProgramName,
  CmdLineParam,
  NewDirect,
  HoldDirect     : PathStr;
  HoldAttr       : byte;
  HoldMin,
  HoldMax        : word;
  SlashSpot,
  BlankSpot      : byte;

{+++++++++++++++++++++++++++++++}
procedure PrintMessage;
begin
  { Clever message to make your end user feel foolish }
end;
{-------------------------------}

{++++++++++++++++++++++}
procedure SwapScreenOut;
begin
  { Whatever routine you want to use to    }
  { save the contents on the active screen }
end;
{---------}

{++++++++++++++++++++++}
procedure SwapScreenIn;
begin
  { Whatever routine you want to use to }
  { restore the contents on the screen  }
end;
{---------}

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
function GetProgramToRun : PathStr;
{ Courtesy of Neil Rubenking, this code duplicates the way DOS normally }
{ searches the path for a file name typed in at the DOS level using the }
{ TP5 routines FSearch and FExpand (code published PC Magazine 1/17/89) }
var
  Name : PathStr;
begin
  Name := FSearch(ProgramName + '.COM','');          { Search    }
  If Name = '' then                                  { the       }
    Name := FSearch(ProgramName + '.EXE','');        { active    }
  If Name = '' then                                  { drive/    }
    Name := FSearch(ProgramName + '.BAT','');        { directory }
  If Name = '' then
    Name := FSearch(ProgramName + '.COM',GetEnv('PATH'));
  If Name = '' then                                          { Search }
    Name := FSearch(ProgramName + '.EXE',GetEnv('PATH'));    { the    }
  If Name = '' then                                          { path   }
    Name := FSearch(ProgramName + '.BAT',GetEnv('PATH'));
  If Name <> '' then
    Name := FExpand(Name);
  GetProgramToRun := Name;
end;
{------------------------------------------------------------------------}

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
function RAMFreeInK : Word;
{ A tidy little chunk of Inline code from Rich Sandowsky }
Inline(
  $B8/$00/$48/           {  mov   AX,$4800  ; set for DOS function 48h}
  $BB/$FF/$FF/           {  mov   BX,$FFFF  ; try to allocate more RAM}
                         {                  ; than is possible}
  $CD/$21/               {  int   $21       ; execute the DOS call}
  $B1/$06/               {  mov   CL,6      ;}
  $D3/$EB/               {  shr   BX,CL     ; convert to 1K blocks}
  $89/$D8);              {  mov   AX,BX     ; return number of 1K blocks}
                         {                  ; RAM free as function result}
{------------------------------------------------------------------------}

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
procedure WritePrompt;
{ Create a DOS prompt for the user }
begin
  TextAttr := Normal;
  Write('Temporarily in DOS (',RAMFreeInK,'K available) ... Type ');
  TextAttr := Reverse;
  Write('EXIT');
  TextAttr := Normal;
  WriteLn(' to return to ',ApplicationName);
  Write(NewDirect,'>');
end;
{------------------------------------------------------------------------}

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
procedure RunTheShell;
{ The actual use of the EXEC procedure }
var
  Index : integer;
begin
  GetDir(0,NewDirect);
  WritePrompt;
  CmdLineParam := '';
  ReadLn(ProgramName);
  For Index := 1 to length(ProgramName) do
    ProgramName[index] := Upcase(ProgramName[Index]);
  While ProgramName[length(ProgramName)] = #32 do
    Dec(ProgramName[0]);
  While (length(ProgramName) > 0) and (ProgramName[1] = #32) do
    Delete(ProgramName,1,1);
  If (ProgramName <> 'EXIT') then
    begin
      EXEC(GetEnv('COMSPEC'),'/C '+ ProgramName + CmdLineParam);
      { Brute force to see if we need to pursue any further }
      If Lo(DOSExitCode) <> 0 then
        begin
          BlankSpot := pos(' ',ProgramName);
          SlashSpot := pos('/',ProgramName);
          If SlashSpot > 0 then
            If (SlashSpot < BlankSpot) or (BlankSpot = 0) then
              BlankSpot := SlashSpot;
          If BlankSpot > 0 then
            begin
              CmdLineParam := copy(ProgramName,BlankSpot,Length(ProgramName));
              ProgramName[0] := Chr(pred(BlankSpot));
            end;
          ProgramName := GetProgramToRun;
          If ProgramName <> '' then
            If pos('.BAT',ProgramName) > 0 then
              EXEC(GetEnv('COMSPEC'),'/C '+ ProgramName + CmdLineParam)
            else EXEC(ProgramName,CmdLineParam);
        end;
    end;
  WriteLn;
end;
{------------------------------------------------------------------------}

{=================================}
begin
  If RamFreeInK <= SmallestAllowableRam then
    begin
      PrintMessage;
      EXIT;
    end;
  HoldAttr := TextAttr;           { Grab the current video attribute }
  GetDir(0,HoldDirect);           { Grab the current drive/path }
  HoldMin := WindMin;
  HoldMax := WindMax;             { And the current window }
  TextAttr := Normal;
  SwapScreenOut;
  Window(1,1,80,25);
  ClrScr;
  SwapVectors;
  Repeat
    RunTheShell;
  Until ProgramName = 'EXIT';
  SwapVectors;                      { Restore all the original set up }
  ChDir(HoldDirect);
  TextAttr := HoldAttr;
  Window(Lo(HoldMin),Hi(HoldMin),Lo(HoldMax),Hi(HoldMax));
  ClrScr;
  SwapScreenIn;
end;

END.
