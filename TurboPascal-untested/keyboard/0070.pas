  {========================================================================}
  {                                                                        }
  { If you find these procedures/functions useful, please help support the }
  { SHAREWARE system by sending a small donation ( up to $5 ) to help with }
  { my college education. Reguardless of a donation, use these routines in }
  { good health (and with a clear concious), I hope you find them useful.  }
  {                                                                        }
  {                                                                        }
  { Send Any Replies To:  EUROPA Software                                  }
  {                       314 Pleasant Meadows Dr.                         }
  {                       Gaffney, SC 29340                                }
  {                                                                        }
  { Program: KB_v02                                Last Revised: 11/21/89  }
  {                                                                        }
  { Author: J.E. Clary                                                     }
  {                                                                        }
  { Using ALL of these routines increases the .EXE by only 336 bytes.      }
  {                                                                        }
  { Implementation: Turbo Pascal v.4.0 & v.5.0                             }
  {                                                                        }
  { Purpose:                                                               }
  {                                                                        }
  { This UNIT is to provide direct access to the Keyboard status byte.     }
  { It is intended to use while running under MS-DOS. The unit will not    }
  { function properly, if at all, when running under OS/2. This is because }
  { low-memory access is denied under OS/2 to protect the Operating System.}
  { If you need these functions under OS/2 they are easily accesible by    }
  { calling OS Interrupt 9, which returns status bytes 40:17h and 40:18h   }
  { 'leagally'. The UNIT is written to carry as little excess baggage as   }
  { possible ( only 16 bytes in constants and work variables ) and execute }
  { as fast as possible. This is achieved by directly addressing the key-  }
  { board status byte instead of calling the Operating System.             }
  {                                                                        }
  {=========================   DISCALIMER   ===============================}
  {                                                                        }
  {                                                                        }
  {   These routines are provided AS IS. EUROPA Software, nor any of its   }
  {   employees shall be held liable for any incidental or consequential   }
  {   damage attributed to the use, or inability to use this product.      }
  {                                                                        }
  {                                                                        }
  {========================================================================}

unit KB_v02;

   INTERFACE

   const   Right_Shift     = 0;    { Key_To_Check Constants  }
           Left_Shift      = 1;
           Control_Key     = 2;
           Alt_key         = 3;

           Scroll_Lock_Key = 4;    { Key_To_Set Constants    }
           Number_Lock_Key = 5;
           Caps_Lock_Key   = 6;

           State_Off       = 0;    {  Action Constants       }
           State_On        = 1;
           State_Toggle    = 2;


   function Is_Key_Pressed( Key_To_Check  :  byte )  :  boolean;

   procedure Set_Keyboard_State( Key_To_Set, Action  :  byte );
   procedure Save_Keyboard_Status;
   procedure Restore_Keyboard_Status;
   procedure Clear_Type_Ahead_Buffer;



   IMPLEMENTATION


   var Hold_Keyboard_Status, Or_Mask, And_Mask  :  byte;

       kb_stat   :  byte absolute $0:$417;  { Keyboard Status Byte }
       tail_buf  :  byte absolute $0:$41C;  { Tail of Circular KB Buffer }
       head_buf  :  byte absolute $0:$41A;  { Head of Circular KB Buffer }


   procedure Clear_Type_Ahead_Buffer;

      begin

         tail_buf := head_buf;

      end;



   procedure Save_Keyboard_Status;

      begin

         Hold_Keyboard_Status := kb_stat;

      end;



   procedure Restore_Keyboard_Status;

      begin

         kb_stat := Hold_Keyboard_Status;

      end;



   function Is_Key_Pressed( Key_To_Check  :  byte )  :  boolean;

      begin

         Or_Mask := (1 SHL Key_To_Check);
         Is_Key_Pressed := ((kb_stat AND Or_Mask) = Or_Mask);

      end;



   procedure Set_Keyboard_State(  Key_to_Set, Action  :  byte );

      begin

         Or_Mask  := 1 SHL Key_To_Set;
         And_Mask := (NOT Or_Mask);

         case Action of

              0: kb_stat := kb_stat AND And_Mask;          {  Off   }
              1: kb_stat := kb_stat OR   Or_Mask;          {  On    }

              2: if ( kb_stat AND Or_Mask) = Or_Mask then  { Toggle }
                      kb_stat := (kb_stat AND And_Mask)
                 else kb_stat := (kb_stat  OR  Or_Mask);

             end;

      end;



   begin  { UNIT Initialization Code }

      Hold_Keyboard_Status := 0;

   end.

{ --------------------------  DEMO ----------------------------}

program test_KB;

   { Demonstates the use of the KB_v02 Unit. }

   uses crt, KB_v02;

   const on       = 'Key is Pressed   ';
         off      = 'Key isn''t Pressed';
         EveryMsg = 'Any Key to Force ';
         MidMsg   = ' Lock Key to ';

         lock_keys   :  array[1..3] of byte =

                        ( Number_Lock_Key, Caps_Lock_Key, Scroll_Lock_Key );

         key_states  :  array[1..3] of byte =

                       ( State_On, State_Off, State_Toggle );


         key_names    :  array[1..3] of string = ('Number','Caps','Scroll');
         state_names  :  array[1..3] of string = ('On','Off','Toggle');



   var i,j  :  byte;

   procedure BurnKey;

      var ch  :  char;

      begin

         ch := readkey;
         if ch = #0 then ch := readkey;

      end;

   procedure writeAT( x,y  :  byte;  st  :  string );

      begin

         gotoxy( x,y );
         write( st );

      end;


   begin

      clrscr;
      writeln( 'DEMO of Is_Keypressed Function' );
      writeln;
      writeln( ' Any Normal Key to continue ' );

      writeAT( 10, 10, 'Alt Key Status'  );
      writeAT( 10, 12, 'CTRL Key Status' );
      writeAT( 10, 14, 'Left Shift Status' );
      writeAT( 10, 16, 'Right Shift Status' );


      repeat

          if Is_Key_Pressed( Alt_Key ) then writeAT( 30,10, on )
          else writeAT( 30,10, off );

          if Is_Key_Pressed( Control_Key ) then writeAT( 30,12, on )
          else writeAT( 30,12, off );

          if Is_Key_Pressed( Left_Shift ) then writeAT( 30,14, on )
          else writeAT( 30,14, off );

          if Is_Key_Pressed( Right_Shift ) then writeAT( 30,16, on )
          else writeAT( 30,16, off );

          delay(100);

      until keypressed;

      clrscr;

      burnkey;
      writeln('Keyboard Status Saved' );
      writeln;

      Save_Keyboard_Status;

      for i := 1 to 3 do begin

          for j := 1 to 3 do begin

              writeln( EveryMsg, key_names[i], MidMsg, state_names[j] );
              burnkey;
              Set_Keyboard_State( Lock_Keys[i], key_States[j] );

          end;

          writeln;

      end;

      writeln;
      writeln( 'End of Demo.' );
      writeln( 'Any Key to Restore Original Lock Status and Exit.' );

      BurnKey;

      Restore_Keyboard_Status;

   end.

