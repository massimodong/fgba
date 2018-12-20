C_SRCS = $(shell find -L ./src/ -name "*.c")
CPP_SRCS = $(shell find -L ./src/ -name "*.cpp")

test.txt: test.gba thumb.txt
	arm-none-eabi-objdump -D -b binary -m armv4t test.gba > test.txt
thumb.txt: test.gba
	arm-none-eabi-objdump -D -b binary -m armv4t -Mforce-thumb test.gba > thumb.txt
test.gba:  ./include/* $(C_SRCS) $(CPP_SRCS)
	arm-none-eabi-gcc -c $(C_SRCS) -mthumb-interwork -march=armv4t -mthumb -O2 -I ./include -fpermissive
	arm-none-eabi-g++ -c $(CPP_SRCS) -mthumb-interwork -march=armv4t -mthumb -O2 -I ./include -fpermissive
	arm-none-eabi-gcc ./*.o -mthumb-interwork -march=armv4t -marm -specs=gba.specs -o test.elf
	arm-none-eabi-objcopy -v -O binary test.elf test.gba
