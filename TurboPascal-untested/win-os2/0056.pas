{
A while back, I posted a question in this conference asking how to
position the caret within an edit control using BP7 and OWL.  I didn't
get a good answer back, but have since figured out the answer.  It took
me a while because of the poor Borland documentation.  I thought I'd
post it here to save others some grief.  SWAG Librarians: Please
consider adding this message to the Win-OS2 library.  It turns out to be
extremely simply.  To position the caret within an edit control, simply
call the SetSelection method, giving it a starting position and an
ending position equal to your desired caret position.  For example, if
you have an edit control object named EC, and want to position the caret
at column 5 (numbering starts at 0), simply

  EC^.SetSelection(5, 5);
