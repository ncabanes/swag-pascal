> Also does anyone know how to import TheDraw Files into a prg and get
> them to show properly. Thanks.

Save the Files into Bin Format, then run BinOBJ on them. When you select a
public name, remember that this will be the Procedure's name.

After that Write:

Procedure <public name>; External; {$L <objname>}

Walkthrough example:


Saved File: Welcom.Bin

BinOBJ WELCOME WELCOME WELCOMESCREEN

In pascal:

Procedure WelcomeScreen; External; {$L WELCOME.OBJ}

In order to display, dump the Procedure to b800:0 -

Move(@WelcomeScreen,Mem[$B800:0],4000];

4000 is the size For 80x25. The size is x*y*2.

