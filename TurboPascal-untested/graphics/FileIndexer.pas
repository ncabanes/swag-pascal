(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0288.PAS
  Description: File Indexer
  Author: MIGUEL_ANGEL
  Date: 01-02-98  07:35
*)


{ Demo at the end of this unit }

{
  Program by         Miguel Angel Candón
  Last revision date 09-01-93
  miguel_angel@jet
}
(*

   First, excuse me, I don't speak english.


  1024 bytes per page,
     Max keys in page = 1014 div (4+LenKey)
     Min keys in page = Max keys in page div 2
     Every key (if not level 0), have another key page
     One page reserved for swaps.

  if (LenKey = 10) and (PagesInMemory = 16) the index file can
  have 36^14 keys up to 72^14.

  MaxPagesInMemory : 4..63 = 16;  { Levels per index file }

   Return:
     RecIndex : LongInt  ==> rec number in data file
     ErrIndex : word     ==> if <> 0 => errors ...

procedure OpenIndex( var CualIndex:PtrIndex; const NomFile:PathStr );
procedure CreateIndex( var CualIndex:PtrIndex; const NomFile:PathStr;
CualKeyLength:byte );
procedure FindKey( CualIndex:PtrIndex; Clave:string );
procedure FindKeyRecNo( CualIndex:PtrIndex; const Clave:string;
RecNo:LongInt );
procedure NextKey( CualIndex:PtrIndex; SearchNextNotFound:boolean );
procedure PrevKey( CualIndex:PtrIndex; SearchNextNotFound:boolean );
procedure InsKey( CualIndex:PtrIndex; Clave:string; RecNo:LongInt );
procedure CloseIndex( var CualIndex:PtrIndex );
procedure DelKey( CualIndex:PtrIndex; Clave:string; RecNo:LongInt );
procedure ReplaceKey( CualIndex:PtrIndex; const OldClave,NewClave:string;
RecNo:LongInt );
procedure FindFirstKey(CualIndex:PtrIndex);
procedure FindLastKey(CualIndex:PtrIndex);

procedure ShortIntToKey( valor:ShortInt ; var Salida:Char );
procedure ByteToKey( valor:byte ; var Salida:Char );
procedure IntegerToKey( valor:integer ; var Salida:Char2 );
procedure WordToKey( valor:word ; var Salida:Char2 );
procedure LongIntToKey( valor:LongInt ; var Salida:Char4 );

*)

{$A+,B-,D-,E-,F-,G+,I+,L-,N-,O-,P+,Q-,R-,S-,T-,V-,X+,Y-}

unit
  SwagIdx;

interface

uses
  memory,dos;

const
  Version = $0202;

  MaxPagesInMemory : 4..63 = 16;  { Leves per index file }
  MaxKeyLength = 100;

  IndexRetryCount : word = 10;   { Shared retry }
{  IndexRetryDelay : word = 1;    }

  ErrIndex : word=0;
  RecIndex : LongInt=0;

  ErrIndexFound       = $0000;
  ErrIndexNotFound    = $0001;
  ErrIndexBig         = $0002;
  ErrIndexEOF         = $0010;
  ErrIndexBOF         = $0011;
  ErrIndexOtherKey    = $0004;
  ErrIndexNoKeys      = $00FF;

  ErrIndexShared      = $1000;
  ErrIndexRead        = $1100;
  ErrIndexWrite       = $1200;
  ErrIndexFileNoOpen  = $1300;
  ErrIndexNoMemory    = $FFFF;
  ErrIndexTooManyKeys = $FEFE;

type
  char2   = array[1..2] of char;
  char4   = array[1..4] of char;
  Char255 = array[1..255] of char;
const
  SizeOfResto = 1024-10;
type
  RegPageIndex = record
    Nivel:byte;
    RecActual:byte;
    OfsResto:word;
    NPage:LongInt; { Rec number in FIndex }
    KeysInPage:word;
    resto:array[0..SizeOfResto-1] of byte;
          { RecNo + clave | RecNo + clave ... }
          { if RecNo = -1 => deleted }
  end;
  RegAuxBufIndexHead = record
    NumKeys,
    NumDelKeys,
    FirstPage,
    LastPage:LongInt;
  end;
  RegBufIndex=record
    NumKeys:LongInt;
    NumDelKeys:LongInt;
    FirstPage,
    LastPage:LongInt;
    KeyLength:word;
    CualVersion:word;
    FIndex:file;
    MaxKeysInPage:word;
    TotKeyLength:word;
    PageActual:byte;     { from 1 to PagesInMemory }
    SeBloquea:boolean;
    PtrClave:pointer;
    SizeCualIndex:word;
    PagesInMemory : 4..63;
    ModPages:array[0..63] of boolean;
    Pages:array[1..63] of RegPageIndex;
  end;
  PtrIndex = ^RegBufIndex;

procedure OpenIndex( var CualIndex:PtrIndex; const NomFile:PathStr );
procedure CreateIndex( var CualIndex:PtrIndex; const NomFile:PathStr;
CualKeyLength:byte );
procedure FindKey( CualIndex:PtrIndex; Clave:string );
procedure FindKeyRecNo( CualIndex:PtrIndex; const Clave:string;
RecNo:LongInt );
procedure NextKey( CualIndex:PtrIndex; SearchNextNotFound:boolean );
procedure PrevKey( CualIndex:PtrIndex; SearchNextNotFound:boolean );
procedure InsKey( CualIndex:PtrIndex; Clave:string; RecNo:LongInt );
procedure CloseIndex( var CualIndex:PtrIndex );
procedure DelKey( CualIndex:PtrIndex; Clave:string; RecNo:LongInt );
procedure ReplaceKey( CualIndex:PtrIndex; const OldClave,NewClave:string;
RecNo:LongInt );

procedure FindFirstKey(CualIndex:PtrIndex);
procedure FindLastKey(CualIndex:PtrIndex);

procedure ShortIntToKey( valor:ShortInt ; var Salida:Char );
procedure ByteToKey( valor:byte ; var Salida:Char );
procedure IntegerToKey( valor:integer ; var Salida:Char2 );
procedure WordToKey( valor:word ; var Salida:Char2 );
procedure LongIntToKey( valor:LongInt ; var Salida:Char4 );


procedure UnLockFileIndex( CualHandle:word );
function LockFileIndex(CualHandle:word):boolean;

procedure MyGetMem(var puntero:pointer; Tamano:word; ValorRelleno:byte);
procedure MyFreeMem(var puntero:pointer; Tamano:word);
function Equal(var Comparando1,Comparando2; Tamano:word):boolean;

implementation

const
  IsLockFileIndex : boolean = false;
type
  MaskPtr = record
    xOffset,xSegment:word
  end;
  MaskLong = record
    LoWord, HiWord : word
  end;
  MaskWord = record
    LoByte, HiByte : byte
  end;

procedure MyGetMem(var puntero:pointer; Tamano:word; ValorRelleno:byte);
begin
  if Lo(Tamano) and $0F<>0 then
    Tamano := (Tamano and $FFF0) + $10;
  if LongInt(Tamano) > MaxAvail then
    RunError(203)   { Heap Overflow Error }
  else
    begin
      if Tamano > 65528 then
        RunError(203);  { Heap Overflow Error }
      Puntero := MemAllocSeg(Tamano); { GetMem(Puntero,Tamano); }
      fillchar( Puntero^, Tamano, ValorRelleno )
    end;
end;

procedure MyFreeMem(var puntero:pointer; Tamano:word);
begin
  if puntero <> nil then
    begin
      if MaskWord(Tamano).LoByte and $0F<>0 then
        Tamano := (Tamano and $FFF0) + $10;
      FreeMem(Puntero,Tamano);
      Puntero:=nil;
    end
end;

procedure ShortIntToKey( valor:ShortInt ; var Salida:Char ); assembler;
asm
  mov  al,valor
  cmp  al,80h
  jb   @@ShortIntToKeyPositivo
  not  ax
  inc  al
  jmp @@EndShortIntToKey
@@ShortIntToKeyPositivo:
  or  al,80h
@@EndShortIntToKey:
  les  di,Salida
  stosb
end;

procedure ByteToKey( valor:byte ; var Salida:Char ); assembler;
asm
  mov  al,valor
  les  di,Salida
  stosb
end;

procedure IntegerToKey( valor:integer ; var Salida:Char2 ); assembler;
asm
  mov  ax,valor
  cmp  ah,80h
  jb   @@IntegerToKeyPositivo
  not  ax
  inc  ax
  jmp @@EndIntegerToKey
@@IntegerToKeyPositivo:
  or  ah,80h
@@EndIntegerToKey:
  xchg al,ah
  les  di,Salida
  stosw
end;

procedure WordToKey( valor:word ; var Salida:Char2 ); assembler;
asm
  mov  ax,valor
  xchg al,ah
  les  di,Salida
  stosw
end;

procedure LongIntToKey( valor:LongInt ; var Salida:Char4 ); assembler;
asm
  mov  ax,MaskLong(valor).HiWord
  mov  dx,MaskLong(valor).LoWord
  cmp  ah,80h
  jb   @@LongIntToKeyPositivo
  not  ax
  not  dx
  inc  dx
  jnc  @@EndLongIntToKey
  inc  ax
  jmp @@EndLongIntToKey
@@LongIntToKeyPositivo:
  or  ah,80h
@@EndLongIntToKey:
  xchg al,ah
  xchg dl,dh
  les  di,Salida
  cld
  stosw
  mov  es:[di],dx
end;


function Equal(var Comparando1,Comparando2; Tamano:word):boolean;
assembler;
asm
  mov  al,false
  push ds
  cld
  mov  cx,Tamano
  les  di,Comparando1
  lds  si,Comparando2
  repe cmpsb
  jne  @@NoEqual
  mov  al,True
@@NoEqual:
  pop  ds
end;


procedure WritePage(CualIndex:PtrIndex; CualPage:byte);
begin
  with CualIndex^ do
    if Pages[CualPage].NPage>0 then
      begin
        seek(FIndex,Pages[CualPage].NPage);
        BlockWrite(FIndex,Pages[CualPage],1);
        ModPages[CualPage]:=false
      end
end;

procedure GetEmptyPage(CualIndex:PtrIndex; DondeLeer:byte);
var
  AuxBucle:byte;
begin
  with CualIndex^ do
    begin
      inc(LastPage);
      Pages[DondeLeer].NPage:=LastPage
    end
end;

function LockFileIndex(CualHandle:word):boolean;
var
  Intentos:word;
  HayError:boolean;
begin
  Intentos:=0;
  repeat
    HayError:=false;
    asm
      mov  ax,5C00h
      mov  bx,CualHandle
      xor  cx,cx
      mov  dx,cx
      mov  si,cx
      mov  di,16
      int  21h
      jnc  @@LockFileIndexOk
      mov  HayError,True     { If AL=1 => Invalid function code, =6 Invalid
handle, 33 File-Locking violation }
@@LockFileIndexOk:
    end;
    if HayError then
      if IndexRetryCount <> 0 then inc(intentos)
  until (not HayError) or (intentos >= IndexRetryCount);
  IsLockFileIndex := not HayError;
  LockFileIndex := ( not HayError )
end;

procedure UnLockFileIndex( CualHandle:word );
{var                  }
{  Intentos:word;     }
{  HayError:boolean;  }
begin
{ Intentos:=0;
  repeat
    HayError:=false;  }
    asm
      mov  ah,68h         { Commit file }
      mov  bx,CualHandle
      int  21h
      mov  ax,5C01h
      mov  bx,CualHandle
      xor  cx,cx
      mov  dx,cx
      mov  si,cx
      mov  di,16
      int  21h
(*
      jnc  @@UnLockFileIndexOk
      mov  HayError,True     { if AL=1 => Invalid function code, =6 Invalid
handle, 33 File-Locking violation }
@@UnLockFileIndexOk:
*)
    end;
(*
    if HayError then
      if IndexRetryCount<>0 then inc(intentos)
  until (not HayError) or (intentos=IndexRetryCount);
*)
  IsLockFileIndex:=false
end;

procedure LoadPage(var CualIndex:PtrIndex; PageToLeer:LongInt;
DondeLeer:byte );
label
  LeePage;
var
  leidos:word;
  LowLevel:byte;
  PageLowLevel:byte;
procedure ChangePage;
var
  AuxPage:RegPageIndex;
  AuxModPage:boolean;
begin
  with CualIndex^ do
    begin
      AuxPage:=Pages[DondeLeer];
      Pages[DondeLeer]:=Pages[leidos];
      Pages[leidos]:=AuxPage;
      AuxModPage:=ModPages[DondeLeer];
      ModPages[DondeLeer]:=ModPages[leidos];
      ModPages[Leidos]:=AuxModPage
    end
end;
begin   { LoadPage }
  with CualIndex^ do
    begin
      if DondeLeer>PagesInMemory then
        begin
          ErrIndex:=ErrIndexTooManyKeys;
          exit
        end;
      for leidos:=2 to PagesInMemory do
        if PageToLeer = Pages[leidos].NPage then
          begin
            if leidos<>DondeLeer then
              ChangePage;
            exit
          end;
      for leidos:=2 to PagesInMemory do   { find empty page ... }
        if Pages[leidos].NPage = 0 then
          begin
            ChangePage;
            goto LeePage
          end;
      if DondeLeer < PagesInMemory then
        begin
          LowLevel := $FF;
          PageLowLevel := 0;
          for leidos := DondeLeer+1 to PagesInMemory do
            begin
              if Pages[leidos].Nivel < LowLevel then
                begin
                  LowLevel := Pages[leidos].Nivel;
                  PageLowLevel := leidos
                end;
              if (Pages[leidos].Nivel = 0) and (not ModPages[leidos]) then
                begin
                  LowLevel := Pages[leidos].Nivel;
                  PageLowLevel := leidos
                end;
            end;
          if LowLevel <> $FF then
            begin
              leidos := PageLowLevel;
              ChangePage
            end;
        end;
LeePage:
      if ModPages[DondeLeer] then
        WritePage( CualIndex, DondeLeer );
      if PageToLeer >= 0 then
        begin
          seek( FIndex, PageToLeer );
          BlockRead( FIndex, Pages[DondeLeer], 1 )
        end
      else
        fillchar( Pages[DondeLeer], SizeOf(RegPageIndex), 0 )
    end
end;    { LoadPage }

procedure ChkModFile(CualIndex:PtrIndex);
var
  AuxHead  : RegAuxBufIndexHead; { NumKeys , NumDelKeys , FirstPage,
LastPage }
  OfsAuxHead:word;
  Handle:word;
  HayError:byte;
begin
  with CualIndex^ do
    if LockFileIndex(FileRec(FIndex).Handle) then
      begin
        HayError := 0;
        Handle:=FileRec(FIndex).Handle;
        OfsAuxHead:=ofs(AuxHead);

        FileRec( FIndex ).RecSize := 1;
        seek( FIndex, 0 );
        BlockRead( FIndex, AuxHead, SizeOf(RegAuxBufIndexHead) );
        FileRec( FIndex ).RecSize := SizeOf( RegPageIndex );

        if (AuxHead.NumKeys<>NumKeys) or (AuxHead.NumDelKeys<>NumDelKeys)
then
          begin
            move( AuxHead, CualIndex^, SizeOf(RegAuxBufIndexHead) );
           
fillchar(CualIndex^.Pages,SizeOf(RegPageIndex)*PagesInMemory,0);
            LoadPage( CualIndex, FirstPage, 1 );
            PageActual:=1;
            IsLockFileIndex := true
          end
      end
    else
      ErrIndex:=Lo(ErrIndex) + ErrIndexShared
end;

procedure IniciaIndex(CualIndex:PtrIndex; var SeDesbloquea:boolean);
begin
  ErrIndex := Lo(ErrIndex);
  if CualIndex^.SeBloquea then
    begin
      SeDesbloquea:=not IsLockFileIndex;
      if SeDesbloquea then
        ChkModFile(CualIndex)
    end
  else
    SeDesbloquea:=false
end;

procedure FinalizaIndex( CualIndex:PtrIndex; SeDesbloquea:boolean );
var
  Handle:word;
  AuxBucle:byte;
  HayError:byte;
begin
  if CualIndex^.SeBloquea then
    with CualIndex^ do
      begin
        for AuxBucle:=1 to PagesInMemory do
          if ModPages[AuxBucle] then
            WritePage(CualIndex,AuxBucle);
        if ModPages[0] then
          begin
            HayError := 0;
            Handle:=FileRec(FIndex).Handle;

            FileRec( FIndex ).RecSize := 1;
            seek( FIndex, 0 );
            BlockWrite( FIndex, CualIndex^, SizeOf(RegAuxBufIndexHead) );
            FileRec( FIndex ).RecSize := SizeOf( RegPageIndex );
            ErrIndex := Lo(ErrIndex);
            ModPages[0]:=false
          end;
      if SeDesbloquea then
        UnLockFileIndex(FileRec(FIndex).Handle)
    end
end;

procedure CreateIndex(var CualIndex:PtrIndex; const NomFile:PathStr;
CualKeyLength:byte );
var
  AuxWord:word;
begin
  AuxWord :=
SizeOf(RegBufIndex)-(63-MaxPagesInMemory)*SizeOf(RegPageIndex);
  MyGetMem( pointer(CualIndex), AuxWord, 0 );
  if CualIndex = nil then
    ErrIndex:=ErrIndexNoMemory
  else
    begin
      with CualIndex^ do
        begin
          SizeCualIndex := AuxWord;
          PagesInMemory := MaxPagesInMemory;
          if (FileMode and 112) = 0 then
            SeBloquea := false
          else
            SeBloquea := ( FileMode and 112 ) <> 16 ;  { if shared }
          CualVersion := Version;
          KeyLength := CualKeyLength;
          FirstPage := 1;
          LastPage := 1;
          System.assign(FIndex,NomFile);

          rewrite( FIndex, 1 );
{$I-}
          if IOResult<>0 then
            begin
              ErrIndex := ErrIndexFileNoOpen;
              MyFreeMem(pointer(CualIndex),SizeOf(RegBufIndex));
              exit
            end;
{$I+}
          if SeBloquea then
            LockFileIndex( FileRec(FIndex).Handle );

          Pages[2].NPage:=1;

          BlockWrite( FIndex, CualIndex^.Pages[1], SizeOf(RegPageIndex)*2
);
          seek( FIndex, 0 );
          BlockWrite( FIndex, CualIndex^, 20 );

          Pages[1].NPage := 1;
          Pages[2].NPage := 0;

          TotKeyLength := KeyLength+4;
          MaxKeysInPage := SizeOfResto div TotKeyLength;
          if SeBloquea then
            UnLockFileIndex( FileRec(FIndex).Handle );
          close( FIndex );
          reset( FIndex, SizeOf(RegPageIndex ) )
        end;
    end
end;

procedure OpenIndex(var CualIndex:PtrIndex; const NomFile:PathStr );
var
  SaveFileMode:byte;
  AuxWord:word;
begin
  AuxWord :=
SizeOf(RegBufIndex)-(63-MaxPagesInMemory)*SizeOf(RegPageIndex);
  MyGetMem( pointer(CualIndex), AuxWord , 0 );
  if CualIndex=nil then
    ErrIndex:=ErrIndexNoMemory
  else
    with CualIndex^ do
      begin
        SizeCualIndex := AuxWord;
        PagesInMemory := MaxPagesInMemory;
        if (FileMode and 112) = 0 then
          SeBloquea := false
        else
          SeBloquea := ( FileMode and 112 <> 16 ); { if shared }
        System.assign(FIndex,NomFile);
{$I-}
        reset( FIndex, SizeOf(RegPageIndex) );
        if IOResult <> 0 then
          begin
            ErrIndex := ErrIndexFileNoOpen;
            MyFreeMem( pointer(CualIndex), CualIndex^.SizeCualIndex );
            exit
          end;
{$I+}
        if SeBloquea then
          LockFileIndex( FileRec(FIndex).Handle );

        FileRec( FIndex ).RecSize := 1;
        BlockRead( FIndex, CualIndex^, 20 );  { file tail }
        FileRec( FIndex ).RecSize := SizeOf( RegPageIndex );

        TotKeyLength := KeyLength + 4;
        MaxKeysInPage := SizeOfResto div TotKeyLength;

        seek( FIndex, FirstPage );
        BlockRead( FIndex, Pages[1], 1 );
        LastPage := FileSize(FIndex) - 1;
        if SeBloquea then
          UnLockFileIndex( FileRec(FIndex).Handle )
      end
end;

procedure CloseIndex(var CualIndex:PtrIndex);
var
  AuxBucle:byte;
begin
  if FileRec(CualIndex^.FIndex).Mode = fmInOut then
    begin
      with CualIndex^ do
        begin
          for AuxBucle:=1 to PagesInMemory do
            if ModPages[AuxBucle] then
              WritePage(CualIndex,AuxBucle);
          if CualIndex^.ModPages[0] then
            begin
              FileRec( FIndex ).RecSize := 1;
              seek( FIndex, 0 );
              BlockWrite( Findex, NumKeys, SizeOf(RegAuxBufIndexHead) );
            end;
          close( FIndex );
        end;
      MyFreeMem( pointer(CualIndex), CualIndex^.SizeCualIndex );
      CualIndex:=nil
    end
end;

procedure InsKey(CualIndex:PtrIndex; Clave:string; RecNo:LongInt);
var
  AuxWord,AuxBucle:word;
  AuxRecNo,AuxRecPage:LongInt;
  SeDesbloquea:boolean;
procedure MeteKey(CualPagina:word; Donde:word; Replace:boolean; var Clave);
var
  AuxWord:word;
procedure ModifyPagesBefore;
var
  BuscaPage,AuxLong:LongInt;
  SaveDonde:word;
begin
  SaveDonde:=Donde;
  with CualIndex^ do
    begin
      while (donde = Pages[CualPagina].KeysInPage) and (CualPagina > 1) do 
{ modificar página(s) anterior(es) }
        begin        (***************************)
          BuscaPage := Pages[CualPagina].NPage;
          dec( CualPagina );
          donde := 0;
          AuxWord := 0;
          repeat
            move( Pages[CualPagina].resto[AuxWord], AuxLong, 4 );
            inc( donde );
            AuxWord := AuxWord + TotKeyLength
          until (Donde > Pages[CualPagina].KeysInPage) or (AuxLong =
BuscaPage);
          if AuxLong = BuscaPage then
            begin
              AuxWord := AuxWord-TotKeyLength;
              move( clave, Pages[CualPagina].resto[AuxWord], TotKeyLength
);
              move( AuxLong, Pages[CualPagina].resto[AuxWord], 4 );
              ModPages[CualPagina] := true
            end
        end
    end;
  Donde:=SaveDonde
end;
procedure PartePage;
var
  AuxBucle:word;
  AuxClave:Char255;
begin
  with CualIndex^ do
    begin
      LoadPage( CualIndex, -1, PagesInMemory );  (* // *)
(*  //
      if ModPages[PagesInMemory] then
        WritePage( CualIndex, PagesInMemory );
      fillchar( Pages[PagesInMemory], SizeOf(RegPageIndex), 0 );
//  *)
      AuxWord := TotKeyLength * ( MaxKeysInPage div 2 );
      move( Pages[CualPagina], Pages[PagesInMemory], 10 + AuxWord );
      ModPages[PagesInMemory] := true;
      ModPages[CualPagina] := true;
      GetEmptyPage( CualIndex, PagesInMemory );
      Pages[PagesInMemory].KeysInPage := MaxKeysInPage div 2;
      Pages[CualPagina].KeysInPage := MaxKeysInPage -
Pages[PagesInMemory].KeysInPage;
      AuxWord := TotKeyLength * Pages[CualPagina].KeysInPage;
      move( Pages[CualPagina].resto[ (MaxKeysInPage div 2)*TotKeyLength ],
Pages[CualPagina].resto[0], AuxWord );
      fillchar( Pages[CualPagina].resto[AuxWord], SizeOfResto - AuxWord, 0
);
      if donde > Pages[PagesInMemory].KeysInPage then
        begin
          PageActual := CualPagina;
          donde := donde - Pages[PagesInMemory].KeysInPage;
        end
      else
        PageActual := PagesInMemory;
      Pages[PageActual].OfsResto := (donde-1) * TotKeyLength;
      Pages[PageActual].RecActual := donde;
      if not Replace then
        begin
          inc( Pages[PageActual].KeysInPage );
          inc( NumKeys );
          ModPages[0] := true;
          move( Pages[PageActual].resto[Pages[PageActual].OfsResto],
                Pages[PageActual].resto[Pages[PageActual].OfsResto +
TotKeyLength],
                TotKeyLength*(Pages[PageActual].KeysInPage - donde));
        end;
      move( clave, Pages[PageActual].resto[Pages[PageActual].OfsResto],
TotKeyLength );
      if CualPagina = 1 then  { make another first key page }
        begin
          if Pages[1].Nivel+1 = PagesInMemory then  { too many keys }
            begin
              ErrIndex := ErrIndexTooManyKeys;
              exit
            end;
          LoadPage( CualIndex, -1, PagesInMemory-1 );  (* // *)
(* //
          WritePage( CualIndex, PagesInMemory );
          if ModPages[ PagesInMemory-1 ] then
            WritePage( CualIndex, PagesInMemory-1 );
// *)
          for AuxBucle := PagesInMemory-1 downto 2 do
            begin
              Pages[AuxBucle] := Pages[AuxBucle-1];
              ModPages[AuxBucle] := ModPages[AuxBucle-1];
            end;
          fillchar( Pages[1], SizeOf(RegPageIndex), 0 );

          ModPages[1] := true;
          GetEmptyPage( CualIndex, 1 );
          Pages[1].KeysInPage := 2;
          Pages[1].Nivel := Pages[2].Nivel+1;
          move( Pages[PagesInMemory].NPage, Pages[1].resto[0], 4 );
          move(
Pages[PagesInMemory].resto[(Pages[PagesInMemory].KeysInPage-1)*TotKeyLength+
4],
            Pages[1].resto[4], KeyLength );
          move( Pages[2].NPage, Pages[1].resto[TotKeyLength], 4 );
          move( Pages[2].resto[(Pages[2].KeysInPage-1)*TotKeyLength+4],
Pages[1].resto[TotKeyLength+4], KeyLength );
          FirstPage := Pages[1].NPage;
          ModPages[0] := true
        end
      else
        begin
          move(
Pages[PagesInMemory].resto[(Pages[PagesInMemory].KeysInPage-1)*TotKeyLength]
,
                AuxClave[1], TotKeyLength );
          move( Pages[PagesInMemory].NPage, AuxClave[1], 4 );
          if PageActual = PagesInMemory then
            begin
              LoadPage( CualIndex, -1, CualPagina );  (* // *)
(*  //
              if ModPages[CualPagina] then
                WritePage( CualIndex, CualPagina );
// *)
              Pages[CualPagina] := Pages[PagesInMemory];
              ModPages[CualPagina] := true;
            end
          else
            begin
              LoadPage( CualIndex, -1, PagesInMemory )  (* // *)
(* //
              WritePage( CualIndex, PagesInMemory );
// *)
            end;
          fillchar( Pages[PagesInMemory], SizeOf(RegPageIndex), 0 );
          ModPages[PagesInMemory] := false;
          PageActual := CualPagina;
          if ErrIndex = ErrIndexNotFound then
            MeteKey( CualPagina-1, Pages[CualPagina-1].RecActual-1, false,
AuxClave[1] )
          else
            MeteKey( CualPagina-1, Pages[CualPagina-1].RecActual, false,
AuxClave[1] );
          PageActual := CualPagina;
          if ErrIndex=ErrIndexTooManyKeys then exit;
          ModifyPagesBefore
        end;
    end
end;

begin   { MeteKey }
  with CualIndex^ do
    begin
      if (donde > MaxKeysInPage) or ((not Replace) and
(Pages[CualPagina].KeysInPage = MaxKeysInPage)) then
        if CualPagina < PagesInMemory then
          PartePage
        else
          ErrIndex := ErrIndexTooManyKeys
      else
        begin
          AuxWord := (donde-1)*TotKeyLength;
          if not Replace then
            move( Pages[CualPagina].Resto[AuxWord],
Pages[CualPagina].Resto[AuxWord+TotKeyLength],
              (Pages[CualPagina].KeysInPage+1-donde)*TotKeyLength);
          move( clave, Pages[CualPagina].resto[AuxWord], TotKeyLength );
          if not Replace then
            begin
              inc( Pages[CualPagina].KeysInPage );
              inc( NumKeys );
              ModPages[0] := true;
            end;
          Pages[CualPagina].RecActual := donde;
          Pages[CualPagina].OfsResto := (donde-1)*TotKeyLength;
          ModPages[CualPagina] := true;
          ModifyPagesBefore
        end
    end
end;    { MeteKey }

begin  { InsKey }
  IniciaIndex( CualIndex, SeDesbloquea );
  if Hi(ErrIndex) <> 0 then exit;
  while length(Clave) < CualIndex^.KeyLength do Clave:=Clave+#0;
  FindKey( CualIndex, Clave );
  move( Clave[1],Clave[5], CualIndex^.KeyLength );
  move( RecNo, Clave[1], 4 );
  with CualIndex^ do
    begin
      if ErrIndex = ErrIndexNotFound then { clave mayor que todas las
claves }
        begin
          PageActual := 1;
          while Pages[PageActual].Nivel <> 0 do
            begin
              Pages[PageActual].RecActual :=
Pages[PageActual].KeysInPage+1;
              Pages[PageActual].OfsResto :=
Pages[PageActual].KeysInPage*TotKeyLength;
              move(
Pages[PageActual].resto[TotKeyLength*(Pages[PageActual].KeysInPage-1)],
AuxRecPage, 4 );
              inc( PageActual );
              LoadPage( CualIndex, AuxRecPage, PageActual );
              if ErrIndex = ErrIndexTooManyKeys then exit;
            end;
          Pages[PageActual].RecActual := Pages[PageActual].KeysInPage+1;
          Pages[PageActual].OfsResto :=
Pages[PageActual].KeysInPage*TotKeyLength;
          MeteKey( PageActual,Pages[PageActual].KeysInPage+1, false,
Clave[1] )
        end
      else { if ErrIndex=ErrIndexNotFound then key more big that last key
in file }
        begin { find key greather equal }
          MeteKey( PageActual,Pages[PageActual].RecActual, false, Clave[1]
)
        end
    end;
  FinalizaIndex( CualIndex, SeDesbloquea );
end;   { InsKey }

procedure NextKey(CualIndex:PtrIndex; SearchNextNotFound:boolean);
label
  Label01;
var
  AuxRecPage:LongInt;
  AuxWord,WordBusca:word;
  AuxClave:Char255;
begin
  with CualIndex^ do
    begin
      move( Pages[PageActual].resto[Pages[PageActual].OfsResto], AuxClave,
TotKeyLength );
      if Pages[PageActual].RecActual < Pages[PageActual].KeysInPage then
        begin
          inc( Pages[PageActual].RecActual );
          inc( Pages[PageActual].OfsResto,TotKeyLength )
        end
      else
        begin
          AuxWord := PageActual;
{ $R-}
          while (Pages[PageActual].RecActual =
Pages[PageActual].KeysInPage) and (PageActual > 1) do
            dec( PageActual );
{ $R+}
          if Pages[PageActual].RecActual = Pages[PageActual].KeysInPage
then
            begin
              PageActual := AuxWord;
              ErrIndex := ErrIndexEOF;
              exit
            end;
          inc( Pages[PageActual].OfsResto, TotKeyLength );
          inc( Pages[PageActual].RecActual );
          while Pages[PageActual].Nivel <> 0 do
            begin
              move( Pages[PageActual].Resto[Pages[PageActual].OfsResto],
AuxRecPage, 4 );
              inc( PageActual );
              LoadPage( CualIndex, AuxRecPage, PageActual );
              if ErrIndex = ErrIndexTooManyKeys then exit;
              Pages[PageActual].OfsResto := 0;
              Pages[PageActual].RecActual := 1;
            end
        end;
      move( Pages[PageActual].Resto[Pages[PageActual].OfsResto], RecIndex,
4 );
      PtrClave :=
addr(Pages[PageActual].resto[Pages[PageActual].OfsResto+4]);
      if Equal( AuxClave[5],
Pages[PageActual].Resto[Pages[PageActual].OfsResto+4], KeyLength) then
        ErrIndex := ErrIndexFound
      else
        if SearchNextNotFound then
          ErrIndex := ErrIndexFound
        else
          ErrIndex := ErrIndexOtherKey
    end
end;

procedure PrevKey(CualIndex:PtrIndex; SearchNextNotFound:boolean);
label
  Label01;
var
  AuxRecPage:LongInt;
  AuxWord,WordBusca:word;
  AuxClave:Char255;
begin
  with CualIndex^ do
    begin
      move( Pages[PageActual].resto[Pages[PageActual].OfsResto], AuxClave,
TotKeyLength );
      if Pages[PageActual].RecActual > 1 then
        begin
          dec( Pages[PageActual].RecActual );
          dec( Pages[PageActual].OfsResto, TotKeyLength )
        end
      else
        begin
          AuxWord := PageActual;
{ $R-}
          while (Pages[PageActual].RecActual = 1) and (PageActual > 1) do
            dec( PageActual );
{ $R+}
          if Pages[PageActual].RecActual = 1 then
            begin
              PageActual := AuxWord;
              ErrIndex := ErrIndexBOF;
              exit
            end;
          dec( Pages[PageActual].OfsResto, TotKeyLength );
          dec( Pages[PageActual].RecActual );
          while Pages[PageActual].Nivel <> 0 do
            begin
              move( Pages[PageActual].Resto[Pages[PageActual].OfsResto],
AuxRecPage, 4 );
              inc( PageActual );
              LoadPage( CualIndex, AuxRecPage, PageActual );
              if ErrIndex = ErrIndexTooManyKeys then exit;
              Pages[PageActual].RecActual := Pages[PageActual].KeysInPage;
              Pages[PageActual].OfsResto :=
(Pages[PageActual].KeysInPage-1) * TotKeyLength
            end
        end;
      move( Pages[PageActual].Resto[Pages[PageActual].OfsResto], RecIndex,
4 );
      PtrClave := addr(
Pages[PageActual].resto[Pages[PageActual].OfsResto+4] );
      if Equal( AuxClave,
Pages[PageActual].Resto[Pages[PageActual].OfsResto+4], KeyLength ) then
        ErrIndex := ErrIndexFound
      else
        if SearchNextNotFound then
          ErrIndex := ErrIndexFound
        else
          ErrIndex := ErrIndexOtherKey
    end
end;

procedure FindKey(CualIndex:PtrIndex; Clave:string);
label
  H1;
var
  AuxRecPage:LongInt;
  AuxCont:word;
  SeDesbloquea:boolean;
function BuscaMayorIgual(var Clave, Resto; KeyLength,
KeysInPage:word):byte; assembler;
asm
  mov  cx,KeyLength
  mov  dx,cx
  add  dx,4            { dx = TotKeyLength }

  mov  ax,1
  mov  bx,KeysInPage

  cld
  push ds
  les  di,Clave
  lds  si,Resto
  add  si,4
@@Bucle:
  cmp  ax,bx
  ja   @@EndXX
  push si
  push di
  push cx
  repe cmpsb
  pop  cx
  pop  di
  pop  si
  jae  @@EndXX
  add  si,dx
  inc  ax
  jmp  @@Bucle
@@EndXX:
  pop  ds
end;
begin
  IniciaIndex( CualIndex, SeDesbloquea );
  if Hi(ErrIndex)<>0 then exit;
  while length(Clave) < CualIndex^.KeyLength do
    Clave := Clave+#0;
  with CualIndex^ do
    begin
      PageActual := 1;
H1:
      Pages[PageActual].RecActual :=
BuscaMayorIgual(Clave[1],Pages[PageActual].Resto,KeyLength,Pages[PageActual]
.KeysInPage);
      Pages[PageActual].OfsResto := (Pages[PageActual].RecActual-1) *
TotKeyLength;
      if Pages[PageActual].RecActual > Pages[PageActual].KeysInPage then
        ErrIndex := ErrIndexNotFound
      else
        begin
          if Pages[PageActual].Nivel <> 0 then
            begin
              move( Pages[PageActual].Resto[Pages[PageActual].OfsResto],
AuxRecPage, 4 );
              inc( PageActual );
              LoadPage( CualIndex, AuxRecPage, PageActual );
              if ErrIndex = ErrIndexTooManyKeys then exit;
              goto H1
            end
          else
            begin
              if
Equal(clave[1],Pages[PageActual].resto[Pages[PageActual].OfsResto+4],KeyLength)
              and (Pages[PageActual].RecActual <=
Pages[PageActual].KeysInPage) then
                ErrIndex := ErrIndexFound
              else
                ErrIndex := ErrIndexBig;
              move( Pages[PageActual].resto[Pages[PageActual].OfsResto],
RecIndex, 4 );
              PtrClave := addr(
Pages[PageActual].resto[Pages[PageActual].OfsResto+4] )
            end
        end;
      if SeBloquea and SeDesbloquea then
        UnLockFileIndex( FileRec(FIndex).Handle )
    end;
{  FinalizaIndex( CualIndex, SeDesbloquea ); }
end;

procedure FindKeyRecNo(CualIndex:PtrIndex; const Clave:string;
RecNo:LongInt);
var
  SeDesbloquea:boolean;
begin
  IniciaIndex( CualIndex, SeDesbloquea );
  if Hi(ErrIndex) <> 0 then exit;
  FindKey( CualIndex, Clave );
  if ErrIndex = ErrIndexFound then
    with CualIndex^ do
      begin
        repeat
          move( Pages[PageActual].Resto[Pages[PageActual].OfsResto],
RecIndex, 4 );
          if RecIndex <> RecNo then
            NextKey( CualIndex, false );
        until (ErrIndex = ErrIndexOtherKey) or (ErrIndex = ErrIndexEOF) or
(RecIndex = RecNo);
        if (RecIndex <> RecNo) or (ErrIndex = ErrIndexEOF) or (ErrIndex =
ErrIndexOtherKey) then
          ErrIndex := ErrIndexNotFound
      end
  else
    ErrIndex := ErrIndexNotFound;
  FinalizaIndex( CualIndex, SeDesbloquea );
end;

procedure DelKey(CualIndex:PtrIndex; Clave:string; RecNo:LongInt);
label
  Label01;
var
  AuxLong:LongInt;
  BuclePage:word;
  SavePage:word;
  SeDesbloquea:boolean;
procedure MiraFirstPage;
var
  AuxBuclePage:word;
begin
  with CualIndex^ do
    if (Pages[1].KeysInPage = 1) and (Pages[1].Nivel > 0) then
      begin
        Pages[1].KeysInPage := 0;
        fillchar( Pages[1].Resto, SizeOfResto, 0 );
        Pages[1].RecActual := 0;
        Pages[1].OfsResto := 0;
        Pages[1].Nivel := 0;
        WritePage( CualIndex, 1 );
        for AuxBuclePage := 1 to PagesInMemory-1 do
          begin
            Pages[AuxBuclePage] := Pages[AuxBuclePage+1];
            ModPages[AuxBuclePage] := ModPages[AuxBuclePage+1];
          end;
        ModPages[PagesInMemory] := false;
        fillchar( Pages[PagesInMemory], SizeOf(RegPageIndex), 0 );
        FirstPage := Pages[1].NPage;
        dec( SavePage )
      end
end;
procedure JuntaPages;
var
  sw:boolean;
  AuxPage:byte;
begin
  with CualIndex^ do
    begin
      sw:=true;
      if Pages[BuclePage-1].RecActual > 0 then
        begin
          if ModPages[PagesInMemory] then
            WritePage( CualIndex, PagesInMemory );
          move(
Pages[BuclePage-1].resto[Pages[BuclePage-1].OfsResto-TotKeyLength],AuxLong,4
);
          LoadPage( CualIndex, AuxLong, PagesInMemory );
          if
Pages[PagesInMemory].KeysInPage+Pages[BuclePage].KeysInPage<MaxKeysInPage
then
            begin
              sw:=false;
              move( Pages[BuclePage].Resto, Pages[PagesInMemory].resto[
Pages[PagesInMemory].KeysInPage*TotKeyLength ],
                Pages[BuclePage].KeysInPage * TotKeyLength );
              Pages[BuclePage].RecActual := Pages[PagesInMemory].KeysInPage
+ Pages[BuclePage].RecActual;
              Pages[BuclePage].OfsResto :=
(Pages[BuclePage].RecActual-1)*TotKeyLength;
              Pages[BuclePage].KeysInPage :=
Pages[PagesInMemory].KeysInPage +
                Pages[BuclePage].KeysInPage;

              Pages[BuclePage].Resto := Pages[PagesInMemory].Resto;
              move(Pages[BuclePage-1].resto[Pages[BuclePage-1].OfsResto],
               
Pages[BuclePage-1].resto[Pages[BuclePage-1].OfsResto-TotKeyLength],
              
(MaxKeysInPage-Pages[BuclePage-1].RecActual+1)*TotKeyLength);
            end
        end;
     if sw and (Pages[BuclePage-1].RecActual<Pages[BuclePage-1].KeysInPage)
then
        begin
          if ModPages[PagesInMemory] then
            WritePage( CualIndex, PagesInMemory );
          move(
Pages[BuclePage-1].resto[Pages[BuclePage-1].OfsResto+TotKeyLength],AuxLong,4
);
          LoadPage( CualIndex, AuxLong, PagesInMemory );
          if
Pages[PagesInMemory].KeysInPage+Pages[BuclePage].KeysInPage<MaxKeysInPage
then
            begin
              sw:=false;
              move(Pages[PagesInMemory].resto,
               
Pages[BuclePage].resto[Pages[BuclePage].KeysInPage*TotKeyLength],
                Pages[PagesInMemory].KeysInPage*TotKeyLength);
{              Pages[BuclePage].RecActual := Pages[BuclePage].KeysInPage +
Pages[PagesInMemory].RecActual; }
{              Pages[BuclePage].OfsResto  :=
Pages[BuclePage].RecActual*TotKeyLength;                      }
             
inc(Pages[BuclePage].KeysInPage,Pages[PagesInMemory].KeysInPage);
              move(
Pages[BuclePage-1].resto[Pages[BuclePage-1].OfsResto+TotKeyLength+4],
                   
Pages[BuclePage-1].resto[Pages[BuclePage-1].OfsResto+4],
                   
(MaxKeysInPage-Pages[BuclePage-1].RecActual-1)*TotKeyLength);
              if (Pages[BuclePage-1].RecActual+1 =
Pages[BuclePage-1].KeysInPage) and (BuclePage > 2) then
                begin
                  AuxPage := BuclePage-2;
                  while AuxPage >= 1 do
                    begin
                      with Pages[BuclePage-1] do
                        move( Resto[OfsResto+4],
Pages[AuxPage].Resto[Pages[AuxPage].OfsResto+4], KeyLength );
                      dec( AuxPage )
                    end;
                end
            end
        end;
      if not sw then
        begin
          fillchar( Pages[PagesInMemory], SizeOf(RegPageIndex), 0);
          Pages[PagesInMemory]. NPage := AuxLong;
          ModPages[PagesInMemory]:=true;
          ModPages[BuclePage]:=true;
          dec(Pages[BuclePage-1].KeysInPage);
          ModPages[BuclePage-1]:=true
        end;
    end
end;
begin  { DelKey }
  IniciaIndex( CualIndex, SeDesbloquea );
  if Hi(ErrIndex)<>0 then exit;
  FindKeyRecNo(CualIndex,Clave,RecNo);
  if ErrIndex=ErrIndexFound then
    with CualIndex^ do
      begin
        SavePage:=PageActual;
Label01:
        if Pages[PageActual].KeysInPage=Pages[PageActual].RecActual then
          begin
            dec(Pages[PageActual].KeysInPage);
           
fillchar(Pages[PageActual].Resto[Pages[PageActual].OfsResto],TotKeyLength,0)
;
            dec(Pages[PageActual].OfsResto,TotKeyLength);
            dec(Pages[PageActual].RecActual);
            ModPages[PageActual]:=true;
            { change previous pages }
            if (Pages[PageActual].KeysInPage=0) and (PageActual>1) then
              begin
                dec(PageActual);
                goto Label01
              end;
            if Pages[PageActual].KeysInPage>0 then
              begin
               
move(Pages[PageActual].resto[Pages[PageActual].OfsResto],Clave[1],TotKeyLength);
                while (PageActual>1) and
(Pages[PageActual].KeysInPage=Pages[PageActual].RecActual) do
                  begin
                   
move(Clave[5],Pages[PageActual-1].resto[Pages[PageActual-1].OfsResto+4],KeyLength);
                    ModPages[PageActual-1]:=true;
                    dec(PageActual)
                  end
              end
          end
        else
          begin
            with Pages[PageActual] do
              move( resto[ OfsResto + TotKeyLength ], resto[ OfsResto ],
                ( MaxKeysInPage - RecActual ) * TotKeyLength );
            dec(Pages[PageActual].KeysInPage);
            ModPages[PageActual]:=true
          end;
        inc(NumDelKeys);
        dec(NumKeys);
        ModPages[0]:=true;
        MiraFirstPage;
        PageActual:=SavePage;
{ Comprobación de que las páginas se puedan juntar con la anterior o
siguiente
  siempre y cuando KeysInPage <= MaxKeysInPage div 3 }
        for BuclePage := SavePage downto 2 do
          if Pages[BuclePage].KeysInPage > 0 then
            begin
              if (Pages[BuclePage].KeysInPage<=(MaxKeysInPage div 3)) then
                JuntaPages
            end
          else
            begin
{ Página vacía }
            end;
        MiraFirstPage
      end
  else
    ErrIndex:=ErrIndexNotFound;
  FinalizaIndex( CualIndex, SeDesbloquea );
end;  { DelKey }

procedure ReplaceKey(CualIndex:PtrIndex; const OldClave,NewClave:string;
RecNo:LongInt);
var
  SeDesbloquea:boolean;
begin
  IniciaIndex( CualIndex, SeDesbloquea );
  if Hi(ErrIndex)<>0 then exit;
  DelKey(CualIndex,OldClave,RecNo);
  if ErrIndex=ErrIndexFound then
    InsKey(CualIndex,NewClave,RecNo)
  else
    ErrIndex:=ErrIndexNotFound;
  FinalizaIndex( CualIndex, SeDesbloquea )
end;

procedure FindFirstKey(CualIndex:PtrIndex);
var
  AuxClave:string;
begin
  fillchar(AuxClave,SizeOf(AuxClave),0);
  AuxClave[0]:=char(CualIndex^.KeyLength);
  FindKey(CualIndex,AuxClave);
  if (Lo(ErrIndex)=ErrIndexBig) or (ErrIndex=0) then
    ErrIndex := ErrIndexFound
  else
    ErrIndex := ErrIndexNoKeys
end;

procedure FindLastKey(CualIndex:PtrIndex);
var
  AuxLong:LongInt;
  SeDesbloquea:boolean;
begin
  IniciaIndex( CualIndex, SeDesbloquea );
  if Hi(ErrIndex)<>0 then exit;
  with CualIndex^ do
    begin
      if Pages[1].KeysInPage > 0 then
        begin
          PageActual := 1;
          while Pages[PageActual].Nivel <> 0 do
            begin
              move(
Pages[PageActual].resto[(Pages[PageActual].KeysInPage-1)*TotKeyLength],AuxLong,4);
              inc( PageActual );
              LoadPage( CualIndex, AuxLong, PageActual );
            end;
          Pages[PageActual].RecActual := Pages[PageActual].KeysInPage;
          Pages[PageActual].OfsResto :=
(Pages[PageActual].RecActual-1)*TotKeyLength;
         
move(Pages[PageActual].resto[Pages[PageActual].OfsResto],RecIndex,4);
         
PtrClave:=addr(Pages[PageActual].resto[Pages[PageActual].OfsResto+4]);
          ErrIndex := ErrIndexFound
        end
      else
        ErrIndex := ErrIndexNoKeys
    end;
  FinalizaIndex( CualIndex, SeDesbloquea )
end;

end.


{ ----------------------------  DEMO -------------------- }
{ CUT }

{
   SwagIndex Demo.

   First, excuse me, I don't speak english.

   There are two index file for one file data
     -The first index is the field Numero (one data rec => one key)
     -The second index is the field Nombre1 and Nombre2 if not empty
      (one data rec => one or two keys).

}
uses
  crt,dos,SwagIdx;
type
  RegData = record
    Numero:integer;
    Nombre1,Nombre2:string[25];
    telefono:string[12]
  end;
var
  FData:file of RegData;
  RData:RegData;
  IndexDataNumero,IndexDataNombre,AuxIndex:PtrIndex;
  ch,CualClave,CualOrden:char;
  CadBusca:string;
  swWriteCab:boolean;

procedure WriteError;
begin
  case ErrIndex and $00FF of
    ErrIndexNotFound  : writeln( 'Key not found' );
    ErrIndexBig       : writeln( 'Key not found, big exist');
    ErrIndexEOF       : writeln( 'End of index file, no more keys' );
    ErrIndexBOF       : writeln( 'Begin of index file' );
    ErrIndexOtherKey  : writeln( 'It''s another key' );
    ErrIndexNoKeys    : writeln( 'No keys in index file' );
  end;
  case (ErrIndex and $FF00) of
    ErrIndexShared     : writeln( 'Sharing mode error');
    ErrIndexRead       : writeln( 'Read error');
    ErrIndexWrite      : writeln( 'Write error');
    ErrIndexFileNoOpen : writeln( 'Index file not open' );
  end;
  case ErrIndex of
    ErrIndexNoMemory    : writeln( 'Not enaught memory' );
    ErrIndexTooManyKeys : writeln( 'Too many keys in file' )
  end
end;

procedure InsRec( Numero:integer; const Nombre1,Nombre2,Telefono:string);
var
  AuxClave : char2;
begin
  IntegerToKey( Numero, AuxClave );
  InsKey( IndexDataNombre, Nombre1 , FileSize(FData) );
  if Nombre2 <> '' then { if there is a second name ... }
    InsKey( IndexDataNombre, Nombre2 , FileSize(FData) );
  InsKey( IndexDataNumero, AuxClave, FileSize(FData) );
  RData.Numero := Numero;
  RData.Nombre1 := Nombre1;
  RData.Nombre2 := Nombre2;
  RData.Telefono := Telefono;
  seek(FData,FileSize(FData));
  write(FData,RData);
end;

procedure ShowRec;
procedure WriteCab;
begin
  swWriteCab:=true;
  writeln(' Rec   Num.          Name 1                    Name 2           
   Telephon');
  writeln('----- ----- --------------------------
-------------------------- ------------')
end;
begin   { ShowRec }
  if not swWriteCab then WriteCab;
  seek(FData,RecIndex);
  read(FData,RData);
  writeln( RecIndex:5, RData.Numero:6,'
',RData.Nombre1,'':27-length(RData.Nombre1),RData.Nombre2,'':27-length(RData
.Nombre2),
    RData.Telefono);
end;    { ShowRec }

procedure MakeFile;
begin
  if FileRec(FData).Mode = fmInOut then
    begin
      writeln( 'File already open');
      exit
    end;
  rewrite(FData);
  CreateIndex( IndexDataNombre, 'SWAGNDC.NOM',30 );
  CreateIndex( IndexDataNumero, 'SWAGNDC.NUM', 2 );
  InsRec( 1245,'PEPITO PEREZ','JOSEFA PEREZ','12354'  );
  InsRec( 1313,'PEPITO LOPEZ','','91-13123123' );
  InsRec(  245,'OTRO PEPITO','','959-12354' );
  InsRec(  145,'FULANITO DE TAL','MENGANITA','9912354' );
  InsRec(  -12,'TAL Y TAL','GIL','1544254' );
  InsRec( 1435,'TAL Y PASCUAL','MARAGALL','07505505505' );

{ y ya me he cansado }
end;

procedure LeeFile;
begin
  if FileRec(FData).Mode = fmInOut then
    begin
      writeln( 'File already open');
      exit
    end;
{$I-}
  reset(FData);
  if IOResult <> 0 then
{$I+}
    begin
      writeln( 'Open data file error');
      exit
    end;
  OpenIndex( IndexDataNombre, 'SWAGNDC.NOM' );
  OpenIndex( IndexDataNumero, 'SWAGNDC.NUM' )
end;

procedure Informa;
begin
  writeln( FileSize(FData):5,' recs. in file data' );
  writeln( IndexDataNumero^.NumKeys:5,' keys in number''s index file and ',
    IndexDataNumero^.NumDelKeys:5,' deleted keys');
  writeln( IndexDataNombre^.NumKeys:5,' keys in name''s index file and   ',
    IndexDataNombre^.NumDelKeys:5,' deleted keys');
end;

procedure MuestraRecs;
begin
  if CualOrden = 'A' then
    begin
      FindFirstKey( AuxIndex );
      if ErrIndex=ErrIndexNoKeys then
        WriteError
      else
        while ErrIndex <> ErrIndexEOF do
          begin
            ShowRec;
            NextKey( AuxIndex, true )
         end
    end
  else
    begin
      FindLastKey( AuxIndex );
      if ErrIndex=ErrIndexNoKeys then
        WriteError
      else
        while ErrIndex <> ErrIndexBOF do
          begin
            ShowRec;
            PrevKey( AuxIndex, true )
          end;
    end
end;

procedure BuscaClave;
var
  AuxInt:integer;
  AuxChar2:char2;
begin
  write('Key to find: ');
  if CualClave = '2' then
    readln(CadBusca)
  else
    begin
      readln(AuxInt);
      IntegerToKey( AuxInt, AuxChar2 );
      CadBusca := AuxChar2
    end;
  FindKey( AuxIndex, CadBusca );
  if ErrIndex = ErrIndexFound then
    ShowRec
  else
    WriteError
end;

procedure BuscaGenerica;
var
  AuxChar2:char2;
  AuxInt:integer;
begin
  write('Key to find: ');
  if CualClave = '2' then
    readln(CadBusca)
  else
    begin
      readln(AuxInt);
      IntegerToKey( AuxInt, AuxChar2 );
      CadBusca := AuxChar2
    end;
  FindKey( IndexDataNombre, CadBusca );
  while (ErrIndex = ErrIndexFound) or (ErrIndex=ErrIndexBig) do
    begin
      if Equal( IndexDataNombre^.PtrClave^, CadBusca[1], length(CadBusca) )
then
        begin
          ShowRec;
          NextKey( IndexDataNombre, true )
        end
      else
        break
    end
end;

procedure BorraClave;
begin
  if (ErrIndex = 0) or (ErrIndex = ErrIndexBig) or (ErrIndex =
ErrIndexOtherKey) then
    begin
      CadBusca[0] := char(AuxIndex^.KeyLength);
      move( AuxIndex^.PtrClave^, CadBusca[1], byte(CadBusca[0]) );
      DelKey( AuxIndex, CadBusca, RecIndex );
      if ErrIndex <> 0 then WriteError
    end
end;

procedure MeteRec;
var
  AuxInt:integer;
  AuxNombre1,AuxNombre2:string[25];
  AuxTelefono:string[12];
begin
  write('Number: '); readln(AuxInt);
  write('Name 1 : '); readln(AuxNombre1);
  write('Name 2 : '); readln(AuxNombre2);
  write('Telephon: '); readln(AuxTelefono);
  InsRec( AuxInt, AuxNombre1, AuxNombre2, AuxTelefono )
end;

begin
  assign( FData,'SWAGNDC.D');
  repeat
    swWriteCab:=false;
    ClrScr;
    writeln( '0.- Create file' );
    writeln( '1.- Read file' );
    writeln( 'A.- About files' );
    writeln( 'B.- Show recs' );
    writeln( 'C.- Find Key' );
    writeln( 'D.- Find generic key (only names)' );
    writeln( 'E.- Delete last found key' );
    writeln( 'F.- Find next' );
    writeln( 'G.- Find prev' );
    writeln( 'H.- Find smallest key' );
    writeln( 'I.- Find biggest key' );
    writeln( 'J.- Add rec' );
    writeln( 'Z.- End' );
    writeln;
    write( 'Option 0,A-I,Z: ' );
    ch := UpCase(ReadKey);
    writeln( ch );
    writeln;
    if ch = 'Z' then break;
    if (ch in ['A'..'J']) and (FileRec(FData).Mode <> fmInOut) then
      begin
        writeln( 'Must read o create index file first' );
        ch := #0
      end;
    if (ch >='B') and (ch <= 'I') then
      begin
        if (ch <> 'D') and (ch <> 'E') then
          begin
            write( 'Key (1=Numbers, 2=Names) : ');
            CualClave := ReadKey;
            writeln( CualClave )
          end
        else
          if ch = 'D' then
            CualClave := '2';
        if (CualClave <> '1') and (CualClave <> '2') then
	  ch := #0
        else
          begin
            if CualClave = '1' then
	      AuxIndex := IndexDataNumero
	    else
	      AuxIndex := IndexDataNombre;
            if ch = 'B' then
              begin
                write('Orden Ascendente o Descendente (A/D): ');
                CualOrden := UpCase(ReadKey);
                writeln(CualOrden)
              end
          end
      end;
    case ch of
      '0':MakeFile;
      '1':LeeFile;
      'A':Informa;
      'B':MuestraRecs;
      'C':BuscaClave;
      'D':BuscaGenerica;
      'E':BorraClave;
      'F':begin
            NextKey( AuxIndex, true );
            if ErrIndex = 0 then ShowRec else WriteError
          end;
      'G':begin
            PrevKey( AuxIndex, true );
            if ErrIndex = 0 then ShowRec else WriteError
          end;
      'H':begin
            FindFirstKey( AuxIndex );
            if ErrIndex = ErrIndexFound then
              ShowRec
            else
              WriteError
          end;
      'I':begin
            FindLastKey( AuxIndex );
            if ErrIndex = ErrIndexFound then
              ShowRec
            else
              WriteError
          end;
       'J':MeteRec
    end;
    writeln;
    write('Press Enter ...'); readln;
  until false;
  if FileRec(FData).Mode = fmInOut then
    begin
      close(FData);
      CloseIndex( IndexDataNumero );
      CloseIndex( IndexDataNombre )
    end
end.



