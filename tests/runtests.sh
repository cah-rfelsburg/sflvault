#!/bin/sh
#
# SFLvault - Secure networked password store and credentials manager.
#
# Copyright (C) 2008-2009  Savoir-faire Linux inc.
#
# Author: Alexandre Bourget <alexandre.bourget@savoirfairelinux.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Make sure we run from the test dir
cd `dirname $0`

# Clean the directory from previous test runs
echo "Wiping test directory"
rm -rf sandbox
mkdir -p sandbox
cp ../server/test.ini sandbox/test-server.ini
cp ../server/development.ini sandbox/
cd sandbox

# SFLVault test mode
export SFLVAULT_IN_TEST=true

# Setup the test config
echo "Creating test config, certificate, etc.."
# jgama - Pyramid doesn't work with make-config
#paster make-config SFLvault-server test-server.ini
sed -i "s/port = 5551/port = 5767/" test-server.ini
# jgama - Pyramid doesn't work with setup-app
# paster setup-app test-server.ini
openssl genrsa 1024 > host.key ; chmod 400 host.key ; openssl req -new -x509 -config ../test-certif-config -nodes -sha1 -days 365 -key host.key > host.cert ; cat host.cert host.key > host.pem ; chmod 400 host.pem

# Launch the server
echo "Launching server..."
coverage run --rcfile=../coverage.conf `which paster` serve -v --daemon --pid-file test-server.pid test-server.ini
sleep 3

# Launch tests
coverage run --rcfile=../coverage.conf `which nosetests` -w .. -s  --with-xunit 

# Kill the test server
echo "Killing server..."
kill -2 `cat test-server.pid`
rm test-server.pid
