(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0017.PAS
  Description: Text File Positions
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  22:01
*)

Unit TextUnit;

Interface

{$B-,D-,E-,I-,L-,N-,X+}

Uses Dos;

  Function TextFilePos(Var andle:Text):LongInt;        { FilePos    }
  Function TextFileSize(Var andle:Text):LongInt;       { FileSize   }
  Procedure TextSeek(Var andle:Text;Pos:LongInt);      { Seek       }
  Procedure TextBlockread(Var andle:Text; Var buf;     { Blockread  }
                      count:Word; Var result:Word);
  Procedure TextBlockWrite(Var andle:Text;  Var buf;   { BlockWrite }
                        count:Word; Var result:Word);
  Function BinEof(Var andle:Text):Boolean;             { eof ohne $1a   }
  Function TextSeekRel(Var andle:Text; Count:LongInt):LongInt;
                                                       { Relativer Seek }

Implementation

Const
  ab_anfang=0;     { DosSeek }
  ab_jetzig=1;
  ab_ende=2;

Function DosSeek(Handle:Word; Pos:LongInt; wie:Byte):LongInt;
Type dWord=Array[0..1] of Word;
Var Regs:Registers;
    erg:LongInt;
begin
  With Regs do begin
    ah:=$42;
    al:=wie;
    bx:=Handle;                 { Dos-Handle }
    cx:=dWord(Pos)[1];          { Hi-Word Position }
    dx:=dWord(Pos)[0];          { Lo-Word Position }
    MSDos(Regs);
    if Flags and fCarry<>0 then begin
      InOutRes:=ax;
      erg:=0
      end
      else erg:=regs.ax+regs.dx*65536;
  end;
  DosSeek:=erg;
end;

Function TextFilePos(Var andle:Text):LongInt;
Var erg:LongInt;
begin
  erg:=DosSeek(Textrec(andle).Handle, 0, ab_jetzig)
                   -TextRec(andle).Bufend
                   +TextRec(andle).BufPos;
   TextFilepos:=erg;
end;

Function TextFileSize(Var andle:Text):LongInt;
Var TempPtr, erg:LongInt;
begin
  Case TextRec(andle).Mode of
    fmInput:with Textrec(andle) do begin
              TempPtr:=DosSeek(Handle, 0, ab_jetzig);
              erg:=DosSeek(Handle, 0, ab_ende);
              DosSeek(Handle, TempPtr, ab_anfang);
            end;
    fmOutput:erg:=TextFilePos(andle);
    else begin
      erg:=0;
      InOutRes:=1;
    end;
  end;
  TextFileSize:=erg;
end;

Procedure TextSeek(Var andle:Text; Pos:LongInt);
Var aktpos:LongInt;
begin
  aktpos:=TextFilePos(andle);
  if aktpos<>pos then With Textrec(andle) do begin
    if Mode=fmOutput then flush(andle);
    With Textrec(andle) do begin
      if (aktpos+(bufend-bufpos)<Pos) or (aktpos>Pos) then
       begin
        bufpos:=0;
        bufend:=0;
        DosSeek(Textrec(andle).Handle, pos, ab_anfang);
       end
       else begin
         inc(bufpos, pos-aktpos);
       end;
      end;
  end;
end;

Procedure TextBlockread(Var andle:Text; Var buf; count:Word; Var result:Word);
Var R:Registers;
    noch, ausbuf:Word;
    posinTextbuf:Pointer;
begin
  if Textrec(andle).Mode<>fmInput then InOutRes:=1
   else begin
    With Textrec(andle) do
     begin
       noch:=bufend-bufpos;
       if noch<>0 then
         begin
            if noch<count then ausbuf:=noch else ausbuf:=count;

           posinTextbuf:=Pointer(LongInt(bufptr)+bufpos);
           move(posinTextbuf^, buf, ausbuf);
           inc(bufpos, ausbuf);
         end;
     end;
    if noch<count then With r do
      begin
        ds:=Seg(buf);
        dx:=Ofs(Buf)+noch;
        ah:=$3f;
        bx:=Textrec(andle).Handle;
        cx:=count-noch;
        MsDos(R);
        if Flags and fCarry<>0
          then InOutRes:=ax
          else result:=ax+noch;
      end
      else result:=count;
   end;
end;

Procedure TextBlockWrite(Var andle:Text; Var buf; count:Word;Var result:Word);
Var r:Registers;
    posinTextbuf:Pointer;
begin
  if Textrec(andle).Mode<>fmOutput then InOutRes:=1
   else begin
     With Textrec(andle) do begin
       if (bufsize-bufpos)>count then
        begin
          posinTextbuf:=Pointer(LongInt(bufptr)+bufpos);
          move(buf, posinTextbuf^, count);
          inc(bufpos, count);
        end
        else begin
          flush(andle);
          With r do begin
            ah:=$40;
            cx:=count;
            ds:=seg(buf);
            dx:=ofs(buf);
            bx:=Handle;
            MsDos(r);
            if Flags and fCarry<>0 then InOutRes:=ax
                                   else Result:=ax;
          end;
        end;
       end;
   end;
end;

Function TextSeekRel(Var andle:Text; count:LongInt):LongInt;
Var ziel, erg:LongInt;
begin
  With Textrec(andle) do begin
    if Mode=fmOutput then begin InOutRes:=1; Exit; end;
    if (count<0) then
      begin
        ziel:=TextFilePos(andle)+count;
        if ziel<0 then ziel:=0;
        TextSeek(andle, ziel);
        erg:=ziel;
      end
    else if ((bufend-bufpos)<Count) then
      begin
        ziel:=count-(bufend-bufpos);
        if ziel<0 then ziel:=0;
        erg:=DosSeek(Textrec(andle).Handle, ziel, ab_jetzig);
        bufpos:=0; bufend:=0;
      end
      else begin
        inc(bufpos, count);
        erg:=maxLongInt;
      end;
  TextSeekRel:=erg;
  end;
end;


Function BinEof(Var andle:Text):Boolean;
Var e:Boolean;
begin
  e:=eof(andle);
{$R-}
  With Textrec(andle) do
    BinEof:=e and (bufptr^[bufpos]<>#$1a);
{$R+}
end;


end.


