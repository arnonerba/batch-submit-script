# Batch Submit
This project is a functional proof-of-concept Bash script designed to allow multiple processes to be run sequentially in the background on Linux. It is designed so that multiple scripts for programs such as R or Stata can be run in the background without interfering with each other or requiring manual intervention. Output from scripts will be written to a file created by `mktemp` in the same directory as the submitted script.

## Usage
```
usage: batch-submit -p PROGRAM -f file
       batch-submit -p PROGRAM -f file1 -f file2 ... 
       batch-submit -p PROGRAM [-a ARGS] -f file1 -f file2 ... 
```
*Note: arguments containing spaces must be quoted or escaped, as shown below.*

## Examples
```
batch-submit -p /usr/bin/R -f file1.R -f file2.R
```
```
batch-submit -p /usr/bin/R -a "--quiet --vanilla" -f file1.R -f file2.R
```
