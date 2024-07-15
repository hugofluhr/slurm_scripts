#!/bin/bash
#SBATCH --job-name=mriqc
#SBATCH -o /home/hfluhr/logs/learning-habits/dev/mriqc/out/%x-%A-%a.out
#SBATCH -e /home/hfluhr/logs/learning-habits/dev/mriqc/err/%x-%A-%a.err
##SBATCH --mail-user=hugo.fluhr@econ.uzh.ch
##SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=24:00:00
# what is this line below doing?
# source /etc/profile.d/lmod.sh
# Use as:
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/gera_data/participants_yifei.tsv | cut -f1 -d' '))) scripts/mriqc/mriqc_batch.sh
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/learninghabits/dev/participants.tsv | cut -f1 -d' '))) scripts/mriqc/mriqc_batch.sh
# sbatch --array=1-3 scripts/mriqc/mriqc_batch.sh


module load singularityce

SUBJ_LIST_DIR="/data/hfluhr/learninghabits/dev"
subID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJ_LIST_DIR}/participants.tsv)
subject="sub-${subID}"
echo $subject

#singularity run --cleanenv -B /home/hfluhr/shares-hare/ds004299:/ds004299 -B /scratch/hfluhr/workflows:/workflow /home/hfluhr/data/containers/mriqc /ds004299 /ds004299/derivatives/mriqc participant --participant-label $subject -w /workflow/mriqc_run1 --session-id 3 --run-id 4
#singularity run --cleanenv /home/hfluhr/data/containers/mriqc --version
singularity run --cleanenv -B /home/hfluhr/shares-hare/ds-learning-habits:/ds-learning-habits -B /scratch/hfluhr/workflows:/workflow /home/hfluhr/data/containers/arch/mriqc /ds-learning-habits /ds-learning-habits/derivatives/mriqc participant --participant-label $subject -w /workflow/learning-habits/dev/mriqc