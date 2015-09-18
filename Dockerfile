# This file is part of Invenio.
# Copyright (C) 2015 CERN.
#
# Invenio is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# Invenio is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Invenio; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.

###############################################################################
## 1. Base (stable)                                                          ##
###############################################################################

# TODO: Change to the Invenio version as soon as PR#147 is accepted.
FROM ddaze/invenio-cdslabs

USER root
WORKDIR /code-cds

# Install vim
RUN apt-get update && \
    apt-get -qy install --fix-missing --no-install-recommends \
        vim \
        && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg}/ && \
    (find /usr/share/doc -depth -type f ! -name copyright -delete || true) && \
    (find /usr/share/doc -empty -delete || true) && \
    rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/*

# Allow sudo
RUN echo "alias ll='ls -alF'" >>  /home/invenio/.bashrc && \
    echo "invenio ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
###############################################################################
## 2. Requirements (semi-stable)                                             ##
###############################################################################

# add requirement files
COPY ./requirements.txt \
     ./dev.requirements.txt \
     ./test.requirements.txt \
     ./base.requirements.txt \
     ./base-pinned.requirements.txt \
     ./setup.py \
     /code-cds/

COPY ./cds/version.py /code-cds/cds/

# install python requirements, remove invenio from requirements
RUN sed -i '/CERNDocumentServer\/invenio/d' requirements.txt \
    && pip install -r /code-cds/requirements.txt --exists-action i --upgrade


###############################################################################
## 3. Code (changing)                                                        ##
###############################################################################

# add current directory as `/code`.
COPY . /code-cds


###############################################################################
## 4. Build (changing)                                                       ##
###############################################################################

# step back
# in general code should not be writable, especially because we are using
# `pip install -e`
RUN mkdir -p /code-cds/src && \
    chown -R invenio:invenio /code-cds && \
    chown -R invenio:invenio /home/invenio
    # chown -R invenio:invenio $VIRTENV
    # chown -R root:root /code-cds/cds && \
    # chown -R root:root /code-cds/setup.* && \
    # chown -R root:root /code-cds/src

# finally step back again
USER invenio

RUN cfgfile=$INVENIOBASE_INSTANCE_PATH/invenio.cfg && \
    mkdir -p $INVENIOBASE_INSTANCE_PATH && \
    echo "CFG_BATCHUPLOADER_DAEMON_DIR = u'/home/invenio/var/batchupload'" >> $cfgfile && \
    echo "CFG_BIBSCHED_LOGDIR = u'/home/invenio/var/log/bibsched'" >> $cfgfile && \
    echo "CFG_BIBEDIT_CACHEDIR = u'/home/invenio/var/tmp-shared/bibedit-cache'" >> $cfgfile && \
    echo "CFG_BIBSCHED_LOGDIR = u'/home/invenio/var/log/bibsched'" >> $cfgfile && \
    echo "CFG_BINDIR = u'/usr/local/bin'" >> $cfgfile && \
    echo "CFG_CACHEDIR = u'/home/invenio/var/cache'" >> $cfgfile && \
    echo "CFG_ETCDIR = u'/home/invenio/etc'" >> $cfgfile && \
    echo "CFG_LOCALEDIR = u'/home/invenio/share/locale'" >> $cfgfile && \
    echo "CFG_LOGDIR = u'/home/invenio/var/log'" >> $cfgfile && \
    echo "CFG_PYLIBDIR = u'/usr/local/lib/python2.7'" >> $cfgfile && \
    echo "CFG_RUNDIR = u'/home/invenio/var/run'" >> $cfgfile && \
    echo "CFG_TMPDIR = u'/tmp/invenio-`hostname`'" >> $cfgfile && \
    echo "CFG_TMPSHAREDDIR = u'/home/invenio/var/tmp-shared'" >> $cfgfile && \
    echo "CFG_WEBDIR = u'/home/invenio/var/www'" >> $cfgfile && \
    cd /code-cds && \
    inveniomanage bower -o bower.json && \
    sed -i 's,directory":.*,directory": "/home/invenio/static/vendors",g' .bowerrc && \
    bower install -q -f && \
    inveniomanage collect && \
    rm -f $cfgfile

# add volumes
# do this AFTER `chown`, because otherwise directory permissions are not
# preserved
VOLUME ["/code-cds"]

# install init scripts
# ENTRYPOINT ["/code/scripts/docker_boot.sh"]

# default to bash
# CMD ["bash"]
