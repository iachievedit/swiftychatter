all:	chatterserver chatterclient

chatterserver:
	swift build --chdir chatterserver

chatterclient:
	swift build --chdir chatterclient

clean:
	swift build --chdir chatterserver -k
	swift build --chdir chatterclient -k

distclean:	clean
	rm -rf chatterserver/Packages
	rm -rf chatterclient/Packages
	

.PHONY:	chatterserver chatterclient
