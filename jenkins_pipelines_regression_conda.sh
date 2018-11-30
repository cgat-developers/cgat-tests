#!/usr/bin/env bash

# References
# http://kvz.io/blog/2013/11/21/bash-best-practices/
# http://jvns.ca/blog/2017/03/26/bash-quirks/

# exit when a command fails
set -o errexit

# exit if any pipe commands fail
set -o pipefail

# exit when your script tries to use undeclared variables
#set -o nounset

# trace what gets executed
set -o xtrace

# configure module
unset -f module
module() {  eval `/usr/bin/modulecmd bash $*`; }

# Host to run pipeline from. Jenkins must be able to SSH into there.
SUBMIT_HOST=jenkins@cgath1

export HOME=/ifs/home/jenkins

export DRMAA_LIBRARY_PATH=/ifs/apps/system/sge-6.2/lib/lx24-amd64/libdrmaa.so
export SGE_ROOT=/ifs/apps/system/sge-6.2
export SGE_CLUSTER_NAME=cgat
export SGE_ARCH=lx24_x86
export SGE_CELL=default

export MODULEPATH=/usr/share/Modules/modulefiles:/etc/modulefiles:/ifs/apps/modulefiles

echo "Installing pipelines"
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ${SUBMIT_HOST} \
   "cd ${WORKSPACE} && \
    export TERM=xterm && \
    bash install.sh \
    --install-dir ${WORKSPACE}/cgat-developers"

echo "Run python tests"
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ${SUBMIT_HOST} \
   "cd ${WORKSPACE} && \
    export TERM=xterm && \
    bash install.sh \
    --test \
    --install-dir ${WORKSPACE}/cgat-developers"

# copy test configuration files
curl -O https://raw.githubusercontent.com/cgat-developers/cgat-tests/master/pipeline.yml

error_report() {
    echo "Error detected"
    echo "Dumping log traces of test pipelines:"
    grep "ERROR" *.dir/pipeline.log
    grep -A 30 "Exception" *.dir/pipeline.log
    echo "Dumping error messages from pipeline_testing/pipeline.log:"
    sed -n '/start of error messages$/,/end of error messages$/p' pipeline.log
}

trap 'error_report' ERR

# run pipelines

echo "Starting pipelines"
ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ${SUBMIT_HOST} \
   "cd ${WORKSPACE} && \
    export TERM=xterm && \
    source ${WORKSPACE}/cgat-developers/conda-install/etc/profile.d/conda.sh && \
    conda activate base && conda activate cgat-f && \
    module load bio/gatk-full bio/homer  && \
    cgatflow testing make full -v 5"

