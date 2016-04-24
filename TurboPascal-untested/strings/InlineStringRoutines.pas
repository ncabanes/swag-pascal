(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0095.PAS
  Description: Inline String Routines
  Author: EDDY THILLEMAN
  Date: 08-25-94  09:08
*)

{
How do I make from a procedure or function an inline version?
If I run the following program, the computer locks up. What's wrong??
Help!!
}
var
  s1, s2: string;

procedure CopySubStr( Str1: string; start, nrchars: byte; var Str2: string );
  { copy part of Str1 (beginning at start for nrchars) to Str2
    if start > length of Str1, Str2 will contain a empty string.
    if nrchars specifies more characters than remain starting at the
    start position, Str2 will contain just that remainder of Str1. }
InLine(
  $55/          {       push   bp         }
  $89/$E5/      {       mov    bp,sp      }
  $C5/$76/$0C/  {       lds    si,[bp+0C] }
  $FC/          {       cld               }
  $C4/$7E/$04/  {       les    di,[bp+04] }
  $8A/$24/      {       mov    ah,[si]    }
  $20/$E4/      {       and    ah,ah      }
  $74/$16/      {       je     @null      }
  $8A/$5E/$0A/  {       mov    bl,[bp+0A] }
  $38/$DC/      {       cmp    ah,bl      }
  $72/$0F/      {       jb     @null      }
  $8A/$46/$08/  {       mov    al,[bp+08] }
  $88/$C6/      {       mov    dh,al      }
  $00/$DE/      {       add    dh,bl      }
  $FE/$CE/      {       dec    dh         }
  $38/$F4/      {       cmp    ah,dh      }
  $72/$06/      {       jb     @rest      }
  $EB/$0A/      {       jmp    @copy      }
                { @null:                  }
  $B0/$00/      {       mov    al,00      }
  $EB/$15/      {       jmp    @done      }
                { @rest:                  }
  $28/$DC/      {       sub    ah,bl      }
  $FE/$C4/      {       inc    ah         }
  $88/$E0/      {       mov    al,ah      }
                { @copy:                  }
  $88/$C1/      {       mov    cl,al      }
  $30/$ED/      {       xor    ch,ch      }
  $30/$FF/      {       xor    bh,bh      }
  $01/$DE/      {       add    si,bx      }
  $89/$FA/      {       mov    dx,di      }
  $47/          {       inc    di         }
  $F3/$A4/      {   rep movsb             }
  $89/$D7/      {       mov    di,dx      }
                { @done:                  }
  $88/$05/      {       mov    [di],al    }
                { @exit:                  }
  $5D           {       pop    bp         }
) { CopySubStr };

procedure StrCopy( var Str1, Str2: string );
  { copy str1 to str2 }
InLine(
  $89/$EA/      {       mov    dx,bp      }
  $89/$E5/      {       mov    bp,sp      }
  $C5/$76/$08/  {       lds    si,[bp+08] }
  $FC/          {       cld               }
  $C4/$7E/$04/  {       les    di,[bp+04] }
  $30/$ED/      {       xor    ch,ch      }
  $8A/$0C/      {       mov    cl,[si]    }
  $41/          {       inc    cx         }
  $F3/$A4/      {   rep movsb             }
  $89/$D5       {       mov    bp,dx      }
) { StrCopy };

function StrPos( var str1, str2: string ): byte;
  { returns position of the first occurrence of str1 in str2 }
  { return value in AX }
  { str1 - string to search for }
  { str2 - string to search in  }
InLine(
  $55/          {       push   bp         }
  $89/$E5/      {       mov    bp,sp      }
  $FC/          {       cld               }
  $C4/$7E/$04/  {       les    di,[bp+04] }
  $30/$ED/      {       xor    ch,ch      }
  $8A/$0D/      {       mov    cl,[di]    }
  $21/$C9/      {       and    cx,cx      }
  $74/$2A/      {       je     @negatief  }
  $47/          {       inc    di         }
  $C5/$76/$08/  {       lds    si,[bp+08] }
  $AC/          {       lodsb             }
  $20/$C0/      {       and    al,al      }
  $74/$21/      {       je     @negatief  }
  $88/$C4/      {       mov    ah,al      }
  $FE/$CC/      {       dec    ah         }
  $AC/          {       lodsb             }
                { @start:                 }
  $F2/$AE/      { repnz scasb             }
  $75/$18/      {       jne    @negatief  }
  $38/$E1/      {       cmp    cl,ah      }
  $72/$14/      {       jb     @negatief  }
  $89/$F2/      {       mov    dx,si      }
  $89/$CB/      {       mov    bx,cx      }
  $88/$E1/      {       mov    cl,ah      }
  $F3/$A6/      {   rep cmpsb             }
  $74/$0E/      {       je     @positief  }
  $29/$D6/      {       sub    si,dx      }
  $29/$F7/      {       sub    di,si      }
  $89/$D6/      {       mov    si,dx      }
  $89/$D9/      {       mov    cx,bx      }
  $EB/$E4/      {       jmp    @start     }
                { @Negatief:              }
  $31/$C0/      {       xor    ax,ax      }
  $EB/$09/      {       jmp    @exit      }
                { @Positief:              }
  $30/$E4/      {       xor    ah,ah      }
  $C4/$7E/$04/  {       les    di,[bp+04] }
  $8A/$05/      {       mov    al,[di]    }
  $29/$D8/      {       sub    ax,bx      }
                { @Exit:                  }
  $5D           {       pop    bp         }
) { StrPos };

procedure Trim( var Str: string );
  { remove leading and trailing white space from str }
InLine(         { setup }
  $55/          {       push   bp         }
  $89/$E5/      {       mov    bp,sp      }
  $C5/$76/$04/  {       lds    si,[bp+04] }
  $8C/$D8/      {       mov    ax,ds      }
  $8E/$C0/      {       mov    es,ax      }
  $8A/$04/      {       mov    al,[si]    }
  $20/$C0/      {       and    al,al      }
  $74/$45/      {       je     @exit      }
  $89/$F7/      {       mov    di,si      }
  $88/$C4/      {       mov    ah,al      }
              { remove trailing white space }
  $30/$ED/      {       xor    ch,ch      }
  $88/$E1/      {       mov    cl,ah      }
  $01/$CE/      {       add    si,cx      }
                { @start1:                }
  $8A/$04/      {       mov    al,[si]    }
  $3C/$20/      {       cmp    al,20      }
  $77/$09/      {       ja     @stop1     }
  $4E/          {       dec    si         }
  $FE/$C9/      {       dec    cl         }
  $20/$C9/      {       and    cl,cl      }
  $74/$02/      {       je     @stop1     }
  $EB/$F1/      {       jmp    @start1    }
                { @stop1:                 }
  $20/$C9/      {       and    cl,cl      }
  $74/$26/      {       je     @done      }
              { look for leading white space }
  $89/$FE/      {       mov    si,di      }
                { @start2:                }
  $46/          {       inc    si         }
  $8A/$04/      {       mov    al,[si]    }
  $3C/$20/      {       cmp    al,20      }
  $77/$08/      {       ja     @stop2     }
  $FE/$C9/      {       dec    cl         }
  $20/$C9/      {       and    cl,cl      }
  $74/$02/      {       je     @stop2     }
  $EB/$F1/      {       jmp    @start2    }
                { @stop2:                 }
  $89/$F2/      {       mov    dx,si      }
  $29/$FA/      {       sub    dx,di      }
  $83/$FA/$01/  {       cmp    dx,0001    }
  $74/$0C/      {       je     @done      }
  $FC/          {       cld               }
  $89/$CB/      {       mov    bx,cx      }
  $89/$FA/      {       mov    dx,di      }
  $47/          {       inc    di         }
  $F3/$A4/      {   rep movsb             }
  $89/$D7/      {       mov    di,dx      }
  $89/$D9/      {       mov    cx,bx      }
                { @done:                  }
  $88/$0D/      {       mov    [di],cl    }
                { @exit:                  }
  $5D           {       pop    bp         }
) { Trim };

begin
  s1 := '123456789-123456789-';
  s2 := '';
  CopySubStr( s1, 1, 12, s2 );
  writeln( s2 );

  s1 := '123qqwerty';
  s2 := 'qwerty';
  CopySubStr( s1, 1, 12, s2 );
  writeln( s2 );

  StrCopy( s1, s2 );
  writeln( s2 );

  s1 := '123456789-123456789-';
  s2 := '4567';
  writeln( StrPos( s1, s2 ) );

  s1 := '  123qqwerty   ';
  s2 := 'qwerty';
  writeln( StrPos( s1, s2 ) );

  Trim( s1 );
  writeln( s2 );
end.

