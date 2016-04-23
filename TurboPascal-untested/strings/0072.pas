{
From: GLENN CROUCH
Subj: BASM STRING ROUTINES
---------------------------------------------------------------------------
The following has been adjusted to do word aligned operations where possible
for speed:
}

{$A+}
const
     PadCh : CHAR = #32;

function PadRightStr (const S : string; Len : Byte) : string; assembler;

     { S is the String to Pad, Len is the length of the resultant String
          Function adds Spaces to the Right of the String until Length is
          Achieved. if Length (S) >= Len, then S is returned }

asm
          mov dx, ds          { Save DS Register }
          cld                 { Clear Direction Flag }
          les di, @Result     { ES:DI => OutGoing String }
          lds si, [S]         { DS:SI => Incoming String }
          lodsb               { Read Length }
          mov bh, al          { Store Length in BH }
          sub ah, ah          { Set AH to 0 }
          mov cx, ax          { Load CX with Current Length }
          mov bl, [Len]       { Load Length of Dest into BL }
          cmp al, bl
          jnb @2
          mov  al, bl           { Write Length }
     @2:  stosb

      { Copy String }

          jcxz @1             { Ensure that there is some string to Copy }
          movsb               { Move first char so stay word aligned }
          dec  cx
          jcxz @1
          shr cx,1            { CX <- CX div 2 }
          rep movsw           { move rest as words }
          jnc @1              { if carry then odd number }
          movsb               { so move the odd one }

     { Padding }

     @1:  sub   bl, bh          { Calculate how many spaces }
          jna  @3             { if <= 0 then no padding needed }
          sub cx, cx          { Load CX with No. of Spaces }
          mov cl, bl
          mov al, ' '         { place pad character into al }
          shr bh, 1           { if original length was even then not word
                             aligned }
          jc @4
          stosb               { Write first space to keep word aligned }
          dec cx
          jcxz @3
     @4:  mov ah, al          { place ' ' also in Ah }
          shr cx, 1           { Move Words }
          rep stosw
          jnc  @3             { Check if even number }
          stosb               { Move odd space if any }
     @3:  mov ds, dx          { Restore DS Register }
end;
