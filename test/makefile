all:
	@echo "-- Bulding and running tests --"
	@echo "Specify one of the following test as target"
	@echo "+ tickgentest"

tickgentest:
	iverilog ../rtl/uart16550_axil.v tickgentest.v -s tickgentest -o tickgentest.app
	./tickgentest.app

fifotest:
	iverilog ../rtl/uart16550_axil.v fifotest.v -s fifotest -o fifotest.app
	./fifotest.app

clean:
	rm -f *.app *.vcd 


