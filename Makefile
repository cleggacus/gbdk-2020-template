
#
# A Makefile that compiles all .c and .s files in "src" and "res" 
# subdirectories and places the output in a "obj" subdirectory
#

# If you move this project you can change the directory 
# to match your GBDK root directory (ex: GBDK_HOME = "C:/GBDK/"
ifndef GBDK_HOME
	GBDK_HOME = ../../../
endif

LCC = $(GBDK_HOME)bin/lcc 

# GBDK_DEBUG = ON
ifdef GBDK_DEBUG
	LCCFLAGS += -debug -v
endif

# You can set the name of the .gb ROM file here
PROJECTNAME = Example

SRCDIR      = src
OBJDIR      = obj
RESDIR      = res
BINS        = $(OBJDIR)/$(PROJECTNAME).gb
CSOURCES    = $(foreach dir,$(SRCDIR),$(wildcard $(dir)/*.c)) $(foreach dir,$(RESDIR),$(wildcard $(dir)/*.c))
ASMSOURCES  = $(foreach dir,$(SRCDIR),$(wildcard $(dir)/*.s))
OBJS        = $(patsubst %.c,$(OBJDIR)/%.o,$(CSOURCES)) $(patsubst %.s,$(OBJDIR)/%.o,$(ASMSOURCES))

all: prepare $(BINS) generate_compile_commands

compile.bat: Makefile
	@echo "REM Automatically generated from Makefile" > compile.bat
	@make -sn | sed y/\\//\\\\/ | sed s/mkdir\ -p\/mkdir\/ | grep -v make >> compile.bat

# Define a generic rule for compiling .c files from any source directory
$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@)  # Create necessary directories
	$(LCC) $(LCCFLAGS) -c -o $@ $<

# Define a generic rule for compiling .s files from any source directory
$(OBJDIR)/%.o: %.s
	@mkdir -p $(dir $@)  # Create necessary directories
	$(LCC) $(LCCFLAGS) -c -o $@ $<

# If needed, compile .c files to .s assembly files (not required if .c is compiled directly to .o)
$(OBJDIR)/%.s: %.c
	@mkdir -p $(dir $@)  # Create necessary directories
	$(LCC) $(LCCFLAGS) -S -o $@ $<

# Link the compiled object files into a .gb ROM file
$(BINS): $(OBJS)
	$(LCC) $(LCCFLAGS) -o $(BINS) $(OBJS)

prepare:
	mkdir -p $(OBJDIR)

generate_compile_commands:
	GBDK_HOME=$(GBDK_HOME) sh generate_compile_commands.sh

clean:
	rm -rf $(OBJDIR)/*

