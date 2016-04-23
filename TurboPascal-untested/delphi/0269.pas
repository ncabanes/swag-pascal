--------------------------------------------------------------------------------
As you know, every line of code you write has to eventually translate
into machine code in order for your computer to understand. If you're
interested in seeing the assembly language (easier to understand version
of machine code) equelant of what you write while debugging (for example) ..

(a) Exit Delphi
(b) Run "Registry Editor" (run regedit.exe or regedt32.exe)
(c) Select following registry key:

HKEY_CURRENT_USER\Software\
Borland\Delphi\2.0\Debugging


(d) Add an string item named "EnableCPU" and set its value to "1" (without the
quotes)
(e) Exit Registry Editor
(f) Restart Delphi and select "View | CPU"
Now when you debug your program, you'll see the assembly instructions in
the new "DiassemblyView" window.
