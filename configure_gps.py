import serial

ser = serial.Serial(
    port='/dev/ttyUSB3',
    baudrate=115200
)

ser.isOpen()
ser.write(b'AT+CGPS = 1\r\n')
ser.close()
