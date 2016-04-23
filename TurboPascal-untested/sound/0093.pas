UNIT CDAUDIO;
{ by Eric Miller, Jan. 15, 1996 }
{ public domain }
INTERFACE

Uses Objects;

CONST
        cdPlaying = 1;     { drive is playing audio }
        cdDisc = 2;        { disc is in drive }
        cdDoor = 4;        { drive door is closed }
TYPE
        TRedBook = RECORD
                Frame, Second, Minute, Unused: Byte;
        END;
        TTrack = RECORD
                Start, Finish: TRedBook;
        END;
        TDeviceHeader = RECORD
                NextDriver: Pointer;
                Attribute, StratEntry, IntEntry: Word;
                Name: array[0..7] of Char;
                Res: Word;
                Letter, Units: Byte;
        END;
        TDevice = RECORD
                Subunit: Byte;
                Header: Pointer;
        END;
        TRequestHeader = RECORD
                Length,        Subunit, Command: Byte;
                Status: Word;
                Res: array[0..7] of Byte;
        END;
        TPlayRequest = RECORD
                Header: TRequestHeader;
                Addressing: Byte;
                Start, Length: LongInt;
        END;
        TIOCTLRequest = RECORD
                Header: TRequestHeader;
                Media: Byte;
                Address: Pointer;
                Length,        Start: Word;
                Res: Pointer;
        END;
        TQChannel = RECORD
                Command, CTRL_ADR, Track,        Point: Byte;
                Min, Sec, Frame, Zero, AMin, ASec, AFrame: Byte;
        END;
        TDeviceStatus = RECORD
                Command: Byte;
                Status: LongInt;
        END;
        TCommand = RECORD
                Command: Byte;
        END;
        TDiskInfo = RECORD
                Command: Byte;
                LowTrack, HighTrack: Byte;
                LeadOut: TRedBook;
        END;
        TTrackInfo = RECORD
                Command, Track: Byte;
                Start: TRedBook;
                Control: Byte;
        END;
TYPE
        TCD = OBJECT
                Drive,                 { CD-ROM drive }
                Letter: Byte;          { drive letter }
                Header: ^TDeviceHeader;
                Subunit: Byte;
                Name: String[8]; { name of driver }
                Handle: Word;
                LowTrack, HighTrack, CurTrack: Byte;
                cMin, cSec, cFrame,                                                { track time }
                tMin, tSec, tFrame,                                                { track length }
                dMin, dSec, dFrame: Byte;           { disc time }
                Tracks: array[1..64] of TTrack;        { track info }
                Status: Word;                                                                        { drive status }
                PROCEDURE Eject;
                PROCEDURE Retract;
                FUNCTION State(AState: Word): Boolean; { test Status field }
                PROCEDURE GetStatus;                                        { set Status field }
                PROCEDURE Error(Code: Word);
                PROCEDURE Stop;
                FUNCTION RedToHSG(Redbook: TRedbook): LongInt;
                PROCEDURE HSGToRed(HSG: Longint; VAR Redbook: TRedbook);
                FUNCTION Time(M, S, F: Byte): String;        { Redbook > 'mm:ss:ff' }
                FUNCTION Drives: Byte;                                        { # of CD-ROM drives }
                FUNCTION Version: Word;                                        { MSCDEX version }
                FUNCTION MediaChanged: Byte;                { disc ready/different/etc }
                PROCEDURE PlayTrack(Track: Byte);
                PROCEDURE GetPosition;                                        { get play position }
                PROCEDURE GetTracks;                                                { get track info }
                PROCEDURE GetHandle;
                PROCEDURE GetSubUnit;
                PROCEDURE GetDriveLetter;
                PROCEDURE GetDriverName;
                FUNCTION Init: Boolean;
                PROCEDURE Done;
        END;

IMPLEMENTATION

PROCEDURE TCD.Done;
BEGIN
        Drive := 0;        Header := NIL;
        Name := '';        LowTrack := 0;
        HighTrack := 0;        Status := 0;
END;

FUNCTION TCD.State(AState: Word): Boolean;
BEGIN
        State := Status AND AState = AState;
END;

PROCEDURE TCD.Error(Code: Word);
BEGIN
        IF Status AND $8000 > 0 THEN
                BEGIN
                        Write('ERROR - (', Status AND $F, ') ');
                        CASE (Status AND $F) of
                                0: Writeln('Write-protect violation');
                                1: Writeln('Unknown unit');
                                2: Writeln('Drive not ready');
                                3: Writeln('Unknown command');
                                4: Writeln('CRC error');
                                5: Writeln('Bad drive request structure length');
                                6: Writeln('Seek error');
                                7: Writeln('Unknown media');
                                8: Writeln('Sector not found');
                                9: Writeln('Printer out of paper');
                         10: Writeln('Write fault');
                         11: Writeln('Read fault');
                         12: Writeln('General failure');
                         13..14: Writeln('Reserved error');
                         15: Writeln('Invalid disk change');
                        END;
                END;
END;

FUNCTION TCD.Init: Boolean;
BEGIN
        IF Drives > 0 THEN
                BEGIN
                        Init := True;
                        Drive := 1;
                        GetDriveLetter;
                        GetSubunit;
                        GetDriverName;
                        GetHandle;
                        MediaChanged;
                        GetPosition;
                        GetStatus;
                END
        ELSE
                Init := False;
END;

PROCEDURE TCD.Eject;
VAR
        E: TCommand;
        IOCTLO: TIOCTLRequest;
        Offs, Segm: Word;
        ALetter: Byte;
BEGIN
        ALetter := Letter;
        Segm := Seg(IOCTLO);
        Offs := Ofs(IOCTLO);
        WITH IOCTLO DO
                BEGIN
                        Media := 0;
                        Address := @E;
                        Length := SizeOf(E);
                        Start := 0;
                        Res := NIL;
                        WITH Header DO
                                BEGIN
                                        Length := 26;        Command := 12;
                                END;
                        Header.Subunit := Subunit;
                END;
        E.Command := $0;
        ASM
                mov ax,Segm
                mov es,ax
                mov bx,Offs
                mov cl,ALetter
                mov ax,1510h
                int 2fh
        END;
END;

PROCEDURE TCD.Retract;
VAR
        R: TCommand;
        IOCTLO: TIOCTLRequest;
        Offs, Segm: Word;
        ALetter: Byte;
BEGIN
        ALetter := Letter;
        Segm := Seg(IOCTLO);
        Offs := Ofs(IOCTLO);
        WITH IOCTLO DO
                BEGIN
                        Media := 0;
                        Address := @R;
                        Length := SizeOf(R);
                        Start := 0;
                        Res := NIL;
                        WITH Header DO
                                BEGIN
                                        Length := 26;        Command := 12;
                                END;
                        Header.Subunit := Subunit;
                END;
        R.Command := $5;
        ASM
                mov ax,Segm
                mov es,ax
                mov bx,Offs
                mov cl,ALetter
                mov ax,1510h
                int 2fh
        END;
END;


PROCEDURE TCD.Stop;
VAR
 Request: TRequestHeader;
 Segm, Offs: Word;
 ALetter: Byte;
BEGIN
        ALetter := Letter;
        Segm := Seg(Request);
        Offs := Ofs(Request);
        WITH Request DO
                BEGIN
                        Length := 5;
                        Command := $85;
                END;
        Request.Subunit := Subunit;
        ASM
                push ds
                mov  ax,Segm
                mov  es,ax
                mov  bx,Offs
                xor  cx,cx
                mov  cl,ALetter
                mov  ax,1510h
                int  2fh
                pop  ds
        END
END;

PROCEDURE TCD.GetStatus;
VAR
        ALetter: Byte;
        DeviceStatus: TDeviceStatus;
        IOCTLI: TIOCTLRequest;
        Segm, Offs: Word;
BEGIN
        ALetter := Letter;
        Segm := Seg(IOCTLI);
        Offs := Ofs(IOCTLI);
        WITH IOCTLI DO
                BEGIN
                        Media := 0;
                        Address := @DeviceStatus;
                        Length := SizeOf(DeviceStatus);
                        Start := 0;
                        Res := NIL;
                        WITH Header DO
                                BEGIN
                                        Length := 26;        Command := 3;
                                END;
                        Header.Subunit := Subunit;
                END;
        DeviceStatus.Command := $6;

  ASM
                mov ax,Segm
                mov es,ax
                mov bx,Offs
                mov cl,ALetter
                mov ax,1510h
                int 2fh
        END;
        Status := 0;
        IF IOCTLI.Header.Status AND $200 > 0 THEN
                Inc(Status, cdPlaying);
        IF NOT (DeviceStatus.Status AND $800 > 0) THEN
                Inc(Status, cdDisc);
        IF DeviceStatus.Status AND 1 = 0 THEN
                Inc(Status, cdDoor);
END;

FUNCTION TCD.Time(M, S, F: Byte): String;
VAR
        St: String;
        T: LongInt;
BEGIN
        T := (longint(M MOD 100) * 10000) + ((S MOD 60) * 100) + (F MOD 75);
        Str(T:6, St);
        IF T > 99 THEN
                BEGIN
                        Insert(':', St, 5);
                        IF T > 9999 THEN
                                Insert(':', St, 3)
                        ELSE
                                St := Concat(' ', St);
                END
        ELSE
                St := Concat('  ', St);
        Time := St;
END;

PROCEDURE TCD.GetPosition;
VAR
        Segm, Offs: Word;
        QChannel: TQChannel;
        IOCTLI: TIOCTLRequest;
        T: Longint;
        S: String;
        ALetter: Byte;
BEGIN
        ALetter := Letter;
        Segm := Seg(IOCTLI);
        Offs := Ofs(IOCTLI);
        WITH IOCTLI DO
                BEGIN
                        Media := 0;
                        Address := @QChannel;
                        Length := SizeOf(QChannel);
                        Start := 0;
                        Res := NIL;
                        WITH Header DO
                                BEGIN
                                        Length := 26;        Command := 3;
                                END;
                        Header.Subunit := Subunit;
                END;
        QChannel.Command := 12;
        ASM
                mov ax,Segm
                mov es,ax
                mov bx,Offs
                xor cx,cx
                mov cl,ALetter
                mov ax,1510h
                int 2fh
        END;
        WITH QChannel DO
                BEGIN
                        cMin := Min; cSec := Sec;        cFrame := Frame;
                        dMin := AMin;        dSec := ASec;        dFrame := AFrame;
                END;
END;

FUNCTION TCD.RedToHSG(Redbook: TRedBook): LongInt;
BEGIN
        WITH Redbook DO
                RedToHSG := (longint(Minute) * 4500) + (Second * 75) + Frame - 150;
END;

PROCEDURE TCD.HSGToRed(HSG: Longint; VAR Redbook: TRedbook);
BEGIN
        Inc(HSG, 150);
        WITH RedBook DO
                BEGIN
                        Minute := HSG DIV 4500;
                        Second := HSG DIV 75 MOD 60;
                        Frame := HSG MOD 75;
                END;
END;

PROCEDURE TCD.PlayTrack(Track: Byte);
VAR
 Segm, Offs: Word;
 ADrive: Byte;
 PlayRequest: TPlayRequest;
 Red_Length: TRedbook;
        StartHSG, EndHSG, HSG_Length: Longint;
BEGIN
        CurTrack := Track;
        StartHSG := RedToHSG(Tracks[Track].Start);
        EndHSG := RedToHSG(Tracks[Track].Finish);
        HSG_Length := EndHSG - StartHSG;
        HSGToRed(HSG_Length, Red_Length);
        WITH Red_Length DO
                BEGIN
                        tMin := Minute; tSec := Second; tFrame := Frame;
                END;
        Segm := Seg(PlayRequest);
        Offs := Ofs(PlayRequest);
        ADrive := Letter;
        WITH PlayRequest DO
                BEGIN
                        Header.Length := SizeOf(PlayRequest);
                        Header.Subunit := SubUnit;
                        Header.Command := $84;
                        Addressing := 0;
                        Start := RedToHSG(Tracks[Track].Start);
                        Length := RedToHSG(Tracks[Track].Finish) - RedToHSG(Tracks[Track].Start);
                END;
        ASM
                push ds
                mov  ax,Segm
                mov  es,ax
                mov  bx,Offs
                xor  cx,cx
                mov  cl,ADrive
                mov  ax,1510h
                int  2fh
                pop  ds
        END;
END;

PROCEDURE TCD.GetTracks;
VAR
        DiskInfo: TDiskInfo;
        TrackInfo: TTrackInfo;
        Segm, Offs: Word;
        Z: Byte;
        AHandle: Word;
BEGIN
        AHandle := Handle;
        Segm := Seg(DiskInfo);
        Offs := Ofs(DiskInfo);
        DiskInfo.Command := $A;
        ASM
                push ds
                mov  ax,Segm
                mov  ds,ax
                mov  dx,Offs
                mov  bx,AHandle
                mov  cx,7
                mov  ax,4402h
                int  21h
                pop  ds
        END;

        HighTrack := DiskInfo.HighTrack;
        LowTrack := DiskInfo.LowTrack;

        Segm := Seg(TrackInfo);
        Offs := Ofs(TrackInfo);
        TrackInfo.Command := $B;

        FOR Z := LowTrack TO HighTrack DO
                BEGIN
                        TrackInfo.Track := Z;
                        ASM
                                push ds
                                mov  ax,Segm
                                mov  ds,ax
                                mov  dx,Offs
                                mov  bx,AHandle
                                mov  cx,7
                                mov  ax,4402h
                                int  21h
                                pop  ds
                        END;
                        Tracks[Z].Start := TrackInfo.Start;
                END;

        FOR Z := LowTrack + 1 TO HighTrack DO
                BEGIN
                        TrackInfo.Track := Z;
                        Tracks[Z - 1].Finish := Tracks[Z].Start;
                END;
        Tracks[HighTrack].Finish := DiskInfo.LeadOut;
END;

FUNCTION TCD.MediaChanged: Byte;
VAR
        AHandle, Segm, Offs: Word;
        Buffer: array[0..127] of Byte;
BEGIN
        Segm := Seg(Buffer);
        Offs := Ofs(Buffer);
        AHandle := Handle;
        ASM
                push ds
                mov  ax,Segm
                mov  ds,ax
                mov  dx,Offs
                mov  bx,dx
                mov  al,9h
                mov  ds:[bx],al
                mov  bx,AHandle
                mov  cx,2
                mov  ax,4402h
                int  21h
                pop  ds
        END;
        MediaChanged := Buffer[1];
END;

PROCEDURE TCD.GetHandle;
VAR
        Result, Segm, Offs: Word;
BEGIN
        Segm := Seg(Name);
        Offs := Succ(Ofs(Name));
        ASM
                push ds
                mov  ax,Segm
                mov  ds,ax
                mov  dx,Offs
                mov  ah,3dh
                mov  al,2h
                int  21h
                jc   @1
                mov         Result,ax
                jmp @2
                @1:
                mov Result,0h
                @2:
                pop ds
        END;
        Handle := Result;
END;

PROCEDURE TCD.GetDriverName;
BEGIN
        Name := '';
        Move(Header^.Name, Name[1], 8);
        REPEAT
                Inc(Name[0]);
        UNTIL (Length(Name) = 8) OR (Name[Length(Name)] = #32);
END;

PROCEDURE TCD.GetDriveLetter;
VAR
        DriveLetterList: array[1..26] of Byte;
        Segm, Offs: Word;
BEGIN
        Segm := Seg(DriveLetterList);
        Offs := Ofs(DriveLetterList);

  ASM
                mov ax,Segm
                mov es,ax
                mov bx,Offs
                mov ax,150Dh
                int 2fh
        END;
        Letter := DriveLetterList[Drive];
END;


FUNCTION TCD.Version: Word; assembler;
ASM
        mov  ax,150ch
        int  2fh
        mov  ax,bx
END;


PROCEDURE TCD.GetSubunit;
VAR
        DeviceList: array[1..26] of TDevice;
        Segm, Offs: Word;
BEGIN
        Segm := Seg(DeviceList);
        Offs := Ofs(DeviceList);
        ASM
                mov ax,Segm
                mov es,ax
                mov bx,Offs
                mov ax,1501h
                int 2fh
        END;
        Subunit := DeviceList[Drive].Subunit;
        Header := DeviceList[Drive].Header;
END;

FUNCTION TCD.Drives: Byte; assembler;
ASM
        mov ax,1500h
        mov bx,0
        int 2fh
        mov al,bl
END;

END.

{ ----------------------   DEMO PROGRAM ------------------ }

PROGRAM CDPLAY;
{ Test program for CDAUDIO unit.        
        Plays audio tracks sequentially until keypressed.
}
Uses CRT, CDAUDIO;

VAR
        CD: TCD;
        Track: Byte;
        Ticker: Longint ABSOLUTE $40:$6c;
        Tick: Longint;
BEGIN
        IF CD.Init THEN
                WITH CD DO
                        BEGIN
                                GetTracks;
                                Writeln(CD.HighTrack, ' tracks');
                                Track := LowTrack;
                                WHILE (Track <= HighTrack) AND NOT Keypressed DO
                                        BEGIN
                                                PlayTrack(Track);
                                                Write('TRACK ', Track, ' LENGTH ', Time(tMin, tSec, tFrame), ' TIME ');
                                                REPEAT
                                                        Tick := Ticker;
                                                        REPEAT UNTIL Ticker <> Tick;
                                                        GetPosition;
                                                        Write(Time(cMin, cSec, cFrame));
                                                        GetStatus;
                                                        Write(#8#8#8#8#8#8#8#8);
                                                UNTIL Keypressed OR NOT State(cdPlaying);
                                                Writeln;
                                                Inc(Track);
                                        END;
                        IF State(cdPlaying) THEN
                                Stop;
                        Done;
                END
        ELSE
                Writeln('No CD-ROM drive?!');
END.
