all: schematic.pdf

schematic.pdf: prototype.kicad_sch
	kicad-cli sch export pdf --output $@ $<
