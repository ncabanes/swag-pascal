(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0104.PAS
  Description: Associate a string with a component
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)

{
Q:  Is there a way to associate a string with each component?

A:  Since the Tag property is a longint, you can type cast it
as a Pointer or PChar.  So, you can basically store a pointer
to a record by using the Tag property.

Note:  You're not going to be able to store the string, or
pointer rather, at design time. This is something you'll have
to do at run time. Take a look at this example:
}
 var
  i: integer;
 begin
   for i := 0 to ComponentCount - 1 do

     if Components[i] is TEdit then
       Components[i].Tag := LongInt(NewStr('Hello '+IntToStr(i)));
 end;

Here, I loop through the components on the form.  If the 
component is a TEdit, I assign a pointer to a string to its Tag 
property.  The NewStr function returns a PString (pointer to a 
string).  A pointer is basically the same as a longint or 
better, occupies the same number of bytes in memory. Therefore, 
you can type cast the return value of NewStr as a LongInt and 
store it in the Tag property of the TEdit component.  Keep in 
mind that this could have been a pointer to an entire record.  
Now I'll use that value:

 var
  i: integer;
 begin
   for i := 0 to ComponentCount - 1 do
     if Components[i] is TEdit then begin
       TEdit(Components[i]).Text := PString(Components[i].Tag)^;
       DisposeStr(PString(Components[i].Tag));
     end;
 end;

Here, again I loop through the components and work on only the 
TEdits.  This time, I extract the value of the component's Tag 
property by typecasting it as a PString (Pointer to a string) 
and assigning that value to the TEdit's Text property. Of 
course, I must dereference it with the caret (^) symbol.  Once 
I do that, I dispose of the string stored in the edit 
component.  Important note: if you store anything in the 
TEdit's Tag property as a pointer, you are responsible for 
disposing of it also.

FYI, Since Delphi objects are really pointers to class 
instances, you can also store objects in the Tag property. As 
long as you remember to Free them.

Three methods spring to mind to use Tags to access strings that 
persist from app to app.

1.  If your strings stay the same forever, create a string
resource in Resource Workshop (or equiv) and use the Tags as 
indexes into your string resource.

2.  Use TIniFile and create a section for your strings, and 
give each string a name with number so that your ini file has a 
section like this:

[strings]
string1=Aristotle
string2=Plato
string3=Well this is Delphi, after all

Then you can fetch them back out this way:

  var s1: string;
  ...
  s1 := IniFile1.ReadString('strings', 'string'+IntToStr(Tag), '');

3.  Put your strings into a file, with each followed by a
carriage return.  Read them into a TStringList.  Then your Tags
become an index into this stringlist:

  StringList1.LoadFromFile('slist.txt');
  ...
  s1 := StringList1[Tag];

Given the way Delphi is set up, I think the inifile method is easiest.

