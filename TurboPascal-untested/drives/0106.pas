
Unit CD_ROM;
Interface
Const
  RED=1;
  HSG=0;
  GlobalError:Word    = 0;
  GlobalDriveCount:Byte    = 0;
  MSCDEXOk:Boolean = FALSE;
  AudioCD:Boolean = FALSE;
Type
  REDUnPack = Record
             Frame:Byte;
             Second:Byte;
             Minute:Byte;
             Unused:Byte;
             End;
Var
  GlobalDriveNo:Byte;
  GlobalLeadOut:LongInt;
  GlobalTrackMin:Byte;
  GlobalTrackMax:Byte;
  GlobalAktualTrack :Byte;
  TOC:Array [1..99] Of LongInt;
Function  RED2HSG(Minute, Second, Frame :LongInt) :LongInt;
Procedure HSG2RED(HSG :LongInt; var Minute, Second, Frame :LongInt);
Procedure Audio_Disk_Info(var TrackMin,TrackMax :Byte; var LeadOut :LongInt);
Procedure Audio_Track_Info(TrackNr :Byte; var TrackStart :LongInt; var CntlAdr
:Byte);Function  Media_Changed :Byte;
Procedure Audio_Status(var AudioStatus :Word; var StartResume,EndPlay
:LongInt);Procedure Stop_Audio;
Procedure Pause_Audio;
Procedure Resume_Audio;
Procedure Play_Audio(StartSector,nFrames :LongInt);
Function  Location_of_Head(AdressMode :Byte) :LongInt;
Function  Device_Status :LongInt;
Procedure Audio_Channel_Info(var
ChOut0,Vol0,ChOut1,Vol1,ChOut2,Vol2,ChOut3,Vol3 :Byte);Procedure
Audio_Q_Channel_Info(var TrackNo,Min,Sec,Frame,Zero,AMin,ASec,AFrame :Byte);
Function  Disk_Remain :LongInt;
Function  Track_Remain :LongInt;
Function  Get_UPC :String;
Procedure MSCDEX_Version(var HVersion, NVersion :Byte);
Function  CDROM_Number(var DriveNo :Byte) :Byte;
Procedure MSCDEX_Init;
Procedure ReadTOC;
Procedure Calculate_Track(TrackNo :Byte; var StartSector,TrackLength,DiskEnd
:LongInt);Procedure Play_Track(TrackNo :Byte);
Procedure Play_Track_to_End(TrackNo :Byte);
Procedure Show_Track(TrackNo, Seconds :Byte);
Procedure Next_Track;
Procedure Last_Track;
Procedure Next_Track_to_End;
Procedure Last_Track_to_End;
Procedure Eject_Disk;
Procedure Close_Tray;
Procedure Lock_Door;
Procedure UnLock_Door;
Procedure Reset_Drive;
Procedure
Audio_Channel_Control(ChOut0,Vol0,ChOut1,Vol1,ChOut2,Vol2,ChOut3,Vol3
:Byte);Procedure Chk_Audio;Implementation
Const
  TOCreaded : Boolean = FALSE;
Type
  Ptr     = Record
              Ofs :Word;
              Seg :Word;
            End;
  TDevName = Array [1..8] of Char;
  TRequestHeader =
    Record
      Len             :Byte;
      SubUnit         :Byte;
      CommandCode     :Byte;
      Status          :Word;
      DevName         :TDevName;
    End;
  TIOCtlOBufferStruct =
    Record
      Command:Byte;
      Data0:Byte;
      Data1:Byte;
      Data2:Byte;
      Data3:Byte;
      Data4:Byte;
      Data5:Byte;
      Data6:Byte;
      Data7:Byte;
    End;
  TIOCtlO =
    Record
      RequestHeader:TRequestHeader;
      MediaDescriptor:Byte;
      Buffer:Pointer;
      BufferSize:Word;
      StartSector:LongInt;
      VolumePtr:LongInt;
    End;
  TIOCtlI =
    Record
      RequestHeader:TRequestHeader;
      MediaDescriptor:Byte;
      Buffer:Pointer;
      BufferSize:Word;
      StartSector:Word;
      VolumePtr:LongInt;
    End;
Var
  IO:TIOCtlO;
  II:TIOCtlI;

Function RED2HSG(Minute, Second, Frame :LongInt) :LongInt;
  Begin
    RED2HSG:=Minute*4500+Second*75+Frame;
  End;

Procedure HSG2RED(HSG :LongInt; var Minute, Second, Frame :LongInt);
  Begin
    Frame:=HSG Mod 75;
    HSG:=HSG Div 75;
    Second:=HSG Mod 60;
    Minute:=HSG Div 60;
  End;

Procedure IOCTLin(IOCTL :Pointer; IOCTLLength :Word);
  Var S,O :Word;
  Begin
    FillChar(II, SizeOf(II), 0);
    With II do
      Begin
        RequestHeader.Len:=SizeOf(TIOCtlI);
        RequestHeader.CommandCode:=3;
        Buffer:=IOCTL;
        BufferSize:=IOCTLLength;
        StartSector:=0;
        VolumePtr:=0;
      End;
    O:=Ofs(II);S:=Seg(II);
    Asm
      xor ch,ch;
      mov cl,GlobalDriveNo;
      mov ax,S;
      mov es,ax;
      mov bx,O;
      mov ax,$1510;
      int $2f;
    End;
    GlobalError:=II.RequestHeader.Status;
  End;

Procedure IOCTLout(IOCTL :Pointer; IOCTLLength :Word);
  Var S,O :Word;
  Begin
    FillChar(IO, SizeOf(IO), 0);
    With IO do
      Begin
        RequestHeader.Len:=SizeOf(TIOCtlI);
        RequestHeader.CommandCode:=12;
        Buffer:=IOCTL;
        BufferSize:=IOCTLLength;
        StartSector:=0;
        VolumePtr:=0;
      End;
    O:=Ofs(IO);
    S:=Seg(IO);
    Asm
      xor ch,ch;
      mov cl,GlobalDriveNo;
      mov ax,S;
      mov es,ax;
      mov bx,O;
      mov ax,$1510;
      int $2f;
    End;
    GlobalError:=IO.RequestHeader.Status;
  End;
Procedure Audio_Disk_Info(var TrackMin,TrackMax :Byte; var LeadOut :LongInt);
Type
  TAudioDiskInfo =
    Record
    Command:Byte;
    Min:Byte;
    Max:Byte;
    LeadOut:LongInt;
    End;
  Var
    IOCTL:TAudioDiskInfo;
  Begin
    IOCTL.Command:=10;
    IOCTLin(@IOCTL,SizeOf(IOCTL));
    TrackMin:=IOCTL.Min;
    TrackMax:=IOCTL.Max;
    LeadOut:=IOCTL.LeadOut; (* RED *)
  End;

Procedure Audio_Track_Info(TrackNr :Byte; var TrackStart :LongInt; var CntlAdr
:Byte);Type
 TAudioTrackInfo = Record
                     Command:Byte;
        TrackNr:Byte;
        TrackStart :LongInt;
        TrackCntl:Byte;
      End;
  Var
    IOCTL :TAudioTrackInfo;
  Begin
    IOCTL.Command:=11;
    IOCTL.TrackNr:=TrackNr;
    IOCTLin(@IOCTL,SizeOf(IOCTL));
    TrackStart:=IOCTL.TrackStart; (* RED *)
    CntlAdr:=IOCTL.TrackCntl;
  End;

Function Media_Changed :Byte;
  Type
    TMediaChanged =
      Record
        Command:Byte;
        MediaChanged:Byte;
      End;
  Var IOCTL :TMediaChanged;
  Begin
    IOCTL.Command:=9;
    IOCTLin(@IOCTL,SizeOf(IOCTL));
    Media_Changed:=IOCTL.MediaChanged;
  End;

Procedure Audio_Status(var AudioStatus :Word; var StartResume,EndPlay
:LongInt);  Type
    TAudioStatus =
      Record
        Command:Byte;
        AudioStatus:Word;
        StartResume:LongInt;
        EndPlay:LongInt;
      End;
  Var
    IOCTL :TAudioStatus;
  Begin
    If AudioCD Then
      Begin
        IOCTL.Command:=15;
        IOCTLin(@IOCTL,SizeOf(IOCTL));
        AudioStatus:=IOCTL.AudioStatus;
        StartResume:=IOCTL.StartResume;
        EndPlay:=IOCTL.EndPlay;
      End;
  End;

Procedure Halt_Audio;
  Var RequestHeader :TRequestHeader; S,O :Word;
  Begin
    If AudioCD Then
      Begin
        RequestHeader.Len:=SizeOf(TRequestHeader);
        RequestHeader.CommandCode:=133;
        O:=Ofs(RequestHeader);
        S:=Seg(RequestHeader);
        Asm
          xor ch,ch;
          mov cl,GlobalDriveNo;
          mov ax,S;
          mov es,ax;
          mov bx,O;
          mov ax,$1510;
          int $2f;
        End;
        GlobalError:=RequestHeader.Status;
      End;
  End;

Procedure Stop_Audio;
  Var AudioStatus :Word; StartResume,EndPlay :LongInt;
  Begin
    If AudioCD Then
      Begin
        Halt_Audio;
        Audio_Status(AudioStatus,StartResume,EndPlay);
        If (AudioStatus AND 1)=1 Then
          Halt_Audio;
      End;
  End;

Procedure Pause_Audio;
  Var AudioStatus :Word; StartResume,EndPlay :LongInt;
  Begin
    If AudioCD Then
      Begin
        Audio_Status(AudioStatus,StartResume,EndPlay);
        If (AudioStatus AND 1)=0 Then
          Halt_Audio;
      End;
  End;

Procedure Resume_Audio;
  Var RequestHeader :TRequestHeader; AudioStatus,S,O :Word;
StartResume,EndPlay :LongInt;  Begin
    If AudioCD Then
      Begin
        Audio_Status(AudioStatus,StartResume,EndPlay);
        If (AudioStatus AND 1)=1 Then
          Begin
            RequestHeader.Len:=SizeOf(TRequestHeader);
            RequestHeader.CommandCode:=136;
            O:=Ofs(RequestHeader);
            S:=Seg(RequestHeader);
            Asm
              xor ch,ch;
              mov cl,GlobalDriveNo;
              mov ax,S;
              mov es,ax;
              mov bx,O;
              mov ax,$1510;
              int $2f;
            End;
          GlobalError:=RequestHeader.Status;
        End;
      End;
  End;

Procedure Play_Audio(StartSector,nFrames :LongInt);
  Type
    TPlayAudio =
      Record
        RequestHeader   :TRequestHeader;
        AdressMode      :Byte;
        StartSector     :LongInt;
        nFrames         :LongInt;
      End;
  Var
    PA :TPlayAudio; S,O :Word;
  Begin
    FillChar(PA, SizeOf(PA), 0);
    PA.RequestHeader.Len:=SizeOf(TPlayAudio);
    PA.RequestHeader.CommandCode:=132;
    PA.AdressMode:=0; (* HSG *)
    PA.StartSector:=StartSector;
    PA.nFrames:=nFrames;
    O:=Ofs(PA);
    S:=Seg(PA);
    Asm
      xor ch,ch;
      mov cl,GlobalDriveNo;
      mov ax,S;
      mov es,ax;
      mov bx,O;
      mov ax,$1510;
      int $2f;
    End;
    GlobalError:=PA.RequestHeader.Status;
  End;

Function Location_of_Head(AdressMode :Byte) :LongInt;
  Type
    TLocHead =
      Record
        Command         :Byte;
        AdressMode      :Byte;
        HeadPosition    :LongInt;
      End;
  Var
    IOCTL :TLocHead;
  Begin
    IOCTL.Command:=1;
    IOCTL.AdressMode:=AdressMode; (* 0=HSG 1=RED *)

    IOCTLin(@IOCTL,SizeOf(IOCTL));

    Location_of_Head:=IOCTL.HeadPosition;
  End;

Function Device_Status :LongInt;
  Type
    TDeviceStatus =
      Record
        Command         :Byte;
        Status          :LongInt;
      End;
  Var IOCTL :TDeviceStatus;
  Begin
    IOCTL.Command:=6;

    IOCTLin(@IOCTL,SizeOf(IOCTL));

    Device_Status:=IOCTL.Status;
  End;

Procedure Audio_Channel_Info(var
ChOut0,Vol0,ChOut1,Vol1,ChOut2,Vol2,ChOut3,Vol3 :Byte);  Type
    TAudioChannelInfo =
      Record
        Command :Byte;
        ChOut0  :Byte;
        Vol0    :Byte;
        ChOut1  :Byte;
        Vol1    :Byte;
        ChOut2  :Byte;
        Vol2    :Byte;
        ChOut3  :Byte;
        Vol3    :Byte;
      End;
  Var IOCTL :TAudioChannelInfo;
  Begin
    IOCTL.Command:=4;
    IOCTLin(@IOCTL,SizeOf(IOCTL));
    ChOut0:=IOCTL.ChOut0;
    ChOut1:=IOCTL.ChOut1;
    ChOut2:=IOCTL.ChOut2;
    ChOut3:=IOCTL.ChOut3;
    Vol0:=IOCTL.Vol0;
    Vol1:=IOCTL.Vol1;
    Vol2:=IOCTL.Vol2;
    Vol3:=IOCTL.Vol3;
  End;

Procedure Audio_Q_Channel_Info(var TrackNo,Min,Sec,Frame,Zero,AMin,ASec,AFrame
:Byte);  Type
    TAudioQChannelInfo =
      Record
        Command :Byte;
        ADR     :Byte;
        TrackNo :Byte;
        Point   :Byte;
        Min     :Byte;
        Sec     :Byte;
        Frame   :Byte;
        Zero    :Byte;
        AMin    :Byte;
        ASec    :Byte;
        AFrame  :Byte;
      End;
  Var IOCTL :TAudioQChannelInfo; HTrack :Byte;
  Begin
    IOCTL.Command:=12;
    IOCTL.ADR:=1;
    IOCTL.Point:=0;
    IOCTLin(@IOCTL,SizeOf(IOCTL));
    HTrack:=(IOCTL.TrackNo AND $0F)+((IOCTL.TrackNo AND $F0) shr 4)*10;
    TrackNo:=HTrack;
    Min:=IOCTL.Min;
    Sec:=IOCTL.Sec;
    Frame:=IOCTL.Frame;
    Zero:=IOCTL.Zero;
    AMin:=IOCTL.AMin;
    ASec:=IOCTL.ASec;
    AFrame:=IOCTL.AFrame;
  End;

Function Disk_Remain :LongInt;
  Var StartSector,TrackLength,DiskEnd :LongInt;
      TrackNo,Min,Sec,Frame,Zero,AMin,ASec,AFrame :Byte;
  Begin
    If NOT TOCreaded Then
      ReadTOC;
    If TOCreaded AND (Media_Changed=1) AND AudioCD Then
      Begin
        Audio_Q_Channel_Info(TrackNo,Min,Sec,Frame,Zero,AMin,ASec,AFrame);
        Disk_Remain:=GlobalLeadOut-RED2HSG(AMin,ASec,AFrame);
        GlobalAktualTrack:=TrackNo;
      End;
  End;

Function Track_Remain :LongInt;
  Var StartSector,TrackLength,DiskEnd :LongInt;
      TrackNo,Min,Sec,Frame,Zero,AMin,ASec,AFrame :Byte;
  Begin
    If NOT TOCreaded Then
      ReadTOC;
    If TOCreaded AND (Media_Changed=1) AND AudioCD Then
      Begin
        Audio_Q_Channel_Info(TrackNo,Min,Sec,Frame,Zero,AMin,ASec,AFrame);
        Calculate_Track(TrackNo,StartSector,TrackLength,DiskEnd);
        Track_Remain:=TrackLength-RED2HSG(Min,Sec,Frame);
        GlobalAktualTrack:=TrackNo;
      End;
  End;

Function Get_UPC :String;
  Type
    TGetUPCAEN =
      Record
        Command:Byte;
        ADR:Byte;
        UPC:Array [0..6] Of Char;
        Zero:Byte;
        AFrame:Byte;
      End;
  Var IOCTL :TGetUPCAEN; HStr :String[7]; T :Byte;
  Begin
    IOCTL.Command:=14;
    IOCTL.ADR:=1;
    IOCTLin(@IOCTL,SizeOf(IOCTL));
    HStr:='';
    For T:=0 To 6 Do
      HStr:=HStr+IOCTL.UPC[T];
    Get_UPC:=HStr;
  End;

Procedure MSCDEX_Version(var HVersion, NVersion :Byte);
  Var HV,NV :Byte;
  Begin
    Asm
      mov ax,$150C;
      int $2F;
      mov HV,bh;
      mov NV,bh;
    End;
    HVersion:=HV;
    NVersion:=NV;
  End;

Function CDROM_Number(var DriveNo :Byte) :Byte;
  Var Ha,Hb:Byte;
  Begin
    Asm
      mov ax,$1500;
      xor bx,bx;
      xor cx,cx;
      int $2F;
      mov Ha,bl;
      mov Hb,cl;
    End;
    CDROM_Number:=Ha;
    DriveNo:=Hb;
  End;

Procedure MSCDEX_Init;
  Type
    TInit =
      Record
        RequestHeader:TRequestHeader;
        AnzahlDrv:Byte;
        EndAdress:LongInt;
        BPB:LongInt;
        BlockDeviceNo:Byte;
      End;
  Var MSCDEXInit :TInit; S,O :Word;
  Begin
    MSCDEXInit.RequestHeader.Len:=SizeOf(MSCDEXInit);
    MSCDEXInit.RequestHeader.CommandCode:=0;
    MSCDEXInit.AnzahlDrv:=0;
    MSCDEXInit.BlockDeviceNo:=0;
    O:=Ofs(MSCDEXInit);
    S:=Seg(MSCDEXInit);
    Asm
      xor ch,ch;
      mov cl,GlobalDriveNo;
      mov ax,S;
      mov es,ax;
      mov bx,O;
      mov ax,$1510;
      int $2f;
    End;
    GlobalError:=MSCDEXInit.RequestHeader.Status;
  End;

Procedure Chk_Audio;
  Begin
    Play_Audio(0,10);
    If (GlobalError AND $8002)=$8002 Then
      AudioCD:=FALSE
    Else
      AudioCD:=TRUE;
    Stop_Audio;
  End;

Procedure ReadTOC;
  Var Change,TrackMin,TrackMax,T,CntlADR :Byte; HTOC,LeadOut :LongInt; HErr
:Word;  Begin
    Change:=Media_Changed;
    While (Change<>1) AND ((GlobalError AND $8000)=0) Do
      Change:=Media_Changed;
    Chk_Audio;
    If ((GlobalError AND $8000)=0) AND AudioCD Then
      Begin
        Audio_Disk_Info(TrackMin,TrackMax,LeadOut);
        If (GlobalError AND $8000)=0 Then
          Begin
            GlobalLeadOut:=RED2HSG(REDUnPack(LeadOut).Minute,
                           REDUnPack(LeadOut).Second,
                           REDUnPack(LeadOut).Frame);
            GlobalTrackMin:=TrackMin;
            GlobalTrackMax:=TrackMax;
            TOCreaded:=TRUE;
            For T:=TrackMin To TrackMax Do
              Begin
                Audio_Track_Info(T,HTOC,CntlADR);
                TOC[T]:=RED2HSG(REDUnPack(HTOC).Minute,
                                REDUnPack(HTOC).Second,
                                REDUnPack(HTOC).Frame);
              End;
          End;
      End;
  End;

Procedure Calculate_Track(TrackNo :Byte; var StartSector,TrackLength,DiskEnd
:LongInt);  Var HStartSector,HTrackLength :LongInt;
  Begin
    If (TOCreaded) AND (Media_Changed=1) AND AudioCD Then
      Begin
        HStartSector:=TOC[TrackNo]-TOC[GlobalTrackMin];
        If TrackNo<GlobalTrackMax Then
          HTrackLength:=(TOC[TrackNo+1]-HStartSector)-TOC[GlobalTrackMin]
        Else
          HTrackLength:=(GlobalLeadOut-HStartSector)-TOC[GlobalTrackMin];
        DiskEnd:=GlobalLeadOut-HStartSector;
      End;
    StartSector:=HStartSector;
    TrackLength:=HTrackLength;
  End;

Procedure Play_Track(TrackNo :Byte);
  Var Status,StartSector,TrackLength,DiskEnd :LongInt;
  Begin
    Status:=Device_Status;
    If (Status AND $0800)=$0000 Then
      Begin
        If (NOT TOCreaded) OR (Media_Changed<>1) Then
          ReadTOC;
        If (TrackNo>=GlobalTrackMin) AND (TrackNo<=GlobalTrackMax) AND AudioCD
Then          Begin
            Status:=Device_Status;
            If (GlobalError AND $0200)=$0200 Then
              Pause_Audio;
            Calculate_Track(TrackNo,StartSector,TrackLength,DiskEnd);
            If (GlobalError AND $8000)=0 Then
              Begin
                Play_Audio(StartSector,TrackLength);
                GlobalAktualTrack:=TrackNo;
              End;
          End;
      End;
  End;

Procedure Play_Track_to_End(TrackNo :Byte);
  Var Status,StartSector,TrackLength,DiskEnd :LongInt;
  Begin
    Status:=Device_Status;
    If (Status AND $0800)=$0000 Then
      Begin
        If (NOT TOCreaded) OR (Media_Changed<>1) Then
          ReadTOC;
        If (TrackNo>=GlobalTrackMin) AND (TrackNo<=GlobalTrackMax) AND AudioCD
Then          Begin
            Status:=Device_Status;
            If (GlobalError AND $0200)=$0200 Then
              Pause_Audio;
            Calculate_Track(TrackNo,StartSector,TrackLength,DiskEnd);
            If (GlobalError AND $8000)=0 Then
              Begin
                Play_Audio(StartSector,DiskEnd);
                GlobalAktualTrack:=TrackNo;
              End;
          End;
      End;
  End;

Procedure Show_Track(TrackNo, Seconds :Byte);
  Var Status,StartSector,TrackLength,DiskEnd :LongInt;
  Begin
    Status:=Device_Status;
    If (Status AND $0800)=$0000 Then
      Begin
        If (NOT TOCreaded) OR (Media_Changed<>1) Then
          Reset_Drive;
        If (TrackNo>=GlobalTrackMin) AND (TrackNo<=GlobalTrackMax) AND AudioCD
Then          Begin
            Status:=Device_Status;
            If (GlobalError AND $0200)=$0200 Then
              Pause_Audio;
            Calculate_Track(TrackNo,StartSector,TrackLength,DiskEnd);
            If (GlobalError AND $8000)=0 Then
               Begin
                 Play_Audio(StartSector,Seconds*75);
                 GlobalAktualTrack:=TrackNo;
               End;
          End;
      End;
  End;

Procedure Next_Track;
  Begin
    If (TOCreaded) AND (Media_Changed=1) AND AudioCD Then
      If GlobalTrackMax>GlobalAktualTrack Then
        Play_Track(GlobalAktualTrack+1)
      Else
        Play_Track(GlobalTrackMin);
  End;

Procedure Last_Track;
  Begin
    If (TOCreaded) AND (Media_Changed=1) AND AudioCD Then
      If GlobalTrackMin<GlobalAktualTrack Then
        Play_Track(GlobalAktualTrack-1)
      Else
        Play_Track(GlobalTrackMax);
  End;

Procedure Next_Track_to_End;
  Begin
    If (TOCreaded) AND (Media_Changed=1) AND AudioCD Then
      If GlobalTrackMax>GlobalAktualTrack Then
        Play_Track_to_End(GlobalAktualTrack+1)
      Else
        Play_Track_to_End(GlobalTrackMin);
  End;

Procedure Last_Track_to_End;
  Begin
    If (TOCreaded) AND (Media_Changed=1) AND AudioCD Then
      If GlobalTrackMin<GlobalAktualTrack Then
        Play_Track_to_End(GlobalAktualTrack-1)
      Else
        Play_Track_to_End(GlobalTrackMax);
  End;

Procedure
Audio_Channel_Control(ChOut0,Vol0,ChOut1,Vol1,ChOut2,Vol2,ChOut3,Vol3 :Byte);
Type    TAudioChannelControl =
      Record
        Command :Byte;
        ChOut0  :Byte;
        Vol0    :Byte;
        ChOut1  :Byte;
        Vol1    :Byte;
        ChOut2  :Byte;
        Vol2    :Byte;
        ChOut3  :Byte;
        Vol3    :Byte;
      End;
  Var IOCTL :TAudioChannelControl;
  Begin
    IOCTL.Command:=3;
    IOCTL.ChOut0:=ChOut0;
    IOCTL.ChOut1:=ChOut1;
    IOCTL.ChOut2:=ChOut2;
    IOCTL.ChOut3:=ChOut3;
    IOCTL.Vol0:=Vol0;
    IOCTL.Vol1:=Vol1;
    IOCTL.Vol2:=Vol2;
    IOCTL.Vol3:=Vol3;
    IOCTLout(@IOCTL,SizeOf(IOCTL));
  End;

Procedure Eject_Disk;
  Type
    TEjectDisk =
      Record
        Command :Byte;
      End;
  Var IOCTL :TEjectDisk;
  Begin
    IOCTL.Command:=0;
    IOCTLout(@IOCTL,SizeOf(IOCTL));
  End;

Procedure Close_Tray;
  Type
    TCloseTray =
      Record
        Command :Byte;
      End;
  Var IOCTL :TCloseTray;
  Begin
    IOCTL.Command:=5;
    IOCTLout(@IOCTL,SizeOf(IOCTL));
  End;

Procedure Lock_Door;
  Type
    TLockUnlock =
      Record
        Command    :Byte;
        LockUnlock :Byte;
      End;
  Var IOCTL :TLockUnlock;
  Begin
    IOCTL.Command:=1;
    IOCTL.LockUnlock:=1; (* Lock *)
    IOCTLout(@IOCTL,SizeOf(IOCTL));
  End;

Procedure UnLock_Door;
  Type
    TLockUnlock =
      Record
        Command    :Byte;
        LockUnlock :Byte;
      End;
  Var IOCTL :TLockUnlock;
  Begin
    IOCTL.Command:=1;
    IOCTL.LockUnlock:=0; (* Unlock *)
    IOCTLout(@IOCTL,SizeOf(IOCTL));
  End;

Procedure Reset_Drive;
  Type
    TResetDrive =
      Record
        Command    :Byte;
      End;
  Var IOCTL :TResetDrive;
  Begin
    IOCTL.Command:=2;
    IOCTLout(@IOCTL,SizeOf(IOCTL));
  End;

Begin
  MSCDEX_Init;
  GlobalDriveCount:=CDROM_Number(GlobalDriveNo);
  If GlobalDriveCount>0 Then
    MSCDEXOk:=TRUE;
End.
