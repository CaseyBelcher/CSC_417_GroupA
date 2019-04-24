# CSC_417_GroupA
Austen Adler, Bryan Arrington, and Casey Belcher

## Project 2 part 1
For project 2 part 1, we implemented `duo` using `typescript`.

Easy install/run:
```bash
./hw2.sh
# To test our part
make dom
# To test the whole pipeline
make rank
```
Note that the easy run script assumes you do not have node installed. If you already have node installed, the script will work only if you have a recent version (i.e. you execute node by running `node`, not `nodejs`).
If you have an older version of node installed, please make a new codeanywhere instance.

If that fails, try running the commands individually:
```bash
cd duo/src

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get -y install nodejs build-essential

cd team-a
npm i
cd ..
ln -s team-a/node_modules .

../etc/ide
# To test our part
make dom
# To test the whole pipeline
make rank
```

Our report for 2A is located at root and is the file 2a_report.pdf. 



## Project 2 part 2
Our report for 2B is located at root and the file is 2b_report.pdf.



## Homework 1A
Run:
```bash
./hwa/onea
```

## Homework 1B
 
Run: 
```
cd ./hwb
./oneb.st
```

## Homework 1C 
Part 1 answers located at: 
```
./hwc/prolog1c.txt
```
Run Parts 2-3: 
```
./hwc/prolog1c.lisp
```

## Homework 1D
Run: 
```
./hwd/oo1d.lisp
```
