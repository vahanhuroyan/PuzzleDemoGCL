#$ -S /bin/bash

#$ -l h_vmem=20G
#$ -l tmem=20G
#$ -l h_rt=200:0:0
#$ -j y
#$ -t 1-6:1
#$ -N dataset5

# -m a

#$ -cwd

sleep 40

/share/apps/matlabR2013b/bin/matlab -nodisplay -r "run_dataset5_on_cluster(${SGE_TASK_ID});exit"