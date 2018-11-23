test.txt: test.gba thumb.txt
	arm-none-eabi-objdump -D -b binary -m arm7dmi test.gba > test.txt
thumb.txt: test.gba
	arm-none-eabi-objdump -D -b binary -m arm7dmi -Mforce-thumb test.gba > thumb.txt
test.gba: test.c
	arm-none-eabi-gcc -c test.c -mthumb-interwork -march=armv4t -marm -O2 -o test.o
	arm-none-eabi-gcc test.o -mthumb-interwork -march=armv4t -marm -specs=gba.specs -o test.elf
	arm-none-eabi-objcopy -v -O binary test.elf test.gba
