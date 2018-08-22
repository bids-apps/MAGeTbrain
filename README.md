## MAGeTbrain segmentation pipeline

### Description
This pipeline takes in native-space T1 brain images and volumetrically segments
them using the MAGeTbrain algorithm using a variety of input atlases.

### Documentation
https://github.com/cobralab/antsRegistration-MAGet.

### How to report errors
Please open an issue at https://github.com/BIDS-Apps/MAGeTbrain/issues

### Acknowledgements
Describe how would you would like users to acknowledge use of your App in their papers (citation, a paragraph that can be copy pasted, etc.)

### Usage
This App has the following command line arguments:

```
usage: run.py [-h]
              [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
              [--segmentation_type {amygdala,cerebellum,hippocampus-whitematter,colin27-subcortical,all}]
              [-v] [--n_cpus N_CPUS] [--fast] [--label-masking] [--no-cleanup]
              bids_dir output_dir {participant1,participant2}

MAGeTbrain BIDS App entrypoint script.

positional arguments:
  bids_dir              The directory with the input dataset formatted
                        according to the BIDS standard.
  output_dir            The directory where the output files should be stored.
                        When you are running partipant2 level analysis this folder
                        must be prepopulated with the results of
                        the participant1 level analysis.
  {participant1,participant2}
                        Level of the analysis that will be performed. Multiple
                        participant{1,2} level analyses can be run
                        independently (in parallel) using the same output_dir.
                        In MAGeTbrain parlance, participant1 = template stage,
                        partipant2 = subject + resample + vote + qc stage. The
                        proper order is participant1, participant2

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
                        separately
  -v, --version         show program's version number and exit
  --n_cpus N_CPUS       Number of CPUs/cores available to use.
  --fast                Use faster (less accurate) registration calls
  --label-masking       Use the input labels as registration masks to reduce
                        computation and (possibly) improve registration
  --no-cleanup          Do no cleanup intermediate files after group phase
```

To run construct the template library, run the participant1 stage:
```sh
    docker run -i --rm \
		-v /Users/filo/data/ds005:/bids_dataset:ro \
		-v /Users/filo/outputs:/outputs \
		bids/example \
		/bids_dataset /outputs participant1 --participant_label 01
```

After doing this for approximately 21 representative subjects (potentially in parallel),
the subject level labeling can be done:
can be run:
```sh
    docker run -i --rm \
		-v /Users/filo/data/ds005:/bids_dataset:ro \
		-v /Users/filo/outputs:/outputs \
		bids/example /outputs participants2 --participant_label 01
```
This can also happen in parallel on a per-subject basis

### Special considerations
- segmentation_types output directories must be kept separate for each type
- participant1 stages can be run in parallel per subject, approximately 21
subjects should be selected which are a representative subset of the population
under study
- participant2 stages can also be run in parallel, but must be started after
participant1 stages are complete
