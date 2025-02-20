include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME                  = NoteBook
PACKAGE_NAME              = NoteBook
NoteBook_PRINCIPAL_CLASS  = NSApplication
NoteBook_APPLICATION_ICON = NoteBook.png
NoteBook_VERSION          = 0.3

#
# Resource Files
#

NoteBook_MAIN_MODEL_FILE = NoteBookApp.gorm

NoteBook_RESOURCE_FILES = \
	NoteBook.png \
	NoteBookInfo.plist

NoteBook_LOCALIZED_RESOURCE_FILES = \
	NoteBookApp.gorm \
	Page.gorm \
	PageName.gorm

NoteBook_LANGUAGES = \
	English

#
# Source
#

NoteBook_HEADER_FILES = \
	BrowserDelegate.h \
	Controller.h \
	Page.h \
	PageNameController.h

NoteBook_OBJC_FILES = \
	BrowserDelegate.m \
	Controller.m \
	Page.m \
	PageNameController.m \
	main.m

#ADDITIONAL_CFLAGS = -Wall
#ADDITIONAL_OBJCFLAGS = -Wall

include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
