(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0008.PAS
  Description: SCSICODE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

{
 > I am trying to issue an SCSI START/StoP Unit via Adaptec's ASPI SCSI
 > manager and an 1542B host adaptor.  This is For an application I am
 > writing in BP.  Adaptec is of no help.  if anyone here has any
 > comments
 > or suggestions please respond in this Forum.
}

Unit Aspi;

{ I/O Error reporting:

  AspiSenseKey is the primary source of error inFormation.

    0:    I/O Complete.
          Warnings (Filemark, Short block, etc) may be posted in Sense.

    1-E:  Error occured.
          Examine SRBStat, HostStat, TargStat, Sense For details.

    F:    Severe error detected, no SCSI info available.

  -------------------------------------------------------------------- }

Interface

Const
  SrbIn = $08;
  SRBOut = $10;
  SRBNone = $18;
  AspiPtr:  Pointer = Nil;


Type
  AspiSrb = Record
    SrbCmd:      Byte;
    SrbStat:     Byte;
    SrbHost:     Byte;
    SrbReqFlags: Byte;
    SrbHdrFill:  LongInt;
    Case Integer of
     2: (Srb2TargetID: Byte;
         Srb2LUN:      Byte;
         Srb2DataLen:  LongInt;
         Srb2SenseLen: Byte;
         Srb2DataPtr:  Pointer;
         Srb2LinkPtr:  Pointer;
         Srb2CDBLen:   Byte;
         Srb2HAStat:   Byte;
         Srb2TargStat: Byte;
         Srb2PostAddr: Pointer;
         Srb2Filler:   Array [1..34] of Byte;
         { Sense data follows CDB }
         Srb2CDB:      Array [0..50] of Byte);
     1: (Srb1TargetID: Byte;
         Srb1LUN:      Byte;
         Srb1DevType:  Byte);
     0: (Srb0Cnt:      Byte;
         Srb0TargetID: Byte;
         Srb0MgrID:    Array [1..16] of Char;
         Srb0HostID:   Array [1..16] of Char;
         Srb0HostParm: Array [1..16] of Char);
    end;

Var
  AspiSRBStat:      Byte;
  AspiHostStat:     Byte;
  AspiTargStat:     Byte;
  AspiSenseKey:     Byte;
  AspiSense:        Array [0..17] of Byte;
  AspiSenseCode:    Word;

Function AspiOpen: Integer;

Procedure AspiCall (Var SRB: AspiSrb);
{ Call ASPI Handler With SRB }
Inline ($FF/$1E/>AspiPtr/
        $58/$58);

Procedure AspiWait (Var SRB: AspiSrb);

Function AspiClose: Integer;

Implementation

Uses Dos;

Procedure AspiWait (Var SRB: AspiSRB);
{ Call ASPI Handler With SRB and wait For Completion }
begin
  if AspiPtr = Nil
    then begin
      AspiSenseKey := $0F;
      Exit;
      end;
  With Srb do begin
    SrbStat := 0;
    AspiCall (Srb);
    While SrbStat = 0 do ;
    AspiSrbStat   := SrbStat;
    AspiHostStat  := Srb2HAStat;
    AspiTargStat  := Srb2TargStat;
    AspiSenseKey  := 0;
    FillChar (AspiSense, Sizeof (AspiSense), #0);
    Move (Srb2CDB [Srb2CDBLen], AspiSense, Sizeof (AspiSense));
    AspiSenseKey := AspiSense[2] and $0F;
    AspiSenseCode := (AspiSense [12] SHL 8) or AspiSense [13];
    end;
  end;

Function AspiOpen: Integer;
Const
  AspiName: Array [1..9] of Char = 'SCSIMGR$'#0;
Var
  R:       Registers;
  AspiHan: Word;
begin
  With R do begin
    { Assume failure }
    AspiOpen := -1;
    AspiPtr := Nil;

    { Open ASPI device driver }
    AX := $3D00;
    DS := Seg (AspiName[1]);
    DX := ofs (AspiName[1]);
    MSDos (R);
    if odd (Flags)
      then Exit;
    AspiHan := AX;

    { Do IOCtl Read to get Pointer to ASPI handler }
    AX := $4402;
    BX := AspiHan;
    CX := 4;
    DS := Seg (AspiPtr);
    DX := ofs (AspiPtr);
    MSDos (R);
    if Odd (flags)
      then Exit;

    { Close device driver }
    AX := $3E00;
    BX := AspiHan;
    MsDos (R);
    if Odd (Flags)
      then Exit;
    end;

  { Indicate success  and Exit }
  AspiOpen := 0;
  end { AspiOpen };

Function AspiClose: Integer;
begin
  AspiClose := 0;
end { AspiClose };

end.

