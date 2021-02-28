# compat-drivers-dkms

This Makefile and debian packaging is a wrapper for the compat-drivers
backports of the latest Linux network drivers to older kernels.

## Introduction

Compat-drivers is needed when needing a newer driver to be run on an
older kernel without replacing the whole kernel. It is used for example
in OpenWRT.

[compat-drivers](https://backports.wiki.kernel.org/index.php/Documentation/compat-drivers)
provides the newer drivers to be compiled on an older kernel
and adds the required glue code like newer helper functions.

[DKMS](https://help.ubuntu.com/community/DKMS) takes care of
re-compiling and glueing the new modules into the existing kernel
whenever necessary (e.g. after updating the distros kernel).
It is run automatically from debian package postinst scripts.

This project adds the DKMS definitions for compat-drivers
and wraps this into a debian package to be easily installed.

## Notes

DKMS needs to know the list of modules (compiled .ko files) that will be
built by compat-drivers, and that list must be supplied before the drivers
are compiled on the target system (where the DKMS package is to be
installed) in dkms.conf.

To avoid hard-coding that list, it is automatically generated
when building the debian package.

## Configuration

Use make menuconfig to (re-)configure.

The Debian package is configured to build only some modules by default,
which might not be what you want.

Then build a new Debian package:

	debuild -i -us -uc -b

If you have ccache installed you can try as well:

	debuild --prepend-path=/usr/lib/ccache -i -us -uc -b

This should build a `.deb` file in the parent directory:

	dpkg-deb: building package `compat-drivers-dkms' in `../compat-drivers-dkms_5.10.16-1_all.deb'.

You can install this package on any Debian-like system where you want the latest drivers.

When you install it, DKMS should automatically build the drivers for your
current running kernel.

You can check the status of the drivers in DKMS with this command

	$ dkms status -m compat-drivers
	compat-drivers, 5.10.16-1, 5.10.0-0.bpo.3-amd64, x86_64: installed

* `added` means that the module was registered with DKMS, but failed to
  build. This is bad. Try to build it with this command and see what
  happens:

	dkms build -m compat-drivers -v 5.10.16-1

* `built` means that the module has been built (for a particular kernel),
  but is not installed in that kernel's module directory under
  `/lib/modules` any more. The kernel may have been uninstalled, or the
  modules removed from it with the `dkms uninstall` command. If the
  kernel is still in use, then the updated `compat-drivers` modules
  are not available for use with it, which is bad, but can be fixed by
  running `dkms install -m compat-drivers -v 5.10.16-1 .

* `installed` means that the modules are in the kernel modules directory
  under `/lib/modules` and will be used. This is good.

