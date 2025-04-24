#!/bin/bash
#SBATCH --job-name=linpack_benchmark
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=240G
#SBATCH --time=02:00:00
#SBATCH --partition=normal
#SBATCH --nodelist=cnode4 
#SBATCH --output=linpack_%j.out
#SBATCH --error=linpack_%j.err

# Load MKL environment
source /software/oneapi/mkl/2022.0.2/env/vars.sh

# Set working directory (adjust if needed)
WORK_DIR=$SLURM_SUBMIT_DIR
cd $WORK_DIR


# Set threading for 20 cores
export OMP_NUM_THREADS=20
export KMP_AFFINITY=compact,granularity=fine


# Verify input file
if [ ! -f lininput_xeon64 ]; then
    echo "Error: lininput_xeon64 not found!"
    exit 1
fi

# Run Linpack benchmark
echo "Starting Linpack benchmark on $(hostname) at $(date)"
cd $MKLROOT/benchmarks/mp_linpack/
./xhpl_intel64_dynamic lininput_xeon64
echo "Linpack benchmark completed at $(date)"

# Save results
mv linpack_$SLURM_JOB_ID.out linpack_results_$SLURM_JOB_ID.txt