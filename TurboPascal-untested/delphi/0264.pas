
--------------------------------------------------------------------------------
Although it's easy enough to catch errors (or exceptions) using "try / catch"
blocks, some applications might benefit from having a global exception
handler. For example, you may want your own global exception handler to
handle "common" errors such as "divide by zero," "out of space," etc.
Thanks to TApplication's "OnException" event -- which occurs when an
unhandled exception occurs in your application, it only takes three
(or so) easy steps get our own exception handler going:1. Declare your
custom exception handler in your form's "public declarations" section.
For example, if your form is named "Form1:"

    { Public declarations }

    { begin new code }
    procedure MyExceptionHandler(
      Sender : TObject; E : Exception );
    { end new code }


2. Define your exception handler in the "implementation" section:

procedure TForm1.MyExceptionHandler(
  Sender : TObject; E : Exception );
var
  wRetVal : Word;
begin
  wRetVal := MessageDlg(
    {
     E.Message contains the
     actual error message
     we'll customize it a bit...
    }
    'ERROR: ' + E.Message,

    mtError,
    mbAbortRetryIgnore,
    0
  );

  case wRetVal of
    mrAbort:
    begin
      { handle "Abort" here... }
    end;


    mrRetry:
    begin
      { handle "Retry" here... }
    end;

    mrIgnore:
    begin
      { handle "Ignore" here... }
    end;

    else
    begin
      {
       handle "other" action here...
       for example, if user choose to
       close the message box without
       clicking on any buttons
      }
    end;
  end;

  {
   you could also call the default
   exception handler:

     Application.ShowException( E );
  }
end;


3. Finally, assign the newly created exception handler to your
application's OnException event.

procedure
  TForm1.FormCreate(Sender: TObject);
begin
  { begin new code }
  Application.OnException :=
    MyExceptionHandler;
  { end new code }
end;


