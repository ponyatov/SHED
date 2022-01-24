# \ var
MODULE   = $(notdir $(CURDIR))
OS       = $(shell uname -s)
NOW      = $(shell date +%d%m%y)
REL      = $(shell git rev-parse --short=4 HEAD)
BRANCH   = $(shell git rev-parse --abbrev-ref HEAD)
SHADOW  ?= shadow
PACKAGE ?= io.github.ponyatov
# / var

# \ dir
CWD      = $(CURDIR)
BIN      = $(CWD)/bin
DOC      = $(CWD)/doc
LIB      = $(CWD)/lib
SRC      = $(CWD)/src
TMP      = $(CWD)/tmp
# / dir

# \ version
VERSION ?= 0.0.1
GJF_VER  = 1.13.0
# / version

# \ jar
GJF_JAR  = google-java-format-$(GJF_VER)-all-deps.jar
# / jar

# \ tool
CURL     = curl -L -o
CF       = clang-format-11
MAVEN    = mvn
JAVA     = java
JAVAC    = javac
GJF      = $(JAVA) -jar bin/$(GJF_JAR) --replace
# / tool

# \ src
J += $(shell find src -type f -regex ".+.java$$")
S += $(J)
# / src

# \ bin
CLASS = $(shell echo $(J) | sed "s/src/bin/" | sed "s/.java/.class/")
# / bin

.PHONY: all
all: $(CLASS)
	java -cp bin $(MODULE)

tmp/format_java: $(J)
	$(CF) -i -style=file $? && touch $@

# \ rule
bin/%.class: src/%.java Makefile
	$(JAVAC) -d bin $< && $(MAKE) tmp/format_java
# / rule

# \ doc
.PHONY: doxy
doxy:
	rm -rf docs ; doxygen doxy.gen 1>/dev/null

.PHONY: doc
doc:
# / doc

# \ install
.PHONY: install update
install: doc gz
	$(MAKE) update
update: $(OS)_update

.PHONY: Linux_install Linux_update
Linux_install Linux_update:
ifneq (,$(shell which apt))
	sudo apt update
	sudo apt install -u `cat apt.txt`
endif

# \ gz
.PHONY: gz
gz: bin/$(GJF_JAR)

GJF_URL = https://github.com/google/google-java-format/releases/download/v$(GJF_VER)/$(GJF_JAR)
bin/$(GJF_JAR):
	$(CURL) $@ $(GJF_URL)
# / gz
# / install

# \ merge
MERGE  = Makefile README.md apt.dev apt.txt $(S)
MERGE += .gitignore .clang-format doxy.gen
MERGE += .vscode bin doc lib src tmp

.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout $(SHADOW) -- $(MERGE)

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow
# / merge
