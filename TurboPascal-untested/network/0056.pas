 {
 Program Name : 10Peek.Pas
 Written By   : Anonymous
 E-Mail       : nothing
 Web Page     : nothing
 Program
 Compilation  : Turbo Pascal 5.0 or later

 Program Description :

  This program uses the 10NET network function call $14 of the $6F interrupt
  (GetRemoteMemory) provided by 10NET to access first the low memory of
  another node, to find out what video mode it is currently in, and then
  Video memory, to "peek" at their screen and duplicate it locally. It works
  for monochrome, CGA in text or graphics mode, and EGA or VGA in all but
  their highest resolution graphics.
       The parameters that the program expects on startup are as illustrated:

       10Peek <Nodename> [<delay>]

  where <Nodename> must be currently on the network and available to NetStat,
  and <delay> is an optional number of seconds to delay between refreshes of
  the screen. Whether a delay is selected or not, a refresh can be forced by
  pressing the spacebar.
     This program takes advantage of TURBO Pascal 5.5 graph procedures to put
  the local monitor into the proper mode.

   [In the case of high resolution VGA/EGA modes, apparently part of the
  detail of their screen images is not available in their directly accessible
  memory.]

  }

Program TenPeek;


  Uses CRT,DOS,Graph;
TYPE
    VGABuffer = Array[0..32767] of Byte;

CONST
   VGARemScreen : Array[0..3] of Word = ($A000,$A800,$B000,$B800);
   VRec : Array[0..3] of ^VGABuffer = (Ptr($A000,0000),Ptr($A800,0000),Ptr($B000,0000),Ptr($B800,0000));
TYPE
   RegRec= Registers;
   Buffer = Byte;
   VidRec = Record
             VMode : Byte;
             ColCount : Integer;
             ScreenPagelength : Word;
             ScreenLoc : Integer;
             CursorPos : Array[1..8] of Array[1..2] of Byte;
             CursorSize : Array[1..2] of Byte;
             DisplayPage : Byte;
             ControllerAddr : Integer;
             CRTMode : Byte;
             PalletteMask : Byte;
          end;
    ScreenBuffer = Array[0..65490] of Char;
    String12 = String[12];
    ScreenRec = Record
                 RNode : String12;
                 SBuffer : ScreenBuffer;
                 VidBuffer : VidRec;
                end;
VAR
   VGAHi : Boolean;
   CGAScreen : Array[0..4096] of Byte absolute $B800:0000;
   EGAVGAScreen : Array[0..41360] of Byte absolute $A000:0000;
   LocalScreenBuffer : Array[0..4096] of Byte;
   PageOffset,ErrCode : Word;
   VideoMode : Byte;
   GDriver,GMode : Integer;
   PauseCount : Word;
   Test,I,IV,VLength : Integer;
   VidBuffer : VidRec;
   SRec : ^ScreenRec;
   LocalScreen : ^ScreenBuffer;
   RemScreen : Word;
   OneKey : Char;
   LocalVideo : VidRec absolute 0000:$0449;
   Reps : Integer;
   Regs : RegRec;

Procedure Save;
Begin
   Move(LocalVideo,VidBuffer,30);
   Repeat until ((Port[$3DA] and 8)=8);
   Move(LocalScreen^,LocalScreenBuffer,4096);
End;

Procedure Restore;
Begin
   GDriver:=CGA;
   GMode:=0;
   Case VidBuffer.VMode of
   0..3 : TextMode(VidBuffer.VMode);
   4 : InitGraph(GDriver,GMode,'');
   5 : InitGraph(GDriver,GMode,'');
   6 : InitGraph(GDriver,GMode,'');
   end;
   LocalScreen:=@CGAScreen;
   Repeat until ((Port[$3DA] and 8)=8);
   Move(LocalScreenBuffer,LocalScreen^,4096);
   Move(VidBuffer.CursorPos,LocalVideo.CursorPos,18);
End;


Procedure GetRemoteMemory(VAR Node : String12; RSeg,ROfs : Word; VAR RLength : Integer;VAR LBuffer);
Begin
   With Regs do
    begin
       AX:=$1400;
       BX:=RSeg;
       CX:=RLength;
       SI:=ROfs;
       DS:=Seg(Node);
       DX:=Ofs(Node)+1;
       While (Length(Node)<12) do Node:=Node+' ';
       DI:=Ofs(LBuffer);
       Intr($6F,Regs);
       If (Flags and 1)>0
       then
        begin
           Writeln(^G,'Error reading remote memory...Halting');
           Halt;
        end;
       RLength:=CX;
    end;
End;

Procedure SetVideoMode;
Begin
   Case SRec^.VidBuffer.VMode of
   0..3,7 : Begin
               VGAHi:=False;
               If ((SRec^.VidBuffer.VMode=3) and (SRec^.VidBuffer.ScreenPageLength>4096))
               then
                begin
                   TextMode(CO80+Font8X8);
                   LocalScreen:=@CGAScreen;
                   RemScreen:=$B800;
                   Reps:=17;
                end
               else if SRec^.VidBuffer.VMode=7 then TextMode(BW80)
               else TextMode(SRec^.VidBuffer.VMode);
               LocalScreen:=@CGAScreen;
            End;
   4 : Begin
          VGAHi:=False;
          GMode:=0;
          GDriver:=CGA;
          LocalScreen:=@CGAScreen;
       End;
   6 : Begin
          VGAHi:=False;
          GMode:=4;
          GDriver:=CGA;
          LocalScreen:=@CGAScreen;
       End;
   14 : Begin
           VGAHi:=False;
           GMode:=0;
           GDriver:=EGA;
           LocalScreen:=@EGAVGAScreen;
        End;
   16 : Begin
           VGAHi:=True;
           GMode:=1;
           GDriver:=VGA;
           LocalScreen:=@EGAVGAScreen;
        End;
   18,19 : Begin
           VGAHi:=True;
           GMode:=2;
           GDriver:=VGA;
           LocalScreen:=@EGAVGAScreen;
        End;
   End;
   If SRec^.VidBuffer.VMode in [4,6,14,16,18,19]
   then
    begin
       InitGraph(GDriver,GMode,'');
       ErrCode:=GraphResult;
       If ErrCode=0 then VideoMode:=SRec^.VidBuffer.VMode;
    end
   else VideoMode:=SRec^.VidBuffer.VMode;
End;

Procedure VideoParms;
Begin
   VLength:=30;
   GetRemoteMemory(SRec^.RNode,0,$449,VLength,SRec^.VidBuffer);
   If VLength<>30 then Halt;
{   ClrScr;
   GotoXY(1,1);
   Writeln('Mode: ',SRec^.VidBuffer.VMode);
   Writeln('Columns: ',SRec^.VidBuffer.ColCount);
   Writeln('Bytes/Page: ',SRec^.VidBuffer.ScreenPageLength);
   Delay(300);
 }  If VideoMode<>SRec^.VidBuffer.VMode
   then SetVideoMode;
   Case SRec^.VidBuffer.VMode of
        0 : Begin
               Reps:=4;
               RemScreen:=$B800;
            End;
        1 : Begin
               Reps:=4;
               RemScreen:=$B800;
            End;
        2 : Begin
               Reps:=8;
               RemScreen:=$B800;
            End;
        3 : If not((SRec^.VidBuffer.VMode=3) and (SRec^.VidBuffer.ScreenPageLength>4096))
            then
             begin
               Reps:=8;
               RemScreen:=$B800;
             End;
        4 : Begin
               Reps:=34;
               RemScreen:=$B800;
            End;
        6 : Begin
               Reps:=34;
               RemScreen:=$B800;
            End;
        7 : Begin
               Reps:=34;
               RemScreen:=$B000;
            End;
        14 : Begin
               Reps:=34;
               RemScreen:=$A000;
             End;
        16 : Begin
                Reps:=69;
                RemScreen:=$A000;
             end;
        18,19 : Begin
                Reps:=69;
                RemScreen:=$A000;
             End;

        else
         begin
	    TextMode(CO80);
            ClrScr;
            Writeln('VideoMode= ',SRec^.VidBuffer.VMode);
            Halt;
         end;
   end;
  Move(SRec^.VidBuffer.CursorPos,LocalVideo.CursorPos,18);
end;

{Main}
Begin
   If ParamCount=0
   then
    begin
       Writeln(' Syntax : ');
       Writeln('             10Peek <Nodename>');
    end
   else
    begin
       New(SRec);
       VideoMode:=255;
       VGAHi:=False;
       LocalScreen:=@CGAScreen;
       ErrCode:=0;
       SRec^.RNode:=ParamStr(1);
       For I:=1 to Length(SRec^.RNode) do SRec^.RNode[I]:=Upcase(SRec^.RNode[I]);
       PauseCount:=0;
       If Paramcount<2 then Test:=0 else VAL(ParamStr(2),PauseCount,Test);
       If test<>0 then PauseCount:=0;
       PauseCount:=PauseCount*10;
       Save;
       VideoParms;
       Repeat
          OneKey:=#0;
          If (SRec^.VidBuffer.VMode in [0..3])
          then PageOffset:=Integer(SRec^.VidBuffer.DisplayPage)*SRec^.VidBuffer.ScreenPageLength
          else PageOffset:=0;
          If not VGAHi
          then
           begin
              for I:=0 to Reps do
               begin
                  VLength:=470;
                  GetRemoteMemory(SRec^.RNode,RemScreen,I*470+PageOffset,VLength,SRec^.SBuffer[I*470]);
               end;
              Repeat until ((Port[$3DA] and 8)=8);
              Move(SRec^.SBuffer[0],LocalScreen^,(Reps*470)+VLength);
           end
          else for IV:=0 to 3 do
           begin
              Delay(10);
              for I:=0 to Reps do
               begin
                  VLength:=470;
                  GetRemoteMemory(SRec^.RNode,RemScreen,I*470+PageOffset,VLength,SRec^.SBuffer[I*470]);
               end;
              Move(SRec^.SBuffer,VRec[IV]^,32767);
           end;
          Sound(6000);
          Delay(50);
          Nosound;
          Repeat
             If PauseCount<>0
             then
              begin
                 OneKey:=#32;
                 For I:=1 to PauseCount do if not keypressed
                  then delay(100) else
                   begin
                      I:=PauseCount;
                      OneKey:=Readkey;
                   end;
              end
             else OneKey:=Readkey;
             If not (Onekey in [#32,#27]) then Write(#7);
          Until OneKey in [#32,#27];
          If Onekey=#32 then Videoparms;
       Until OneKey=#27;
      Restore;
   end;
End.
