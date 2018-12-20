test.txt: test.gba thumb.txt
	arm-none-eabi-objdump -D -b binary -m armv4t test.gba > test.txt
thumb.txt: test.gba
	arm-none-eabi-objdump -D -b binary -m armv4t -Mforce-thumb test.gba > thumb.txt
test.gba: test.c ../include/*
	arm-none-eabi-gcc -c test.c -mthumb-interwork -march=armv4t -mthumb -O2 -o test.o -I ../include
	arm-none-eabi-gcc test.o -mthumb-interwork -march=armv4t -mthumb -specs=gba.specs -o test.elf
	arm-none-eabi-objcopy -v -O binary test.elf test.gba
