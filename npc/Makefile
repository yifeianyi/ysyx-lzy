
export PRJ_PATH=$(shell pwd)/..
#多核处理，这个地方只能手动指定，不清楚原因
export MAKEFLAGS += -j1 --no-print-directory
#顶层模块名
TOPNAME   =top
INC_PATH := $(abspath $(shell find ./csrc/include -type d -print | grep -v '/\.'))

#开启多线程的话无法批处理一群函数，因为多输入问题会一起执行导致报错
#verilator的编译选项
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD -cc  --exe \
				-O3 --x-assign fast --x-initial fast --trace --threads {1} --output-split {1}-Wall 
VERILATOR_CFLAGS += -Wno-fatal		# only print lint warning, but not terminate compile.
# VERILATOR_CFLAGS += -Wno-UNUSED 		# close <unused> warning.
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
# BIN = $(OBJ_DIR)/V$(TOPNAME)
BIN = $(BUILD_DIR)/V$(TOPNAME)

#默认运行bin
default: sim
#创建build/obj_dir编译目录
$(shell mkdir -p $(BUILD_DIR))

#相关文件资源的搜索路径，.v中只能强制指定不然宏定义失败 
VSRCS = ./vsrc/*.v ./vsrc/*/*.v   ./vsrc/*/*/*.v
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

#verilator的一些添加标志，top名，链接库，反汇编
CFLAGS += $(addprefix -I, $(INC_PATH)) -DTOP_NAME="\"V$(TOPNAME)\"" -O3 -MMD -Wall
LIBS += $(shell llvm-config --libs) 
LDFLAGS += -lSDL2 -lSDL2_image -lreadline -ldl -pie -fPIE $(LIBS)

#loadbin
IMG ?=

#后构建verilator编译规则
gen: $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	@echo "=================== start rtl gen compile ============================"
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $(VSRCS) $(CSRCS) --Mdir $(OBJ_DIR)\
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

	
all:
	@echo "Write this Makefile by your self."
#运行编译好的bin文件
sim: $(BIN) 
	@echo "==================== RTL sim finished ===================="
	+$(call git_commit, "sim RTL")
	@./$(BIN) 

# ================================= Code line count =======================================
count:
	find . -name "*.[cv]" | xargs wc -l

countv:
	find . -name "*.[v]" | xargs wc -l

countc:
	find . -name "*.[c]" | xargs wc -l



clean:
	@rm -rf obj_dir top.vcd
	 rm -rf $(BUILD_DIR)  obj_dir *.vcd

.PHOYN: gen sim run clean count countv countc
include ../Makefile