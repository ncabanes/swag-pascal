(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0220.PAS
  Description: Calling Netscape Navigator
  Author: SWAG SUPPORT TEAM
  Date: 03-04-97  13:18
*)


program Netscape;

uses DDEMan;

procedure GotoURL( sURL : string );
var
dde : TDDEClientConv;
begin
dde   := TDDEClientConv.Create( nil );
with dde do
  begin
     // specify the location of netscape.exe
     ServiceApplication :='c:\ns32\program\netscape.exe';
     // activate the Netscape Navigator
     SetLink( 'Netscape', 'WWW_Activate' );
     RequestData('0xFFFFFFFF');
     // go to the specified URL
     SetLink( 'Netscape', 'WWW_OpenURL' );
     RequestData(sURL+',,0xFFFFFFFF,0x3,,,' );
     // ...
     CloseLink;
  end;
dde.Free;
end;

begin
GotoURL('http://www.whatever.com/' );
end.

