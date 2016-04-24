(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0046.PAS
  Description: Pick File Routines
  Author: JIM LUCKAS
  Date: 09-04-95  10:55
*)


{============================================================================}
{ PickFile.Pas - A unit that returns a filename selected by the user using    }
{                the point and shoot method.                                  }
{                You are free to modify and freely distribute the following   }
{                source code in any way you feel neccessary.                  }
{                I plan on using it in some of my database programs in order  }
{                for the user to select a databases for Him/Her to use.       }
{ Author : Jim Luckas (76630,370)                                             }
{                                                                             }
{ P.S. this is my first attempt at TP V4.0 (What a wonderfull experiance!)    }
{=============================================================================}

unit pickfile;

interface
uses dos,crt;
{$I-,S-,V-}

Const
  Shadow   = TRUE;
  NoShadow = FALSE;

Var Picked: Boolean; {True if a file was picked}

Function FPick(Path          : PathStr;
               BorderColor,WinColor,
               TopX,TopY,Deep: Byte;
               Shadow        : Boolean ) : PathStr;


implementation

type S_Type = string[13];


Function FAttr(path : PathStr) : Byte;
  var info: SearchRec;
  begin
    FindFirst(path,Directory,info);
    if DosError= 0 then
      FAttr := info.attr
    else
      FAttr := 0;
    end;

{-----------------------------------------------------------------------------}
{ This is the Function that you call from your main program.                  }
{ Path        = Search Path example. '*.pas'                                  }
{ Deep        = Maximum number of file names in the box.                      }
{ Shadow      = Should the box have a shadow?                                 }
{ This function returns the filename without the extension.                   }
{ Sample call : WriteLn(FPick('*.pas',White,White+Blue*16,10,10,23,Shadow))   }
{-----------------------------------------------------------------------------}

{--------------------------- Globals to be used by program -------------------}


Const
  FNameLen = 13;
  BoxWidth    = FNameLen + 2;
  ShadowWidth = BoxWidth + 2;

Type
  Stack_Ptr  = String[FNameLen];

Var
  HeapTop   : ^Integer;
  PtrArray  : Array[1..256] of ^Stack_Ptr;
  NuOfFiles,
  BotY,RecNum,Ypos : Byte;


Function FPick(Path          : PathStr;
               BorderColor,WinColor,
               TopX,TopY,Deep: Byte;
               Shadow        : Boolean ) : PathStr;

    Var
      SearchDir  : DirStr;
      SearchName : NameStr;
      SearchExt  : ExtStr;


{-----------------------------------------------------------------------------}
{ Return the last directory name in the string                                }
{-----------------------------------------------------------------------------}

    Function LastDir(p:DirStr):DirStr;
    var i : integer;
        disk : string[5];
    begin
      i := length(p);
      if p[i]='\' then begin
        dec(i);
        p[0] := chr(i);
      end;
      while (i>0) and not (p[i] IN ['\',':']) do dec(i);
      if (i>1) and (p[2]=':') then
        disk := p[1]+':'
      else
        disk := '';
      {
      if p[i]='\' then
        disk := disk + ' ..\';
      }
      LastDir := disk + Copy(p,i+1,255);
    end;


{-----------------------------------------------------------------------------}
{ Draw the Display Box for the filenames                                      }
{-----------------------------------------------------------------------------}

    Procedure Draw_Frame;
    begin
      If NuOfFiles > (Deep-TopY) then           {<- Decide How   }
        BotY := Deep                            {   Long to make }
      else BotY := (TopY + 1) + NuOfFiles;      {   Display Box  }
      If Shadow then                            {<- Check to see if  }
        Begin                                       {   we want a shodow }
          Window(TopX+1,TopY+1,TopX+ShadowWidth,BotY + 1); {<- Window the       }
          TextAttr := $07;                          {   shadow image     }
          ClrScr;                                   {   and clear it     }
        end;
      TextAttr := BorderColor;                   {<- Set the Frame color }
      Window(TopX,TopY,TopX+BoxWidth,BotY+1);    {<- Window the file box }
      Inc(TopY); dec(BotY);
      Write('┌──────────────┐');                    {     Now     }
      GotoXY(3,1);Write(LastDir(SearchDir));
      GotoXY(1,2);
      For Ypos := TopY to BotY do                   {   Draw the  }
        Write('│              │');                  {     Box     }
      Write('└──────────────┘');                    {    image    }
      Inc(TopX);
      Deep := BotY - TopY;                       {<- Change to inside depth }
      GotoXY(6,Deep+3);
      If NuOfFiles > Deep+1 then                 {<- Let the user Know   }
        Write(' more ');                         {   theres more to come }
    end;

{-----------------------------------------------------------------------------}
{ Store the FileNames in memory for now                                       }
{-----------------------------------------------------------------------------}

  Function Get_Files : Boolean;
    Var
      DirInfo : SearchRec;                      { Turbo's FileName Rec }

    Procedure AddFile(name:S_Type);
      begin
        inc(NuOfFiles);                       {<- Increment File Counter }
        New(PtrArray[NuOfFiles]);             {<- Get new pointer }
        PtrArray[NuOfFiles]^ := name;         {<- Store the FileName }
      end;

    begin
      NuOfFiles := 0;                           {<- Set Number of Files to 0 }
      FindFirst(SearchDir+Path,Archive, DirInfo);
      Get_Files := True;                        {<- Set Return to True }
      If DosError IN [0,18] then begin          {<- Check to see if any files }
        While DosError = 0 do
          begin
            AddFile(DirInfo.name);
            FindNext(DirInfo);
          end;
        FindFirst(SearchDir+'*.*',Directory, DirInfo);
        If DosError=0 then begin                {<- Check to see if any files }
          While DosError = 0 do
            begin
              with DirInfo do
                if (attr=Directory) and (name<>'.') then
                  AddFile(name+'\');
              FindNext(DirInfo);                    {<- Thanks Again }
            end
         end {if}
        else Get_Files := False;            {<- If no files found Return False }
       end {if}
      else Get_Files := False;            {<- If no files found Return False }
    end;

{-----------------------------------------------------------------------------}
{ Function that returns a parsed file name. exp.(Test.pas would return Test)  }
{-----------------------------------------------------------------------------}

  Function ParsedFile( FileToParse : S_Type) : S_Type;   { File name Passed }
    var d: DirStr;
        n: NameStr;
        x: ExtStr;
    begin
      if FileToParse[length(FileToParse)]='\' then
        ParsedFile := FileToParse
      else begin
        FSplit(FileToParse,d,n,x);
        while length(n)<SizeOf(NameStr)-1 do n := n + ' ';
        ParsedFile := n+x;                   {<- Return Parsed FileName }
      end;
    end;

{-----------------------------------------------------------------------------}
{ Draw the initial Display of FileNames                                       }
{-----------------------------------------------------------------------------}

  Procedure Draw_Files;
    begin
      Window(TopX,TopY,TopX+FNameLen,BotY); {<- First we need to Clear }
      TextAttr := WinColor;              {   The Display box to our }
      ClrScr;                            {   selected color         }
      For RecNum := 1 to deep+1 do       {<- Fill Display to Bottom }
        begin
          GotoXY(2,RecNum);
          Write(ParsedFile(PtrArray[RecNum]^));          {<- Write FileName }
        end;
      Window(1,1,80,25);                 {<- Set to default window }
    end;

{-----------------------------------------------------------------------------}
{ Procedure to scroll window                                                  }
{-----------------------------------------------------------------------------}
  Procedure Scroll(Direction : Char;
                   X,Y,Width,Deep,Lines,Attr : Byte);
    Var
      Reg : Registers;
    begin
      dec(X);                                     { Assembly  }
      dec(Y);                                     { is not    }
      inc(Deep,Y);                                { one of my }
      inc(Width,X);                               { favorite  }
      If Direction = 'D' then                     { things    }
        Reg.ah := 7                               { But must  }
      else Reg.ah := 6;                           { be done   }
      Reg.al := Lines;                            { sometimes }
      Reg.bh := Attr;                             { to save   }
      Reg.ch := Y;                                { on code   }
      reg.cl := X;
      reg.dh := Deep;
      Reg.dl := Width ;
      Intr(16,Reg);
    end;

{-----------------------------------------------------------------------------}
{ Here's we we actually start to pick the FileName                            }
{-----------------------------------------------------------------------------}

  Procedure Pick_File;
    Const FileNameLen = FNameLen + 1;
    Var CH       : Char;
        filename : String[FileNameLen];
        i        : Integer;
    begin
      Ypos := TopY;                             {<- Start selection at top }
      RecNum := 1;                              {<- and with the First file }
      repeat
          GotoXY(TopX,Ypos);
          TextAttr := $70;                      {<- HighLight attributte }
          For i := 1 to FileNameLen do
            FileName[i] := ' ';                 {<- Blankfill FileName }
          FileName[0] := chr(FileNameLen);
          Insert(ParsedFile(PtrArray[RecNum]^),FileName,2);
          Write(FileName);                      {<- Now Write HighLight Bar }
          CH := ReadKey;                        {<- Wait for Keystroke }
          If CH = #0 then                       {<- Is it an extended  }
            CH := ReadKey;                      {<- If so Read second Half }
          GotoXY(TopX,Ypos);                    {<- Rewrite FileName }
          TextAttr := WinColor;                 {   in Normal        }
          Write(FileName);                      {   Attributte       }
          Case CH of
            #80 : begin                         {<- Down Arrow Key }
                    inc(Ypos);
                    inc(RecNum);
                  end;
            #72 : Begin                         {<- Up Arrow Key }
                    dec(Ypos);
                    dec(RecNum);
                  end;
            #27 : PtrArray[RecNum]^ := '';      {<- If ESC the Return Null }
          end;
          If Ypos > BotY then                   {<- Did we reach the }
            begin                               {   Bottom of the    }
              dec(Ypos);                        {   Display and need }
              If RecNum <= NuOfFiles then       {   to Scroll Up     }
                Scroll('U',TopX,TopY,FNameLen,deep,1,WinColor)
              else RecNum := NuOfFiles;
            end;
          If Ypos < TopY then                   {<- Did we reach the }
            begin                               {   Top of the       }
              inc(Ypos);                        {   Display and need }
              If RecNum > 0 then                {   to Scroll Down   }
                Scroll('D',TopX,TopY,FNameLen,Deep,1,WinColor)
              Else RecNum := 1;
            end;
        until (CH = #13) or (CH = #27);      {<- Break out If Return or Esc }
      end;

{-----------------------------------------------------------------------------}
{ This is where main function FPick Starts                              }
{-----------------------------------------------------------------------------}

var SelectionMade : Boolean;
    oldDeep,oldX,oldY : Integer;
    oldWind : record
      x,y     : integer;
      attr    : byte;
      max,min : word;
      end;
    DeepX,DeepY : Integer;

begin
  if Deep<1 then Deep := 1;     {Minimum value}
  {Change Deep to a screen position}
    Deep := Deep + TopY + 2;
    if Shadow then
      DeepY := ShadowWidth - BoxWidth
    else
      DeepY:= 0;
    if Deep+DeepY>hi(WindMax) then begin {adjust to end of screen}
      Deep := hi(WindMax)-DeepY;
      if Deep-TopY < 2 then begin {not enough room!}
        FPick := '';
        DosError := 0;
        Exit;
      end;
    end;
  DeepX := TopX + BoxWidth + DeepY;
  DeepY := Deep + DeepY;
  oldDeep := Deep;
  oldX := TopX;  oldY := TopY;
  with oldWind do begin
    x := WhereX;     y := WhereY;
    attr := TextAttr;
    min := WindMin;  max := WindMax;
  end;
  SelectionMade := FALSE;
  FSplit(FExpand(Path),SearchDir,SearchName,SearchExt);
  repeat
    Picked := FALSE;
    Path := SearchName+SearchExt;
    Mark(HeapTop);                                {<- Mark HeapTop             }
    If Get_Files then                             {<- if Files Found Continue  }
      begin
        Draw_Frame;                               {<- Draw the Display Frame   }
        Draw_Files;                               {<- Fill Display with Files  }
        Pick_File;                                {<- Pick a FileName          }
        path := PtrArray[RecNum]^;
        SelectionMade := (path='');
        if SelectionMade then
          path := SearchDir
        else begin
          path := FExpand(SearchDir + path);
          if path[length(path)]='\' then
            SearchDir := path
          else begin
            SelectionMade := TRUE;
            Picked        := TRUE;
          end;
        end;
      end
    else begin
      path := '';                                 {<- No Files Found Ret ''   }
      SelectionMade := TRUE;
    end;
    Release(HeapTop);                             {<- Release the memory used  }
    {Restore the input parameters}
      TopX := oldX;  TopY := oldY;
      Deep := oldDeep;
    {Clear up the screen}
      Window(TopX,TopY,DeepX,DeepY);
      TextAttr := oldWind.attr;
      GotoXY(1,1);
      ClrScr;
  until SelectionMade;
  {Restore the screen}
    with oldWind do begin
      Window(lo(min)+1,hi(min)+1,lo(max)+1,hi(max)+1);
      GotoXY(x,y);
      TextAttr := Attr;
    end;
  FPick := path;
end;

Begin
End.

{ -------------------   DEMO PROGRAM --------------- }

{--------------------------- Demo for PickFile.pas ---------------------------}
{                For a better description peruse pickfile.pas                 }
{-----------------------------------------------------------------------------}
{ PickFile.tpu    - Turbo unit for selecting a file from the directory }
{ PFdemo.pas      - This pas file to demonstarate PickFile             }
{ PickFile.pas    - The source for PickFile.tpu.                       }
{ All yours to use as you wish.                                        }
{                                                                      }
{ Function FPick (Path        : PathStr;                               }
{                 BorderColor,WindowColor,                             }
{                 TopX,TopY,BotY,Shadow : Byte ) : PathStr;            }
{ Shadow  1=yes 0=no                                                   }
{----------------------------------------------------------------------}

uses Dos,Crt,PickFile;

Const
  OnBlack     =   0;
  OnBlue      = $10;
  OnGreen     = $20;
  OnCyan      = $30;
  OnRed       = $40;
  OnMagenta   = $50;
  OnBrown     = $60;
  OnLightGray = $70;

Var
  PathName : String[80];
  FileName : PathStr;
  Starts   : integer;

Begin
  Textattr := White+OnBlue;
  ClrScr;
  Textattr := White+OnMagenta;
  Write('Enter a FileSpec : ');
  Starts := WhereX;
  ReadLn(PathName);
  Textattr := White+OnBlue;
{------------------ This is where we call the function --------------------}

  FileName := FPick(PathName,White,White+OnBlue,Starts,WhereY+1,25,Shadow);

{--------------------------------------------------------------------------}
{
  TextAttr := $07;
  ClrScr;
}
  If Picked then
    WriteLn('You selected : ',Filename)
  Else If Filename = '' then
    WriteLn('PickFile Aborted (',DosError,')')
  Else
    Writeln('You quit looking in : ',Filename);
end.

