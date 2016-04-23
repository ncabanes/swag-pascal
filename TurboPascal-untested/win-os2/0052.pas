{
  This program demonstrates a simple terminal emulator using
  Serial Communications.  Windows provides support for the
  communications port so your program will be able to poll the
  port and send/recieve data from a remote location.

  Since this is not a program that Borland International has
  developed through normal quality channels, we do not provide
  technical support or establish bug lists for this demonstration
  program.  It is for the sole purpose of demonstrating the use
  of the available functions.
}


Program Terminal;

uses WinTypes, WinProcs, WObjects, Strings;
const
  idEdit     = 100;
  LineWidth  = 80;  { Width of each line displayed.                  }
  LineHeight = 60;  { Number of lines that are held in memory.       }

  { The configuration string below is used to configure the modem.  }
  { It is set for communication port 2, 2400 baud, No parity, 8 data }
  { bits, 1 stop bit.                                                }

  Config = 'com2:24,n,8,1';
  CPort = 'com2';

  { An example of using communication port 1, 1200 baud, Even parity }
  { 7 data bits, 2 stop bits.                                        }
  {  Config = 'com1:12,e,7,2';                                       }


type
  TApp = object(TApplication)
    procedure Idle; virtual;
    procedure InitMainWindow; virtual;
    procedure MessageLoop; virtual;
  end;

  PBuffer = ^TBuffer;
  TBuffer = object(TCollection)
    Pos: Integer;
    constructor Init(AParent: PWindow);
    procedure FreeItem(Item: Pointer); virtual;
    function PutChar(C: Char): Boolean;
  end;

  PCommWindow = ^TCommWindow;
  TCommWindow = object(TWindow)
    Cid: Integer;
    Buffer: PBuffer;
    FontRec: TLogFont;
    CharHeight: Integer;
    constructor Init(AParent: PWindowsObject; ATitle: PChar);
    destructor Done; virtual;
    procedure Error(E: Integer; C: PChar);
    procedure Paint(PaintDC: HDC; var PaintInfo: TPaintStruct); virtual;
    procedure ReadChar; virtual;
    procedure SetHeight;
    procedure SetUpWindow; virtual;
    procedure wmChar(var Message: TMessage);
      virtual wm_Char;
    procedure wmSize(var Message: TMessage);
      virtual wm_Size;
    procedure WriteChar;
  end;

{ TBuffer }
{ The Buffer is used to hold each line that is displayed in the main   }
{ window.  The constant LineHeight determines the number of lines that }
{ are stored.  The Buffer is preloaded with the LineHeight worth of    }
{ lines.                                                               }
constructor TBuffer.Init(AParent: PWindow);
var
  P: PChar;
  I: Integer;
begin
  TCollection.Init(LineHeight + 1, 10);
  GetMem(P, LineWidth + 1);
  P[0] := #0;
  Pos := 0;
  Insert(P);
  for I := 1 to LineHeight do
  begin
    GetMem(P, LineWidth + 1);
    P[0] := #0;
    Insert(P);
  end;
end;

procedure TBuffer.FreeItem(Item: Pointer);
begin
  FreeMem(Item, LineWidth + 1);
end;

{ This procedure processes all incomming in formation from the comm }
{ port.  This procedure is called by TCommWindow.ReadChar.           }

function TBuffer.PutChar(C: Char): Boolean;
var
  Width: Integer;
  P: PChar;
begin
  PutChar := False;
  Case C of
    #13: Pos := 0;                          { if a Carriage Return.  }
    #10:                                    { if a Line Feed.        }
      begin
        GetMem(P, LineWidth + 1);
        FillChar(P^, LineWidth + 1, ' ');
        P[Pos] := #0;
        Insert(P);
      end;
    #8:
      if Pos > 0 then                       { if a Delete.           }
      begin
        Dec(Pos);
        P := At(Count - 1);
        P[Pos] := ' ';
      end;
   #32..#128:                               { else handle all other  }
    begin                                   { displayable characters.}
      P := At(Count - 1);
      Width := StrLen(P);
      if Width > LineWidth then             { if line is to wide     }
      begin                                 { create a new line.     }
        Pos := 1;
        GetMem(P, LineWidth + 1);
        P[0] := C;
        P[1] := #0;
        Insert(P);
      end
      else                                   { else add character    }
      begin                                  { to current line.      }
        P[Pos] := C;
        Inc(Pos);
        P[Pos] := #0;
      end;
    end;
  end;
  if Count > LineHeight then                 { if more to many lines }
  begin                                      { have been added delete}
    AtFree(0);                               { current line and let  }
    PutChar := True;                         { the call procedure    }
  end;                                       { know to scroll up.    }
end;

{ TCommWindow }
{ The CommWindow displays the incoming and out goinging text.  Note   }
{ that the text type by the use is displayed by                      }
{ being echoed back to the ReadChar procedure.  So there is no need for }
{ wmChar to write a character to the screen.                          }
constructor TCommWindow.Init(AParent: PWindowsObject; ATitle: PChar);
begin
  TWindow.Init(AParent, ATitle);
  Attr.Style := Attr.Style or ws_VScroll;
  Scroller := New(PScroller, Init(@Self, 1, 1, 100, 100));
  Buffer := New(PBuffer, Init(@Self));
end;

{ Close the Comm port and deallocate the Buffer.                      }
destructor TCommWindow.Done;
begin
  Error(CloseComm(Cid), 'Close');
  Dispose(Buffer, Done);
  TWindow.Done;
end;

{ Checks for comm errors and writes any errors.                       }
procedure TCommWindow.Error(E: Integer; C: PChar);
var
  S: array[0..100] of Char;
begin
  if E >= 0 then exit;
  Str(E, S);
  MessageBox(GetFocus, S, C, mb_Ok);
end;

{ Redraw all the lines in the buffer by using ForEach.                }
procedure TCommWindow.Paint(PaintDC: HDC; var PaintInfo: TPaintStruct);
var
  I: Integer;
  Font: HFont;

  procedure WriteOut(Item: PChar); far;
  begin
    TextOut(PaintDC, 0, CharHeight * I, Item, StrLen(Item));
    inc(I);
  end;

begin
  I := 0;
  Font := SelectObject(PaintDC, CreateFontIndirect(FontRec));
  Buffer^.ForEach(@WriteOut);
  DeleteObject(SelectObject(PaintDC, Font));
end;

{ Read a charecter from the comm port, if there is no error then call }
{ Buffer^.PutChar to add it to the buffer and write it to the screen. }
procedure TCommWindow.ReadChar;
var
  Stat: TComStat;
  I, Size: Integer;
  C: Char;
begin
  GetCommError(CID, Stat);
  for I := 1 to Stat.cbInQue do
  begin
    Size := ReadComm(CId, @C, 1);
    Error(Size, 'Read Comm');
    if C <> #0 then
    begin
      if Buffer^.PutChar(C) then
      begin
        ScrollWindow(HWindow, 0, -CharHeight, Nil, Nil);
        UpDateWindow(HWindow);
      end;
      WriteChar;
    end;
  end;
end;

procedure TCommWindow.SetUpWindow;
var
  DCB: TDCB;
begin
  TWindow.SetUpWindow;
  SetHeight;

{ Open for Comm2 2400 Baud, No Parity, 8 Data Bits, 1 Stop Bit }

  BuildCommDCB(Config, DCB);
  Cid := OpenComm('COM2', 1024, 1024);
  Error(Cid, 'Open');
  DCB.ID := CID;
  Error(SetCommState(DCB), 'Set Comm State');
  WriteComm(Cid, 'ATZ'#13#10, 5);  { Send a reset to Modem. }
end;

{ Call back function used only in to get record structure for fixed   }
{ width font.                                                         }
function GetFont(LogFont: PLogFont; TM: PTextMetric; FontType: Word;
  P: PCommWindow): Integer; export;
begin
  if P^.CharHeight = 0 then
  begin
    P^.FontRec := LogFont^;
    P^.CharHeight := P^.FontRec.lfHeight;
  end;
end;

{ Get the a fixed width font to use in the TCommWindow.  Use EnumFonts  }
{ to save work of create the FontRec by hand.                         }
{ The TScroller of the main window is also updated know that the font }
{ height is known.                                                    }

procedure TCommWindow.SetHeight;
var
  DC: HDC;
  ProcInst: Pointer;
begin
  DC := GetDC(HWindow);
  CharHeight := 0;
  ProcInst := MakeProcInstance(@GetFont, HInstance);
  EnumFonts(DC, 'Courier', ProcInst, @Self);
  FreeProcInstance(ProcInst);
  ReleaseDC(HWindow, DC);

  Scroller^.SetUnits(CharHeight, CharHeight);
  Scroller^.SetRange(LineWidth, LineHeight);
  Scroller^.ScrollTo(0, LineHeight);
end;


{ Write the character from the pressed key to the Communication Port.   }
procedure TCommWindow.wmChar(var Message: TMessage);
begin
  if CID <> 0 then
    Error(WriteComm(CId, @Message.wParam, 1), 'Writing');
end;

procedure TCommWindow.wmSize(var Message: TMessage);
begin
  TWindow.wmSize(Message);
  Scroller^.SetRange(LineWidth, LineHeight -
                    (Message.lParamhi div CharHeight));
end;

procedure TCommWindow.WriteChar;
var
  DC: HDC;
  Font: HFont;
  S: PChar;
  APos: Integer;
begin
  APos := Buffer^.Count - 1;
  S := Buffer^.AT(APos);
  APos := (APos - Scroller^.YPos) * CharHeight;
  if APos < 0 then exit;
  if Hwindow <> 0 then
  begin
    DC := GetDC(HWindow);
    Font := SelectObject(DC, CreateFontIndirect(FontRec));
    TextOut(DC, 0, APos, S, StrLen(S));
    DeleteObject(SelectObject(DC, Font));
    ReleaseDC(HWindow, DC);
  end;
end;

{ TApp }
procedure TApp.Idle;
var
  Stat: TComStat;
  I, Size: Integer;
  C: Char;
begin
  if MainWindow <> Nil then
    if MainWindow^.HWindow <> 0 then
      PCommWindow(MainWindow)^.ReadChar;
end;

procedure TApp.InitMainWindow;
begin
  MainWindow := New(PCommWindow, Init(Nil, 'Comm Test'));
end;

{ Add Idle loop to main message loop used for polling.               }
procedure TApp.MessageLoop;
var
  Message: TMsg;
begin
  while True do
  begin
    if PeekMessage(Message, 0, 0, 0, pm_Remove) then
    begin
      if Message.Message = wm_Quit then
      begin
        Status := Message.WParam;
        Exit;
      end;
      if not ProcessAppMsg(Message) then
      begin
        TranslateMessage(Message);
        DispatchMessage(Message);
      end;
    end
    else
      Idle;
  end;
end;

var
  App: TApp;
begin
  App.Init('Comm');
  App.Run;
  App.Done;
end.
