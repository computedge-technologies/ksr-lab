ProjectName ?= nanocore16

clean:
	rm -rf *vvp *vcd

compile:
	iverilog -g2012 -c ${WORKAREA}/output/${ProjectName}/sim.f -o ${ProjectName}.vvp

sim:
	vvp *.vvp

gui:
	gtkwave *.vcd &
