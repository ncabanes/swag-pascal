
Using the following works fine :

var
  dummy : integer;

To turn Ctrl-Alt-Del and Alt-Tab off :
SystemParametersInfo( SPI_SCREENSAVERRUNNING, 1, @dummy, 0);

And to turn it back on:
SystemParametersInfo( SPI_SCREENSAVERRUNNING, 0, @dummy, 0);
