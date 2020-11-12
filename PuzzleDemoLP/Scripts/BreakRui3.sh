#$ -S /bin/bash

#$ -l h_vmem=5G
#$ -l tmem=5G
#$ -l h_rt=200:0:0
#$ -j y
#$ -t 1-20:1
#$ -N BreakRui

# -m a

#$ -cwd

sleep 40

/share/apps/matlabR2013a/bin/matlab -nodisplay -r "cd ..;PuzzleBasedOnRanking_break(${SGE_TASK_ID}-20);exit"
