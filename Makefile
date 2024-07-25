AS=as
ASFLAGS=--32 -gstabs -g -gstabs+
LD=ld -O --relax

SRC_DIR=src
OBJ_DIR=obj
BIN_DIR=bin

MAIN_SRC=$(SRC_DIR)/main.s
SLL_SRC=$(SRC_DIR)/sll.s
SLL_UTILS_SRC=$(SRC_DIR)/sll_utils.s
READFILE_SRC=$(SRC_DIR)/readfile.s
TASK_SRC=$(SRC_DIR)/task_utils.s
QUEUE_SRC=$(SRC_DIR)/queue.s
UI_SRC=$(SRC_DIR)/ui.s
CONSTANTS_SRC=$(SRC_DIR)/constants.s
UTILS_SRC=$(SRC_DIR)/common_utils.s


MAIN_OBJ=$(OBJ_DIR)/main.o
SLL_OBJ=$(OBJ_DIR)/sll.o
SLL_UTILS_OBJ=$(OBJ_DIR)/sll_utils.o
READFILE_OBJ=$(OBJ_DIR)/readfile.o
TASK_OBJ=$(OBJ_DIR)/task_utils.o
QUEUE_OBJ=$(OBJ_DIR)/queue.o
UI_OBJ=$(OBJ_DIR)/ui.o
CONSTANTS_OBJ=$(OBJ_DIR)/constants.o
UTILS_OBJ=$(OBJ_DIR)/common_utils.o


TARGET=$(BIN_DIR)/scheduler

all: $(TARGET)

$(TARGET): $(MAIN_OBJ) $(UTILS_OBJ) $(SLL_OBJ) $(SLL_UTILS_OBJ) $(READFILE_OBJ) $(TASK_OBJ) $(QUEUE_OBJ) $(UI_OBJ) $(CONSTANTS_OBJ)
	$(LD) -melf_i386 -o $@ $^


$(MAIN_OBJ): $(MAIN_SRC)
	$(AS) $(ASFLAGS) -o $@ $<

$(UTILS_OBJ): $(UTILS_SRC)
	$(AS) $(ASFLAGS) -o $@ $<

$(SLL_OBJ): $(SLL_SRC)
	$(AS) $(ASFLAGS) -o $@ $<

$(SLL_UTILS_OBJ): $(SLL_UTILS_SRC)
	$(AS) $(ASFLAGS) -o $@ $<
	
$(READFILE_OBJ): $(READFILE_SRC)
	$(AS) $(ASFLAGS) -o $@ $<
	
$(TASK_OBJ): $(TASK_SRC)
	$(AS) $(ASFLAGS) -o $@ $<
	
$(QUEUE_OBJ): $(QUEUE_SRC)
	$(AS) $(ASFLAGS) -o $@ $<

$(UI_OBJ): $(UI_SRC)
	$(AS) $(ASFLAGS) -o $@ $<

$(CONSTANTS_OBJ): $(CONSTANTS_SRC)
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f $(OBJ_DIR)/*.o $(TARGET)
