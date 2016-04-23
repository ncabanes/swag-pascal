
Take a look at TStream/TFileStream.  There is a specific pair of methods
called WriteComponent and ReadComponent that will do what you need.
However, it may not always work exactly as expected.

WriteComponent will take a component as a parameter and will write
that component and all components that it owns to a stream, according
to the documentation.  However, it will not actually write all of
its owned components unless it is a TWinControl descendant (or a
component type that overrides the WriteComponents method).

To store a form and all of the components on it, you would do something
like:

procedure SaveForm(form : TForm; filename : string);
var
  fstream : TFileStream;
begin
  if form <> nil then begin
    fstream := TFileStream.Create(filename, fmCreate);
    try
      fstream.WriteComponent(form);
    finally
      fstream.Free;
    end;
  end;
end;

You could then read it back in with the following:

function LoadForm(filename : string) : TForm;
var
  fstream : TFileStream;
  cmpnt   : TComponent;
begin
  Result  := nil;
  fstream := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
  try
    cmpnt := fstream.ReadComponent(nil);   {read component from stream}
    if cmpnt <> nil then begin             {if successfully read, ... }
      if cmpnt is TForm then begin         {check that it is a form   }
        Result := cmpnt;                   {if so, return it          }
        Application.InsertComponent(Result); {and make App owner of it}
      end else                             {if not what was expected  }
        cmpnt.Free;                        {free it and return nil    }
    end;
  finally
    fstream.Free;
  end;
end;

One thing you should watch out for, however, is that this method writes
and reads ALL of the components on the form, even those that were added
during design time.  This can be problematic when you try to read the
form back in.  The first item read in will be the form itself, which
will be created according to its declaration, which will include all
of the controls added at design time.  Then, when it begins loading
in the owned controls from the stream, it will run into name conflicts
when it tries to create those controls that were design-time additions
to the form since they already exist when the form is created.

One possible way around this is to limit exactly which components
are saved to the stream.  For example, something like this:

        for i := 0 to form.ComponentCount - 1 do
          fstream.WriteComponent(form.Components[i]);

This will store one component after another to the stream.  You could
then read it back with something like:

      while not (fstream.Position = fstream.Size) do begin
        cmpnt := fstream.ReadComponent(nil);
        if cmpnt <> nil then begin
          form.InsertComponent(cmpnt);
          if cmpnt is TControl then
            TControl(cmpnt).Parent := form;
        end;
      end;

However, watch out when you use this.  It is not compatible with some
components.  For example, when I tried to use this method to load in
a TMemo I had saved that contained some text, I received a 'Control
has no parent' exception.  Apparently, attempting to add text to a
TMemo that has no Parent will cause an exception, interrupting the
ReadComponent process.

With a bit more work and code, you may be able to come up with a
more flexible method for loading and saving components.  To do so,
you will need to take a look at the TFiler components, TReader and
TWriter.

Oh!  One other note -- ReadComponent and WriteComponent will only
work with components that have been registered with a call to
RegisterClass or RegisterClasses.  It uses the list of registered
classes as a look-up table to determine how to recreate what is
stored in the stream.  Unforutnately, Delphi does not automatically
register classes.  So, you must already have some idea ahead of
time about what kinds of controls may be read and written.  Make
a call to RegisterClasses once during application start-up --
something like:

  RegisterClasses([TButton, TEdit, TListBox, TMemo, TForm1]);

