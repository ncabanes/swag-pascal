
Someone posted a message requesting information on how to use Delphi for 
a screen saver. 

a) In the project file (*.dpr) add '{$D SCRNSAVE <saver name>} after the
uses clause.

b) On the main form, turn off the border and icon controls. In the 
activate method set the form left and top to 0, and set the Windowstate 
to wsMaximize.

c) In the form create method, set the application.OnMessage to a method 
that controls the deactivation of the screen saver. Set the 
application.OnIdle method to whatever display method for the saver.

d) In the form create method the command line should be tested for /c and 
/s. These are the command line parameters windows uses to define whether 
the screensaver should run or configure. (/c is for configuration)

e) Compile the program, and rename the .exe to .scr. Move it to the
windows directory, and it should show up in the control panel.

