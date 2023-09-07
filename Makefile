CC = gcc
RM = rm -f
CP = cp
CHMOD = chmod
GLPATH = /glftpd/bin
ETCPATH = /glftpd/etc
MAKE = make

CCFLAGS = -O2 -Wall

all: 	clean compile

compile:
		${CC} ${CCFLAGS} -o addaffil addaffil.c
		${CC} ${CCFLAGS} -o delaffil delaffil.c

clean:
	$(RM) addaffil delaffil

install:
	@ echo "Copying the compiled files and conf to ${GLPATH} ..."
	${CP} addaffil ${GLPATH}
	${CP} addaffil.sh ${GLPATH}
	${CP} addgrp.sh ${GLPATH}
	${CP} delgrp.sh ${GLPATH}
	${CP} delaffil ${GLPATH}
	${CP} delaffil.sh ${GLPATH}
	${CP} pre.sh ${GLPATH}
	${CP} rg-pre.conf ${ETCPATH}
	${CP} getmp3preinfo.sh ${GLPATH}
	${CP} getmvpreinfo.sh ${GLPATH}
	${CHMOD} +x ${GLPATH}/addaffil
	${CHMOD} +x ${GLPATH}/delaffil
	${CHMOD} +x ${GLPATH}/addaffil.sh
	${CHMOD} +x ${GLPATH}/delaffil.sh
	${CHMOD} +x ${GLPATH}/pre.sh
	${CHMOD} +x ${GLPATH}/getmp3preinfo.sh
	${CHMOD} +x ${GLPATH}/getmvpreinfo.sh
	@ echo "Done."
	@ echo "Add addaffil.sh, delaffil.sh, listaffils.sh to be custom glftpd commands."
	@ echo "Set your sitebot to announce pres logged by pre.sh and to show affils using listaffils.sh"
	@ echo "All the installation information is located in the README file, please read it."
	@ echo "Enjoy!"

update:
	@ echo "Copying the compiled files to ${GLPATH} ..."
	${CP} addaffil ${GLPATH}
	${CP} addaffil.sh ${GLPATH}
	${CP} addgrp.sh ${GLPATH}
	${CP} delgrp.sh ${GLPATH}
	${CP} delaffil ${GLPATH}
	${CP} delaffil.sh ${GLPATH}
	${CP} pre.sh ${GLPATH}
	${CP} getmp3preinfo.sh ${GLPATH}
	${CP} getmvpreinfo.sh ${GLPATH}
	${CHMOD} +x ${GLPATH}/addaffil
	${CHMOD} +x ${GLPATH}/delaffil
	${CHMOD} +x ${GLPATH}/addgrp.sh
	${CHMOD} +x ${GLPATH}/addaffil.sh
	${CHMOD} +x ${GLPATH}/delaffil.sh
	${CHMOD} +x ${GLPATH}/delgrp.sh
	${CHMOD} +x ${GLPATH}/pre.sh
	${CHMOD} +x ${GLPATH}/getmp3preinfo.sh
	${CHMOD} +x ${GLPATH}/getmvpreinfo.sh
	@ echo "Done."