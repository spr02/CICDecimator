SRC=\
	downsampler.vhd\
	integrator.vhd\
	differentiator.vhd\
	cic_decimator.vhd\
	cic_decimator_tb.vhd
clock : $(SRC)
	ghdl -a --std=93c $(SRC)
	ghdl -s --std=93c $(SRC)
	ghdl -e --std=93c cic_decimator_tb
	make run
run : 
	./run.sh
clean distclean::
	ghdl --clean
	ghdl --remove
	rm -rf *.fst
	rm cic_decimator_tb
#	rm -rf ../matlab/hdl_out_log.m
