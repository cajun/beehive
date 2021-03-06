LIBDIR					= $(shell erl -eval 'io:format("~s~n", [code:lib_dir()])' -s init stop -noshell)
VERSION					= $(shell cat VERSION | tr -d '\n')
CC							= erlc
ERL							= erl
EBIN						= ebin
INCLUDE_DIRS 		= include
EBIN_DIRS				= -pa $(EBIN) -pz $(wildcard deps/*/ebin) -pz $(wildcard include/*/ebin)
CFLAGS					= +debug_info -W0 -I $(INCLUDE_DIRS) $(EBIN_DIRS) -noinput +B
ECOMPILE        = $(ERL) $(CFLAGS)
DEPS_DIR 				= deps
TEST_DIR				= test
TEST_EBIN_DIR		= $(TEST_DIR)/ebin
APP							= beehive
BIN_DIR					= $(PREFIX)/usr/bin
TARGET_DIR			= $(PREFIX)/$(LIBDIR)/$(APP)-$(VERSION)
SCRIPTS					= beehive_env queen start_beehive

RELFILE = $(EBIN)/$(APP)-$(VERSION).rel

all: compile boot
  
deps: mochi babysitter

babysitter:
	@(cd deps/babysitter;$(MAKE))

babysitter_install:
	@(cd deps/babysitter;$(MAKE) boot)

mochi:
	@(cd deps/mochiweb;$(MAKE))

boot:
	(cd ebin; $(ECOMPILE) -noshell -run make_boot write_scripts beehive $(VERSION) router $(VERSION) storage $(VERSION) bee $(VERSION);)
	
compile: $(TEST_EBIN_DIR) deps
	@$(ECOMPILE) -eval 'case make:all() of up_to_date -> halt(0); error -> halt(1) end.'
	
debug: $(TEST_EBIN_DIR)
	@$(ECOMPILE) -eval 'case make:all([{d, debug}]) of up_to_date -> halt(0); error -> halt(1) end.'

test: compile
	$(ECOMPILE)	-noshell \
					-pa $(EBIN_DIRS) \
					-pa $(TEST_EBIN_DIR) \
					-s test_suite test \
					-s init stop

install: compile boot babysitter_install
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(TARGET_DIR)/bin
	@mkdir -p $(PREFIX)/var/lib/beehive/db
	@mkdir -p $(PREFIX)/var/log/beehive
	
	@cp -r ebin src app_templates include ./../../LICENSE deps $(TARGET_DIR)
	# for i in ebin/*.beam; do install $$i $(TARGET_DIR)/$$i; done
	
	# copy the shell templates to the beehive home
	@cp -r shell_templates $(PREFIX)/var/lib/beehive
	
	if [ ! -n $$BEEHIVE_USER ]; then chown -R $(PREFIX)/var/lib/beehive/ ./; fi
	if [ ! -n $$BEEHIVE_USER ]; then chown -R $(PREFIX)/var/log/beehive/ ./; fi
	
	chmod 0755 scripts/*
	for i in $(SCRIPTS); do install scripts/$$i $(BIN_DIR)/$$i; done
	
edoc:
	@echo Generating $(APP) documentation from srcs
	@$(ECOMPILE) -noinput -eval 'edoc:application($(APP), "./", [{doc, "doc/"}, {files, "src/"}])' -s erlang halt

$(TEST_EBIN_DIR):
	@mkdir -p $(TEST_EBIN_DIR)

clean:
	echo $(TEST_EBIN_DIR)
	rm -rf $(EBIN)/*.beam $(EBIN)/erl_crash.dump erl_crash.dump $(EBIN)/*.boot $(EBIN)/*.rel $(EBIN)/*.script $(TEST_EBIN_DIR)/*.beam $(EBIN)/$(APP)-*.tar.gz *.log

clean_deps:
	@(cd deps/mochiweb; $(MAKE) clean)