{
> Are there anybody out there who has some routins to play CD Audio in a CD
> ROM drive. Just the usual commands like play, stop, resume, eject and so
> on. I would appreciate any help!
}

Unit CDROM;

{  Unit talking to a CD-Rom-Drive
   Low-level CD access,
   only the first drive is supported...!
   Copyright 1992  Norbert Igl  }

Interface

Type
   CD_Record = Record
                    Status : Word;    { Status des Drives/letzte Funktion }
                    DrvChar: Char;    { LW-Buchstabe }
                    DrvNo  : Byte;    { als Byte ablegegt (0...) }
                    HSG_RB : Byte;    { Adressierungs-Modus }

                    Sector : LongInt; { Adresse des Lesekopfes }
                    VolInfo: Array[1..8] of Byte; { Lautst.-Einstellungen }
                    DevPar : LongInt; { Device-parameter, BIT-Feld! }
                    RawMode: Boolean; { Raw/Cooked-Mode ? }
                    SecSize: Word;    { Bytes/Sector }
                    VolSize: LongInt; { sek/Volume => Groesse der CD}

                    MedChg : Byte;    { Disk gewechselt? }

                    LoAuTr : Byte;    { kleinste Audio-Track # }
                    HiAuTr : Byte;    { groesste Audio-Track # }
                    endAdr : LongInt; { Adresse der Auslaufrille (8-) }

                    TrkNo  : Byte;    { Track #. Eingabe-Wert ! }
                    TrkAdr : LongInt; { Adresse dieses Tracks }
                    TrkInf : Byte;    { Info dazu: BIT-Feld! }

                    CntAdr : Byte;   { CONTROL und ADR, von LW }
                    CTrk   : Byte;   { track # }
                    Cindx  : Byte;   { point/index }
                    CMin   : Byte;   { minute\  }
                    CSek   : Byte;   { second > Laufzeit im Track }
                    CFrm   : Byte;   { frame /  }
                    Czero  : Byte;   { immer =0 }
                    CAmin  : Byte;   { minute \ }
                    CAsec  : Byte;   { sekunde > Laufzeit auf Disk }
                    CAFrm  : Byte;   { frame  / }

                    Qfrm   : LongInt;{ start-frame address }
                    Qtrfs  : LongInt;{ Bufferaddresse }
                    Qcnt   : LongInt;{ Anzahl der Sectoren }
                      { pro Sector werden 96 Byte nach buffer kopiert }

                    Uctrl  : Byte;  { CONTROL und ADR Byte }
                    Upn    : Array[1..7] of Byte; { EAN-CODE }
                    Uzero  : Byte;  { immer = 0 }
                    Ufrm   : Byte;  { Frame-# }
                  end;
      OneTrack             = Record
                               Title   : String[20];
                               Runmin,
                               RunSec :  Byte;
                               Start  :  LongInt;  { HSG Format ! }
                             end;
      VolumeTableOfContens = Record
                               Diskname: String[20];
                               UAN_Code: String[13];
                               TrackCnt: Byte;
                               Titles  : Array[1..99] of OneTrack;
                             end;
       TrkInfo  = Record
                     Nummer  : Byte;
                     Start   : LongInt;
                     Cntrl2  : Byte;
                  end;
{===== global verfuegbare Variablen =============}

Var    CD           : CD_Record;
       CD_AVAIL     : Boolean;
       VtoC         : VolumeTableOfContens;
       CD_REDPos    : String;
       CD_HSGPos    : String;

{===== allgemeine Funktionen ===================}

Function CD_Reset   : Boolean;
Function CD_HeadAdr : Boolean;
Function CD_Position: Boolean;
Function CD_MediaChanged: Boolean;


{===== Tray/Caddy-Funktionen ===================}

Function CD_Open:  Boolean;
Function CD_Close: Boolean;
Function CD_Eject: Boolean;

{==== Audio-Funktionen =========================}

Function CD_Play(no:Byte; len:Integer):  Boolean;
Function CD_Stop:  Boolean;
Function CD_Resume:Boolean;
Function CD_SetVol:Boolean;
Function CD_GetVol:Boolean;

Procedure CD_Info;
Procedure CD_TrackInfo( Nr:Byte; Var T:TrkInfo );

{==== Umwandlungen =============================}

Function Red2Time( Var Inf:TrkInfo ):Word;

Implementation Uses Dos;
Type   IOCtlBlk = Array[0..200] of Byte;

Const  IOCtlRead  = $4402;
       IOCtlWrite = $4403;
       DevDrvReq  = $1510;
       All:LongInt= $0f00;

Var  R        : Registers;
     H        : Text;
     Handle   : Word;
     Old_Exit : Pointer;
     CtlBlk   : IOCtlBlk;

     Tracks   : Array[1..100] of TrkInfo;

Procedure CD_Exit;               { wird bei Programmende ausgefuehrt }
begin
  if Old_Exit <> NIL
    then ExitProc := Old_Exit;      { Umleitung wieder zuruecknehmen }
{$I-}
  Close(H);
  If IoResult = 0 then;              { 'H' schliessen, falls offen, }
{$I+}                                      { evtl. Fehler verwerfen }
end;


Function CD_Init:  Boolean;    { Initialisierung beim Programmstart }
begin
 FillChar( CD, SizeOf( CD ), 0);
 With R do
 begin
   AX := $1500;
   BX := $0000;
   CX := $0000;
   Intr( $2F, R );
   CD_Init := (BX > 0);                  { Anzahl der CD-Laufwerke }
   If BX > 0
    then begin
      CD.DrvChar                           { CD-Laufwerksbuchstabe }
         := Char( CL + Byte('A') );
      CD.DrvNo := CL;
      If CD_HeadAdr then
        If CD_GetVol then;
    end
    else CD.DrvChar := '?';                      { im Fehlerfall...}
 end
end;

Procedure CD_TrackInfo( Nr:Byte; Var T:TrkInfo );
begin
  T := Tracks[nr]
end;

Function OpenCDHandle:Word;
Const Name : String[8] = 'MSCD001';        { evt. anpassen!!! ? }
begin
  Assign(H, Name);                         { Filehandle holen }
(*$I-*)
  Reset(H);
(*$I+*)
  if IoResult = 0 then
  begin
    Handle := TextRec(H).Handle;                { Filehandle holen }
    Old_Exit := ExitProc;           { Bei ende/Abbruch muss 'H'... }
    ExitProc := @CD_Exit;      { ...automatisch geschlossen werden }
  end
  else Handle := 0;
  OpenCDHandle := Handle;
end;

Procedure CloseCDHandle;
begin
  if TextRec(H).Mode <> FmClosed
     then ExitProc := Old_Exit;     { Umleitung wieder zuruecknehmen }
  Old_Exit := NIL;
{$I-}
  Close(H);
  If IoResult = 0 then;             { 'H' schliessen, falls offen, }
{$I+}                                     { evtl. Fehler verwerfen }
end;


Function Red2HSG( Var Inf:TrkInfo ):LongInt;
Var l: LongInt;
begin
      l :=     LongInt(( Inf.Start shr 16 ) and $FF )  * 4500;
      l := l + LongInt(( Inf.Start shr  8 ) and $FF )  * 75;
      l := l + LongInt(( Inf.Start        ) and $FF ) ;

  Red2HSG := l -2;
end;

Function Red2Time( Var Inf:TrkInfo ):Word;
begin
  Red2Time:= (( Inf.Start shr 24 ) and $FF ) shl 8
           + (( Inf.Start shr 16 ) and $FF )
end;

Function HSG2Red(L:LongInt):LongInt;
begin
end;

Function CD_IOCtl( Func, Len : Word) :  Boolean;
begin
  With R do
  begin
    AX := Func;
    BX := OpenCDHandle;
    CX := 129;
    DS := DSeg;
    ES := DS;
    DX := Ofs(CtlBlk);
    MsDos( R );
    CD.Status := AX;
    CD_IOCtl  := (Flags and FCARRY) = 0;
    CloseCDHandle;
  end
end;


Function CD_Reset: Boolean;
begin
  CtlBlk[0] := 2;   { Reset }
  CD_Reset  := CD_IoCtl( IoCtlWrite, 1)
end;

Function DieTuer( AufZu:Byte ): Boolean;
begin
  CtlBlk[0] := 1;                                      { die Tuer.. }
  CtlBlk[1] := AufZu;                                { ..freigeben }
  DieTuer := CD_IoCTL(IoCtlWrite, 2);
end;

Function CD_Open: Boolean;
Const Auf = 0;
begin
 CD_Open := DieTuer( Auf );
end;

Function CD_Close: Boolean;
Const Zu = 1;
begin
 CD_Close := DieTuer( Zu );
end;


Function CD_Eject: Boolean;
begin
  CtlBlk[0] := 0;                                   { CD auswerfen }
  CD_Eject  := CD_IOCtl(IoCtlWrite, 1);
end;


Function CD_Play(no:Byte; len:Integer):  Boolean;
begin                                               { CD PlayAudio }

  FillChar(CtlBlk, SizeOf(CtlBlk), 0);
  CtlBlk[0] := 22;                             { laenge des req-hdr }
  CtlBlk[1] := 0;                                       { sub-Unit }
  CtlBlk[2] := $84;                                     { Kommando }
  CtlBlk[3] := 0;                                    { Status-WORT }
  CtlBlk[4] := 0;
  CtlBlk[5] := 0;
  CtlBlk[13]:= CD.HSG_RB;                             { HSG-Modus }

  CD.Sector := VtoC.Titles[no].Start;          { ist im HSG-Format }

  Move( CD.Sector, CtlBlk[14], 4 );                 { Start-Sector }
  if len = -1
    then All := $FFFF
    else All := len;
  Move( All      , CtlBlk[18], 4 );               { Anzahl Sectoren}
  Asm
     mov  ax, $1510
     push ds
     pop  es
     xor  cx, cx
     mov  cl, CD.DrvNo
     mov  bx, offset CtlBlk
     Int $2f
  end;

  CD.Status := CtlBlk[3] or CtlBlk[4] shl 8;
  CD_Play   := CD.Status and $8000 = 0;

end;

Function CD_VtoC:Boolean;
Var i: Byte;
    l: LongInt;
begin
  FillChar( Tracks, SizeOf( Tracks ), 0);
  CtlBlk[0] := 10;                               { Read LeadOut-Tr }
  CD_IoCtl( IoCtlRead, 6);
  Move( CtlBlk[1], CD.LoAuTr, 6);
  i := CD.HiAuTr+1;
  Move( CtlBlk[3], Tracks[i], 4);      { die Auslaufrille 8-) }
  Tracks[i].Start := Red2Hsg(Tracks[i]);

  For i := CD.LoAuTr to CD.HiAuTr do
  begin
    FillChar(CtlBlk, SizeOf(CtlBlk), 0);           { RED-Book-Format }
    CtlBlk[0] := 11;                               { Read VtoC-Entry }
    CtlBlk[1] := i;                                       { track-no }
    CD_IoCtl( IoCtlRead, 6);
    Move( CtlBlk[1], Tracks[i], 6);
{   Tracks[i].Start := Red2Hsg(Tracks[i]); }
  end;


  With VtoC do
  begin
    DiskName := '';
    UAN_Code := '';
    TrackCnt := CD.HiAuTr;
    For i := CD.LoAuTr to CD.HiAuTr do
    With Titles[i] do
    begin
      L := LongInt((Tracks[i+1].Start shr 16) and $FF) * 60
        +         (Tracks[i+1].Start shr  8) and $FF
        - ( LongInt((Tracks[i].Start shr 16) and $FF) * 60
                 +  (Tracks[i].Start shr  8) and $FF);
      Title  := '???';
      RunMin := L div 60;
      RunSec := l - RunMin*60;
      Start  := Red2Hsg(Tracks[i]);
    end
  end;



end;

Function CD_Stop:  Boolean;
begin                                               { CD StopAudio }
  FillChar(CtlBlk, SizeOf(CtlBlk), 0);
  CtlBlk[0] := 5;                             { laenge des req-hdr }
  CtlBlk[1] := 0;                                       { sub-Unit }
  CtlBlk[2] := $85;                                     { Kommando }
  CtlBlk[3] := 0;                                    { Status-WORT }
  CtlBlk[4] := 0;
  CtlBlk[5] := 0;
  Asm
     mov  ax, $1510
     push ds
     pop  es
     xor  cx, cx
     mov  cl, CD.DrvNo
     mov  bx, offset CtlBlk
     Int $2f
  end;

  CD.Status := CtlBlk[3] or CtlBlk[4] shl 8;
  CD_Stop   := CD.Status and $8000 = 0;

end;


Function CD_Resume:Boolean;
begin                                                 { ResumeAudio}
  CtlBlk[0] := 3;                              { laenge des req-hdr }
  CtlBlk[1] := 0;                                       { sub-Unit }
  CtlBlk[2] := $88;                                     { Kommando }
  CtlBlk[3] := 0;                                    { Status-WORT }
  CtlBlk[4] := 0;
  Asm
     mov ax, Seg @DATA
     mov es, ax
     mov ax, DevDrvReq
     lea bx, CtlBlk
     Int 2fh
  end;
  CD.Status := CtlBlk[3] or CtlBlk[4] shl 8;
  CD_Resume := CD.Status and $8000 = 0;

end;

Function CD_GetVol:Boolean;
begin
  CtlBlk[0] := 4;                           { die Lautstaerke lesen }
  CD_GetVol := CD_IOCtl(IoCtlRead, 8);
  if ((R.Flags and FCARRY) = 0)
   then Move(CtlBlk[1], CD.VolInfo, 8)
   else FillChar( CD.VolInfo, 8, 0)
end;

Function CD_SetVol:Boolean;
begin
  CtlBlk[0] := 3;                          { die Lautstaerke setzen }
  CD_SetVol := CD_IOCtl( IoCtlWrite, 8);
end;

Function CD_HeadAdr: Boolean;
Var  L:LongInt;  S:String;
begin
  FillChar(CtlBlk, SizeOf(CtlBlk), 0);
  CtlBlk[0] := 1;
  CtlBlk[1] := 1;                     { die KopfPosition im RED-Format }
  CD_HeadAdr:= CD_IOCtl(IoCtlRead, 128);
  if ((R.Flags and FCARRY) = 0)
    then begin
           Move(CtlBlk[2], L, 4);
           if CtlBlk[1] = 1 then
           begin
             STR( CtlBlk[4]:2, S);  CD_REDPos := S;
             STR( CtlBlk[3]:2, S);  CD_REDPos := CD_REDPos+ ':'+ S;
             CD.Sector := LongInt(CtlBlk[4]) *4500 +
                          LongInt(CtlBlk[3]) *75   +
                          LongInt(CtlBlk[2])
                          - 150;
           end else
           begin
             CD.Sector := L;
             STR(L:0,CD_HSGPos);
           end

         end
    else FillChar( CD.Sector, 4, 0);
end;


Function CD_Position:Boolean;
Var l : LongInt;
begin
  CtlBlk[0] := 12;                                  { Audio-Infos  }
  CD_Position :=CD_IOCtl(IoCtlRead,10);
  Move(CtlBlk[1], CD.CntAdr, 10);
end;


Procedure CD_GetUAN;
begin
  CtlBlk[0] := 14;                                  { EAN-Nummer   }
  If CD_IOCtl(IoCtlRead,10)
    then Move(CtlBlk[1], CD.Uctrl, 10);
end;


Function CD_MediaChanged:Boolean;
begin
  CtlBlk[0] := 9;                                   { Media-Change }
  If CD_IOCtl(IoCtlRead, 1)
    then Move(CtlBlk[1], CD.MedChg, 1 );
  CD_MediaChanged:= CD.MedChg <> 1
end;

Procedure CD_Info;
begin

 { CD_Reset; }

  If CD_HeadAdr then;

  CtlBlk[0] := 6;                               { Device-parameter }
  If CD_IOCtl(IoCtlRead, 4)
    then Move(CtlBlk[1], CD.DevPar, 4 );

  CtlBlk[0] := 7;                                   { Sector-Groesse }
  If CD_IOCtl(IoCtlRead, 3)                              { & Modus }
    then Move(CtlBlk[1], CD.RawMode, 3 );

  CtlBlk[0] := 8;                                   { Volume-Groesse }
  If CD_IOCtl(IoCtlRead, 4)
    then Move(CtlBlk[1], CD.VolSize, 4 );

  CtlBlk[0] := 12;                                  { Audio-Infos  }
  If CD_IOCtl(IoCtlRead,10)
    then Move(CtlBlk[1], CD.CntAdr, 10);

  CtlBlk[0] := 11;                                  { Track-Infos  }
  CtlBlk[1] := CtlBlk[2];                           { aktueller... }
  If CD_IOCtl(IoCtlRead, 6)
    then Move(CtlBlk[1], CD.TrkNo, 6 );

  CD_VtoC;

end;

{========= minimale Initialisierung =============}
begin
  CD_Avail := CD_Init;
  if CD_Avail then CD_INFO
end. Norbert

{
--- part 2, a Test -----
}
Program CDROM_TEST;
Uses Crt, cdrom, SbTest;
Type a5 = Array[0..4] of Byte;
Var i:Byte;
    L : LongInt;
    ch : Char;
    no,
    len : Integer;

begin
  ClrScr;
  WriteLn('CDROM-Unit TestProgram',#10);
  With CD do
  if CD_Avail then
  begin
   WriteLn('■ CD als Laufwerk ',DrvChar,': gefunden!');
   Write  ('■ Aktuelle CD: ');

   Write('(UPN-CODE:');
   For i := 1 to 7 do Write(Char( (Upn[i] shr 4)  or $30),
                            Char((Upn[i] and $f) or $30));
   WriteLn(#8')');
   WriteLn('■ Audio-Tracks : ',loautr,'..',hiautr);
   WriteLn(' Laufzeiten : ');
   For i := CD.LoAuTr to CD.HiAuTr do
    With VtoC.Titles[i] do
      WriteLn(i,Title:10, RunMin:6,':',RunSec);
   no := 1;
   len := -1;

   if CD_Stop then
     if not CD_Play( no ,len)
        then WriteLn('! Fehler-Status: ',STATUS and $F);

   ch := ' ';
   While ch <> #27 do
   begin
   While ch = ' ' do
     With CD do
     begin
       if CD_Position then
         Write('Playing Track ',CTrk,'  :   ',CMin:2,':',CSek:2,'   '#13);
       Delay(1500);
       if KeyPressed
          then ch := ReadKey;
     end;
     Case ch of
       '+' : Inc(no);
       '-' : Dec(no);
     end;
     if ch <> #27 then ch := ' ';
     if no > cd.HiAUTr then Dec(no);
     if no < cd.LoAuTr then Inc(no);
     if CD_Stop
       then CD_Play(no, len);
   end;
   cd_stop;
   clreol;
   WriteLn(' CD stopped...');
  end
  else WriteLn('Leider kein CD-ROM gefunden...');
end.

