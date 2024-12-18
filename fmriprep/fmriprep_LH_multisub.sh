#!/bin/bash
#SBATCH --job-name=fmriprep
#SBATCH -o /home/hfluhr/logs/learninghabits/fmriprep/%x-%A/out/%x-%A-%a.out
#SBATCH -e /home/hfluhr/logs/learninghabits/fmriprep/%x-%A/err/%x-%A-%a.err
##SBATCH --mail-user=hugo.fluhr@econ.uzh.ch
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00

# Use as:
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/learninghabits/dev/participants.tsv | cut -f1 -d' '))) scripts/fmriprep/fmriprep_LH_multisub.sh

module load singularityce
IMG="/home/hfluhr/data/containers/fmriprep23"
export SINGULARITYENV_FS_LICENSE=$HOME/freesurfer/license.txt

SUBJ_LIST_DIR="/data/hfluhr/learninghabits/dev"
subID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJ_LIST_DIR}/participants.tsv)
SUBJECT="sub-${subID}"
echo "Processing the anatomical and functional workflows on subject: $SUBJECT"

# Paths
DATADIR="/home/hfluhr/shares-hare/ds-learning-habits"
#DATADIR="/home/hfluhr/data/learninghabits/ds-learninghabits"
WORKDIR="/scratch/hfluhr/workflows/ds-learninghabits"
mkdir -p ${WORKDIR}
OUTDIR="${DATADIR}/derivatives"
mkdir -p $OUTDIR

# bindings for container
BINDINGS="-B $DATADIR:/data \
-B ${WORKDIR}:/work \
-B ${OUTDIR}:/out"

FMRIPREP_CMD="/data /out/fmriprep-23.2.1_new participant --participant-label $SUBJECT \
-w /work"

SING_CMD="singularity run --cleanenv $BINDINGS $IMG $FMRIPREP_CMD"
echo $SING_CMD
$SING_CMD
echo "Completed with return code: $?"