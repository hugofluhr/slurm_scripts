#!/bin/bash
#SBATCH --job-name=fmriprep
#SBATCH -o /home/hfluhr/logs/fmriprep/%x-%A/out/%x-%A-%a.out
#SBATCH -e /home/hfluhr/logs/fmriprep/%x-%A/err/%x-%A-%a.err
##SBATCH --mail-user=hugo.fluhr@econ.uzh.ch
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=24:00:00

# Use as:
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/gera_data/participants_yifei.tsv | cut -f1 -d' '))) scripts/fmriprep/fmriprep_bold.sh "extinction"

module load singularityce
IMG="/home/hfluhr/data/containers/fmriprep"
export SINGULARITYENV_FS_LICENSE=$HOME/freesurfer/license.txt

subID=$(printf "%02d" $SLURM_ARRAY_TASK_ID)
SUBJECT="sub-${subID}"
echo "Processing the anatomical and functional workflows on subject: $SUBJECT"

# Paths
DATADIR="/home/hfluhr/data/learninghabits/ds-learninghabits"
WORKDIR="/scratch/hfluhr/workflows/ds-learninghabits"
mkdir -p ${WORKDIR}
OUTDIR="${DATADIR}/derivatives"
mkdir -p $OUTDIR

# bindings for container
BINDINGS="-B $DATADIR:/data \
-B ${WORKDIR}:/work \
-B ${OUTDIR}:/out"

FMRIPREP_CMD="/data /out/fmriprep-23.2.1 participant --participant-label $SUBJECT \
-w /work \
--skip-bids-validation"

SING_CMD="singularity run --cleanenv $BINDINGS $IMG $FMRIPREP_CMD"
echo $SING_CMD
$SING_CMD
echo "Completed with return code: $?"