(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0006.PAS
  Description: PTYPES.INC
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

{--PTYPES.INC-----------------------------------------------------------
}
{ Type and Constant decalarations }

CONST
   MAX_FILENAME_LEN   = 32;
   MAX_SOURCELINE_LEN = 246;
   MAX_PRINTLINE_LEN  = 80;
   MAX_LINES_PER_PAGE = 50;
   DATE_STRING_LENGTH = 26;
   F_FEED             = #12;

VAR
   line_num, page_num,
   level, line_count   :word;

   source_buffer :string[MAX_SOURCELINE_LEN];
   source_name   :string[MAX_FILENAME_LEN];
   date          :string[DATE_STRING_LENGTH];
   F1            :text;


