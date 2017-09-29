## MAGeTbrain segmentation pipeline

### Description
This pipeline takes in native-space T1 or T2 (or multiple co-registered modalities) brain images and volumetrically segments
them using the MAGeTbrain algorithm.

### Documentation
Provide a link to the documention of your pipeline.

### How to report errors
Provide instructions for users on how to get help and report errors.

### Acknowledgements
Describe how would you would like users to acknowledge use of your App in their papers (citation, a paragraph that can be copy pasted, etc.)

### Usage
This App has the following command line arguments:

```
usage: run.py [-h]
              [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
              [--segmentation_type {amygdala,cerebellum,hippocampus-whitematter,colin27-subcortical,all}]
              [-v] [--n_cpus N_CPUS] [--fast] [--label-masking] [--no-cleanup]
              bids_dir output_dir {participant1,participant2,group}

MAGeTbrain BIDS App entrypoint script.

positional arguments:
  bids_dir              The directory with the input dataset formatted
                        according to the BIDS standard.
  output_dir            The directory where the output files should be stored.
                        When you are running group level analysis this folder
                        must be prepopulated with the results of
                        theparticipant level analysis.
  {participant1,participant2,group}
                        Level of the analysis that will be performed. Multiple
                        participant level analyses can be run independently
                        (in parallel) using the same output_dir. In MAGeTbrain
                        parlance, participant1 = template stage, partipant2 =
                        subject stage group = resample + vote + qc stage. The
                        proper order is participant1, participant2, group

optional arguments:
  -h, --help            show this help message and exit
  --participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]
                        The label(s) of the participant(s) that should be
                        analyzed. The label corresponds to
                        sub-<participant_label> from the BIDS spec (so it does
                        not include "sub-"). If this parameter is not provided
                        all subjects should be analyzed. Multiple participants
                        can be specified with a space separated list.
  --segmentation_type {amygdala,cerebellum,hippocampus-whitematter,colin27-subcortical,all}
                        The segmentation label type to be used.
                        colin27-subcortical, since it is on a different atlas,
                        is not included in the all setting and must be run
                        seperately
  -v, --version         show program's version number and exit
  --n_cpus N_CPUS       Number of CPUs/cores available to use.
  --fast                Use faster (less accurate) registration calls
  --label-masking       Use the input labels as registration masks to reduce
                        computation and (possibily) improve registration
  --no-cleanup          Do no cleanup intermediate files after group phase
```

To run it in participant level mode (for one participant):
```sh
    docker run -i --rm \
		-v /Users/filo/data/ds005:/bids_dataset:ro \
		-v /Users/filo/outputs:/outputs \
		bids/example \
		/bids_dataset /outputs participant --participant_label 01
```
After doing this for all subjects (potentially in parallel), the group level analysis
can be run:
```sh
    docker run -i --rm \
		-v /Users/filo/data/ds005:/bids_dataset:ro \
		-v /Users/filo/outputs:/outputs \
		bids/example \
		/bids_dataset /outputs group
```
### Special considerations
Describe whether your app has any special requirements. For example:

- Multiple map reduce steps (participant, group, participant2, group2 etc.)
- Unusual memory requirements
- etc.
