{
I needed a routine to convert a byte value into a string with leading zeros.
> So I made one in BASM: Byte2lzStr. If you want, include this in SWAG.
}
var s: string;
    tel, n : byte;

procedure Byte2lzStr( n, width: byte; var str: string ); assembler;
  { Byte to string with leading zeros }
asm
        std                 { string operations backwards }
        mov   al, [n]       { numeric value to convert    }
        mov   cl, [width]   { width of str                }
        xor   ch, ch        { clear ch                    }
        les   di, str       { adress of str               }
        mov   [di], cl      { length of str               }
        add   di, cx        { start with last char str    }
@start: jcxz  @exit         { done?                       }
        aam                 { divide al by 10             }
        add   al, 30h       { convert remainder to char   }
        stosb               { store digit                 }
        xchg  al, ah        { swap remainder and quotient }
        dec   cl            { count down                  }
        jmp   @start        { next digit                  }
@exit:
end  { Byte2lzStr };

begin
  randomize;
  for tel := 1 to 24 do
  begin
    n := random( 256 );
    Byte2lzStr( n, 5, s );
    writeln( tel:2,':  ', n:3,'  ', s,'  [',length(s),']' );
  end;
end.
