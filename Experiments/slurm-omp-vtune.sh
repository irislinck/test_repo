#!/bin/bash
# ======================== Comments ==============================
# This job run OpenMP programs compiled on Intel Compilers
# This job will assume 48 threads as default
# Run Intel VTune to profile the code
# DO NOT CHANGE ANY PARAMETER IN THIS JOB
# ----------------------------------------------------------------
# --> submit the job from the command line with the desired number of threads, the program name, 
#     and parameters:
#
# --> Example how to submit this job:
#     export KMP_AFFINITY=scatter,verbose  or KMP_AFFINITY=compact,verbose
#     sbatch --export=ALL --cpus-per-task=<num_opm_threads> slurm-openmp-perf.sh  ./myprogram arg1 arg2 arg3 

# --> check the availab;e partitions : sinfo -f
# --> month-long-cpu     up 31-00:00:0        0/17/0/17 node[1-16,18]
# --> week-long-cpu      up 7-00:00:00        0/17/0/17 node[1-16,18]
# --> day-long-cpu       up 1-00:00:00        0/17/0/17 node[1-16,18]
# --> short-cpu*         up    1:00:00        0/17/0/17 node[1-16,18]
# --> interactive-cpu    up 2-00:00:00        0/17/0/17 node[1-16,18]
# ================================================================
# --> SLURM will likely allocate one of the nodes (node1 to node16) entirely to your job.
#SBATCH --partition=day-long-cpu           ### Partition

# --> Students may setup the name for the job and email
# --> The %x is a SLURM job name placeholder that gets replaced with the job's name when the job runs. In this case
# --> Slurm will use the same jobname to identify the output file and error file.
# --> The job name is useful for tracking and managing jobs, especially when using SLURM commands like squeue or 
# --> when looking at job logs
#SBATCH --job-name=mm1          ### Job Name
#SBATCH --output=%x_out.%j      ### File in which to store job output. x% is a placeholder that gets replaced with the job's name.
#SBATCH --error=%x_err.%j       ### File in which to store job error messages. x% is a placeholder that gets replaced with the job's name.
#SBATCH --mail-type=ALL         ### email alert at start, end and abortion of execution
#SBATCH --mail-user=myemail     ### send mail to this address

# --> The #SBATCH --time=0-00:01:00 directive in your SLURM script specifies the maximum amount 
# --> of wall clock time your job is allowed to run. If you don't specify a time limit, SLURM will 
# --> use the default time limit for the partition
#SBATCH --time=0-01:00:00       ### Wall clock time limit in Days-HH:MM:SS

# --> With --exclusive, even though your job uses all logical cores, the memory and other resources 
# --> on the node will be exclusively reserved for your job, potentially leading to underutilization 
# --> if your job doesn't require them
#SBATCH --exclusive            ### no shared resources within a node

# --> # cpus-per-task: set the maximum logical cores to be allocated. 
#       It is necessary for SLURM to plan ahead
# This job receives the number of threads by parameter and will update --cpus-per-task
#SBATCH --cpus-per-task=48   # will be updated by command line according to the number of threads    
#SBATCH --ntasks=1          # make sure only one instace of the program will run for openMP code

# Set OpenMP environment variables
source /opt/intel/oneapi/setvars.sh
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

if [ "$KMP_AFFINITY" == "compact" ]; then
    echo "KMP_AFFINITY is set to "compact" and hyper-threading will be available"
    export KMP_AFFINITY=compact
fi
if [ -z "$KMP_AFFINITY" ]; then
    echo "KMP_AFFINITY is not set. Defaulting to "compact" and hyper-threading will be available"
    export KMP_AFFINITY=compact
fi
# If KMP_AFFINITY is scatter, apply --hint=nomultithread
if [ "$KMP_AFFINITY" == "scatter" ]; then
    echo "KMP_AFFINITY is scatter. Make sure you submit your job with --hint=nomultithread to disable hyper-threading."
fi

# Get the program name and parameters from the remaining command-line arguments
program_name=$1
shift 1
program_params="$@"

# Ensure the program has the correct path
if [[ ! -x "$program_name" ]]; then
    echo "MSG Error from job: Program $program_name is not executable or not found."
    exit 1
fi

echo "msg from slurm job: Executing: $program_name $program_params"
echo "msg from slurm job: OMP_NUM_THREADS = ${OMP_NUM_THREADS:-1} threads"
echo "msg from slurm job: KMP_AFFINITY= $KMP_AFFINITY"
echo "CPUs per task: ${SLURM_CPUS_PER_TASK:-1}"
echo "SLURM_HINT: $SLURM_HINT"

echo "Running on node: $(hostname)"

# Print information for debugging
echo "Message from job: Running program: $program_name"
echo " with parameters: $program_params"

# Execute and profile the code
vtune -collect performance-snapshot -- $program_name $program_params

# Check the exit status of the program
if [ $? -ne 0 ]; then
    echo "MSg Error from Job: Program $program_name failed to execute."
    exit 1
fi