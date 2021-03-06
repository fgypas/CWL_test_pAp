#!/usr/bin/bash

# Set bash options
set -eo pipefail

# Set parameters
testname=$(basename "$0" .sh)
root="/scicore/home/zavolan/kanitz/Sandbox/singularity-toil/CWL_test_pAp"
venv="/scicore/home/zavolan/kanitz/Sandbox/singularity-toil/venv/bin/activate"
cwltool_dir="/scicore/home/zavolan/kanitz/Sandbox/singularity-toil/venv/lib/python2.7/site-packages/cwltool"

# Create execution/temp/results directories and log file
testdir="${root}/${testname}"
mkdir -p "$testdir"
results="${testdir}/RESULTS"
mkdir -p "$results"
log="${results}/log"
touch "$log"

# Import modules
echo "Importing modules..."
ml purge &>> "$log"
ml Python/2.7.11-goolf-1.7.20 &>> "$log"
ml Singularity/2.4.4 &>> "$log"

# Activate virtual environment
echo "Activate virtual environment..."
source "$venv"

# Set & populate SINGULARITY_PULLFOLDER
echo "Set and populate SINGULARITY_PULLFOLDER..."
export SINGULARITY_PULLFOLDER="${testdir}/SINGULARITY_IMAGES"
mkdir -p $SINGULARITY_PULLFOLDER
cp "${root}/images/"* "$SINGULARITY_PULLFOLDER"

# Set TOIL_SLURM_ARGS
export TMPDIR="${testdir}/TMP"
mkdir -p "$TMPDIR"
export TOIL_SLURM_ARGS='--export=ALL'

# Ensure that desired version of singularity.py module is used
echo "Ensure that desired version of 'singularity.py' is used..."
rm -f "${cwltool_dir}/singularity.pyc"
cp "${cwltool_dir}/singularity.py.prefetch" "${cwltool_dir}/singularity.py"

# Run tool
echo "Starting tool..."
toil-cwl-runner --batchSystem="slurm" --singularity "${root}/workflows/cjh_polyA_prepro_WF1.1.cwl" "${root}/workflows/cjh_polyA_prepro_WF1.1.yml" &>> "$log"

# Clean up
echo "Cleaning up..."
mv *fa *fq *fa.gz slurm-*.out "$results" &>> "$log"
rm -rf out_tmpdir* &>> "$log"
