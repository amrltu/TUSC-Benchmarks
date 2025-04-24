## Step-by-Step Process to Run the Benchmark

### Step 1: Set Up the Environment
1. Source MKL Environment:
    - Load MKL variables:
    ```
    source /software/oneapi/mkl/2022.0.2/env/vars.sh 
    ```
    -  Verify:
    ```
    echo $MKLROOT
    ```
2. Check Libraries:
- Ensure MKL libraries are present:
    ```
    ls $MKLROOT/lib/intel64
    ```
    Look for libmkl_core.so, libmkl_intel_lp64.so.

### Step 2: Navigate to Linpack Directory
1. Go to Benchmark Directory:
    The Linpack benchmark is in:
    ```
    cd $MKLROOT/benchmarks/linpack
    ```
    - Confirm the prebuilt binary exists:
    ```
    ls xlinpack_xeon64
    ```

    - If missing, copy it from $MKLROOT/benchmarks/linpack:
    ```
    cp $MKLROOT/benchmarks/linpack/xlinpack_xeon64 .
    ```

2. Ensure Binary is Executable:
    ```
    chmod +x xlinpack_xeon64
    ```

### Step 3: Configure Threading
1. Set Threads:
- Use all logical cores:
    ```
    export OMP_NUM_THREADS=$(nproc)
    ```

- Check core count:
    ```
    nproc
    ```
    Example: 20 cores with hyperthreading = 40 threads.

2. Pin Threads (optional, for better performance):
    ```
    export KMP_AFFINITY=compact,granularity=fine
    ```

### Step 4: Run the Benchmark
1. Execute:
    Run with your input file:
    ```
    ./xlinpack_xeon64 lininput_xeon64
    ```

    This will process all 15 test cases sequentially.
    - Note: ```lininput_xeon64``` is input file for linpack test. You need to make yourself. Sample is attached within this directory.

2. Expected Runtime: 
    - Small sizes (N=1,000–5,000): Seconds per trial. 
    - Large sizes (N=40,000–45,000): Minutes per trial.
    - Total time depends on CPU and trials (e.g., ~10–30 minutes for all tests on a modern CPU).

3. Output:
    Results for each test case, like:

    ```Copy
    Size   LDA    Align. Time(s)    Gflops  Residual
    1000   1000   4      0.12       10.5    1.23e-14
    20000  20016  4      12.34      1234.5  1.23e-13
    ...
    ```
    - Gflops: Performance (e.g., 1234.5 Gflops = 1.234 TeraFLOPS).
    - Residual: Accuracy (smaller is better, <1.0 is good).

### Step 5: Save Results
1. Redirect Output:
    ```
    ./xlinpack_xeon64 lininput_xeon64 > linpack_results.txt
    ```
2. Review:
    - Check linpack_results.txt for Gflops, residuals, and runtimes.


### Step 6: Optimize and Tune
1. Check Memory:
    - N=45,000 requires ~16.2GB. Verify available RAM:
    ```
    free -h
    ```
    - If insufficient, reduce max N (e.g., to 30,000, ~7.2GB):
    ```
    sed -i 's/45000/30000/g' lininput_xeon64
    sed -i 's/15/12/' lininput_xeon64  # Update number of tests
    ```
2. Adjust Threads:
    - Test with fewer threads if performance is suboptimal:
    ```
    export OMP_NUM_THREADS=16
    ```

    - Run again and compare Gflops.
3. CPU Frequency:
    - Ensure max performance:
    ```
    lscpu | grep MHz
    ```

    - Set performance governor (if available):

4. AVX-512:
    - MKL 2022.0.2 uses AVX-512 if your CPU supports it (e.g., Xeon Scalable).
    ```
    lscpu | grep avx512
    ```

5. Cooling:
- Monitor temperatures:(using lm-sensors)
    ```
    sensors
    ```
    - Ensure no thermal throttling.

### Step 7: Interpret Results

Performance:
- Small N (1,000–5,000): Low Gflops due to overhead.
- Large N (20,000–45,000): Peak Gflops, closer to CPU’s theoretical max.
- Example: A 16-core Xeon might achieve 1–3 TeraFLOPS for N=20,000+.
Share Hardware: Provide CPU model (e.g., via lscpu) and RAM size for precise performance estimates.

<hr>

## Run using Slurm
There is slurm bash file in ```run_linpack.slurm```:

### Explanation of SLURM Directives
- --job-name: Names the job linpack_benchmark.
- --nodes=1: Requests one node (cnode4).
- --ntasks=1: Runs a single task (Linpack is single-process with OpenMP threading).
- --cpus-per-task=20: Allocates 20 CPU cores for OpenMP.
- --mem=240G: Requests 240 GB (leaving ~16 GB for system overhead).
- --time=02:00:00: Sets a 2-hour limit (adjust based on expected runtime).
- --partition=general: Assumes a general partition (modify if your cluster uses a different partition).
- --nodelist=cnode4: Specifies cnode4.
- --output and --error: Saves output and errors to files with job ID.

### Script Details
- Environment Setup: Sources MKL 2022.0.2 environment variables.
- Threading: Sets OMP_NUM_THREADS=20 and pins threads with KMP_AFFINITY.
- CPU Optimization: Attempts to set performance governor (requires cpufrequtils and permissions).
- Input Validation: Ensures lininput_xeon64 exists.
- Execution: Runs the benchmark and logs start/end times.
- Results: Saves output to ```linpack_results_<job_id>.txt```.