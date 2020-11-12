#$ -S /bin/bash

#$ -l h_vmem=5G
#$ -l tmem=5G
#$ -l h_rt=200:0:0
#$ -j y
#$ -t 1-5:1
#$ -N BreakRui_Image

# -m a

#$ -cwd

sleep 40

/share/apps/matlabR2013a/bin/matlab -nodisplay -r "cd ..;PuzzleBasedOnRanking_break(${SGE_TASK_ID});exit"