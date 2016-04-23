From: Lode Deleu <101612.1454@compuserve.com>

> Is it possible to create an array of components? I'm using a LED component for a status display, and I'd like to be able to access it via: 

First of all, you'l need to declare the array:

  LED : array[1..10] of TLed;      (TLed being your led component type)
if you would create the LED components dynamically, you could do this during a loop like this :

  for counter := 1 to 10 do
    begin
       LED[counter]:= TLED.Create;
       LED[counter].top := ...
       LED[counter].Left := ...
       LED[counter].Parent := Mainform;   {or something alike}
    end;
If the components already exist on your form (visually designed), you could simply assign them to the array like this:

  leds := 0;
  for counter := 0 to Form.Componentcount do
    begin
       if (components[counter] is TLED) then
         begin
            inc(leds);
            LED[leds] := TLED(components[counter]);
         end
    end;
This however leaves you with a random array of LED's, I suggest you give each LED a tag in the order they should be in the array, and then fill the array using the tag :

  for counter := 0 to Form.Componentcount do
    begin
       if (components[counter] is TLED) then
         begin
            LED[Component[counter].tag] := TLED(components[counter]);
         end
    end;
if you need a two dimensional array, you'll need to find another trick to store the index, I've used the hint property a number of times to store additional information.

