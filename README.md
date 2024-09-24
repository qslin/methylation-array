This repo contains template scripts for methylation-array (EPICv2) analysis.

report.Rmd can be rendered into an HTML report. 

Before rendering, check the following parameters:
- raw_data_root_folder: path to the folder of all raw data.
- sampleinfo: a csv file containing sample information. In the table, the first column must be `Sample_Name` whose values are exactly the same as those in metadata files (in .csv format) that come along with the raw data; metadata files should be inside the raw_data_root_folder. The samples in sampleinfo can be a subset of raw data; if this is the case, only samples inside sampleinfo will be analyzed. There must be a `Group` column indicating sample groups to compare. Note that on tSNE plot, the colors will map to the second column in this csv file and the shapes will map to the third column if exists.
- platform: "EPICv2"
- result_folder: name of the folder to save results; will also be the name of .RData output.
- remove_bad_samples: whether to remove samples with <40% success detection rate.
- tSNE_perplexity: perplexity to use in tSNE.
- skip_DM: whether to skip the differential methylation test. This must be TRUE when rendering the script on local machine with a relatively low memory.
- test_mode: whether to test the script using the first 2000 probes of each sample only and not to overwrite current .RData output; usually used on a local machine.
- contrast_pairs: a list of vectors; each vector has two character strings, where is the first one is the reference group name and the second is the experimental group name (as defined in the `Group` column of sampleinfo).

***Important: The raw data read-in cannot be done on Randi (likely due to a bug in `sesame`). So We first render the script on local machine with `skip_DM=TRUE`. A `report.html` file will be generated and R objects will be saved to a .RData file. If the .RData already exists in the working directory, will use it for analyses downstream of QC instead of reading from raw data. If you want to restart from reading in raw data, please remove the .RData file from current working directory and render the script again. Then, we upload the .RData and the script to Randi. To run differential methylation tests on Randi, set `skip_DM` to `FALSE` and render the script using the image at [https://hub.docker.com/r/jonalin/cri-methylation-array-report](https://hub.docker.com/r/jonalin/cri-methylation-array-report). ***

