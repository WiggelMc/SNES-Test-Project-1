#!/usr/bin/make -f
#
# Makefile for LoROM template
# Copyright 2014-2015 Damian Yerrick
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#

# These are used in the title of the SFC program and the zip file.
title = lorom-template
version = 0.06


# Space-separated list of asm files without .s extension
# (use a backslash to continue on the next line)
objlist = \
  snesheader init main bg player \
  ppuclear blarggapu spcimage musicseq
objlistspc = \
  spcheader spcimage musicseq
	
#Dependencies for spc-list will not be automatically loaded
	

AS65 := ca65
LD65 := ld65
objdir := obj/snes
lstdir := lst/snes
depdir := dependencies/snes
srcdir := src
imgdir := tilesets

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

# If it's not bsnes, it's just BS.  But I acknowledge that being
# stuck on an old Atom laptop is BS.  Atom N450 can't run bsnes at
# full speed, but the Atom-based Pentium N3710 can.
ifndef SNESEMU
#SNESEMU := xterm -e zsnes -d

SNESEMU := EmuHawk
endif
SNESEMUALT := Mesen-S_ozihack

# game-music-emu by blargg et al.
# Using paplay-based wrapper from
# https://forums.nesdev.com/viewtopic.php?f=6&t=16218
SPCPLAY := gmeplay

ifdef COMSPEC
PY := py.exe
else
PY :=
endif

# Calculate the current directory as Wine applications would see it.
# yep, that's 8 backslashes.  Apparently, there are 3 layers of escaping:
# one for the shell that executes sed, one for sed, and one for the shell
# that executes wine
# TODO: convert to use winepath -w
wincwd := $(shell pwd | sed -e "s'/'\\\\\\\\'g")

# .PHONY means these targets aren't actual filenames
.PHONY: all run nocash-run spcrun dist clean

# When you type make without a target name, make will try
# to build the first target.  So unless you're trying to run
# NO$SNS in Wine, you should move run above nocash-run.



run: $(title).sfc
	$(SNESEMU) $(mkfile_dir)$<
	
run-m: $(title).sfc
	$(SNESEMUALT) $(mkfile_dir)$<

build-only: $(title).sfc
	echo "BUILD COMPLETE:" $<

load-only:
	$(SNESEMU) $(mkfile_dir)$(title).sfc

load-only-m:
	$(SNESEMUALT) $(mkfile_dir)$(title).sfc



# Per Martin Korth on 2014-09-16: NO$SNS requires absolute
# paths because he screwed up and made the filename processing
# too clever.
# Not default
nocash-run: $(title).sfc
	wine "C:\\Program Files (x86)\\nocash\\no\$$sns.exe" "Z:$(wincwd)\\$(title).sfc"

# Special target for just the SPC700 image
spcrun: $(title).spc
	$(SPCPLAY) $<

all: $(title).sfc $(title).spc

clean:
	-rm $(objdir)/*.o $(objdir)/*.chrsfc $(objdir)/*.chrgb
	-rm $(objdir)/*.wav $(objdir)/*.brr $(objdir)/*.s
	-rm $(objdir)/*.lst $(lstdir)/*.lst $(depdir)/*.d

dist: zip
zip: $(title)-$(version).sc.zip
$(title)-$(version).sc.zip: zip.in all README.md $(objdir)/index.txt $(lstdir)/index.txt $(depdir)/index.txt
	$(PY) tools/zipup.py $< $(title)-$(version).sc -o $@
	#-advzip -z3 $@

# Build zip.in from the list of files in the Git tree
zip.in:
	git ls-files | grep -e "^[^.]" > $@
	echo zip.in >> $@
	echo $(title).sfc >> $@
	echo $(title).spc >> $@

$(objdir)/index.txt $(lstdir)/index.txt $(depdir)/index.txt: makefile
	echo "Files produced by build tools go here. (This file's existence forces the unzip tool to create this folder.)" > $@

# Rules for ROM

#Generate INCLUDE LIST FILES
.PRECIOUS: $(depdir)/%.d
$(depdir)/%.d: $(srcdir)/%.s
	$(PY) tools/generatedependencies.py $< $@ $(objdir)/$(*F).o

objlisto = $(foreach o,$(objlist),$(objdir)/$(o).o)
objlistospc = $(foreach o,$(objlistspc),$(objdir)/$(o).o)

map.txt $(title).sfc: lorom256k.cfg $(objlisto)
	$(LD65) -o $(title).sfc --dbgfile $(title).dbg -m map.txt -C $^
	$(PY) tools/fixchecksum.py $(title).sfc

spcmap.txt $(title).spc: spc.cfg $(objlistospc)
	$(LD65) -o $(title).spc -m spcmap.txt -C $^


$(objdir)/%.o: $(srcdir)/%.s $(depdir)/%.d
	$(AS65) -l $(lstdir)/$(*F).lst -g $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(AS65) -l $(lstdir)/$(*F).lst -g $< -o $@

# Rules for CHR data

# .chrgb (CHR data for Game Boy) denotes the 2-bit tile format
# used by Game Boy and Game Boy Color, as well as Super NES
# mode 0 (all planes), mode 1 (third plane), and modes 4 and 5
# (second plane).
$(objdir)/%.chrgb: tilesets/%.png
	$(PY) tools/pilbmp2nes.py --planes=0,1 $< $@

$(objdir)/%.chrsfc: tilesets/%.png
	$(PY) tools/pilbmp2nes.py "--planes=0,1;2,3" $< $@

# Rules for audio
$(objdir)/%.brr: audio/%.wav
	$(PY) tools/wav2brr.py $< $@
$(objdir)/%.brr: $(objdir)/%.wav
	$(PY) tools/wav2brr.py $< $@
$(objdir)/%loop.brr: audio/%.wav
	$(PY) tools/wav2brr.py --loop $< $@
$(objdir)/%loop.brr: $(objdir)/%.wav
	$(PY) tools/wav2brr.py --loop $< $@
$(objdir)/karplusbass.wav: tools/karplus.py
	$(PY) $< -o $@ -n 1024 -p 64 -r 4186 -e square:1:4 -a 30000 -g 1.0 -f .5
$(objdir)/hat.wav: tools/makehat.py
	$(PY) $< $@


#Load INCLUDE LIST FILES
-include $(foreach o,$(objlist),$(depdir)/$(o).d)