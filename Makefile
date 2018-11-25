all: top.bin top.png tb

clean:
	rm -f top.asc
	rm -f top.blif
	rm -f top.dot
	rm -f top.png
	rm -f top.bin
	rm -f *vcd
	rm -f shiftout_tb top_tb ledmatrix_tb
	rm -f top_syntb top_syn.v

top.blif: top.v ledmatrix.v shiftout.v
	# -abc2 -retime -nodffe
	yosys -p "synth_ice40 -blif top.blif" top.v shiftout.v

top.dot: top.v ledmatrix.v shiftout.v
	# ledmatrix.v
	yosys -p "prep; show -stretch -prefix top -format dot" top.v shiftout.v

top.png: top.dot
	dot -Tpng top.dot >top.png

top.asc: top.blif pins.pcf
	# iceblink40
	arachne-pnr -d 1k -P vq100 -p pins.pcf top.blif -o top.asc
	# tinyfpga bx
	# arachne-pnr -d 8k -P cm81 -p pins.pcf top.blif -o top.asc

tb: shiftout_tb ledmatrix_tb top_tb
	# top_syntb

shiftout_tb: shiftout.v shiftout_tb.v
	iverilog -o shiftout_tb shiftout.v shiftout_tb.v
	./shiftout_tb

ledmatrix_tb: ledmatrix.v shiftout.v
	iverilog -o ledmatrix_tb ledmatrix.v shiftout.v
	./ledmatrix_tb

top_tb: top.v top_tb.v shiftout.v
	iverilog -o top_tb top_tb.v top.v shiftout.v
	./top_tb

# top_syn.v: top.blif
# 	yosys -p 'read_blif -wideports top.blif; write_verilog top_syn.v'

# top_syntb: top_syn.v top_tb.v
# 	iverilog -o top_syntb top_syn.v top_tb.v `yosys-config --datdir/ice40/cells_sim.v`
# 	./top_syntb

# top_tb2: top.v top_tb.v ledmatrix.v shiftout.v
# 	yosys -p "synth_ice40; write_verilog top_tb2_synth.v" top_tb.v top.v ledmatrix.v shiftout.v

top.bin: top.asc
	icepack top.asc top.bin

prog: tb top.bin
	sudo iCEburn -ew top.bin
	# sudo tinyprog -p top.bin
