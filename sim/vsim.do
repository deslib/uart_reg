add wave -position insertpoint  \
sim:/tb_top/* \
sim:/tb_top/U_TOP/* \
sim:/tb_top/U_TOP/U_UART/* \
sim:/tb_top/U_TOP/U_UART/U_BAUDRATE/* \
sim:/tb_top/U_TOP/U_UART/U_TX/* \
sim:/tb_top/U_TOP/U_UART/U_RX/*
run 2000us;
