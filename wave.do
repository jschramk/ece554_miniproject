onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {clk & rst}
add wave -noupdate -radix binary /tpumac_tb/DUT/clk
add wave -noupdate -radix binary /tpumac_tb/DUT/rst_n
add wave -noupdate -divider {en & WrEn}
add wave -noupdate -radix binary /tpumac_tb/DUT/WrEn
add wave -noupdate -radix binary /tpumac_tb/DUT/en
add wave -noupdate -divider Inputs
add wave -noupdate -radix hexadecimal /tpumac_tb/DUT/Ain
add wave -noupdate -radix hexadecimal /tpumac_tb/DUT/Bin
add wave -noupdate -radix hexadecimal /tpumac_tb/DUT/Cin
add wave -noupdate -divider Outputs
add wave -noupdate -radix hexadecimal /tpumac_tb/DUT/Aout
add wave -noupdate -radix hexadecimal /tpumac_tb/DUT/Bout
add wave -noupdate -radix hexadecimal /tpumac_tb/DUT/Cout
add wave -noupdate -divider {Expected Output}
add wave -noupdate -radix hexadecimal /tpumac_tb/ExpSum
add wave -noupdate -divider Errors
add wave -noupdate -radix decimal /tpumac_tb/errors
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1012 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 173
configure wave -valuecolwidth 41
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {946 ps} {1344 ps}
