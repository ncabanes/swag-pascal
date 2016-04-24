(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0002.PAS
  Description: BMSEARCH.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

{ Default Compiler Directives}
{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
  {Allow overlays}
  {$F+,O-,X+,A-}
{$ENDIF}

UNIT SEARCH;

INTERFACE

function SearchBuffer(var Buffer; BufLength : Word;
                      var Match; MatLength : Word) : Word;
 {-Search through Buffer for Match. BufLength is length of range to search.
   MatLength is length of string to match. Returns number of bytes searched
   to find Match, $FFFF if not found.}

IMPLEMENTATION

  function SearchBuffer(var Buffer; BufLength : Word;
                  var Match; MatLength : Word) : Word;
   {-Search through Buffer for Match. BufLength is length of range to search.
     MatLength is length of string to match. Returns number of bytes searched
     to find Match, $FFFF if not found.}
  begin
    inline(
      $1E/                   {PUSH DS                 ;Save DS}
      $FC/                   {CLD                     ;Go forward}
      $C4/$7E/<Buffer/       {LES  DI,[BP+<Buffer]    ;ES:DI => Buffer}
      $89/$FB/               {MOV  BX,DI              ;BX = Ofs(Buffer)}
      $8B/$4E/<BufLength/    {MOV  CX,[BP+<BufLength] ;CX = Length of range to scan}
      $8B/$56/<MatLength/    {MOV  DX,[BP+<MatLength] ;DX = Length of match string}
      $85/$D2/               {TEST DX,DX              ;Length(Match) = 0?}
      $74/$24/               {JZ   Error              ;If so, we're done}
      $C5/$76/<Match/        {LDS  SI,[BP+<Match]     ;DS:SI => Match buffer}
      $AC/                   {LODSB                   ;AL = Match[1]; DS:SI => Match[2]}
      $4A/                   {DEC  DX                 ;DX = MatLength-1}
      $29/$D1/               {SUB  CX,DX              ;CX = BufLength-(MatLength-1)}
      $76/$1B/               {JBE  Error              ;Error if BufLength is less}
                             {;Search for first character in Match}
                             {Next:}
      $F2/$AE/               {REPNE SCASB             ;Search forward for Match[1]}
      $75/$17/               {JNE  Error              ;Done if not found}
      $85/$D2/               {TEST DX,DX              ;If Length = 1 (DX = 0) ...}
      $74/$0C/               {JZ   Found              ; the "string" was found}
                             {;Search for remainder of Match}
      $51/                   {PUSH CX                 ;Save CX}
      $57/                   {PUSH DI                 ;Save DI}
      $56/                   {PUSH SI                 ;Save SI}
      $89/$D1/               {MOV  CX,DX              ;CX = Length(Match) - 1}
      $F3/$A6/               {REPE CMPSB              ;Does rest of string match?}
      $5E/                   {POP  SI                 ;Restore SI}
      $5F/                   {POP  DI                 ;Restore DI}
      $59/                   {POP  CX                 ;Restore CX}
      $75/$EC/               {JNE  Next               ;Try again if no match}
                             {;Calculate number of bytes searched and return}
                             {Found:}
      $4F/                   {DEC  DI                 ;DX = Offset where found}
      $89/$F8/               {MOV  AX,DI              ;AX = Offset where found}
      $29/$D8/               {SUB  AX,BX              ;Subtract starting offset}
      $EB/$03/               {JMP  SHORT SDone        ;Done}
                             {;Match was not found}
                             {Error:}
      $31/$C0/               {XOR  AX,AX              ;Return $FFFF}
      $48/                   {DEC  AX}
                             {SDone:}
      $1F/                    {POP  DS                 ;Restore DS}
      $89/$46/<SearchBuffer); {MOV [BP+<Search],AX     ;Set func result}
  end;

END.
