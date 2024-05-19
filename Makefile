AS=as
ASFLAGS=--32 -gstabs
LD=ld

SRC_DIR=src
OBJ_DIR=obj
BIN_DIR=bin

MAIN_SRC=$(SRC_DIR)/main.s
ITOA_SRC=$(SRC_DIR)/itoa.s
SLL_SRC=$(SRC_DIR)/sll.s

MAIN_OBJ=$(OBJ_DIR)/main.o
ITOA_OBJ=$(OBJ_DIR)/itoa.o
SLL_OBJ=$(OBJ_DIR)/sll.o

TARGET=$(BIN_DIR)/main

all: $(TARGET)

$(TARGET): $(MAIN_OBJ) $(ITOA_OBJ) $(SLL_OBJ)
	$(LD) -melf_i386  -o $@ $^

$(MAIN_OBJ): $(MAIN_SRC)
	$(AS) $(ASFLAGS) -o $@ $<

$(ITOA_OBJ): $(ITOA_SRC)
	$(AS) $(ASFLAGS) -o $@ $<

$(SLL_OBJ): $(SLL_SRC)
	$(AS) $(ASFLAGS) -o $@ $<
clean:
	rm -f $(OBJ_DIR)/*.o $(TARGET)
