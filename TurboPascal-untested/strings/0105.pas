
Unit ns;

Interface

Function PosAfter(find:string;var tline; after:integer):integer ;

 {Finds position of find in string tline, starting after tline[after].
  Returns zero if not found, position where match starts otherwise
 }

Function PosC(find:char;var tst):integer;

 {Just like Pos, but searches only for a single character.  Slightly
  faster than Pos.  Probably not worth bothering with.
 }

Function PosCAfter(FIND:Char; Var TST; N:Integer):Integer;

 {Like PosAfter, but finds only a character.  Faster that PosAfter.
 }

Procedure StripL (var tst; strp:char);

  {Deletes leading character strp from string tst.
   tst may be of any string type.
  }


Function StripCountL (var tst; strp:char):integer;

  {deletes leading character strp from string tst
   tst may be of any string type.
   returns the number of characters stripped
  }

Procedure StripR (var tst;strp:char);

   {Strips trailing characters strp from string tst.
    tst may be any string type
   }


Procedure StripThrough (var tst;strp:char);

   {For string tst and char strp,
    strips from the left up to and including
    the first instance of char strp
   }

Procedure SwapSubString (Var tline; find, repl:string;
                         Var enough:boolean; limit:byte);

    {tline is a string.  Find and replace are strings, but may be literals
     (e.g., 'abc','').  Replaces all instances of substring find with
     substring repl in tline.  Limit is the maximum permissible length of
     the string Tline after the replacements, but no more than 255.
     Enough returns FALSE if not all swaps are accomplished because limit
     length exceeded.  If limit is less than the actual length of tline
     and repl is longer than find, no replacements are done.  If limit is
     longer than length tline and repl is longer than find, replaces are
     done up to the point where the next replace would leave tline longer
     than limit.  If repl is not longer than find, limit has no effect. If
     repl contains find, the find within repl is not replaced.

     SwapSubString can do everything that FlipChar and StrpChar can do,
     but is slower.
    }

Function Stringup(tline:string):string;

   {Returns uppercase version of tline.
   }

Procedure StupCase (var tline);
   {Uppercases string tline.  Based on routine in
    Turbo 2 Manual
   }

Procedure LowCase(var tline);
  {lowercases string tline
  }

Procedure FlipChar(var tst; srch, repl: char);

  {replaces every instance of character srch in string tst by
   character repl
  Written by Mitchell Lazarus.
  }

Function FlipCount(var tst;srch,repl:char):integer;

  {Just like FlipChar, except it returns the number of
   times it did the replacement
  }

Procedure StripChar (var tst; strp: char);

  {deletes all instances of character strp from
   string tst
   Written by Mitchell Lazarus
  }

Function Count(var tst; srch:char):integer;

    {Returns count of instances of srch in string tst}

Function HowMany(var str1,str2):integer;

    {str1 and str2 are strings.  Function compares them character
      by character for up to min(length(str1),length(str2))
      characters.  Result is the number of consecutive characters
      (starting with string[1]) for which the two strings are
      equal. e.g., if str1 is cats and str2 is catchup, function
      result is 3.  If str1 is cat and str2 is dog, function
      result is 0.  If str1 is acat and str2 is cat, function
      result is 0.
    }

Function Equal_Structures (var a,b;size:integer):boolean;

     {compares two structures of size bytes.  Returns
       true of they are equal, false if they are not.
       A and B may be strings.  You can then use the
       function to compare portions of strings of
       unequal length for equality.  For example,
       if equal_structures (a[1],b[1], 5) tests whether
       the first five characters of strings a and b are
       equal.
      }

Function space (N:integer; C:char):string;

     {Returns string of length N, consisting of
      N instances of C
     }

Procedure Blanker(var tline:string);

   {if tline consists entirely of blanks, sets
    length(tline) to zero.  Otherwise, does not
    alter tline
   }

Function Break (search: string; var tline): byte;

 {returns position of first occurence in string tline of
  a character in search.  If none is found in tline, returns 0
 }

Function Break2 (search,tline:string):byte;

  {does exactly what Break does, but by a different method.
   Which is faster probably depends on relative lengths of
   search and tline.
  }

Function Span(search,tline:string):byte;

  {returns length of initial segment of tline that consists
   entirely of characters found in search.  Assuming there are
   some characters in tline not in search, the first one
   is at tline[span(search,tline) +1]
  }

Function LastPosC (find: char; var tst): integer;

  {returns position in string tst of last instance of find
  }

Function WildPosAfter(find:string; var tline ; after:integer):integer;

   {Like PosAfter, but with a wildcard.  ASCII 255 in find matches
    any character in tline.  Thus 'c'#255't' matches cat, cot,
    cut.
   }

(*---------------------------------------------------------------------*)
Implementation


Function PosAfter{(find:string;var tline; after:integer):integer};

Begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
                         {;tline is a string of any type.  Find is string of}
                         {;type string, but may be literal (e.g., 'abc','').}
                         {;finds first instance of find after tline[after]}
                         {;Returns zero if not found, otherwise the position find starts in}
  $8D/$B6/>FIND/         {          lea       si, >find[bp]       ;addressing of find string}
  $36/$8A/$14/           {      ss: mov       dl, [si]            ;store length of find}
  $46/                   {          inc       si}
  $36/$8A/$04/           {      ss: mov       al, [si ]           ;store first find character in al}
  $C7/$46/$FE/$00/$00/   {          mov       wo [bp-2], 0        ;result of no match}
  $C4/$BE/>TLINE/        {          les       di, >tline[BP]      ;address of string to modify}
  $31/$C9/               {          xor       cx,cx               ;zero out cx}
  $8A/$0D/               {          mov       cl,[di]             ;length tline to cl}
  $E3/$29/               {          jcxz      quit                ;exit if tline null}
  $89/$CB/               {          mov       bx,cx               ;save length}
  $2B/$8E/>AFTER/        {          sub       cx, >after[bp]}
  $7E/$21/               {          jle       quit}
  $03/$BE/>AFTER/        {          add       di, >after[bp]      ;move to char to begin after}
  $47/                   {j2:       inc       di                  ;to after it}
  $38/$D1/               {scan:     cmp       cl, dl              ;is remaining string>find?}
  $72/$18/               {          jb        quit                ;exit if not enough left for a match}
  $FC/                   {          cld                           ;move forwards}
  $F2/$AE/               {repne     scasb                         ;search for first char}
  $75/$13/               {          jne       quit                ;exit if not found}
  $51/                   {          push      cx                  ;save no. of bytes left after match}
  $4F/                   {          dec       di                  ;to match position}
  $57/                   {          push      di                  ;save position after match}
  $88/$D1/               {          mov       cl, dl              ;get length of find string}
  $36/$F3/$A6/           {ss:repe      cmpsb                         ;match on find string?}
  $5F/                   {          pop       di                  ;start of match test}
  $59/                   {          pop       cx                  ;bytes then remaining}
  $75/$EA/               {          jne       j2                  ;cycle if no match}
                         {;gets here if you found a match.}
  $F7/$D9/               {          neg       cx                 ;negative start}
  $01/$D9/               {          add       cx,bx              ;add new and old length}
  $89/$4E/$FE            {          mov       wo [bp-2],cx         ;}
 );                      {quit:}
end;


Function PosC{(find:char;var tst):integer};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $C4/$BE/>TST/          {          les       di,>tst[bp]    ;get string length}
  $C7/$46/$FE/$00/$00/   {          mov       wo [bp-2],0    ;result if nothing found or}
                         {                                   ; length 0}
  $8A/$86/>FIND/         {          mov       al,>find[bp]   ;get the character}
  $31/$C9/               {          xor       cx,cx}
  $26/$8A/$0D/           {      es: mov       cl,[di]        ;get length}
  $E3/$0D/               {          jcxz      quit           ;stop if zero length}
  $89/$CB/               {          mov       bx,cx          ;save length}
  $47/                   {          inc       di             ;start at first char}
  $FC/                   {          cld                      ;moveforward}
  $F2/$AE/               {repne     scasb}
  $75/$05/               {          jne       quit           ;stop if not found}
  $29/$CB/               {          sub       bx,cx          ;add new and old length}
  $89/$5E/$FE            {          mov       [bp-2],bx      ;save result}
 );                      {quit:}
end;

Function PosCAfter{(FIND:Char; Var TST; N:Integer):Integer};

begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $C4/$BE/>TST/          {          les       di,>tst[bp]    ;load string}
  $C7/$46/$FE/$00/$00/   {          mov       wo [bp-2],0    ;result if nothing found or}
                         {                                   ; start beyond length}
  $8A/$86/>FIND/         {          mov       al,>find[bp]   ;get the character}
  $31/$C9/               {          xor       cx,cx}
  $8A/$0D/               {          mov       cl,[di]        ;get length}
  $E3/$19/               {          jcxz      quit           ;stop if zero length}
  $89/$CB/               {          mov       bx,cx          ;save length}
  $2B/$8E/>N/            {          sub       cx,>N[bp]      ;length after start}
  $7E/$11/               {          jle       quit           ;quit if nowhere to search}
  $03/$BE/>N/            {          add       di,>N[bp]      ;moves to the char to begin after}
  $47/                   {          inc       di             ;to after it}
  $FC/                   {          cld                      ;moveforward}
  $F2/$AE/               {repne     scasb                    ;search}
  $75/$07/               {          jne       quit           ;stop if not found}
  $F7/$D9/               {          neg       cx}
  $01/$D9/               {          add       cx,bx          ;add new and old length}
  $89/$4E/$FE            {          mov       [bp-2],cx      ;save result}
 );                      {quit:}
end;

Procedure StripL {(var tst; strp:char)};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push      ds           ; save for exit}
  $C4/$BE/>TST/          {          les       di,>tst[bp]  ; ES:DI to start}
  $8C/$C0/               {          mov       ax,es        ; match segments}
  $8E/$D8/               {          mov       ds,ax}
  $89/$FB/               {          mov       bx,di        ; save start}
  $8A/$86/>STRP/         {          mov       al,>strp[bp] ; char to strip}
  $29/$C9/               {          sub       cx,cx        ; zero in CX}
  $8A/$0D/               {          mov       cl,[di]      ; length in CX}
  $E3/$17/               {          jcxz      quit         ; exit if null}
  $47/                   {          inc       di}
  $3A/$05/               {          cmp       al,[di]      ; check first char}
  $75/$12/               {          jne       quit         ; exit if no match}
  $47/                   {          inc       di           ; next char}
  $49/                   {          dec       cx           ; already checked first one}
  $FC/                   {          cld                    ; frontwards}
  $F3/$AE/               {repe      scasb                  ; do search after first}
  $74/$07/               {          je        null         ; if stripping whole line}
  $89/$FE/               {          mov       si,di        ; char after last match}
  $89/$DF/               {          mov       di,bx        ; to start of string}
  $47/                   {          inc       di}
  $4E/                   {          dec       si           ;}
  $41/                   {          inc       cx}
  $89/$0F/               {null:     mov       [bx],cx      ; to get length right}
  $F2/$A4/               {rep       movsb                  ; delete}
  $1F                    {quit:     pop       ds}
 );                      {end;}
end;

Function StripCountL {(var tst; strp:char):integer};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
                         {;Function StripCountL (var tst; strp:char):integer;}
                         {;deletes leading character strp from string tst}
                         {;tst may be of any string type.}
                         {;returns the number of characters stripped}
  $1E/                   {          push      ds           ; save for exit}
  $C4/$BE/>TST/          {          les       di,>tst[bp]  ; ES:DI to start}
  $8C/$C0/               {          mov       ax,es        ; match segments}
  $8E/$D8/               {          mov       ds,ax}
  $89/$FB/               {          mov       bx,di        ; save start}
  $8A/$86/>STRP/         {          mov       al,>strp[bp] ; char to strip}
  $29/$C9/               {          sub       cx,cx        ; zero in CX}
  $8A/$0D/               {          mov       cl,[di]      ; length in CX}
  $89/$CA/               {          mov       dx,cx        ; save original length}
  $C7/$46/$FE/$00/$00/   {          mov       wo [bp-2],0  ; set result of zero}
  $E3/$1C/               {          jcxz      quit         ; exit if null}
  $47/                   {          inc       di}
  $3A/$05/               {          cmp       al,[di]      ; check first char}
  $75/$17/               {          jne       quit         ; exit if no match}
  $47/                   {          inc       di           ; next char}
  $49/                   {          dec       cx           ; already checked first one}
  $FC/                   {          cld                    ; frontwards}
  $F3/$AE/               {repe      scasb                  ; do search after first}
  $74/$07/               {          je        null         ; if stripping whole line}
  $89/$FE/               {          mov       si,di        ; char after last match}
  $89/$DF/               {          mov       di,bx        ; to start of string}
  $47/                   {          inc       di}
  $4E/                   {          dec       si           ;}
  $41/                   {          inc       cx}
  $89/$0F/               {null:     mov       [bx],cx      ; to get length right}
  $29/$CA/               {          sub       dx,cx        ;number of bytes stripped}
  $89/$56/$FE/           {          mov       [bp-2 ],dx   ;move that to function result}
  $F2/$A4/               {rep       movsb                  ; delete}
  $1F                    {quit:     pop       ds}
 );                      {end;}
end;

Procedure StripR {(var tst;strp:char)};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push      ds}
  $C4/$BE/>TST/          {          les       di,>tst[bp] ; ES:DI to start}
  $8C/$C0/               {          mov       ax,es}
  $8E/$D8/               {          mov       ds,ax}
  $89/$FB/               {          mov       bx,di       ; save start}
  $8A/$86/>STRP/         {          mov       al,>strp[bp]; char to strip}
  $29/$C9/               {          sub       cx,cx       ; zero  CX}
  $8A/$0D/               {          mov       cl,[di]     ; length in CX}
  $E3/$0E/               {          jcxz      quit        ; exit if null}
  $01/$CF/               {          add       di,cx       ;start at far end of string}
  $3A/$05/               {          cmp       al,[di]     ;check last character}
  $75/$08/               {          jne       quit        ;exit if no match}
  $FD/                   {          std                   ;scan backwards}
  $F3/$AE/               {repe      scasb                 ;search for first non-matching byte}
  $74/$01/               {          je        null        ;if you are stripping all characters}
  $41/                   {          inc       cx          ;fix length}
  $88/$0F/               {null:     mov       [bx],cl     ;new length}
  $1F);                  {quit:     pop       ds}
end;

Procedure StripThrough {(var tst;strp:char)};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push      ds}
  $C4/$BE/>TST/          {          LES       DI,>TST[BP]   ; ES:DI to start}
  $89/$FB/               {          MOV       BX,DI         ; save start}
  $8C/$C0/               {          mov       ax,es}
  $8E/$D8/               {          mov       ds,ax}
  $8A/$86/>STRP/         {          MOV       AL,>STRP[BP]   ; char to strip through}
  $29/$C9/               {          SUB       CX,CX          ; zero in CX}
  $8A/$0D/               {          MOV       CL,[DI]        ; length in CX}
  $E3/$0F/               {          JCXZ      QUIT           ; exit if null}
  $47/                   {          INC       DI             ; first char}
  $FC/                   {          CLD                      ; frontwards}
  $F2/$AE/               {REPNE     SCASB                    ; do search}
  $75/$09/               {          JNE       QUIT           ; not found}
  $89/$FE/               {          MOV       SI,DI          ; char after, start move here}
  $89/$DF/               {          MOV       DI,BX}
  $47/                   {          INC       DI}
  $89/$0F/               {          MOV       [BX],cx        ; to get length right}
  $F2/$A4/               {REP       MOVSB                    ; delete leading characters}
  $1F                    {QUIT:     pop       ds}
 );                      {end;}
end;

Procedure SwapSubstring { (Var tline; find, repl:string;
                         Var enough:boolean; limit:byte)};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push      ds}
  $8D/$B6/>FIND/         {          lea       si,>find[bp]        ;address find}
  $36/$8A/$14/           {       ss:mov       dl, [si]            ;store length of find}
  $36/$8A/$44/$01/       {       ss:mov       al [si+1]           ;store first find character in al}
  $8D/$B6/>REPL/         {          lea       si,>repl[bp]        ;address repl}
  $36/$8A/$34/           {       ss:mov       dh,[si]             ;store length of repl}
  $88/$D4/               {          mov       ah, dl}
  $28/$F4/               {          sub       ah,dh               ;find difference in length of strings}
  $C4/$BE/>ENOUGH/       {          les       di,>enough[bp]      ;initialize flag}
  $C6/$05/$01/           {          mov       by [di],1}
  $C4/$BE/>TLINE/        {          les       di, >tline[BP]      ;address of string to modify}
  $8C/$C3/               {          mov       bx,es               ;match segments}
  $8E/$DB/               {          mov       ds,bx}
  $89/$FB/               {          mov       bx,di               ;save tline address}
  $31/$C9/               {          xor       cx,cx               ;zero out cx}
  $8A/$0D/               {          mov       cl,[di]             ;length tline to cl}
  $E3/$03/               {          jcxz      j1                  ;exit if tline null}
  $E9/$03/$00/           {          jmp       j2}
  $E9/$8E/$00/           {j1:       jmp       quit}
  $47/                   {j2:       inc       di                  ;to start of string}
  $38/$D1/               {scan:     cmp       cl, dl              ;is remaining string>find?}
  $72/$F8/               {          jb        j1                  ;exit if not enough left for a match}
  $FC/                   {          cld                           ;move forwards}
  $F2/$AE/               {repne     scasb                         ;search for first char}
  $75/$F3/               {          jne       j1                  ;exit if not found}
  $51/                   {          push      cx                  ;save no. of bytes left after match}
  $4F/                   {          dec       di                  ;to match position}
  $57/                   {          push      di                  ;save position after match}
  $8D/$B6/>FIND+$0001/   {          lea       si, >find[bp]+1}
  $88/$D1/               {          mov       cl, dl              ;get length of find string}
  $F3/$36/$A6/           {repe   ss:cmpsb                         ;match on find string?}
  $5F/                   {          pop       di                  ;start of match test}
  $59/                   {          pop       cx                  ;bytes then remaining}
  $75/$E6/               {          jne       j2                  ;cycle if no match}
                         {;gets here if you found a match. Now compare find and replace strings}
  $FE/$C1/               {          inc       cl                  ;bytes from beginning of match}
  $80/$FC/$00/           {          cmp       ah,0                ;test which branch to follow}
  $74/$52/               {          je        moveq               ;skip string adjust if find=repl}
  $7C/$1B/               {          jl        longrep             ;jump if repl >find}
                         {;if find > repl, need to close up the gap resulting from replacing}
  $28/$D1/               {          sub       cl,dl               ;no of bytes from end of find string}
  $51/                   {          push      cx                  ;save it}
  $57/                   {          push      di                  ;save beginning of match}
  $89/$FE/               {          mov       si, di              ;make both start of match}
  $53/                   {          push      bx                  ;clear some workspace}
  $31/$DB/               {          xor       bx, bx              ; "}
  $88/$F3/               {          mov       bl, dh              ;len(repl)}
  $01/$DF/               {          add       di, bx              ;add to get destination address}
  $88/$D3/               {          mov       bl, dl              ;len(find)}
  $01/$DE/               {          add       si, bx              ;add to get source address}
  $5B/                   {          pop       bx                  ;restore}
  $28/$27/               {          sub       [bx],ah             ;shrink tline[0]}
  $F2/$A4/               {rep       movsb                         ;close the gap}
  $5F/                   {          pop       di                  ;get back start of match}
  $59/                   {          pop       cx                  ;get back bytes after replacing}
  $E9/$37/$00/           {          jmp       movr                ;go do the replacement}
                         {;if repl> find, increase the gap}
  $57/                   {longrep:  push      di}
                         {;test whether this would make string too long}
  $F6/$DC/               {          neg       ah}
  $52/                   {          push      dx                  ;get some workspace}
                         {;if you do not like using the parameter limit, you can fix}
                         {;the limit by replacing the following line with the commented}
                         {;line after it.  Then you can replace 255 with whatever length less}
                         {;than that you want.}
  $8A/$B6/>LIMIT/        {          mov       dh,[>limit[bp]]     ;get maximum string length}
                         {;         mov       dh,255              ;get max string length}
  $28/$E6/               {          sub       dh,ah               ;find longest string you can add to}
  $8A/$17/               {          mov       dl,[bx]             ;get actual current length}
  $38/$F2/               {          cmp       dl,dh               ;compare them}
  $77/$37/               {          ja        j5                  ;stop if max<actual, but pop first}
  $5A/                   {          pop       dx                  ;restore}
  $00/$27/               {          add       by [bx],ah          ;increase string length}
                         {;now need to make room for the replace}
  $53/                   {          push      bx                  ;save tline address}
  $02/$1F/               {          add       bl,[bx]             ;get end of tline}
  $73/$02/               {          jnc       j4}
  $FE/$C7/               {          inc       bh                  ;add one if a carry}
  $89/$DF/               {j4:       mov       di,bx               ;move to end of lengthened string}
                         {;now need where you are moving it too}
  $31/$DB/               {          xor       bx,bx               ;clear some space}
  $88/$E3/               {          mov       bl,ah               ;get the increment}
  $89/$FE/               {          mov       si,di               ;move the address}
  $29/$DE/               {          sub       si,bx               ;get end of string before increment}
  $5B/                   {          pop       bx                  ;restore}
  $51/                   {          push      cx                  ;save bytes after first match}
  $28/$D1/               {          sub       cl,dl               ;don't move bytes in find}
  $FD/                   {          std                           ;change direction}
  $F2/$A4/               {rep       movsb                         ;move the string down}
  $FC/                   {          cld                           ;get the direction again}
  $59/                   {          pop       cx                  ;restore}
  $5F/                   {          pop       di                  ;restore.}
  $28/$D1/               {          sub       cl,dl               ;subtract find from remaining bytes}
  $F6/$DC/               {          neg       ah}
  $E9/$02/$00/           {          jmp       movr                ;go get the replace}
                         {;now fix up cx for equal strings}
  $28/$F1/               {moveq:    sub       cl,dh               ;bytes remaining after repl}
                         {;now move repl into place}
  $51/                   {movr:     push      cx                  ;save bytes remaining}
  $8D/$B6/>REPL+$0001/   {          lea       si, [>repl[bp]+1]         ;get replace string}
  $31/$C9/               {          xor       cx,cx               ;clear it out}
  $88/$F1/               {          mov       cl,dh               ;get bytes to move- len(repl)}
  $F2/$36/$A4/           {rep    ss:movsb                         ;move replacement string}
  $59/                   {          pop       cx                  ;bytes remaining.di should be ok}
  $E9/$7C/$FF/           {          jmp       near scan           ;look for next match}
  $5A/                   {j5:       pop       dx                  ;clean up stack}
  $C4/$BE/>ENOUGH/       {          les       di, >enough[bp]     ;not enough to make all swaps}
  $C6/$05/$00/           {          mov       by [di],0}
  $5F/                   {          pop       di}
  $1F                    {quit:     pop       ds}
 );                      {end;}
end;

Function Stringup {(tline:string):string};

Begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push ds               ;save things for later}
  $C5/$76/$06/           {          lds  si, [bp+06]   ;addressing of the string}
  $FC/                   {          cld                   ;move forward}
  $31/$C9/               {          xor  cx,cx}
  $8A/$0C/               {          mov  cl,[si]          ;string length to cl}
  $C4/$7E/$0A/           {          les di, [bp+10]        ;point di to function result}
  $26/$88/$0D/           {     es:  mov [di],cl           ;and move length to function result}
  $E3/$10/               {          jcxz l2}
  $46/                   {          inc  si               ;point to start of string}
  $47/                   {          inc  di               ;and where it goes}
  $AC/                   {l1:       lodsb                 ;get byte from string}
  $3C/$61/               {          cmp  al,'a'           ;tests from Turbo manual}
  $72/$06/               {          jb   l3}
  $3C/$7A/               {          cmp  al,'z'}
  $77/$02/               {          ja   l3}
  $2C/$20/               {          sub  al,$20}
  $AA/                   {l3:       stosb                 ;store result}
  $E2/$F2/               {          loop l1}
  $1F);                  {l2:       pop ds}
end;

Procedure StupCase {(var tline)};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push ds}
  $C5/$B6/>TLINE/        {          lds  si, >tline[bp]}
  $8A/$0C/               {          mov  cl,[si]}
  $FE/$C1/               {          inc  cl}
  $FE/$C9/               {l1:       dec  cl}
  $74/$10/               {          jz   l2}
  $46/                   {          inc  si}
  $80/$3C/$61/           {          cmp  by[si],'a'}
  $72/$F6/               {          jb   l1}
  $80/$3C/$7A/           {          cmp  by[si],'z'}
  $77/$F1/               {          ja   l1}
  $80/$2C/$20/           {          sub  by[si],$20}
  $EB/$EC/               {          jmp  short l1}
  $1F);                  {l2:       pop  ds}
end;

Procedure LowCase {(var tline)};

begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push ds}
  $C4/$BE/>TLINE/        {          les  di, >tline[bp]}
  $8C/$C0/               {          mov  ax,es}
  $8E/$D8/               {          mov  ds,ax}
  $8A/$0D/               {          mov  cl,[di]}
  $FE/$C1/               {          inc  cl}
  $FE/$C9/               {l1:       dec  cl}
  $74/$10/               {          jz   l2}
  $47/                   {          inc  di}
  $80/$3D/$41/           {          cmp  by[di],'A'}
  $72/$F6/               {          jb   l1}
  $80/$3D/$5A/           {          cmp  by[di],'Z'}
  $77/$F1/               {          ja   l1}
  $80/$05/$20/           {          add  by[di],$20}
  $EB/$EC/               {          jmp  short l1}
  $1F);                  {l2:       pop  ds}
end;

Procedure FlipChar {(var tst; srch, repl: char)};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $C4/$BE/>TST/          {          LES       DI,>TST[BP] ; ES:DI to start}
  $8A/$86/>SRCH/         {          MOV       AL,>SRCH[BP] ; search char}
  $8A/$A6/>REPL/         {          MOV       AH,>REPL[BP] ; repl. char}
  $29/$C9/               {          SUB       CX,CX     ; zero in CX}
  $8A/$0D/               {          MOV       CL,[DI]   ; length in CX}
  $E3/$0D/               {          JCXZ      QUIT      ; exit if null}
  $47/                   {          INC       DI        ; first char}
  $FC/                   {          CLD                 ; frontwards}
  $E3/$09/               {MORE:     JCXZ      QUIT      ; no more}
  $F2/$AE/               {REPNE     SCASB               ; do search}
  $75/$05/               {          JNE       QUIT      ; not found}
  $88/$65/$FF/           {          MOV       [DI-1],AH ; replace}
  $EB/$F5/               {          JMP       MORE      ; try for more}
  $90);                  {QUIT:     NOP                 ; exit}
end;

Function FlipCount {(var tst;srch,repl:char):integer};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
                         {;Function FlipCount(var tst;srch,repl:char):integer;}
                         {;(*  Tst is a string.  This is identical to the procedure}
                         {; Flipchar except that the function returns the number of}
                         {; times the search character was replaced by the find character.}
                         {; Written 2/16/86 by D. Seidman, based on Flipchar by M. Lazarus*)}
  $1E/                   {          push      ds}
  $C4/$BE/>TST/          {          les       di,>tst[BP] ; ES:DI to start}
  $8C/$C0/               {          mov       ax,es}
  $8E/$D8/               {          mov       ds,ax}
  $8A/$86/>SRCH/         {          mov       al,>srch[BP] ; search char}
  $8A/$A6/>REPL/         {          mov       ah,>repl[BP] ; repl. char}
  $31/$DB/               {          xor       bx,bx     ;zero in bx -- for counting}
  $31/$C9/               {          xor       cx,cx     ; zero in CX}
  $8A/$0D/               {          mov       cl,[di]   ; length in CX}
  $E3/$0E/               {          jcxz      quit      ; exit if null}
  $47/                   {          inc       di        ; first char}
  $FC/                   {          cld                 ; frontwards}
  $E3/$0A/               {more:     jcxz      quit      ; no more}
  $F2/$AE/               {repne     scasb               ; do search}
  $75/$06/               {          jne       quit      ; not found}
  $43/                   {          inc       bx        ;count it}
  $88/$65/$FF/           {          mov       [di-1],ah ; replace}
  $EB/$F4/               {          jmp       more      ; try for more}
  $89/$5E/$FE/           {quit:     mov       [bp-2],bx ;get function result}
  $1F);                  {          pop       ds}
end;

Procedure StripChar {(var tst; strp: char)};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
                         {;procedure stripchar(var tst; strp: char);}
  $1E/                   {          PUSH      DS        ; save for exit}
  $C4/$BE/>TST/          {          LES       DI,>TST[BP] ; ES:DI to start}
  $89/$FB/               {          MOV       BX,DI     ; save start}
  $8C/$C0/               {          MOV       AX,ES     ; match segments}
  $8E/$D8/               {          MOV       DS,AX     ;   (same)}
  $8A/$86/>STRP/         {          MOV       AL,>STRP[BP] ; char to strip}
  $29/$C9/               {          SUB       CX,CX     ; zero in CX}
  $8A/$0D/               {          MOV       CL,[DI]   ; length in CX}
  $E3/$16/               {          JCXZ      QUIT      ; exit if null}
  $47/                   {          INC       DI        ; first char}
  $FC/                   {          CLD                 ; frontwards}
                         {MORE:}
  $F2/$AE/               {REPNE     SCASB               ; do search}
  $75/$10/               {          JNE       QUIT      ; not found}
  $57/                   {          PUSH      DI        ; save locn}
  $51/                   {          PUSH      CX        ; bytes to go}
  $89/$FE/               {          MOV       SI,DI     ; char after}
  $4F/                   {          DEC       DI        ; destination}
  $F2/$A4/               {REP       MOVSB               ; delete}
  $FE/$0F/               {          DEC       BY [BX]   ; decr length}
  $59/                   {          POP       CX        ; bytes to go}
  $5F/                   {          POP       DI        ; last locn}
  $4F/                   {          DEC DI              ; char gone}
  $E3/$02/               {          JCXZ      QUIT      ; no more}
  $EB/$EC/               {          JMP       MORE      ; try again}
  $1F);                  {QUIT:     POP       DS        ; restore for exit}
end;

Function Count {(var tst; srch:char):integer};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push      ds}
  $C4/$BE/>TST/          {          les       di,>tst[BP] ; ES:DI to start}
  $8C/$C0/               {          mov       ax,es}
  $8E/$D8/               {          mov       ds,ax}
  $8A/$86/>SRCH/         {          mov       al,>srch[BP] ; search char}
  $31/$DB/               {          xor       bx,bx     ;zero in bx -- for counting}
  $31/$C9/               {          xor       cx,cx     ; zero in CX}
  $8A/$0D/               {          mov       cl,[di]   ; length in CX}
  $E3/$0B/               {          jcxz      quit      ; exit if null}
  $47/                   {          inc       di        ; first char}
  $FC/                   {          cld                 ; frontwards}
  $E3/$07/               {more:     jcxz      quit      ; no more}
  $F2/$AE/               {repne     scasb               ; do search}
  $75/$03/               {          jne       quit      ; not found}
  $43/                   {          inc       bx        ;count it}
  $EB/$F7/               {          jmp       more      ; try for more}
  $89/$5E/$FE/           {quit:     mov       [bp-2],bx ;get function result}
  $1F);                  {          pop       ds}
end;

Function HowMany {(var str1,str2):integer};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
                         {;Function HowMany(var str1,str2):integer;}
                         {;str1 and str2 are strings of any type.}
                         {;function compares them character by}
                         {;character for up to min(length(str1),length(str2))}
                         {;characters.  Function is the number of consecutive}
                         {;characters (starting with string 1) for which the}
                         {;two strings are equal. e.g., if str1 is cats and}
                         {;str2 is catchup, function result is 3.  If str1 is}
                         {;cat and str2 is dog, function result is 0.}
  $1E/                   {        push    ds}
  $C5/$B6/>STR1/         {        lds     si, >str1[bp]   ;addressing str1}
  $C4/$BE/>STR2/         {        les     di, >str2[bp]   ;addressing str2}
  $31/$C9/               {        xor     cx,cx           ;zero cx}
  $8A/$0D/               {        mov     cl,[di]         ;get length str2}
  $3A/$0C/               {        cmp     cl,[si]         ;compare lengths}
  $72/$02/               {        jb      diless}
  $8A/$0C/               {siless: mov     cl, [si]}
  $89/$CB/               {diless: mov     bx, cx          ;save length}
  $E3/$0A/               {        jcxz    j2}
  $FC/                   {        cld                     ;move forward}
  $46/                   {        inc     si              ;to start of string}
  $47/                   {        inc     di              ; "}
  $F3/$A6/               {repe    cmpsb                   ;string compare}
  $74/$01/               {        je      j1              ;equal for full length}
  $41/                   {        inc     cx              ;correct, last byte ne}
  $29/$CB/               {j1:     sub     bx,cx           ;# matching bytes}
  $89/$5E/$FE/           {j2:     mov     [bp-2],bx       ;function result}
  $1F);                  {        pop     ds}
end;

Function Equal_Structures {(var a,b;size:integer):boolean};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {       push   ds}
  $C6/$46/$FF/$01/       {       mov    by [bp-1],1  ;set up a true result}
  $C4/$BE/>A/            {       les    di,>a[bp]     ;get first structure, es:di}
  $C5/$B6/>B/            {       lds    si,>b[bp]     ;get second structure, ds:si}
  $8B/$8E/>SIZE/         {       mov    cx,>size[bp]  ;get length of structures}
  $FC/                   {       cld}
  $F3/$A6/               {repe   cmpsb                ;compare, byte by byte}
  $74/$04/               {       je     quit          ;if still equal, done}
  $C6/$46/$FF/$00/       {       mov    by [bp-1],0  ;set result for unequal}
  $1F);                  {quit:  pop    ds}
end;

Function space {(N:integer; C:char):string};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $8B/$8E/>N/            {      mov     cx,>N[bp]}
  $C4/$7E/$0A/           {      les     di, [bp+10]}
  $26/$88/$0D/           {  es: mov     [di],cl}
  $31/$C0/               {      xor     ax,ax}
  $8A/$46/<C/            {      mov     al,<C[bp]}
  $47/                   {      inc     di}
  $FC/                   {      cld}
  $F2/$AA);              {    rep  stosb}
end;

procedure blanker {(var tline:string)};
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $C4/$BE/>TLINE/        {          les       di,>tline[BP]}
  $31/$C9/               {          xor       cx,cx}
  $26/$8A/$0D/           { es:      mov       cl,[di]      ;length to cl}
  $E3/$0E/               {          jcxz      quit         ; exit if null}
  $B0/$20/               {          mov       al,32        ; move space to al}
  $89/$FB/               {          mov       bx,di        ;save tline start}
  $47/                   {          inc       di           ; to first char}
  $FC/                   {          cld                    ; frontwards}
  $F3/$AE/               {repe      scasb                  ; repeat while space}
  $75/$04/               {          jne       quit         ; exit if a non-space found}
  $26/$C6/$07/$00        { es:      mov      by [bx],0     ; null string if all spaces}
 );                      {quit:}
end;

Function Break (Search: string; var tline): byte;
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $8D/$B6/>SEARCH/       {          lea  si,>search[bp]}
  $31/$C9/               {          xor  cx,cx}
  $36/$8A/$0C/           {       ss:mov  cl, [si]            ;no. of search items}
  $C4/$BE/>TLINE/        {          les  di, >tline[bp]}
  $31/$DB/               {          xor  bx,bx}
  $26/$8A/$1D/           {     es:  mov  bl, [di]            ;save length tline}
  $47/                   {          inc  di                  ;point to tline start}
  $89/$FA/               {          mov  dx,di               ;save tline start}
  $B4/$00/               {          mov  ah,0                ;default function result}
  $E3/$2A/               {          jcxz done}
  $80/$FB/$00/           {          cmp  bl,0}
  $74/$25/               {          je   done}
  $FC/                   {          cld}
  $80/$FC/$01/           { again:   cmp  ah,1                ;done if found at tline[1]}
  $74/$1F/               {          je   done}
  $46/                   {          inc  si                  ;next item in search}
  $36/$8A/$04/           {      ss: mov  al,[si]             ;load for search}
  $51/                   {          push cx                  ;save loop count}
  $89/$D9/               {          mov  cx,bx               ;string length}
  $89/$D7/               {          mov  di,dx               ;byte 1 of tline}
  $F2/$AE/               {  repne   scasb                    ;search for item}
  $75/$0F/               {          jne recycle              ; not found.}
  $F7/$D9/               {          neg  cx                  ; found. find where}
  $01/$D9/               {          add  cx,bx               ; position in tline}
  $80/$FC/$00/           {          cmp  ah,0}
  $74/$04/               {          je   fix}
  $38/$E1/               {          cmp  cl,ah               ;check against f. result}
  $77/$02/               {          ja   recycle             ;if after, leave old result}
  $88/$CC/               { fix:     mov  ah,cl               ;save new result}
  $59/                   { recycle: pop  cx                  ; restore loop counter}
  $E2/$DC/               {          loop again}
  $88/$66/$FF);          { done:    mov [bp-1], ah           ;store result}
end;

Function Break2 (search,tline:string):byte;
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push ds}
  $8C/$D3/               {          mov  bx, ss}
  $8E/$C3/               {          mov  es, bx}
  $8E/$DB/               {          mov  ds, bx}
  $8D/$B6/>TLINE/        {          lea  si, >tline[bp]}
  $31/$C9/               {          xor  cx,cx}
  $8A/$0C/               {          mov  cl, [si]            ;length tline in cl for loop}
  $E3/$22/               {          jcxz L1a}
  $88/$CB/               {          mov  bl, cl              ;and save for later}
  $8D/$BE/>SEARCH/       {          lea  di, >search[bp]}
  $8A/$25/               {          mov  ah, [di]            ;length search stored in ah}
  $80/$FC/$00/           {          cmp  ah,0}
  $74/$15/               {          je   L1a}
  $47/                   {          inc  di                  ;point to first char in search}
  $89/$FA/               {          mov  dx,di               ;and save it}
  $FC/                   {          cld}
  $46/                   {L1:       inc  si                  ;begin loop. Move through tline}
  $89/$D7/               {          mov  di,dx               ;start of search}
  $8A/$04/               {          mov  al, [si]            ;tline char to set up search}
  $88/$CF/               {          mov  bh,cl               ;store loop index}
  $88/$E1/               {          mov  cl,ah               ;length search controls search}
  $F2/$AE/               {repne     scasb}
  $88/$F9/               {          mov  cl,bh               ;restore loop index}
  $74/$09/               {          je   L2                  ;found the char in search}
  $E2/$EF/               {          loop L1}
  $C6/$46/$FF/$00/       {L1a:      mov  by [bp-1],0         ;if here, no match}
  $E9/$07/$00/           {          jmp  L3}
  $28/$FB/               {L2:       sub  bl,bh}
  $FE/$C3/               {          inc  bl}
  $88/$5E/$FF/           {          mov  [bp-1],bl}
  $1F);                  {L3:       pop  ds}
end;

Function Span(search,tline:string):byte;
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $1E/                   {          push ds}
  $8C/$D3/               {          mov  bx, ss}
  $8E/$C3/               {          mov  es, bx}
  $8E/$DB/               {          mov  ds, bx}
  $8D/$B6/>TLINE/        {          lea  si, >tline[bp]}
  $31/$C9/               {          xor  cx,cx}
  $8A/$0C/               {          mov  cl, [si]            ;length tline in cl for loop}
  $88/$CB/               {          mov  bl, cl              ;and save for later}
  $E3/$24/               {          jcxz L4}
  $8D/$BE/>SEARCH/       {          lea  di, >search[bp]}
  $8A/$25/               {          mov  ah, [di]            ;length search stored in ah}
  $47/                   {          inc  di                  ;point to first char in search}
  $89/$FA/               {          mov  dx,di               ;and save it}
  $FC/                   {          cld}
  $46/                   {L1:       inc  si                  ;begin loop. Move through tline}
  $89/$D7/               {          mov  di,dx               ;start of search}
  $8A/$04/               {          mov  al, [si]            ;tline char to set up search}
  $88/$CF/               {          mov  bh,cl               ;store loop index}
  $88/$E1/               {          mov  cl,ah               ;length search controls search}
  $F2/$AE/               {repne     scasb}
  $88/$F9/               {          mov  cl,bh               ;restore loop index}
  $75/$08/               {          jne  L2                  ;found char not in search}
  $E2/$EF/               {          loop L1}
  $88/$5E/$FF/           {          mov  by [bp-1],bl        ;if here, all in search}
  $E9/$06/$00/           {          jmp  L3}
  $28/$FB/               {L2:       sub  bl,bh}
  $90/                   {          nop}
  $88/$5E/$FF/           {L4:       mov  [bp-1],bl}
  $1F                    {L3:       pop  ds}
 );                      {end;}
end;

Function LastPosC (find: char; var tst): integer;
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
  $C4/$BE/>TST/          {          les       di,>tst[bp]    ;get string length}
  $C7/$46/$FE/$00/$00/   {          mov       wo [bp-2],0    ;result if nothing found or}
                         {                                   ; length 0}
  $8A/$86/>FIND/         {          mov       al,>find[bp]   ;get the character}
  $31/$C9/               {          xor       cx,cx}
  $26/$8A/$0D/           {      es: mov       cl,[di]        ;get length}
  $E3/$0B/               {          jcxz      quit           ;stop if zero length}
  $01/$CF/               {          add       di, cx}
  $FD/                   {          std                      ;move backward}
  $F2/$AE/               {repne     scasb}
  $75/$04/               {          jne       quit           ;stop if not found}
  $41/                   {          inc       cx}
  $89/$4E/$FE            {          mov       [bp-2],cx      ;save result}
 );                      {quit:}
end;

Function WildPosAfter(find:string; var tline ; after:integer):integer;
begin
Inline(                  {Assembly by Inline 02/23/88 21:28}
                         {;accepts as a wildcard in find ASCII 255}
  $1E/                   {          push ds}
  $C4/$BE/>TLINE/        {          les  di, >tline[bp]}
  $8B/$9E/>AFTER/        {          mov  bx, >after[bp]      ;in bl}
  $30/$FF/               {          xor  bh,bh}
  $8D/$B6/>FIND/         {          lea  si, >find[bp]}
  $C7/$46/$FE/$00/$00/   {          mov  wo [bp-2], 0        ;initialize for not found result}
  $16/                   {          push ss}
  $1F/                   {          pop  ds                  ;because find in ss}
  $26/$8A/$05/           {      es: mov  al, [di]            ;length of tline in al, to move to bh}
  $3C/$00/               {          cmp  al,0}
  $74/$40/               {          je   L5}
  $38/$C3/               {          cmp  bl,al}
  $77/$3C/               {          ja   L5}
  $28/$D8/               {          sub  al,bl               ;adjust length for starting point}
  $01/$DF/               {          add  di, bx              ;adjust tline start for after}
  $88/$C7/               {          mov  bh,al}
  $8A/$24/               {          mov  ah, [si]            ;length of find}
  $80/$FC/$00/           {          cmp  ah, 0}
  $74/$2F/               {          je   L5}
  $46/                   {          inc  si                  ;point to start of find}
  $56/                   {          push si                  ;save start of find}
  $31/$C9/               {          xor  cx,cx}
  $47/                   {          inc  di                  ;to start of tline}
  $89/$FA/               {          mov  dx, di              ;save start of tline}
  $FC/                   {          cld}
  $38/$FC/               {L1:       cmp  ah, bh              ;is enough left for match?}
  $77/$22/               {          ja   L4                  ;not enough, so jump out}
  $5E/                   {          pop  si                  ;restore start of find}
  $56/                   {          push si                  ;and save it again}
  $89/$D7/               {          mov  di,dx               ;get start of remaining tline}
  $88/$E1/               {          mov  cl,ah               ;set loop for length of find}
  $AC/                   {L2:       lodsb}
  $3C/$FF/               {          cmp  al, 255             ;check for wildcard}
  $74/$0D/               {          je   L3                  ; recycle if wild}
  $26/$3A/$05/           {      es: cmp al, [di]             ; not wild, check against tline}
  $74/$08/               {          je   L3                  ;recycle if match}
                         {;gets here if no match}
  $42/                   {          inc  dx                  ;new starting point for tline}
  $FE/$C3/               {          inc  bl                  ;count up in tline}
  $FE/$CF/               {          dec  bh                  ;shorten tline}
  $EB/$E5/               {          jmp  L1}
  $90/                   {          nop}
  $47/                   { L3:      inc  di                  ;move to next character to search}
  $E2/$EB/               {          LOOP L2                  ;and recycle to check next in find}
                         {                                   ;here only if everything matches}
  $FE/$C3/               {          inc  bl                  ;to get right match start}
  $30/$FF/               {          xor  bh,bh}
  $89/$5E/$FE/           {          mov  [bp-2],bx           ;function result}
  $5E/                   {L4:       pop  si                  ;only to clear}
  $1F);                  {L5:       pop  ds                  ;to restore}
end;
end.
