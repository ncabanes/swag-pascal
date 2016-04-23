{
MG> Wanted: Phone-directory (like TELIX.FON, etc...) structures in Pascal
MG>         format. Also what the fields can contain (e.g. 9600...155200,
MG>         'A'...'F')

    Didn't have it and since I might have to hack my own ZOC phonebook, since I
haven't found a utility yet that will convert from Telix to Zoc, I just decided
to have a go at it and here is the result.
Written, Compiled and tested on Borland Pascal 7.x.

##########################################################################
#######                                                            #######
#######   REMEMBER TO CHANGE THE PATH AND NAME FOR THE .FON FILE   #######
#######                                                            #######
##########################################################################

}

{$A+,B-,D+,E+,F+,G+,I+,L+,N+,O+,P+,Q+,R+,S+,T+,V+,X+,Y+}
{$M 16384,0,655360}
Program TelixFon;
{
 Read a Telix 3.22 Phonebook and display it one entry at a time
 The real purpose of the program is just to demonstrate that
 the structure definition is correct
}
uses crt;

type

 FlagSet = set of
  (LocalEcho,
  AddLineFeeds,
  RecvBSDest,
  SendBSDel,
  StripHigh,
  Dummy32,
  Dummy64,
  Dummy128);

 TlxFonRec = record
  BbsName : array [$00..$18] of char;
  Phone : array [$00..$10] of char;
  Baud : byte;
  Parity : byte;
  DataBits : byte;
  StopBits : byte;
  Script : array [$00..$0B] of char;
  LastCall : array [$00..$05] of char;
  TotalCalls : Word;
  Terminal : byte;
  Protocol : char;
  BitField : FlagSet;
  B_85h : byte;
  B_86h : byte;
  DialPrefix : byte;
  Password : array [$00..$0D] of char;
 end;


const
 BaudRate : array[0..8] of string =
 ('300', '1200', '2400', '4800', '9600',
 '19200', '38400', '57600', '115200');

 ParityType : array[0..4] of string =
 ('None', 'Even', 'Odd', 'Mark', 'Space');

 TerminalType : array[0..5] of string =
 ('TTY', 'ANSI-BBS', 'VT102', 'VT52', 'AVATAR', 'ANSI');

var
 TlxFon : file;
 Entry : TlxFonRec;
 Index : word;
 BbsName   : string[$18];
 BbsPhone   : string[$10];
 BBsScript  : string[$0B];
 BbsPassword : string[$0D];
 Ch : char;

Function Echo(Field:FlagSet) : string;

 begin
  if LocalEcho in Field then
   Echo := 'On'
  else
   Echo := 'Off';
 end;

Function LineFeeds(Field:FlagSet) : string;

 begin
  if AddLineFeeds in Field then
   LineFeeds := 'On'
  else
   LineFeeds := 'Off';
 end;

Function RecvBS(Field:FlagSet) : string;

 begin
  if RecvBSDest in Field then
   RecvBS := 'Off'
  else
   RecvBS := 'On';
 end;

Function SendBS(Field:FlagSet) : string;

 begin
  if SendBSDel in Field then
   SendBS := 'Del'
  else
   SendBS := 'BS';
 end;

Function StripHBit(Field:FlagSet) : string;

 begin
  if StripHigh in Field then
   StripHBit := 'On'
  else
   StripHBit := 'Off';
 end;


begin
 assign(TlxFon, 'C:\Comm\Telix.fon');
 reset(TlxFon,1);
 Index := 0;
 {
  Skip PhoneBook Header by seeking directly to first entry
 }
 Seek(TlxFon, $40);
 while not eof(TlxFon) do begin
  BlockRead(TlxFon, Entry, Sizeof(TlxFonRec));
  with Entry do begin
   clrscr;
   writeln('Entry #',Index);
   writeln('Name: ':30,Copy(BbsName,1,sizeof(BbsName)));
   writeln('Phone: ':30,Copy(Phone,1,sizeOf(Phone)));
   writeln('Baud: ':30, BaudRate[Baud]);
   writeln('Parity: ':30,ParityType[Parity]);
   writeln('DataBits: ':30, DataBits);
   writeln('StopBits: ':30, StopBits);
   writeln('Script: ':30,Copy(Script,1,sizeof(Script)));
   writeln('LastCall: ':30,
    Copy(LastCall,1,2) ,'.',
    Copy(LastCall,3,2), '.',
    Copy(LastCall,5,2), '');
   writeln('TotalCalls: ':30,TotalCalls);
   writeln('Terminal: ':30,TerminalType[Terminal]);
   writeln('Protocol: ':30, Protocol);
   writeln('Local Echo: ':30,Echo(BitField));
   writeln('Add Line Feed: ':30,LineFeeds(BitField));
   writeln('Strip HighBits: ':30,StripHBit(BitField));
   writeln('Received BS is Destructive: ':30,RecvBS(BitField));
   writeln('BackSpace Sends: ':30,SendBS(BitField));
   writeln('Unknown B_85h: ':30,B_85h);
   writeln('Unknown B_86h: ':30,B_86h);
   writeln('DialPrefix: ':30,DialPrefix);
   writeln('Password: ':30,Copy(Password,1,sizeof(Password)));
  end;
  writeln;
  writeln('Press any key to continue or <ESC> to terminate...');
  writeln;
  while keypressed do readkey;
  while not keypressed do;
  Ch := readkey;
  if Ch=#27 then
   { Force Exit if <ESC> is pressed by forcing EOF }
   Seek(TlxFon, filesize(TlxFon));
  while keypressed do readkey;
  Inc(Index);
 end;
 close(TlxFon);
end.
