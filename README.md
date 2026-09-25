# The Macrosyntenic Subsampler #

## Introduction ##

This project is a shell script that serves as a wrapper for three R scripts, two of which are directly derived from the currently available package MacroSyntR, available here:
https://github.com/SamiLhll/macrosyntR/tree/master

The Macrosyntenic Subsampler creates 100 subsamples of a target input ortholog table, then uses MacrosyntR to assess the robusticity of macrosyntenic inferences. It then pastes these robusticity values onto an Oxford dot plot of the complete dataset, allowing users to visualise the robusticity of inferences of macrosynteny across their dataset in an accessible way.

The mathematics and philosophy behind this process are explored in our manuscript in more detail here 

(LINK). 

The scripts contained in here are (in order of intended use):
- GetSeeds.r: this RScript obtains a list of 100 randomly generated seeds for use in the subsampling process. This ensures that subsamples are repeatable.
- MacrosyntenicSubsampler.sh: This shell script uses the seed file to generate 100 subsample datasets, then calls the R script TestSignificance.R (discussed below) to assess each dataset.
- TestSignificance.r: The is the standard MacroSyntR script. Here it is called by the MacrosyntenicSubsampler to calculate significant pairs for each subsampled dataset.
- DotPlotsWithSupport.r: This RScript is a modificated of the standard MacroSyntR script, intended for use on the original, unsampled dataset. It calculates the Oxford grid and Oxford dot plots as in the original MacroSyntR script, and then takes the information provided in Unique.Significant.tsv to overlay the support values determined by the subsample analysis.
  
Provided in the example folder are three files. These are the same example files used in MacroSyntR (https://github.com/SamiLhll/macrosyntR/tree/master):
- Bflo.bed
- Pyes.bed - A list of bed 
- Bflo_vs_Pyes.tab - A tab-seperated table matching the orthologs in the two bed files
These are the three core files that form the input for the Macrosyntenic Subsampler. To replace them with your own bed and tab files, change the input values in the R scripts DotPlotsWithSupport.r and TestSignificance.r to the relevant .bed files, and use the appropriate tab file as the input for Subsample.PresentationQuality.sh


## How to ##

To run the MacroSyntenic Subsampler, first run GetSeeds.r, which requires no other inputs. 

```
Rscript GetSeeds.r
```

This creates seeds.txt, a file of 100 randomly generated seeds that allow each subsample to be regenerated. This will be automatically used in the next step, MacrosyntenicSubsampler.sh.

```
bash MacrosyntenicSubsampler.sh <Input File> <Output Prefix> [Subsample Size]
```

For MacrosyntenicSubsampler.sh, the input file is the ortholog table - a file like Bflo_vs_Pyes.tab in the Example folder. The Output Prefix can be anything you would like. The final input options, subsample size, is completely optional. This determines the size of each subsampled dataset. By default, if no value is entered here, it will be half the size of the ortholog table. This results in an input like this:
```
bash MacrosyntenicSubsampler.sh Bflo_vs_Pyes.tab BfloPyes
```
or
```
bash MacrosyntenicSubsampler.sh Bflo_vs_Pyes.tab BfloPyes 1807
```
if you would like to specify the size of the subsample.

This produces 100 subsample datasets of the subsample size, and uses MacroSyntR to test each dataset for macrosyntenic associations in the same way as a larger input dataset. Following the completion of this assessment, it will output three summary files:
  - Unique.txt - a list of each pair recovered across the 100 subsamples.
  - Unique.Appearances.tsv - a tab-separated table of the number of occurrences of each pair across the 100 subsamples
  - Unique.Significant.tsv - a tab-separated table of the number of times a recovered pair was deemed to be significant in a subsample

Following this, you can then run DotPlotsWithSupport.r like this:

```
Rscript DotPlotsWithSupport.r
```

Which is a slightly modified version of the standard MacrosyntR script that will produce Oxford Dot Plots with the proportion of datasets producing a significant hit for each chromosome pair noted done.


## Remember! ##

Just as with MacroSyntR, you will need to edit the r scripts (here, DotPlotsWithSupport.r and TestSignificance.r) to include the names of your input bed files (on lines 9 and 10 of TestSignificance.r, and 12 and 13 of DotPlotsWithSupport.r), and the names of your input taxa (on lines 16, 17, 22 and 23 of TestSignificance.R and on lines 33, 34, 39, 40 of DotPlotsWithSupport.r).
