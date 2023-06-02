#! /bin/bash

set -eux -o pipefail

# Get a test dataset from OSF and extract it to $HOME/data
#
# source: https://osf.io//9q7dv/
#
# USAGE:
#
# - run:
#     name: Get test data
#     command: |
#       wget https://raw.githubusercontent.com/bids-apps/maintenance-tools/main/utils/get_data_from_osf.sh
#       bash get_data_from_osf.sh name_of_the_dataset
#

# shellcheck disable=SC2128

dry_run=false

dataset=$1

tar_datasets=("ds114_test1 ds114_test2 ds114_test1_freesurfer ds114_test2_freesurfer ds005-deriv-light ds114_test1_freesurfer_precomp_v6.0.0 ds114_test2_freesurfer_precomp_v6.0.0 ds003_downsampled")
tar_gz_datasets=("ds114_test1_with_freesurfer ds114_test1_with_freesurfer_and_fsaverage")
zip_datasets=("hcp_example_bids_v3 lifespan_example_bids_v3")

if [[ " ${tar_datasets[*]} " =~ ${dataset} ]]; then
  extension="tar"
elif [[ " ${zip_datasets[*]} " =~ ${dataset} ]]; then
  extension="zip"
elif [[ " ${tar_gz_datasets[*]} " =~ ${dataset} ]]; then
  extension="tar.gz"
fi

if [ "${dataset}" = "ds114_test1" ]; then
  ds_download_prefix="zerfq"
elif [ "${dataset}" = "ds114_test2" ]; then
  ds_download_prefix="eg4ma"
elif [ "${dataset}" = "ds114_test1_freesurfer" ]; then
  ds_download_prefix="vx5pu"
elif [ "${dataset}" = "ds114_test2_freesurfer" ]; then
  ds_download_prefix="myhwm"
elif [ "${dataset}" = "ds005-deriv-light" ]; then
  ds_download_prefix="ye7rx"
elif [ "${dataset}" = "ds114_test1_freesurfer_precomp_v6.0.0" ]; then
  ds_download_prefix="j6zk2"
elif [ "${dataset}" = "ds114_test2_freesurfer_precomp_v6.0.0" ]; then
  ds_download_prefix="yhzzj"
elif [ "${dataset}" = "hcp_example_bids_v3" ]; then
  ds_download_prefix="6429f"
elif [ "${dataset}" = "lifespan_example_bids_v3" ]; then
  ds_download_prefix="epv7m"
elif [ "${dataset}" = "ds003_downsampled" ]; then
  ds_download_prefix="8s29u"
elif [ "${dataset}" = "ds114_test1_with_freesurfer" ]; then
  ds_download_prefix="y4q8a"
elif [ "${dataset}" = "ds114_test1_with_freesurfer_and_fsaverage" ]; then
  ds_download_prefix="nz3af"
else
  : "UNKNOWN DATASET: first argument must be one of the following"
  : "-" "${tar_datasets[@]}"
  : "-" "${tar_gz_datasets[@]}"
  : "-" "${zip_datasets[@]}"
  : "got ${dataset}"
  exit 1
fi

mkdir -p "${HOME}/data"
if [[ ! -d "${HOME}/data/${dataset}" ]]; then

  : "Downloading ${dataset}.${extension} from https://osf.io/download/${ds_download_prefix}"

  if [ "${dry_run}" = false ]; then

    wget --retry-connrefused \
      --waitretry=5 \
      --read-timeout=20 \
      --timeout=15 \
      -t 0 \
      -q \
      -O "${HOME}/${dataset}.${extension}" \
      "https://osf.io/download/${ds_download_prefix}"

    if [ "${extension}" = "tar" ]; then
      tar -xvf "${HOME}/${dataset}.${extension}" -C "${HOME}/data"
    elif [ "${extension}" = "tar.gz" ]; then
      tar -xvzf "${HOME}/${dataset}.${extension}" -C "${HOME}/data"
    elif [ "${extension}" = "zip" ]; then
      unzip -d "${HOME}/data" "${HOME}/${dataset}.${extension}"
    fi

  fi

else
  : "Dataset ${dataset} was cached"
fi
