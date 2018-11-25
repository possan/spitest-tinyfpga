all: top.bin top.png tb

clean:
	rm -f top.asc
	rm -f top.blif
	rm -f top.dot
	rm -f top.png
	rm -f top.bin
	rm -f *vcd
	rm -f shiftout_tb top_tb
	rm -f top_syntb top_syn.v

top.blif: top.v shiftout.v
	yosys -p "synth_ice40 -blif top.blif" top.v shiftout.v

top.dot: top.v shiftout.v
	yosys -p "prep; show -stretch -prefix top -format dot" top.v shiftout.v

top.png: top.dot
	dot -Tpng top.dot >top.png

top.asc: top.blif pins.pcf
	arachne-pnr -d 8k -P cm81 -p pins.pcf top.blif -o top.asc

tb: shiftout_tb ledmatrix_tb top_tb

shiftout_tb: shiftout.v shiftout_tb.v
	iverilog -o shiftout_tb shiftout.v shiftout_tb.v
	./shiftout_tb

top_tb: top.v top_tb.v shiftout.v
	iverilog -o top_tb top_tb.v top.v shiftout.v
	./top_tb

top.bin: top.asc
	icepack top.asc top.bin

prog: tb top.bin
	sudo tinyprog -p top.bin
