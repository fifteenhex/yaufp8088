# 1 - name
define chip_targets
$1.jed: $1.pld
	cd galette && cargo run ../$$<

.PHONY: burn_$1
burn_$1: $1.jed
	minipro -p $2 -P -w $$<
endef

$(eval $(call chip_targets,io,ATF16V8B))
$(eval $(call chip_targets,mem,ATF16V8B))
$(eval $(call chip_targets,protoboard_0,ATF16V8B))
$(eval $(call chip_targets,protoboard_1,ATF16V8B))
$(eval $(call chip_targets,protoboard_2,ATF22V10C))

$(eval $(call chip_targets,debugboard_0))
