
Procedure ReverseString(var s:string);
var i,j:byte; c:char;
begin
 j:=Length(s);
 for i:=1 to j div 2 do
  begin
   c:=s[i];
   s[i]:=s[j];
   s[j]:=c;
   dec(j);
  end;
end;

{ ---- BASM 'pointer oriented' version ------------------------------ }
Procedure ReverseAString(var s:string); assembler;
asm
        lds SI,s
        mov AL,[SI]
        xor AH,AH
        mov DI,SI
        inc SI                  { SI points to start of s }
        add DI,AX               { DI points to end of s }

@@0:    cmp SI,DI               { while SI=DI do ... }
        jae @@1

        mov AL,[SI]
        mov AH,[DI]
        mov [SI],AH
        mov [DI],AL
        inc SI
        dec DI
        jmp @@0
@@1:
end;

{ Version #2 }

Procedure ReverseAString(var s:string); assembler;
asm
                push DS
                cld
                lds SI,s
                mov DI,SI
                lodsb
                xor AH,AH
                add DI,AX               { DI points to end of s }
@ReverseLoop:   cmp SI,DI               { while SI=DI do ... }
                jae @ReverseExit
                mov AL,[SI]
                mov AH,[DI]
                mov [SI],AH
                mov [DI],AL
                inc SI
                dec DI
                jmp @ReverseLoop
@ReverseExit:   pop DS
end;

Function FlipStr(s:string):string; assembler;
asm
                push DS
                cld
                les DI,@Result
                lds SI,s
                lodsb
                stosb
                mov CL,AL
                xor CH,CH
                add DI,CX
@FlipLoop:      and CL,CL
                jz @FlipExit
                lodsb
                dec DI
                mov ES:[DI],AL
                dec CL
                jmp @FlipLoop
@FlipExit:      pop DS
end;
