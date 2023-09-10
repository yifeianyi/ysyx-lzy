#顶层模块名
TOPNAME   = top
VERILATOR = verilator
VERILATOR_CFLAGS += -MMD -cc  --exe \
				 --trace --threads {1} --output-split {1}-Wall 
VERILATOR_CFLAGS += -Wno-fatal		# only print lint warning, but not terminate compile.

#默认运行bin
default: sim

VSRCS = top.v ysyx_22041405_IFU.v
CSRCS = sim_main.cpp 
BIN   = obj_dir/V$(TOPNAME)
#后构建verilator编译规则
gen: $(VSRCS) $(CSRCS)
	@echo "=================== start rtl gen compile ============================"
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $(VSRCS) $(CSRCS)
	@echo "=================== start rtl gen finished ==========================="

$(BIN): $(VSRCS) $(CSRCS)
	@echo "==================== start rtl sim compile ===================="
	@+$(VERILATOR) $(VERILATOR_CFLAGS) --build \
		--top-module $(TOPNAME) $(VSRCS) $(CSRCS)
#运行编译好的bin文件
sim: $(BIN) 
	@echo "==================== RTL sim finished ===================="
	@./$(BIN) 

clean:
	 rm -rf build  obj_dir *.vcd

.PHOYN: gen sim run clean 