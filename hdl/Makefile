SRC=\
	math_pkg.vhd\
	downsampler.vhd\
	integrator.vhd\
	differentiator.vhd\
	cic_decimator.vhd\
	cic_decimator_tb.vhd
clock : $(SRC)
	mkdir -p out/
	ghdl -s --std=93c --workdir=out/ $(SRC)
	ghdl -a --std=93c --workdir=out/ $(SRC)
	ghdl -e --std=93c --workdir=out/ cic_decimator_tb
	make run
run : 
	./run.sh
clean distclean::
	ghdl --clean
	ghdl --remove
	rm *.o
	rm -rf *.fst
	rm cic_decimator_tb
	rm -rf out/
#	rm -rf ../matlab/hdl_out_log.m
