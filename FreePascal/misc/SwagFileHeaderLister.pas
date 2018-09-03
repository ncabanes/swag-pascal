(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0180.PAS
  Description: SWAG File Header Lister
  Author: VALERY VOTINTSEV
  Date: 05-31-96  09:17
*)

{-------------------------------------------------------------}
{                  Small SWAG LISTER                          }
{            (c) 1996 by Valery Votintsev                     }
{                         E-Mail: vot@infolink.tver.su        }
{                         FIDO:   2:5021/2.30                 }
{          modified slightly by Gayle Davis                   }
{-------------------------------------------------------------}

{ Tested in 2018 with CRC.SWG dated 30-Sep-1997: does not seem to work }

Program SWAGL;

Uses DOS;

TYPE
  SwagHeader =
    RECORD
      HeadSize : BYTE;                 {size of header}
      HeadChk  : BYTE;                 {checksum for header}
      HeadID   : ARRAY [1..5] OF CHAR; {compression type tag}
      NewSize  : LONGINT;              {compressed size}
      OrigSize : LONGINT;              {original size}
      Time     : WORD;                 {packed time}
      Date     : WORD;                 {packed date}
      Attr     : WORD;                 {file attributes and flags}
      BufCRC   : LONGINT;              {32-CRC of the Buffer }
      Swag     : STRING[12];           {stored SWAG filename}
      Subject  : STRING[40];           {snipet subject}
      Contrib  : STRING[35];           {contributor}
      Keys     : STRING[70];           {search keys, comma deliminated}
      FName    : PathStr;              {filename (variable length)}
      CRC      : WORD;                 {16-bit CRC (immediately follows FName)}
    END;

    SWAGFooter =
    RECORD
       CopyRight : String[60];         { GDSOFT copyright }
       Title     : String[65];         { SWG File Title   }
       Count     : INTEGER;
    END;

    ShortHeader =
    RECORD
      OrigSize : LONGINT;               {original size}
      Date     : WORD;                  {packed date}
      Subject  : STRING[40];            {snipet subject}
      Contrib  : STRING[35];            {contributor}
    END;

Var
   PMask,
   FMask: String;                       { SWAG files mask      }
   Buf: SwagHeader;                     { Temporary buffer     }
   Footer:SWAGFooter;                   { SWAG file footer     }
   NextPos:LongInt;                     { Next snipet position }
   fSize:LongInt;                       { File size            }
   aList:Array[1..2000] of Pointer;     { Array of snipet info }
   pShortHeader: ^ShortHeader;          { snipet info pointer  }
   ListLen:Integer;                     { Snipet array length  }
   Snipets:Integer;                     { Number of snipets    }
   AllSize:LongInt;                     { All snipets size     }
   TotalSize:LongInt;                   { Total size           }
   F:File;
   DirInfo:SearchRec;
   i:integer;
   Dir: DirStr;
   Name: NameStr;
   Ext: ExtStr;

{----------------------------------------------}
{ Convert the string to upper case             }
{(Russian conversion is excluded for simlicity)}

Function StUpcase(S:String):String;
Var
   i:integer;
   l:byte absolute S;
begin
   StUpcase[0]:=Chr(l);
   For i:=1 to l do
      StUpcase[i]:=UpCase(S[i]);
end;

{----------------------------------------------}
{ Repeat the char n times                      }
Function Replicate(C:Char;n:byte):String;
Var
   i:integer;
begin
   Replicate[0]:=Chr(n);
   For i:=1 to n do
      Replicate[i]:=C;
end;

{----------------------------------------------}
{ String Pad Right                             }
Function PadR(S:String;n:byte):String;
Var
   i:integer;
   l:byte absolute S;
begin
   PadR:=S;
   PadR[0]:=Chr(n);
   For i:=l+1 to n do
   begin
      PadR[i]:=' ';
   end;
end;

{----------------------------------------------}
{ Convert Integer to string & add leading zero }
Function LeadZero(L:Longint;n:byte):String;
Var
   i:integer;
   S:String;
begin
   STR(L:n,S);
   For i:=1 to n do
      If S[i]=' ' then S[i]:='0';
   LeadZero:=S;
end;
{-------------------------------------------}
{ Convert packed date to string }
Function Date2str(D:Word):String;
Var
   Day  :Word;
   Month:Word;
   Year :Word;
begin
   Day  := ( D and $1F);
   Month:= ( D and $1E0) shr 5;
   Year := ( D and $FE00) shr 9;
   Date2str:=LeadZero(Day,2)+'-'
            +LeadZero(Month,2)+'-'
            +LeadZero((Year+80),2);
end;


{--------- Main Routine ---------------------------------------}
begin
   FMask := ParamStr(1); { Get the file mask from command line }
   If FMask <> '' then
   begin
      FSplit(FMask, PMask, Name, Ext);

      FindFirst(FMask,ARCHIVE,DirInfo); { Search first file }

      Writeln('');
      Writeln('================= SWAG Snipets List ==================');
      Writeln('   (c) 1996 by Valery Votintsev (vot@infolink.tver.su)');
      Writeln('');
      Writeln('From                 Size   Date   Subject');
      Writeln('------------------- ----- -------- ---------------');

      TotalSize:=0;
      Snipets  :=0;

      While DOSError = 0 do   { while files exists }
      begin
         FSplit(DirInfo.Name, Dir, Name, Ext);
         If StUpcase(Ext)='.SWG' then begin    { Skip not .SWG files }
            Assign(F,Pmask + DirInfo.Name);
            Reset(F,1);

            NextPos:=0;
            FSize:=FileSize(F);
            AllSize:=0;
            ListLen:=0;

            While (nextPos+SizeOf(Buf)) < FSize do
            begin
               Seek(F,NextPos);
               BlockRead(F,Buf,SizeOf(Buf));

               New ( pShortHeader ); {Allocate memory}
               Inc(ListLen);
               aList[ListLen]:=pShortHeader;

               With pShortHeader^ do
               begin
                  OrigSize := Buf.OrigSize;
                  Date     := Buf.Date;
                  Subject  := Buf.Subject;
                  Contrib  := Buf.Contrib;

                  Inc(AllSize,OrigSize);
               end;
               NextPos:=NextPos+Buf.HeadSize+buf.NewSize+2;
            end;

            SEEK (F, FileSize(F) - SIZEOF(Footer));
            BlockRead(F,Footer,SizeOf(Footer));
            Close(F);

            { Say snipet header }
            Writeln('');
            Writeln(PadR(StUpcase(DirInfo.Name),12),' - ',Footer.Title);
            i:=Length(Footer.Title)+15;
            Writeln(Replicate('~',i));

            { List snipets in the file }
            For i:=1 to ListLen do
            begin
               pShortHeader:=aList[i];

               { Say the snipet info}
               With pShortHeader^ do
               begin
                  Write  (PadR(Contrib,19),' ');
                  Write  (OrigSize:5,' ');
                  Write  (Date2str(Date),' ');
                  Writeln(PadR(Subject,40));
               end;
               Dispose (pShortHeader); {Release memory}
            end;

            Inc(Snipets,ListLen);
            Inc(TotalSize,AllSize);

            { Say this file totals}
            Writeln('------------------- -----');
            Writeln(ListLen:13,AllSize:12);
         end; {If Ext = .SWG }
         FindNext(DirInfo);  { Search next file }
      end; {While DosError}

      { Say totals}
      Writeln('------------------- -----');
      Writeln('Total:',Snipets:7,TotalSize:12,' bytes');
      Writeln('');
   end; {If Mask <> ''}
end.
