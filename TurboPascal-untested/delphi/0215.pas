program iexplor;
uses
   Windows, OLEAuto;


procedure OpenInternetExplorer( sURL : string );
const
csOLEObjName = 'InternetExplorer.Application';
var
IE        : Variant;
WinHanlde : HWnd;
begin
if( VarIsEmpty( IE ) )then
begin
IE := CreateOleObject( csOLEObjName );
IE.Visible := true;
IE.Navigate( sURL );
end else
begin
WinHanlde := FindWIndow( 'IEFrame', nil );
if( 0 <> WinHanlde )then
begin
IE.Navigate( sURL );
SetForegroundWindow( WinHanlde );
end else
begin
// handle error ...
end;
end;
end;

begin
OpenInternetExplorer( 'microsoft.com' );
end.

