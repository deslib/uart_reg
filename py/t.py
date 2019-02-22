#need to install pyserial(pip install pyserial)

import serial
import struct 


ser = serial.Serial('COM4', 115200)
ser.timeout = 1

WR = 0
RD = 1

def send_byte(val):
    ser.write(struct.pack('B',val))

def reg_wr(addr,val):
    send_byte(WR)
    send_byte(addr)
    send_byte(val)

def reg_rd(addr):    
    send_byte(RD)
    send_byte(addr)
    r = ser.read()
    if not r:
        raise Exception("reg rd addr=%d timeout"%addr)
    return ord(r)

