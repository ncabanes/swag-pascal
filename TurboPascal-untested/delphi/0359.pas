{--------------------------------------------------------------
Copyright (c) 1996-97 Massimo Maria Ghisalberti
CopyRight (c) 1996-97 MAx!
CopyRight (c) 1996-97 Objects Built for you! (O.B.you!)
Internet EMail: roentgen@mbox.vol.it

MODULO:    CrtDll.pas
           Interface fo the crtdll.dll Microsoft c runtime library

VERSIONe:  1.0 Freeware.
         
Data iniziale : 11/8/97

NOTE: If you use this code, please mention O.B.you!
      somewhere in your program
--------------------------------------------------------------}

unit CrtDll;



interface

uses SysUtils,Windows;

const MSCrtDll = 'crtdll.dll';

const _MAX_PATH   =260;
const _MAX_DRIVE  =3;
const _MAX_DIR    =256;
const _MAX_FNAME  =256;
const _MAX_EXT    =256;

const CLK_TCK     =1000.0

type size_t = cardinal;
type TbsearchFunc = function (arg1,arg2 :Pointer):integer;
type TqsortFunc = function (arg1,arg2 :Pointer):integer;
type TcMemHeap = Pointer;
type TClock_t = cardinal;

type Div_t = record
  quot :integer;
  rem  :integer;
end;
type lDiv_t = Div_t;


type TDFree = record
  total_clusters :cardinal;
  avail_clusters :cardinal;
  sectors_per_cluster :cardinal;
  bytes_per_sector :cardinal;
end;
type PDFree = ^TDFree;

procedure abort;
function  abs(value :integer):integer;cdecl;
function  atexit(ExitFunc :Pointer):integer;cdecl;
function  atof(value :PChar):double;cdecl;
function  atoi(value :PChar):integer;cdecl;
function  atol(value :PChar):integer;cdecl;
function  itoa(value :integer;text :string;radix :integer):PChar;cdecl;
function  bsearch(_key,_base :Pointer;_nmemb,_size :size_t;SFunc :TbsearchFunc):Pointer;cdecl;
function  calloc (nitems, size :size_t):TcMemHeap;cdecl;
function  cdiv(_numer,_denom :integer):Div_t;cdecl;
function  cldiv(_numer,_denom :integer):lDiv_t;cdecl;
procedure cexit(status :integer);cdecl;
procedure cfree(heap :Pointer);cdecl;
function  getenv(env :PChar):PChar;cdecl;
function  labs(int :integer):integer;cdecl;
function  malloc(size :size_t):TcMemHeap;cdecl;
function  lrot(val :cardinal;count :integer):cardinal;cdecl;
function  rotl(val ,count :word):word;cdecl;
procedure qsort(base :Pointer; nmemb,size :size_t; qsortFunc :TqsortFunc);cdecl;
function  rand:integer;cdecl;
function  realloc(block :TcMemHeap;size :size_t):TcMemHeap;cdecl;
procedure srand(arg :cardinal);cdecl;
function  system(command :PChar):integer;cdecl;
function  putenv(env :PChar):integer;cdecl;
//function  setenv(str,value :PChar;overwrite :integer):integer;cdecl;
procedure splitpath(path,drive,dir,name,ext :PChar);cdecl;
procedure fnsplit(path,drive,dir,name,ext :PChar);cdecl;
function  strrev(Prima:PChar):PChar;cdecl	;
function  cstrlen(STringa :PChar):integer;cdecl;
function  strtok (str1 :PChar;const str2 :PChar):PChar;cdecl;
function  searchenv(const FileName, VarName, Buff :PChar):PChar;cdecl;
function  clock:TClock_t;cdecl;
function  dup(Handle :THFile):THFile;
function  dup2(NewHandle, OldHandle :THFile):THFile;cdecl;
function  fullpath(Buff ,const Path :PChar; BuffLn :integer);cdecl;
function  getdrive:integer;cdecl;
function  getdrives:cardinal;cdecl;
function  getdiskfree(DriveNum :cardinal, dtable :PDFree);cdecl;
function  getpid;cdecl;

var HMsCrtDll :THandle;

implementation

procedure abort;external MSCrtDll name 'abort';
function  abs;external MSCrtDll name 'abs';
function  atexit;external MSCrtDll name 'atexit';
function  atof;external MSCrtDll name 'atof';
function  atoi;external MSCrtDll name 'atoi';
function  atol;external MSCrtDll name 'atol';
function  itoa;external MSCrtDll name 'itoa';
function  bsearch;external MSCrtDll name 'bsearch';
function  calloc;external MSCrtDll name 'calloc';
function  cdiv;external MSCrtDll name 'div';
function  cldiv;external MSCrtDll name 'ldiv';
procedure cexit;external MSCrtDll name 'exit';
procedure cfree;external MSCrtDll name 'free';
function  getenv;external MSCrtDll name 'getenv';
function  labs;external MSCrtDll name 'labs';
function  malloc;external MSCrtDll name 'malloc';
function  lrot;external MSCrtDll name '_lrot';
function  rotl;external MSCrtDll name '_rotl';
procedure qsort;external MSCrtDll name 'qsort';
function  rand;external MSCrtDll name 'rand';
function  realloc;external MSCrtDll name 'realloc';
procedure srand;external MSCrtDll name 'srand';
function  system;external MSCrtDll name 'system';
function  putenv;external MSCrtDll name '_putenv';
//function  setenv;external MSCrtDll name 'setenv';
procedure splitpath;external MSCrtDll name '_splitpath';
procedure fnsplit;external MSCrtDll name '_splitpath';
function  strrev;external MSCrtDll name '_strrev';
function  cstrlen;external MSCrtDll name 'strlen';
function  strtok;external MSCrtDll name 'strtok';
function  searchenv;external MSCrtDll name '_searchenv';
function  clock:external MSCrtDll name 'clock';
function  dup:external MSCrtDll name 'dup';
function  dup2:external MSCrtDll name 'dup2';
function  fullpath:external MSCrtDll name '_fullpath';
function  getdrive;external MSCrtDll name '_getdrive';
function  getdrives;external MSCrtDll name '_getdrives';
function  getdiskfree;external MSCrtDll name '_getdiskfree';
function  getpid;external MSCrtDll name '_getpid';
end.

