#Q1: 
#Extract indels from the file to output file SNPs_only.recode.vcf
    vcftools --vcf pilot.vcf --remove-indels --recode --recode-INFO-all --out SNPs_only
#Count the lines which would be equivelant to the number of SNPs excluding meta header (lines starting with #)
    grep -v "#" SNPs_only.recode.vcf  | wc -l

#Q2 : 
vcftools --vcf gt.vcf --geno-depth --chr 1 --from-bp 1105124 --to-bp 1105424 -c > geno_depth.vcf

#Q3:extract variants from pilot.vcf that have HM3 membership flag and extract such variants from gt.vcf
#Extract chromosome number and position from Pilot.vcf having HM3 flag and output into a file positions_hap.txt that has Chr number and Position
cat pilot.vcf | grep -v "#" | grep "HM3"  |  cut -f1,2 > positions_hap.txt
#Extract such variants from gt.vcf by using --position-overlap and outputing into a file called gt_hap.recode.vcf
vcftools --vcf gt.vcf --positions-overlap positions_hap.txt --recode --recode-INFO-all --out gt_variants

#Q4: 36 individuals have missing genotype more than 10%
#Use bcftools stat and grep Per sample count and cut the second column that has sample names and missing genotypes count
bcftools stats -s - gt.vcf  | grep "^PSC" | cut -f2,14 > missing_count.txt 
#loop through each line and divide it by the number of records to determine the percentage of missing genes per sample
cat missing_count.txt | while read lines; do missing=$(echo "$lines" | cut -f2); perc=$(echo "scale=2; $missing / 5175" | bc); if (( $(echo "$perc > 0.1" |bc -l) ));  then  echo $lines | cut -f1,2 >> remove.txt; else echo $lines | cut -f1,2 >> keep.txt; fi; done

#Q5: making a vcf file of the filtered individuals
#filter out sample names that will be removed ( as sample names are the first column) 
less remove.txt | cut -f1 > remove_samples.txt
#use vcftools to remove such individuals
vcftools --remove remove_samples.txt --vcf gt.vcf --recode --recode-INFO-all --out filtered

#Q6
#Get a vcftools with contig information since bcftools needs contig information 
bcftools view gt.vcf > gt_contig.vcf
#Populate info field on the new vcf file (fitlered.recode.vcf) with fill-tags
bcftools +fill-tags filtered.recode.vcf -Ov -o filtered_tags.vcf

#Q7:
#extract chromosome AC AN from filtered 
bcftools query -H -f '%CHROM\t%POS\t%AN\t%AC\n' gt.vcf.gz > ALT1.vcf
#Extract chromosome AC AN from gt 
bcftools query - H -f '%CHROM\t%POS\t%AN\t%AC\n' filtered_tags.vcf > ALT2.vcf

#Q8: 88 variants
comm -12 <(sort ALT1.vcf) <(sort ALT2.vcf) | wc -l










 
