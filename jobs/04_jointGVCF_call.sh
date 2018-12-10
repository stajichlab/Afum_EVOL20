#!/usr/bin/bash
#SBATCH -p short --out logs/call_filter_snps.log --ntasks 8

MEM=64g
module unload java
module load java/8
module load picard
module load gatk/3.6
module load vcftools

GENOME=index/A_fumigatus_Af293.fasta

INDIR=Variants
OUT=A_fumigiatus_Af293.EVOL_vs_WT.vcf
FILTEROUT=A_fumigiatus_Af293.EVOL_vs_WT.filter.vcf
SELECTOUT=A_fumigiatus_Af293.EVOL_vs_WT.selected.vcf

CPU=$SLURM_CPUS_ON_NODE
if [ ! $CPU ]; then
 CPU=2
fi


N=`ls $INDIR/*.g.vcf | sort | perl -p -e 's/\n/ /; s/(\S+)/-V $1/'`
if [ ! -f $OUT ]; then
java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOME \
    $N \
    -o $OUT \
    -nt $CPU
fi

if [ ! -f $FILTEROUT ]; then
  java -Xmx3g -jar $GATK \
   -T VariantFiltration -o $FILTEROUT \
   --variant $OUT -R $GENOME \
   --clusterWindowSize 10  -filter "QD<2.0" -filterName QualByDepth \
   -filter "MQ<40.0" -filterName MapQual \
   -filter "QUAL<100" -filterName QScore \
   -filter "MQRankSum < -12.5" -filterName MapQualityRankSum \
   -filter "SOR > 4.0" -filterName StrandOddsRatio \
   -filter "FS>60.0" -filterName FisherStrandBias \
   -filter "ReadPosRankSum<-8.0" -filterName ReadPosRank \
   --missingValuesInExpressionsShouldEvaluateAsFailing
  fi

if [ ! -f $SELECTOUT ]; then
   java -Xmx16g -jar $GATK \
   -R $GENOME \
   -T SelectVariants \
   --variant $FILTEROUT \
   -o $SELECTOUT \
   -env \
   -ef \
   --excludeFiltered
 fi

 vcf-to-tab < $SELECTOUT > A_fumigiatus_Af293.EVOL_vs_WT.selected.tab
