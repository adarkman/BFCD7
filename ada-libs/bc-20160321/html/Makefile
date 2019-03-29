# Copyright (C) Simon Wright <simon@pushface.org>.

# This package is free software; you can redistribute it and/or
# modify it under terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or
# (at your option) any later version. This package is distributed in
# the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU General Public License for more
# details. You should have received a copy of the GNU General Public
# License distributed with this package; see file COPYING.  If not,
# write to the Free Software Foundation, 59 Temple Place - Suite
# 330, Boston, MA 02111-1307, USA.

# (GNU) Makefile for Booch Components documentation.

all::

FILES = Makefile *.{css,html,gif,jpg,png} x.ada coldframe-hash.{tgz,zip}

dist:
	mkdir $(DIST)/html
	tar cf - $(FILES) | (cd $(DIST)/html; tar xvf -)

############################
# Documentation upload to SF

ifeq (${USER},martin)
    SFUSER	   ?= krischik
else ifeq (${USER},simon)
    SFUSER	   ?= simonjwright
else
    SFUSER         ?= nobody
endif

upload-docs: force
	rsync						\
	  --compress					\
	  --copy-unsafe-links				\
	  --cvs-exclude					\
	  --perms					\
	  --recursive					\
	  --rsh=ssh					\
	  --times					\
	  --update					\
	  --verbose					\
	  $(FILES)					\
	  $(SFUSER),booch95@web.sourceforge.net:htdocs/

.PHONY: force

#vim: textwidth=0 nowrap tabstop=8 shiftwidth=4 softtabstop=4 noexpandtab
#vim: filetype=make encoding=utf-8 fileformat=unix
