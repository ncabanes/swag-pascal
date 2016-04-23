(*
 BW>> I'm programming a very big program in Turbo Pascal 5.5, and when
 BW>> I compil VB--}it, I've the error Code segment too large. I can't split
 BW>> my amin program  VB--}units because many procedures call many others
 BW>> who call back the first. VB--}How can I solve that ?

 BW>> Sounds like you need some overlays.  Better study up on them.

 MC>    Nope, overlays are about the last thing he needs to try.  The normal
 MC> solution to this problem is Units.  They can always be (re)designed to
 MC> do what's needed, structurally and functionally.  Overlays are a
 MC> solution to a very specific set of problems in TP/BP programming, and
 MC> this error isn't one of them...

 MC> ... CAUTION! DO NOT LOOK AT LASER WITH REMAINING EYE!
cool tag...

anyway, overlays may not be what he needs but have this anyways guys & girls.
tested in tp 6.0 & 7.0


This was written by Arron Cusimano of ACT Australia.


(*────────────────────────────────────────────────────────────────────────────
  Copyright (c)Arron Cusimano 1994           All Rights Reserved Worldwide.

  Conditions of use:
  1) I will not be held responisble for any adverse effects of this code.
  2) compliation of this code constitutes agreement to these conditions.
  3) have fun with it... :)

  Use of this unit :

    To use *.OVR files with a program, you must place {$O+} at the
  begining of each unit and {$F+} at the start of the program.
   Also, just after your uses clause in your program,
  a {$O unitname} statment is required for each unit.
  ( "unitname" is the name of unit you wish to be in the overlay )
   Make sure THIS unit is in your uses clause!
  Compile to disk (cannot run in memory).

          *****  NOTE : This unit MUST NOT be overlaid! *****

  Initial buffer size can be set by changing:  OverlayBufferSize: longint;
────────────────────────────────────────────────────────────────────────────*)
UNIT ovlinit ;

{ LEAVE next line alone! }
{$O-,I-,F+}

{ modify next line as you wish. }
{$R-,S-,D-,L-,G+,A+}

  INTERFACE

USES Dos, Overlay;

procedure add_ovl_buffer_size(extrasize: longint; add: boolean);

  IMPLEMENTATION

var
  ovr_file_name: pathstr;
  OverlayBufferSize: longint;

procedure RemapMemory;
{──────────────────────────────────────────────────────────────────
        MOVE "OVRHEAPORG" & "OVRHEAPEND" TO TOP OF MEMORY.
 ──────────────────────────────────────────────────────────────────}
begin
   HeapOrg:= Ptr(OvrHeapOrg, 0) ;
   HeapPtr:= HeapOrg ;
   FreeList:= HeapOrg ;
   OvrHeapOrg:= PrefixSeg + MemW[pred(PrefixSeg):3] - OverlayBufferSize div
16;   while (OverlayBufferSize MOD 16) <> 0 do inc(OvrHeapOrg);
   OvrHeapPtr:= OvrHeapOrg;
   OvrHeapEnd:= OvrHeapOrg + OverlayBufferSize div 16;
   HeapEnd:= Ptr(OvrHeapOrg, 0);
end ;

procedure InitOverlays(ovr_name: pathstr);
 {────────────────────────────────────────────────────────────
     ACTIVATE OVERLAYS
  ────────────────────────────────────────────────────────────}
begin
        OvrFileMode := $20;     { Read-Only + Deny-write }
        OvrInit(ovr_name);
        case OvrResult of
          ovrNoMemory: writeln('Not enough memory for overlay!'#7);
          ovrIOerror : writeln('Error reading overlay file!'#7);
          ovrError   : writeln('OVERLAY ERROR!'#7);
        else
         begin
           OvrSetBuf (OverlayBufferSize);
           OvrSetRetry (OvrGetBuf div 3);
           EXIT;
         end;
        end ; { case }
        HALT(1);
end ;

procedure search_for_overlay_file;
 {───────────────────────────────────────────────────────────
         CHECK .EXE FILE DIRECTORY THEN PATH OR QUIT
  ───────────────────────────────────────────────────────────}
var
  dir : dirstr;
  name: namestr;
  ext : extstr;

begin
  if Lo (DosVersion) > 2 then ovr_file_name := system.ParamStr(0)
        else  { get dos version or quit }
                begin
                  write('Yuck...dos version less than 3.0'+ #13#10#7);
                  halt(1);
                end;
  ovr_file_name:= FExpand(ovr_file_name); { get full path name of exe file }
  FSplit(ovr_file_name, Dir, Name, Ext) ; { split it up }
  ovr_file_name:= FSearch(Name + '.OVR', Dir);{ ovr_file_name.EXE = 
ovr_file_name.OVR }
  if ovr_file_name = '' then { if not found, check PATH }
           ovr_file_name:= FSearch(Name + '.OVR', GetEnv('PATH')) ;
  if ovr_file_name = '' then { if still not found, quit }
         begin
            writeln('Overlay not found in current directory or on PATH'#7);
            halt(1);
         end;
  ovr_file_name := FExpand(ovr_file_name) ;
end;

procedure add_ovl_buffer_size(extrasize: longint; add: boolean);
{────────────────────────────────────────────────────────────
     ___,/|
     \ o_o|    Set boolean to true for addition to buffer -
     =(_|_)=
     /   |    set to false for subtraction.
    /      \
────────────────────────────────────────────────────────────}
  begin
        case add of
          true:
                begin
                  OvrSetBuf(OvrGetBuf+ExtraSize);
                  if OvrResult = OvrError then exit;
                end;
          false:
                begin
                  OvrSetBuf(OvrGetBuf-ExtraSize);
                  if OvrResult = OvrError then exit;
                end;
        end;{case}
  end;{procedure}

BEGIN  { * INIT * }
         OverlayBufferSize := 16000; { adjust as needed,
                                   if performance is sluggish make bigger }
         Search_for_overlay_file;
         if OvrGetBuf > 0 then
         begin
            RemapMemory ;
            InitOverlays(ovr_file_name) ;
         end;
END.  { * END INIT * }
