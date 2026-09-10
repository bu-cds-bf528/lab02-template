# Lab 2 - Workflow Basics

Today we are going to construct a very basic workflow that downloads a microbial
genome from the NCBI FTP server, and runs a script that calculates some simple
statistics about the genome. We will build this workflow from a primitive version
that we run on the command line and iteratively add features to it to make it
more robust, reproducible, and easy to use. As we do this, I will point out various
features in nextflow that provide many quality-of-life improvements to our workflow.

All of the operations we will be doing are relatively simple and have already been
implemented by others. We are simply building a workflow from the ground up to
understand the components that make up a proper reproducible and robust workflow. 

Feel free to discuss with your classmates, consult google or LLMs, or ask me
questions if you get stuck. We will walk through these exercises together. 

# Setup

1. Open a VSCode interactive session on the SCC in your
student folder in the `/projectnb/bf528/students/<your-bu-username>` directory. 
Replace the `<your-bu-username>` with your BU ID and no @bu.edu.

2. Accept the classroom50 for this lab and clone the repo to 
your directory. Ensure that this newly clone directory is your working directory
in VSCode.

3. Open a terminal and run the following command:

```bash
conda env create -f envs/nextflow_env.yml
```

You will only have to run this command **once**.

4. Make sure to activate the conda environment we just created using the following command:

```bash
conda activate nextflow_latest
```

You will need to **re-run** this command with every new VSCode session as well as 
whenever you open new terminals in the same VSCode session.

5. Before you do the next part, please also run the following commands on any terminal:

```bash
echo 'export NXF_SYNTAX_PARSER=v2' >> ~/.bashrc

source ~/.bashrc

```

You should only have to run this **once**.

6. This lab will be completed in a series of iterations. Each iteration will build
on the previous one and add new features to make the workflow more robust, 
reproducible, and easy to use. Please navigate to the iteration_X/ directory for 
each iteration using `cd`. If you are comfortable in a terminal, be aware of your
working directory. If you are still getting used to things, you can also use
the VSCode (File -> Open Folder...) for each iteration, making sure you do this
separately for each one. 


# Background

A FTP link is a web address that points to a file or directory on a server. It is
a standard protocol for transferring files from a server to a client. The NCBI
hosts a number of resources that we can download and analyze. For example,
today we will be downloading the genomic sequence of Escherichia coli and running
a small python script to calculate the length of the sequence. 

# First Iteration - Simplest workflow

Navigate to the iteration_1/ directory in a terminal using `cd` and perform the following:

1. Download the E. Coli genome using this command:

```bash
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
```

2. Run the script:

```bash
python calc_length.py
```

- [ ] Download the E. Coli genome 
- [ ] Run the script to print out the length of the genome
- [ ] What version of python ran this script?

# Second Iteration - Submitting jobs to the cluster

**Lecture (10 minutes)**

[Basic SCC Usage](https://bu-bioinfo.github.io/bf528/lectures/week-02/)

**Your Turn**

Navigate to the iteration_2/ directory in a terminal and perform the following:

1. Make a new text file called `download_script.sh` that has the following lines:

```bash
#!/bin/bash -l

#$ -P bf528

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
```

2. Run the script using `qsub download_script.sh`

3. Check the status of the job using `qstat -u <your-bu-username>`

4. Do the same for your python script by making a new script called `calc_length_script.sh`.
This should look the same as the download script but with the python command in place
of the wget command.

5. Wait until the file has finished downloading and then run the `calc_length_script.sh`
using `qsub calc_length_script.sh`

6. Check the status of the job using `qstat -u <your-bu-username>`

- [ ] Make a qsub script that downloads the genome
- [ ] Make a qsub script that runs the python script
- [ ] Check the status of your submitted jobs using `qstat`

# Third Iteration - Basic Nextflow workflow

Above would be the simplest example of a bioinformatics pipeline. Nextflow is a
workflow management tool that will help us connect and automate the above 
components into a single pipeline. I have provided you a new script that will 
calculate the GC content of a FASTA file. The previous script `calc_length.py` 
and the `wget` command worked because the base environment on the SCC already
had the necessary tools installed. This will not always be the case, but we can
use conda environments to create custom environments for our workflow with the
packages we want installed. 

Navigate to the iteration_3/ directory in a terminal and take note of the following:

**In the main.nf**

*At the top of the file*

- Note the line `nextflow.enable.types = true`. This turns on Nextflow's
typed syntax for declaring process inputs and outputs, which is what we will
use for the rest of this lab. It is a newer, stricter way of writing
processes where every input and output is given an explicit type.

*Within the `process`*
- The `output` - this specifies the file that will be created or exist
at the end of the process

- With typed syntax, an output is declared as `Type = expression`:

```groovy
output:
Path = file("GCF_000005845.2_ASM584v2_genomic.fna.gz")
```

Here `Path` is the type of the output (i.e. a file or directory), and
`file(...)` tells Nextflow which file, created inside the process's work
directory, should be captured as that output. In Iteration 5 you'll see
outputs can also be given a name, e.g. `length: Path = file('length.txt')`,
which lets you refer to a specific output by name rather than position.

- The `script` - this is where the commands are executed and you can see the
same wget command we ran earlier on the terminal

*Within the `workflow`*
- The `DOWNLOAD()` calls the DOWNLOAD process. Calling a process returns its
output(s), which we assign to a variable, e.g. `dl_genome = DOWNLOAD()`. That
variable can then be passed into another process the same way you would pass
any other variable, e.g. `GC_CONTENT(dl_genome)`. This replaces the older
`PROCESS.out` syntax you may see in other Nextflow examples online.

**In the bin/ directory:**

- The gc_content.py script is located in the bin/ directory - nextflow 
automatically makes any scripts in the bin/ directory available to any process. 
This means that we do not need to pass the script into the process and can 
call it by name in the process as long as we make it executable.

**In the envs/ directory:**

- The biopython_env.yml file is located in the envs/ directory. This should
look exactly like the file used to create your nextflow conda environment. 

- Keep in mind that we do not need to do anything with this file ourselves. Nextflow
will automatically build this environment and activate it for us provided we use
the correct commands. 

**Your Turn:**

1. Use the following command in a terminal to make the script in the bin/ 
directory executable:

```bash
chmod +x bin/gc_content.py
```

Making a script executable allows it to be run as a command in the terminal. It
also allows us to avoid having to specify which interpreter to use to run the
script (as long as it's specified in the script). 

It will also let us call it from a terminal with the following command:

```bash
gc_content.py
```

Notice how we are not required to specify `python` to run the script. 

2. In the `main.nf`, make a new process called GC_CONTENT that takes the 
output of the DOWNLOAD process as input and runs the gc_content.py script on it. 
Structure it with similar syntax as the DOWNLOAD process.

- Declare the input using the typed syntax `name: Path`, e.g. `fasta: Path`.
This gives a name to the incoming file, similar to how `Path = file(...)`
names and types an output.

- Make sure to check the script to see what file it creates and set that as the
output

- At the same indentation level as `input`, `output`, or `script`, please add a
line that looks like: 

```bash
conda 'envs/biopython_env.yml'
```

3. In the workflow block of the `main.nf`, assign the result of `DOWNLOAD()`
to a variable (e.g. `dl_genome = DOWNLOAD()`) and pass that variable into the
GC_CONTENT process, e.g. `gc_content = GC_CONTENT(dl_genome)`

- Call the GC_CONTENT process the same way the DOWNLOAD process was called
- Remember to always explicitly assign the output of processes to a variable

4. Run the nextflow script using `nextflow run main.nf -profile conda,local`

- Note this may take several minutes as Nextflow is creating the conda environment

Notice that when it finished, nextflow created a new directory called `work` and 
stored the output there. As nextflow is running, you will see the name of the process
and a series of letters or numbers indicating the hash of the process. 

![nextflow run information]({{ site.baseurl }}/assets/images/nextflow_run.png)

If you now navigate into your `work/` directory, you will see two directories with
the first two characters of the hash and a subdirectory with the remaining characters of the hash. 

From our above example, the directory would be `work/ab/2496183aa8f126aac4b6a083de6ade/`.
That is where the outputs of the DOWNLOAD process were stored. The terminal 
output only shows the first six unique characters of the hash, but the full hash
is used to identify the process. Your directory location will be different than the one
shown above. 

Every nextflow process will execute in these isolated directories that Nextflow automatically
creates for you. These directories will be populated with any files passed in the
process and will not have access to any other files. 

In this workflow, we are only running two processes and so it's relatively trivial
to determine in what directory our process executes. When we are running many, we will
take advantage of several built-in functionalities in nextflow. 

You may have noticed that when you run nextflow, you can see an often whimsical code name
of two vaguely related science words separated by an underscore. These are run names that
nextflow randomly generates every time you invoke a nextflow workflow. After you have run
this workflow, please use the following command:

```bash
nextflow log
```

This will print out all of the recorded runs tracked by nextflow. Locate the RUN NAME and
now run the following command (remove the <> before running):

```bash
nextflow log <RUN NAME> -f hash,name,exit,status
```

This will print out the hash, name, exit code and status of every process that was executed
by the workflow run. This will enable you in the future to figure out in what directory was
each process executed in. 

- [ ] Write a process that calls the python script provided in the bin/ directory
- [ ] Specify a conda environment for a specific process to use
- [ ] Understand how to find the outputs of specific processes
- [ ] Understand the idea of staging directories
- [ ] Use various commands to find the output directory for any process from a nextflow run
- [ ] Learn how to use profiles to specify options at runtime

# Fourth Iteration - Updating our script to use argparse

Navigate to the iteration_4/ directory.

You may have noticed that the python script we provided in the bin/ directory is not
very flexible. It is hardcoded to work on a specific file and write the output to a specific file.
We will update the script to use argparse to accept input and output file names on the command line.
As you've seen with other command line tools or scripts, we will often pass arguments to a script
on the command line using what are sometimes referred to as flags. These flags usually look like `-i` or `--input`
and are followed by the value of the argument. For example, we might run a script using:

```bash
gc_content.py -i <fasta_file> -o <length_file>
``` 
The values on the command line passed after the arguments will be read by the script,
stored in variables, and used to run the script with the values provided.

This is a common pattern that will enable our scripts to be more flexible and 
reusable. 

## Argparse Resources

[Argparse Guide]({{ site.baseurl }}/guides/argument_parsing/)

[Argparse Documentation]

**Your Turn:**

1. Adjust the python script to use argparse to accept input and output file names on the command line.

- You should have two arguments: one for the input file and one for the output file.

- If you are struggling with this, please use the example script provided in the
directory. It is not in the bin/ directory and you should be able to run it on
the command line using `python argparse_example.py`. Read the message that is
printed to the terminal to understand how to use the script. Look at the script
itself and it should become clear how we use argparse in python scripts.

2. Make the script executable using `chmod +x bin/gc_content.py`

Once finished, the script should be runnable via the following command:

```bash
gc_content.py -i <fasta_file> -o <length_file>
```

3. Go into your main.nf and create a new process that calls the gc_content.py script.

- The process should take the output of the DOWNLOAD process as input and pass it
to the gc_content.py script

- As in Iteration 3, declare the input with the typed syntax `name: Path`,
e.g. `genome: Path`. Whatever name you give it (`genome` in this example) is
the variable you use to refer to that file elsewhere in the process.

- Pass the appropriate files on the command line to the python script. Remember
that you may access values in the input and output of a nextflow process. A
named input may be accessed in the `script` block using the $ symbol followed
by the name you gave it, e.g. `$genome`. 

4. Update the workflow block to call the new process like in the last exercise

- Assign the output of `DOWNLOAD()` to a variable and pass that variable into
your new process, e.g. `dl_genome = DOWNLOAD()` followed by
`gc_content = GC_CONTENT(dl_genome)`.

5. Run the nextflow script using `nextflow run main.nf -profile conda,cluster`

- [ ] Adjust the python script to use argparse
- [ ] Make the script executable
- [ ] Create a new process that calls the gc_content.py script
- [ ] Update the workflow block to call the new process
- [ ] Run the nextflow script  

# Fifth Iteration - Specifying multiple outputs in a process

Sometimes we will want to have a process that creates multiple outputs and pass
the outputs to different processes. Nextflow provides a way to do this using dot notation,
similar to other programming languages. 

Navigate to the iteration_5/ directory and you'll notice a few differences:

1. Look at the script in the bin/ directory. This script now creates two files and 
writes the output to them - gc_content.txt and length.txt. 

2. The main.nf file now has four processes: DOWNLOAD, GENOME_STATS, PRINT_GC, and PRINT_LENGTH.

3. Pay attention to the `output block` of the GENOME_STATS process. It has two outputs,
each given a name:

```bash
output:
    length: Path = file('length.txt')
    gc_content: Path = file('gc_content.txt')
```

Also note that the input for GENOME_STATS is also declared with a typed,
named input, e.g. `genome: Path`, the same as you saw in the previous iteration.

When you call GENOME_STATS in the workflow block, assign the result to a
variable, e.g. `stats = GENOME_STATS(dl_genome)`. Because the outputs above
were given names, you can then access each one individually using dot
notation on that variable: `stats.length` and `stats.gc_content`. This is
how we pass different outputs of the same process to different downstream
processes (PRINT_GC and PRINT_LENGTH).

4. Look at the contents of the genome_stats.py script and properly fill out the
`script` block with the appropriate commands to run the script.

5. Send the appropriate outputs of the GENOME_STATS process to the PRINT_GC and PRINT_LENGTH
processes in the workflow.

6. In your `main.nf`, look at the `publish` block provided for you underneath the workflow
block `main`. Here is where you will specify which files you want to "send" to a directory of your
choice. This is convenient for gathering the important results from a workflow without
having to navigate through the nested structure of the `work/` directory. 

For each process output you want to keep, add a line under `publish` that assigns a name to 
the channel you want published - for example, `fastqc_logs = fastqc_ch`. This name does not
need to be the same as the channel name but you should try to choose something descriptive so
it's easy to intuit what it represents. Do this for all of the outputs you want to easily
access.

Once you've finished listing the outputs under `publish`, look at the `output` block at the
bottom of the workflow script. Every name you assigned in `publish` must appear here as its
own entry. Add an entry for each of your published names (e.g. fastqc_logs {}). Once you have
done this, run the pipeline again and check your `results/` directory - you should see your
published files copied here without the hashed subdirectories in `work`

7. Once finished, run the nextflow script using the following command:

```bash
nextflow run main.nf -profile conda,cluster
```

- [ ] Learn how naming outputs lets us access them individually with dot notation
- [ ] Use the `publish` and `output` blocks to make the pipeline outputs available in `results/`
- [ ] Inspect the work/ directory to see where the outputs are stored and the
various log files that are created
- [ ] Send the appropriate outputs of the GENOME_STATS process to the PRINT_GC and PRINT_LENGTH
processes in the workflow
- [ ] Run the nextflow script
- [ ] Take a look at the nextflow.config file and understand what we store there

# Sixth Iteration

1. Instead of using `wget`, develop a nextflow workflow that instead utilizes
the `ncbi-datasets-cli` tool to download the E. coli genome.

- This process only produces a single, unnamed output, so declare it the same
way as the DOWNLOAD process in earlier iterations: `Path = file(...)`.

**Hints:**

- Check the tool's own help to find the command shape, e.g.
`datasets download genome accession --help`. You'll use the same accession
(`GCF_000005845.2`) you've been using all along.

- The download itself is not a FASTA file - `datasets download` always
produces a zip archive called `ncbi_dataset.zip`. Your `script`/`shell` block
will need to download it and then unzip it before Nextflow can capture a
`.fna` file.

- Remember that each process runs in its own isolated work directory (as we
saw when exploring the `work/` directory in Iteration 3). Wherever you choose
to unzip the archive (e.g. a `dataset/` directory) is relative to that
process's own directory, not the project root.

- Once unzipped, the `.fna` file is nested a few directories deep, in a path
that includes the accession/assembly name again. Rather than hardcoding that
exact path, look into using a glob pattern in your `file(...)` call - `**`
will match across any number of subdirectories, e.g. `file('dataset/**/*.fna')`.

2. Keep the rest of the workflow the same as iteration_5 and run the `genome_stats.py`
script on the downloaded E. Coli genome, including the `publishDir` line you
added to GENOME_STATS.

- Don't forget to include `nextflow.enable.types = true` near the top of this
`main.nf` as well, since we're using the same typed input/output syntax here

# Ending Notes

What aspects of the final iteration can still be improved upon in terms of reproducibility,
portability and usability? Where does it still fall short in terms of ease of reuse?