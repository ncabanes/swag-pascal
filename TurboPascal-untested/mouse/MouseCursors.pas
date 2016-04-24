(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0012.PAS
  Description: Mouse Cursors
  Author: MICHAEL NICOLAI
  Date: 01-27-94  11:56
*)

{
> I whant to draw a new mouse cursor, and the routines that I'm using will
> allow me to do this by passing an array [0..31] of integer; I don't know
> how to draw a cursor thought using this array. Some other routins have
> predifined cursors, but that nubers are out of range.

Here's some explanation:

At the memory location where ES:DX points to, there have to be first 16
words (the screen mask) followed by 16 words (the cursor mask).

The screen mask defines an AND with the background beneath the cursor, and
the cursor mask defines a XOR with the background pixels.

- For each pixel use the following Equations:

 1. expand each mask-bit to the width needed to display one colored-pixel
    in the used video-mode, e.g. if you are using mode $13 (320x200x256)
    each mask-bit is expanded to 8 bits (one byte). If you are using
    640x480x16, each mask-bit is expanded to 4 bits.

 2. Backgrd._pixel AND screen-mask_pixel XOR cursor-mask_pixel => new
    pixel.

Example: (standard arrow-cursor)

            screen-mask       cursor-mask    |   cursor-form
                                             |
          1001111111111111  0000000000000000 | +00+++++++++++++
          1000111111111111  0010000000000000 | +010++++++++++++
          1000011111111111  0011000000000000 | +0110+++++++++++
          1000001111111111  0011100000000000 | +01110++++++++++
          1000000111111111  0011110000000000 | +011110+++++++++
          1000000011111111  0011111000000000 | +0111110++++++++
          1000000001111111  0011111100000000 | +01111110+++++++
          1000000000111111  0011111110000000 | +011111110++++++
          1000000000011111  0011111111000000 | +0111111110+++++
          1000000000001111  0011111000000000 | +01111100000++++
          1000000011111111  0011011000000000 | +0110110++++++++
          1000100001111111  0010001100000000 | +01000110+++++++
          1001100001111111  0000001100000000 | +00++0110+++++++
          1111110000111111  0000000110000000 | ++++++0110++++++
          1111110000111111  0000000110000000 | ++++++0110++++++
          1111111000111111  0000000000000000 | +++++++000++++++
                                             |

As you can easily see:


    screen-mask | cursor-mask | new pixel
   -------------+-------------+-----------
        0       |      0      |  black
        0       |      1      |  white
        1       |      0      |  background visible
        1       |      1      |  background inverted


A quick example for the inverted background:

Lets say we have a 01101101 as a backgroundpixel, ok?

     1.       01101101
          AND 11111111 (expanded) screen-mask-bit
         -----------------------------------------
              01101101 leaving the background-pixel untouched.


     2.       01101101
          XOR 11111111 (expanded) cursor-mask-bit
         -----------------------------------------
              10010010 inverted background pixel

}

