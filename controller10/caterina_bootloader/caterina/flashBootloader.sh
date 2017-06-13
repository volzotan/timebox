avrdude -v -patmega32u4 -cstk500v2 -Pusb -e -Ulock:w:0x3F:m -Uefuse:w:0xcb:m -Uhfuse:w:0xd8:m -Ulfuse:w:0xff:m 
avrdude -v -patmega32u4 -cstk500v2 -Pusb -Uflash:w:TimeboxCaterina.hex:i -Ulock:w:0x2F:m 
