dut ?= nanocore16

clean_filelist:
	rm -rf ${WORKAREA}/output/${dut}/sim.f

gen_filelist:
	mkdir -p ${WORKAREA}/output/${dut}
	touch ${WORKAREA}/output/${dut}/sim.f
	cat ${WORKAREA}/filelist/*.f >> ${WORKAREA}/output/${dut}/sim.f
