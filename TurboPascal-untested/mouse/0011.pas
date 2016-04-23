UNIT Mouse;
{*****************************************************************************}
                               INTERFACE
{*****************************************************************************}
USES DOS;

TYPE mouse_cursor_mask = RECORD
                         screen_mask : ARRAY[0..7] OF BYTE;
                         cursor_mask : ARRAY[8..15] OF BYTE;
                         END;

CONST on = TRUE;
CONST off = FALSE;
CONST left = $00;
CONST right = $01;

CONST change_in_cursor_position = $0001;         {call masks for user defined}
CONST left_button_pressed = $0002;               {input mask and swap vectors}
CONST left_button_released = $0004;
CONST right_button_pressed = $0008;
CONST right_button_released = $0010;

CONST alternate_key_pressed = $0001;   {call masks for alternate user handlers}
CONST control_key_pressed = $0002;
CONST shift_button_pressed = $0004;
CONST right_button_up = $0008;
CONST right_button_down = $0010;
CONST left_button_up = $0020;
CONST left_button_down = $0040;
CONST cursor_moved = $0080;

VAR mouse_driver_disabled : BOOLEAN;
VAR number_of_presses, number_of_releases : INTEGER;
VAR number_buttons, x, y : INTEGER;
VAR button_status, horizontal_counts, vertical_counts : INTEGER;
VAR left_mouse_button_pressed, right_mouse_button_pressed,
    left_mouse_button_released, right_mouse_button_released : BOOLEAN;
VAR register : REGISTERS;

PROCEDURE check_button_status;
PROCEDURE disable_mouse_driver (VAR int33h_vector_address : POINTER);
PROCEDURE enable_mouse_driver; INLINE($B8/$20/$00/$CD/$33);
FUNCTION  get_alternate_user_interrupt_vector (call_mask : WORD) : POINTER;
PROCEDURE get_left_button_press_information;
PROCEDURE get_left_button_release_information;
PROCEDURE get_mouse_position;
PROCEDURE get_mouse_sensitivity (VAR horizontal_coordinates_per_pixel,
                                     vertical_coordinates_per_pixel,
                                     double_speed_threshold : WORD);
PROCEDURE get_right_button_press_information;
PROCEDURE get_right_button_release_information;
PROCEDURE light_pen_emulation; INLINE($B8/$0D/$00/$CD/$33);
FUNCTION  mouse_button_pressed : BOOLEAN;
PROCEDURE mouse_cursor_off; INLINE($B8/$02/$00/$CD/$33);
PROCEDURE mouse_cursor_off_area (x1,y1,x2,y2 : INTEGER);
PROCEDURE mouse_cursor_on; INLINE($B8/$01/$00/$CD/$33);
FUNCTION  mouse_exists : BOOLEAN;
FUNCTION  mouse_state_buffer_size : INTEGER;
FUNCTION  mouse_video_page : WORD;
FUNCTION  number_of_buttons : INTEGER;
PROCEDURE relative_number_of_screen_positions_moved (VAR x, y : INTEGER);
          {reported in units of 0.02 inches - approximately 0.5 millimeters}
PROCEDURE reset_mouse_software; INLINE($B8/$21/$00/$CD/$33);
PROCEDURE restore_mouse_driver_state (mouse_state_buffer_segment,
                                      mouse_state_buffer_offset : WORD);
          {use when returning from another program to your program}
PROCEDURE save_mouse_driver_state (mouse_state_buffer_segment,
                                   mouse_state_buffer_offset : WORD);
          {use mouse_state_buffer_size to set up buffer first;
           use when EXEC another program from your program}
PROCEDURE set_alternate_mouse_user_handler (call_mask,
                                            function_offset : INTEGER);
PROCEDURE set_double_speed_threshold (threshold_speed : INTEGER);
PROCEDURE set_graphics_mouse_cursor (hot_spot_x, hot_spot_y : INTEGER;
                                   screen_and_cursor_mask : mouse_cursor_mask);
PROCEDURE set_mouse_physical_movement_ratio (x8_positions_to_move,
                                             y8_positions_to_move : INTEGER);
          {each position corresponds to 1/200th of an inch}
PROCEDURE set_mouse_position (x,y : INTEGER);
PROCEDURE set_mouse_sensitivity (horizontal_coordinates_per_pixel,
                                 vertical_coordinates_per_pixel,
                                 double_speed_threshold : WORD);
PROCEDURE set_mouse_video_page (page_number : WORD);
PROCEDURE set_mouse_x_bounds (minimum_x, maximum_x : WORD);
PROCEDURE set_mouse_y_bounds (minimum_y, maximum_y : WORD);
PROCEDURE set_text_mouse_attribute_cursor (screen_cursor_mask_offset : WORD);
PROCEDURE set_text_mouse_hardware_cursor (top_scan_line,
                                          bottom_scan_line : INTEGER);
PROCEDURE stop_light_pen_emulation; INLINE($B8/$0E/$00/$CD/$33);
PROCEDURE swap_mouse_interrupt_vector (VAR call_mask, mouse_vector_segment,
                                           mouse_vector_offset : WORD);
{*****************************************************************************}
                             IMPLEMENTATION
{*****************************************************************************}
PROCEDURE check_button_status;
   VAR check_left, check_right : WORD;
   BEGIN
      IF button_status AND $0001 = $0001 THEN
         left_mouse_button_pressed := TRUE ELSE
         left_mouse_button_pressed := FALSE;

      IF button_status AND $0002 = $0002 THEN
         right_mouse_button_pressed := TRUE ELSE
         right_mouse_button_pressed := FALSE;
   END;
{*****************************************************************************}
PROCEDURE disable_mouse_driver (VAR int33h_vector_address : POINTER);
   BEGIN
      register.AX := $001F;
      INTR($33,register);
      IF register.AX = $001F THEN
         BEGIN
            mouse_driver_disabled := TRUE;
            int33h_vector_address := PTR(register.ES,register.BX);
         END ELSE mouse_driver_disabled := FALSE;
   END;
{*****************************************************************************}
FUNCTION  get_alternate_user_interrupt_vector (call_mask : WORD) : POINTER;
   BEGIN
      register.AX := $0019;
      register.CX := call_mask;
      INTR($33,register);
      get_alternate_user_interrupt_vector := PTR(register.BX,register.DX);
   END;
{*****************************************************************************}
PROCEDURE get_left_button_press_information;
   BEGIN
      register.BX := $0000;
      register.AX := $0005;
      INTR($33,register);
      number_of_presses := register.BX;
      x := register.CX;
      y := register.DX;
      button_status := register.AX;
      check_button_status;
   END;
{*****************************************************************************}
PROCEDURE get_left_button_release_information;
   BEGIN
      register.BX := $0000;
      register.AX := $0006;
      INTR($33,register);
      number_of_releases := register.BX;
      x := register.CX;
      y := register.DX;
      button_status := register.AX;
      check_button_status;
   END;
{*****************************************************************************}
PROCEDURE get_mouse_position;
   BEGIN
      register.AX := $0003;
      INTR($33,register);
      x := register.CX;
      y := register.DX;
      button_status := register.BX;
      check_button_status;
   END;
{*****************************************************************************}
PROCEDURE get_mouse_sensitivity (VAR horizontal_coordinates_per_pixel,
                                     vertical_coordinates_per_pixel,
                                     double_speed_threshold : WORD);
   BEGIN
      register.AX := $001B;
      register.BX := horizontal_coordinates_per_pixel;
      register.CX := vertical_coordinates_per_pixel;
      register.DX := double_speed_threshold;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE get_right_button_press_information;
   BEGIN
      register.BX := $0001;
      register.AX := $0005;
      INTR($33,register);
      number_of_presses := register.BX;
      x := register.CX;
      y := register.DX;
      button_status := register.AX;
      check_button_status;
   END;
{*****************************************************************************}
PROCEDURE get_right_button_release_information;
   BEGIN
      register.BX := $0001;
      register.AX := $0006;
      INTR($33,register);
      number_of_releases := register.BX;
      x := register.CX;
      y := register.DX;
      button_status := register.AX;
      check_button_status;
   END;
{*****************************************************************************}
FUNCTION mouse_button_pressed : BOOLEAN;
   BEGIN
      register.AX := $0003;
      INTR($33,register);
      button_status := register.BX;
      check_button_status;
   END;
{*****************************************************************************}
PROCEDURE mouse_cursor_off_area (x1,y1,x2,y2 : INTEGER);
   BEGIN
      register.AX := $0010;
      register.CX := x1;
      register.DX := y1;
      register.SI := x2;
      register.DI := y2;
      INTR($33,register);
      mouse_cursor_on;   {may need to remove this statement}
   END;
{*****************************************************************************}
FUNCTION  mouse_exists : BOOLEAN;
   BEGIN
      register.AX := $0021;
      INTR($33,register);
      IF (register.AX = $FFFF) AND (register.BX = $02) THEN
         mouse_exists := TRUE ELSE
         mouse_exists := FALSE;
   END;
{*****************************************************************************}
FUNCTION  mouse_state_buffer_size : INTEGER;
   BEGIN
      register.AX := $15;
      INTR($33,register);
      mouse_state_buffer_size := register.BX;
   END;
{*****************************************************************************}
FUNCTION mouse_video_page : WORD;
   BEGIN
      INLINE($B8/$1E/$00/$CD/$33);
      mouse_video_page := register.BX;
   END;
{*****************************************************************************}
FUNCTION number_of_buttons : INTEGER;
   BEGIN
      register.AX := $0000;
      INTR($33,register);
      number_of_buttons := register.BX;
   END;
{*****************************************************************************}
PROCEDURE relative_number_of_screen_positions_moved (VAR x, y : INTEGER);
   BEGIN
      register.AX := $000B;
      INTR($33,register);
      register.CX := x;
      register.DX := y;
   END;
{*****************************************************************************}
PROCEDURE restore_mouse_driver_state (mouse_state_buffer_segment,
                                      mouse_state_buffer_offset : WORD);
   BEGIN
      register.AX := $17;
      register.ES := mouse_state_buffer_segment;
      register.DX := mouse_state_buffer_offset;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE save_mouse_driver_state (mouse_state_buffer_segment,
                                   mouse_state_buffer_offset : WORD);
   BEGIN
      register.AX := $16;
      register.ES := mouse_state_buffer_segment;
      register.DX := mouse_state_buffer_offset;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_alternate_mouse_user_handler (call_mask,
                                            function_offset : INTEGER);
   BEGIN
      register.AX := $0018;
      register.CX := call_mask;
      register.DX := function_offset;
      INTR($33,register);
      x := register.CX;
      y := register.DX;
      horizontal_counts := register.DI;
      vertical_counts := register.SI;
      button_status := register.BX;
      check_button_status;
   END;
{*****************************************************************************}
PROCEDURE set_mouse_video_page (page_number : WORD);
   BEGIN
      register.AX := $001D;
      register.BX := page_number;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_double_speed_threshold (threshold_speed : INTEGER);
   BEGIN
      register.AX := $0013;
      register.DX := threshold_speed;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_graphics_mouse_cursor (hot_spot_x, hot_spot_y : INTEGER;
                                   screen_and_cursor_mask : mouse_cursor_mask);
   BEGIN
      register.AX := $0009;
      register.BX := hot_spot_x;
      register.CX := hot_spot_y;
      register.ES := SEG(screen_and_cursor_mask);
      register.DX := OFS(screen_and_cursor_mask);
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_mouse_physical_movement_ratio (x8_positions_to_move,
                                             y8_positions_to_move : INTEGER);
   BEGIN
      register.AX := $000F;
      register.CX := x8_positions_to_move;
      register.DX := y8_positions_to_move;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_mouse_position (x,y : INTEGER);
   BEGIN
      register.AX := $0004;
      register.CX := x;
      register.DX := y;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_mouse_sensitivity (horizontal_coordinates_per_pixel,
                                 vertical_coordinates_per_pixel,
                                 double_speed_threshold : WORD);
   BEGIN
      register.AX := $001A;
      register.BX := horizontal_coordinates_per_pixel;
      register.CX := vertical_coordinates_per_pixel;
      register.DX := double_speed_threshold;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_mouse_x_bounds (minimum_x, maximum_x : WORD);
   BEGIN
      register.AX := $0008;
      register.CX := minimum_x;
      register.DX := maximum_x;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_mouse_y_bounds (minimum_y, maximum_y : WORD);
   BEGIN
      register.AX := $0007;
      register.CX := minimum_y;
      register.DX := maximum_y;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_text_mouse_attribute_cursor (screen_cursor_mask_offset : WORD);
   BEGIN
      register.AX := $000A;
      register.BX := $0000;
      register.CX := screen_cursor_mask_offset;
      register.DX := screen_cursor_mask_offset + 8;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_text_mouse_hardware_cursor (top_scan_line,
                                          bottom_scan_line : INTEGER);
   BEGIN
      register.AX := $000A;
      register.BX := $0001;
      register.CX := top_scan_line;
      register.DX := bottom_scan_line;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE set_user_defined_input_mask (call_mask, function_offset : INTEGER);
   BEGIN
      register.AX := $000C;
      register.CX := call_mask;
      register.DX := function_offset;
      INTR($33,register);
   END;
{*****************************************************************************}
PROCEDURE swap_mouse_interrupt_vector (VAR call_mask, mouse_vector_segment,
                                           mouse_vector_offset : WORD);
   VAR register_DS : INTEGER;
   BEGIN
      register_DS := register.DS;  {save the data segment}
      register.AX := $0014;
      register.CX := call_mask;
      register.ES := mouse_vector_offset;
      register.DX := mouse_vector_offset;
      INTR($33,register);
      call_mask := register.CX;
      mouse_vector_segment := register.ES;
      mouse_vector_offset := register.DX;
      register.DS := register_DS;   {resets the data segment}
      button_status := register.BX;
      check_button_status;
      horizontal_counts := register.DI;
      vertical_counts := register.SI;
      x := register.CX;
      y := register.DX;
   END;
{*****************************************************************************}
BEGIN
   x := 0;
   y := 0;
   number_buttons := number_of_buttons;
   number_of_presses := 0;
   number_of_releases := 0;
   left_mouse_button_released := FALSE;
   right_mouse_button_released := FALSE;
   left_mouse_button_released := FALSE;
   right_mouse_button_released := FALSE;
END.
