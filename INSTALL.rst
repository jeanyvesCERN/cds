Installation
=============

1. About
--------

This document specifies how to install a development version of CDS for the
first time. Production grade deployment is not covered here.

2. Docker
---------

Please only use for development and testing.

The docker container is based on the Invenio docker container.

For more information please check `Read the Docs (Invenio / Docker) <http://invenio.readthedocs.org/en/latest/developers/docker.html>`_.

2.1 Prerequisites
-----------------
Please install `docker <https://docs.docker.com/installation/ubuntulinux/>`_
and docker-compose:

.. code-block:: console

    # Install docker
    sudo apt-get install curl
    curl -sSL https://get.docker.com/ | sh

    # Use docker without sudo
    sudo usermod -aG docker *your_user*

    # Verify docker is installed correctly.
    docker run hello-world

    # Install docker-compose
    sudo pip install docker-compose


2.2 OS X prerequisites
~~~~~~~~~~~~~~~~~~~~~~
Install docker for OS X.

https://docs.docker.com/installation/mac/

Hints:

- Change the port binding in `docker-compose.yml` the docker-machine IP-Address.
- Change the CFG_SITE_URL.

2.2 Quick start
---------------
2.2.1 Getting the source code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First go to GitHub and fork the CDS repositories if you have
not already done so (see Step 1 in
`Fork a Repo <https://help.github.com/articles/fork-a-repo>`_):

- `CDS <https://github.com/CERNDocumentServer/cds>`_

Next, clone your forks to get the development versions of CDS.

.. code-block:: console

    $ cd $HOME/src/
    $ git clone https://github.com/<username>/cds.git
    $ cd $HOME/src/cds
    $ git checkout -b cdslabs cds/cdslabs



2.2.2 Optional - Using a different invenio version
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Using Invenio form your own source repository also activates live reloading
of changed Python files.

So you might want to use git-new-workdir to create a separate *invenio_cdslabs*
folder.

In the cds/docker-compose.yml file under the *web* container
change the mapped volumes to match you local source path:

Uncomment the 3 lines and change the path corresponding to you installation.

.. code-block:: yml

    volumes:
        # - ../invenio_cdslabs/invenio:/code/invenio:ro
        # - ../invenio_cdslabs/docs:/code/docs:rw
        # - ../invenio_cdslabs/scripts:/code/scripts:ro
        - ./cds:/code-cds/cds
        - /home/invenio



2.3 Build and run the Docker image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
To build the cdslabs image go to the cds source folder and execute:

.. code-block:: console

    docker-compose build

Run cdslabs with:

.. code-block:: console

    docker-compose up

Load the demo records (Optinal):

.. code-block:: console

    docker-compose run --rm web inveniomanage records create -t marcxml < cds/demosite/data/cds-demobibdata.xml


Remove the containers:

.. code-block:: console

    docker-compose rm -v


2.4 Develop
-----------
For development on the cds overlay is the cds/cds folder directly mapped
into the container.

Changes in Python files will be automatically detected and trigger a reload.

If other file are changed the container has to be recreated.

.. code-block:: console

    docker-compose build
    docker-compose up


To everything including the database:

.. code-block:: console

    docker-compose rm -v
    docker-compose build
    docker-compose up


3. Virtual enviroment
-------------
3.1 Prerequisites
-----------------

If you haven't done it already, follow the section "2. Prerequisites" in
`First Steps with Invenio <http://invenio.readthedocs.org/en/latest/getting-started/first-steps.html#prerequisites>`_

3.1.1 OS X prerequisites
~~~~~~~~~~~~~~~~~~~~~~

For OS X it is recommended to install dependencies via Homebrew.
First install Homebrew and make sure you have the XCode command-line tools
(note you may need to install XCode via AppStore if you did not already do so):

.. code-block:: console

   $ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
   $ xcode-select --install

Next install dependencies via Homebrew:

.. code-block:: console

   $ brew install python redis mysql libxml2 libxslt nodejs git rabbitmq
   $ npm install -g less@1.7.5 clean-css requirejs uglify-js bower
   $ pip install virtualenv virtualenv-wrapper

3.1.2 MySQL configuration (Needs review)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The default MySQL configuration needs to be modified otherwise the database
loading will fail. Please add the following lines to ``my.cnf`` (located in ``/etc/my.cnf`` or ``/usr/local/etc/my.cnf``):

.. code-block:: ini

   [mysqld]
   max_allowed_packet=1G
   open_files_limit=4096

Additionally on OS X developer machines you will need to limit number of open files (defaults to 256 per process in OS X):

.. code-block:: ini

   [mysqld]
   # ...
   table_open_cache=250

Alternatively, you can also increase number of allowed files per process using:

.. code-block:: console

   $ launchctl limit maxfiles 65536

See http://stackoverflow.com/a/22773887 and
http://docs.basho.com/riak/latest/ops/tuning/open-files-limit/#Mac-OS-X for how
to persist the change.

3.2. Quick start
--------------

3.2.1. Getting the source code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First go to GitHub and fork both Invenio and CDS repositories if you have
not already done so (see Step 1 in
`Fork a Repo <https://help.github.com/articles/fork-a-repo>`_):

- `Invenio <https://github.com/inveniosoftware/invenio>`_
- `CDS <https://github.com/CERNDocumentServer/cds>`_

Next, clone your forks to get development versions of Invenio and CDS.

.. code-block:: console

    $ cd $HOME/src/
    $ git clone https://github.com/<username>/invenio.git
    $ git clone https://github.com/<username>/cds.git

Make sure you configure upstream remote for the repository so you can fetch
updates to the repository.

.. code-block:: console

    $ cd $HOME/src/invenio
    $ git remote add upstream https://github.com/inveniosoftware/invenio.git
    $ git fetch upstream
    $ git remote add cds https://github.com/CERNDocumentServer/invenio.git
    $ git fetch cds
    $ cd $HOME/src/cds
    $ git remote add cds https://github.com/CERNDocumentServer/cds.git
    $ git fetch cds

3.2.2 Working environment
~~~~~~~~~~~~~~~~~~~~~~~

We recommend to work using
`virtual environments <http://www.virtualenv.org/>`_ so packages are installed
in an isolated environment . ``(cdslabs)$`` tells that your
*cdslabs* environment is the active one.

.. code-block:: console

    $ mkvirtualenv cdslabs
    (cdslabs)$ # we are in the cdslabs environment now and
    (cdslabs)$ # can leave it using the deactivate command.
    (cdslabs)$ deactivate
    $ # Now join it back, recreating it would fail.
    $ workon cdslabs
    (cdslabs)$ # That's all there is to know about it.

Let's create a working copy of the Invenio and CDS overlay source code in the
just created environment.

.. code-block:: console

    (cdslabs)$ cdvirtualenv
    (cdslabs)$ mkdir src; cd src
    (cdslabs)$ git-new-workdir $HOME/src/invenio/ invenio cdslabs
    (cdslabs)$ git-new-workdir $HOME/src/cds/ cds cdslabs

By default we checkout the development branches `cdslabs` for CDS and
`cdslabs` for Invenio.

TODO: Finish docs!

3.2.3 Installation
~~~~~~~~~~~~~~~~

The steps for installing CDS are nearly identical to a normal Invenio
installation:

.. code-block:: console

    (cdslabs)$ cdvirtualenv src/cds
    (cdslabs)$ pip install -r requirements.txt --exists-action i

.. NOTE::
   The option ``--exists-action i`` for ``pip install`` is needed to ensure that
   the Invenio source code we just cloned will not be overwritten. If you
   omit it, you will be prompted about which action to take.

If the Invenio is installed in development mode, you will need to compile the
translations manually.

.. code-block:: console

    (cdslabs)$ cdvirtualenv src/invenio
    (cdslabs)$ python setup.py compile_catalog

.. NOTE::
    Translation catalog is compiled automatically if you install
    using `python setup.py install`.

For development environments you should install our git commit hooks that checks
code according to our code quality standards:

.. code-block:: console

    (cdslabs)$ cd $HOME/src/invenio/
    (cdslabs)$ kwalitee githooks install
    (cdslabs)$ cd $HOME/src/cds/
    (cdslabs)$ kwalitee githooks install

3.2.4. Configuration
~~~~~~~~~~~~~~~~~~

Generate the secret key for your installation.

.. code-block:: console

    (cdslabs)$ inveniomanage config create secret-key

If you are planning to develop locally in multiple environments please run
the following commands.

.. code-block:: console

    (cdslabs)$ inveniomanage config set CFG_EMAIL_BACKEND flask.ext.email.backends.console.Mail
    (cdslabs)$ inveniomanage config set CFG_BIBSCHED_PROCESS_USER $USER

By default the database name and username is set to `cds`. You mau want to
change that especially if you have multiple local installations:

.. code-block:: console

    (cdslabs)$ inveniomanage config set CFG_DATABASE_NAME <name>
    (cdslabs)$ inveniomanage config set CFG_DATABASE_USER <username>

Sometimes, depending on what is the final purpose of the installation, enabling
the debug mode could be usefull:

.. code-block:: console

    (cdslabs)$ inveniomanage config set DEBUG True

3.2.5. Assets
~~~~~~~~~~~

Assets in non-development mode may be combined and minified using various
filters. We need to set the path to the binaries if they are not in the
environment ``$PATH`` already.

.. code-block:: console

    # Global installation
    $ sudo npm install -g less@1.7.5 clean-css requirejs uglify-js bower

    or
    # Local installation
    $ workon cdslabs
    (cdslabs)$ cdvirtualenv
    (cdslabs)$ inveniomanage config set LESS_BIN `find $PWD/node_modules -iname lessc | head -1`
    (cdslabs)$ inveniomanage config set CLEANCSS_BIN `find $PWD/node_modules -iname cleancss | head -1`
    (cdslabs)$ inveniomanage config set REQUIREJS_BIN `find $PWD/node_modules -iname r.js | head -1`
    (cdslabs)$ inveniomanage config set UGLIFYJS_BIN `find $PWD/node_modules -iname uglifyjs | head -1`


Install the external JavaScript and CSS libraries:

.. code-block:: console

    (cdslabs)$ cdvirtualenv src/cds
    (cdslabs)$ inveniomanage bower -o bower.json
    (cdslabs)$ bower install


``inveniomanage collect`` will create the static folder with all
the required assets (JavaScript, CSS and images) from each module static folder
and bower. ``inveniomanage assets build`` will build minified and cleaned
assets using the once that have been copied to the static folder.

.. code-block:: console

    (cdslabs)$ inveniomanage config set COLLECT_STORAGE invenio.ext.collect.storage.link
    (cdslabs)$ inveniomanage collect
    (cdslabs)$ inveniomanage assets build

3.2.6. Initial data
~~~~~~~~~~~~~~~~~

**Troubleshooting:** As a developer, you may want to use the provided
``Procfile`` with `honcho <https://pypi.python.org/pypi/honcho>`_. It
starts all the services at once with nice colors. Be default, it also runs
`flower <https://pypi.python.org/pypi/flower>`_ which offers a web interface
to monitor the *Celery* tasks.

.. code-block:: console

    (cdslabs)$ cdvirtualenv src/cds
    (cdslabs)$ honcho start

Once you have everything installed and the __services running__ you can create
the database and populate it with initial data.

.. note::
    It is important to have all serices running as database init and database
    create will insert information already in Elasticseach anr will use celery
    as well to run tasks inside the redis queue.

.. code-block:: console

    $ # in a new terminal
    $ workon cdslabs
    (cdslabs)$ inveniomanage database init --user=root --password=$MYSQL_ROOT --yes-i-know
    (cdslabs)$ inveniomanage database create

.. 3.7. Background processes
.. ~~~~~~~~~~~~~~~~~~~~~~~~~
..
.. Now you should be able to run the development server. Invenio uses
.. `Celery <http://www.celeryproject.org/>`_ and `Redis <http://redis.io/>`_
.. which must be running alongside with the web server.
..
.. .. code-block:: console
..
..     $ # make sure that redis is running
..     $ sudo service redis-server status
..     redis-server is running
..     $ # or start it with start
..     $ sudo service redis-start start
..
..     $ # launch celery
..     $ workon cdslabs
..     (cdslabs)$ celeryd -E -A invenio.celery.celery --workdir=$VIRTUAL_ENV
..
..     $ # launch bibsched
..     (cdslabs)$ bibsched start
..
..     $ # in a new terminal
..     $ workon cdslabs
..     (cdslabs)$ inveniomanage runserver
..      * Running on http://0.0.0.0:4000/
..      * Restarting with reloader
..


When you have the servers running, it is possible to upload the demo records.

.. code-block:: console

    $ workon cdslabs
    (cdslabs)$ cdvirtualenv src/cds
    (cdslabs)$ inveniomanage records create -t marcxml < cds/demosite/data/cds-demobibdata.xml

.. NOTE::
    Sometimes the changes doesn't appear inmediatly when running the
    development server, simply stop honcho and start it again.

And you may now open your favourite web browser on
`http://0.0.0.0:4000/ <http://0.0.0.0:4000/>`_


3.3. Updating existing installation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First step update both Invenio and CDS repositories inside the virtualenv:

.. code-block:: console

    $ workon cdslabs
    (cdslabs)$ cdvirtualenv src/invenio
    (cdslabs)$ git fetch cds
    (cdslabs)$ git reset --hard cds/cdslabs
    (cdslabs)$ cdvirtualenv src/cds
    (cdslabs)$ git fetch cds
    (cdslabs)$ git pull # be carefull if you have local change, --rebase should help


With the new code in place run the installation process:

.. code-block:: console

    (cdslabs)$ cdvirtualenv src/cds
    (cdslabs)$ pip install -r requirements.txt --exists-action i

It might be the there are some new assets:

.. code-block:: console

    (cdslabs)$ cdvirtualenv src/cds
    (cdslabs)$ inveniomanage bower -o bower.json
    (cdslabs)$ bower install
    (cdslabs)$ inveniomanage collect
    (cdslabs)$ inveniomanage assets build

And it could be that the database schema has change:

.. code-block:: console

    (cdslabs)$ inveniomanage upgrader check
    # If any upgrade recepie is pending
    (cdslabs)$ inveniomanage upgrader run


4. Fetching pull requests
~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: console

    $ cd $HOME/src/invenio/
    $ vim .git/config

Add `fetch = +refs/pull/*/head:refs/remotes/upstream/pr/*` to the remote
`upstream` and `cds`

.. code-block:: ini

    [remote "upstream"]
        url = git://github.com/inveniosoftware/invenio.git
        fetch = +refs/heads/*:refs/remotes/upstream/*
        fetch = +refs/pull/*/head:refs/remotes/upstream/pr/*

    [remote "cds"]
        url = git://github.com/CERNDocumentServer/invenio.git
        fetch = +refs/heads/*:refs/remotes/upstream/*
        fetch = +refs/pull/*/head:refs/remotes/upstream/pr/*


.. code-block:: console

    $ cd $HOME/src/cds/
    $ vim .git/config

Add `fetch = +refs/pull/*/head:refs/remotes/upstream/pr/*` to the remote
`cds`.

.. code-block:: ini

    [remote "cds"]
        url = https://github.com/CERNDocumentServer/cds.git
        fetch = +refs/heads/*:refs/remotes/upstream/*
        fetch = +refs/pull/*/head:refs/remotes/upstream/pr/*
