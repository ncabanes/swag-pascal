(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0027.PAS
  Description: Decode MIME (Base64) Files
  Author: ARNE DE BRUIJN
  Date: 02-21-96  21:03
*)

{
 JD> This 'base64' encoding is new to me. Anybody out there who has an
 JD> algorithm or code.

=== UNBASE64.PAS
{ Decode base-64 files, Arne de Bruijn, 1996, Released to the Public Domain }
{ Strip everything but the base-64 lines before feeding it into this program }
uses dos;
var
 Base64:array[43..122] of byte;
var
 T:text;
 Chars:set of char;
 S:string;
 K,I,J:word;
 Buf:pointer;
 DShift:integer;
 F:file;
 B,B1:byte;
 Decode:array[0..63] of byte;
 Shift2:byte;
 Size,W:word;
begin
 FillChar(Base64,SizeOf(Base64),255);
 J:=0;
 for I:=65 to 90 do
  begin
   Base64[I]:=J;
   Inc(J);
  end;
 for I:=97 to 122 do
  begin
   Base64[I]:=J;
   Inc(J);
  end;
 for I:=48 to 57 do
  begin
   Base64[I]:=J;
   Inc(J);
  end;
 Base64[43]:=J; Inc(J);
 Base64[47]:=J; Inc(J);
 if ParamCount=0 then
  begin
   WriteLn('UNBASE64 <mime file> [<output file>]');
   Halt(1);
  end;
 S:=ParamStr(1);
 assign(T,S);
 GetMem(Buf,32768);
 SetTextBuf(T,Buf^,32768);
 {$I-} reset(T); {$I+}
 if IOResult<>0 then
  begin
   WriteLn('Error reading ',S);
   Halt(1);
  end;
 if ParamCount>=2 then
  S:=ParamStr(2)
 else
  begin write('Destination:'); ReadLn(S); end;
 assign(F,S);
 {$I-} rewrite(F,1); {$I+}
 if IOResult<>0 then
  begin
   WriteLn('Error creating ',S);
   Halt(1);
  end;
 while not eof(T) do
  begin
   ReadLn(T,S);
   if (S<>'') and (pos(' ',S)=0) and (S[1]>=#43) and (S[1]<=#122) and
    (Base64[byte(S[1])]<>255) then
    begin
     FillChar(Decode,SizeOf(Decode),0);
     DShift:=0;
     J:=0; Shift2:=1;
     Size:=255;
     B:=0;
     for I:=1 to Length(S) do
      begin
       case S[I] of
        #43..#122:B1:=Base64[Ord(S[I])];
       else
        B1:=255;
       end;
       if B1=255 then
        if S[I]='=' then
         begin
          B1:=0; if Size=255 then Size:=J;
         end
        else
         WriteLn('Char error:',S[I],' (',Ord(S[I]),')');
       if DShift and 7=0 then
        begin
         Decode[J]:=byte(B1 shl 2);
         DShift:=2;
        end
       else
        begin
         Decode[J]:=Decode[J] or Hi(word(B1) shl (DShift+2));
         Decode[J+1]:=Lo(word(B1) shl (DShift+2));
         Inc(J);
         Inc(DShift,2);
        end;
      end;
     if Size=255 then Size:=J;
     BlockWrite(F,Decode,Size);
    end;
  end;
 Close(F);
 close(T);
end.

