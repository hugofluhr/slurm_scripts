#!/bin/bash
#SBATCH --job-name=fmriprep-anat
#SBATCH -o /home/hfluhr/logs/fmriprep/out/%x-%A-%a.out
#SBATCH -e /home/hfluhr/logs/fmriprep/err/%x-%A-%a.err
##SBATCH --mail-user=hugo.fluhr@econ.uzh.ch
##SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=30G
#SBATCH --time=20:00:00
# what is this line below doing? smth with using zsh
# source /etc/profile.d/lmod.sh
# Use as:
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/gera_data/participants_yifei.tsv | cut -f1 -d' '))) scripts/fmriprep/fmriprep_anatonly.sh

module load singularityce
IMG="/home/hfluhr/data/containers/fmriprep"
export SINGULARITYENV_FS_LICENSE=$HOME/freesurfer/license.txt

SUBJ_LIST_DIR="/data/hfluhr/gera_data"
subID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJ_LIST_DIR}/participants_yifei.tsv)
SUBJECT="sub-${subID}"
echo "Processing the anatomical workflow on subject: $SUBJECT"

# Paths
DATADIR="/home/hfluhr/shares-hare/ds004299"
WORKDIR="/scratch/hfluhr/workflows/gera_data/"
mkdir -p ${WORKDIR}
OUTDIR="${DATADIR}/derivatives"
mkdir -p $OUTDIR

# bindings for container
BINDINGS="-B $DATADIR:/data \
-B ${WORKDIR}:/work \
-B ${OUTDIR}:/out"

FMRIPREP_CMD="/data /out/fmriprep-23.2.1 participant --participant-label $SUBJECT \
-w /work \
--anat-only --skip-bids-validation \
--nprocs 4 --mem 25G --omp-nthreads 16"

SING_CMD="singularity run --cleanenv $BINDINGS $IMG $FMRIPREP_CMD"
echo $SING_CMD
$SING_CMD
echo "Completed with return code: $?"