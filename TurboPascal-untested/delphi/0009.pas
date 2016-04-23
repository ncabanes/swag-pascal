
{
Someone was looking for a serial communication control, I just don't
quite remember who it was.  Hopefully this code will help him/her..
}
unit Comm;

interface

uses
  Messages,WinTypes,WinProcs,Classes,Excepts,Forms,MsgDlg;

type
  TPort=(tptNone,tptOne,tptTwo,tptThree,tptFour,tptFive,
         tptSix,tptSeven,tptEight);

  TBaudRate=(tbr110,tbr300,tbr600,tbr1200,tbr2400,tbr4800,tbr9600,
             tbr14400,tbr19200,tbr38400,tbr56000,tbr128000,
             tbr256000);

  TParity=(tpNone,tpOdd,tpEven,tpMark,tpSpace);

  TDataBits=(tdbFour,tdbFive,tdbSix,tdbSeven,tdbEight);

  TStopBits=(tsbOne,tsbOnePointFive,tsbTwo);

  TCommEvent=(tceBreak,tceCts,tceCtss,tceDsr,tceErr,tcePErr,
              tceRing,tceRlsd,tceRlsds,tceRxChar,tceRxFlag,
              tceTxEmpty);

  TCommEvents=set of TCommEvent;

const
  PortDefault=tptNone;
  BaudRateDefault=tbr9600;
  ParityDefault=tpNone;
  DataBitsDefault=tdbEight;
  StopBitsDefault=tsbOne;
  ReadBufferSizeDefault=2048;
  WriteBufferSizeDefault=2048;
  RxFullDefault=1024;
  TxLowDefault=1024;
  EventsDefault=[];

type
  TNotifyEventEvent=
    procedure(Sender:TObject;CommEvent:TCommEvents) of object;

  TNotifyReceiveEvent=
    procedure(Sender:TObject;Count:Word) of object;

  TNotifyTransmitEvent=
    procedure(Sender:TObject;Count:Word) of object;

  TComm=class(TComponent)
  private
    FPort:TPort;
    FBaudRate:TBaudRate;
    FParity:TParity;
    FDataBits:TDataBits;
    FStopBits:TStopBits;
    FReadBufferSize:Word;
    FWriteBufferSize:Word;
    FRxFull:Word;
    FTxLow:Word;
    FEvents:TCommEvents;
    FOnEvent:TNotifyEventEvent;
    FOnReceive:TNotifyReceiveEvent;
    FOnTransmit:TNotifyTransmitEvent;
    FWindowHandle:hWnd;
    hComm:Integer;
    HasBeenLoaded:Boolean;
    Error:Boolean;
    procedure SetPort(Value:TPort);
    procedure SetBaudRate(Value:TBaudRate);
    procedure SetParity(Value:TParity);
    procedure SetDataBits(Value:TDataBits);
    procedure SetStopBits(Value:TStopBits);
    procedure SetReadBufferSize(Value:Word);
    procedure SetWriteBufferSize(Value:Word);
    procedure SetRxFull(Value:Word);
    procedure SetTxLow(Value:Word);
    procedure SetEvents(Value:TCommEvents);
    procedure WndProc(var Msg:TMessage);
    procedure DoEvent;
    procedure DoReceive;
    procedure DoTransmit;
  protected
    procedure Loaded;override;
  public
    constructor Create(AOwner:TComponent);override;
    destructor Destroy;override;
    procedure Write(Data:PChar;Len:Word);
    procedure Read(Data:PChar;Len:Word);
    function IsError:Boolean;
  published
    property Port:TPort
      read FPort write SetPort default PortDefault;
    property BaudRate:TBaudRate read FBaudRate write SetBaudRate
      default BaudRateDefault;
    property Parity:TParity read FParity write SetParity
      default ParityDefault;
    property DataBits:TDataBits read FDataBits write SetDataBits
      default DataBitsDefault;
    property StopBits:TStopBits read FStopBits write SetStopBits
      default StopBitsDefault;
    property WriteBufferSize:Word read FWriteBufferSize
      write SetWriteBufferSize default WriteBufferSizeDefault;
    property ReadBufferSize:Word read FReadBufferSize
      write SetReadBufferSize default ReadBufferSizeDefault;
    property RxFullCount:Word read FRxFull write SetRxFull
      default RxFullDefault;
    property TxLowCount:Word read FTxLow write SetTxLow
      default TxLowDefault;
    property Events:TCommEvents read FEvents write SetEvents
      default EventsDefault;
    property OnEvent:TNotifyEventEvent read FOnEvent
      write FOnEvent;
    property OnReceive:TNotifyReceiveEvent read FOnReceive
      write FOnReceive;
    property OnTransmit:TNotifyTransmitEvent
      read FOnTransmit write FOnTransmit;
  end;

procedure Register;

implementation

procedure TComm.SetPort(Value:TPort);
const
  CommStr:PChar='COM1:';
begin
  FPort:=Value;
  if (csDesigning in ComponentState) or
     (Value=tptNone) or (not HasBeenLoaded) then exit;
  if hComm>=0 then CloseComm(hComm);
  CommStr[3]:=chr(48+ord(Value));
  hComm:=OpenComm(CommStr,ReadBufferSize,WriteBufferSize);
  if hComm<0 then
  begin
    Error:=True;
    exit;
  end;
  SetBaudRate(FBaudRate);
  SetParity(FParity);
  SetDataBits(FDataBits);
  SetStopBits(FStopBits);
  SetEvents(FEvents);
  EnableCommNotification(hComm,FWindowHandle,FRxFull,FTxLow);
end;

procedure TComm.SetBaudRate(Value:TBaudRate);  
var
  DCB:TDCB;  
begin
  FBaudRate:=Value;
  if hComm>=0 then
  begin
    GetCommState(hComm,DCB);
    case Value of
      tbr110:
        DCB.BaudRate:=CBR_110;
      tbr300:
        DCB.BaudRate:=CBR_300;
      tbr600:
        DCB.BaudRate:=CBR_600;
      tbr1200:
        DCB.BaudRate:=CBR_1200;
      tbr2400:
        DCB.BaudRate:=CBR_2400;
      tbr4800:
        DCB.BaudRate:=CBR_4800;
      tbr9600:
        DCB.BaudRate:=CBR_9600;
      tbr14400:
        DCB.BaudRate:=CBR_14400;
      tbr19200:
        DCB.BaudRate:=CBR_19200;
      tbr38400:
        DCB.BaudRate:=CBR_38400;
      tbr56000:
        DCB.BaudRate:=CBR_56000;
      tbr128000:
        DCB.BaudRate:=CBR_128000;
      tbr256000:
        DCB.BaudRate:=CBR_256000;
    end;
    SetCommState(DCB);
  end;
end;

procedure TComm.SetParity(Value:TParity);  
var
  DCB:TDCB;
begin
  FParity:=Value;
  if hComm<0 then exit;
  GetCommState(hComm,DCB);
  case Value of
    tpNone:
      DCB.Parity:=0;
    tpOdd:
      DCB.Parity:=1;
    tpEven:
      DCB.Parity:=2;
    tpMark:
      DCB.Parity:=3;
    tpSpace:
      DCB.Parity:=4;
  end;
  SetCommState(DCB);  
end;  

procedure TComm.SetDataBits(Value:TDataBits);
var
  DCB:TDCB;  begin
  FDataBits:=Value;
  if hComm<0 then exit;
  GetCommState(hComm,DCB);
  case Value of
    tdbFour:
      DCB.ByteSize:=4;
    tdbFive:
      DCB.ByteSize:=5;
    tdbSix:
      DCB.ByteSize:=6;
    tdbSeven:
      DCB.ByteSize:=7;
    tdbEight:
      DCB.ByteSize:=8;
  end;
  SetCommState(DCB);
end;

procedure TComm.SetStopBits(Value:TStopBits);
var
  DCB:TDCB;  
begin
  FStopBits:=Value;
  if hComm<0 then exit;
  GetCommState(hComm,DCB);
  case Value of
    tsbOne:
      DCB.StopBits:=0;
    tsbOnePointFive:
      DCB.StopBits:=1;
    tsbTwo:
      DCB.StopBits:=2;
  end;
  SetCommState(DCB);  
end;

procedure TComm.SetReadBufferSize(Value:Word);
begin
  FReadBufferSize:=Value;
  SetPort(FPort);  
end;  

procedure TComm.SetWriteBufferSize(Value:Word);
begin
  FWriteBufferSize:=Value;
  SetPort(FPort);  
end;  

procedure TComm.SetRxFull(Value:Word);  
begin
  FRxFull:=Value;
  if hComm<0 then exit;
  EnableCommNotification(hComm,FWindowHandle,FRxFull,FTxLow);  
end;

procedure TComm.SetTxLow(Value:Word);  
begin
  FTxLow:=Value;
  if hComm<0 then exit;
  EnableCommNotification(hComm,FWindowHandle,FRxFull,FTxLow);  
end;

procedure TComm.SetEvents(Value:TCommEvents);  
var
  EventMask:Word;  
begin
  FEvents:=Value;
  if hComm<0 then exit;
  EventMask:=0;
  if tceBreak in FEvents then inc(EventMask,EV_BREAK);
  if tceCts in FEvents then inc(EventMask,EV_CTS);
  if tceCtss in FEvents then inc(EventMask,EV_CTSS);
  if tceDsr in FEvents then inc(EventMask,EV_DSR);
  if tceErr in FEvents then inc(EventMask,EV_ERR);
  if tcePErr in FEvents then inc(EventMask,EV_PERR);
  if tceRing in FEvents then inc(EventMask,EV_RING);
  if tceRlsd in FEvents then inc(EventMask,EV_RLSD);
  if tceRlsds in FEvents then inc(EventMask,EV_RLSDS);
  if tceRxChar in FEvents then inc(EventMask,EV_RXCHAR);
  if tceRxFlag in FEvents then inc(EventMask,EV_RXFLAG);
  if tceTxEmpty in FEvents then inc(EventMask,EV_TXEMPTY);
  SetCommEventMask(hComm,EventMask);  
end;  

procedure TComm.WndProc(var Msg:TMessage);  
begin
  with Msg do
  begin
    if Msg=WM_COMMNOTIFY then
    begin
      case lParamLo of
        CN_EVENT:
          DoEvent;
        CN_RECEIVE:
          DoReceive;
        CN_TRANSMIT:
          DoTransmit;
      end;
    end
    else
      Result:=DefWindowProc(FWindowHandle,Msg,wParam,lParam);
  end;  
end;  

procedure TComm.DoEvent;
var
  CommEvent:TCommEvents;
  EventMask:Word;
begin
  if (hComm<0) or not Assigned(FOnEvent) then exit;
  EventMask:=GetCommEventMask(hComm,Integer($FFFF));
  CommEvent:=[];
  if (tceBreak in Events) and (EventMask and EV_BREAK<>0) then
    CommEvent:=CommEvent+[tceBreak];
  if (tceCts in Events) and (EventMask and EV_CTS<>0) then
    CommEvent:=CommEvent+[tceCts];
  if (tceCtss in Events) and (EventMask and EV_CTSS<>0) then
    CommEvent:=CommEvent+[tceCtss];
  if (tceDsr in Events) and (EventMask and EV_DSR<>0) then
    CommEvent:=CommEvent+[tceDsr];
  if (tceErr in Events) and (EventMask and EV_ERR<>0) then
    CommEvent:=CommEvent+[tceErr];
  if (tcePErr in Events) and (EventMask and EV_PERR<>0) then
    CommEvent:=CommEvent+[tcePErr];
  if (tceRing in Events) and (EventMask and EV_RING<>0) then
    CommEvent:=CommEvent+[tceRing];
  if (tceRlsd in Events) and (EventMask and EV_RLSD<>0) then
    CommEvent:=CommEvent+[tceRlsd];
  if (tceRlsds in Events) and (EventMask and EV_Rlsds<>0) then
    CommEvent:=CommEvent+[tceRlsds];
  if (tceRxChar in Events) and (EventMask and EV_RXCHAR<>0) then
    CommEvent:=CommEvent+[tceRxChar];
  if (tceRxFlag in Events) and (EventMask and EV_RXFLAG<>0) then
    CommEvent:=CommEvent+[tceRxFlag];
  if (tceTxEmpty in Events) and (EventMask and EV_TXEMPTY<>0) then
    CommEvent:=CommEvent+[tceTxEmpty];
  FOnEvent(Self,CommEvent);  
end;  

procedure TComm.DoReceive;  
var
  Stat:TComStat;  
begin
  if (hComm<0) or not Assigned(FOnReceive) then exit;
  GetCommError(hComm,Stat);
  FOnReceive(Self,Stat.cbInQue);
end;  

procedure TComm.DoTransmit;
var
  Stat:TComStat;  
begin
  if (hComm<0) or not Assigned(FOnTransmit) then exit;
  GetCommError(hComm,Stat);
  FOnTransmit(Self,Stat.cbOutQue);  
end;  

procedure TComm.Loaded;
begin
  inherited Loaded;
  HasBeenLoaded:=True;
  SetPort(FPort);
end;  

constructor TComm.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  FWindowHandle:=AllocateHWnd(WndProc);
  HasBeenLoaded:=False;
  Error:=False;
  FPort:=PortDefault;
  FBaudRate:=BaudRateDefault;
  FParity:=ParityDefault;
  FDataBits:=DataBitsDefault;
  FStopBits:=StopBitsDefault;
  FWriteBufferSize:=WriteBufferSizeDefault;
  FReadBufferSize:=ReadBufferSizeDefault;
  FRxFull:=RxFullDefault;
  FTxLow:=TxLowDefault;
  FEvents:=EventsDefault;
  hComm:=-1;
end;  

destructor TComm.Destroy;
begin
  DeallocatehWnd(FWindowHandle);
  if hComm>=0 then CloseComm(hComm);
  inherited Destroy;
end;  

procedure TComm.Write(Data:PChar;Len:Word);
begin
  if hComm<0 then exit;
  if WriteComm(hComm,Data,Len)<0 then Error:=True;  
end;  

procedure TComm.Read(Data:PChar;Len:Word);  
begin
  if hComm<0 then exit;
  if ReadComm(hComm,Data,Len)<0 then Error:=True;
end;  

function TComm.IsError:Boolean;
begin
  IsError:=Error;
  Error:=False;
end;

procedure Register;
begin
  RegisterComponents('Additional',[TComm]);
end;

end.

{------------------------------------------------------------------------------}

unit Main;  

interface 

uses
  Messages,WinTypes, WinProcs, Classes,
  Graphics, Forms, Controls,StdCtrls, Comm;  

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Comm1: TComm;
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure Comm1Receive(Sender: TObject; Count: Word);
  end;  

var
  Form1: TForm1;

implementation 

{$R *.FRM}

procedure TForm1.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
  Comm1.Write(@Key,SizeOf(Key));
end;

procedure TForm1.Comm1Receive(Sender: TObject; Count: Word);
var
  CommChar:Char;
  i:Word;
begin
  for i:=1 to Count do
  begin
    Comm1.Read(@CommChar,SizeOf(CommChar));
    PostMessage(Memo1.Handle,WM_CHAR,Word(CommChar),0);
  end;
end;

begin
  RegisterClasses([TForm1, TMemo, TComm]);
  Form1 := TForm1.Create(Application);
end.

