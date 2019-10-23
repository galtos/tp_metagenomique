#!/bin/bash
dossier_reads_bruts=$1
dossier_sortie=$2

#echo $dossier_reads_bruts
#echo $dossier_sortie


#echo $dossier_reads_bruts/*_R1.fastq.gz $dossier_reads_bruts/*_R2.fastq.gz
mkdir $dossier_sortie
mkdir $dossier_sortie/fastq_output
gunzip $dossier_reads_bruts/*.fastq.gz

flag=1
for file in $dossier_reads_bruts/*;do

    if (($flag==2))
    then
        file_R2=$file
        flag=3
    fi
    if (($flag==1))
    then
        file_R1=$file
        flag=2
    fi
    if (($flag==3))
    then
        #fastq $file_R1 $file_R2 -o 
        #echo java -jar soft/AlienTrimmer.jar -if $file_R1 -ir $file_R2 -c databases/contaminants.fasta -q 20 -of $dossier_sortie/$file_R1 -or $dossier_sortie/$file_R2
        flag=1
    fi
done

#for file in $dossier_reads_bruts/*;do
#   echo $file
#   file_R1=$file
#   file_R2=$(echo$file|sed "s:R1:R2:g")
#ID=${sample%_*};
file_R1=$dossier_reads_bruts/1ng-25cycles-1_R1.fastq
echo $file_R1
file_R2=$(echo $file_R1|sed "s:R1:R2:g")
file_trim_R1=$(echo $file_R1|sed "s:R1.*:R1.flt.fastq:g"|sed "s:fastq/::g")
file_trim_R2=$(echo $file_R2|sed "s:R2.*:R2.flt.fastq:g"|sed "s:fastq/::g")
file_trim_RS=$(echo $file_R2|sed "s:R2.*:RS.flt.fastq:g"|sed "s:fastq/::g")
mkdir $dossier_sortie/Alientrimmer_output
#java -jar soft/AlienTrimmer.jar -if $file_R1 -ir $file_R2 -c databases/contaminants.fasta -q 20 -of $dossier_sortie/Alientrimmer_output/$file_trim_R1 -or $dossier_sortie/Alientrimmer_output/$file_trim_R2 -os $dossier_sortie/Alientrimmer_output/$file_trim_RS

mkdir $dossier_sortie/Vsearch_output
#--relabel STRING
#--fastq_mergepairs FILENAME
file_vsearch_merge=$(echo $file_R2|sed "s:R2.*:merge.fasta:g"|sed "s:fastq/::g")
name_ech=$(echo $file_R2|sed "s:_R2.*::g"|sed "s:fastq/::g")

#vsearch --fastq_mergepairs $dossier_sortie/Alientrimmer_output/$file_trim_R1* --reverse $dossier_sortie/Alientrimmer_output/$file_trim_R2* --fastaout $dossier_sortie/Vsearch_output/$file_vsearch_merge --label_suffix ";sample=$name_ech;"

#rassembler en un fichier
mkdir $dossier_sortie/amplicon
touch $dossier_sortie/amplicon/amplicon.fasta


echo $dossier_sortie/Vsearch_output/$file_vsearch_merge
#sed "s: ::g" $dossier_sortie/Vsearch_output/$file_vsearch_merge >> $dossier_sortie/amplicon/amplicon.fasta

#vsearch --derep_fulllength $dossier_sortie/amplicon/amplicon.fasta --output $dossier_sortie/amplicon/amplicon_dereplicate.fasta --minuniquesize 10
#seuil superieur supprime plus de sequences
#vsearch --uchime_denovo $dossier_sortie/amplicon/amplicon_dereplicate.fasta --nonchimeras $dossier_sortie/amplicon/amplicon_nochimeras.fasta

vsearch --cluster_size $dossier_sortie/amplicon/amplicon_nochimeras.fasta --otutabout $dossier_sortie/amplicon/amplicon_OTUcentroids.fasta --id 0.97 --relabel "OTU_"

vsearch --usearch_global














