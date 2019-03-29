# Copyright (C) Simon Wright <simon@pushface.org>.
#
#      This program is free software; you can redistribute it
#      and/or modify it under the terms of the Ada Community
#      License which comes with this Library.
#
#      This program is distributed in the hope that it will be
#      useful, but WITHOUT ANY WARRANTY; without even the implied
#      warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#      PURPOSE. See the Ada Community License for more details.
#      You should have received a copy of the Ada Community
#      License with this library, in the file named "Ada Community
#      License" or "ACL". If not, contact the author of this library
#      for a copy.
#

# $Id$

# (GNU) Makefile for demos of Booch Components distribution.

########
# Demos

ifneq (, $(findstring CYGWIN, $(sys)))
  EXE = .exe
else
  EXE =
endif

GNATMAKE = gnatmake

#####################
# Default build rule
%$(EXE): %.adb
	$(GNATMAKE) -Pdemos $<

all:: demos

DEMOS += ada_units$(EXE)
DEMO_SRC += ada_units.adb ada_unit_support.ad[bs]
ada_units$(EXE): force

DEMOS += configuration_demo$(EXE)
DEMO_SRC += configuration_demo.adb configuration_demo_support.ad[bs]
configuration_demo$(EXE): force

DEMOS += lists_traversal$(EXE)
DEMO_SRC += lists_traversal.adb lists_for_traversal.ad[bs]
lists_traversal$(EXE): force

DEMOS += ordering_test$(EXE)
DEMO_SRC += ordering_test.adb ordering_support.ad[bs]
ordering_test$(EXE): force

DEMOS += storage$(EXE)
DEMO_SRC += storage.adb
storage$(EXE): force

DEMOS += storage_timing$(EXE)
DEMO_SRC += storage_timing.adb storage_timing_support.ads
storage_timing$(EXE): force

DEMOS += test_synchronization$(EXE)
DEMO_SRC += test_synchronization.adb
test_synchronization$(EXE): force

DEMOS += time_change$(EXE)
DEMO_SRC += time_change.adb
time_change$(EXE): force

DEMOS += time_collections$(EXE)
DEMO_SRC += time_collections.adb collection_test_support.ads
time_collections$(EXE): force

DEMOS += time_lists$(EXE)
DEMO_SRC += time_lists.adb lists_for_timing.ads
time_lists$(EXE): force

DEMOS += time_queues$(EXE)
DEMO_SRC += time_queues.adb queues_for_timing.ads
time_queues$(EXE): force

DEMOS += user_map$(EXE)
DEMO_SRC += user_map.adb user_map_support.ad[bs]
user_map$(EXE): force

DEMOS += user_set$(EXE)
DEMO_SRC += user_set.adb user_set_support.ad[bs]
user_set$(EXE): force

DEMOS += word_count$(EXE)
DEMO_SRC += bcwords.ada
word_count$(EXE): bcwords.ada force
	gnatchop -r -w bcwords.ada
	$(GNATMAKE) -Pdemos word_count

DEMO_SRC += global_heap.ads

demos: .build $(DEMOS)

dist:
	mkdir $(DIST)/demos
	cp $(DEMO_SRC) Makefile demos.gpr $(DIST)/demos/ 

.build:
	mkdir .build

.PHONY: force
