test.txt: test.gba thumb.txt
	arm-none-eabi-objdump -D -b binary -m armv4t test.gba > test.txt
thumb.txt: test.gba
	arm-none-eabi-objdump -D -b binary -m armv4t -Mforce-thumb test.gba > thumb.txt
test.gba:  ./include/* ./src/*
	arm-none-eabi-gcc -c ./src/*.c -mthumb-interwork -march=armv4t -marm -O2 -I ./include
	arm-none-eabi-gcc ./*.o -mthumb-interwork -march=armv4t -marm -specs=gba.specs -o test.elf
	arm-none-eabi-objcopy -v -O binary test.elf test.gba
