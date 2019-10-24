#!/bin/bash
dossier_reads_bruts=$1
dossier_sortie=$2

mkdir $dossier_sortie
mkdir $dossier_sortie/Vsearch_output
mkdir $dossier_sortie/Alientrimmer_output
mkdir $dossier_sortie/amplicon
touch $dossier_sortie/amplicon/amplicon.fasta
gunzip $dossier_reads_bruts/*.fastq.gz

for file in $(ls $dossier_reads_bruts/*_R1.fastq);do
    echo $file
    file_R1=$file
    file_R2=$(echo $file|sed "s:R1:R2:g")
    
    file_trim_R1=$(echo $file_R1|sed "s:R1.*:R1.flt.fastq:g"|sed "s:fastq/::g")
    file_trim_R2=$(echo $file_R2|sed "s:R2.*:R2.flt.fastq:g"|sed "s:fastq/::g")
    file_trim_RS=$(echo $file_R2|sed "s:R2.*:RS.flt.fastq:g"|sed "s:fastq/::g")

    fastqc $file_R1 $file_R2 -o $dossier_sortie
    java -jar soft/AlienTrimmer.jar -if $file_R1 -ir $file_R2 -c databases/contaminants.fasta -q 20 -of $dossier_sortie/Alientrimmer_output/$file_trim_R1 -or $dossier_sortie/Alientrimmer_output/$file_trim_R2 -os $dossier_sortie/Alientrimmer_output/$file_trim_RS
    
    file_vsearch_merge=$(echo $file_R2|sed "s:R2.*:merge.fasta:g"|sed "s:fastq/::g")
    name_ech=$(echo $file_R2|sed "s:_R2.*::g"|sed "s:fastq/::g")
    
    vsearch --fastq_mergepairs $dossier_sortie/Alientrimmer_output/$file_trim_R1* --reverse $dossier_sortie/Alientrimmer_output/$file_trim_R2* --fastaout $dossier_sortie/Vsearch_output/$file_vsearch_merge --label_suffix ";sample=$name_ech;"
    
done

sed "s: ::g" $dossier_sortie/Vsearch_output/$file_vsearch_merge >> $dossier_sortie/amplicon/amplicon.fasta

vsearch --derep_fulllength $dossier_sortie/amplicon/amplicon.fasta --output $dossier_sortie/amplicon/amplicon_dereplicate.fasta --minuniquesize 10
#seuil superieur supprime plus de sequences
vsearch --uchime_denovo $dossier_sortie/amplicon/amplicon_dereplicate.fasta --nonchimeras $dossier_sortie/amplicon/amplicon_nochimeras.fasta

vsearch --cluster_size $dossier_sortie/amplicon/amplicon_nochimeras.fasta --otutabout $dossier_sortie/amplicon/amplicon_OTUcentroids.fasta --id 0.97 --relabel "OTU_" --centroids $dossier_sortie/amplicon/centroids.fasta

vsearch --usearch_global $dossier_sortie/amplicon/amplicon.fasta --db $dossier_sortie/amplicon/centroids.fasta --otutabout $dossier_sortie/amplicon/amplicon_table_abondance.fasta --id 0.97

vsearch --usearch_global $dossier_sortie/amplicon/centroids.fasta --db databases/mock_16S_18S.fasta --id 0.90 --top_hits_only --userfields "query+target" --userout $dossier_sortie/amplicon/annotation.txt

sed '1iOTU\tAnnotation' -i $dossier_sortie/amplicon/annotation.txt










