
 Question:  How do I make a simple method to rotate between forms?
            How do I add my own return results to a ShowModal form?
            How do I instantiate forms at runtime?

 Answer:  The method required is quite simple to implement.  For my
    example I used 3 forms, the Mainform, Form1, and Form2.  I
    placed a button on the Mainform that will bring up Form1, then
    from that form you could rotate through any number of forms via
    buttons placed on those forms.  For my example, only Form1 and
    Form2 can be flipped between.

    step 1. Places these two lines in the interface section of this
       Form, which will be refered to as the main form

       const
         mrNext = 100;
         mrPrevious = 101;

    step 2. On the main form add a button and add the following block
        of code into it.

       var
         MyForm: TForm;
         R, CurForm: Integer;
       begin
          R := 0;
          CurForm := 1;
          while R <> mrCancel do begin
            Case CurForm of
              1: MyForm := TForm1.Create(Application);
              2: MyForm := TForm2.Create(Application);
            end;
            try
              R := MyForm.ShowModal;
            finally
              MyForm.Free;
            end;
            case R of
              MrNext : Inc(CurForm);
              MrPrevious : Dec(CurForm);
            end;
                // these 2 lines will make sure we don't go out of bounds
            if CurForm < 1 then CurForm := 2
            else if CurForm > 2 then CurForm := 1;
           end; // while
         end;

    step 3. Add forms 1 and 2 (and any others you are going to have)
        to the uses statement for the MainForm.

    step 4. On Form1 and Form2 add the MainForm to the uses (so they
        can see the constants.

    step 5. On Form1, Form2 and all subsequent forms add 2 TBitBtn's,
        labeled Next and Previous.  In the OnClick Events for these buttons
        add the following line of code.
          If it's a Next Button add :  ModalResult := mrNext;
          If it's a Previous Button add :  ModalResult := mrPrevious;
