#顶层模块名
TOPNAME   =top
INC_PATH := $(abspath $(shell find ./csrc/include -type d -print))

#verilator的编译选项
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD -cc  --exe  --trace --build   
VERILATOR_CFLAGS += -Wno-fatal		# only print lint warning, but not terminate compile.
VERILATOR_CFLAGS += -Wno-UNUSED 		# close <unused> warning.
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
VSRCS_DIR = vsrc
BIN = $(BUILD_DIR)/V$(TOPNAME)

#默认运行bin
default: sim
#创建build/obj_dir编译目录
$(shell mkdir -p $(BUILD_DIR))

VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")


#verilator的一些添加标志，top名，链接库，反汇编
CFLAGS += $(addprefix -I, $(INC_PATH)) -DTOP_NAME="\"V$(TOPNAME)\"" -O3 -MMD -Wall
## 过渡方案,关掉c++将字符串常量转换为char*的警告
CFLAGS += -Wno-write-strings
LIBS += $(shell llvm-config --libs) 
LDFLAGS += -lSDL2 -lSDL2_image -lreadline -ldl -pie -fPIE $(LIBS)

IMG ?= $(TEST).bin
ARGS ?= 

#后构建verilator编译规则
gen: $(VSRCS) 
	@rm -rf $(OBJ_DIR)
	@echo "=================== start rtl gen compile ============================"
# @echo "=============================================================="
# @echo $(VSRCS)
# @echo "=============================================================="
	@$(VERILATOR) $(VERILATOR_CFLAGS) -I$(VSRCS_DIR)\
		--top-module $(TOPNAME) $(VSRCS)  --Mdir $(OBJ_DIR)\
		$(addprefix -CFLAGS , $(CFLAGS))
	@echo "=================== start rtl gen finished ==========================="

################################# 未成功方案 #########################################
#
#	本来想完成分步编译的，且指定可执行文件的路径的做法，但目前并没有找到可行方案。
#	尝试过的方式：
#		1、直接在make 后面加 -o path/name
#		2、make -j -C build/obj_dir -f V$(TOPNAME).mk ../V$(TOPNAME) 
#		3、make -j -C build/obj_dir -f V$(TOPNAME).mk abspath/V$(TOPNAME) 	
#
#####################################################################################


$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	@echo "==================== start rtl sim compile ===================="
	@+$(VERILATOR) $(VERILATOR_CFLAGS) \
		-top $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all:
	@echo "Write this Makefile by your self."
#运行编译好的bin文件
sim: $(BIN) 
	@echo "==================== RTL sim finished ===================="
	+$(call git_commit, "sim RTL")
run: sim gentest
	@./$(BIN) $(ARGS) $(IMG)

runb: sim gentest
	@./$(BIN) $(ARGS) -b $(IMG)

# ================================= Code line count =======================================
count:
	find . -path ./build -prune -o \( -name "*.v" -o -name "*.c" -o -name "*.cpp" -o -name "*.hpp" \) -print | xargs wc -l
	
countv:
	find . -name "*.[v]" | xargs wc -l

countc:
	find . -path ./build -prune -o \( -name "*.c" -o -name "*.cpp" -o -name "*.hpp" \) -print | xargs wc -l




# ================================ genTest ====================================
TEST ?= test/addi
RV = riscv64-linux-gnu
gentest: $(TEST).S
	@$(RV)-as $(TEST).S -o $(TEST).o
	@$(RV)-ld $(TEST).o -o $(TEST)
	@$(RV)-objcopy --only-section=.text -O binary $(TEST) $(TEST).bin

wave: runb
	gtkwave dump.vcd dummy.gtkw


.PHOYN: clean count countv countc
.PHOYN: gen sim run runb clean test


clean:
	@rm -rf obj_dir top.vcd
	@rm -rf $(BUILD_DIR)  obj_dir *.vcd
	@find test -type f ! -name "*.S" -delete

include ../Makefile