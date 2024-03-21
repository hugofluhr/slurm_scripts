#!/bin/bash
#SBATCH --job-name=fmriprep-bold
#SBATCH -o /home/hfluhr/logs/fmriprep/%x-%A/out/%x-%A-%a.out
#SBATCH -e /home/hfluhr/logs/fmriprep/%x-%A/err/%x-%A-%a.err
##SBATCH --mail-user=hugo.fluhr@econ.uzh.ch
##SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=24:00:00
# what is this line below doing?
# source /etc/profile.d/lmod.sh
# Use as:
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/gera_data/participants_yifei.tsv | cut -f1 -d' '))) scripts/fmriprep/fmriprep_bold.sh "extinction"

module load singularityce
IMG="/home/hfluhr/data/containers/fmriprep"
export SINGULARITYENV_FS_LICENSE=$HOME/freesurfer/license.txt

SUBJ_LIST_DIR="/data/hfluhr/gera_data"
subID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJ_LIST_DIR}/participants_yifei.tsv)
SUBJECT="sub-${subID}"
echo "Processing the functional workflow on subject: $SUBJECT"

# Paths
DATADIR="/home/hfluhr/shares-hare/ds004299"
WORKDIR="/scratch/hfluhr/workflows/gera_data"
mkdir -p ${WORKDIR}
OUTDIR="${DATADIR}/derivatives"
mkdir -p $OUTDIR

# bindings for container
BINDINGS="-B $DATADIR:/data \
-B ${WORKDIR}:/work \
-B ${OUTDIR}:/out"

# processing only 1 session
RUN=$1
if [ $RUN = "extinction" ]
then
    echo '{"bold": {"datatype": "func", "session": "3", "suffix": "extinction_bold"}}' > ${WORKDIR}/filter_file_${RUN}.json
elif [ $RUN = "run4" ]
then
    echo '{"bold": {"datatype": "func", "session": "3", "run": "4", "suffix": "bold"}}' > ${WORKDIR}/filter_file_${RUN}.json
else
    echo 'invalid run identifier, can be "extinction" or "run4"'
fi

FMRIPREP_CMD="/data /out/fmriprep-23.2.1 participant --participant-label $SUBJECT \
-w /work \
--bids-filter-file /work/filter_file_${RUN}.json \
--skip-bids-validation \
--fs-subjects-dir /out/fmriprep-23.2.1/sourcedata/freesurfer \
--derivatives /out/fmriprep-23.2.1 \
--nprocs 4 --mem 25G --omp-nthreads 8"

SING_CMD="singularity run --cleanenv $BINDINGS $IMG $FMRIPREP_CMD"
echo $SING_CMD
$SING_CMD
echo "Completed with return code: $?"