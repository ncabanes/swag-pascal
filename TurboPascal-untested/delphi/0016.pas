
>How can you bring an icon to the front (set focus), without actually
>restoring the mainwindow?

Michael--

  If the form/app is already minimized, this should do what you want:

  ShowWindow(Form1.Handle, SW_MINIMIZED);

  NB: I have not actually tried this, although I see no reason why it
wouldn't work.

