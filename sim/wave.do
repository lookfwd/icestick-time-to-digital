onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clk_100m
add wave -noupdate /top_tb/tdc_inst/rst_n
add wave -noupdate /top_tb/tdc_inst/signal_in
add wave -noupdate /top_tb/tdc_inst/meas_pending
add wave -noupdate -radix unsigned -childformat {{{/top_tb/tdc_inst/meas_buffer[39]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[38]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[37]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[36]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[35]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[34]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[33]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[32]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[31]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[30]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[29]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[28]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[27]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[26]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[25]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[24]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[23]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[22]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[21]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[20]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[19]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[18]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[17]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[16]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[15]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[14]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[13]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[12]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[11]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[10]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[9]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[8]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[7]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[6]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[5]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[4]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[3]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[2]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[1]} -radix unsigned} {{/top_tb/tdc_inst/meas_buffer[0]} -radix unsigned}} -subitemconfig {{/top_tb/tdc_inst/meas_buffer[39]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[38]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[37]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[36]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[35]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[34]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[33]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[32]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[31]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[30]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[29]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[28]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[27]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[26]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[25]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[24]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[23]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[22]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[21]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[20]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[19]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[18]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[17]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[16]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[15]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[14]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[13]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[12]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[11]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[10]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[9]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[8]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[7]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[6]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[5]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[4]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[3]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[2]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[1]} {-height 15 -radix unsigned} {/top_tb/tdc_inst/meas_buffer[0]} {-height 15 -radix unsigned}} /top_tb/tdc_inst/meas_buffer
add wave -noupdate /top_tb/tdc_inst/uart_start
add wave -noupdate /top_tb/tdc_inst/can_transmit
add wave -noupdate -radix decimal /top_tb/tdc_inst/rate_counter
add wave -noupdate -radix decimal /top_tb/tdc_inst/uart_inst/state
add wave -noupdate -radix unsigned /top_tb/tdc_inst/uart_inst/bit_index
add wave -noupdate -radix unsigned /top_tb/tdc_inst/uart_inst/char_index
add wave -noupdate /top_tb/tdc_inst/tdc_inst/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {51000225300 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 233
configure wave -valuecolwidth 59
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits us
update
WaveRestoreZoom {54500725800 ps} {54500804 ns}
