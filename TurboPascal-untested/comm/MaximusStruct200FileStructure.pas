(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0066.PAS
  Description: Maximus STRUCT.200 File Structure
  Author: JOHN STEPHENSON
  Date: 11-26-94  05:05
*)

{
> does anyone have the file STRUCT.200 available for F'req ?
> it seems to be the structure file of the USERS.BBS ?

You should say you're looking for the maximus one. Here's one I've personally
converted:
}

{ Converted to Pascal by John Stephenson on 7/11/1994, original source }
{ supply was from the maximus documentation                            }

  maxsingleusertype = record
      {  Caller's name                                                     }
      name : array[1..36] of char;
      {  Caller's location                                                 }
      city : array[1..36] of char;

      {  MAX: user's alias (handle)                                        }
      alias : array[1..21] of char;
      {  MAX: user's phone number                                          }
      phone : array[1..15] of char;

      {  MAX: a num which points to offset in LASTREAD                     }
      {  file -- Offset of lastread pointer will be                        }
      {  lastread_ptr*sizeof(int).                                         }
      lastread_ptr : word;

      {  MAX: time left for current call (xtern prog)                      }
      timeremaining : word;

      {  Password                                                          }
      pwd : array[1..16] of char;
      {  Number of previous calls to this system                           }
      times : word;
      {  Help level                                                        }
      help : byte;
      {  Reserved by Maximus for future use                                }
      rsvd1 : array[1..2] of byte;
      {  user's video mode (see GRAPH_XXXX)                                }
      video : byte;
      {  Number of Nulls (delays) after <cr>                               }
      nulls : byte;

      {  Bit flags for user (number 1)                                     }
      bits : byte;
      {  Reserved by Maximus for future use                                }
      rsvd2 : word;
      {  Bit flags for user (number 2)                                     }
      bits2 : word;

      {  Access level                                                      }
      priv : integer;
      {  Reserved by Maximus for future use                                }
      rsvd3 : array[1..19] of char;
      {  len of struct, divided by 20. SEE ABOVE!                          }
      struct_len : byte;
      {  Time on-line so far today                                         }
      time : word;
      {  Used to hold baud rate for O)utside command                       }
      {  In USER.BBS, usr.flag uses the constants                          }
      {  UFLAG_xxx, defined earlier in this file.                          }
      delflag : word;
      {  Reserved by Maximus for future use                                }
      rsvd4 : array[1..8] of char;
      {  Width of the caller's screen                                      }
      width : byte;
      {  Height of the caller's screen                                     }
      len : byte;
      {  Matrix credit, in cents                                           }
      credit : word;
      {  Current matrix debit, in cents                                    }
      debit : word;
      {  Priv to demote to, when time or minutes run                       }
      {  out.                                                              }
      xp_priv : word;
      {  Bit-mapped date of when user expires.                             }
      {  If zero, then no expiry date.                                     }
      xp_date : longint;
      {  How many minutes the user has left before                         }
      {  expiring.                                                         }
      xp_mins : longint;
      {  Flags for expiry.  See above XFLAG_XXX defs.                      }
      xp_flag : byte;
      xp_rsvd : byte;
      {  Bit-mapped date of user's last call                               }
      ludate : longint;
      {  User's keys (all 32 of 'em)                                       }
      xkeys : longint;
      {  The user's current language #                                     }
      lang : byte;
      {  Default file-transfer protocol                                    }
      def_proto : shortint;
      {  K-bytes uploaded, all calls                                       }
      up : longint;
      {  K-bytes downloaded, all calls                                     }
      down : longint;
      {  K-bytes downloaded, today -- or lastcall                          }
      downtoday : longint;
      {  User's last msg area (string)                                     }
      msg : array[1..MAX_ALEN] of char;
      {  User's last file area (string)                                    }
      files : array[1..MAX_ALEN] of char;
      {  Default compression program to use                                }
      compress : byte;
      {  Reserved for future use                                           }
      rsvd5 : byte;
      extra : longint;
  end;

