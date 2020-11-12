#$ -S /bin/bash

#$ -l h_vmem=5G
#$ -l tmem=5G
#$ -l h_rt=200:0:0
#$ -j y
#$ -t 20-60:5
#$ -N BreakGallagher

# -m a

#$ -cwd

sleep 40

/share/apps/matlabR2013a/bin/matlab -nodisplay -r "cd ..;PuzzleDemoMGC_break(${SGE_TASK_ID});exit"
