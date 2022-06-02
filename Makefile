OBJS = \
	addlibrary.prg \
	addreference.prg \
	addsymbol.prg \
	chartoupper.prg \
	checkmap.prg \
	checkreq.prg \
	checkvram.prg \
	crlf.prg \
	data.prg \
	dispsymbols.prg \
	dolibs.prg \
	dolink.prg \
	errors.prg \
	findreference.prg \
	findrequire.prg \
	findsymbol.prg \
	gethex.prg \
	ishex.prg \
	loadfile.prg \
	outhex2.prg \
	outhex4.prg \
	outputbinary.prg \
	outputelfos.prg \
	outputintel.prg \
	outputrcs.prg \
	processcl.prg\
	prune.prg \
	readcontrol.prg \
	readln.prg \
	readmap.prg \
	readmem.prg \
	readmemb.prg \
	refcount.prg \
	setmap.prg \
	setup.prg \
	setvram.prg \
	showunres.prg \
	start.prg \
	strcasecmp.prg \
        strcat.prg \
	strcmp.prg \
	strcpy.prg \
	strcpyinline.prg \
	strncasecmp.prg \
	strncmp.prg \
	trim.prg \
	writemap.prg \
	writemem.prg \
	writememb.prg

.SUFFIXES: .asm .prg

link02.bin: $(OBJS) link02.link
	link02 @link02.link

.asm.prg:
	asm02 -l -L $<

clean:
	rm *.prg
	rm *.lst
	rm *.bin

addlibrary.prg:    macros.inc addlibrary.asm
addreference.prg:  macros.inc addreference.asm
addsymbol.prg:     macros.inc addsymbol.asm
chartoupper.prg:   macros.inc chartoupper.asm
checkmap.prg:      macros.inc checkmap.asm
checkreq.prg:      macros.inc checkreq.asm
checkvram.prg:     macros.inc checkvram.asm
crlf.prg:          macros.inc crlf.asm
data.prg:          macros.inc data.asm
dispsymbols.prg:   macros.inc dispsymbols.asm
dolibs.prg:        macros.inc dolibs.asm
dolink.prg:        macros.inc dolink.asm
errors.prg:        macros.inc errors.asm
findreference.prg: macros.inc findreference.asm
findrequire.prg:   macros.inc findrequire.asm
findsymbol.prg:    macros.inc findsymbol.asm
gethex.prg:        macros.inc gethex.asm
ishex.prg:         macros.inc ishex.asm
loadfile.prg:      macros.inc loadfile.asm
outhex2.prg:       macros.inc outhex2.asm
outhex4.prg:       macros.inc outhex4.asm
outputbinary.prg:  macros.inc outputbinary.asm
outputelfos.prg:   macros.inc outputelfos.asm
outputintel.prg:   macros.inc outputintel.asm
outputrcs.prg:     macros.inc outputrcs.asm
processcl.prg:     macros.inc processcl.asm
prune.prg:         macros.inc prune.asm
readcontrol.prg:   macros.inc readcontrol.asm
readln.prg:        macros.inc readln.asm
readmap.prg:       macros.inc readmap.asm
readmem.prg:       macros.inc readmem.asm
readmemb.prg:      macros.inc readmemb.asm
refcount.prg:      macros.inc refcount.asm
setmap.prg:        macros.inc setmap.asm
setup.prg:         macros.inc setup.asm
setvram.prg:       macros.inc setvram.asm
showunres.prg:     macros.inc showunres.asm
start.prg:         macros.inc start.asm
strcasecmp.prg:    macros.inc strcasecmp.asm
strcat.prg:        macros.inc strcat.asm
strcmp.prg:        macros.inc strcmp.asm
strcpy.prg:        macros.inc strcpy.asm
strcpyinline.prg:  macros.inc strcpyinline.asm
strncasecmp.prg:   macros.inc strncasecmp.asm
strncmp.prg:       macros.inc strncmp.asm
tablesearch.prg:   macros.inc tablesearch.asm
trim.prg:          macros.inc trim.asm
writemap.prg:      macros.inc writemap.asm
writemem.prg:      macros.inc writemem.asm
writememb.prg:     macros.inc writememb.asm
