#!/usr/bin/bash
module load bedtools

awk 'BEGIN{OFS="\t"} { print $1,$2,$2}' A_fumigiatus_Af293.EVOL_vs_WT.selected_diff_only.tab > A_fumigiatus_Af293.EVOL_vs_WT.selected_diff_only.bed
bedtools intersect -a A_fumigiatus_Af293.EVOL_vs_WT.selected_diff_only.bed -b genome/Afumigatus_Af293.gtf -wo 

