NAME:=compat-drivers
VERSION=5.10.16
SRC_VERSION:=$(VERSION)-1
SRC_FILE:=backports-$(SRC_VERSION).tar.xz
DESTDIR?=install

default: build/tree build/dkms.conf

clean:
	rm -rf build

install: build/dkms.conf
	mkdir $(DESTDIR)/usr/src/$(NAME)-$(SRC_VERSION)
	tar xJf build/$(SRC_FILE) -C $(DESTDIR)/usr/src/$(NAME)-$(SRC_VERSION) --strip-components=1
	cp src/config $(DESTDIR)/usr/src/$(NAME)-$(SRC_VERSION)/.config
	cp build/dkms.conf $(DESTDIR)/usr/src/$(NAME)-$(SRC_VERSION)/dkms.conf

build/tree: src/config build/$(SRC_FILE)
	mkdir -p build/tree
	tar xJf build/$(SRC_FILE) -C build/tree --strip-components=1
	cp src/config build/tree/.config

build/dkms.conf: build/tree
	make -C build/tree
	cat src/dkms.conf.in \
		| sed -e "s/#NAME#/$(NAME)/" \
		| sed -e "s/#VERSION#/$(SRC_VERSION)/" \
		> build/dkms.conf
	./make-dkms-conf build/tree >> build/dkms.conf

build/$(SRC_FILE):
	test -e src/$(SRC_FILE) && ln src/$(SRC_FILE) build/$(SRC_FILE) || wget https://cdn.kernel.org/pub/linux/kernel/projects/backports/stable/v$(VERSION)/$(SRC_FILE) -O build/$(SRC_FILE)

menuconfig: build/tree
	make -C build/tree menuconfig
	cp build/tree/.config src/config
