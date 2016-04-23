{
From: omipd@aztec.co.za (Ahmed Bhamjee)

This is the best way to do bulk processing in Windows. When the window is
created, you set a timer for PROCESSDELAY milliseconds.
}
  PROCEDURE caProcessFile.SetupWindow;
  BEGIN
    INHERITED SetupWindow;
    fCurrent := 0;
    SetTimer(HWindow,tm_ProcessRecord,PROCESSDELAY,NIL);
  END;
{
When the timer message arrives, post a user message to the same window do
perform the required task (eg stepping through a database)
}
  PROCEDURE caProcessFile.WMTimer(VAR Msg:TMessage);
  BEGIN
    KillTimer(HWindow,tm_ProcessRecord);
    PostMessage(HWindow,um_ProcessRecord,0,0);
  END;
{
When the message arrives, decide firstly how many records (iterations) you
wish to perform before releasing "time" to Windows.
}
  PROCEDURE caProcessFile.ProcessRecord(VAR Msg:TMessage);
  BEGIN
    SetExit(FALSE);
    WHILE NOT fpoDatabase^.EOF DO
      BEGIN
        fErrorCode := 0;
        DoSomething;
        IF fErrorCode > 0 THEN
          BEGIN
            CloseYourSelf(fErrorCode);
            EXIT;
          END;
        fpoDatabase^.Skip(1);
        INC(fCurrent);
{
BLOCKSIZE is the number of iterations.
}
        IF (fCurrent MOD BLOCKSIZE)=0 THEN
         BEGIN
           SetExit(TRUE);
{
Set a timer back to this method.
}
           SetTimer(HWindow,tm_ProcessRecord,PROCESSDELAY,NIL);
           EXIT;
         END;
      END;
    EndProcessing;
  END;

  PROCEDURE caProcessFile.EndProcessing;
  BEGIN
    KillTimer(HWindow,tm_ProcessRecord);
    CloseYourSelf;
  END;

