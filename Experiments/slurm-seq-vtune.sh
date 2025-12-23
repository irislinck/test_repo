#!/bin/bash

# ======================== Comments ==============================
# This job run sequential programs on Heracles Cluster
# ----------------------------------------------------------------
# Submit this job as
# sbatch slurm-seq.sh --job-name=<jobname> $PWD/my_program arg1 arg2 argN
# 
# --> check the available partitions : sinfo
#SBATCH --partition=day-long-cpu      ###  up 1-00:00:00   node[2-16]

#SBATCH --job-name=myjobname      ### Job Name
#SBATCH --output=%x_out.%j        ### File in which to store job output. x% is a placeholder that gets replaced with the job's name.
#SBATCH --error=%x_err.%j         ### File in which to store job error messages. x% is a placeholder that gets replaced with the job's name.

#SBATCH --exclusive               ### no shared resources within a node

# --> use < scontrol show partition day-long-cpu > to check memory default for this cluster
#SBATCH --mem=10G                 ### Request maximum memory on CPU          

# Capture the program name and parameters from the command line arguments
program_name=$1
shift 1  # Shift the positional parameters to the left (so $2 becomes $1, etc.)
program_params="$@"

echo "Running on node: $(hostname)"
# Print information for debugging
echo "Message from job: Running program: $program_name with parameters: $program_params"

# Run the program with the given parameters
source /opt/intel/oneapi/setvars.sh
vtune -collect performance-snapshot -- $program_name $program_params