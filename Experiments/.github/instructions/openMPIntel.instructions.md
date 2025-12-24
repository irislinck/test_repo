---
applyTo: "**/*.{c,cc,cpp,cxx,h,hh,hpp,hxx}"
---

# OpenMP + Intel compiler (oneAPI) project instructions

You are assisting with C/C++ code that uses OpenMP and is built with the Intel compiler toolchain (oneAPI).

## Compiler + build assumptions
- Prefer Intel oneAPI compilers (icx/icpx). If "classic" is used (icc/icpc), keep suggestions compatible.
- Prefer OpenMP flag: `-qopenmp` (Intel). Do not suggest only `-fopenmp` unless explicitly requested.
- Optimization flags should be conservative and portable: `-O2` or `-O3`. Avoid unsafe flags unless asked.
- If suggesting architecture flags, prefer `-xHost` (Intel) only when appropriate; otherwise keep portable.

## OpenMP coding standards (must follow)
- Default to explicit scoping:
  - Use `#pragma omp parallel for default(none)` when feasible
  - Explicitly declare `shared(...)`, `private(...)`, `firstprivate(...)`, `reduction(...)`
- Avoid data races:
  - Prefer `reduction` over `atomic` when correct
  - Prefer `omp critical` only as a last resort (explain performance impact)
- Use correct scheduling:
  - Recommend `schedule(static)` for uniform workloads
  - Recommend `schedule(dynamic, <chunk>)` only when workload is imbalanced (justify)
- Prefer thread-safe patterns:
  - Avoid writing to shared containers in parallel unless protected or partitioned
  - Use per-thread buffers then combine (reduce/merge) when possible

## Performance guidance (important)
- Avoid false sharing:
  - Align/pad per-thread data when necessary
- Prefer contiguous memory access and cache-friendly loops
- When suggesting vectorization:
  - Consider `#pragma omp simd` only when safe
  - Do not suggest `simd` if there are loop-carried dependencies
- If changing parallel regions:
  - Prefer fewer parallel regions and avoid nested parallelism unless requested

## Review expectations
When reviewing or proposing changes:
- Call out possible data races and shared-state hazards
- Mention if a change may increase synchronization overhead
- Mention if a change affects determinism/reproducibility
- Provide a short “How to test” note (compile + run) when you propose OpenMP changes
