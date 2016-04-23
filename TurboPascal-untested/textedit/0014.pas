
{
 This is a very simple editor for ascii text files. It uses an array of
 pointers and dynamic memory allocation for every line, so that lines can
 easily be inserted or deleted without moving huge amounts of data.
 There is no saving available, but this should be easy to include.

 I recommend compiling this as a protected mode application (far more
 memory available), but you can also use it in real mode, if you want.
 You can edit texts of every size (no 64K limit), they just have to fit
 into your memory.

 This is Public Domain, feel free to use it for whatever you like, but at
 your own risk !

 Any questions, comments, etc. : heiner@rummelplatz.uni-mannheim.de
                                 Alexander Heiner
}

uses crt,dos;
{$F+}

type
    D_LStr = record
        StrLen: word;
        Str: array[0..16383] of byte;
    end;
    P_LStr = ^D_Lstr;

    D_TmpStr=array[0..16383] of char;

var
    LStr: array[0..16000] of P_LStr;
    TmpStr: ^D_TmpStr;
    YscrlPos,XscrlPos:longint;
    CrX,CrY:word;
    MaxLines:longint;
    ch:char;
    FName:string;

procedure OutString(x,y:word;s:string;tcol,bcol:byte);
var p:pointer;
begin
     p:=@s;
     asm
        push    ds
        mov     ax,SegB800
        lds     si,p
        mov     es,ax
        imul    di,y,160
        mov     ax,x
        shr     ax,1
        add     di,ax
        mov     ah,bcol
        shl     ah,4
        add     ah,tcol
        mov     cl,ds:[si]
        inc     si
@l1:
        lodsb
        stosw
        dec     cl
        jnz     @l1

        pop     ds
     end;
end;

procedure LoadText(Fname:string);
var f:text;a,b:word;s:string;gmem:longint;
begin
     getmem(tmpStr,16384);
     assign(f,Fname);
     reset(f);
     a:=0;gmem:=0;
     while not eof(f) do begin
           readln(f,TmpStr^);
           b:=0;while TmpStr^[b]<>#0 do inc(b);

           if memavail>=2+b then begin
              getmem(LStr[a],2+b);
              move(TmpStr^,LStr[a]^.Str,b);
              Lstr[a]^.StrLen:=b;
              inc(gmem,b+2);
           end else begin outstring(0,3,'Not enough memory.',7,0);halt(1);end;

           inc(a);if a>16000 then begin
           outstring(0,3,'Line overflow (max.16000)',7,0);halt(1);end;

           str(a,s);outstring(0,0,'lines loaded: '+s,7,0);
           str(gmem,s);outstring(0,1,'memory allocated: '+s+ ' bytes',7,0);
     end;
     MaxLines:=a-1;
     freemem(tmpStr,16384);
end;

procedure ShowAllText;
var x,y,len:word;s:string;
begin
     for y:=0 to 23 do begin
      s:='';
      if LStr[y+Yscrlpos]<>NIL then begin
         len:=LStr[y+Yscrlpos]^.StrLen;
        if len>XscrlPos then begin
         dec(len,XScrlPos);
         if len>80 then len:=80;
         move(LStr[y+Yscrlpos]^.Str[XScrlPos],s[1],len);
         s[0]:=chr(len);
        end;
      end;
      while s[0]<#80 do s:=s+' ';
      OutString(0,y,s,11,0);
     end;
end;

procedure ScrollDown;
begin
     if YScrlPos>=(MAxLines-23) then exit;
     inc(YScrlPos);
     ShowAllText;
end;

procedure ScrollUp;
begin
     if YScrlPos<1 then exit;
     dec(YScrlPos);
     ShowAllText;
end;

procedure ScrollRight;
begin
     inc(XScrlPos);
     ShowAllText;
end;

procedure ScrollLeft;
begin
     if XScrlPos<1 then exit;
     dec(XScrlPos);
     ShowAllText;
end;

procedure InsertChar(ch:char);
var l1,add:word;
begin
     inc(CrX,XScrlPos);
     l1:=LStr[CrY+YscrlPos]^.StrLen;
     if (CrX+1)<=l1 then add:=1 else add:=(crx+1)-l1;

     getmem(TmpStr,l1+add);
     move(LStr[CrY+YscrlPos]^.Str,TmpStr^,l1);
     if (CrX+1)<=l1 then move(TmpStr^[CrX],TmpStr^[CrX+1],l1-crx) else
     fillchar(TmpStr^[l1],crx-l1,32);
     TmpStr^[Crx]:=ch;

     freemem(LStr[CrY+YscrlPos],2+l1);
     getmem(LStr[CrY+YscrlPos],2+l1+add);

     move(TmpStr^,LStr[CrY+YscrlPos]^.Str,l1+add);
     LStr[CrY+YscrlPos]^.StrLen:=l1+add;

     freemem(TmpStr,l1+add);
     dec(CrX,XScrlPos);

     if CrX=79 then ScrollRight else inc(CrX);
     ShowAllText;
     gotoxy(CrX+1,CrY+1);
end;

procedure DeleteLine(Lpos:byte);
var y,l1,l2:word;
begin
     l1:=LStr[Lpos-1]^.StrLen;
     l2:=LStr[Lpos]^.StrLen+l1;
     getmem(TmpStr,l2);

     move(LStr[Lpos-1]^.Str,TmpStr^,l1);
     move(LStr[Lpos]^.Str,TmpStr^[l1],Lstr[Lpos]^.StrLen);
     freemem(LStr[Lpos-1],l1+2);
     getmem(LStr[Lpos-1],l2+2);
     move(TmpStr^,LStr[Lpos-1]^.Str,l2);
     LStr[Lpos-1]^.StrLen:=l2;

     dec(MaxLines);
     freemem(Lstr[Lpos],LStr[Lpos]^.StrLen+2);
     for y:=Lpos to MaxLines do LStr[y]:=Lstr[y+1];
     LStr[MaxLines+1]:=NIL;
     freemem(TmpStr,l2);

     if CrY=0 then ScrollUp else begin dec(CrY);ShowAllText;end;
     Crx:=l1;
     gotoxy(CrX+1,CrY+1);
end;

procedure DeleteChar;
var l1:word;
begin
     inc(CrX,XScrlPos);
     if Crx=0 then begin
        DeleteLine(Cry+YscrlPos);
        exit;
     end;
     l1:=LStr[CrY+YscrlPos]^.StrLen;

     getmem(TmpStr,l1);
     move(LStr[CrY+YscrlPos]^.Str,TmpStr^,l1);
     move(TmpStr^[CrX],TmpStr^[CrX-1],l1-crx);

     freemem(LStr[CrY+YscrlPos],2+l1);
     getmem(LStr[CrY+YscrlPos],2+l1-1);

     move(TmpStr^,LStr[CrY+YscrlPos]^.Str,l1-1);
     LStr[CrY+YscrlPos]^.StrLen:=l1-1;

     freemem(TmpStr,l1);
     dec(CrX,XScrlPos);

     if CrX=0 then ScrollLeft else dec(CrX);
     ShowAllText;
     gotoxy(CrX+1,CrY+1);
end;

procedure InsertLine;
var y,l1:word;
begin
     inc(CrX,XScrlPos);
     inc(MaxLines);
     l1:=LStr[YscrlPos+CrY]^.StrLen;
     for y:=MaxLines-1 downto Yscrlpos+CrY+1 do LStr[y+1]:=Lstr[y];

     if (CrX>=l1)or(l1=0) then begin
        getmem(LStr[YscrlPos+CrY+1],2+1);
        LStr[YscrlPos+CrY+1]^.StrLen:=0;
     end else begin
        getmem(LStr[YscrlPos+CrY+1],2+(l1-crx));
        move(LStr[YscrlPos+CrY]^.Str[CrX],LStr[YscrlPos+CrY+1]^.Str,l1-crx);
        LStr[YscrlPos+CrY+1]^.StrLen:=l1-crx;

        getmem(TmpStr,crx+1);
        move(LStr[YscrlPos+CrY]^.Str,TmpStr^,crx);
        freemem(LStr[YscrlPos+CrY],2+l1);
        getmem(LStr[YscrlPos+CrY],2+crx);
        move(TmpStr^,LStr[YscrlPos+CrY]^.Str,crx);
        LStr[YscrlPos+CrY]^.StrLen:=crx;
        freemem(TmpStr,crx+1);
     end;
     dec(CrX,XScrlPos);

     XScrlPos:=0;
     ShowAllText;
     CrX:=0;
     if CrY=23 then ScrollDown else inc(CrY);
     gotoxy(CrX+1,CrY+1);
end;


{----- cursor control ------------------------------------------------------}

procedure CursorDown;
begin
     if Cry+YscrlPos>=MAxLines then exit;
     if CrY=23 then ScrollDown else inc(CrY);
     gotoxy(CrX+1,CrY+1);
end;

procedure CursorUp;
begin
     if CrY=0 then ScrollUp else dec(CrY);
     gotoxy(CrX+1,CrY+1);
end;

procedure CursorRight;
begin
     if CrX=79 then ScrollRight else inc(CrX);
     gotoxy(CrX+1,CrY+1);
end;

procedure CursorLeft;
begin
     if CrX=0 then ScrollLeft else dec(CrX);
     gotoxy(CrX+1,CrY+1);
end;

procedure CursorAtLineEnd;
begin
     CrX:=LStr[YscrlPos+CrY]^.StrLen;
     if CrX>79 then begin XScrlPos:=CrX-79;CrX:=79; end else begin
       if CrX>XScrlPos then dec(CrX,XScrlPos) else XScrlPos:=0;
     end;
     gotoxy(CrX+1,CrY+1);
     ShowAllText;
end;

procedure CursorAtLineStart;
begin
     XScrlPos:=0;
     CrX:=0;
     gotoxy(1,CrY+1);
     ShowAllText;
end;

procedure PageDown;
begin
     inc(YscrlPos,22);if yscrlpos>MaxLines-23 then Yscrlpos:=Maxlines-23;
     ShowAllText;
end;

procedure PageUp;
begin
     dec(YscrlPos,22);if yscrlpos<0 then Yscrlpos:=0;
     ShowAllText;
end;


{----- status line ---------------------------------------------------------}

procedure ShowStats;
var s,s2,s3:string;
begin
     str(CrY+YScrlPos+1,s);
     str(MaxLines+1,s2);
     s3:='  '+FName;
     if s3[0]>#40 then s3[0]:=#40;
     while s3[0]<#40 do s3:=s3+' ';

     s3:=s3+'Line: '+s+' / '+s2+'     Row: ';
     str(CrX+XScrlPos+1,s);
     str(LStr[YscrlPos+CrY]^.StrLen,s2);
     s3:=s3+s+' / '+s2;
     while s3[0]<#80 do s3:=s3+' ';

     OutString(0,24,s3,0,7);
end;


{----- main ----------------------------------------------------------------}

begin

     FName:='test.doc';

     clrscr;
     XscrlPos:=0;YscrlPos:=0;CrX:=0;CrY:=0;

     LoadText(FName);
     ShowAllText;
     ShowStats;
     gotoxy(1,1);

repeat
      repeat until keypressed;
      ch:=readkey;
      if ch=#0 then begin
         ch:=readkey;
         if ch=#80 then CursorDown;
         if ch=#72 then CursorUp;
         if ch=#77 then CursorRight;
         if ch=#75 then CursorLeft;
         if ch=#71 then CursorAtLineStart;
         if ch=#79 then CursorAtLineEnd;
         if ch=#81 then PageDown;
         if ch=#73 then PageUp;
         ShowStats;
      end else begin
        if ch<>#27 then
         if ch=#8 then DeleteChar else
          if ch=#13 then InsertLine else
            InsertChar(ch);
            ShowStats;
      end;
until ch=#27;
end.
 

