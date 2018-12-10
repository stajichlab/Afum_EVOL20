#PBS -l nodes=1:ppn=64,mem=64gb -q js -l walltime=48:00:00 -j oe 
module load RepeatMasker
RepeatMasker -pa 64 -s -gff -e ncbi -species Fungi AfumigatusAf293.fa
