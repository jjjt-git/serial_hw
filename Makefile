GHDL := ghdl
RM := rm -rf

GHDLOPTS := --std=02

MODULES := $(wildcard *.vhd)
OBJECTS := $(MODULES:.vhd=.o)
DEPS := $(MODULES:.vhd=.d)

TESTBENCHES := $(patsubst %.vhd,%,$(wildcard tb_*.vhd))
TB_RUN_TRGS := $(addprefix run_,$(TESTBENCHES))

MODULES_IMPORT_TRGS := $(addprefix import_,$(MODULES))

.PHONY: all run clear $(TB_RUN_TRGS) $(MODULES_IMPORT_TRGS)
all: $(OBJECTS)

run: $(TB_RUN_TRGS)
$(TB_RUN_TRGS): run_%: %
	ghdl -r $* --wave=$*.ghw

clear:
	$(RM) $(subst .o,,$(OBJECTS)) *.o *.cf *.d *.ghw

$(OBJECTS): %.o: %.vhd $(MODULES_IMPORT_TRGS)
	$(GHDL) -a $(GHDLOPTS) $<

$(TESTBENCHES): %: %.o
	$(GHDL) -m $(GHDLOPTS) $@

$(MODULES_IMPORT_TRGS): import_%: %
	$(GHDL) -i $(GHDLOPTS) $*

