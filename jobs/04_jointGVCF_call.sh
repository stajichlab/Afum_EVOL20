#PBS  -l nodes=1:ppn=32,mem=64gb -N GATK.GVCFGeno -j oe
MEM=64g
module unload java
module load java/8
module load picard
module load gatk/3.6

GENOME=index/A_fumigatus_Af293.fasta

INDIR=Variants
OUT=A_fumigiatus_Af293.EVOL_vs_WT.vcf

CPU=1
if [ $PBS_NUM_PPN ]; then
 CPU=$PBS_NUM_PPN
fi

N=`ls $INDIR/*.g.vcf | sort | perl -p -e 's/\n/ /; s/(\S+)/-V $1/'`

java -Xmx$MEM -jar $GATK \
    -T GenotypeGVCFs \
    -R $GENOME \
    $N \
    -o $OUT \
    -nt $CPU
