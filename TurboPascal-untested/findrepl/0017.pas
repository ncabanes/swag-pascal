{ BOYERMO2.PAS (23 January 1988) (Rufus S. Hendon) }

{    This Unit provides facilities For searching a Text For a target using
  the Boyer-Moore search method.  The routine is based on Don Strenczewilk's
  Implementation of a Variant form of the Boyer-Moore method (his case-
  insensitive version B1, available on CompuServe in File BLINE.ARC in
  Borland BPROGA Data Library 4, uploaded 21 August 1987).  In addition to
  repackaging his routine as a Turbo Pascal 4.0 Unit, I have modified it
  (1) to provide protection against endless loops that in the original
  version can arise due to wrap-around of the index used to scan the Text
  when the the length of the Text approaches the maximum (65521 Characters)
  allowed by Turbo Pascal 4.0 For Arrays of Type Char and (2) to improve
  efficiency slightly by removing three instructions (a PUSH, a MOV, and a
  POP) from the comparison loop.
     The Text to be searched must be stored in an Array of Type Char or an
  equivalent user-defined Type.  The lower bound of the Array must be 1.
  The target For which the Text is to be searched must be of Type String.
  The Program must also provide a Variable For the storage of the shift
  table used by the Boyer-Moore method when it searches the Text.  This
  Variable must provide 256 Bytes of storage; it can, For example, be a
  Variable of Type Array[Char] of Byte.  The target Variable and the shift-
  table Variable must be in the same segment:  they must both be global
  Variables (located in the data segment) or both local Variables (stored
  in the stack segment).
     Whenever the Text is to be searched For a new target, the Program must
  call MAKE_BOYER_MOORE_TABLE to create the shift table For the target.
  Thereafter the Text can be searched For the target by invoking
  BOYER_MOORE_SEARCH, specifying as arguments the target and its shift
  table as well as the position in the Text where the search is to begin.
  if the Program maintains multiple target Variables and a separate shift
  table and starting-position Variable For each target, searches for
  occurrences of the Various targets can be underway simultaneously.
     In a call to BOYER_MOORE_SEARCH, the argument associated With the
  parameter START determines the position in the Text With which the search
  begins.  To search the entire Text, the Function would be invoked With
  START = 1.  The Function scans the Text beginning from the START position
  For the first subString that matches the target specified by the Variable
  associated With the parameter TARGET, using the shift table stored in the
  Variable associated With the parameter TABLE.  if such a subString is
  found, the Function returns the position (Array subscript) of the initial
  Character of the matching subString; since the Array is required to have
  1 as its lower bound, the position returned after a successful search
  will always be greater than 0.  if the Function fails to find a matching
  subString, it returns 0.  (if the requirement that the TARGET and TABLE
  Variables be in the same segment is violated, the Function also returns
  0.)
     When it is required that all occurrences in the Text of a given target
  be found, BOYER_MOORE_SEARCH would be invoked in a loop, in which the
  START argument would initially have the value of 1; thereafter, after
  every successful search, the START argument would be reset to the
  position returned by the Function plus 1.  The loop would terminate when
  the Function reported failure.  The loop would have a general structure
  similar to this:

    item := [the target String];
    make_Boyer_Moore_table(item,shift_table);
    scan_beginning := 1;
    search_Text_length := length(search_Text);
    Repeat
      i := Boyer_Moore_search(search_Text,scan_beginning,search_Text_length,
          item,shift_table);
      if i > 0 then begin
        [do whatever processing is required when the search is successful];
        scan_beginning := i+1
      end
    Until i = 0

     Note that if the Text Array can only be referred to by means of a
  Pointer, as will be the Case if the Array is allocated in the heap by
  means of the NEW Procedure, the Pointer, when used as the first argument
  of BOYER_MOORE_SEARCH, must be dereferenced by writing '^' after it.  If,
  For example, TextPTR is a Pointer to the Text Array, the call to the
  search Function in the loop just given would take this form:

      i := Boyer_Moore_search(Textptr^,scan_beginning,search_Text_length,
          item,shift_table);
                                                                             }
{============================================================================}
Unit BOYERMO2;
{============================================================================}
Interface

Procedure MAKE_BOYER_MOORE_TABLE(Var target: String; Var table);
{ TARGET is the target String For which a Text is to be searched.  The
  shift table For the target String is Constructed in TABLE, which must be
  a Variable providing 256 Bytes of storage, e.g. a Variable declared as
  Array[Char] of Byte. }

Function BOYER_MOORE_SEARCH(Var Text_Array; start, Text_length: Word;
    Var target: String; Var table): Word;
{ Text_Array is an Array of Characters in which a Text is stored; the
  Text begins in Text_Array[1] and is Text_LENGTH Characters long.  TARGET
  must either be the same Variable used as parameter TARGET in an earlier
  call to MAKE_BOYER_MOORE_TABLE or another Variable With the same value.
  TABLE must be the Variable that was used as parameter TABLE in the same
  call to MAKE_BOYER_MOORE_TABLE.  TARGET and TABLE must be in the same
  segment, i.e. they must both be global Variables or both local Variables.
  A Boyer-Moore search is performed on the Text in Text_Array, beginning
  With the Character in position START and using shift table TABLE, for
  the first subString that matches TARGET.  if a match is found, the
  position of the first Character of the matching subString is returned.
  Otherwise 0 is returned.  A Function value of 0 is also returned if TABLE
  and TARGET are not in the same segment. }
{============================================================================}
Implementation

Const
  copy: String = '';
Var
  table: Array[Char] of Byte;
{****************************************************************************}
Procedure MAKE_BOYER_MOORE_TABLE(Var target: String; Var table);
{ TARGET is the target String For which a Text is to be searched.  The
  shift table For the target String is Constructed in TABLE, which must be
  a Variable providing 256 Bytes of storage, e.g. a Variable declared as
  Array[Char] of Byte. }
begin { MAKE_BOYER_MOORE_TABLE }
  Inline
    ($1E/              {       push ds            }
     $C5/$76/<target/  {       lds si,[bp+target] }
     $89/$F3/          {       mov bx,si          }
     $8A/$04/          {       mov al, [si]       }
     $88/$C4/          {       mov ah,al          }
     $B9/$80/$00/      {       mov cx,$0080       }
     $C4/$7E/<table/   {       les di,[bp+table]  }
     $89/$FA/          {       mov dx,di          }
     $FC/              {       cld                }
     $F2/$AB/          {       rep stosw          }
     $89/$DE/          {       mov si,bx          }
     $89/$D7/          {       mov di,dx          }
     $46/              {       inc si             }
     $98/              {       cbw                }
     $3C/$01/          {       cmp al,1           }
     $7E/$13/          {       jle done           }
     $48/              {       dec ax             }
     $88/$E1/          {       mov cl,ah          }
     $88/$E7/          {       mov bh,ah          }
     $8A/$1C/          { next: mov bl,[si]        }
     $89/$C2/          {       mov dx,ax          }
     $29/$CA/          {       sub dx,cx          }
     $88/$11/          {       mov [bx+di],dl     }
     $46/              {       inc si             }
     $41/              {       inc cx             }
     $39/$C1/          {       cmp cx,ax          }
     $75/$F2/          {       jne next           }
     $1F)              { done: pop ds             }
end; { MAKE_BOYER_MOORE_TABLE }

{****************************************************************************}
Function BOYER_MOORE_SEARCH(Var Text_Array; start, Text_length: Word;
    Var target: String; Var table): Word;
{ Text_Array is an Array of Characters in which a Text is stored; the
  Text begins in Text_Array[1] and is Text_LENGTH Characters long.  TARGET
  must either be the same Variable used as parameter TARGET in an earlier
  call to MAKE_BOYER_MOORE_TABLE or another Variable With the same value.
  TABLE must be the Variable that was used as parameter TABLE in the same
  call to MAKE_BOYER_MOORE_TABLE.  TARGET and TABLE must be in the same
  segment, i.e. they must both be global Variables or both local Variables.
  A Boyer-Moore search is performed on the Text in Text_Array, beginning
  With the Character in position START and using shift table TABLE, for
  the first subString that matches TARGET.  if a match is found, the
  position of the first Character of the matching subString is returned.
  Otherwise 0 is returned.  A Function value of 0 is also returned if TABLE
  and TARGET are not in the same segment. }
begin { BOYER_MOORE_SEARCH }
  Inline
    ($1E/                  {            push ds                 }
     $33/$C0/              {            xor ax,ax               }
     $C5/$5E/<table/       {            lds bx,[bp+table]   } { if TABLE and  }
     $8C/$D9/              {            mov cx,ds           } { TARGET are in }
     $C5/$76/<target/      {            lds si,[bp+target]  } { different     }
     $8C/$DA/              {            mov dx,ds           } { segments, re- }
     $3B/$D1/              {            cmp dx,cx           } { port failure  }
     $75/$76/              {            jne notfound2       } { at once       }
     $8A/$F4/              {            mov dh,ah               }
     $8A/$14/              {            mov dl,[si]             }
     $80/$FA/$01/          {            cmp dl,1                }
     $7F/$1F/              {            jg boyer                }
     $7C/$6B/              {            jl notfound2            }
     $8A/$44/$01/          {            mov al,[si+1]           }
     $8B/$56/<start/       {            mov dx,[bp+start]       }
     $4A/                  {            dec dx                  }
     $8B/$4E/<Text_length/ {            mov cx,[bp+Text_length] }
     $2B/$CA/              {            sub cx,dx               }
     $C4/$7E/<Text_Array/  {            les di,[bp+Text_Array]  }
     $8B/$DF/              {            mov bx,di               }
     $03/$FA/              {            add di,dx               }
     $FC/                  {            cld                     }
     $F2/$AE/              {            repne scasb             }
     $75/$53/              {            jne notfound2           }
     $97/                  {            xchg ax,di              }
     $2B/$C3/              {            sub ax,bx               }
     $EB/$50/              {            jmp short Exit          }
     $FE/$CA/              { boyer:     dec dl                  }
     $03/$F2/              {            add si,dx               }
     $C4/$7E/<Text_Array/  {            les di,[bp+Text_Array]  }
     $8B/$CF/              {            mov cx,di               }
     $03/$4E/<Text_length/ {            add cx,[bp+Text_length] }
     $49/                  {            dec cx                  }
     $4F/                  {            dec di                  }
     $03/$7E/<start/       {            add di,[bp+start]       }
     $03/$FA/              {            add di,dx               }
     $8A/$74/$01/          {            mov dh,[si+1]           }
     $55/                  {            push bp                 }
     $8B/$E9/              {            mov bp,cx               }
     $8A/$EC/              {            mov ch,ah               }
     $FD/                  {            std                     }
     $EB/$05/              {            jmp short comp          }
     $D7/                  { nexttable: xlat                    }
     $03/$F8/              {            add di,ax               }
     $72/$2A/              {            jc notfound             }
     $3B/$EF/              { comp:      cmp bp,di               }
     $72/$26/              {            jb notfound             }
     $26/$8A/$05/          {            mov al,es:[di]          }
     $3A/$F0/              {            cmp dh,al               }
     $75/$F0/              {            jne nexttable           }
     $4F/                  {            dec di                  }
     $8A/$CA/              {            mov cl,dl               }
     $F3/$A6/              {            repe cmpsb              }
     $74/$0D/              {            je found                }
     $8A/$C2/              {            mov al,dl               }
     $2B/$C1/              {            sub ax,cx               }
     $03/$F8/              {            add di,ax               }
     $47/                  {            inc di                  }
     $03/$F0/              {            add si,ax               }
     $8A/$C6/              {            mov al,dh               }
     $EB/$DC/              {            jmp short nexttable     }
     $5D/                  { found:     pop bp                  }
     $C4/$46/<Text_Array/  {            les ax,[bp+Text_Array]  }
     $97/                  {            xchg ax,di              }
     $2B/$C7/              {            sub ax,di               }
     $40/                  {            inc ax                  }
     $40/                  {            inc ax                  }
     $EB/$03/              {            jmp short Exit          }
     $5D/                  { notfound:  pop bp                  }
     $32/$C0/              { notfound2: xor al,al               }
     $89/$46/$FE/          { Exit:      mov [bp-2],ax           }
     $FC/                  {            cld                     }
     $1F)                  {            pop ds                  }
end; { BOYER_MOORE_SEARCH }
{****************************************************************************}
end.

