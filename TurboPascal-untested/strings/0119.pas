{TPAS -> ASMB}

{$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 8192,0,655360}
 
 
PROCEDURE ChangeChars(var S: string; Old, New: char);
begin
   while Pos(Old, S) > 0 do
   S[Pos(Old, S)] := New;
end;
{-----------------------------------------------------}

procedure ChangeCharsASM( VAR s1: string; Old,New : char);
begin
  asm
    push es
    push di
    push ds
    push si

    mov cx,word ptr S1[2] { ds:si -> S1 } {get}
    mov ds,cx
    mov si,word ptr S1

    LodsB                 { al := ds:si }
                          { inc si }
    mov si,di             { es:di -> ds:si }
    mov es,cx
 
    mov cx,ax             { cx := length(s);}
@looper:                  { for I:=cx down to 1 do  }
    LodsB                 { al := ds:si }
                          { inc si }
 
    cmp al,old            { if al= old then begin }
    jne @skip_me          {    di := si -1        }
    mov di,si             {}
    dec di                {}
    mov al,new            {}
    stosb                 {    es:id := new;      }
    mov al,old
                          { end;                  }
@skip_me:
    loop @looper          { dec cx; loop if cx <> 0 }
 
    pop si
    pop ds
    pop di
    pop es
  end;
end;
 
 
 
var S : string;
begin
  S :='Hemmo!';
  changeChars(S,'m','l');
  writeln(S);

  changeCharsASM(S,'l','m');
  writeln(s);
end.

