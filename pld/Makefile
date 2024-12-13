# 1 - name
define chip_targets
$1.jed: $1.pld
	cd galette && cargo run ../$$<

.PHONY: burn_$1
burn_$1: $1.jed
	minipro -p ATF16V8B -P -w $$<
endef

$(eval $(call chip_targets,io))
$(eval $(call chip_targets,mem))
