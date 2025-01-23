.PHONY: all

all:
	$(MAKE) -C pld
	$(MAKE) -C software


.PHONY: bootstrap

bootstrap:
	$(MAKE) -C software bootstrap
