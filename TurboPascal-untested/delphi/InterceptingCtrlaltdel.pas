(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0377.PAS
  Description: Intercepting Ctrl-Alt-Del
  Author: ALAN VERCAUTEREN
  Date: 01-02-98  07:33
*)


Using the following works fine :

var
  dummy : integer;

To turn Ctrl-Alt-Del and Alt-Tab off :
SystemParametersInfo( SPI_SCREENSAVERRUNNING, 1, @dummy, 0);

And to turn it back on:
SystemParametersInfo( SPI_SCREENSAVERRUNNING, 0, @dummy, 0);

