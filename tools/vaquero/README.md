# Deconvolution using VaQuERo

## Useful documentation
[GitHub](https://github.com/fabou-uobaf/VaQuERo)


## Scripts
scripts/run_vaquero.sh
* runs vaquero for a single plate


## Conda env for VaQuERo needs
```bash
module load anaconda3
mamba create -m conda/env-vaquero -c bioconda pysam lofreq pandas
conda activate conda/env-vaquero
```

## Clone vaquero repo and install dependencies
```bash
cd software
git clone https://github.com/fabou-uobaf/VaQuERo.git
Rscript VaQuERo/R_package_dependency_install.r
cd -
```

## Notes on assumtions/parameters
### Meta data file
We generate this using [write_vaquero_metadata.py](scripts/write_vaquero_metadata.py) and make several generalizations in order to ensure vaquero treats each sample as different but from the same location with no smoothing based on time or location.
Field | Example | Description
--- | --- | ---
BSF_run | Mixture01 | same as sample name
BSF_sample_name | Mixture01 | the sample name
BSF_start_date | 2023-05-05 | same for all samples
LocationID | None | same for all samples
LocationName | Nowhere | same for all samples
N_in_Consensus | 0 | irrelevant for our purposes except that we want all samples to pass vaquero's qc (defualt: Ns make up <40% of consensus, so if N is 0, all samples will pass)
RNA_ID_int | Mixture01 | same as sample name
additional_information |  | irrelevant for our purposes
adress_town | Charlotte | same for all samples
connected_people | 0 | irrelevant for our purposes
dcpLatitude | 35.31270260350986 | same for all samples
dcpLongitude | -80.74195454164692 | same for all samples
include_in_report | TRUE | include all samples
report_category | MixedControls | same for all samples
sample_date | 2023-03-03 | different for each sample (by at least 2 days to avoid any smoothing)
status | passed_qc | all samples should be marked as 'passed_qc'

### Parameters given to vaquero
```
# to avoid smoothing:
--smoothingsample 0
# to avoid producing timecourse plots
--plottp 1000
# to set location on map (not really relevant but required):
--country=USA --bbsouth=33.7 --bbnorth=36.7 --bbwest=-84.4 --bbeast=-75.3
```

### Note on plotting
A few plots will be produced, but vaquero will fail at the "plotting overview Sankey plot + Detection Plot" step due to a data-related issue.