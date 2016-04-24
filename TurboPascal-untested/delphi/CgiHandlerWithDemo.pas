(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0358.PAS
  Description: CGI handler with demo
  Author: SWAG SUPPORT TEAM
  Date: 01-02-98  07:33
*)


{ NOTE THE Sample DEMO is included in XX34 format at the end }
unit cgi_h;

interface
uses classes;

{intitialize and cleanup procedures}
procedure InitializeCGI;
          {call this at the beginning of the program, it reads in and separates}
          {all the Form variables to allow easy calling from the functions}
procedure freeCGI;
          {call this at end of program to free the string list containing}
          {the form input}

{output special HTML codes easily}
procedure writeHTMLHeader;
          {writes out the header for an HTML document}
function sendFile(fileName:string):boolean;
          {sends a file to the server for output}
function sendFileBinary(fileName:string):boolean;
          {sends a binary file to the server for output}
function sendFileBinary2( fileName:string): boolean;
           {same but sends length header}
procedure br;
          {writes a <BR> code}
procedure hr;
          {writes an <HR> code}
function HRef(location, text: string):string;
         {returns a string containing the link to [location] around [text]}
function Image(location: string):string;
         {returns a string containing a reference to image at [location]}


{retrieve and output Form variables}
procedure outputList;
          {Outputs the list of form variables, one per line}
procedure outputListToFile(s:string);
          {Outputs all variables to an HTML file for easy reading}
          {Used for guestbooks.  It appends if fileExists}
function getInputVar(s:string):string;
         {return the value of the input variable}
function getAsField(s:string):string;
         {returns the value of the input variable with Field codes}
         {this one works when the Field name is the same as the Form variable}
function getAsFieldName(s,f:string):string;
         {similar to getAsField, except, this allows you to specify a different
         name for the field}
function getRemoteHost:string;
function getRemoteIP:string;
function getCookie(s:string):string;
function WinExecuteWait(s:string):boolean;


{string manipulations}
procedure findRepl(var s:string; f,r:string);
          {finds and replaces substrings in a string}
function EncodeURL(s:string):string;
         {puts the hex equivolent in for special characters}
         {(opposite of decodeFormInfo)}
function DecodeFormInfo(s:string):string;
         {Convert Form Info to regular text (remove Special Character Codes}


{Internally used functions...but you could use them if you know how}
function getRequestMethod:String;
         {gets the request method (POST or GET)}
function decodeHEXChr(s:string):char;
         {Converts a two digit Hex number to it's character equivolent}
function getContentLength:integer;
         {Returns the length of the Form Info}
procedure retrieveInput(var s:string);
          {Pulls in all Form variables}
procedure separateInput( s:string);
          {Separates the Form variables and put in string list}


implementation
uses windows,sysUtils;
const
  ValidURLChars:set of char=['A'..'Z','a'..'z','~','_','0'..'9'];
  alreadyRetrieved:boolean=false;
  clOpen:boolean=false;

var cl:TStringList;

procedure writeHTMLHeader;
begin
  writeln('Content-type:  text/html');
  writeln;
  writeln;
end;

procedure writeHTMLHeaderCookie(n,v,d:string);
begin
  writeln('Content-type:  text/html');
  if d<>'' then
  writeln('Set-cookie: '+n+'='+v+'; domain='+d)
  else
  writeln('Set-cookie: '+n+'='+v);
  writeln;
  writeln;
end;


procedure fr(var s:string; f,r:string);
var x:longint;
begin
  while pos(f,s)<>0 do begin
     x:=pos(f,s);
     delete(s,x,length(f));
     insert(r,s,x);
  end;
end;

procedure findRepl(var s:string; f,r:string);
begin
 fr(s,f,#25);
 fr(s,#25,r);
end;


procedure br;
begin
  writeln('<BR>');
end;

procedure hr;
begin
  writeln('<HR>');
end;


function HexDigit(c:char):integer;
begin
  c:=upcase(c);
  if (c>='0') and (c<='9') then result:=ord(c)-ord('0');
  if (c>='A') and (c<='F') then result:=ord(c)-ord('A')+10;
end;

procedure freeCGI;
begin
  clOpen:=false;
  cl.free;
end;

procedure InitializeCGI;
var s:string;
begin
   cl:=tStringList.create;
   clOpen:=true;
   retrieveInput(s);
   SeparateInput(s);
end;


function decodeHEXChr(s:string):char;
var x:integer;
begin
  x:=16*hexDigit(s[1])+hexDigit(s[2]);
  result:=chr(x);
end;


function EncodeURL(s:string):string;
var i:integer;
    c:char;
begin
   i:=1;
   findRepl(s,'!','!21');
   while (i<=length(s)) and (i<2000) do begin
       if (not (s[i] in validURLChars)) and (s[i]<>' ') and (s[i]<>'!') then begin
          c:=s[i];
          findRepl(s,c,'!'+intToHex(ord(c),2));
          i:=i+2;
       end;
       i:=i+1;
   end;
   findRepl(s,' ','+');
   result:=s;
end;

function DecodeFormInfo(s:string):string;
begin
   result:='';
   findRepl(s,'+',' ');
   findRepl(s,'!','%');
   while length(s)>0 do begin
         if s[1]='%' then begin
             delete(s,1,1);
             if s[1]='%' then begin
                 result:=result+'%';
                 delete(s,1,1);
             end else begin
                 result:=result+decodeHEXChr(copy(s,1,2));
                 delete(s,1,2);
             end;
         end else begin
             result:=result+s[1];
             delete(s,1,1);
         end;
   end;
end;

function getRemoteHost:string;
var PC: array[0..255] of char;
begin
   getEnvironmentVariable('REMOTE_HOST',PC,255);
   Result:=StrPas(pc);
end;

function getRemoteIP:string;
var PC: array[0..255] of char;
begin
   getEnvironmentVariable('REMOTE_ADDR',PC,255);
   Result:=StrPas(pc);
end;


function getCookie(s:string):string;
var PC: array[0..1023] of char;
   x:integer;
begin
   getEnvironmentVariable('HTTP_COOKIE',PC,1023);
   Result:=StrPas(pc);
   x:=pos(uppercase(s),uppercase(result));
   if x=0 then begin
      result:='';
      exit;
   end;  
   delete(result,1,x-1+length(s));
   x:=pos(';',result);
   if x<>0 then delete(result,x,length(result));
end;




function getContentLength:integer;
var PC: array[0..255] of char;
    Content_Length:string;
    x:integer;
begin
   result:=0;
   getEnvironmentVariable('CONTENT_LENGTH',PC,255);
   Content_Length:=StrPas(pc);
   val(Content_Length,result,x);
end;

function getRequestMethod:String;
var PC: array[0..255] of char;
begin
   getEnvironmentVariable('REQUEST_METHOD',PC,255);
   Result:=StrPas(pc);
end;

function getQueryString:String;
var PC: array[0..1023] of char;
begin
   getEnvironmentVariable('QUERY_STRING',PC,1024);
   Result:=StrPas(pc);
end;



procedure retrieveInput(var s:string);
var c:char;
    i:integer;
begin
s:='';
if alreadyRetrieved then exit;
alreadyRetrieved:=true;
if getRequestMethod='POST' then
for i:=1 to getContentLength do begin
    read(c);
    s:=s+c;
end
else
  s:=getQueryString;
end;

procedure separateInput( s:string);
begin
   if not clOpen then exit;
   while (length(s)>0) do begin
      if pos('&',s)<>0 then begin
         cl.add(copy(s,1,pos('&',s)-1));
         delete(s,1,pos('&',s));
      end else begin
         cl.add(s);
         s:='';
      end;
   end;
end;

procedure outputList;
var i:integer;
begin
   if not clOpen then exit;
   for i:=0 to cl.count-1 do
     writeln(decodeFormInfo(cl.strings[i])+'<BR>');
end;

procedure outputListToFile(s:string);
var i,j:integer;
    f:textFile;
begin
   if not clOpen then exit;
   if s='' then exit;
   assignFile(f,s);
   if fileExists(s) then append(f) else rewrite(f);
   try
      writeln(f,'<HR>('+timeToStr(time)+')--->['+dateToStr(date)+']<BR>');
      for i:=0 to cl.count-1 do begin
         s:=decodeFormInfo(cl.strings[i]);
         if pos('=',s)<>0 then begin
            j:=pos('=',s);
            delete(s,j,1);
            insert('</Strong><DD>',s,j);
         end;
         findRepl(s,#13,'<DD>');
         writeln(f,'<strong>'+s);
         writeln(f,'<BR>');
      end;
   finally
      closeFile(f);
   end;
end;



function getInputVar(s:string):string;
var i:integer;
begin
  if not clOpen then exit;
  i:=0;
  result:='';
  while i<cl.count do begin
     if uppercase(copy(cl.strings[i],1,length(s)))=uppercase(s) then begin
        result:=copy(cl.strings[i],pos('=',cl.strings[i])+1,length(cl.strings[i]));
        result:=decodeFormInfo(result);
        exit;
     end;
     inc(i);
  end;
end;

function getAsField(s:string):string;
begin
  result:=getInputVar(s);
  if result<>'' then result:='[Field '+s+':'+result+']';
end;


function getAsFieldName(s,f:string):string;
begin
  result:=getInputVar(s);
  if result<>'' then result:='[Field '+f+':'+result+']';
end;

function HRef(location, text: string):string;
begin
   result:='<A HREF="'+location+'">'+text+'</A>';
end;

function Image(location: string):string;
begin
   result:='<IMG SRC="'+location+'">';
end;

function sendFileBinary( fileName:string): boolean;
var fileHandle:HFile;
    f:char;
    x,i:integer;
begin
result:=false;
FileHandle:= CreateFile( PChar(fileName), Generic_Read, File_Share_Read,
   nil, Open_Existing, File_Attribute_Normal, 0);
if FileHandle = Invalid_Handle_Value then exit;
fileSeek(fileHandle,0,0);
repeat
x:=fileRead(FileHandle,f,sizeOf(f));
write(f);
until x<>sizeOf(f);
closeHandle(fileHandle);
result:=true;
end;


function sendFileBinary2( fileName:string): boolean;
var fileHandle:HFile;
    f:char;
    x,i:integer;
    l:longInt;
begin
result:=false;
FileHandle:= CreateFile( PChar(fileName), Generic_Read, File_Share_Read,
   nil, Open_Existing, File_Attribute_Normal, 0);
if FileHandle = Invalid_Handle_Value then exit;
l:=getFileSize(fileHandle,@l);
writeln('Content-type: application/octet-string');
writeln('Content-Length: '+intToStr(l));
writeln;
fileSeek(fileHandle,0,0);
repeat
x:=fileRead(FileHandle,f,sizeOf(f));
write((f));
until x<>sizeOf(f);
closeHandle(fileHandle);
result:=true;
end;


function sendFile( fileName:string): boolean;
var fileHandle:HFile;
    f:array [0..2000] of char;
    x,i:integer;
begin
result:=false;
FileHandle:= CreateFile( PChar(fileName), Generic_Read, File_Share_Read,
   nil, Open_Existing, File_Attribute_Normal, 0);
if FileHandle = Invalid_Handle_Value then exit;
fileSeek(fileHandle,0,0);
repeat
x:=fileRead(FileHandle,f,sizeOf(f));
write(f);
until x<>sizeOf(f);
closeHandle(fileHandle);
result:=true;
end;


function WinExecuteWait(s:string):boolean;
var StartupInfo:TStartupInfo;
     ProcessInfo: TProcessInformation;
begin
   if (CreateProcess(nil, pchar(s), Nil, Nil, FALSE,
                     0, nil, nil, StartupInfo, Processinfo))
   then begin
   waitForSingleObject(ProcessInfo.Hprocess, INFINITE);
   result:=true;
   end else begin
   result:=false;
   end;
end;


end.

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-002753-200896--72--85-45224------SAMPLE.ZIP--1-OF--1
I2g1--E++++6+17R302nurKqA++++1M++++9++++EIt7HI3IFGt6J2qnGQdDePHXtP9lA9Ef
GGoigR5DA+FlArDH3Me9YaoHwn7n2ohGxJ6fIip-sjdUxE-EGkA23+++++U+ZZoI6OJG9TLQ
++++6E6+++g+++-VPaZhMLFZ9aFkQfKEnIv26-G3xoru1imcWH1Jl6rBP1Enfq4MsIdjEWw2
PhBdXCxiNMnFyL2bP+WQQytrW0asN+NV0+T1oBJJLMoNQZo7AG5NACLPjQCLLW+7KIsuaWm9
Q+QCuJCtf0YVUuR4DURW63MwFrUIkyUNcoawCeU-1q-JUiXB5fdR4AaOB8wrNCJBxniaCopJ
ud9gRBfGkQ58sSiZk8y914GruC27ONbSmC8topRApmWCypxMvjxYmFsUBUxhqttzlYywwj7a
O-O-SoV5b0ksW1XaLajxTZuUy7Lu9fXEuExEGkA23+++++U+ZZkI6RwVdfLZ+k++qUE+++c+
++-dPK3bNH2iNqZa9JBzHBFZ45zj1fUvvc+qGN1-9ERfU1OopnCmv6xECHLfacKIEePb4vwe
yFJrOqkrn6gckrN1SUiBIxZEpUasyOBPAiOQb9t2or29twllFwmO9eEZUyXdSPvqzb5PQwzn
T5sxRwKPBlIyxuu9iRUXlU++DvlS9zjzQQM2Mt6lVRxHlHbXUb57i46Qe0Ys2s67mMFW+aVK
QWM3Yt77lGHEei7A0OMYIscdM2H04EU4Yc30JU6aOAH0NNk4se2bC7SQ8wu-O92GUUj7VS60
G+IqdS-GQeas--83godk7PZGL+3el3ICUcDYc1U+GGMD8-dJcWkU-wG2o6W3mo04eAMbVJ-0
+DZ1KemY33670KELJK-HGO4II61iIFHC0d+0Z+0UA0UgrAMso1xEBaE7kJ+oeUG8WcUF4u2F
0mUtOaCBHoY730HuEpegZ768A3SoWmek8I37+6eNfW7cZc64Gdqm2vF8QE+RUFk8EW9FE1QV
5M8+0FfcF1EhW6QSsAIkGDG5h3WdlvwGvTmU5FWo2s7q7B1C+3fEc2I7KZWUlE4OMR+gUGMO
B3aU2MA41RcmO4qBWWIZ7KJYNCHathfhxe8W6eTHKJNKJZpRvLOvTHuTrywD-+9-M1+I0cL1
sIUY2cj3NaNa5izeR1exLawk4C9Wsi9XslAG2cl4cwZYAdjBWMa73cj3OfIWTb7mQYd8mYfu
nRBzkKU0dXBZCjevVkyMZiHj4iYDLDvoWSkhLMu-spQyHyRJhoQ4HZlhTuec9LDnsAakDrTv
uJrVkNvfbOjqLijmp97hbMOOCmtNDrpBdqiMLtD58bsCD3qTI7eTKibcqReyffZeHRLBItZx
anfOv5x2jhwFWeHyCLuux71nShrubOzrrSejKPvoHQjO1rPyo5XzpMO3YXAP9XIjfYpZPDxP
3peKNDnPJXUkTCK9f-ItpiQ5LEQvNghTufKzTrRIPosHpcipYpp5WuDqNx6fTfzFPLksTayW
fiPwhfGnYKyzuLvkWvvDhtVoiq8glRSoo1UeUrJrKjq47hCQNqPgtiexMw4tJIqygoA3ExO0
Gu5v1xhzD35Qyj5uVRY5ymurbvapgjbLqSXtcM7rC0nyArvp1Szkp9HB0wgiq3cSfLNwRq+y
fxLqWL39eSqUtSqt96xtrdWpALpDT2TXbARRwZtjHyxYvS72qcv43PNnlzRzh2wwKPtvh1Tu
NTslJzFEsPB9MsQBFzv8zif1tQhmDaj8itSnjLVm73PyKYZZHrrqFgxIlveqYpB5hjvoxMrC
rGxTrDC88rxWmjbWiPmchDnhiBjJ28aQDifyvRHoAFOrUPrk5p-9+kEI++++0+0qL-EVvp1M
NnM2+++a-E++0U+++4ZhMKRZAWtbOKMhIrpApKIITWxkiNSD0qpgd6G9Q3s73Kfjk+NPozUE
Q1dKsogUsQNSaXT3iG+cJkkE+WmLXC0RU3qsrjW6msTB3ZHHW6xP9tWf8+ozIVFlOkpakCs4
drByRjutCvxnnbCStnbjrNSOzB9ikW7Kl3MN+s0BXErwNTw5Nokk7VZHx-2nnVYLX2j43SB+
FQ4N22l67VEHE9qGAmaMZ2ke7c343KR8A0KNIYk-kEBb6-V6-Uer2X--6lMCMnTE5Uf-iSFQ
QEuo3XAVi7-Q80u+K4-F0WsZZsd9639MekFLYWj33G-55CIUC2UCWUAENR8+d72ZoU7GE7gE
4f3k42UEtFVG00I2Y1tQWtaIEWcVUSEW0mke8NEG0Z+xYg7S+J8+2U-Y-da3oqU5uUTmVWEV
4774ZY-KoK92FaX2+b8CmdVX80a-X2Fxi-MndOE0x-LZ6UggGZ+GU4maekXe7OC-L0Tj-6qG
5I-566K0Y6Uoo2q6Vm-UUUMu2LI9qYA-S12o2jLVKgkIjV9hBM-qPx+i0hfBE9g8O9u1tWlc
rc5a1aXuEJA6aUPEK694+vFBc44-pUpDQgNA7ZB6G2V2F2FAH2l0EY7uSbdyTfvJOWoj9uyh
fKpeOf9NP2ubQrFopCJmnQvCngzD9mohDNbJuLES5VuSbdtSLZtujRvPqxhUA-WBFVwT5pxT
LnwzDrxzTwED0+U61+nQGKySzUg46n0RAHFZw9AfpQOUm9mdERhMrJBPoxdGVXf54nTl6rBH
EpqHNw6G4Y7HVyqidcXLSjBQklRyObbVXFzPIWwudgxt4lvCTFqoTOfRcwfLpDj9xiGCi9f6
9L4LrlnLvSx8DjfcwLDdDRYmwuUldWyfDnScP1ohYzoqe7zwRDrRs3qJRijjZolxgJ4tLtLw
TODRyeLnpaXiiaxGkxjFBrhC4ftjngosTipIpN1NaPDuMhP2vYNrywvMtJRbca7quDhztbyc
6uYhtfuFytO9kES0zdIXdQI1Zv8WNbM3jrCsytjrWYrCsS9YenyIZdli0motq1DR5ZEIhRtt
vx5gttMnulLlexRiDLwA+e8zWuycPvvONFVsqS7SmPkyJfkKgb9GTSCTURW-kqi94sOD1+KJ
5U4haSxvFtPZJnLgbGmcBdenPlQ2DhVqjReFh7-LiwYhvhEgPvZEa-7KqrfnkqRRgLySK7aq
Kldbftk8rlQxYrrvxCGrlbi7MLRPwrCqVViODhulDDLLzgHMf9gTX6kbnNop-xT7V0lRjPrt
QQPWT5BZQv8xqZOOSeTZuRd3qtuOxEm5hTWJ5bDHUHH5zLCKWRG3xiCCF5D5aAapw5dBngG1
wqztd4qqbL0bV5RK9xLARclhRXwwTzPMaeBfzdDulKGRpyJhZde8LlSvIvkDxLFrZFoerBhn
ReFrHryjbnjmWu4NiDHSNzFq3jwTI2g-+X693+++++U+AZoI6HDfRPMk++++BU++++g+++++
+++++E+U+9O-+++++23CGIp-J2IiG3FBI2g-+X693+++++U+ZZoI6OJG9TLQ++++6E6+++g+
+++++++++E+U+9O-KE+++43iOKpVR4IiN5-mI2g-+X693+++++U+ZZkI6RwVdfLZ+k++qUE+
++c++++++++++++U+9O-LU2++4ZhMKRZAGtbOKNEGk20AUgI++++0+0qL-EVvp1MNnM2+++a
-E++0U+++++++++++0++hc3f-E++OKpVNqIm9aRdNZ-9-EM+++++-++2+C6+++170E++++++
***** END OF BLOCK 1 *****


