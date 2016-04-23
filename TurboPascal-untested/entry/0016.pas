{
Well, this code outlines your problem and it's solution. I assume
you have a single string input procedure. However, why don't you just
position several strings on the screen? The techinique I've outlined
is legit, but a little cumbersome:
(in two messages}
{Regarding your request for a form input technique, I do not know
of a library that handles this, although there probably is one.
Such an object (in the loose sense of the word) could be written in
Turbo Pascal, given a string input handler that you have the source
to so you could modify the exit keys.
   Imagine a procedure getstring that sets single string input that
returns the string when Enter or Tab is pressed, sets a list to "commit"
when enter is pressed as well, and sets a list to "cancel" when escape
is
pressed. Now you can set up a global record structure and skeleton
for form input like so}
program formit;
uses crt;
       type
       single_string=record
           startx,starty:byte; {start coordinates of each caption}
           caption:string; {the caption for the string}
           str:string; {the single string you are getting}
           max_permitted:byte; {maximum length of field}
           end;

       {an array storing the strings in the forms and their place
       on the screen}
       form_array_type=array[1..30] of single_string;

       {exit status for each string entered}
       exitlist=(nocode,tabstop,cancel,commit);

       var
       form_array:form_array_type; {our form with it's strings}
       no_strings_in_form:byte; {how many active strings in form}
       exitcode:exitlist;
       x:byte;
            Procedure getstring(var input_string:string;max_permitted:
            byte;var exitcode:
                                   exitlist);
                Begin
                {single string input procedure}
                {doen't care about the form structure}

                End;
        {SUB PROCEDURE SHOW_FORM}
         procedure show_form(form_array:form_array_type;
              no_strings_in_form:byte);
            var
            x:byte;
            begin
            for x:=1 to no_strings_in_form do
                begin
                gotoxy(form_array[x].startx,form_array[x].starty);
                write(form_array[x].caption);
                end;
            end;
        {SUB PROCEDURE GET_FORM}

            Procedure Get_form(var form_array:form_array_type;
                  no_items:byte; var exitcode:exitlist);
               var
                 form_array_index:byte;
                 current_string:string;
                 max_permitted:byte;
                 {SUB} procedure get_first_tab; {find top left string}
                      {THESE SCAN PROCEDURES MAY SEEM A LITTLE OBSCURE,
                      THEY ARE DESIGNED TO FIND THE NEXT STRING
                      AND NEED TO BE DEBUGGED}
                      var
                      x:byte;
                      lastx,lasty:byte;
                      begin
                      form_array_index:=1;
                      lastx:=form_array[1].startx;
                      lasty:=form_array[1].starty;
                      for x:=2 to no_items do
                          if (form_array[x].starty<=lasty) and
                             (form_array[x].startx<=lastx) then
                             begin
                             lasty:=form_array[x].starty;
                             lastx:=form_array[x].startx;
                             form_array_index:=x;
                             end;
                      end;

               {SUB}  procedure get_next_tab;
                      var
                      found:boolean;
                      x,lastx,lasty:byte;
                      last_form_array_index:byte;
                      begin
                      found:=false;
                      last_form_array_index:=form_array_index;
                      lastx:=200;
                      lasty:=200; {force values}
                      for x:=1 to no_items do
                          if
                          (x<>last_form_array_index) and
                          (form_array[x].starty<=lasty)
                          and
                          (form_array[x].startx<=lastx)
                          and
                          (form_array[x].starty>=
                            form_array[last_form_array_index].starty)
                            and
                          (form_array[x].startx>=
                            form_array[last_form_array_index].startx)
                             then
                                begin
                                  form_array_index:=x;
                                  lasty:=form_array[form_array_index]
                                  .starty;
                                  lastx:=form_array[form_array_index].
                                  startx;
                                  found:=true;
                                end;
                      if not found then
                         get_first_tab;
                      end;
               Begin
               {1. ? find the top left by
                    scanning the startx, starty of form_array}
               get_first_tab;
               REPEAT

                 {2. Now write the string and get the new string}
                 gotoxy(form_array[form_array_index].startx,
                        form_array[form_array_index].starty);
                 write(form_array[form_array_index].caption,
                       form_array[form_array_index].str);
                 gotoxy(form_array[form_array_index].startx+
                 length(form_array[form_array_index].caption),
                        form_array[form_array_index].starty);

                 current_string:=form_array[form_array_index].str;
                 max_permitted:=form_array[form_array_index].
                      max_permitted;
                 exitcode:=nocode;
                 {3. } Getstring(current_string,max_permitted,exitcode);

                 form_array[form_array_index].str:=current_string;

                 {4. ? find the next placed
                      string to tab to by scanning the startx,
                      starty of form array}
                 if exitcode = tabstop then
                      begin
                      {? depends on x/y order in array};
                      get_next_tab;
                      end;

                UNTIL exitcode in [cancel,commit];
                End; {get_form}

       Begin {Calling procedure}
       {initialize array only has to be done once for the form
       within scope}
       no_strings_in_form:=5;
       form_array[1].startx:=1;
       form_array[1].starty:=3;
       form_array[1].caption:='Name ';
       form_array[1].str:='';
       form_array[1].max_permitted:=20;
       form_array[2].startx:=1;
       form_array[2].starty:=4;
       form_array[2].caption:='Address ';
       form_array[2].str:='';
       form_array[2].max_permitted:=60;
       {ETCETERA}
       {care must be taken not to overlap captions and strings}

       {the array is passed to the form input handler}
       clrscr;
       show_form(form_array,no_strings_in_form);
       Get_form(form_array,no_strings_in_form,exitcode);

       {the new values of the strings are returned in
       the array form_array, in each .str field}
       End.
