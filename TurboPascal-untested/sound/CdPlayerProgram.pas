(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0089.PAS
  Description: CD Player Program
  Author: PAT O'MALLEY
  Date: 11-22-95  13:23
*)

{ I noticed that more than a few people wanted to know how to program a
  CD player. I did too, once. So here is the fruit of my labor.
  The programming isn't all that good. I wrote it to be SMALL.

  There are quite a number of unused variables, procedures, etc. Just
  try them!

  I'd like to thank Kristian Leonhard for two of his procedures. Saved a
  big amount of space and bad computing.

  No messages about how I _should_ have coded something. If you can make it
  so much better DO IT.

  I recommend a file called MSCDFUNC.DOC which contains all of the info
  used in this program. EXCEPT for the stuff that Kristian Leonhard wrote.

  Programmed by: Patrick O'Malley, 1995 
}

{$X+}        {I know, bad directive}
Program CDPlayer;
Uses Crt;
Type  Std = record             {read and write}
                 length : byte;
                 subcode : byte;
                 cmdcode : byte;
                 status : word;
                 res : array[1..8] of byte;
                 {---Nothing special between READ and WRITE----}
                 MedDesc : Byte;
                 XFerAddr : Pointer;
                 XFerbytes : Word;
                 SSNum : Word;
                 ReqPtr : Longint;
               end;

      Playreq = record            {play}
                  Length : Byte;
                  SubCode : Byte;        {0?}
                  CmdCode : Byte;        {132}
                  Status : Word;
                  Res : Array[1..8] of byte;
                  AddrMode : Byte;
                  StrtSec : Longint;
                  numSect : Longint;
                end;

      Qinfo = record         {QI}           {uses IOCTLI header}
                CtlCode : Byte; {12}
                CTl_ADR : Byte;
                TNO : Byte;
                POINT : Byte;
                MIN : Byte;
                SEC : Byte;
                Frame : Byte;
                Zero : Byte;
                AMIN : Byte;
                ASEc : Byte;
                AFRAME : Byte;
              end;

      DiskInfo = record          {DI}        {uses IOCTLI header}
                   CtlCode : Byte;  {10}
                   LowTrack : Byte;
                   HiTrack : Byte;
                   StrtSect : Longint;
                 end;

      TrackInfo = record        {TI}         {uses IOCTLI header}
                    CtlCode : Byte;
                    TrackNum : Byte;
                    TStart : Longint;
                    TCI : Byte;
                  end;

      Eject = record           {EJ}          {uses IOCTLO header}
                CtlCode : Byte; {0}
              end;

      RstDrive = record
                   CtlCode : Byte;
                 end;
      MedType = record
                  CtlCode : Byte;
                  MediaByte : Byte;
                end;
      OneTime = record
                  Minute : Byte;
                  Second : Byte;
                  Frame  : Byte;
                end;
      RedBookFormat = Record
                        Frame  : Byte;
                        Second : Byte;
                        Minute : Byte;
                        Unused : Byte;
                      End;
      AudioTrackType = Array[0..1,0..255] Of RedBookFormat;

Var      {I think some of these vars are unused ;) }
    StdHdr : Std;
    Play : Playreq;
    QI : Qinfo;
    DI : DiskInfo;
    TI : TrackInfo;
    EJ : Eject;
    Rst : RstDrive;
    Media : MedType;
    {---Universal variables---}
    TStart : Array[1..64] of OneTime;
    TLength : Array[1..64] of OneTime;
    StdOfs : Word;
    CDNum : Word;
    NumDrives : Word;       {number of CD-ROM devices found}
    TrNum : Byte;
    DrvList : Array[1..26] of byte; {list of CD-ROM devices}
    Tracks : AudioTrackType;

Function LongMul(X,Y : Integer) : Longint; Assembler;
Asm
  mov ax,X
  imul Y
End;

Procedure SendDDR;
{Sends a device driver request. In this case to the CD-ROM driver}
Begin
  asm
    push ds
    mov ax,ds
    mov es,ax
    mov ax,1510h
    mov bx,StdOfs
    mov cx,CDNum
    Int 2fh
    pop ds
  end;
end; {sendDDR}

Function IsInstalled : Boolean;
Begin
  asm
    mov ax,1500h
    int 2fh
    mov numdrives,bx
  end;
  If Numdrives = 0 then IsInstalled := False
    else IsInstalled := True;
End; {IsInstalled func}

Function MediaChanged : Byte;
Begin
  FillChar(StdHdr,SizeOf(StdHdr),0);
  StdHdr.Length := SizeOf(StdHdr);
  StdHdr.CmdCode := 3;
  StdHdr.XFerAddr := Addr(Media);
  StdHdr.XFerBytes := 2;
  Media.CtlCode := 9;
  SendDDR;
  MediaChanged := Media.MediaByte;
end;

Procedure GetDrvLetrs;
{Gets the list of CD-ROM devices in the system. It returns a number for
each drive. For example, if drive 'D' is a CD-ROM and the only one in the
system, DrvList[1] would equal 3. Remember: A=0,B=1,C=2,D=3. DrvList[x]
can be used to play any cd device. DrvList[2] would be the second device,etc.}
Begin
  asm
    mov ax,ds
    mov es,ax
    mov ax,150dh
    mov bx,offset drvlist
    int 2fh
  end;
end; {getdrvletrs proc}

Procedure GetDriverName(CDROMNumber:Byte;Var Name:String);
 { Also from Kristian Leonhard. Interesting procedure. }
 { CDROMNumber = 1 .. 26 }
 { 1 means first cdrom number }
 Var
  Data : Array[0..129] Of Byte;
  Offs : Word;
  Segm : Word;
  DSeg : Word;
  DOfs : Word;
  Z    : Word;
 Begin
  Offs:=Ofs(Data);
  Segm:=Seg(Data);
  Asm
   mov  ax,segm
   mov  es,ax
   mov  bx,offs
   mov  ax,1501h
   int  2fh
  End;
  DSeg:=MemW[segm:(Offs+3)];
  DOfs:=MemW[segm:(Offs+1)]+((CDROMNumber-1)*5);
  Z:=0;
  While (Mem[DSeg:DOfs+Z]<>$20) And (Z<7) Do
  Begin
   Inc(Z);
   Mem[Seg(Name):Ofs(Name)]:=Z;
   Mem[Seg(Name):Ofs(Name)+Z]:=Mem[DSeg:(DOfs+9+Z)];
  End;
  Inc(Z);
  Mem[Seg(Name):Ofs(Name)]:=Z;
  Mem[Seg(Name):Ofs(Name)+Z]:=0;
End; {getdrivername proc}

Procedure GetAudioTrackInfo(Handle:Word;Var AudioTrack:AudioTrackType);
{Thanks to Kristian Leonhard for this procedure. Sure beats my old
 one!                                                             }
Label
 Error,Exit,Error2,Exit2,Error3,Exit3;
Var
 Buffer : Array[0..1024] Of Byte;
 BufSeg : Word;
 BufOfs : Word;
 Err    : Boolean;
 Z      : Byte;
 Max,Min: Byte;

Procedure WriteTimeFromSec(Sec:Word);
Begin
 Writeln((Sec div 60),':',Sec-((Sec div 60)*60));
End;

Begin
 BufSeg:=Seg(Buffer);
 BufOfs:=Ofs(Buffer);
 { Get StartTrack & EndTrack }
 Asm
          push ds
          mov  ax,BufSeg
          mov  ds,ax
          mov  dx,BufOfs
          mov  bx,dx
          mov  al,0ah
          mov  ds:[bx],al
          mov  bx,Handle
          mov  cx,7
          mov  ax,4402h
          int  21h
          jc   Error
          mov  al,0h
          mov  Err,al
          jmp  Exit
 Error  : mov  al,1h
          mov  Err,al
          jmp  Exit
 Exit   : pop  ds
 End;
 If Not Err Then
 Begin
  Max:=Buffer[2];
  Min:=Buffer[1];
  AudioTrack[1][Max].Frame:=Buffer[3];
  AudioTrack[1][Max].Second:=Buffer[4];
  AudioTrack[1][Max].Minute:=Buffer[5];
  { Get Rest of audio info }
  For Z:=Min To Max Do
  Begin
   Asm
          push ds
          mov  ax,BufSeg
          mov  ds,ax
          mov  dx,BufOfs
          mov  bx,dx
          mov  al,0bh
          mov  ds:[bx],al
          mov  al,z
          mov  ds:[bx+1],al
          mov  bx,Handle
          mov  cx,7
          mov  ax,4402h
          int  21h
          jc   Error
          mov  al,0h
          mov  Err,al
          jmp  Exit2
 Error2 : mov  al,1h
          mov  Err,al
          jmp  Exit2
 Exit2  : pop  ds
  End;
  AudioTrack[0][Z].Frame:=Buffer[2];
  AudioTrack[0][Z].Second:=Buffer[3];
  AudioTrack[0][Z].Minute:=Buffer[4];
 End;
For Z:=Min+1 To Max Do
  Begin
   Asm
          push ds
          mov  ax,BufSeg
          mov  ds,ax
          mov  dx,BufOfs
          mov  bx,dx
          mov  al,0bh
          mov  ds:[bx],al
          mov  al,z
          mov  ds:[bx+1],al
          mov  bx,Handle
          mov  cx,7
          mov  ax,4402h
          int  21h
          jc   Error
          mov  al,0h
          mov  Err,al
          jmp  Exit3
 Error3 : mov  al,1h
          mov  Err,al
          jmp  Exit3
 Exit3  : pop  ds
  End;
  AudioTrack[1][Z-1].Frame:=Buffer[2];
  AudioTrack[1][Z-1].Second:=Buffer[3];
  AudioTrack[1][Z-1].Minute:=Buffer[4];
  End;
  Writeln('AudioCD Info : ');
  Writeln('Start       End       Total');
  For Z:=Min To Max Do
  Begin
    Write(AudioTrack[0][Z].Minute,':',AudioTrack[0][Z].Second,'         ',
          AudioTrack[1][Z].Minute,':',AudioTrack[1][Z].Second,'      ');
    WriteTimeFromSec(((AudioTrack[1][Z].Minute-AudioTrack[0][Z].Minute)
                  *60)+(AudioTrack[1][Z].Second-AudioTrack[0][Z].Second));
  End;
 End
 Else
 Begin
  Writeln('Error reading audio info');
 End;
 Writeln('Press a key');
 Readkey;
End; {getaudiotrackinfo proc}

Procedure SubtractTime(Min1,Sec1,F1,Min2,Sec2,F2 : Byte;Var RMin,RSec,RF :
Byte);{Subtracts Min1,Sec1 from Min2,Sec2  (Min2-Min1,etc)}
{Places answers in RMin and RSec}
Var D : Real;
    S1,S2,R : Word;
Begin
  {Check to see if F2 > F1. If not, subtract one from S2, add 75 to F2,
   subtract and place result. then convert rest to packed}
  If F2-F1 < 0 then begin
    S2 := S2 - 1;
    F2 := F2 + 75;
    RF := F2-F1;
  end else RF := F2-F1;      {recent addition -- check}
  {convert to packed}
  S1 := Min1*60+Sec1;
  S2 := Min2*60+Sec2;
  {do subtraction}
  R := S2-S1;
  {Is R > 60, if so then divide r by 60 to find RMin}
  {mult. frac(r) by 60 to fin rsec}
  If R >= 60 then begin
    D := R / 60;
    RMin := Trunc(D);
    D := Frac(D) * 60;
    RSec := Trunc(D);
  end
  else begin
    RMin := 0;
    RSec := R;
  End;
End; {SubtractTime}

Procedure EjectCd;
Begin
  StdHdr.Length := SizeOf(StdHdr);
  StdHdr.Subcode := 0;
  StdHdr.CmdCode := 12;
  StdHdr.MedDesc := 0;
  StdHdr.XFerAddr := ADDR(EJ);
  StdHdr.XFerBytes := 1;
  StdHdr.SSNum := 0;
  StdHdr.ReqPtr := 0;
  EJ.CtlCode := 0;
  SendDDR;
End; {ejectcd proc}

Procedure ResetCD;
Begin
  StdHdr.Length := SizeOf(StdHdr);
  StdHdr.Subcode := 0;
  StdHdr.CmdCode := 12;
  StdHdr.MedDesc := 0;
  StdHdr.XFerAddr := ADDR(RST);
  StdHdr.XFerBytes := 1;
  StdHdr.SSNum := 0;
  StdHdr.ReqPtr := 0;
  Rst.CtlCode := 2;
  SendDDR;
End; {resetcd proc}

Procedure GetDiskInfo;
Begin
  StdHdr.Length := SizeOf(StdHdr);
  StdHdr.SubCode := 0;
  StdHdr.CmdCode := 3;
  StdHdr.MedDesc := 0;
  StdHdr.XFerAddr := Addr(DI);
  StdHdr.XFerBytes := 7;
  StdHdr.SSNum := 0;
  Stdhdr.ReqPtr := 0;
  DI.CtlCode := 10;
  SendDDR;
End; {getdiskinfo proc}

Procedure GetTrackInfo(Track : Byte;Var Start : Longint);
Begin
  StdHdr.Length := SizeOf(StdHdr);
  StdHdr.SubCode := 0;
  StdHdr.CmdCode := 3;
  Stdhdr.MedDesc := 0;
  Stdhdr.XFerAddr := Addr(TI);
  StdHdr.XFerBytes := 7;
  StdHdr.SSNum := 0;
  StdHdr.ReqPtr := 0;
  TI.CtlCode := 11;
  TI.TrackNum := Track;
  SendDDR;
  Start := TI.TStart;
End; {GetTrackInfo Proc}

Procedure GetTrackLengths;
Var Loop : Byte;
Begin
  {place track starts in TStart}
  For Loop := DI.LowTrack to DI.HiTrack do Begin
    TStart[Loop].Minute := Tracks[0,Loop].Minute;
    TStart[Loop].Second := Tracks[0,Loop].Second;
    TStart[Loop].Frame := Tracks[0,Loop].Frame;
  end;
  {find lengths of tracks}
  For Loop := DI.LowTrack to DI.HiTrack do

SubtractTime(Tracks[0,Loop].Minute,Tracks[0,Loop].Second,Tracks[0,Loop].Frame,
Tracks[1,Loop].Minute,Tracks[1,Loop].Second,Tracks[1,Loop].Frame,

TLength[Loop].Minute,TLength[Loop].Second,TLength[Loop].Frame);End;
{gettracklengths proc}
Procedure PlayCD(Start,Length : Longint);
Begin
  Play.Length := 13{SizeOf(Play)};
  Play.SubCode := 0;
  Play.CMdCode := 132;
  Play.AddrMode := 0;
  Play.StrtSec := Start;
  Play.NumSect := Length;
  asm
    push ds
    mov ax,ds
    mov es,ax
    mov ax,1510h
    mov bx,offset play
    mov cx,CDNum
    Int 2fh
    pop ds
  end;
End;   {playcd proc}

Procedure PlayTrack(TrackNum : Byte);
Var LMin,LSec,LF,
    SMin,SSec,SF : Byte;
    S,L : Longint;
Begin
  LMin := TLength[TrackNum].Minute;
  LSec := TLength[TrackNum].Second;
  LF := TLength[TrackNum].Frame;
  SMin := TStart[TrackNum].Minute;
  SSec := TStart[Tracknum].Second;
  SF := TStart[TrackNum].Frame;
  L := LongMul(LMin,75*60)+LongMul(LSec,75)+LF-150;
  S := LongMul(SMin,60*75)+LongMul(SSec,75)+SF-150;
  PlayCD(S,L);
End; {playtrack proc}

Procedure PlayTracks(First,Second : Byte);
{Plays everything from the first to the second tracks. Not used.}
Var Strt : OneTime;
    X : Byte;
    LngthTime : Longint;
    L,S : Longint;
Begin
  LngthTime := 0;
  Strt := TStart[First];
  For X := First to Second do
    LngthTime := LngthTime +
LongMul(TLength[X].Minute,75*60)+LongMul(TLength[X].Second,75)+
TLength[X].Frame-150;  L := LngthTime;
  S := LongMul(Strt.Minute,60*75)+LongMul(Strt.Second,75)+Strt.Frame-150;
  PlayCD(S,L);
End; {playtracks proc}

Procedure GetAudioInfo;
Var CDName : String;
    CDHandle : Word;
    CDFile : File;
Begin
  GetDriverName(1,CDName);
  Assign(CDFile,CDName);
  Reset(CDFile,1);
  CDHandle := MemW[SSeg:Ofs(CDFile)];
  GetAudioTrackInfo(CDHandle,Tracks);
  Close(CDFile);
End; {getaudioinfo}

Begin
  {--Set some universal constants--}
  StdOfs := Ofs(StdHdr);
  If IsInstalled then begin
    GetDrvLetrs;
    CDNum := DrvList[1];
  End
  else Begin
    Writeln('MSCDEX and/or CD-ROM not detected! Aborting');
    Halt(1);
  End;
  {--reset drive then play a track--}
  ResetCD;  {My CD won't play music CDs without a reset first. Driver prob.}
  MediaChanged;  {have to run it once to get a correct answer the next time}
  GetAudioInfo;  {  not that I use it here again ;)}
  GetDiskInfo;
  GetTrackLengths;
  {$I-}
  Repeat
    Writeln('Enter track number to play (',DI.LowTrack,'-',DI.HiTrack,'):');
    Readln(TrNum);
  Until (IOResult = 0) AND (TrNum <= DI.HiTrack) AND (TrNum >= DI.LowTrack);
  {$I+}
  PlayTrack(TrNum);
End.

A word about CDNum: CDNum is the number of the drive where A=0,B=1,C=2,D=3.
On my system the CD is drive D so CDNum would be 3. HOWEVER: In the
GetDriverName procedure, CDROMNumber is NOT the same. It is the number of
the CDROM drive you want to play. That is, if you have more than 1 CDROM.
So if you have 2 CDROM drives, D&E, then CDROMNumber = 1 would activate
drive D and CDROMNumber=2 would activate E. Simple. Keep it on 1 and
things _should_ go OK.

Pat O'Malley AKA Silicon Slim

