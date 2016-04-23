Program Display;

Uses Crt;

procedure loadpcx(fname:string);
var f             : file ;
    buf           : array[1..16] of byte;
    pcxdata,palet : pointer ;
    pcxlen        : word;

begin
   assign(f,fname);
   {$I-}
   reset(f,1);
   if ioresult<>0 then exit; { couldnt open file}
   blockread(f,buf,16);
   if ioresult<>0 then exit; { Read error }
   if buf[1]<>$0a then exit;  {no pcx file}
   if (buf[2]<>5) or (buf[4]<>8) then exit; {no 256 colors}
   if (buf[13]<>$40) or (buf[14]<>$01) or (buf[15]<>$c8) or (buf[16]<>0)
   then Exit;

   pcxlen:=filesize(f)-128-768;
   getmem(pcxdata,pcxlen);
   seek(f,128);
   blockread(f,pcxdata^,pcxlen);
   if ioresult<>0 then exit;
   {$I+}
{---- read body ----}
   asm
     push ds
     Mov DI,$A000
     Mov ES,DI
     And Di,0
     lds si,pcxdata
     mov bx,di
     add bx,64000
@nextpcxbyte:
     mov al,[si]
     inc si
     mov cl,al
     and cl,$c0
     cmp cl,$c0
     je @herhaling
     mov cl,1
@verder:
     rep stosb
     cmp di,bx
     je @end
     jmp @nextpcxbyte
@herhaling:
     mov cl,al
     and cl,$3f
     mov al,[si] ; inc si
     jmp @verder
@end: pop ds
   end;

{-------- read palette --------}
      seek(f,filesize(f)-768);
      GetMem(palet,768);
      blockread(f,palet^,768);
      if ioresult<>0 then exit;
      asm
        les di,palet
           mov ax,768
        mov cl,2
       @1:
        shr es:[di],cl
        inc di
        dec ax
           jnz @1
        mov ax,$1012
        mov bx,0
        mov cx,255;
        les dx,palet
        int $10
      end;
   close(f);
end;

Begin

  Asm Mov AX,$13; Int $10 End;

  IF Paramcount > 0 THEN
     BEGIN
     LoadPcx(ParamStr(1));
     ReadLn;
     END;

  Asm Mov AX,$3; Int $10 End;

End.

