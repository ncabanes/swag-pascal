
Here is something I picked up off Compuserve that should help.  I
have a zip that contains examples of several other controls besides 
the edit.  If anyone would like a copy of the zip, let me know and I 
will send it to you.


Using the <Enter> key like a <Tab> key with Delphi Controls
===========================================================

The example code supplied here demonstrates how to trap the 
<Enter> key and the cursor keys to provide better data entry
processing.

The trick is to overide the Keypress and KeyDown events so
that they process the keys the way you want. In the examples
supplied I have used the <Enter> key to move to the next 
control (like the <Tab> key) and the cursor Up and Down keys
to move to the previous and next controls respectively.

The Edit and EBEdit use the cursor keys as stated above, but
the Combobox and the Listbox use Shift-Up and Shift-Down 
instead so as not to interfere with existing functionality.

The Grid control uses the <Enter> key to move between fields,
however it will not move from the last field of the last row.
It is very easy to make it exit the grid at this point if you
need to.

The method used to move to the next/previous control is the 
Windows API call SendMessage which is used to dispatch a 
WM_NEXTDLGCTL to the form the controls are children to. 
Delphi provides a function called GetParentForm to get the 
handle of the parent form of the control.

These simple extensions can be expanded to respond to almost
any keyboard event, and I think using this method is less 
trouble than trapping keys in the forms OnKey events (using
keypreview:=true).

Feel free to use the code as you wish, but if you discover 
something new please let me in on it!


Simon Callcott

CIS: 100574,1034

{
  Edit control that reponds as if the <Tab> key has been pressed when an
  <Enter> key is pressed, moving to the next control.
  Very simple extension to the KeyPress event, this technique should work
  with TDBedit as well, Useful for data entry type apps.
  Less trouble than using the Keypreview function of the form to do the same
  thing.

  Please Use Freely.

  Simon Callcott  CIS: 100574, 1034
}


unit Entedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TEnterEdit = class(TEdit)
  private

  protected

    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

  public

  published

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TEnterEdit]);
end;

procedure TEnterEdit.KeyPress(var Key: Char);
var
   MYForm: TForm;
begin

   if Key = #13 then
   begin
       MYForm := GetParentForm( Self );
       if not (MYForm = nil ) then
           SendMessage(MYForm.Handle, WM_NEXTDLGCTL, 0, 0);
       Key := #0;
   end;

   if Key <> #0 then inherited KeyPress(Key);

end;

procedure TEnterEdit.KeyDown(var Key: Word; Shift: TShiftState);
var
   MYForm: TForm;
   CtlDir: Word;
begin

   if (Key = VK_UP) or (Key = VK_DOWN) then
   begin
       MYForm := GetParentForm( Self );
       if Key = VK_UP then CtlDir := 1
       else CtlDir :=0;
       if not (MYForm = nil ) then
           SendMessage(MYForm.Handle, WM_NEXTDLGCTL, CtlDir, 0);
   end
   else inherited KeyDown(Key, Shift);

end;

end.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

Q.  "Is there a way to use the return key for data entry, instead of tab or the
    mouse?"

A.  Use this code for an Edit's OnKeyPress event.

    procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
    begin
      If Key = #13 Then
      Begin
        SelectNext(Sender as tWinControl, True, True );
        Key := #0;
      end;
    end;

    This causes Enter to behave like tab.  Now, select all controls on the form
    you'd like to exhibit this behavior (not Buttons) and go to the Object
    Inspector and set their OnKeyPress handler to EditKeyPress.  Now, each
    control you selected will process Enter as Tab.  If you'd like to handle
    this at the form (as opposed to control) level, reset all the controls
    OnKeyPress properties to blank, and set the _form_'s OnKeyPress property to
    EditKeyPress.  Then, change Sender to ActiveControl and set the form's
    KeyPreview property to true:

    procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
    begin
      If Key = #13 Then
      begin
        SelectNext(ActiveControl as tWinControl, True, True );
        Key := #0;
      end;
    end;

    This will cause each control on the form (that can) to process Enter as Tab.
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
