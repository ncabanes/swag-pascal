{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
{$M 16384,0,655360}
{$DEFINE Kort}
Program Extract;
  { extract filenames and accompanying descriptions from bbs files listings }
  { Author: Eddy Thilleman, 19 mei 1994 }
  { written in Borland Pascal version 7.01 }
  {  modified: augustus 1994 - choose between long vs. short directory name }
  {  modified: januari  1995 - keep only filenames with entries found on screen
                             - total number of found entries
                             - delete destination directory if no entries found }

Uses
  Dos;

Type
  TypeNotAllowed = set of char;  { filter out (some) header lines }
Const
  NotAllowed : TypeNotAllowed = [''..' ','*',':'..'?','|','░'..'▀'];
  NoFAttr : word =   $1C;  { dir-, volume-, system attributen }
  FAttr   : word =   $23;  { readonly-, hidden-, archive attributes }
  BufSizeBig     = 49152;  { 48 KB }
  BufSizeSmall   =  8192;  {  8 KB }
  Cannot         = 'Cannot create destination ';
  MaxNrLines     =    20;  { max # of lines for one entry }
  MaxNrSearch    =    18;  { max # of words to search for }

Type
  BufTypeSource  = array [1..BufSizeBig  ] of char;
  BufTypeDest    = array [1..BufSizeSmall] of char;
  string3        = string[03];
  String12       = string[12];
  String16       = string[16];
  String25       = string[25];
  String65       = string[65];
  TypeLine       = array [1..MaxNrLines] of string;

Var
  Line             : TypeLine;         { filename and description  }
  Tmp1, Tmp2       : string;           { temporary hold lines here }
  FileName         : String12;         { filename in files listing }
  SearchText       : array [1..MaxNrSearch] of String65;
  Count, TotalCount: word;             { # of found entries        }
  SourceFile, DestFile : text;         { sourcefile and dest. file }
  SourceBuf        : BufTypeSource;    { source text buffer        }
  DestBuf          : BufTypeDest;      { destination text buffer   }
{$IFDEF Kort}
  DestListing      : string16;         { name of destination file  }
  DestDir          : string3 ;         { name of destination directory }
{$ELSE}
  DestListing      : string25;         { name of destination file  }
  DestDir          : string12;         { name of destination directory }
{$ENDIF}
  FR               : SearchRec;        { FileRecord }
  FMask, DirName   : String12;
  Exists           : boolean;
  nr,                                  { nr: points to element# where
                                             to put the next read-in line   }
  NrLines          : byte;             { NrLines: number of lines belonging
                                             to this entry }
  found, Header    : boolean;
  T                : byte;             { points to char in line: allowed? }
  NrSearch,                            { current word to search for       }
  TotalNrSearch    : byte;             { total # of words to search for   }


procedure LowerFast( var Str: String );
  { 52 Bytes by Bob Swart, 11-6-1993, '80XXX' FASTEST! }
InLine(
  $8C/$DA/               {       mov   DX,DS                 }
  $BB/Ord('A')/
      Ord('Z')-Ord('A')/ {       mov   BX,'Z'-'A'/'A'        }
  $5E/                   {       pop   SI                    }
  $1F/                   {       pop   DS                    }
  $FC/                   {       cld                         }
  $AC/                   {       lodsb                       }
  $88/$C1/               {       mov   CL,AL                 }
  $30/$ED/               {       xor   CH,CH                 }
  $D1/$E9/               {       shr   CX,1                  }
  $73/$0B/               {       jnc   @Part1                }
  $AC/                   {       lodsb                       }
  $28/$D8/               {       sub   AL,BL                 }
  $38/$F8/               {       cmp   AL,BH                 }
  $77/$04/               {       ja    @Part1                }
  $80/$44/$FF/
      Ord('a')-Ord('A')/ {@Loop: ADD   Byte Ptr[SI-1],'a'-'A'}
  $E3/$14/               {@Part1:jcxz  @Exit                 }
  $AD/                   {       lodsw                       }
  $28/$D8/               {       sub   AL,BL                 }
  $38/$F8/               {       cmp   AL,BH                 }
  $77/$04/               {       ja    @Part2                }
  $80/$44/$FE/
      Ord('a')-Ord('A')/ {       ADD   Byte Ptr[SI-2],'a'-'A'}
  $49/                   {@Part2:dec   CX                    }
  $28/$DC/               {       sub   AH,BL                 }
  $38/$FC/               {       cmp   AH,BH                 }
  $77/$EC/               {       ja    @Part1                }
  $EB/$E6/               {       jmp   @Loop                 }
  $8E/$DA                {@Exit: mov   DS,DX                 }
) { LowerFast };


procedure CopySubStr( Str1: string; start, nrchars: byte; var Str2: string );
assembler;
  { copy part of Str1 (beginning at start for nrchars) to Str2
    if start > length of Str1, Str2 will contain a empty string.
    if nrchars specifies more characters than remain starting at the
    start position, Str2 will contain just that remainder of Str1. }
asm     { setup }
        lds   si, str1     { load in DS:SI pointer to str1 }
        cld                { string operations forward     }
        les   di, str2     { load in ES:DI pointer to str2 }
        mov   ah, [si]     { length str1 --> AH            }
        and   ah, ah       { length str1 = 0?              }
        je    @null        { yes, empty string in Str2     }
        mov   bl, [start]  { starting position --> BL      }
        cmp   ah, bl       { start > length str1?          }
        jb    @null        { yes, empty string in Str2     }

        { start + nrchars - 1 > length str1?               }
        mov   al, [nrchars]{ nrchars --> AL                }
        mov   dh, al       { nrchars --> DH                }
        add   dh, bl       { add start                     }
        dec   dh
        cmp   ah, dh       { nrchars > rest of str1?       }
        jb    @rest        { yes, copy rest of str1        }
        jmp   @copy
@null:  xor   ax, ax       { return a empty string         }
        jmp   @done
@rest:  sub   ah, bl       { length str1 - start           }
        inc   ah
        mov   al, ah
@copy:  mov   cl, al       { how many chars to copy        }
        xor   ch, ch       { clear CH                      }
        xor   bh, bh       { clear BH                      }
        add   si, bx       { starting position             }
        mov   dx, di       { save pointer to str2          }
        inc   di
    rep movsb              { copy part str1 to str2        }
        mov   di, dx       { restore pointer to str2       }
@done:  mov   [di], al     { overwrite length byte of str2 }
@exit:
end  { CopySubStr };


procedure StrCopy( var Str1, Str2: string ); assembler;
  { copy str1 to str2 }
asm
        lds   si, str1     { load in DS:SI pointer to str1 }
        cld                { string operations forward     }
        les   di, str2     { load in ES:DI pointer to str2 }
        xor   ch, ch       { clear CH                      }
        mov   cl, [si]     { length str1 --> CX            }
        inc   cx           { include length byte           }
    rep movsb              { copy str1 to str2             }
@exit:
end  { StrCopy };


function StrPos( var str1, str2: string ): byte; assembler;
  { returns position of the first occurrence of str1 in str2 }
  { str1 - string to search for }
  { str2 - string to search in  }
  { return value in AX }
asm
        cld                 { string operations forward                 }
        les   di, str2      { load in ES:DI pointer to str2             }
        xor   cx, cx        { clear cx                                  }
        mov   cl, [di]      { length str2 --> CL                        }
        jcxz  @not          { if length str2 = 0, nothing to search in  }
        mov   bh, cl        { length str2 --> BH                        }
        inc   di            { di point to 1st char of str2              }
        lds   si, str1      { load in DS:SI pointer to str1             }
        lodsb               { load in AL length str1                    }
        and   al, al        { length str1 = 0?                          }
        jz    @not          { length str1 = 0, nothing to search for    }
        dec   al            { 1st char need not be compared again       }
        sub   cl, al        { length str2 - length str1                 }
        jbe   @not          { length str2 < length str1                 }
        mov   ah, al        { length str1 --> AH                        }
        lodsb               { load in AL 1st character of str1          }
@start:
  repne scasb               { scan for next occurrence 1st char in str2 }
        jne   @not          { no success                                }
        mov   dx, si        { pointer to 2nd char in str1 --> DX        }
        mov   bl, cl        { number of chars in str2 to go --> BL      }
        mov   cl, ah        { length str1 --> CL                        }
   repe cmpsb               { compare until characters don't match      }
        je    @pos          { full match                                }
        sub   si, dx        { current SI - prev. SI = # of chars moved  }
        sub   di, si        { current DI - # of chars moved = prev. DI  }
        mov   si, dx        { restore pointer to 2nd char in str1       }
        mov   cl, bl        { number of chars in str2 to go --> BL      }
        jmp   @start        { scan for next occurrence 1st char in str2 }
@not:   xor   ax, ax        { str1 is not in str2, result 0             }
        jmp   @exit
@pos:   add   bl, ah        { number of chars in str2 left              }
        mov   al, bh        { length str2 --> AX                        }
        sub   al, bl        { start position of str1 in str2            }
@exit:                      { we are finished. }
end  { StrPos };


procedure Trim( var Str: string ); assembler;
  { remove leading and trailing white space from str }
  { white space = all ASCII chars 0h - 20h }
asm     { setup }
        lds   si, str        { load in DS:SI pointer to Str       }
        xor   cx, cx         { clear cx                           }
        mov   cl, [si]       { length Str --> cx                  }
        jcxz  @exit          { if length Str = 0, exit            }
        mov   bx, si         { save pointer to length byte of Str }
        add   si, cx         { last character                     }

        { look for trailing space }
@loop1: mov   al, [si]       { load character                     }
        cmp   al, ' '        { no white space                     }
        ja    @stop1         { first non-blank character found    }
        dec   si             { next character                     }
        dec   cx             { count down                         }
        jcxz  @done          { if no more characters left, done   }
        jmp   @loop1         { try again                          }
@stop1: mov   si, bx         { point to start of Str              }
        inc   si             { point to 1st character             }
        mov   di, si         { pointer to Str --> DI              }
        { look for leading white space }
@loop2: mov   al, [si]       { load character                     }
        cmp   al, ' '        { no white space                     }
        ja    @stop2         { first non-blank character found    }
        inc   si             { next character                     }
        dec   cx             { count down                         }
        jcxz  @done          { if no more characters left, done   }
        jmp   @loop2         { try again                          }

        { remove leading white space }
@stop2: cld                  { string operations forward          }
        mov   dx, cx         { save new length Str                }
    rep movsb                { move remaining part of Str         }
        mov   cx, dx         { restore new length Str             }
@done:  mov   [bx], cl       { new length of Str                  }
@exit:
end  { Trim };


function InSet25(var _Set; OrdElement: Byte): Boolean;
  { I got this function from Bob Swart }
InLine(
  $58/         {   pop   AX                   }
  $30/$E4/     {   xor   AH,AH                }
  $5F/         {   pop   DI                   }
  $07/         {   pop   ES                   }
  $89/$C3/     {   mov   BX,AX                }
  $B1/$03/     {   mov   CL,3                 }
  $D3/$EB/     {   shr   BX,CL                }
  $88/$C1/     {   mov   CL,AL                }
  $80/$E1/$07/ {   and   CL,$07               }
  $B0/$01/     {   mov   AL,1                 }
  $D2/$E0/     {   shl   AL,CL                }
  $26/         {   ES:                        }
  $22/$01/     {   and   AL,BYTE PTR [DI+BX]  }
  $D2/$E8);    {   shr   AL,CL                }
{ InSet25 }


function OpenTextFile (var InF: text; const name: string; var buffer: BufTypeSource): boolean;
begin
  Assign( InF, Name );
  SetTextBuf( InF, buffer );
  Reset( InF );
  OpenTextFile := (IOResult = 0);
end  { OpenTextFile };

function CreateTextFile (var OutF: text; const name: string; var buffer: BufTypeDest): boolean;
begin
  Assign( OutF, Name );
  SetTextBuf( OutF, buffer );
  Rewrite( OutF );
  CreateTextFile := (IOResult = 0);
end  { CreateTextFile };

function Exist( Name : string ) : Boolean;
  { Return true if directory or file with the same name is found}
var
  F    : file;
  Attr : Word;
begin
  Assign( F, Name );
  GetFAttr( F, Attr );
  Exist := (DosError = 0)
end;

{$IFDEF Kort}
procedure UniekeEntry( var Naam : string3 );
const
  max    = $39;  { '0'..'9' = $30..$39 }
var
  Nbyte  : array [0..3] of byte absolute Naam;
  Exists : boolean;

begin
  Nbyte [0] := 3;  { FileName of 3 characters }

  Exists := True;
  Nbyte [1] := $30;
  while (Nbyte [1] <= max) and Exists do begin
    Nbyte [2] := $30;
    while (Nbyte [2] <= max) and Exists do begin
      Nbyte [3] := $30;
      while (Nbyte [3] <= max) and Exists do begin
        Exists := Exist( Naam );
        if Exists then inc( Nbyte [3] );
      end;
      if Exists then inc( Nbyte [2] );
    end;
    if Exists then inc( Nbyte [1] );
  end;
end;  { end procedure UniekeEntry }

{$ELSE}
procedure UniekeEntry( var Naam : string12 );
const
  max    = $39;  { '0'..'9' = $30..$39 }
var
  Nbyte  : array [0..12] of byte absolute Naam;
  Exists : boolean;

begin
  Nbyte [0] := 12;  { FileName of 12 characters (8+3+".") }
  Nbyte [9] := $2E; { '.' as 9e character }

  Exists := True;
  Nbyte [1] := $30;
  while (Nbyte [1] <= max) and Exists do begin
    Nbyte [2] := $30;
    while (Nbyte [2] <= max) and Exists do begin
      Nbyte [3] := $30;
      while (Nbyte [3] <= max) and Exists do begin
        Nbyte [4] := $30;
        while (Nbyte [4] <= max) and Exists do begin
          Nbyte [5] := $30;
          while (Nbyte [5] <= max) and Exists do begin
            Nbyte [6] := $30;
            while (Nbyte [6] <= max) and Exists do begin
              Nbyte [7] := $30;
              while (Nbyte [7] <= max) and Exists do begin
                Nbyte [8] := $30;
                while (Nbyte [8] <= max) and Exists do begin
                  Nbyte [10] := $30;
                  while (Nbyte [10] <= max) and Exists do begin
                    Nbyte [11] := $30;
                    while (Nbyte [11] <= max) and Exists do begin
                      Nbyte [12] := $30;
                      while (Nbyte [12] <= max) and Exists do begin
                        Exists := Exist( Naam );
                        if Exists then inc( Nbyte [12] );
                      end;
                      if Exists then inc( Nbyte [11] );
                    end;
                    if Exists then inc( Nbyte [10] );
                  end;
                  if Exists then inc( Nbyte [8] );
                end;
                if Exists then inc( Nbyte [7] );
              end;
              if Exists then inc( Nbyte [6] );
            end;
            if Exists then inc( Nbyte [5] );
          end;
          if Exists then inc( Nbyte [4] );
        end;
        if Exists then inc( Nbyte [3] );
      end;
      if Exists then inc( Nbyte [2] );
    end;
    if Exists then inc( Nbyte [1] );
  end;
end;  { end procedure UniekeEntry }
{$ENDIF}


procedure Search;
begin
  found := False;
  NrSearch := 1;
  while (NrSearch <= TotalNrSearch) and not found do
  begin
    nr := 1;
    while (nr <= NrLines) and not found do
    begin                                { search wanted text    }
      StrCopy( Line[nr], Tmp1 );
      LowerFast( Tmp1 );                 { convert to lower case }
      if StrPos( SearchText[NrSearch], Tmp1 ) > 0 then found := True;
      inc( nr );
    end;
    inc( NrSearch );
  end;
  if found then                      { at least one of the wanted words found }
  begin
    for nr := 1 to NrLines do WriteLn( DestFile, Line[nr] );
    inc( Count );
  end;
end;


procedure Process( var SourceListing : string12 );
begin
  Count := 0;
  DestListing  := DestDir + '\' + SourceListing;
  if OpenTextFile( SourceFile, SourceListing, SourceBuf ) then
  begin
    if CreateTextFile( DestFile, DestListing, DestBuf ) then
    begin
      write( SourceListing:12 );
      Header   := False;
      FileName := '';
      NrLines  := 0;
      nr := 1;
      ReadLn( SourceFile, Line[nr] );
      while not Eof(SourceFile) and (IOResult = 0) do
      begin
        StrCopy( Line[nr], Tmp1 );
        Trim( Tmp1 );
        if Length( Tmp1 ) > 0 then                  { no empty lines }
        begin
          CopySubStr( Line[nr], 1, 12, FileName );
          Trim( FileName );
          T := 1;
          while (T <= Length( FileName ))
          and not InSet25( NotAllowed, Byte( FileName[T] ) ) do
            inc( T );                               { look out for headers }
          { }
          Header := (T <= Length( FileName ))
            or ((Length( FileName ) > 0) and (Line[nr][1]=' '));  { header? }
          if Header then
            FileName := ''                          { read next line }
          else                                      { no header }
          begin
            if (Length( FileName ) = 0) then        { more description }
            begin
              inc( nr );
              inc( NrLines );
            end
            else
            begin
              StrCopy( Line[nr], Tmp2 );     { save new textline    }
              Search;

              { setup for next entry }
              NrLines  := 1;                 { already got one line }
              nr       := 2;                 { so next line in #2   }
              StrCopy( Tmp2, Line[1] );      { restore new textline }
              FileName := '';                { make sure a new line is read }
            end;  { endif (Length( FileName ) = 0)) }
          end;  { if Header }
        end;  { if Length( Tmp1 ) > 0 }
        if (Length( FileName ) = 0) then
          ReadLn( SourceFile, Line[nr] );
        { }
      end;  { while not Eof(SourceFile) and (IOResult = 0) }
      inc( NrLines );   { include the last line in the search }
      Search;
      Close( DestFile );
      if (Count = 0) then
      begin
        Erase( DestFile );
        Write( #13 );
      end
      else
      begin
        writeln( Count:7, ' in ', DestListing );
        TotalCount := TotalCount + Count;
      end
    end  { if CreateTextFile }
    else
      writeln( Cannot, 'file ', DestListing );
    { }
    Close( SourceFile );
  end   { if OpenTextFile }
  else
    writeln( 'Cannot open sourcefile ', SourceListing );
  { }
end;


begin
  if ParamCount > 1 then                 { parameters: listing catchwords  }
  begin
    TotalCount := 0;
    TotalNrSearch := ParamCount - 1;
    if (TotalNrSearch > MaxNrSearch) then
      TotalNrSearch := MaxNrSearch;      { no more catchwords than maximum }
    UniekeEntry( DestDir );
    if not Exists then
    begin
      MkDir( DestDir );
      if (IOResult=0) then
      begin
        Write( 'Searching:' );
        FMask        := ParamStr( 1 );                    { filemask       }
        for NrSearch := 1 to TotalNrSearch do             { all catchwords }
        begin
          SearchText[NrSearch] := ParamStr( NrSearch+1 ); { each catchword }
          LowerFast( SearchText[NrSearch] );     { translate to lower case }
          Write(' ', SearchText[NrSearch] );
        end;
        WriteLn;
        FindFirst(FMask, FAttr, FR);
        while DosError = 0 do
        begin
          Process(FR.Name);
          FindNext(FR);
        end;
        WriteLn( 'Total found ', TotalCount, ' entries.' );
        if (TotalCount = 0) then RmDir( DestDir );
      end;  { if not IOResult }
    end   { if not Exists }
    else
      writeln( Cannot, 'directory ', DestListing );
    { }
  end   { if ParamCount > 1 }
  else
    WriteLn( 'Extract filename word(s)' );
end.
