.LIBPATTERNS =
.SUFFIXES:
export SHELL = /bin/bash

ROOTDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SRCDIR := $(abspath $(ROOTDIR)/src)
BUILDDIR := $(abspath $(ROOTDIR)/build)
UPLOADDIR := p-frontend1:/srv/htdocs/frontend
MINIFY := $(ROOTDIR)/3rdparty/minify_2.7.6_linux_amd64/minify
SASSC := sassc

OBJECTS := $(addprefix $(BUILDDIR)/, \
	$(patsubst $(SRCDIR)/%, %, $(shell find $(SRCDIR) -type f)) \
	css/style.css \
	index.html \
)

define make_path
	@mkdir -p $(dir $@)
	@chmod 0755 $(dir $@)
	@touch -cr $(dir $<) $(dir $@)
	@[[ "$(dir $@)" == "$(BUILDDIR)/" ]] || \
		touch -cr $(dir $<).. $(dir $@)..
endef

define fix_file
	@chmod 0644 $@
	@touch -cr $< $@
	@touch -cr $(dir $<) $(dir $@)
endef

define copy_file
	$(make_path)
	cp -L --preserve=timestamps $< $@
	$(fix_file)
endef

.PHONY: all
all: $(OBJECTS)

.PHONY: clean
clean:
	rm -vrf $(BUILDDIR)

.PHONY: upload
upload:
	rsync \
		--verbose \
		--progress \
		--8-bit-output \
		--human-readable=1 \
		--recursive \
		--links \
		--copy-unsafe-links \
		--delete \
		--perms \
		--times \
		--timeout=30 \
		$(BUILDDIR)/ \
		$(UPLOADDIR) \

# html
$(BUILDDIR)/index.html: $(SRCDIR)/index-en.html
	$(make_path)
	ln -s $(notdir $<) $@
	$(fix_file)

$(BUILDDIR)/%.html: $(SRCDIR)/%.html
	$(make_path)
	$(MINIFY) --type html \
		--html-keep-conditional-comments \
		--html-keep-default-attrvals \
		--html-keep-document-tags \
		--html-keep-end-tags -o \
		$@ $<
	$(fix_file)

# styles
$(BUILDDIR)/css/style.css: $(SRCDIR)/scss/style.scss
	$(make_path)
	$(SASSC) --style compressed $< $@
	$(fix_file)

$(BUILDDIR)/%.css: $(SRCDIR)/%.css
	$(make_path)
	$(MINIFY) --type css --css-decimals -1 -o $@ $<
	$(fix_file)

$(BUILDDIR)/%.css.map: ;
$(BUILDDIR)/scss/%: ;
$(BUILDDIR)/scss/%: ;

# scripts
$(BUILDDIR)/%.js: $(SRCDIR)/%.js
	$(make_path)
	$(MINIFY) --type js -o $@ $<
	$(fix_file)

# fonts
$(BUILDDIR)/%.woff:  $(SRCDIR)/%.woff  ; $(copy_file)
$(BUILDDIR)/%.woff2: $(SRCDIR)/%.woff2 ; $(copy_file)
$(BUILDDIR)/%.ttf:   $(SRCDIR)/%.ttf   ; $(copy_file)
$(BUILDDIR)/%.eot:   $(SRCDIR)/%.eot   ; $(copy_file)

# images
$(BUILDDIR)/%.gif:  $(SRCDIR)/%.gif  ; $(copy_file)
$(BUILDDIR)/%.png:  $(SRCDIR)/%.png  ; $(copy_file)
$(BUILDDIR)/%.ico:  $(SRCDIR)/%.ico  ; $(copy_file)
$(BUILDDIR)/%.jpeg: $(SRCDIR)/%.jpeg ; $(copy_file)
$(BUILDDIR)/%.jpg:  $(SRCDIR)/%.jpg  ; $(copy_file)

$(BUILDDIR)/%.svg: $(SRCDIR)/%.svg
	$(make_path)
	$(MINIFY) --type svg --svg-precision 0 -o $@ $<
	$(fix_file)

# ignore
$(BUILDDIR)/%.zip: ;
$(BUILDDIR)/%.empty: ;
