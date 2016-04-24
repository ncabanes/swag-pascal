(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0129.PAS
  Description: LTRIM & assembler
  Author: PETER OGDEN
  Date: 05-31-96  09:17
*)

(*
In a message dated Wednesday March 13 1996, Mario Polycarpou of 3:690/354
wrote:
 DR>> function LTrim(S: string): string;
 DR>> var C: Byte;
 DR>> begin
 DR>> for C := 1 to Length(S) do if S[C+1]<>#32 then Break;
 DR>> LTrim := Copy(S,C,255);
 DR>> end;

 MP>  Sorry mate but that's crap. Have a play with this...

 MP> {-+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--}
 MP> FUNCTION TrimL(S:String):String;     {Trim left}
 MP> VAR X:Integer;
 MP> BEGIN
 MP>  X:=1;
 MP>  WHILE S[X]=#32 DO Inc(X);
 MP>  TrimL:=Copy(S,X,Length(S));
 MP> END;
 MP> {-+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--}

OK, by my calculations, TrimL is about 10% faster - try this, it's about twice
as fast as Marios:
*)

function StripLBStr (const S: string): string; assembler;

asm
      mov  dx, ds     { Save DS Register }
      cld
      les  di, [S]    { ES:DI => Source }
      mov  al, es:[DI]{ Load Length of String }
      inc  di
      sub  cx, cx     { Set CX to Zero }
      mov  cl, al     { CX <- No. of Bytes }
      jcxz @1         { if Null String then Terminate }
      mov  ax, ' '    { Store ' ' in AX }
      repz scasb      { Scan String until no Space or string scan complete }
      jz   @3
      inc  cx
      dec  di
      push es
      pop  ds
      mov  si, di
  @3: mov  al, cl
  @1: les  di, @Result{ ES:DI => Destination }
      stosb           { store length byte }
      jcxz @2         { if CX = 0 then done }
      movsb           { Move first char so stay word aligned }
      dec  cx
      jcxz @2
      shr  cx,1       { CX <- CX div 2 }
      rep  movsw      { move rest as words }
      jnc  @2         { if carry then odd number }
      movsb           { so move the odd one }
  @2: mov  ds, dx     { Restore DS Register }
end;

