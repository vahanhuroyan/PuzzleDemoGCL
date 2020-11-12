#$ -S /bin/bash

#$ -l h_vmem=5G
#$ -l tmem=5G
#$ -l h_rt=200:0:0
#$ -j y
#$ -t 1-100:1
#$ -N BreakGallagher_Image

# -m a

#$ -cwd

sleep 40

/share/apps/matlabR2013a/bin/matlab -nodisplay -r "cd ..;PuzzleDemoMGC_Rotbreak(${SGE_TASK_ID});exit"