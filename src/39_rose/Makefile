RM = rm -f
QEMU = qemu-system-x86_64 -gdb tcp::12345 -S boot.img


ifeq ($(OS),Windows_NT)
	RM = cmd.exe /C del /Q
	QEMU = qemu-system-i386.exe -gdb tcp::12345 -S boot.img
endif

boot: 
	nasm boot.s -o boot.bin -l boot.lst
	nasm kernel.s -o kernel.bin -l kernel.lst
	cat boot.bin kernel.bin > boot.img

run:
	bochsdbg -q -f ../../env/bochsrc.bxrc -rc ../../env/cmd.init

dbg:
	$(QEMU)&
	gdb

clean:
	$(RM) *.img
	$(RM) *.bin
	$(RM) *.lst

