{
Well, I'm writing a File Viewer and it works great, except for one thing, if
you're on the last screen of the file you're viewing, and you hit Page Down...
it will go BELOW the last line and display sime High ASCii Characters... I
have tried many things to get this to work... but it won't.. 
If SWAG wants this, they can have it...

---------------------------<CUT HERE>---------------------------

{This is Released Into the Public Domain on May 21             }
{By Steven B Edwards. Do what you want to it, if yo      ,     }
{give me some credit if you use it.                            }

Uses Crt, Dos;

Type LinePtr = ^LineRec;
     LineRec = String[79];

Var CurLine: Array[1..16000] of LinePtr;
    Total: Integer;
    Current, OldLine: Integer;
    F: Text;
    I: Byte;
    Ch: Char;
    Done, Again: Boolean;

procedure WriteColor(S : string);
var
  I: byte;
begin
 for I := 1 to Length(S)
  do begin
   case S[I] of
    '0'..'9' : textcolor(lightcyan);
    'A'..'Z' : textcolor(LightGray);
    'a'..'z' : textcolor(White);
    #9: Write(' ':8);
    else textcolor(3);
   end;
   If S[I] <> #9 then write(S[I]);
  end;
  I := 79 - Length(S); Write(' ':I);
end;

Begin

ClrScr;

Assign(F, ParamStr(1));
Reset(F);
Total := 1;
While not Eof(F) do begin
New (CurLine[Total]);
ReadLn(F, CurLine[Total]^);
Inc(Total);
end;
Close(F);

Current := 1;
Again := True;
Done := False;

Repeat
If Again then begin
For I := 0 to 23 do begin
                    GotoXY(1, I + 1);
                    WriteColor(CurLine[Current + I]^);
                    End;
                    Again := False; End;
Ch := ReadKey;
Case Ch of
     #0: begin
         OldLine := Current;
         Ch := ReadKey;
         Case Ch of
              #72: If Current > 1 then Dec(Current);
              #80: If Current + 24 < Total then Inc(Current);
              #73: {Page Up}
                   If Current > 23 then Dec(Current, 23);
              #81: {Page Down}
                   If Current < Total - 25 then Inc(Current, 23)
                   else Current := Total - 24;
              #71: {Home}
                   Current := 1;
              #79: {End}
                   Current := Total - 24;
              end;

         If OldLine <> Current then Again := True;

         end;

     end;
Until Ch = #27;
End.
