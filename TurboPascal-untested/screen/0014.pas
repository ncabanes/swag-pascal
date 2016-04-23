Program TestVid;

{ High speed Text-video routines For working With binary Files, direct   }
{ screen access etc.  (c)1993 Chris Lautenbach                           }
{                                                                        }
{ You are hereby permitted to use this routines, so long as you give me  }
{ credit.  If you modify them, do not distribute the modified version.   }
{                                                                        }
{ This is the example Program, see SPEEDVID.PAS For the actual Unit      }
{ code, and usage information.                                           }
{                                                                        }
{ "ScreenFile" is a File containing sequential binary screen images. The }
{ easiest way to make these, is to draw several screens in a Program     }
{ like TheDraw, then save them as Binary.  After you are done, copy them }
{ all to one File, like so:                                              }
{                                                                        }
{ COPY /B SCREEN1.BIN+SCREEN2.BIN+SCREEN3.BIN SCREEN.BIN                 }
{                                                                        }
{ Note: the /B option is NECESSARY.  Without specifying binary mode,     }
{       COPY will insert ^Z's and other wierd stuff that will screw up   }
{       the resulting File.                                              }

Uses  Dos, Crt, SpeedVid;

Var   ScreenFile : File of ScreenLine;
      StartLine, TempLine, idx : Integer;
      Cmd : Char;
      p : Pointer;

Procedure ShowScreenLine(Index:Word);
begin
  If StartLine+Index<Filesize(ScreenFile) then
  begin
    Seek(ScreenFile, StartLine+Index-1);
    Read(ScreenFile, VideoScreen[Index]);
  end;
end;

begin
  MonoMode := (VideoMode = 7);
  SaveScreen(P);
  Assign(ScreenFile,'testvid.exe');
  {$I-} Reset(ScreenFile); {$I+}
  If IOResult<>0 then
  begin
    Writeln('Error: Cannot open SCREEN.BIN.');
    Halt;
  end;
  StartLine:=0;
  For TempLine:=1 to ScreenHeight do ShowScreenLine(TempLine);
  Repeat
    Repeat Until KeyPressed;
    Cmd:=ReadKey;
    If Cmd=#0 then
    begin
      Cmd:=ReadKey;
      Case Cmd of
{Down}  #80 : If StartLine+1<Filesize(ScreenFile) then
              begin
                Inc(StartLine);
                ScrollScreen(Up);
                ShowScreenLine(ScreenHeight);
              end;
{Up}    #72 : If StartLine-1>=0 then
              begin
                Dec(StartLine);
                ScrollScreen(Down);
                ShowScreenLine(1);
              end;
{PgDn}  #81 : begin
                If StartLine+ScreenHeight<Filesize(ScreenFile) then
                  TempLine:=ScreenHeight
                    ELSE
                  TempLine:=ScreenHeight-(Filesize(ScreenFile)-ScreenHeight);
                For idx:=1 to TempLine do
                begin
                  Inc(StartLine);
                  ScrollScreen(Up);
                  ShowScreenLine(ScreenHeight);
                end;
              end;
{PgUp}  #73 : begin
                If StartLine-ScreenHeight>=0 then
                  TempLine:=ScreenHeight
                    ELSE
                  TempLine:=StartLine;
                For idx:=1 to TempLine do
                begin
                  Dec(StartLine);
                  ScrollScreen(Down);
                  ShowScreenLine(1);
                end;
              end;
      end; {case}
    end;
  Until Cmd=#27; {ESC}
  Close(ScreenFile);
  RestoreScreen(P);
end.
