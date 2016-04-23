
unit setenv;
interface
type  s24 = string;
Function SetTheEnv (symbol, val : s24) : boolean;

implementation
{uses asciiz;}
const
   arena_size = 16;
   NORMAL_ATYPE = #$4D;
   LAST_ATYPE   = #$5A;
   COMSPEC : string[8] = 'COMSPEC=';

type
    PSP = record
	fill1              : array [1..10] of char;
        PrevTermHandlerPtr : ^integer;
	PrevCtrlCptr       : ^integer;
	PrevCritErrPtr     : ^integer;
	fill2              : array [1..22] of char;
	EnvirSeg           : word;
        end;

    Arena = record
	ArenaType     : char;
	PspSegment    : word;
	NumOfSegments : word;
        fill3         : array [1..11] of char;
        ArenaData     : string;{ca}
        end;

     str4 = string[4];

var
    ap    : ^arena;

{$ifdef Debug}
Function HexStr (n:word):str4;
   const ha:array[0..15] of char=('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
   var str : str4;
   begin
   str[0]:=chr(4);
   str[1]:=ha[hi(n) shr 4];
   str[2]:=ha[hi(n) and $F];
   str[3]:=ha[(n shr 4) and $F];
   str[4]:=ha[n and $F];
   HexStr := str;
   end;
{$endif}


Function GetNextArena (var ap:arena) : pointer;
   var tp : pointer;
   begin
   tp := Ptr( Seg(ap)+1+ap.NumOfSegments, 0);
   GetNextArena := tp;
   end {GetNextArena};


Function IsValidArena (var ar:arena) : boolean;
var ap1 : ^arena;
   begin
   IsValidArena := false;
   if ar.ArenaType <> NORMAL_ATYPE   then  Exit;
   ap1 := GetNextArena (ar);
   if ap1^.ArenaType <> NORMAL_ATYPE then  Exit;

   ap1 := GetNextArena (ap1^);
   if (ap1^.ArenaType <> NORMAL_ATYPE) and
      (ap1^.ArenaType <> LAST_ATYPE)        then  Exit;
   IsValidArena:=true;
   end {IsValidArena};


Function GetFirstArena : pointer;
{ return pointer to the first arena.
  scan memory for a 0x4D on a segment start,
  see if this points to another two levels of arena. }
var
   ap, ap1  : ^arena;
   segment  : word;

   begin
        for segment:=60 to Cseg do
            begin
            ap := ptr(segment, 0);
            if IsValidArena (ap^)  then
               begin  GetFirstArena := ap;  Exit;  end;
            end;
	GetFirstArena := nil;
end {GetFirstArena};


Function IsValidEnv (var ad:ca; NumSegs:integer):boolean;
var
   COMSPECa : ca;
   adp      : cap;
   BaseAD   : word;

   begin
   BaseAD := ofs (ad);
   adp    := @ad;
   PtoA (COMSPEC, COMSPECa);
   while ( adp^[0] <> #0 ) and
         ( (ofs(adp^)-BaseAD) shr 4 < NumSegs ) do
        begin
        if (strnicmp(adp^, COMSPECa, 8) = 0) then
            begin  IsValidEnv:=true;  Exit;  end;
        adp := @adp^[strlen(adp^) + 1];
        end {while};
   IsValidEnv := false;
end {IsValidEnv};


Function GetArenaOfEnvironment : pointer;
{  First get segment of COMMAND.COM from segment of previous critical err code.
   then go to this COMMAND.COM, and go get its ENV block,
   check that it is an ENV block }

Label L1, L2;
var
   ap       : ^arena;
   Mypsp    : ^psp;
   CCpsp    : ^psp;
   CCseg, i : word;
   EnvSeg   : word;
   ad       : cap;

   begin
   GetArenaOfEnvironment := NIL;

   { set Mypspp to psp of this program }
   Mypsp := Ptr (PrefixSeg, 0);

   { set CCpsp to psp of COMMAND.COM }
   CCseg := Seg (Mypsp^.PrevCritErrPtr^);
   i := CCseg - 32;   if i<60 then i:=60;

   while CCseg > i do
         begin
         ap := Ptr (CCseg, 0);
         if IsValidArena (ap^) then  goto L1;
         dec (CCseg);
         end;
    exit;   {error}

L1: inc (CCseg);
    CCpsp := Ptr (CCseg, 0);

   {$ifdef Debug}
      writeln ('prog psp=', HexStr(seg(Mypsp^)),
               ' prog crit_err_seg=', HexStr(CCseg) );
   {$endif}

   {first see if the env seg in command.com points at a good env block?}
   EnvSeg := CCpsp^.EnvirSeg;
   ap := Ptr (EnvSeg-1, 0);

   {$ifdef Debug}
      writeln ('Env ', HexStr(seg(ap^)),
                    ',  psp in env=', HexStr(ap^.PspSegment));
   {$endif}

   { if a valid arena, then search the entire arena for validity,
     if not a valid arena, then maybe it is one of these fabricated
     guys that shells like "4DOS" set up, search the first 128 bytes
     only }

   i := ap^.NumOfSegments-1;

   if not IsValidArena(ap^) then
      i := 9
   else
      if  ap^.PspSegment <> CCseg  then  goto L2;

   if IsValidEnv(ap^.ArenaData, i) then
      begin
      GetArenaOfEnvironment := ap;
      {$ifdef Debug} writeln('env found');  {$endif}
      Exit;
      end;

   {command.com did not have a good env segment, lets search all MCB's }
L2:
   ap := GetFirstArena;
   if ap=NIL then Exit;
   while (ap^.ArenaType <> LAST_ATYPE) do
        begin
        {$ifdef Debug} Writeln ('arena ', HexStr(seg(ap^)));  {$endif}
        if (ap^.PspSegment=CCseg) and
            IsValidEnv(ap^.ArenaData, ap^.NumOfSegments-1) then
           begin
           GetArenaOfEnvironment := ap;
           {$ifdef Debug} writeln('env found'); {$endif}
           Exit;
           end;
        ap := GetNextArena (ap^);
        end;

   end {GetArenaOfEnvironment};

{*****************************************************************************}

Function SetTheEnv (symbol, val : s24) : boolean;
var
    TotalEnvSize,
    NeededSize,
    strlength     : integer;
    sp, op, envir : cap;
    SymbolLen     : integer;
    SymbolA, ValA : ca;
    Found         : boolean;
    ap            : ^arena;

    begin
    NeededSize := 0;
    Found      := false;
    SetTheEnv  := false;

    PtoA  (Symbol, SymbolA);
    PtoA  (Val, ValA);
    strupr(symbolA);
    SymbolLen := strlen (symbolA);
    SymbolA [SymbolLen]   := '=';
    SymbolA [SymbolLen+1] := #0;

    { first, can the COMMAND.COM envir block be found ? }
    ap := GetArenaOfEnvironment;
    if ( ap = NIL) then  exit;


    { search to end of the envir block, get sizes }
    TotalEnvSize := 16 * ap^.NumOfSegments;
    envir := @ap^.ArenaData;
    op    := envir;
    sp    := envir;

    while sp^[0] <> #0 do
        begin
	strlength := strlen(sp^)+1;
	if ( strnicmp(sp^, symbolA, SymbolLen+1) = 0 )  then
	     found := true
	else
             begin
             NeededSize := NeededSize + strlength;
             if found then  strcpy(op^  , sp^);
             op := @op^[strlength];
	     end;
	sp := @sp^[strlength];
        end;
    op^[0] := #0;

    if (strlen(valA) > 0) then
        begin
	NeededSize := NeededSize + 3 + SymbolLen + strlen(valA);

	if (NeededSize > TotalEnvSize) then
		Exit;    {could mess with environment expansion here}

	strcpy(op^, symbolA);  strcat(op^, valA);
	op := @op^[strlen(op^)+1];
        end;
    op^[0] := #0;
    SetTheEnv := true;
  end {SetTheEnv};

end.
