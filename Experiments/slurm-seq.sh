#!/bin/bash

# ======================== Comments ==============================
# This job run sequential programs on Heracles Cluster
# ----------------------------------------------------------------
# Submit this job as
# sbatch slurm-seq.sh ./my_program arg1 arg2 arg3
# 
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
#SBATCH --job-name=myjobname    ### Job Name
#SBATCH --output=%x_out.%j      ### File in which to store job output. x% is a placeholder that gets replaced with the job's name.
#SBATCH --error=%x_err.%j       ### File in which to store job error messages. x% is a placeholder that gets replaced with the job's name.
#SBATCH --mail-type=ALL         ### email alert at start, end and abortion of execution
#SBATCH --mail-user=myemail     ### send mail to this address

# --> The #SBATCH --time=0-00:01:00 directive in your SLURM script specifies the maximum amount 
# --> of wall clock time your job is allowed to run. If you don't specify a time limit, SLURM will 
# --> use the default time limit for the partition
#SBATCH --time=0-01:00:00       ### Wall clock time limit in Days-HH:MM:SS

# --> --men - This directive allocates 10 GB of system memory (RAM) on the CPU of the node where 
#     your job runs. This is the memory that your CPU tasks (including data transfers to/from the GPU) 
#     will use. It does not refer to the GPU's memory.
# --> Omit --mem if you know that the default memory allocation is more than enough for your job's needs
#     or if memory is automatically allocated based on GPU usage. In this case the default  is unlimited
# --> use < scontrol show partition day-long-cpu > to check memory default for this cluster
#SBATCH --mem=10G                         # Request maximum memory            

# Capture the program name and parameters from the command line arguments
program_name=$1
shift 1  # Shift the positional parameters to the left (so $2 becomes $1, etc.)
program_params="$@"

# Print information for debugging
echo "Message from job: Running program: $program_name with parameters: $program_params"

# Run the program with the given parameters
$program_name $program_params

