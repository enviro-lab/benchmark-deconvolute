# How we ran lineagespot

## Annotations needed in VCF files
To get them,
1. Install SnpEff
```bash
cd software
wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip
```

2. Install java so we can run snpEff
```bash
cd software
wget https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz
tar -zxvf jdk-20_linux-x64_bin.tar.gz
cd -
```
Can now run java via `software/jdk-20.0.2/bin/java`.

3. Install SARS-CoV-2 (NC_045512.2) database to use for annotation
```bash
jdk-20.0.2/bin/java -jar software/snpEff/snpEff.jar download NC_045512.2
```

## Need to download mutation definitions from outbreak.info
Run `tools/lineagespot/scripts/download_mutation_definitions.sh`

## Run lineagespot
run `tools/lineagespot/scripts/run_lineagespot.sh`