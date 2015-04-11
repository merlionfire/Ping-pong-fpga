#-----------------------------------------------------------------------------
#
# Filename    : Makefile
#
# Created by  : $Merlionfire$
#               21/06/2012 # 
# Description : Compile the files at and below this level   
#
#-----------------------------------------------------------------------------

TB_BUILD_FLAG = on 


COMPILER = vlog 
#COMPILER = vcs -full64
RTL_FILES = -f rtl.f 
LIB_DIR =   
#TB_FILES = ../tb/tb_vga_top.v 
MODEL_FILES = 
#ifeq ( $(TB_BUILD_FLAG), on ) 
   ALL_FILES = $(TB_FILES) $(RTL_FILES) $(MODEL_FILES) 
#else	
#   ALL_FILES = $(RTL_FILES)  
#endif

# -----------------------------   Code Coverage   ----------------------------
COVER_TYPE   = +cover=sbcef
COVER_REPORT_FILE  = ping_pong_cov.txt 
COVER_REPORT_HTML_DIR  = ping_pong_cov_report_html 
UCDB_FILE    = ping_pong_cov.ucdb 
COVER_OPT    = -coverage 
# ------------------------------------------------ ----------------------------
  
OPT =  +v2k -sv -novopt +define+SIM+SVA $(COVER_TYPE) +libext+.v+.h+.vh $(LIB_DIR) +incdir+../rtl  -l build.log     
#OPT =  +v2k -novopt +define+SIM+SVA $(COVER_TYPE) +libext+.v+.h+.vh $(LIB_DIR) +incdir+../rtl  -l build.log     

INC = 

#RUN = vsim -pli libpli.so  -novopt -c testbench -L xilinx_XilinxCoreLib  -L xilinx_unisims -L xilinx_simprims  work.glbl  -do "nolog -all ; run -all ; quit" 
RUN = vsim -l cosim.log -wlftlim 1 -pli libpli.so  -novopt $(COVER_OPT) -c testbench -L xilinx_XilinxCoreLib  -L xilinx_unisims -L xilinx_simprims  \
		-do "nolog -all ; coverage save -onexit $(UCDB_FILE)  ; run -all ; quit" 

default : help 

comp : 
	$(COMPILER) $(OPT) $(ALL_FILES)    
	vericom -sverilog -2001 -nolog  +define+SIM -lib work.verdi $(ALL_FILES)  +libext+.v+.h+.vh +incdir+../rtl $(LIB_DIR)  
run : 
	$(RUN)  
verdi : 
	verdi -2001 +defin+SIM -lib work.verdi  -ssf cosim_verdi.fsdb -top testbench -nologo &
nlint : 
	 nLint  -gui
cover_report_txt  : 
	vcover report -detail $(UCDB_FILE) -output $(COVER_REPORT_FILE)   
cover_report_html  : 
	vcover report -html -htmldir $(COVER_REPORT_HTML_DIR)  $(UCDB_FILE)    
help : 
	@echo "==================== HELP ====================="
	@echo "comp        : Compiles everything with debugger"
	@echo "==============================================="
	@echo "run         : Run simulation                   "
	@echo "==============================================="
	@echo "help        : Print help information           "
	@echo "            : This is default parameter        "
	@echo "=============================================================="
	@echo "cover_report_html: Create code coverage report in htlm format "
	@echo "=============================================================="
	@echo "nlint       : invoke nlint gui                 "
	@echo "==============================================="
	@echo ""
	@echo ""

