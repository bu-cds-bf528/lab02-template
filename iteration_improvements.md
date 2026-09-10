# Pipeline Evolution: Iterations 1–6

A concise summary of what changes at each iteration and which aspects it improves
upon with regards to portability, reproducibility and scalability. 

## Overall Changes

- **Iterations 1–2**: no environment/dependency management at all; only the *execution location* changes (login node → cluster job).
- **Iteration 3**: introduces Nextflow itself plus the core reproducibility unit — a per-process conda environment defined in a version-controlled `.yml` file.
- **Iteration 4**: scripts become parameterized/reusable, and the executor becomes a runtime choice (`profile`) rather than a code change.
- **Iteration 5**: outputs become structured and discoverable (`results/`)
- **Iteration 6**: proves the per-process isolation model by running two processes

**Still open (per the lab's own "Ending Notes" prompt):** single hardcoded organism/accession and filename, no `params`-driven inputs, no container option (Docker/Singularity) alongside conda, no automated tests/CI, and no resource directives (cpus/memory) actually attached to `process_single` yet.

## How Nextflow Handles Conda Environments Per Process

Nextflow manages conda environments **per process**, not globally for the whole pipeline:

1. **Declaration is local to the process.** A process opts in with a `conda` directive pointing at an environment file (`conda 'envs/biopython_env.yml'`) or an inline package spec. Nothing else in the pipeline is affected.

2. **Nextflow handles most of the work.** Nextflow will build these isolated conda environments or download container images, and activate and use them as specified *per* process. This will generally be our model where every task will run in a defined environment with a single (or a few) tools installed. 

This is functionally the same isolation model containers provide (one process = one isolated dependency set), just implemented with conda instead of Docker/Singularity images — which is also why swapping to `docker`/`singularity` profiles later is a natural next step rather than a redesign.
