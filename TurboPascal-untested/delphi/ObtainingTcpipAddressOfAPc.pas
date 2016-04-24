(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0245.PAS
  Description: Obtaining TCP/IP address of a PC
  Author: LEONARDO HUMBERTO LIPORATI
  Date: 05-30-97  18:17
*)


>
> I am writing a program which will extract PC information and store it in
> a database.  The program will be run by each PC in my office and will
> return Computername, Username  ...etc..  The program is working fine
> except I am unable to find out what the TCP/IP address of the PC running
> the App.  I am using Delphi1 and the program will be run on both Win3.11
> and Win95 PC's.
>
> Any help would be greatly appreciated.
>
> Also the Ethernet address of the card would be handy as well (if its
> possible to read)
>
> Thanks in advance,
>
> Jason Atkins
> Sydney, Australia
>
> email:  jatkins@awa.com.au

In Delphi 2 and Windows 95 I tested the code below and it works.
Notice that I have included WinSock in the uses clause. Delphi 2 comes with
winsock.dcu but I believe that Delphi 1 does not have it.
Search the Delphi Super Page (http://sunsite.icm.edu.pl/delphi/),
probably there will be useful sockets/TCPIP components that will help you.

Code follows...
-----------------------------------------
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WinSock, StdCtrls;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormShow(Sender: TObject);
type pu_long = ^u_long;
var varTWSAData : TWSAData;
    varPHostEnt : PHostEnt;
    varTInAddr : TInAddr;
    namebuf : Array[0..255] of char;
begin
  If WSAStartup($101,varTWSAData) <> 0 Then
    Edit1.Text := 'WSAStartup error!'
  Else Begin
    gethostname(namebuf,sizeof(namebuf));
    varPHostEnt := gethostbyname(namebuf);
    varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
    Edit1.Text := inet_ntoa(varTInAddr);
  End;
  WSACleanup;
end;

end.

