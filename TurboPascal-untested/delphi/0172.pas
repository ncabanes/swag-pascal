
{ SEE BELOW FOR ENTIRE PROJECT USING THIS INTERFACE }
(* DLL can be found at: http://quest.jpl.nasa.gov/Info-ZIP/             *)

UNIT WizUnZip;

(*                                                                      *)
(* AUTHOR: Michael G. Slack                    DATE WRITTEN: 05/17/1996 *)
(* ENVIRONMENT: Borland Pascal V7.0+/Delphi V1.02+                      *)
(*                                                                      *)
(* Unit that defines the interface into the wizunzip dll.               *)
(* NOTE: File names are case-sensitive.                                 *)
(*                                                                      *)
(* To use:                                                              *)
(*  VAR _DCL  : PDCL;                                                   *)
(*      Fils  : PACHAR; {pointer to array or pchars}                    *)
(*      ZipFn : ARRAY[0..144] OF CHAR;                                  *)
(*      FilNm : ARRAY[0..xx] OF CHAR;                                   *)
(*    { TT    : THANDLE; }                                              *)
(*       ...                                                            *)
(*  StrCopy(FilNm,'case sensitive file name (could incl wildcards)');   *)
(*  GetMem(Fils,SizeOf(PCHAR)); {only allocating for single file}       *)
(*   {or}                                                               *)
(*   {should use this method in Delphi - seems to prevent GPFs}         *)
(*   { TT := GlobalAlloc(GHnd,SizeOf(PCHAR)); }                         *)
(*   { Fils := GlobalLock(TT); }                                        *)
(*  Fils^[0] := @FilNm;                                                 *)
(*  StrCopy(ZipFn,'C:\UNZIP52.ZIP');                                    *)
(*  WZInitADCL(_DCL,HInstance,MWnd,LWnd); {create/initialize struct}    *)
(*  WITH _DCL^ DO                                                       *)
(*   BEGIN {setup rest of parameters for unzip}                         *)
(*    WITH lpUMB^ DO                                                    *)
(*     StrCopy(szUnzipToDirName,'some dir'); {only dir that is used}    *)
(*    {set flags wanted (all set to false from init)}                   *)
(*    OverWrite := TRUE; {example}                                      *)
(*    ArgC := 1; {set equal to number of files submitting}              *)
(*    lpszZipFN := @ZipFn;                                              *)
(*    FNV := Fils;                                                      *)
(*   END; {with}                                                        *)
(*  I := WZ_UnZip(_DCL); {run unzip proc}                               *)
(*  WZDestroyDCL(_DCL); {release control block}                         *)
(*  FreeMem(Fils,SizeOf(PCHAR)); {free file list}                       *)
(*   {or}                                                               *)
(*   { GlobalUnlock(TT); }                                              *)
(*   { GlobalFree(TT); }                                                *)
(*  IF I <> wze_OK THEN {problem with unzip};                           *)
(*                                                                      *)
(* -------------------------------------------------------------------- *)
(*                                                                      *)
(* REVISED: 07/30/1996 - Per suggestions from Brad Clarke               *)
(*                       (bclarke@cyberus.ca), added listing constants  *)
(*                       and changed nzFlag to integer.                 *)
(*                                                                      *)

INTERFACE

 USES WinTypes, WinProcs, CommDlg;

 CONST LibName = 'wizunz16';
       wzl_WizUnzip_Max_Path  = 127; {128}
       wzl_Options_Buffer_Len = 255; {256}
       wzl_None               = 0;   {no listing}
       wzl_Short              = 1;   {short listing}
       wzl_Long               = 2;   {long listing}
       wze_OK                 = 0;
       wze_Warning            = 1;
       wze_Err                = 2;
       wze_BadErr             = 3;
       wze_Mem                = 4;
       wze_Mem2               = 5;
       wze_Mem3               = 6;
       wze_Mem4               = 7;
       wze_Mem5               = 8;
       wze_NoZip              = 9;
       wze_Param              = 10;
       wze_Find               = 11;
       wze_Disk               = 50;
       wze_EOF                = 51;

 TYPE PUMB = ^TUMB;
      TUMB = RECORD
              {fully qualified archive name (OEM chars)}
              szFileName          : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {directory with archive (ANSI chars)}
              szDirName           : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {extraction directory "unzip to" (ANSI chars)}
              szUnzipToDirName    : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {temp extraction dir "unzip to" (ANSI chars)}
              szUnzipToDirNameTmp : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {extraction directory "unzip from" (ANSI chars)}
              szUnzipFromDirName  : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {text for totals of zip archive}
              szTotalsLine        : ARRAY[0..79] OF CHAR;
              {scratch buffer}
              szBuffer            : ARRAY[0..wzl_Options_Buffer_Len] OF CHAR;
              {wave file name for sound}
              szSoundName         : ARRAY[0..wzl_WizUnzip_Max_Path] OF CHAR;
              {password for encrypted files}
              szPassword          : ARRAY[0..80] OF CHAR;
              {pointer to szpassword}
              lpPassword          : PCHAR;
              {archive open file name struct (commdlg)}
              ofn                 : TOPENFILENAME;
              {wave file open file name struct (commdlg)}
              wofn                : TOPENFILENAME;
              {???}
              msg                 : TMSG;
              {archive open file struct}
              _of                 : TOFSTRUCT;
              {wave file open file struct}
              wof                 : TOFSTRUCT;
             END;
      TDLLPRNT = FUNCTION{(VAR F : FILE; Len : WORD; S : PCHAR)} : WORD; {CEDCL;}
      TDLLSND  = PROCEDURE; {CEDCL;}
      PACHAR   = ^TACHAR;
      TACHAR   = ARRAY[0..8187] OF PCHAR;
      PDCL = ^TDCL;
      TDCL = RECORD
              PrintFunc         : TDLLPRNT; {ptr to appl print routine}
              SoundProc         : TDLLSND;  {prt to appl sound routine}
              StdOut            : POINTER;  {stdout/ptr to C FILE struct}
              lpUMB             : PUMB;
              hWndList          : HWND;     {list box to disp zip contents in}
              hWndMain          : HWND;     {appl main window}
              hInst             : THANDLE;  {appl instance}
              ExtractOnlyNewer  : BOOL;     {true = extract only newer}
              OverWrite         : BOOL;     {true = always overwrite}
              SpaceToUnderscore : BOOL;     {true = convert space to underscore}
              PromptToOverwrite : BOOL;     {true = prompt on overwrite}
              ncFlag            : BOOL;     {true = write to stdout}
              ntFlag            : BOOL;     {true = test zip file}
              nvFlag            : INTEGER;  {0=no list, 1=short list, 2=long list}
              nuFlag            : BOOL;     {true = update extraction}
              nzFlag            : BOOL;     {true = display zip file comment}
              ndFlag            : BOOL;     {true = extract w/stored directories}
              noFlag            : BOOL;     {true = extract all files}
              naFlag            : BOOL;     {true = ascii-ebcdic/eoln translate}
              ArgC              : INTEGER;  {count of files to extract}
              lpszZipFN         : PCHAR;    {zip file name}
              FNV               : PACHAR;   {list of files to extract}
             END;

(************************************************************************)

 PROCEDURE WZInitADCL(VAR _DCL : PDCL; PInst : THANDLE; MainW, ListW : HWND);
     (* procedure used to alloc and init a dcl struct with zeros *)

 PROCEDURE WZDestroyDCL(VAR _DCL : PDCL);
     (* procedure used to free a dcl allocated by prior call to initadcl *)

 FUNCTION  WZDummyPrint{(VAR FH : INTEGER; Len : WORD; S : PCHAR)} : WORD; {CEDCL;}
     (* procedure that can be used as a dummy print routine for dll *)
     (* - C call back, parameters ignored in dummy                  *)

 PROCEDURE WZDummySound; {CEDCL;}
     (* procedure that can be used as a dummy sound routine for the dll *)

 FUNCTION  WZRetErrorString(ErrC : INTEGER) : STRING;
     (* function used to return error as a string *)

 FUNCTION  WZ_UnZip(_DCL : PDCL) : INTEGER;
     (* wrapper function to handle switching to choosen unzip to directory *)

 (* dll functions ----------------------------------------------------- *)
 FUNCTION  DLLProcessZipFiles(_DCL : PDCL) : INTEGER;
     (* function to run the unzip routine *)

 PROCEDURE GetDLLVersion(VAR Ver : LONGINT);
     (* procedure to return the current dll version of wizunzip *)
     (*   hiword(ver) = major . loword(ver) = minor             *)

(************************************************************************)

IMPLEMENTATION

{$IFDEF VER80}
 USES SysUtils;
{$ELSE}
 USES Strings;
{$ENDIF}

(************************************************************************)

 PROCEDURE WZInitADCL(VAR _DCL : PDCL; PInst : THANDLE; MainW, ListW : HWND);

  BEGIN (*wzinitadcl*)
   GetMem(_DCL,SizeOf(TDCL));
   FillChar(_DCL^,SizeOf(TDCL),0);
   _DCL^.PrintFunc := WZDummyPrint;
   _DCL^.SoundProc := WZDummySound;
   GetMem(_DCL^.lpUMB,SizeOf(TUMB));
   FillChar(_DCL^.lpUMB^,SizeOf(TUMB),0);
   _DCL^.lpUMB^.lpPassword := @_DCL^.lpUMB^.szPassword;
   _DCL^.hWndMain := MainW;
   _DCL^.hWndList := ListW;
   _DCL^.hInst    := PInst;
  END; (*wzinitadcl*)

(************************************************************************)

 PROCEDURE WZDestroyDCL(VAR _DCL : PDCL);

  BEGIN (*wzdestroydcl*)
   IF _DCL = NIL THEN Exit;
   FreeMem(_DCL^.lpUMB,SizeOf(TUMB));
   FreeMem(_DCL,SizeOf(TDCL));
   _DCL := NIL;
  END; (*wzdestroydcl*)

(************************************************************************)

 FUNCTION WZDummyPrint{(VAR F : FILE; Len : WORD; S : PCHAR)} : WORD;
    VAR Len : WORD;
  BEGIN (*wzdummyprint*)
   ASM
    MOV AX,[BP+8] {pass back len as return}
   END;
  END; (*wzdummyprint*)

(************************************************************************)

 PROCEDURE WZDummySound;
    VAR I : INTEGER;
  BEGIN (*wzdummysound*)
   {do nothing}
   I := 1; {so that optimizations do not remove proc}
  END; (*wzdummysound*)

(************************************************************************)

 FUNCTION WZRetErrorString(ErrC : INTEGER) : STRING;

    VAR T : STRING[80];
        N : STRING[5];

  BEGIN (*wzreterrorstring*)
   T := '';
   CASE ErrC OF
    wze_OK      : ;
    wze_Warning : T := 'Warning, zip may have error!';
    wze_Err     : T := 'Error in zipfile!';
    wze_BadErr  : T := 'Critical error in zipfile!';
    wze_Mem     : T := 'Insufficient memory!';
    wze_Mem2    : T := 'Insufficient memory (2)!';
    wze_Mem3    : T := 'Insufficient memory (3)!';
    wze_Mem4    : T := 'Insufficient memory (4)!';
    wze_Mem5    : T := 'Insufficient memory (5)!';
    wze_NoZip   : T := 'Not a zip file/zip file not found!';
    wze_Param   : T := 'Invalid parameters specified!';
    wze_Find    : T := 'No files found!';
    wze_Disk    : T := 'Disk full error!';
    wze_EOF     : T := 'Unexpected EOF encountered!';
    ELSE BEGIN {other error}
          Str(ErrC,N);
          T := 'Other error during zip operation - Error code = '+N;
         END; {else}
   END; {case}
   WZRetErrorString := T;
  END; (*wzreterrorstring*)

(************************************************************************)

 FUNCTION WZ_UnZip(_DCL : PDCL) : INTEGER;
    VAR S1, S2 : STRING[144];
        W      : WORD;
  BEGIN (*wz_unzip*)
   W := SetErrorMode($8001); S1 := '';
   GetDir(0,S1); S2 := StrPas(_DCL^.lpUMB^.szUnzipToDirName);
   IF S2[Length(S2)] = '\'
    THEN BEGIN {remove '\'?}
          IF (Length(S2) > 1) AND (S2[Length(S2)-1] <> ':')
           THEN Delete(S2,Length(S2),1); {not 'c:\'}
          IF Length(S2) = 1 THEN S2 := '';
         END; {then}
   IF S2 <> ''
    THEN {$I-} ChDir(S2) {$I+}
   ELSE S1 := '';
   IF IOResult <> 0
    THEN BEGIN {error in ch dir}
          MessageBeep(mb_OK);
          MessageBox(_DCL^.hWndMain,'Could not set "unzip-to" directory!',NIL,
                     mb_OK OR mb_IconStop);
          S1 := '';
         END; {then}
   SetErrorMode(W);
   WZ_UnZip := DLLProcessZipFiles(_DCL);
   IF S1 <> '' THEN ChDir(S1);
  END; (*wz_unzip*)

(************************************************************************)

 FUNCTION DLLProcessZipFiles(_DCL : PDCL) : INTEGER;
  EXTERNAL LibName INDEX 1;

 PROCEDURE GetDLLVersion(VAR Ver : LONGINT);
  EXTERNAL LibName INDEX 3;

(************************************************************************)

END. (*of unit*)

{ Cut this out to a file :  Name it TESTDLL.XX and use XX3402 to decode }
{ TESTDLL.ZIP will be created }


*XX3402-003539-250896--72--85-21555-----TESTDLL.ZIP--1-OF--1
I2g1--E++++6+1lSlW-H15rKQU2++7w1+++A++++JItOLpF3IpEiF3B9bJ9jHw6k2DqyNDw8
OOT6Nf6DC30K+0tiC6IFIpa3maWLIY9wvyoDlWOFFDlohrhjvxvpPXN0V8O2takzhuq+MmGk
1qrfaKn7Su5HK8UOg8oVzV+e7elI6GKtKDYiYCY+YyJ8y3vPhalf3b3KMWuyEfchwI6kTd4m
puaYcSgSdOx+Fqhr0v8Y4ol3V+cg-8uZERLvIzMQ6MeKiB5Mc0YGWxLdh+OuYlzfYV2eTgQ1
J-HGvq7x-aOPYZ5dOri8X3Wy8v+iglqJYxWK8E2ziApuzK2o09DcuT2Vnd7yb4GHwHGAob1Q
WfdlFMIBuaEQ7b4KVZBBP98Qgs7j8abpcWTPuiTYA84l+vL7SwMrE3dIoKn3p4gqyBgGcPc-
hIPcL3RvP5hSjQQPJzqBxwT505OQmrRHBOKW6eUGO5fVjSAvqcx4txL+WWNzrn9yccUaTJKd
R1+YJDhHhU7K5+PGefI+z7S+Ikgs3kjc4qnQkybtzI0y+J-9+kEI++++0++PMwMUYSZmW+k0
++1w+k++1++++3JCKYZEJoZC9YF4HMKGnqvHE-14BnOl5HgBEHk+tV7-1ZLHLbfVE28WFadf
en2exBFhD4ZKrSlOuorXc1k+Xk7jkbBktcMskzdD2XSWQD5gf1rTxxArzaqXMC-Rb5LEETC5
XZ1U1kuAMA13f3DBbYxCMG9pPoUDS8HVuWI7tJFjOwM7YBidp3xIn-uC7C5Ag8x6t+MEGl1q
U1CtryCI0vAyddS2VLkFE08Rv2IyezqgNRotbc3VX7NeQ7MDXiGGUcDqT76+XLoEEnOSOhS4
loNHjX0h30kxqOZY6RN2Nh0RGwaNaNSQL9Amw4MCfbogi9KL4ylOmsi+iEfS0j0B7o6E4X6x
peBYT4TK0v4gEvgSVqKDswQxbBNvxYaZAm+In1v1BlF0OqhLqPIvz9jRIRbiyb4vOfyJ29bJ
prPpXkdx8nUZgSnml0de2JdI1YrzKZZjyngePxMQomv3svg5GzpJKefHsrB-E9Xbg5WkqQOE
GPUJaCN1BLicRZw6B4kT0q+mzPuIYMuE2uGPSYQktPTCxhUlJ8kGVD5aecUsRZypxpLSfpRN
KTIzxBAPG00xIKLpZh9hZyrohapuKLWloy0H2l90-S1EMrHtZ2xw98RbwpXq2tKGuhD7HMye
+N2IX9rpPtE7ZnOZToMdykXTEw4yDKvMbzy9u-aTSDQU3c76w+KTFT6zX4iaSifYHdGg8rYN
uMh0Ebw+I2g1--E++++6+A7dlW+8jsNkq++++2Y-+++A++++JItOLpF3IpEiHp-IHMrBHgAk
26HjZjki--+e6-yUcO8We85VJmo5squOJFDPQak7wTFsT659O9uNLQpqvYPD+sJD8KtI7QKh
Cd4WVZj+9S2S60h6+rZ0gM4ok4Ss3vVLi1T6Cz+16gJqlTNM-VupLyEh500vHJp5+IQpTOL1
obMCpRd55ja5vfv9NFipCPONJLJlBXiLsduo9nmf9Yz9EAq-H5G-OQcfulFxWXZHyNZoA5qX
MuzApKtDUyxttsAvHBRzb0n5znn3Y2lCd7UviyT6nidVIaKeoI4D30ZUONBgMLGzI2g1--E+
+++6+A3dlW+wkkvzaE+++Aw++++A++++JItOLpF3IpEiF3-G8mX8Hmx8n3I6nMi81oYh9f5a
tS9Z8WpC9SPZIZ-kmmz89RM-gM1GaELVaLY8E8ESuVTZ4F1iuOQLs-WgfZ+BIaJM0xNMfF8Y
c8ILt-dQ0y6ZdONbtc3oClMIt4Ea7tNYtiTdVKGKt8EeKBYee+BBJ+-NaJeYPcqimfYcBP2Y
3KGmFUXMT-qkMkkpAJE4ZSM-lJ9nIjF+JU6+I2g1--E++++6+A7dlW+MwyXnH+2++-c1+++A
++++JItOLpF3IpEiIYJHdNCzHgAk26QjHRJaW2U5RX6mgdIB20kR88z+pcuF8V3jK26WTUkS
lExUtFYuAYFFdcOVsfVnvHG-PdnpQznR5nil9VU0-X0PTMs+9U2U7RqG+VW1hF4QBCYauFPG
UROO5V8ErHGVKu+1N2TIegp4hCeeLOqtbbUyjqtJRiHzl7IrmOmUmBYwWnxlI4UnQZjD4mcI
LRly9Xa8LAWRS1wkCz6WKFJe1RuVgdr66dx+1UfHgSjimbPWNH87V2yEew9aDLSLCbtUul-A
FQDoiGefegCsf4dHaluPojHmsv9YX4Axgx2xBZJR5V3WAkXHUTKE8E243jRqDpHwsY4tgmp+
QYcI0fqcPheEPoyWXdaW1hukUE1rckzQ7kpyQnjdw01NYtuG2gHh-K71yfd-z0MVulLNni1l
Pf3Qr1wheTDDvHg3BB7oNjiSzsI+TU-EGkA23+++U+U+gPIJ6SRvU66e-E++5Es+++k+++-J
HZd7I3R7HWtEEJCpJypjqXUMzpudzwDnsGFUZuLEHOQHL8RFG2co-UXGeoOjJtZUk7ilAxjd
0pLzxvCREA99fHjR3cb4TZtyTjmwdUYX0WvNaAFLV1KCXsuDmezUVnmj8VMfl39-DK3HTUwn
9c+kVQIAFRWgiCOg2fOezSNC8ML76uW3MQnsulK7MGts2fgtJfjPVEUla4+BZP+d63K5VJ7l
zSHYOu6DQXz5p4J66bTCvos0UnAC-WS5vDcVXw2uDhdQmKkGWSLl2Q1cIJseEeI1qf5VMsnH
pI1kG8wyMWbFrB-O32Zd3VQ0lEhWa0rCZC-OpS1sL0kpfIoEtLCx48ZdGsYIRrL7h7hgp7Ey
kMW5Ffs4Nl+Nr99RJUk1s1lFWfBO5Q7opGWGHkyHrymGioGeQztUI97ZliX5a8J44ZuymxUX
R6RnRfv9q93q0tsa+hjvXVPwjXn0P6e3kNdwld4ev2ZaxqZF2brtLibHzmHxtVjGgG-rGC3I
wEY4uFOaK1hS62IsYz-g-NC7Fhb6qRo-ALq41SER2iik4ozNhqKENInl2XBZhEnZuNQVj59P
zgRbgwiBHtLQPrZmUiR2Mo+LnlHInu-KPI16sqltT9GqNUzoCtmiPk-X2jgAuh+Q1diTfeii
KrjvxUPuDfEunK5aPTrQhZhRo461zQudUTpPVu+LSVTSg4-is-TnnDISQ7GYAEUvLUzCjMiU
hs5Nt8cP89mIPchW7D7HM8H2cALXlv6ppWY0ysHW5ZfWGY5wOVkkcdfOof6lqyY2H0f26ilo
27hGv4mCGzRPiY5MgNTx4xfxb7kO12wGemE4MHcZbo4AV1tOMG3hkolAXMDWE1LyQo2NO0lL
ljOS0RhvSsj0aE1gneRcPdXr8rcvKb0V4jckwvNUVAq9S3ujfRbrF0o8pA0cLspjvMWk3uxc
6N4kn0uH6+Ller3Pro9klvKPWZvEoRgB0IyMUbRE9NVl877fRuIpv5cAHGWS4hD0sOKrRSbx
m+RgWVyAP5JDI3wt7rbRYLTc09yd4PaeQRC9-T9BDaA8l0TIUP0aTuREVp2s15cLilI+SrKE
YLmzm5uVljF7AVQSB9StOO3y7pFOfVicfO6Bku7BMOTNOrSxEiZeAsknRl7Ud+FVQrax5v0P
FetYexFsvDFrdsjNL0rAfZ7dKCyR4P34LguyvsGbphJyTtUaQ2p5+17BnQi8AD0pzbJk+qRE
CWaZWNQGh2fdft8-04hasnocUG8pPUjZ1BxWNuCwHSTZYdr5w-d8jyfE9ZK9glYFGxikbSjZ
dASRtSEHZXRCBRLrBQETvq+dB12xrrgUmf+8wr9HXKmypn93cg1-DUVDQusUFZjZzAENTEF2
8MyEeLzPMOFSI+knTIl-J+RIbrR-yEHFdZ2cLrHMp-aF3SvDmUCH4NJWRRgwqqVoSTGZ56Mu
FBgGTpxLfLjTyztDPAJJouEWUN507oG9OWlhBYUZYeXMEzxrLxvellOBldQTnrTU0VSIuHRP
mBh2a4gtVREOu3WJ1kJymww+zHggfUFFy4+1P6dtmyNwkps+wBQ2IHAzK98QM43iMW6hEGOH
7J4vIy13eS9rzgleHVPdDqZuU-P530C76IczWq30STGZc7Iar0KXatEnWHsHC2rdrPaNWjiO
jNiTur8wLy5PzcTRYPFTtnB2n6UktLsp5a9Z0Q33qh58EQJNdUFHyDoDdiFrFgoyc2mWG-B9
KhLwvp9c50b+xV007vL+vDb3KTHjLv5frhmWLC90IBBjpvnz+J-9+E6I+-E++++6+1lSlW-H
15rKQU2++7w1+++A++++++++++2+6+++++++++-JHZdTJ2JHJ0t2IohEGk203++I++++0++P
MwMUYSZmW+k0++1w+k++1++++++++++-+0++++0Q+E++JItOGJ-LGIsiF2NBI2g-+VE+3+++
++U+kab46+ezVb1M++++GE2+++k++++++++++E+U++++oUA++3JCKZxIFJBI9YxEJ3-9+E6I
+-E++++6+A3dlW+wkkvzaE+++Aw++++A++++++++++2+6++++BE2++-JHZdTJ2JHJ0t2I37E
Gk203++I++++0+10OQMU4DDcwok-+++O+k++1++++++++++++0++++0L-E++JItOLpF3IpEi
IYJHI2g-+VE+3+++++U+gPIJ6SRvU66e-E++5Es+++k++++++++++E+U++++1EQ++3JCKYZE
JoZC9Z--Ip-9-EM+++++-U+4+3k-++-V1+++++++
***** END OF BLOCK 1 *****

