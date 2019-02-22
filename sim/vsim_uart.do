add wave -position insertpoint  \
sim:/tb_uart/* \
sim:/tb_uart/U_UART/* \
sim:/tb_uart/U_UART/U_BAUDRATE/* \
sim:/tb_uart/U_UART/U_TX/* \
sim:/tb_uart/U_UART/U_RX/*
run 150us;
