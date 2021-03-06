################################################################################
########################    Chipseq conservative   #############################################
################################################################################
################################################################################
#### bedtools
#### required liftOver tools

### input
bedpath=$1
chainfile=$2
outputmap=$3
outputunmap=$4
rm temp*
# format bed file with 4 column: chromosome_start_end_value
awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$1"."$2"."$3}' $bedpath| sort -k1,1 -k2,2n  >temp0

# filtered blacklist and gap(gapped-in-hg19, gapped-in-both and blacklist)
bedtools subtract -a temp0 -b Lifted/data/gapped-in-hg19.bed -A|sort -k1,1 -k2,2n > temp001
bedtools subtract -a temp001 -b Lifted/data/gapped-in-both.bed -A|sort -k1,1 -k2,2n > temp002
bedtools subtract -a temp002 -b Lifted/data/blacklist.hg19.bed -A|sort -k1,1 -k2,2n > temp1
rm temp0*
## liftover
liftOver temp1 $chainfile temp2 $outputunmap

### filter gap in hg38 
sort -k1,1 -k2,2n temp2 > temp20
bedtools intersect -a temp20 -b Lifted/data/gapped-in-hg38.bed -v > temp3

#### filter  duplicate, alt chromosome
sort -k1,1 -k2,2n temp3|grep -E "chr(.|..)[[:blank:]]"|sort -k5,5|uniq -f4 -u|sort -k1,1 -k2,2n > temp31
bedtools merge -i  temp31 -c 5 -o collapse -delim "_" > temp32
awk '{if($5!~"_"){print $0}}' temp32|sort -k1,1 -k2,2n > $outputmap

rm temp*
