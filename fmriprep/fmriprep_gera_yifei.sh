#!/bin/bash
#SBATCH --job-name=fmriprep
#SBATCH -o /home/hfluhr/logs/out/res_fmriprep_%x-%A-%a.out
#SBATCH -e /home/hfluhr/logs/err/res_fmriprep_%x-%A-%a.err
#SBATCH --mail-user=hugo.fluhr@econ.uzh.ch
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00
# what is this line below doing?
# source /etc/profile.d/lmod.sh
# Use as:
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/gera_data/participants_yifei.tsv | cut -f1 -d' '))) scripts/fmriprep/fmriprep_gera_yifei.sh

module load singularityce

export SINGULARITYENV_FS_LICENSE=$HOME/freesurfer/license.txt

SUBJ_LIST_DIR="/data/hfluhr/gera_data"
subID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJ_LIST_DIR}/participants_yifei.tsv)
subject="sub-${subID}"
echo $subject

# export SINGULARITYENV_TEMPLATEFLOW_HOME=/opt/templateflow
singularity run --cleanenv -B /home/hfluhr/shares-hare/ds004299:/ds004299 -B /scratch/hfluhr/workflows:/workflow /home/hfluhr/data/containers/fmriprep /ds004299 /ds004299/derivatives participant --participant-label $subject --skip_bids_validation -w /workflow --bids-filter /home/hfluhr/data/gera_data/bids_filter.json