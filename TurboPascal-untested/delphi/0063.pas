
>>Can someone describe how to activate the horizontal scrollbar in a
>>listbox. I need to do this programatically.

try this:

  sendmessage(ListBox.Handle, LB_SetHorizontalExtent, PixelWidth , 0);
