.PHONY: all

all:
	$(MAKE) -C eda
	$(MAKE) -C pld
	$(MAKE) -C software


.PHONY: bootstrap

bootstrap:
	$(MAKE) -C eda bootstrap
	$(MAKE) -C software bootstrap
