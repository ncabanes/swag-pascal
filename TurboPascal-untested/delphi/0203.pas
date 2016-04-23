
I notices that the Delphi FAQ has not been updated in over a year.  Since much 
of the information needed to write Delphi components is undocumented I thought 
that maybe there should be a component writing FAQ.

I have been going through some of my source code to get some of the tricks 
that I have had to use in writing components.  I am going through my mail to 
see what tricks people have sent me and I will attempt to give credit to those 
who have mailed me information.

Right now this document is short but hopefully it will grow over time.  Some 
of the information enclose has never been published.  If you have 
something to contribute or suggestions then mail them to me.

So hear goes......


The Unofficial Delphi Component Writing FAQ

Maintainer:     John M. Miano   miano@worldnet.att.net
Version:        1
Last Updated:   30-Aug-96

------------------------------------------------------------------------
Table of Contents

Section 1 - Introduction
1.1. What is the purpose of this document?

Section 2 - IDE 
2.1. How can I locate problems the result when my component is used in the 
IDE?
2.2. How do I view assembly langugage the Delphi Generates?
2.3. I can create my control at run time but it crashes at design time.  What 
is wrong?
2.4. How can I make my control work only in design mode?

Section 3 - Using other components within a component
3.1. How can I add a scroll bar component to my component and have it work at
in design mode?
3.2. How do I create a Windows '95-style scroll bar?

Section 4 - Bound Controls
4.1. Where is the documentation for the TDataLink class?

Section 5 - VCL
5.1. How can I step through the VCL source while debugging

Section 6 - Other Sources of Information
6.1. Are there any books one how to write Delphi components?

Section 7 - Persistant Objects
7.1. How can I save a complex object containing child objects to the .DFM 
file.

------------------------------------------------------------------------
Section 1 - Introductions

1.1. What is the purpose of this document?

The purpose of this document is to answer common or undocumented questions
related to writing Delphi components.  This information is provided as is.  
There are no guarentee as to its correctness.  If you find error or ommissions 
sent them to the author.

This document is rather short at the moment but hopefully it will grow over 
time.

------------------------------------------------------------------------
Section 2 - IDE Problems

2.1. How can I locate problems the result when my component is used in the 
IDE?

The only solution to locating problems I have found it to:

1. In Delphi go to Tools/Options then go to the "Library" page.
Check the "Compile With Debug Info" box.
2. Rebuild the library.
3. Run Delphi from within Turbo Debugger.

If you get a GPF you can use view the stack and get some idea where the 
problem is occuring.

2.2. How do I view assembly langugage the Delphi Generates?

From Glen Boyd

Borland/Delphi/2.0/Debugging add a string value called EnableCPU and set
its string value to 1.  This add the CPU window to the view menu.  The CPU 
window is
active at run time for stepping through and stuff like that.

2.3. I can create my control at run time but it crashes at design time.  What 
is wrong?

1. You component must descent from TComponent

2. Your constructory and destructor declarations must look like:

Constructor Create (AOwner : TComponent) ; Override ;
Destructor Destroy ; Override ;

3  You will get an Access Violation/GPF if you component has any published 
properties that do not have a property editor defined.  These include array 
properties and properties of types you create. 

How do I make a component work only in design mode?

The trick is to use the Register function.  This is only called in design 
mode.  You can
use it to set a flag that your constructors can check.

2.4. How can I make my control work only in design mode?

The Register procedure is only called in design mode.  You can define a flag 
in your module and have your register procedure set that flag.  If that flag 
is clear in your constructor then you are not in design mode.

------------------------------------------------------------------------
Section 3 - Using other components within a component

3.1. How can I add a scroll bar component to my component and have it work at 
in design mode?

You need to define your own scroll bar class that intercepts the 
CM_DESIGNHITTEST message.

TMyScrollBar = class (TScrollBar)
      Procedure CMDesignHitTest (var Message : TCMDesignHitTest) ; Message 
CM_DESIGNHITTEST ;
    End ;

Procedure TMyScrollBar.CMDesignHitTest (var Message : TCMDesignHitTest) ;
  Begin
  Message.Result := 1 ;
  End ;

When your component creates one of these scroll bars it needs to use

TMyScrollBar.Create (Nil) 

rather then

TMyScrollBar.Create (Self)

otherwise the scroll bar will display sizing handles when it is click.   This 
means you need to be sure to explicitly free the scroll bar in your
component's destructor.

3.2 How do I create a Windows '95-style scroll bar?

You need to set the page size for the scroll bar.   The following code
sequence
illustrates this:

Procedure SetPageSize (ScrollBar : TScrollBar ; PageSize : Integer) ;
  Var
    ScrollInfo : TScrollInfo ;
  Begin
  ScrollInfo.cbSize := Sizeof (ScrollInfo) ;
  ScrollInfo.fMask := SIF_PAGE ;
  ScrollInfo.nPage := PageSize ;   
  SetScrollInfo (ScrollBar.Handle, SB_CTL, ScrollInfo, True) ;
  End ;

To retrieve the page size use:

Function GetpageSize (ScrollBar : TScrollBar) ;
  Var
    ScrollInfo : TScrollInfo ;
  Begin
  If HandleAllocated Then
    Begin
    ScrollInfo.cbSize := Sizeof (ScrollInfo) ;
    ScrollInfo.fMask := SIF_PAGE ;
    GetScrollInfo (ScrollBar.Handle, SB_CTL, ScrollInfo) ;
    Result := ScrollInfo.nPage ;
    End ;

------------------------------------------------------------------------
Section 4 - Bound Controls

4.1. Where is the documentation for the TDataLink class?

As far as I can tell the only documentation for TDataLink that exists in the 
entire universe is what follows

Properties:
===========

Property:       Active : Boolean (Read Only)
----------------------------------------

Returns true when the data link is connected to an active datasource.
The ActiveChanged method is called to give notification when the state
changes.

Property:       ActiveRecord: (Read/Write)
--------------------------------------

This sets or returns the current record within the TDatalink's buffer window.  
Valid values are
0..BufferCount - 1.  There appear to be no range checks so assigning values 
outside this range produces unpredictable results.

Property:       BufferCount: (Read/Write)
-------------------------------------

The TDataLink maintains a window of records into the dataset  This property is
the size of this window and determines the maximum number of row that can be 
view simultaneously.  For most controls you would use a BufferCount of one.  
For controls such as a data grid this value is the number of visible rows.

Property:       DataSet: TDataSet (Read)
------------------------------------

The dataset the TDataLink is attached to.  This is a shortcut to 
DataSource.DataSet.

Property:       DataSource: TDataSource (Read/Write)
------------------------------------------------

Sets or returns data source control the TDataLink is attached to.

Property:       DataSourceFixed: Boolean (Read/WRite)
-------------------------------------------------

This property is used to prevent the data source for the TDataLink from being
changed.  If this property is set to Trye then assigning a value to the 
DataSource property will result in an exception.

Property:       Editing: Boolean (Read Only)
----------------------------------------

Returns true if the datalink is in edit mode.

Property:       ReadOnly: Boolean (read/Write)
------------------------------------------

This property determines if the TDataLink is read only.  It does not appear to
affect the attached datalink
or dataset.  If this property is set to True the datalink will not go into 
edit mode.

Property:       RecordCount: Integer (Read)
---------------------------------------

The property returns the approximate number of records in the attached 
dataset.

Methods:
========

function Edit: Boolean;
-----------------------

Puts the TDatalink's attached dataset into edit mode.

Return Value:
        True => Success
        False => Failure

procedure UpdateRecord;
-----------------------

It appears that this is a function that is intended to be called by other
parts of the data base interface and should not be called directly.  All it
does is set a flag and call UpdateData (described below).


Virtual Methods
===============

The mechanism for having the TDataLink object communicate with a component is 
to override these procedures.

procedure ActiveChanged
------------------------

This procedure is called whenever the datasource the TDataLink is attached to 
becomes active or
inactive.  Use the Active property to determine whether or not the link is 
active.

procedure CheckBrowseMode
-------------------------

This method appears to get called before any changes take place to the
database.

procedure DataSetChanged;
-------------------------

This procedure gets called when the following events occur:

   o  Moving to the start of the dataset
   o Moving to the end of the dataset
   o Inserting or Appending to the dataset
   o Deleting a record from the dataset
   o Canceling the editing of a record
   o Updating a record

The non-overrident action for this procedure is to call
        RecordChanged (Nil)

procedure DataSetScrolled(Distance: Integer)
--------------------------------------------

This procedure is called whenever the current record in the dataset changes.  
The Distance parameter tells how far the buffer window into the dataset was 
scrolled (This seems to always be in the range -1, 0, 1).

Use the ActiveRecord to determine which record within the buffer window is the 
current one.

It is not possible to force a scroll of the buffer window.

procedure FocusControl(Field: TFieldRef)
----------------------------------------

This appears to get called as a result of Field.FocusControl.

procedure EditingChanged
-------------------------

This procedure is called when the editing state of the TDataLink changes.  Use 
the Editing property to determine if the TDataLink is in edit mode or not.

procedure LayoutChanged
-----------------------

This procedure is called when the layout of the attached dataset changes (e.g. 
column added) .

procedure RecordChanged(Field: TField)
--------------------------------------

This procedure gets called when:

   o The current record is edited
   o The record's text has changed

If the Field parameter is non-nil then the change occured to the specified 
field.

procedure UpdateData
--------------------

This procedure is called immediately before a record is updated in the 
database.  You can call the Abort procedure to prevent the record from being 
updated.


------------------------------------------------------------------------
Section 5 - VCL
5.1. How can I step through the VCL source while debugging

Copy the VCL source modules you are interested in stepping through to your 
project directory then rebuild the VCL library.  You will then be able to step 
through the VCL source modules.

------------------------------------------------------------------------
Section 6 - Other Sources of Information

6.1. Are there any books one how to write Delphi components?

I have seen a couple out there but the only one I can recommend is

"Developing Delphi Components" by Ray Konopka

------------------------------------------------------------------------
Section 7 - Persistant Objects

7.1. How can I save a complex object containing child objects to the .DFM 
file.

I have tried all sorts of schemes using DefineProperties and WriteComponents 
and they all failed to work. As far as I can the only way to do this is to use 
Delphi's default mechanism to store your child objects.  

A sequence that does work for saving to a stream is:

1. Make all of the classes whose objects you want to save descent from 
TComponent.
2. Make all of the values you want to save published.
3. Within your Register procedure add a call to RegisterComponents containing 
all of the classes you wish to store.
4. Each class that owns child classes needs to overload the procedure 
GetChildren.  Within this procedure is needs to call the procedure passed as 
an argument for each child to be stored.

Getting the objects out of the stream is a little trickier.  Your parent 
object may need to overload the GetChildOwner and GetChildParent functions.  
Otherwise Delphi will try to make the child owned by the form.


------------------------------------------------------------------------
Copyright 1996 - John Miano

Contributers

Glen Boyd
