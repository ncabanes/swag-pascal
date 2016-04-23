{
MICHAEL NICOLAI

> I need to extract the foreground color (black) and the background color
> (cyan) and insert them into vars for another procedure, that calls a
> picklist with Fg,Bg attributes. I can't change the way the procedure/
> function works, so I need to feed it =my= colors in =its= format.
>

Do you know the format of the attribute-byte? If not, here it is:

 Bit  7 6 5 4 3 2 1 0
      B b b b I f f f

B   - 0 do not blink
      1 character is blinking

bbb - backgroundcolor (3 Bit, giving you a total of 8 different values.)

I   - 0 foregroundcolor is not intensified
      1 foregroundcolor is intensified

fff - foregroundcolor (3 Bit + I, giving you a total of 16 different values.)


If you now want to extract the fore- or backgroundcolor you can easily do
that by performing an AND with either 70h, 0Fh or 07h.

The operator AND (if you don't know it):

   AND  a b | x      a & b = x   (or in Pascal: x := a and b;
       ---------
        0 0 | 0
        0 1 | 0
        1 0 | 0
        1 1 | 1

As you see, only when b is set to 1, the value in a is "getting through".

For example: a = 1011000111010111, b = 0001011011110110
then

                   1011000111010111
                 & 0001011011110110
                --------------------
                   0001000011010110

When you look at it for a while you will see that, only where there is a 1
in the lower number, the value in the upper number is represented in the
result. Hence, you can use the AND operator to mask a portion of a number.

Now, let's get back to your colors: You mentioned 48 or NORM.
48 decimal equals to 00110000b. That is 'Not Blink', 'Color 3 for
Background', 'Color 0 for Foreground' and 'Foregroundcolor not intensified'.

What do you get, if you perform NORM & 70h? Let's see:

          NORM   00110000
        &  70h   01110000
      ---------------------
                 00110000      (= Backgroundcolor or Bg)

Not much you think, hm? Ok, but that has to do with the initial number NORM.
You will see "the light" as we proceed. :-)

Now, let us perform NORM & 0Fh:

          NORM   00110000
        &  0Fh   00001111
      ---------------------
                 00000000      (= Foregroundcolor WITH I)

and NORM & 07h:

          NORM   00110000
        &  07h   00000111
      ---------------------
                 00000000      (= Foregroundcolor WITHOUT I)


Hm, somewhat NORM was a bad choice as an example. But if you try it with
other values you will see how easy it is to "get a few bits out of a byte"!
}

