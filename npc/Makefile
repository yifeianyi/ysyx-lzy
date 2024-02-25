#顶层模块名
TOPNAME   =rv_percpu
INC_PATH := $(abspath $(shell find ./csrc/include -type d -print | grep -v '/\.'))

#verilator的编译选项
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD -cc  --exe
VERILATOR_CFLAGS +=	-O3 --x-assign fast --x-initial fast 
VERILATOR_CFLAGS += --trace --output-split {1}-Wall #--threads {1}
VERILATOR_CFLAGS += -Wno-fatal		# only print lint warning, but not terminate compile.
VERILATOR_CFLAGS += -Wno-UNUSED 		# close <unused> warning.
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
# BIN = $(OBJ_DIR)/V$(TOPNAME)
BIN = $(BUILD_DIR)/V$(TOPNAME)

#默认运行bin
default: sim
#创建build/obj_dir编译目录
$(shell mkdir -p $(BUILD_DIR))

VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")


#verilator的一些添加标志，top名，链接库，反汇编
CFLAGS += $(addprefix -I, $(INC_PATH)) -DTOP_NAME="\"V$(TOPNAME)\"" -O3 -MMD -Wall
LIBS += $(shell llvm-config --libs) 
LDFLAGS += -lSDL2 -lSDL2_image -lreadline -ldl -pie -fPIE $(LIBS)

IMG ?=
ARGS ?=

#后构建verilator编译规则
gen: $(VSRCS) 
	@rm -rf $(OBJ_DIR)
	@echo "=================== start rtl gen compile ============================"
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		-I$(VSRCS)\
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
# $(BIN):  $(OBJ_DIR)
# # make gen
# 	@echo "==================== start rtl sim compile ===================="
# 	make -j -C build/obj_dir -f V$(TOPNAME).mk V$(TOPNAME)  


$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	@echo "==================== start rtl sim compile ===================="
	@+$(VERILATOR) $(VERILATOR_CFLAGS) --build \
		--top-module $(TOPNAME) $(VSRCS) $(CSRCS) \
		$(addprefix -CFLAGS , $(CFLAGS))  $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

nemu:
	$(MAKE) -C $(NEMU_HOME) ARCH=riscv32-nemu -j

nemu-clean:
	$(MAKE) -C $(NEMU_HOME) clean

all:
	@echo "Write this Makefile by your self."
#运行编译好的bin文件
sim: $(BIN) 
	@echo "==================== RTL sim finished ===================="
	+$(call git_commit, "sim RTL")
	@./$(BIN) $(ARGS)

# ================================= Code line count =======================================
count:
	find . -name "*.[cvh]" | xargs wc -l

countv:
	find . -name "*.[v]" | xargs wc -l

countc:
	find . -name "*.[ch]" | xargs wc -l

clean:
	@rm -rf obj_dir top.vcd
	 rm -rf $(BUILD_DIR)  obj_dir *.vcd

.PHOYN: gen sim run clean count countv countc
include ../Makefile