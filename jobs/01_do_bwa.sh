#PBS -l nodes=1:ppn=8 -q js -N bwa.Afum -j oe -l walltime=8:00:00
module load bwa/0.7.12
module unload java
module load java/8
module load picard
GENOME=index/A_fumigatus_Af293
GENOMESTRAIN=Af293
INDIR=input
OUTDIR=aln

N=$PBS_ARRAYID
CPU=1
if [ $PBS_NP ]; then 
 CPU=$PBS_NP
fi

SAMPFILE=samples.csv
if [ ! $N ]; then
 N=$1
fi

if [ ! $N ]; then 
 echo "need to provide a number by PBS_ARRAYID or cmdline"
 exit
fi

if [ $N -eq "1" ]; then 
 echo "Skipping 1 as it is the header in the infile"
 exit
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`

if [ $N -gt $MAX ]; then 
 echo "$N is too big, only $MAX lines in $SAMPFILE"
 exit
fi

IFS=,
sed -n ${N}p $SAMPFILE | while read ID STRAIN FWD REV BARCODE DESC;
do
 echo $ID $STRAIN $FWD $REV $BARCODE $DESC
 LIBRARY=$(echo $FWD | awk -F_ '{print $1}')
 PAIR1=${INDIR}/$FWD
 PAIR2=${INDIR}/$REV
 OUTFILE=NULL
 if [ -f $PAIR2 ]; then
  OUTFILE=$OUTDIR/${ID}.PE.unsrt.sam
  echo "OUTFILE is $OUTFILE"
  if [ ! -f $OUTFILE ]; then
	bwa mem -t $CPU $GENOME $PAIR1 $PAIR2 > $OUTFILE
    fi 
    if [ ! -f $OUTDIR/${ID}.PE.bam ]; then
     java -jar $PICARD AddOrReplaceReadGroups I=$OUTFILE O=$OUTDIR/${ID}.PE.RG.bam \
      RGID=$ID RGSM=$STRAIN RGPL=illumina RGLB=$LIBRARY RGPU=$BARCODE SO=coordinate
    fi
  else
   OUTFILE=$OUTFILE/${ID}.SE.unsrt.bam
   echo "OUTFILE is $OUTFILE"
   if [ ! -f $OUTFILE ]; then
    bwa mem -t $CPU $GENOME $PAIR1 > $OUTFILE
   fi
   if [ ! -f $OUTDIR/${ID}.SE.bam ]; then
     java -jar $PICARD AddOrReplaceReadGroups I=$OUTFILE O=$OUTDIR/${ID}.SE.RG.bam \
      RGID=$ID RGSM=$STRAIN RGPL=illumina RGLB=$LIBRARY RGPU=$BARCODE SO=coordinate
    fi
 fi
done
