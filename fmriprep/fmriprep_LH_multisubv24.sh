#!/bin/bash
#SBATCH --job-name=fmriprep
#SBATCH -o /home/hfluhr/logs/learninghabits/fmriprep24/%x-%A/out/%x-%A-%a.out
#SBATCH -e /home/hfluhr/logs/learninghabits/fmriprep24/%x-%A/err/%x-%A-%a.err
##SBATCH --mail-user=hugo.fluhr@econ.uzh.ch
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00

# Use as:
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/learninghabits/dev/participants.tsv | cut -f1 -d' '))) scripts/fmriprep/fmriprep_LH_multisubv24.sh

module load singularityce
IMG="/home/hfluhr/data/containers/fmriprep24"
export SINGULARITYENV_FS_LICENSE=$HOME/freesurfer/license.txt

SUBJ_LIST_DIR="/data/hfluhr/learninghabits/dev"
subID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJ_LIST_DIR}/participants.tsv)
SUBJECT="sub-${subID}"
echo "Processing the anatomical and functional workflows on subject: $SUBJECT"

# Paths
DATADIR="/home/hfluhr/shares-hare/ds-learning-habits"
#DATADIR="/home/hfluhr/data/learninghabits/ds-learninghabits"
WORKDIR="/scratch/hfluhr/workflows/ds-learninghabits/fmriprep_${SLURM_JOB_ID}"
mkdir -p ${WORKDIR}
OUTDIR="${DATADIR}/derivatives"
mkdir -p $OUTDIR

# bindings for container
BINDINGS="-B $DATADIR:/data \
-B ${WORKDIR}:/work \
-B ${OUTDIR}:/out"

FMRIPREP_CMD="/data /out/fmriprep-24.0.1-mem participant --participant-label $SUBJECT \
-w /work \
--mem-mb 50000"

SING_CMD="singularity run --cleanenv $BINDINGS $IMG $FMRIPREP_CMD"
echo $SING_CMD
$SING_CMD
echo "Completed with return code: $?"