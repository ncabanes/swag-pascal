(*
  Category: SWAG Title: UNIT INFORMATION ROUTINES
  Original name: 0007.PAS
  Description: Code Profiler
  Author: RALF ROSENKRANZ
  Date: 01-02-98  07:35
*)

Unit Profiler; {*********************************************************}
               {*                                                       *}
               {*  PROFILER.PAS, 1997, Ralf Rosenkranz, Hagen, Germany  *}
               {*                                                       *}
               {*  This unit will help you to speed up your Programs.   *}
               {*  The source is PUBLIC DOMAIN, feel free to use it.    *}
               {*                                                       *}
               {*  It works with BP 7.0 and DOS (No Multitasking Env.)  *)
               {*                                                       *}
               {*  USAGE: See the example at the end of this file.      *}
               {*  Just place the PROFILER-Control-Lines in your Code,  *}
               {*  set "Options/Conditional defines" to PROFILE,        *}
               {*  and rebuild the Project. PROFILER will now generate  *}
               {*  at runtime a Timing-Profile of your Code, the        *}
               {*  result is in PROFILE.TXT. Attention: PROFILER uses   *}
               {*  a lot of CPU-time by itself, but this doesn't effekt *}
               {*  the result.                                          *}
               {*                                                       *}
               {*  Please visit my Homepage for more details:           *}
               {*  http://privat.schlund.de/RosenkranzRalf/RR01Home.html*}
               {*                                                       *}
               {*********************************************************}


INTERFACE


uses TpTimer;  {*********************************************************}
               {*                        uses:                          *}
               {*                                                       *}
               {*                   TPTIMER.PAS 2.00                    *}
               {*                by TurboPower Software                 *}
               {*                                                       *}
               {*         It's in the SWAG-Archive ! (TIMING.SWG)       *}
               {*********************************************************}


Type PSPT = ^PST;
     PST = Record
            H :Word;
            Name :String [64];
           end;


Procedure ProfilerEnterSection (SectionPtr :PSPT);

Procedure ProfilerLeaveSection (SectionPtr :PSPT);

Procedure ProfilerReport (FileName :String);


IMPLEMENTATION


{$ifdef DPMI}
const MaxSectionCount = 256;
{$else}
const MaxSectionCount = 64;
{$endif}

const LevelSpacer = '  ';

Type SSDPT = ^SSDT;
     SSDT = Record
             SAC :LongInt;
             SAMS :LongInt;
            end;

Type SSDPAPT = ^SSDPAT;
     SSDPAT = Array [1..MaxSectionCount] of SSDPT;

Type SSCT = Record
             SSAF :Boolean;
             SSDPAP :SSDPAPT;
            end;

Type SDT = Record
            CSP : PSPT;
            TAC :LongInt;
            TAMS :LongInt;
            ET :LongInt;
            LT :LongInt;
            CSH :Word;
            SAF :Boolean;
            SSC :SSCT;
            SOUPOTST :Real;
           end;

Type SDAPT = ^SDAT;
     SDAT = Array [1..MaxSectionCount] of SDT;

Type SCT = Record
            UC :Word;
            SDAP :SDAPT;
            CRSH :Word;
            RDC :LongInt;
           end;

var SC :SCT;

var THSF :Boolean;
    TAS :LongInt;
    TD :LongInt;
    TZO :LongInt;

var R :Text;
    HRF :Boolean;



Procedure Error (E :String);

begin
 WriteLn (E);
 Halt (1);
end;



Function IntToStr (L :LongInt) :String;

var Z :String;

begin
 Str (L, Z);
 IntToStr:= Z;
end;



Function RealToStr (R :Real) :String;

const MAS = 10000000;
      MIS = 0.0000001;

var Z :String;
    EF :Boolean;
    c :Char;

begin
   if ((Abs (R) < MAS) and (Abs (R) > MIS)) or (R = 0) then
   begin
      Str (R:17:16, Z);
      EF:= False;
      while not EF do
      begin
         c:= Z [Length (Z)];
         if (c = '0') or (c = '.')
         then Z:= Copy (Z, 1, Length (Z) - 1)
         else EF:= True;
         if (c = '.') or (Length (Z) <= 1) then EF:= True;
      end;
      while Z [1] = ' ' do Z:= Copy (Z, 2, Length (Z) - 1);
   end
   else
   begin
      Str (R, Z);
      while Z [1] = ' ' do Z:= Copy (Z, 2, Length (Z) - 1);
   end;
   RealToStr:= Z;
end;



Function FixRealStr (S :String; VKB, NKB :Integer) :String;

var PP :Byte;
    EP :Byte;
    MEF :Boolean;
    VK, NK, NE :String;

begin
 EP:= Pos ('E', S);
 if EP = 0 then EP:= Pos ('e', S);
 if EP = 0 then
 begin
  EP:= Length (S) + 1;
  MEF:= False;
 end
 else MEF:= True;
 PP:= Pos ('.', S);
 if (PP > 0) and
  (PP < EP) then
 begin
  VK:= Copy (S, 1, PP - 1);
  NK:= Copy (S, PP + 1, EP - (PP + 1));
  NE:= Copy (S, EP + 1, Length (S) - EP);
  if VK [1] = '-' then
  begin
   while ((VK [2] = '0') or
          (VK [2] = ' ')) and
          (Length (VK) > 2) do VK:= Copy (VK, 3, Length (VK) - 2);
  end
  else
  begin
   while ((VK [1] = '0') or
          (VK [1] = ' ')) and
          (Length (VK) > 1) do VK:= Copy (VK, 2, Length (VK) - 1);
  end;
  while Length (VK) < VKB do VK:= ' ' + VK;
  NK:= Copy (NK, 1, NKB);
  if MEF = True then
  begin
   while Length (NK) < NKB do NK:= ' ' + NK;
  end;
  if MEF = False
  then FixRealStr:= VK + '.' + NK
  else FixRealStr:= VK + '.' + NK + 'E' + NE;
 end
 else
 begin
  VK:= Copy (S, 1, EP - 1);
  NE:= Copy (S, EP + 1, Length (S) - EP);
  if VK [1] = '-' then
  begin
   while ((VK [2] = '0') or
          (VK [2] = ' ')) and
          (Length (VK) > 2)do VK:= Copy (VK, 3, Length (VK) - 2);
  end
  else
  begin
   while ((VK [1] = '0') or
          (VK [1] = ' ')) and
          (Length (VK) > 1) do VK:= Copy (VK, 2, Length (VK) - 1);
  end;
  while Length (VK) < VKB do VK:= ' ' + VK;
  if MEF = False
  then FixRealStr:= VK + '.' + '0'
  else FixRealStr:= VK + '.' + '0' + 'E' + NE;
 end;
end;



Procedure Init;

const InitSection :PST = (H:0; Name:'ProfilerInitSection');
const ZeroSection :PST = (H:0; Name:'ProfilerZeroSection');

const SLC = 1000;

var n,m :Word;

begin
 HRF:= False;
 THSF:= False;
 TAS:= 0;
 TD:= 0;
 with SC do
 begin
  UC:= 0;
  new (SDAP);
  CRSH:= 0;
  RDC:= 0;
  for n:= 1 to MaxSectionCount do
  begin
   with SDAP^[n] do
   begin
    CSP:= NIL;
    TAC:= 0;
    TAMS:= 0;
    ET:= 0;
    LT:= 0;
    CSH:= 0;
    SAF:= False;
    with SSC do
    begin
     New (SSDPAP);
     SSAF:= False;
     for m:= 1 to MaxSectionCount do
     begin
      SSDPAP^[m]:= NIL;
     end;
    end;
   end;
  end;
 end;
 TZO:= 0;
 for n:= 1 to SLC do
 begin
  ProfilerEnterSection (@InitSection);
  ProfilerLeaveSection (@InitSection);
 end;
 with SC.SDAP^[InitSection.H] do
 begin
  TZO:= Round (TAMS / TAC);
 end;
 for n:= 1 to SLC do
 begin
  ProfilerEnterSection (@ZeroSection);
  ProfilerLeaveSection (@ZeroSection);
 end;
end;



Procedure Done;

begin
 if HRF = False then ProfilerReport ('PROFILE.TXT');
end;



Procedure StopTime;

begin
 if THSF = True
 then Error ('Profiler.StopTime: Time is not running !');
 TAS:= ReadTimer - TD;
 THSF:= True;
end;



Procedure ContTime;

begin
 if THSF = False
 then Error ('Profiler.ContTime: Time has not been stopped !');
 Inc (TD, (ReadTimer - TD) - TAS);
 THSF:= False;
end;



Function ReadMicroSecTime :LongInt;

begin
 if THSF = True
 then ReadMicroSecTime:= TAS
 else ReadMicroSecTime:= ReadTimer - TD;
end;



Procedure ProfilerEnterSection (SectionPtr :PSPT);

var H :Word;

begin
 StopTime;
 if SC.RDC > 0 then
 begin
  Inc (SC.RDC);
 end
 else
 begin
  H:= SectionPtr^.H;
  if H = 0 then
  begin
   with SC do
   begin
    if UC >= MaxSectionCount
    then Error ('ProfilerEnterSection: Limit: ' +
          IntToStr (MaxSectionCount) + 'Sections  !');
    Inc (UC);
    H:= UC;
    SectionPtr^.H:= H;
    with SDAP^[H] do
    begin
     CSP:= SectionPtr;
     TAC:= 1;
     TAMS:= 0;
     ET:= ReadMicroSecTime;
     LT:= 0;
     CSH:= CRSH;
     CRSH:= H;
     SAF:= True;
    end;
   end;
  end
  else
  begin
   with SC do
   begin
    with SDAP^[H] do
    begin
     if SAF = True then
     begin
      SC.RDC:= 1;
     end
     else
     begin
      Inc (TAC);
      ET:= ReadMicroSecTime;
      CSH:= CRSH;
      CRSH:= H;
      SAF:= True;
     end;
    end;
   end;
  end;
 end;
 ContTime;
end;



Procedure ProfilerLeaveSection (SectionPtr :PSPT);

var H :Word;
    DMS :LongInt;

begin
 StopTime;
 if SC.RDC > 0 then
 begin
  Dec (SC.RDC);
 end
 else
 begin
  H:= SectionPtr^.H;
  if H <> SC.CRSH then
   with SC do
    Error ('ProfilerLeaveSection: LeaveSection ' +
        SectionPtr^.Name +
        ' doesn''t match EnterSection ' +
        SDAP^[CRSH].CSP^.Name);
  with SC do
  begin
   with SDAP^[H] do
   begin
    LT:= ReadMicroSecTime;
    DMS:= LT - ET;
    DMS:= DMS - TZO;
    Inc (TAMS, DMS);
    CRSH:= CSH;
    SAF:= False;
   end;
   if CRSH > 0 then
   begin
    with SDAP^[CRSH] do
    begin
     with SSC do
     begin
      if SSDPAP^[H] = NIL then
      begin
       New (SSDPAP^[H]);
       SSAF:= True;
       with SSDPAP^[H]^ do
       begin
        SAC:= 1;
        SAMS:= DMS;
       end;
      end
      else
      begin
       with SSDPAP^[H]^ do
       begin
        Inc (SAC);
        Inc (SAMS, DMS);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 ContTime;
end;



Procedure SectionReport (H :Word);

var SH :Word;
    n :Integer;
    L :Word;
    AVMS :Real;
    FP :Real;

begin
 with SC.SDAP^[H] do
 begin
  AVMS:= TAMS / TAC;
  Write (R, CSP^.Name, ':');
  Write (R, ' AverageMicroSecs=', FixRealStr (RealToStr (AVMS), 1, 1));
  Write (R, ' ActiveMicroSecs=', TAMS);
  Write (R, ' ActiveCount=', TAC);
  WriteLn (R);
 end;
end;



Procedure SubSectionReport (L :Word;
                            H :Word;
                            CSAMS :Real;
                            ACPOTST:Real;
                            CSAC :LongInt;
                            TSAC :LongInt;
                            TSAMS :LongInt;
                            PF :Boolean);

var SH :Word;
    n :Integer;
    TSN :String;
    TSAVMS :Real;
    TSCPCS :Real;
    TSEMS :Real;
    AMS :Real;
    SSCPTS :Real;
    EMS :Real;
    ASSEMS :Real;
    NISSEMS :Real;
    LPOTST :Real;
    UPOTST:Real;

begin
 with SC.SDAP^[H] do
 begin
  TSN:= CSP^.Name;
  ASSEMS:= 0;
  with SSC do
  begin
   for SH:= 1 to SC.UC do
   begin
    if SSDPAP^[SH] <> NIL then
    begin
     with SSDPAP^[SH]^ do
     begin
      AMS:= SAMS / SAC;
      SSCPTS:= SAC / TSAC;
      EMS:= AMS * SSCPTS;
      ASSEMS:= ASSEMS + EMS;
     end;
    end;
   end;
  end;
 end;
 TSCPCS:= TSAC / CSAC;
 TSAVMS:= TSAMS / TSAC;
 TSEMS:= TSAVMS * TSCPCS;
 NISSEMS:= (TSAVMS - ASSEMS) * TSCPCS;
 if NISSEMS < 0 then NISSEMS:= 0;
 LPOTST:= ACPOTST * (TSEMS / CSAMS);
 UPOTST:= ACPOTST * (NISSEMS / CSAMS);
 SC.SDAP^[H].SOUPOTST:= SC.SDAP^[H].SOUPOTST + UPOTST;
 if PF = True then
 begin
  for n:= 1 to L do Write (R, LevelSpacer);
  Write (R, TSN, ':');
  Write (R, ' (Level)\Used%OfTime=',
            '(', FixRealStr (RealToStr (LPOTST), 1, 1), ')\',
            FixRealStr (RealToStr (UPOTST), 1, 1), '%');
  Write (R, ' EffectiveMicroSecs=', FixRealStr (RealToStr (NISSEMS), 1, 1));
  Write (R, ' ActiveMicroSecs=', TSAMS);
  Write (R, ' ActiveCount=', TSAC);
  WriteLn (R);
 end;
 with SC.SDAP^[H].SSC do
 begin
  for SH:= 1 to SC.UC do
  begin
   if SSDPAP^[SH] <> NIL then
   begin
    with SSDPAP^[SH]^ do
    begin
     SubSectionReport (L + 1, SH, TSAVMS, LPOTST, TSAC, SAC, SAMS, PF);
    end;
   end;
  end;
 end;
end;



Procedure TopSectionReport (H :Word; PF :Boolean);

var SH :Word;
    n :Integer;
    L :Word;
    AMS :Real;
    FP :Real;
    CAC :LongInt;

begin
 with SC do
 begin
  for n:= 1 to UC do
  begin
   SDAP^[n].SOUPOTST:= 0;
  end;
 end;
 with SC.SDAP^[H] do
 begin
  L:= 0;
  AMS:= TAMS / TAC;
  FP:= 100;
  CAC:= TAC;
  if PF = True then
  begin
   Write (R, CSP^.Name, ':');
   Write (R, ' AvailPercentOfTime=100.0%');
   Write (R, ' AverageMicroSecs=', FixRealStr (RealToStr (AMS), 1, 1));
   Write (R, ' ActiveMicroSecs=', TAMS);
   Write (R, ' ActiveCount=', TAC);
   WriteLn (R);
  end;
  with SSC do
  begin
   for SH:= 1 to SC.UC do
   begin
    if SSDPAP^[SH] <> NIL then
    begin
     with SSDPAP^[SH]^ do
     begin
      SubSectionReport (L + 1, SH, AMS, FP, CAC, SAC, SAMS, PF);
     end;
    end;
   end;
  end;
 end;
end;



Procedure ProfilerReport (FileName :String);

var H :Word;
    SH :Word;
    n :Integer;
    SOA :Real;

begin
 StopTime;
 Assign (R, FileName);
 Rewrite (R);
 with SC do
 begin
  Writeln (R);
  WriteLn (R, '--- Section Overview ---------------------------------------------------------');
  Writeln (R);
  for H:= 1 to UC do
  begin
   SectionReport (H);
  end;
  for n:= 1 to 5 do WriteLn (R);
  Writeln (R);
  WriteLn (R, '--- Top-Level-Sections Tree-View ---------------------------------------------');
  Writeln (R);
  for H:= 1 to UC do
  begin
   if SDAP^[H].CSH = 0 then
   begin
    TopSectionReport (H, True);
    WriteLn (R);
   end;
  end;
  for n:= 1 to 4 do WriteLn (R);
  Writeln (R);
  WriteLn (R, '--- Sub-Level-Sections Tree-View ---------------------------------------------');
  Writeln (R);
  for H:= 1 to UC do
  begin
   if (SDAP^[H].CSH > 0) and
    (SDAP^[H].SSC.SSAF = True) then
   begin
    TopSectionReport (H, True);
    WriteLn (R);
   end;
  end;
  for n:= 1 to 4 do WriteLn (R);
  Writeln (R);
  WriteLn (R, '--- Top-Level-Sections Flat-View ---------------------------------------------');
  Writeln (R);
  for H:= 1 to UC do
  begin
   if SDAP^[H].CSH = 0 then
   begin
    TopSectionReport (H, False);
    with SDAP^[H] do
    begin
     WriteLn (R, CSP^.Name, ':');
    end;
    SOA:= 0;
    for SH:= 1 to UC do
    begin
     if SDAP^[SH].SOUPOTST > 0 then
     begin
      with SDAP^[SH] do
      begin
       Write (R, LevelSpacer);
       Write (R, CSP^.Name, ':');
       Write (R, ' Time%=', FixRealStr (RealToStr (SOUPOTST), 1, 1));
       WriteLn (R);
       SOA:= SOA + SOUPOTST;
      end;
     end;
    end;
    WriteLn (R, LevelSpacer + FixRealStr (RealToStr (SOA), 1, 1), '% of Time used in Sections');
    WriteLn (R);
   end;
  end;
  for n:= 1 to 4 do WriteLn (R);
  Writeln (R);
  WriteLn (R, '--- Sub-Level-Sections Flat-View ---------------------------------------------');
  Writeln (R);
  for H:= 1 to UC do
  begin
   if (SDAP^[H].CSH > 0) and
    (SDAP^[H].SSC.SSAF = True) then
   begin
    TopSectionReport (H, False);
    with SDAP^[H] do
    begin
     WriteLn (R, CSP^.Name, ':');
    end;
    SOA:= 0;
    for SH:= 1 to UC do
    begin
     if SDAP^[SH].SOUPOTST > 0 then
     begin
      with SDAP^[SH] do
      begin
       Write (R, LevelSpacer);
       Write (R, CSP^.Name, ':');
       Write (R, ' Time%=', FixRealStr (RealToStr (SOUPOTST), 1, 1));
       WriteLn (R);
       SOA:= SOA + SOUPOTST;
      end;
     end;
    end;
    WriteLn (R, LevelSpacer + FixRealStr (RealToStr (SOA), 1, 1), '% of Time used in Sections');
    WriteLn (R);
   end;
  end;
  for n:= 1 to 4 do WriteLn (R);
 end;
 Close (R);
 HRF:= True;
 ContTime;
end;



var ESP :Pointer;



Procedure UnitExit; FAR;

begin
 ExitProc:= ESP;
 Done;
end;



begin
 Init;
 ESP:= ExitProc;
 ExitProc:= @UnitExit;
end.




### snip ##########################################################################################


Program PROFTEST;

{$define PROFILE}

uses {$ifdef PROFILE} Profiler, {$endif} DOS;



Procedure WasteTime (Count :Word);

var n,m :Word;
    Dummy :Real;

begin
   for n:= 1 to Count do
   begin
      for m:= 1 to 10 do
      begin
         Dummy:= Sin ((m/10)*PI*2);
      end;
   end;
end;




Procedure Proc_1;

{$ifdef PROFILE} const Section :PST = (H:0; Name:'Proc_1'); {$endif}

begin
   {$ifdef PROFILE} ProfilerEnterSection (@Section); {$endif}

   WriteLn ('Proc_1');
   WasteTime (100);

   {$ifdef PROFILE} ProfilerLeaveSection (@Section); {$endif}
end;




Procedure Proc_2;

{$ifdef PROFILE} const Section :PST = (H:0; Name:'Proc_2'); {$endif}

var n :Integer;

begin
   {$ifdef PROFILE} ProfilerEnterSection (@Section); {$endif}

   WriteLn ('Proc_2');
   WasteTime (200);

   for n:= 1 to 10 do Proc_1;

   {$ifdef PROFILE} ProfilerLeaveSection (@Section); {$endif}
end;




{$ifdef PROFILE} const Section :PST = (H:0; Name:'MainLoop'); {$endif}

var n :Integer;

begin
   {$ifdef PROFILE} ProfilerEnterSection (@Section); {$endif}

   WriteLn ('Start');

   for n:= 1 to 4 do
   begin
      WriteLn (n);

      Proc_1;
      Proc_2;
   end;

   WriteLn ('Stop');
   WriteLn;
   WriteLn ('Results in PROFILE.TXT');
   WriteLn;

   {$ifdef PROFILE} ProfilerLeaveSection (@Section); {$endif}
end.





### snip ##########################################################################################



Result: PROFILE.TXT



--- Section Overview ---------------------------------------------------------

ProfilerInitSection: AverageMicroSecs=24.9 ActiveMicroSecs=24950 ActiveCount=1000
ProfilerZeroSection: AverageMicroSecs=0.2 ActiveMicroSecs=229 ActiveCount=1000
MainLoop: AverageMicroSecs=873098.0 ActiveMicroSecs=873098 ActiveCount=1
Proc_1: AverageMicroSecs=16450.2 ActiveMicroSecs=723809 ActiveCount=44
Proc_2: AverageMicroSecs=196836.5 ActiveMicroSecs=787346 ActiveCount=4






--- Top-Level-Sections Tree-View ---------------------------------------------

ProfilerInitSection: AvailPercentOfTime=100.0% AverageMicroSecs=24.9 ActiveMicroSecs=24950 ActiveCount=1000

ProfilerZeroSection: AvailPercentOfTime=100.0% AverageMicroSecs=0.2 ActiveMicroSecs=229 ActiveCount=1000

MainLoop: AvailPercentOfTime=100.0% AverageMicroSecs=873098.0 ActiveMicroSecs=873098 ActiveCount=1
  Proc_1: (Level)\Used%OfTime=(7.5)\7.5% EffectiveMicroSecs=65766.0 ActiveMicroSecs=65766 ActiveCount=4
  Proc_2: (Level)\Used%OfTime=(90.1)\14.8% EffectiveMicroSecs=129303.0 ActiveMicroSecs=787346 ActiveCount=4
    Proc_1: (Level)\Used%OfTime=(75.3)\75.3% EffectiveMicroSecs=164510.7 ActiveMicroSecs=658043 ActiveCount=40






--- Sub-Level-Sections Tree-View ---------------------------------------------

Proc_2: AvailPercentOfTime=100.0% AverageMicroSecs=196836.5 ActiveMicroSecs=787346 ActiveCount=4
  Proc_1: (Level)\Used%OfTime=(83.5)\83.5% EffectiveMicroSecs=164510.7 ActiveMicroSecs=658043 ActiveCount=40






--- Top-Level-Sections Flat-View ---------------------------------------------

ProfilerInitSection:
  0.0% of Time used in Sections

ProfilerZeroSection:
  0.0% of Time used in Sections

MainLoop:
  Proc_1: Time%=82.9
  Proc_2: Time%=14.8
  97.7% of Time used in Sections






--- Sub-Level-Sections Flat-View ---------------------------------------------

Proc_2:
  Proc_1: Time%=83.5
  83.5% of Time used in Sections






