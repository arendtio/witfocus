templatesdir = $(pkgdatadir)/templates
dist_templates_DATA = \
	task.md \
	vimrc

vimrc: vimrc.in
	sed -e 's|@datadir[@]|$(pkgdatadir)|g' $< > $@
