FROM archlinux:latest

RUN pacman -Syu --noconfirm

# These are all the packages needed to build kstars, indi, indi-3rdparty and GSC
RUN pacman -S git base-devel cmake cfitsio fftw gsl \
	libjpeg-turbo libnova libtheora libusb boost \
	libraw libgphoto2 libftdi libdc1394 libavc1394 \
	ffmpeg gpsd breeze-icons hicolor-icon-theme knewstuff \
	knotifyconfig kplotting qt5-datavis3d qt5-quickcontrols \
	qt5-websockets qtkeychain stellarsolver \
	extra-cmake-modules kf5 eigen cython python-numpy python-setuptools-scm \
	swig netpbm python-pytest python-sphinx graphviz python-pip --noconfirm

# Make a folder where GSC, astrometry, pyerfa and python-astropy will be built
RUN mkdir /tmp/build
WORKDIR /tmp/build

# Build GSC
WORKDIR /tmp/build
RUN git clone https://aur.archlinux.org/gsc.git
WORKDIR /tmp/build/gsc
RUN useradd --no-create-home --shell=/bin/false build && usermod -L build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN chown  build:build /tmp/build/gsc
USER build
RUN makepkg

# Build erfa
USER root
WORKDIR /tmp/build
RUN git clone https://aur.archlinux.org/erfa.git
WORKDIR /tmp/build/erfa
RUN chown  build:build /tmp/build/erfa
USER build
RUN makepkg
USER root
RUN pacman -U /tmp/build/erfa/erfa*x86_64.pkg.tar.zst --noconfirm

# Build python-pyerfa
USER root
WORKDIR /tmp/build
RUN git clone https://aur.archlinux.org/python-pyerfa.git
WORKDIR /tmp/build/python-pyerfa
RUN chown  build:build /tmp/build/python-pyerfa
USER build
RUN makepkg
USER root
RUN pacman -U /tmp/build/python-pyerfa/python-pyerfa*x86_64.pkg.tar.zst --noconfirm

# Build python-sphinx-automodapi
USER root
WORKDIR /tmp/build
RUN git clone https://aur.archlinux.org/python-sphinx-automodapi.git
WORKDIR /tmp/build/python-sphinx-automodapi
RUN chown  build:build /tmp/build/python-sphinx-automodapi
USER build
RUN makepkg
USER root
RUN pacman -U /tmp/build/python-sphinx-automodapi/python-sphinx-automodapi-0.13-1-any.pkg.tar.zst --noconfirm

# Build python-extensions-helpers
USER root
WORKDIR /tmp/build
RUN git clone https://aur.archlinux.org/python-extension-helpers.git
WORKDIR /tmp/build/python-extension-helpers
RUN chown  build:build /tmp/build/python-extension-helpers
USER build
RUN makepkg -s
USER root
RUN pacman -U /tmp/build/python-extension-helpers/python-extension*.zst --noconfirm

# Build python-astropy
USER root
WORKDIR /tmp/build
RUN git clone https://aur.archlinux.org/python-astropy.git
WORKDIR /tmp/build/python-astropy
RUN chown  build:build /tmp/build/python-astropy
USER build
RUN makepkg
USER root
RUN pacman -U /tmp/build/python-astropy/python-astropy*.zst --noconfirm

# Build astrometry
USER root
WORKDIR /tmp/build
RUN git clone https://aur.archlinux.org/astrometry.net.git
WORKDIR /tmp/build/astrometry.net
RUN chown  build:build /tmp/build/astrometry.net
USER build
RUN makepkg
USER root
RUN pacman -U /tmp/build/astrometry.net/astrometry*.zst --noconfirm
