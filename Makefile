.PHONY: all

all:
	$(MAKE) -C software


.PHONY: bootstrap

bootstrap:
	$(MAKE) -C software bootstrap
