GNATMAKE=gnatmake-7.3.1
GNATBIND=gnatbind-7.3.1
GNATLINK=gnatlink-7.3.1
all:
	$(GNATMAKE) -g -c ./memory_manager_test.adb -I.. -A../../ada-libs/florist_3.5.0_20040403.src/floristlib -A../../ada-libs/bc-20160321/src
	$(GNATBIND) ./memory_manager_test -aO../ -aO../../ada-libs/florist_3.5.0_20040403.src/floristlib -aO../../ada-libs/bc-20160321/src
	$(GNATLINK) memory_manager_test -I../../ada-libs/florist_3.5.0_20040403.src -I.. -lflorist -A../../ada-libs/florist_3.5.0_20040403.src/floristlib ../malloc.o -A../../ada-libs/bc-20160321/src

clean:
	rm *.o *.ali

