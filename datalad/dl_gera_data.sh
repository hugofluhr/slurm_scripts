#!/bin/bash
#SBATCH -J dl_gera_data
#SBATCH --time=4:00:00
#SBATCH -n 1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8G
# Outputs ----------------------------------
#SBATCH -o /home/hfluhr/logs/datalad/out/%x-%A-%a.out
#SBATCH -e /home/hfluhr/logs/datalad/err/%x-%A-%a.err
# ------------------------------------------
# Run as
# sbatch --array=1-$(( $(wc -l /home/hfluhr/data/gera_data/participants_yifei.tsv | cut -f1 -d' '))) scripts/datalad/dl_gera_data.sh 

module load mamba
source activate datalad
cd shares-hare/ds004299/

SUBJ_LIST_DIR="/data/hfluhr/gera_data"
#subject=$( sed -n -E "$((${SLURM_ARRAY_TASK_ID} + 1))s/sub-(\S*)\>.*/\1/gp" ${SUBJ_LIST_DIR}/participants_yifei.tsv )
#subject=$(sed -n -E "$((${SLURM_ARRAY_TASK_ID} + 1))s/sub-(\S*).*/\1/p" "${SUBJ_LIST_DIR}/participants_yifei.tsv")
subID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJ_LIST_DIR}/participants_yifei.tsv)

subject="sub-${subID}"
echo $subject
datalad get $subject/ses-3/anat/*
datalad get $subject/ses-3/fmap/*
datalad get $subject/ses-3/func/*run-04*
datalad get $subject/ses-3/func/*extinction*
