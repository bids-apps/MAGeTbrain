#!/usr/bin/env python
import argparse
import errno
import os
import shlex
import shutil
import subprocess
from glob import glob

from bids.grabbids import BIDSLayout

__version__ = open(os.path.join('/version')).read()


def symlink_force(target, link_name):
    try:
        os.symlink(target, link_name)
    except OSError as e:
        if e.errno == errno.EEXIST:
            os.remove(link_name)
            os.symlink(target, link_name)
        else:
            raise e


def run(command, env={}):
    merged_env = os.environ
    merged_env.update(env)
    process = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT,
                               env=merged_env)
    while True:
        line = process.stdout.readline()
        line = str(line, 'utf-8')[:-1]
        print(line)
        if line == '' and process.poll() is not None:
            break
    if process.returncode != 0:
        raise Exception("Non zero return code: {0}".format(process.returncode))


parser = argparse.ArgumentParser(
    description='MAGeTbrain BIDS App entrypoint script.')
parser.add_argument('bids_dir', help='The directory with the input dataset '
                    'formatted according to the BIDS standard.')
parser.add_argument('output_dir', help='The directory where the output files '
                    'should be stored. When you are running group level analysis '
                    'this folder must be prepopulated with the results of the'
                    'participant level analysis.')
parser.add_argument('analysis_level', help='Level of the analysis that will be performed. '
                    'Multiple participant{1,2} level analyses can be run independently '
                    '(in parallel) using the same output_dir. '
                    'In MAGeTbrain parlance, participant1 = template stage, '
                    'partipant2 = subject + resample + vote + qc stage. '
                    'The proper order is participant1, participant2',
                    choices=['participant1', 'participant2'])
parser.add_argument('--participant_label', help='The label(s) of the participant(s) that should be analyzed. The label '
                    'corresponds to sub-<participant_label> from the BIDS spec '
                    '(so it does not include "sub-"). If this parameter is not '
                    'provided all subjects should be analyzed. Multiple '
                    'participants can be specified with a space separated list.',
                    nargs="+")
parser.add_argument('--segmentation_type', help='The segmentation label type to be used.'
                    ' colin27-subcortical, since it is on a different atlas, is not included '
                    'in the all setting and must be run separately',
                    choices=['amygdala', 'cerebellum',
                             'hippocampus-whitematter', 'colin27-subcortical', 'all'],
                    default='all')
parser.add_argument('-v', '--version', action='version',
                    version='MAGeTbrain version {}'.format(__version__))
parser.add_argument('--n_cpus', help='Number of CPUs/cores available to use.',
                    default=1, type=int)
parser.add_argument('--fast', help='Use faster (less accurate) registration calls and float'
                    ' for numerics',
                    action='store_true')
parser.add_argument('--label-masking', help='Use the input labels as registration masks to reduce computation '
                    'and (possibly) improve registration',
                    action='store_true')
parser.add_argument('--no-cleanup', help='Do no cleanup intermediate files after participant2 phase',
                    action='store_true')

args = parser.parse_args()

# Check validity of bids dataset
run('bids-validator {0}'.format(args.bids_dir))
layout = BIDSLayout(args.bids_dir)

if args.analysis_level == "participant1" and not args.participant_label:
    raise Exception(
        "For template level processing subjects must be explicitly specified")

# Select subjects
subjects_to_analyze = []
T1w_files = []

# only for a subset of subjects
if args.participant_label:
    subjects_to_analyze = args.participant_label
# for all subjects
else:
    subjects_to_analyze = layout.get_subjects()

# Convert subjects to T1W files
for subject_label in subjects_to_analyze:
    subject_T1w_files = layout.get(subject=subject_label, type='T1w',
                                   extensions=['.nii', '.nii.gz'],
                                   return_type='file')
    if len(subject_T1w_files) == 0:
        raise Exception(
            "No T1w files found for participant %s" % subject_label)
    else:
        # If template phase, limit templates to first timepoint for subjects
        if args.analysis_level == "participant1":
            T1w_files.append(subject_T1w_files[0])
        else:
            T1w_files.extend(subject_T1w_files)

# Setup magetbrain inputs
os.chdir(args.output_dir)
run('mb.sh -- init')

# Copy in either colin or the big 5 atlases
if args.segmentation_type != 'colin27-subcortical':
    atlases = glob("/opt/atlases-nifti/brains_t1_nifti/*nii.gz")
    for atlas in atlases:
        shutil.copy(
            atlas, '{0}/input/atlas/{1}'.format(args.output_dir, os.path.basename(atlas)))
else:
    shutil.copy('/opt/atlases-nifti/colin/colin27_t1_tal_lin.nii.gz',
                '{0}/input/atlas/colin27_t1.nii.gz'.format(args.output_dir))

# Copy in the labels selected
if args.segmentation_type == 'amygdala':
    labels = glob('/opt/atlases-nifti/amygdala/labels/*.nii.gz')
    for label in labels:
        shutil.copy(label, '{0}/input/atlas/{1}_amygdala.nii.gz'.format(
            args.output_dir, os.path.splitext(os.path.splitext(os.path.basename(label))[0])[0][0:-1]))
elif args.segmentation_type == 'cerebellum':
    labels = glob('/opt/atlases-nifti/cerebellum/labels/*.nii.gz')
    for label in labels:
        shutil.copy(label, '{0}/input/atlas/{1}_cerebellum.nii.gz'.format(
            args.output_dir, os.path.splitext(os.path.splitext(os.path.basename(label))[0])[0][0:-1]))
elif args.segmentation_type == 'hippocampus-whitematter':
    labels = glob('/opt/atlases-nifti/hippocampus-whitematter/labels/*.nii.gz')
    for label in labels:
        shutil.copy(label, '{0}/input/atlas/{1}_hcwm.nii.gz'.format(
            args.output_dir, os.path.splitext(os.path.splitext(os.path.basename(label))[0])[0][0:-1]))
elif args.segmentation_type == 'all':
    labels = glob('/opt/atlases-nifti/amygdala/labels/*.nii.gz')
    for label in labels:
        shutil.copy(label, '{0}/input/atlas/{1}_amygdala.nii.gz'.format(
            args.output_dir, os.path.splitext(os.path.splitext(os.path.basename(label))[0])[0][0:-1]))

    labels = glob('/opt/atlases-nifti/cerebellum/labels/*.nii.gz')
    for label in labels:
        shutil.copy(label, '{0}/input/atlas/{1}_cerebellum.nii.gz'.format(
            args.output_dir, os.path.splitext(os.path.splitext(os.path.basename(label))[0])[0][0:-1]))

    labels = glob('/opt/atlases-nifti/hippocampus-whitematter/labels/*.nii.gz')
    for label in labels:
        shutil.copy(label, '{0}/input/atlas/{1}_hcwm.nii.gz'.format(
            args.output_dir, os.path.splitext(os.path.splitext(os.path.basename(label))[0])[0][0:-1]))
elif args.segmentation_type == 'colin27-subcortical':
    shutil.copy('/opt/atlases-nifti/colin27-subcortical/labels/thalamus-globus_pallidus-striatum.nii.gz',
                '{0}/input/atlas/colin27_label_subcortical.nii.gz'.format(args.output_dir))

if args.analysis_level == "participant2":
    subject_T1_list = []
    for file in T1w_files:
        subject_T1_list.append(
            '/{0}/input/subject/{1}'.format(args.output_dir, os.path.basename(file)))
        shutil.copy(
            file, '/{0}/input/subject/{1}'.format(args.output_dir, os.path.basename(file)))
    cmd = 'mb.sh {0} {1} -s '.format(
        args.fast and '--fast' or '', args.label_masking and '--label-masking' or '')
    cmd += '"' + ' '.join(subject_T1_list) + '"' + \
        ' -- subject resample vote qc'
    run(cmd,
        env={'QBATCH_PPJ': str(args.n_cpus),
             'QBATCH_CHUNKSIZE': str(1),
             'QBATCH_CORES': str(1)})
    if (not args.no_cleanup):
        for file in subject_T1_list:
            os.remove(file)
            shutil.rmtree("output/transforms/template-subject/" +
                          os.path.basename(file))
            shutil.rmtree("output/labels/candidates/" + os.path.basename(file))

# running template level preprocessing
elif args.analysis_level == "participant1":
    template_T1_list = []

    for file in T1w_files:
        shutil.copy(file, '/{0}/input/template/{1}'.format(
            args.output_dir, os.path.basename(file)))
        template_T1_list.append(
            '/{0}/input/template/{1}'.format(args.output_dir, os.path.basename(file)))
    cmd = 'mb.sh {0} {1} -t '.format(
        args.fast and '--fast' or '', args.label_masking and '--label-masking' or '')
    cmd += r'"' + ' '.join(template_T1_list) + r'"' + ' -- template'
    run(cmd,
        env={'QBATCH_PPJ': str(args.n_cpus),
             'QBATCH_CHUNKSIZE': str(1),
             'QBATCH_CORES': str(1)})
