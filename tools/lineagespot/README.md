# How we ran lineagespot

## Annotations needed in VCF files
To be able to annotate the vcfs, we use the below software, following the general steps used in the [lineagespot repo](https://github.com/BiodataAnalysisGroup/lineagespot/tree/master).
1. Install java so we can run snpEff and picard
```bash
cd software
version=21
wget https://download.oracle.com/java/${version}/latest/jdk-${version}_linux-x64_bin.tar.gz
tar -zxvf jdk-${version}_linux-x64_bin.tar.gz
mv jdk-${version}* jdk
cd -
```
Can now run java via `software/jdk/bin/java`.

2. Install SnpEff
```bash
cd software
wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip
unzip snpEff_latest_core.zip
cd -
```

3. Install picard
```bash
cd software
wget https://github.com/broadinstitute/picard/releases/download/3.1.1/picard.jar
cd -
```

4. Install SARS-CoV-2 (NC_045512.2) database to use for annotation
```bash
software/jdk/bin/java -jar software/snpEff/snpEff.jar download NC_045512.2
```

## Mutation definitions
These can be downloaded from outbreak.info and converted to the required format by running: 
```bash
bash tools/lineagespot/scripts/download_mutation_definitions.sh
```

## Run lineagespot
```bash
bash tools/lineagespot/scripts/run_lineagespot_multi.sh
```