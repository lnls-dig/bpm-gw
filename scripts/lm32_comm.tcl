# mostly from lm32-ctl script: http://www.ohwr.org/projects/lm32/repository

########################### MAIN USER LOOP #########################

proc mainLoop {argc argv} {
    sync
    set nextcmd $argv
    set cmd ""
    set line ""
    while {$cmd != "quit"} {

        puts $argv

        if {$argv eq ""} {
            set interactive 1
            puts -nonewline "\nlm32> "
                if {[gets stdin line] < 0} break
        } else {
            set interactive 0
            set line $nextcmd
        }

        set parts [split $line " "]
        set args [lassign $parts cmd]

        #set cmd [lindex $parts 0]
        #set parts [lreplace $parts 0 0]
        #foreach {args} $parts {break}
        #set args $parts

        #set args $parts[0]
        #set parts [lreplace $parts 0 0]
        #foreach {arg1 arg2 arg3 arg4} $args {break}

        set tail [lassign $args arg1 arg2 arg3 arg4]

        switch $cmd {
          "" { }
          "break" { cpu_break }
          "console" { jtag_uart_console }
          "reset" { reset }
          "sync" { sync }
          "read" { set nextcmd [read_memory $arg1 $arg2] }
          "dump" { set nextcmd [dump_memory $arg1 $arg2] }
          "verify" {verify $arg1}
          "write" { write_memory $arg1 $arg2 }
          "csr" { csr $arg1 $arg2 }
          "recv" { recv }
          "send" { send $args }
          "load" { load $arg1 }
          "quit" { }
          default { puts "Unknown command" }
        }

        if {$interactive == 0} {
            break
        }
    }

    # Close device
}

########################### LOW LEVEL ACCESS #########################
#proc jtag_put {handle deviceIndex val} {
proc jtag_put {val} {

    global jtag_handle
    global fpga_deviceIndex
    global device_ir_length
    global CSEJTAG_LOCKED_ME
    global CSE_MSG_ERROR
    global CSEJTAG_SHIFT_READWRITE
    global CSEJTAG_SHIFT_WRITE
    global CSEJTAG_RUN_TEST_IDLE
    global USER_NUM

    set ret 0

    if {[catch {

        csejtag_tap shift_device_ir $jtag_handle $fpga_deviceIndex $CSEJTAG_SHIFT_READWRITE $CSEJTAG_RUN_TEST_IDLE 0 $device_ir_length "[format %03X $USER_NUM]"

        #csejtag_tap shift_device_dr $handle $deviceIndex $CSEJTAG_SHIFT_WRITE $CSEJTAG_SHIFT_DR 0 11 "[format %03X $val]"
        #csejtag_tap shift_device_dr $HANDLE $DEVICE_INDEX $CSEJTAG_SHIFT_WRITE $CSEJTAG_SHIFT_DR 0 11 "[format %03X $val]"
        set ret 0x[csejtag_tap shift_device_dr $jtag_handle $fpga_deviceIndex $CSEJTAG_SHIFT_READWRITE $CSEJTAG_RUN_TEST_IDLE 0 11 "[format %03X $val]"]
        #device_virtual_dr_shift -instance_index 0 -length 11 -dr_value "[format %03X $val]" -value_in_hex -no_captured_dr_value

    } result]} {
        global errorCode
        global errorInfo
        puts stderr "\nCaught error: $result"
        puts stderr "**** Error Code ***"
        puts stderr $errorCode
        puts stderr "**** Tcl Trace ****"
        puts stderr $errorInfo
        puts stderr "*******************"
    }

    return $ret
}

#proc jtag_get {handle deviceIndex} {
proc jtag_get {} {

    global jtag_handle
    global fpga_deviceIndex
    global device_ir_length
    global CSEJTAG_LOCKED_ME
    global CSE_MSG_ERROR
    global CSEJTAG_SHIFT_READWRITE
    global CSEJTAG_SHIFT_READ
    global CSEJTAG_RUN_TEST_IDLE
    global USER_NUM

    set ret 0

    if {[catch {

        csejtag_tap shift_device_ir $jtag_handle $fpga_deviceIndex $CSEJTAG_SHIFT_READWRITE $CSEJTAG_RUN_TEST_IDLE 0 $device_ir_length "[format %03X $USER_NUM]"

        #return 0x[csejtag_tap shift_device_dr $HANDLE $DEVICE_INDEX $CSEJTAG_SHIFT_READ $CSEJTAG_SHIFT_DR 0 11 "[format %03X 000]"]
        set ret 0x[csejtag_tap shift_device_dr $jtag_handle $fpga_deviceIndex $CSEJTAG_SHIFT_READ $CSEJTAG_RUN_TEST_IDLE 0 11 "[format %03X 000]"]
        #return 0x[device_virtual_dr_shift -instance_index 0 -length 11 -dr_value 000 -value_in_hex]

    } result]} {
        global errorCode
        global errorInfo
        puts stderr "\nCaught error: $result"
        puts stderr "**** Error Code ***"
        puts stderr $errorCode
        puts stderr "**** Tcl Trace ****"
        puts stderr $errorInfo
        puts stderr "*******************"
    }

    return $ret
}

#proc jtag_lock {handle deviceIndex timeout} {
proc jtag_lock {} {

    global jtag_handle
    global CSEJTAG_LOCKED_ME
    global TIMEOUT

    set cablelock [csejtag_target lock $jtag_handle $TIMEOUT]
    if {$cablelock != $CSEJTAG_LOCKED_ME} {
        csejtag_session send_message $jtag_handle $CSE_MSG_ERROR "cse_lock_target failed"
        csejtag_target close $jtag_handle
        #return
    }

    return $cablelock
    #csejtag_tap shift_device_ir $HANDLE $DEVICE_INDEX $CSEJTAG_SHIFT_WRITE $CSEJTAG_RUN_TEST_IDLE 0 1 "[format %01X 1]"

    #device_lock -timeout 10000
    #device_virtual_ir_shift -instance_index 0 -ir_value 1 -no_captured_ir_value
# -show_equivalent_device_ir_dr_shift
}

#proc jtag_unlock {handle} {
proc jtag_unlock {} {

    global jtag_handle

    csejtag_target unlock $jtag_handle
}

############################ SAFE-ISHL ACCESS #########################
# 000 1111 0000
# 111 1000 0000
proc jtag_val {idx val} {
  set v [ expr { ($val << 3) | $idx }]
  jtag_put "$v"
}
# 000 1111 0000
proc jtag_cmd {idx cmd} {
  set val [ expr { $cmd<<4 }]
  jtag_val "$idx" "$val"
}

proc jtag_low {i} {
  set high 1
  while {$high >= 1} {
    set val [jtag_get]
    set high [expr {($val >> $i) & 1}]
  }
  return [expr {$val >> 3}]
}

proc jtag_high {i} {
  set high 0
  while {$high < 1} {
    set val [jtag_get]
    set high [expr {($val >> $i) & 1}]
  }
  return [expr {$val >> 3}]
}

############################## COMMANDS ###############################

proc jtag_read_addr {addr} {
  jtag_cmd 0 1
  jtag_val 0 "[expr {($addr >> 24) & 0xff}]"
  jtag_val 0 "[expr {($addr >> 16) & 0xff}]"
  jtag_val 0 "[expr {($addr >>  8) & 0xff}]"
  jtag_val 0 "[expr {($addr >>  0) & 0xff}]"

  return [jtag_low 2]
}

proc jtag_read_next {} {
  jtag_cmd 0 3
  return [jtag_low 2]
}

proc jtag_read_memory {addr len} {
  set out [list]

  for {set i 0} {$i < $len} {incr i} {
    set x [expr {$addr+$i}]
    if {$i == 0 || ($x & 0xffff) == 0} {
      lappend out "[format %02X [jtag_read_addr $x]]"
    } else {
      lappend out "[format %02X [jtag_read_next]]"
    }
  }

  return "$out"
}

proc jtag_write_addr {addr val} {
  jtag_cmd 0 2
  jtag_val 0 "[expr {($addr >> 24) & 0xff}]"
  jtag_val 0 "[expr {($addr >> 16) & 0xff}]"
  jtag_val 0 "[expr {($addr >>  8) & 0xff}]"
  jtag_val 0 "[expr {($addr >>  0) & 0xff}]"
  jtag_val 0 "$val"

  return [jtag_low 2]
}

proc jtag_write_next {val} {
  jtag_cmd 0 4
  jtag_val 0 "$val"
#  return [jtag_low 2]
}

proc jtag_write_memory {addr data} {
  set first 1
  foreach j $data {
    if {$first == 1 || ($addr & 0xffff) == 0} {
      set first 0
      jtag_write_addr "$addr" "$j"
    } else {
      jtag_write_next "$j"
    }
    set addr [expr {$addr + 1}]
  }
}

proc jtag_uart_write {val} {
  jtag_low 1
  jtag_val 1 "$val"
}

proc jtag_uart_read {} {
  set val [jtag_get]
  while {($val & 1) == 1} {
    jtag_val 2 0
    set val [jtag_get]
    set inb [expr {$val >> 3}]
    puts -nonewline "[format %02X $inb] "
  }
  puts "."
}

proc jtag_uart_console {} {
  jtag_lock
  while {1} {
    set val [jtag_get]
    while {($val & 1) == 1} {
      jtag_val 2 0
      set val [jtag_get]
      set inb [expr {$val >> 3}]
      puts -nonewline "[format %c $inb]"
    }
  }
  jtag_unlock
}

proc jtag_write_csr {csr val} {
  jtag_cmd 0 5
  jtag_val 0 "[expr {($val >> 24) & 0xff}]"
  jtag_val 0 "[expr {($val >> 16) & 0xff}]"
  jtag_val 0 "[expr {($val >>  8) & 0xff}]"
  jtag_val 0 "[expr {($val >>  0) & 0xff}]"
  jtag_val 0 "$csr"

  return [jtag_low 2]
}

proc jtag_break {} {
  jtag_cmd 0 6
}

proc jtag_reset {} {
  jtag_cmd 0 7
}

# Move back to idle state
proc jtag_sync {} {
  for {set i 0} {$i < 10} {incr i} {
    jtag_cmd 0 0
    after 20
  }
}

################################# ASM #################################

proc opcode {val} {
  switch $val {
     0 { return "srui"    }
     1 { return "nori"    }
     2 { return "muli"    }
     3 { return "sh"      }
     4 { return "lb"      }
     5 { return "sri"     }
     6 { return "xori"    }
     7 { return "lh"      }
     8 { return "andi"    }
     9 { return "xnori"   }
    10 { return "lw"      }
    11 { return "lhu"     }
    12 { return "sb"      }
    13 { return "addi"    }
    14 { return "ori"     }
    15 { return "sli"     }
    16 { return "lbu"     }
    17 { return "be"      }
    18 { return "bg"      }
    19 { return "bge"     }
    20 { return "bgeu"    }
    21 { return "bgu"     }
    22 { return "sw"      }
    23 { return "bne"     }
    24 { return "andhi"   }
    25 { return "cmpei"   }
    26 { return "cmpgi"   }
    27 { return "cmpgei"  }
    28 { return "cmpgeui" }
    29 { return "cmpgui"  }
    30 { return "orhi"    }
    31 { return "cmpnei"  }
    32 { return "sru"     }
    33 { return "nor"     }
    34 { return "mul"     }
    35 { return "divu"    }
    36 { return "rcsr"    }
    37 { return "sr"      }
    38 { return "xor"     }
    39 { return "div"     }
    40 { return "and"     }
    41 { return "xnor"    }
    42 { return "??"      }
    43 { return "raise"   }
    44 { return "sextb"   }
    45 { return "add"     }
    46 { return "or"      }
    47 { return "sl"      }
    48 { return "b"       }
    49 { return "modu"    }
    50 { return "sub"     }
    51 { return "??"      }
    52 { return "wcsr"    }
    53 { return "mod"     }
    54 { return "call"    }
    55 { return "sexth"   }
    56 { return "bi"      }
    57 { return "cmpe"    }
    58 { return "cmpg"    }
    59 { return "cmpge"   }
    60 { return "cmpgeu"  }
    61 { return "cmpgu"   }
    62 { return "calli"   }
    63 { return "cmpne"   }
  }
}

proc reg {i} {
  switch $i {
    26 { return "gp" }
    27 { return "fp" }
    28 { return "sp" }
    29 { return "ra" }
    30 { return "ea" }
    31 { return "ba" }
    default { return "r$i" }
  }
}

proc csr_reg {i} {
  switch $i {
    0 { return "IE" }
    1 { return "IM" }
    2 { return "IP" }
    3 { return "ICC" }
    4 { return "DCC" }
    5 { return "CC" }
    6 { return "CFG" }
    7 { return "EBA" }
    8 { return "DC" }
    9 { return "DEBA" }
   14 { return "JTX" }
   15 { return "JRX" }
   16 { return "BP0" }
   17 { return "BP1" }
   18 { return "BP2" }
   19 { return "BP3" }
   24 { return "WP0" }
   25 { return "WP1" }
   26 { return "WP2" }
   27 { return "WP3" }
  }
}

proc imm16 {i} {
  if {$i >= 32768} {
    return "-[expr {65536 - $i}]"
  } else {
    return "+$i"
  }
}

proc imm26 {i} {
  if {$i >= 33554432} {
    return "-[expr {67108864 - $i}]"
  } else {
    return "+$i"
  }
}

proc opfmt {op} {
  set code [expr {$op >> 26}]
  set r0 [expr {($op >> 21) & 31}]
  set r1 [expr {($op >> 16) & 31}]
  set r2 [expr {($op >> 11) & 31}]
  set i16 [expr {$op & 0xffff}]
  set i26 [expr {$op & 0x3ffffff}]

  if {$code == 4 || $code == 7 || $code == 10 || $code == 11 || $code == 16} {
    # lb, lh, lw, lhu, lbu
    return "[opcode $code] [reg $r1], ([reg $r0][imm16 $i16])"
  } elseif {$code == 3 || $code == 12 || $code == 22} { # sh, sb, sw
    return "[opcode $code] ([reg $r0][imm16 $i16]), [reg $r1]"
  } elseif {$code <= 32} { # (op, op, imm) instruction
    return "[opcode $code] [reg $r1], [reg $r0], [imm16 $i16]"
  } elseif {$code == 48 || $code == 54} { # b, call
    return "[opcode $code] [reg $r0]"
  } elseif {$code == 36} { # rcsr
    return "[opcode $code] [reg $r2], [csr_reg $r0]"
  } elseif {$code == 52} { # wcsr
    return "[opcode $code] [csr_reg $r0], [reg $r1]"
  } elseif {$code == 56 || $code == 62 || $code == 43} { # bi, calli, raise
    return "[opcode $code] [imm26 $i26]"
  } elseif {$code == 44 || $code == 55} { # sextb, sexth
    return "[opcode $code] [reg $r2], [reg $r0]"
  } else {
    return "[opcode $code] [reg $r2], [reg $r1], [reg $r0]"
  }
}

################################ CMDS #################################

proc reset {} {
  jtag_lock
  jtag_reset
  jtag_unlock
}

proc cpu_break {} {
  jtag_lock
  jtag_break
  jtag_unlock
}

proc sync {} {
  jtag_lock
  jtag_sync
  jtag_unlock
}

proc read_memory {addr len} {
  jtag_lock
  if {$addr == ""} {set addr 0}
  if {$len == ""} {set len 64}

  # Align read to 16-byte boundary
  set a_addr [expr {$addr & ~0xf}]
  set a_len [expr {($len + 15) & ~0xf}]

  set vals [jtag_read_memory $a_addr $a_len]

  for {set i 0} {$i < $a_len} {set i [expr {$i + 16}]} {
    puts -nonewline [format %08X: $a_addr]
    set a_addr [expr {$a_addr + 16}]
    for {set j 0} {$j < 4} {incr j} {
      set vals [lassign $vals b0 b1 b2 b3]
      puts -nonewline " $b0$b1$b2$b3"
    }
    puts ""
  }

  set nextcmd [list]
  lappend nextcmd "read"
  lappend nextcmd $a_addr
  lappend nextcmd $a_len
  jtag_unlock
  return $nextcmd
}

proc write_memory {addr val} {
  jtag_lock
  set data [list]
  lappend data [expr {($val >> 24) & 0xff}]
  lappend data [expr {($val >> 16) & 0xff}]
  lappend data [expr {($val >>  8) & 0xff}]
  lappend data [expr {($val >>  0) & 0xff}]
  jtag_write_memory $addr $data
  jtag_unlock
}

proc dump_memory {addr len} {
  jtag_lock
  if {$addr == ""} {set addr 0}
  if {$len == ""} {set len 16}

  # Align read to 4-byte boundary
  set a_addr [expr {$addr & ~0x3}]
  set a_len [expr {$len * 4}]
  set a_end [expr {$a_addr + $a_len}]

  set vals [jtag_read_memory $a_addr $a_len]

  for {set a $a_addr} {$a < $a_end} {set a [expr {$a + 4}]} {
    set vals [lassign $vals b0 b1 b2 b3]
    puts "[format %08X $a]: [opfmt 0x$b0$b1$b2$b3]"
  }

  set nextcmd [list]
  lappend nextcmd "dump"
  lappend nextcmd [expr {$a_addr + $a_len}]
  lappend nextcmd [expr {$a_len / 4}]
  jtag_unlock
  return $nextcmd
}

proc csr {csr val} {
  jtag_lock
  jtag_write_csr $csr $val
  jtag_unlock
}

proc recv {} {
  jtag_lock
  jtag_uart_read
  jtag_unlock
}

proc send {data} {
  jtag_lock
  foreach j $data {
    jtag_uart_write $j
  }
  jtag_unlock
}

proc transfer {prompt file offset len target} {
  set data [open $file]
  fconfigure $data -translation binary
  seek $data $offset

  set progress 0
  for {set done 0} {$done < $len} {set done [expr {$done+$did}]} {
    puts -nonewline "\r$prompt$done bytes"

    set rest [expr {$len - $done}]
    if {$rest > 100} { set do 100 } else { set do $rest }

    set bytes [read $data $do]
    set chunk [list]
    for {set i 0} {$i < $do} {incr i} {
      scan [string index $bytes $i] %c v
      lappend chunk $v
    }

    #puts "$chunk = [llength $chunk]"
    set did [llength $chunk]
    if {$did != $do} {
      puts "\n -- Short transfer error!"
      break
    }

    jtag_write_memory $target $chunk
    set target [expr {$target+$did}]
  }

  if {$done == $len} {
    puts "\r$prompt[format %d $len] bytes - complete"
  }

  close $data
}

proc cmpBytefield { ilist1 ilist2 target offset} {

  set len1 [llength $ilist1]
  set len2 [llength $ilist2]

    #if list lengths differ, return length of the shorter list, else compare
    #puts "file $len1 ram $len2"
    if {$len1 < $len2} {
        puts "Chunk bigger than Vals!"
        return $len1
    } elseif {$len2 < $len1} {
        puts "Vals bigger than Chunk!"
        return $len2
    } else {
    #compare elements. return -1 if bytefields are equal,
    #else return the offset of first diff

        for { set i 0 } { $i < $len1 } { incr i } {

            set elem1 [format %2.2X [lindex $ilist1 $i]]
            set elem2 [lindex $ilist2 $i]

            if {$elem1 != $elem2} {
                puts ""
                puts ""
                puts "Verify failed, diff follows:"
                puts ""
                set a_addr [expr {$target & ~0xf}]

                puts "RAM Content:"
                puts "*********************************************"
                for {set k 0} {$k < $len1} {set k [expr {$k + 16}]} {

                    puts ""
                    puts -nonewline [format %08X: $a_addr]
                        set a_addr [expr {$a_addr + 16}]
                        for {set j 0} {$j < 4} {incr j} {
                            set ilist2 [lassign $ilist2 b0 b1 b2 b3]
                            if {[expr {$i/4}] == [expr {[expr {$k/4}] + $j}] } {
                                puts -nonewline " \033\[31m$b0$b1$b2$b3\033\[0m"
                            } else {
                                puts -nonewline " $b0$b1$b2$b3"
                        }
                    }
                }

                puts ""
                set a_addr [expr {[expr {$target + $offset}] & ~0xf}]
                    puts ""
                    puts "ELF Content:"
                    puts "*********************************************"
                    for {set k 0} {$k < $len1} {set k [expr {$k + 16}]} {
                        puts ""
                        puts -nonewline [format %08X: $a_addr]
                        set a_addr [expr {$a_addr + 16}]
                        for {set j 0} {$j < 4} {incr j} {
                            set ilist1 [lassign $ilist1 b0 b1 b2 b3]
                            if {[expr {$i/4}] == [expr {[expr {$k/4}] + $j}] } {
                                puts -nonewline " \033\[31m[format %02X $b0][format %02X $b1][format %02X $b2][format %02X $b3]\033\[0m"
                            } else {
                                puts -nonewline " [format %02X $b0][format %02X $b1][format %02X $b2][format %02X $b3]"
                            }
                        }
                    }
                puts ""
                puts ""

                return $i
            }
        }

        return -1
    }
}

proc compare {section file offset len target} {
  set prompt " section $section: "
  set data [open $file]
  fconfigure $data -translation binary
  seek $data $offset

  set progress 0
#puts "Working $section"
  for {set done 0} {$done < $len} {set done [expr {$done+$did}]} {


    set rest [expr {$len - $done}]
    if {$rest > 128} { set do 128 } else { set do $rest }

    set bytes [read $data $do]
    set chunk [list]
    for {set i 0} {$i < $do} {incr i} {
      scan [string index $bytes $i] %c v
      lappend chunk $v
    }

    #puts "$chunk = [llength $chunk]"
    set did [llength $chunk]
    if {$did != $do} {
      puts "\n -- Short transfer error!"
      break
    }

 # Align read to 4-byte boundary
  set a_addr $target
  set a_len $did
  set a_end [expr {$a_addr + $a_len}]
#puts "read vals... START $a_addr LEN $a_len END $a_end"
  set vals [jtag_read_memory $a_addr $a_len]
#puts "read done."

  #modify file content of boot section to match CPU trap in ram

# if {[string equal $section ".boot"]==1 && $done == 0 } {
#   set chunk [lreplace $chunk 0 3 224 0 0 0]
#   puts "Replaced file content with CPU trap"
#  }

  set cmpresult [cmpBytefield $chunk $vals $target $offset]

  if {$cmpresult !=  -1} {
    puts ""
    puts -nonewline "Verify failed at offset "
    puts "[format %#8.8X [expr {$cmpresult+$target}]]"
    puts ""
    break
  } else {
    puts -nonewline "\r$prompt$done bytes"
  }

    set target [expr {$target+$did}]
  }

  if {$done == $len} {
    puts "\r$prompt[format %d $len] bytes - Verify complete"
  }

  close $data
  return $cmpresult
}

proc verify {file} {
  if {$file == ""} {
    puts "Specify file to load!"
    return
  }
  jtag_lock

#puts -nonewline "Capturing the CPU at address 0x0: "
#  for {set i 0} {$i < 20} {incr i} {
#    # bi +0 (CPU trap)
#   jtag_write_memory 0x0 { 0xE0 0x00 0x00 0x00 }
#    # flush instruction cache
#    jtag_write_csr 0x3 0x0
#    # Position CPU on this trap
#    jtag_reset
#  }
#  # Wait a bit to be sure the CPU has the trap good and cached
#  after 20
#  puts "done"

  set sections [list]

  set sf [open "| readelf -S $file" "r"]
  while {[gets $sf line] >= 0} {
    if {[regexp {^\s+\[..\]\s+(\.\w+)\s+[^0-9a-f]*\s[0-9a-f]{4,}\s+([0-9a-f]{4,})\s+([0-9a-f]{4,})\s} $line nil section offset size] == 0} continue
    lappend sections "$section 0x$offset 0x$size"
  }
  close $sf

  set lf [open "| readelf -l $file" "r"]
  while {[gets $lf line] >= 0} {
    if {[regexp {^\s*LOAD\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+} $line nil offset vaddr paddr len] == 0} continue
    puts "Verifying $offset+$len to $paddr"
    if {$paddr != $vaddr} {
      puts " Physical and virtual address mismatch! - Skipping"
      continue
    }
    foreach j $sections {
      lassign [split $j " "] section off size
      set taddr [expr {$paddr+$off-$offset}]
      if {$offset <= $off && $off+$size <= $offset+$len} {
        if {[compare $section $file $off $size $taddr] != -1} {
        break
        }

      } elseif {$offset <= $off && $off < $offset+$len} {
        puts " section $section: only half contained??"
      }
    }
  }
  close $lf

#  puts -nonewline "Releasing CPU: "
#  jtag_write_csr 0x4 0x0
#  after 20
#  jtag_write_csr 0x3 0x0
#  puts done
  jtag_unlock

 # jtag_reset

 # jtag_unlock

}

proc load {file} {
  if {$file == ""} {
    puts "Specify file to load!"
    return
  }
  jtag_lock

  puts -nonewline "Capturing the CPU at address 0x0: "
  for {set i 0} {$i < 20} {incr i} {
    # bi +0 (CPU trap)
    jtag_write_memory 0x0 { 0xE0 0x00 0x00 0x00 }
    # flush instruction cache
    jtag_write_csr 0x3 0x0
    # Position CPU on this trap
    jtag_reset
  }
  # Wait a bit to be sure the CPU has the trap good and cached
  after 20
  puts "done"

  set sections [list]
  set sf [open "| readelf -S $file" "r"]
  while {[gets $sf line] >= 0} {
    if {[regexp {^\s+\[..\]\s+(\.\w+)\s+[^0-9a-f]*\s[0-9a-f]{4,}\s+([0-9a-f]{4,})\s+([0-9a-f]{4,})\s} $line nil section offset size] == 0} continue
    lappend sections "$section 0x$offset 0x$size"
  }
  close $sf

  # We can safely overwrite all of the instruction bus (even 0x0) now.
  # The trap is certainly cached and the CPU will not see the new values.
  set lf [open "| readelf -l $file" "r"]
  while {[gets $lf line] >= 0} {
    if {[regexp {^\s*LOAD\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+} $line nil offset vaddr paddr len] == 0} continue
    puts "Loading $offset+$len to $paddr"
    if {$paddr != $vaddr} {
      puts " Physical and virtual address mismatch! - Skipping"
      continue
    }
    foreach j $sections {
      lassign [split $j " "] section off size
      set taddr [expr {$paddr+$off-$offset}]
      if {$offset <= $off && $off+$size <= $offset+$len} {
        transfer " section $section: " $file $off $size $taddr
      } elseif {$offset <= $off && $off < $offset+$len} {
        puts " section $section: only half contained??"
      }
    }
  }
  close $lf

  # The CPU is spinning at address 0, so no need to reset it.
  # First flush the dcache and then release the CPU by flushing the icache
  puts -nonewline "Releasing CPU: "
  jtag_write_csr 0x4 0x0
  after 20
  jtag_write_csr 0x3 0x0
  puts done
  jtag_unlock
}
