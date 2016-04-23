SECTION 10 - Windows Tools

This document contains information that is most often provided
to users of this section.  There is a listing of common
Technical Information Documents that can be downloaded from the
libraries, and a listing of the five most frequently asked
questions and their answers.
                                    
TI1037   Configuring/Using Turbo Debugger for Windows
TI1262   Installation notes regarding Turbo Debugger for Windows
TI1171   Borland problem report form

Q.   "Should I save my Resource Workshop projects as a .RES file
     or a .RC file?"

A.   Since .RC files are ASCII text, it is easier to debug them
     and share them with other programmers, so it is usually best
     to save your project as a .RC file and have it automatically
     create a .RES file for you.  To do this, first create a .RC
     project.  Then go to File|Preferences, and select the check
     box next to "Multi-Save .RES file." Now, every time you save
     your project, a .RES file will be created for you.

Q.   "What  are WinSpector and WinSight?"

A.   WinSpector is a utility that allows you to perform a post-
     mortem inspection of your windows applications that have
     crashed as a result of a General Protection Fault or
     Unrecoverable Application Error.  WinSpector can show you:

          * The call stack.
          * function and procedures names in the call stack (with
            a little help from you).
          * CPU registers.
          * A disassembly of the instructions.
          * Windows information.
     
     WinSight is a utility that gives you information about
     window classes, windows, and messages while an application
     is running.  You can use it to study how any application
     creates classes and windows, and to see how windows send and
     receive messages.

Q.   "Why does my screen get scrambled when I run Turbo Debugger
     for Windows?"

A.   The Turbo Debugger video DLL you are using is probably
     incompatible with your Windows graphics driver.  Download
     TDSVGA.ZIP from library 2, and try one of the different
     video DLLs.

Q.   "I have a rather large application, and it does not seem to
     work correctly in Turbo Debugger for Windows or Turbo
     Profiler for Windows.  What's the problem?"

A.   Turbo Debugger for Windows and Turbo Profiler for Windows do
     have limitations in the size of the files and number of
     symbols they can handle.  If you find you are encountering
     this problem, the best solution is to modularize your code
     into several discreet objects that can be individually
     debugged.

Q.   "I just installed Borland C++ 4.0, and I have TPW 1.5 or BP
      7.0.  Why am I having problems getting the Pascal Turbo
      Debugger for Windows to work correctly?"

A.   There are three main things to check on here:

        1. Make sure \BP\BIN (or \TPW\BIN) is in your PATH
           statement before \BC4\BIN.
        2. Make sure you are loading the version of TDDEBUG.386
           in the [386Enh] section of SYSTEM.INI) that comes with
           Pascal.
        3. Rename the TDW.INI file that came with BC4, so that
           Pascal will create its own new INI file.

     Also, you may wish to download TI1037 from library 2.  This
     has some good information on TDW.

