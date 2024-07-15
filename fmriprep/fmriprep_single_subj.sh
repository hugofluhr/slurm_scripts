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
module load singularityce
export SINGULARITYENV_FS_LICENSE=$HOME/freesurfer/license.txt
export PARTICIPANT_LABEL=$(printf "%02d" $SLURM_ARRAY_TASK_ID)
# export SINGULARITYENV_TEMPLATEFLOW_HOME=/opt/templateflow
singularity run --cleanenv -B /home/hfluhr/data/learninghabits/ds-learninghabits:/ds-learninghabits -B /scratch/hfluhr/workflows:/workflow /home/hfluhr/data/containers/fmriprep /ds-learninghabits /ds-learninghabits/derivatives participant --participant-label sub-01 --skip_bids_validation -w /workflow