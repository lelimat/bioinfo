# region_to_cytoband.sh
# C: Nov 27, 2014
# M: Jan 12, 2015
# A: Leandro Lima <llima@ime.usp.br>

# From: https://www.biostars.org/p/18856/

found_colon=`echo $1 | grep -c :`
chrom=$1
start=$2
end=$3

if [ "$found_colon" == "1" ]; then
	chrom=`echo $1 | cut -d: -f1`
	start_end=`echo $1 | cut -d: -f2`
	start=`echo $start_end | cut -d'-' -f1`
	end=`echo $start_end | cut -d'-' -f2`
fi

# echo $chrom $start $end # chr5:45945301-49492838

# cytoband=`mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -D hg19 -e "select name from cytoBand where chrom = '$chrom' AND chromStart <= $start AND chromEnd >= $end" | tail -n +2`
cytoband=`mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -D hg19 -e "
			select name
			from cytoBand
			where chrom = '$chrom' AND (
				(chromStart <= $start AND chromEnd >= $end) OR
				(chromStart <= $start AND $start <= chromEnd) OR
				(chromStart <= $end AND $end <= chromEnd))" |
		tail -n +2`

for c in `echo $cytoband`; do
	echo $chrom""$c | sed 's/chr//g'
done | perl -pe 's/\n/-\n/g; s/\n//g' | perl -pe 's/-$/\n/g'

# echo "mysql --user=genome --host=genome-mysql.cse.ucsc.edu -A -D hg19  -e \"select name from cytoBand where chrom = '$1' AND chromStart <= $2 and chromEnd >= $3\"" | sh
