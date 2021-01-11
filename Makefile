.LIBPATTERNS =
.SUFFIXES:
export SHELL = /bin/bash

BASE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SOURCE_DIR := $(abspath $(BASE_DIR)/src)
BUILD_DIR := $(abspath $(BASE_DIR)/build)
UPLOAD_DIR := frontend2:/srv/htdocs/frontend
MINIFY := $(BASE_DIR)/3rdparty/minify_2.7.6_linux_amd64/minify
SASSC := sassc

OBJECTS := $(addprefix $(BUILD_DIR)/, \
	$(patsubst $(SOURCE_DIR)/%, %, $(shell find $(SOURCE_DIR) -type f)) \
	css/style.css \
	favicon.ico \
	apple-touch-icon.png \
	index.html \
)

define MAKE_PATH
	@mkdir -p $(dir $@)
	@chmod 0755 $(dir $@)
	@touch -cr $(dir $<) $(dir $@)
	@[[ "$(dir $@)" == "$(BUILD_DIR)/" ]] || \
		touch -cr $(dir $<).. $(dir $@)..
endef

define FIX_FILE
	@chmod 0644 $@
	@touch -cr $< $@
	@touch -cr $(dir $<) $(dir $@)
endef

define COPY_FILE
	$(MAKE_PATH)
	cp -L --preserve=timestamps $< $@
	$(FIX_FILE)
endef

.PHONY: all
all: $(OBJECTS)

.PHONY: clean
clean:
	rm -vrf $(BUILD_DIR)

.PHONY: upload
upload:
	rsync \
		--progress \
		--human-readable \
		--recursive \
		--links \
		--copy-unsafe-links \
		--delete \
		--perms \
		--times \
		$(BUILD_DIR)/ \
		$(UPLOAD_DIR)

# html
$(BUILD_DIR)/index.html: $(SOURCE_DIR)/index-en.html
	$(MAKE_PATH)
	ln -s $(notdir $<) $@
	$(FIX_FILE)

$(BUILD_DIR)/%.html: $(SOURCE_DIR)/%.html
	$(MAKE_PATH)
	$(MINIFY) --type html \
		--html-keep-conditional-comments \
		--html-keep-default-attrvals \
		--html-keep-document-tags \
		--html-keep-end-tags -o \
		$@ $<
	$(FIX_FILE)

# styles
$(BUILD_DIR)/css/style.css: $(SOURCE_DIR)/scss/style.scss
	$(MAKE_PATH)
	$(SASSC) --style compressed $< $@
	$(FIX_FILE)

$(BUILD_DIR)/%.css: $(SOURCE_DIR)/%.css
	$(MAKE_PATH)
	$(MINIFY) --type css --css-decimals -1 -o $@ $<
	$(FIX_FILE)

$(BUILD_DIR)/%.css.map: ;
$(BUILD_DIR)/scss/%: ;
$(BUILD_DIR)/scss/%: ;

# scripts
$(BUILD_DIR)/%.js: $(SOURCE_DIR)/%.js
	$(MAKE_PATH)
	$(MINIFY) --type js -o $@ $<
	$(FIX_FILE)

# fonts
$(BUILD_DIR)/%.woff:  $(SOURCE_DIR)/%.woff  ; $(COPY_FILE)
$(BUILD_DIR)/%.woff2: $(SOURCE_DIR)/%.woff2 ; $(COPY_FILE)
$(BUILD_DIR)/%.ttf:   $(SOURCE_DIR)/%.ttf   ; $(COPY_FILE)
$(BUILD_DIR)/%.eot:   $(SOURCE_DIR)/%.eot   ; $(COPY_FILE)

# images
$(BUILD_DIR)/favicon.ico: $(SOURCE_DIR)/img/favicons/favicon.ico
	$(COPY_FILE)
$(BUILD_DIR)/apple-touch-icon.png: $(SOURCE_DIR)/img/favicons/apple-touch-icon.png
	$(COPY_FILE)

$(BUILD_DIR)/%.gif:  $(SOURCE_DIR)/%.gif  ; $(COPY_FILE)
$(BUILD_DIR)/%.png:  $(SOURCE_DIR)/%.png  ; $(COPY_FILE)
$(BUILD_DIR)/%.ico:  $(SOURCE_DIR)/%.ico  ; $(COPY_FILE)
$(BUILD_DIR)/%.jpeg: $(SOURCE_DIR)/%.jpeg ; $(COPY_FILE)
$(BUILD_DIR)/%.jpg:  $(SOURCE_DIR)/%.jpg  ; $(COPY_FILE)

$(BUILD_DIR)/%.svg: $(SOURCE_DIR)/%.svg
	$(MAKE_PATH)
	$(MINIFY) --type svg --svg-precision 0 -o $@ $<
	$(FIX_FILE)

# other
$(BUILD_DIR)/%.xml: $(SOURCE_DIR)/%.xml
	$(MAKE_PATH)
	$(MINIFY) --type xml -o $@ $<
	$(FIX_FILE)
$(BUILD_DIR)/%.txt: $(SOURCE_DIR)/%.txt ; $(COPY_FILE)

$(BUILD_DIR)/%.webmanifest: $(SOURCE_DIR)/%.webmanifest
	$(COPY_FILE)

# ignore
$(BUILD_DIR)/%.zip: ;
$(BUILD_DIR)/%.empty: ;
