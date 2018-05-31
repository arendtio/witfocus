templatesdir = $(pkgdatadir)/templates
scriptsdir = $(pkgdatadir)/scripts

dist_templates_DATA = \
	task.md \
	vimrc

dist_scripts_DATA = \
	lib.sh

vimrc: vimrc.in
	sed -e 's|@datadir[@]|$(pkgdatadir)|g' $< > $@
