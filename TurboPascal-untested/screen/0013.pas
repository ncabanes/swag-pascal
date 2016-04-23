Unit SpeedVid;

{ High speed Text-video routines For working With binary Files, direct  }
{ screen access etc.  (c)1993 Chris Lautenbach                          }
{                                                                       }
{ You are hereby permitted to use this routines, so long as you give me }
{ credit.  If you modify them, do not distribute the modified version.  }
{                                                                       }
{ Notes:   This Unit will work fine in 50 line mode, or on monochrome   }
{          monitors.  Remember; when working in 50 line mode, always    }
{          make sure you call Window(1,1,80,50) so that WindMax is      }
{          updated With the correct screen co-ordinates.  In addition,  }
{          the ScrollScreen() routine is much faster than it's standard }
{          BIOS Int 10h counterpart.                                    }
{                                                                       }
{          Turbo Professional users have no need For FastWrite(),       }
{          VideoMode, or ScreenHeight - since these are approximations  }
{          are provided For use by people who do not have the TpCrt     }
{          Unit.                                                        }
{                                                                       }
{ If you need to contact me, I can be found in the NANet, City2City,    }
{ and Intelec Pascal echoes - or at my support BBS, Toronto Twilight    }
{ Communications (416) 733-9012. Internet: cs911212@iris.ariel.yorku.ca }

Interface

Uses
  Dos, Crt;

Const
  MonoMode : Boolean = False;

Type
  ScreenLine = Array[1..160] of Char;
  ScreenBuffer = Array[1..50] of ScreenLine;
  DirectionType = (Up, Down);

Var
  VideoScreen : ScreenBuffer Absolute $B800:$0000;
  MonoScreen  : ScreenBuffer Absolute $B000:$0000;

Function  VideoMode : Byte;                               { Get video mode }
Function  ScreenHeight : Byte;          { Return height of screen in lines }
Procedure ScrollScreen(Direction : DirectionType); { Scroll screen up/down }
Procedure FastWrite(st:String; x,y,color:Byte);    { Write Text to vid mem }
Procedure RestoreScreen(Var p:Pointer);             { Restore saved screen }
Procedure SaveScreen(Var p:Pointer);            { Save screen to a Pointer }

Implementation

Function VideoMode : Byte;
Var
  Mode : Byte;
begin
  Asm
    MOV AH, 0Fh              { Set Function to 0Fh - Get current video mode }
    INT 10h                  { Call interrupt 10h - Video Services }
    MOV Mode, AL             { Move INT 10h result to Mode Variable }
  end;
  VideoMode := Mode;
end;

Function ScreenHeight:Byte;
begin
  ScreenHeight := (Hi(WindMax) + 1);
end;

Procedure ScrollScreen(Direction : DirectionType);
begin
  Case Direction of
    Up   :
      If MonoMode then
        Move(MonoScreen[2],MonoScreen[1],Sizeof(ScreenLine)*(ScreenHeight-1))
      ELSE
        Move(VideoScreen[2],VideoScreen[1],Sizeof(ScreenLine)*(ScreenHeight-1));
    Down :
      If MonoMode then
        Move(VideoScreen[1],VideoScreen[2],Sizeof(ScreenLine)*(ScreenHeight-1))
      ELSE
        Move(VideoScreen[1],VideoScreen[2],Sizeof(ScreenLine)*(ScreenHeight-1));
  end; { Case }
end;

Procedure FastWrite(st:String; x,y,color:Byte);
{ Write a String directly to the screen, x=column, y=row }
Var
  idx, cdx : Byte;
begin
  idx := x * 2;
  cdx := 1;
  Repeat
    {$R-}
    If MonoMode then
    begin
      MonoScreen[y][idx+2] := Chr(Color);
      MonoScreen[y][idx+1] := St[cdx];
    end
    ELSE
    begin
      VideoScreen[y][idx+2] := Chr(Color);
      VideoScreen[y][idx+1] := St[cdx];
    end;
    {$R+}
    Inc(idx,2);
    Inc(cdx,1);
  Until cdx>=length(st);
end;

Procedure RestoreScreen(Var p:Pointer);
begin
 If Assigned(P) then  { make sure this Pointer IS allocated }
 begin
   If MonoMode then
     Move(P^, MonoScreen, 4000)
   ELSE
     Move(P^, VideoScreen, ScreenHeight*SizeOf(ScreenLine));
   FreeMem(P,ScreenHeight*Sizeof(ScreenLine));
 end;
end;

Procedure SaveScreen(Var p:Pointer);
begin
  If not Assigned(P) then   { make sure Pointer isn't already allocated }
  begin
    GetMem(P,ScreenHeight*Sizeof(ScreenLine));
    If MonoMode then
      Move(MonoScreen, P^, 4000)
    ELSE
      Move(VideoScreen, P^, ScreenHeight*Sizeof(ScreenLine));
  end;
end;


begin
end.