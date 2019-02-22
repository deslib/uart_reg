vlib work
vlog -l vlog.log -f compile.f 
vsim -c -l vsim.log tb_uart -do vsim_uart.do
