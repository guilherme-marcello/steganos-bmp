NASM_FLAGS = -f elf64 -F dwarf
LIB_OBJS = util/IOUtil.o util/ArgsUtil.o util/NumericUtil.o
DEPS = steganos-bmp-cover.asm steganos-bmp-recover.asm $(LIB_OBJS)

all: libs cover recover
libs: $(LIB_OBJS)

$(LIB_OBJS): util/%.o: util/%.asm
	nasm $(NASM_FLAGS) $< -o $@

cover: steganos-bmp-cover.o $(LIB_OBJS)
	ld $^ -o steganos-bmp-cover

steganos-bmp-cover.o: steganos-bmp-cover.asm $(LIB_OBJS)
	nasm $(NASM_FLAGS) $< -o $@

recover: steganos-bmp-recover.o $(LIB_OBJS)
	ld $^ -o steganos-bmp-recover

steganos-bmp-recover.o: steganos-bmp-recover.asm $(LIB_OBJS)
	nasm $(NASM_FLAGS) $< -o $@

clean:
	rm -f $(LIB_OBJS) steganos-bmp-cover.o steganos-bmp-recover.o steganos-bmp-cover steganos-bmp-recover
