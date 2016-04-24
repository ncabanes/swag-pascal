(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0043.PAS
  Description: Delete dupe lines
  Author: SWAG SUPPORT TEAM
  Date: 11-26-94  04:57
*)

Program Dup;
   { delete duplicate lines from a sorted text file }
   { Dup file1 file2 }

Uses
  Dos;

Type
  string3 = string[3];
Const
  WhiteSpace : string3 = #00#09#255;

Const
  NoFAttr : word = $1C; { attributen dir, volume, system }
  FAttr   : word = $23; { readonly-, hidden-, archive attributen }
  BufSize = 16384;      { buffersize 16 KB }

Type
  BufType = array [1..BufSize] of char;

Var
  Fname1, Fname2   : string;
  Line1, Line2     : string;
  tmp1 , tmp2      : string;   { temporary vars for lower case comparing }
  OldFile, NewFile : text;
  OldBuf , NewBuf  : BufType;
  tel              : longint;


function OpenTextFile( var InF: text; name: string; var buffer: BufType ): boolean;
begin
  Assign( InF, Name );
  SetTextBuf( InF, buffer );
  Reset( InF );
  OpenTextFile := ( IOResult = 0 );
end { OpenTextFile };

function CreateTextFile( var OutF: text; name: string; var buffer: BufType ): boolean;
begin
  Assign( OutF, Name );
  SetTextBuf( OutF, buffer );
  Rewrite( OutF );
  CreateTextFile := ( IOResult = 0 );
end { CreateTextFile };


function FileExist( var FName : string ) : Boolean;
  {-Return true if entry is found and if it's a file}
var
  F    : file;
  Attr : Word;
begin
  Assign( F, FName );
  GetFAttr( F, Attr );
  if DosError = 0 then
    FileExist := ( ( Attr and NoFAttr ) = 0 )
    { not dir-, volume- or system bit? }
  else
    FileExist := False;            { DosError }
  {}
end;


procedure StrCopy( var Str1, Str2: string ); assembler;
  { copy str1 to str2 }
asm
        LDS   SI,Str1    { load in DS:SI pointer to str1 }
        CLD              { string operations forward     }
        LES   DI,Str2    { load in ES:DI pointer to str2 }
        XOR   CH,CH      { clear CH                      }
        MOV   CL,[SI]    { length str1 --> CX            }
        INC   CX         { include length byte           }
    REP MOVSB            { copy str1 to str2             }
end  { StrCopy };


procedure Lower( var Str: String );
{ 52 Bytes by Bob Swart, 11-6-1993, FidoNet '80XXX' FASTEST! }
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


procedure White2Space( var Str: string; const WhiteSpace: string ); assembler;
  { replace white space chars in Str by spaces
    the string WhiteSpace contains the chars to replace }
asm     { setup }
        cld                      { string operations forwards    }
        les   di, str            { ES:DI points to Str           }
        xor   cx, cx             { clear cx                      }
        mov   cl, [di]           { length Str in cl              }
        jcxz  @exit              { if length of Str = 0, exit    }
        inc   di                 { point to 1st char of Str      }
        mov   dx, cx             { store length of Str           }
        mov   bx, di             { pointer to Str                }
        lds   si, WhiteSpace     { DS:SI points to WhiteSpace    }
        mov   ah, [si]           { load length of WhiteSpace     }

@start: cmp   ah, 0              { more chars WhiteSpace left?   }
        jz    @exit              { no, exit                      }
        inc   si                 { point to next char WhiteSpace }
        mov   al, [si]           { next char to hunt             }
        dec   ah                 { ah counting down              }
        xor   dh, dh             { clear dh                      }
        mov   cx, dx             { restore length of Str         }
        mov   di, bx             { restore pointer to Str        }
        mov   dh, ' '            { space char                    }
@scan:
  repne scasb                    { the hunt is on                }
        jnz   @next              { white space found?            }
        mov   [di-1], dh         { yes, replace that one         }
@next:  jcxz  @start             { if no more chars in Str       }
        jmp   @scan              { if more chars in Str          }
@exit:
end  { White2Space };


procedure RTrim( var Str: string ); assembler;
  { remove trailing spaces from str }
asm     { setup }
        std                      { string operations backwards   }
        les   di, str            { ES:DI points to Str           }
        xor   cx, cx             { clear cx                      }
        mov   cl, [di]           { length Str in cl              }
        jcxz  @exit              { if length of Str = 0, exit    }
        mov   bx, di             { bx points to Str              }
        add   di, cx             { start with last char in Str   }
        mov   al, ' '            { hunt for spaces               }

        { remove trailing spaces }
   repe scasb                    { the hunt is on                }
        jz    @null              { only spaces?                  }
        inc   cx                 { no, don't lose last char      }
@null:  mov   [bx], cl           { overwrite length byte of Str  }
@exit:
end  { RTrim };


procedure LTrim( var Str: string ); assembler;
  { remove leading spaces from str }
asm     { setup }
        cld                      { string operations forward          }
        lds   si, str            { DS:SI points to Str                }
        xor   cx, cx             { clear cx                           }
        mov   cl, [si]           { length Str --> cl                  }
        jcxz  @exit              { if length Str = 0, exit            }
        mov   bx, si             { save pointer to length byte of Str }
        inc   si                 { 1st char of Str                    }
        mov   di, si             { pointer to 1st char of Str --> di  }
        mov   al, ' '            { hunt for spaces                    }
        xor   dx, dx             { clear dx                           }

@start: { look for leading spaces }
   repe scasb                    { the hunt is on                     }
        jz    @done              { if only spaces, we are done        }
        inc   cx                 { no, don't lose 1st non-blank char  }
        dec   di                 { no, don't lose 1st non-blank char  }
        mov   dx, cx             { new lenght of Str                  }
        xchg  di, si             { swap si and di                     }
    rep movsb                    { move remaining part of Str         }
@done:  mov   [bx], dl           { new length of Str                  }
@exit:
end  { LTrim };


function LineOK( var str: string ) : Boolean; assembler;
  { Line contains chars > ASCII 20h ? }
asm     { setup }
        xor   ax, ax         { assume false return value        }
        xor   cx, cx         { clear cx                         }
        lds   si, str        { load in DS:SI pointer to Str     }
        mov   cl, [si]       { length Str --> cx                }
        jcxz  @exit          { if no characters, exit           }
        inc   si             { point to 1st character           }

        { look for chars > ASCII 20h }
@start: mov   bl, [si]       { load character                   }
        cmp   bl, ' '        { char > ASCII 20h?                }
        ja    @yes           { yes, return true                 }
        inc   si             { next character                   }
        dec   cx             { count down                       }
        jcxz  @exit          { if no more characters left, exit }
        jmp   @start         { try again                        }
@yes:   mov   ax, 1          { return value true                }
@exit:
end  { LineOK };


procedure TestLine( var Line, tmp : string );
var
  len: byte absolute Line;

  procedure TrimLine;
  begin
    White2Space( Line, WhiteSpace );  { white space to spaces   }
    RTrim( Line );                    { remove trailing spaces  }
  end;

  procedure TrimPlus;
  begin
    TrimLine;
    while Line[len] = '+' do
    begin
      dec( len );
      TrimLine;
    end;
  end;

begin
  TrimPlus;
  while not Eof( OldFile ) and ( IOResult = 0 ) and ((length( Line ) = 0) or not LineOK( Line )) do
  begin
    ReadLn( OldFile, Line );
    TrimPlus;
  end;
  StrCopy( Line, tmp );             { copy to temp string     }
  LTrim( tmp );                     { remove leading spaces   }
  Lower( tmp );                     { translate to lower case }
end;  { TestLine }


begin
  if ParamCount > 1 then             { parameters file1 file2 }
  begin
    Fname1 := FExpand( ParamStr( 1 ) );
    Fname2 := FExpand( ParamStr( 2 ) );
    tel := 0;
    if FileExist( Fname1 ) then
    begin
      if OpenTextFile( OldFile, Fname1, OldBuf ) then
      begin
        if CreateTextFile( NewFile, Fname2, NewBuf ) then
        begin
          ReadLn( OldFile, Line1 );

          if not Eof( OldFile ) and ( IOResult = 0 ) then
          begin
            TestLine( Line1, tmp1 );
            if length( Line1 ) > 0 then
            begin
              WriteLn( NewFile, Line1 );
              tel := 1;
            end;
            ReadLn( OldFile, Line2 );
          end;

          while not Eof( OldFile ) and ( IOResult = 0 ) do
          begin
            TestLine( Line2, tmp2 );
            if (length( Line2 ) > 0) and (tmp1 <> tmp2) then
            begin
              StrCopy( Line2, Line1 );         { copy Line2 to Line1 }
              StrCopy( tmp2, tmp1 );           { copy tmp2  to tmp1  }
              WriteLn( NewFile, Line1 );
              inc( tel );
            end;
            ReadLn( OldFile, Line2 );
          end {while not eof};

          TestLine( Line2, tmp2 );
          if (length( Line2 ) > 0) and (tmp1 <> tmp2) then
          begin
            WriteLn( NewFile, Line2 );
            inc( tel );
          end;

          writeln (tel, ' unique lines');
          Close( NewFile );
          Close( OldFile );
        end { if create file2 }
        else
          writeln(' error creating file ', Fname1 );
        { error creating file }
      end { if open file1 }
      else
        writeln(' error opening file ', Fname1 );
      { error opening file }
    end { if FileExist( Fname1 ) }
    else
      writeln( Fname1, ' not found' );
    { file not found }
  end { if ParamCount > 1 }
  else
    Writeln( 'Dup file1 file2' );
end.

