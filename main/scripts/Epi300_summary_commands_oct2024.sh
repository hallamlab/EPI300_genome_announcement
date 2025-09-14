

####Summary of commands:


##filtlong to filter reads up to 100x coverage (selects best reads)

### Filtlong v0.2.0


filtlong -t 500000000 Epi300_RC.fastq.gz | gzip - >  Epi300_RC_100x.fastq.gz
## do a quick check for pb adapters (not really needed)

### HiFiAdapterFilt  v 3.0.1

~/HiFiAdapterFilt/hifiadapterfilt.sh -p Epi300_RC_100x -t 8  -o hifi_adapter_out



##flye assembly  v2.9.3

conda activate flye_v293

flye --pacbio-hifi Epi300_RC_100x.fastq.gz \
--out-dir Epi300_RC_100x_flye \
--genome-size 5m  --keep-haplotypes --meta \
-t 8

####Hifiasm v 0.19.8-r603

~/hifiasm/hifiasm -o Epi300_RC_100x_hifiasm \
-t4 Epi300_RC_100x.fastq.gz


## compleasm v 0.2.6

GENOMES=(Epi300_RC_100x_hifiasm.bp.hap1.p.fasta
Epi300_RC_100x_flye.fasta)
for i in ${GENOMES[@]} ; do
compleasm run -t4 -l enterobacterales_odb10 -a ${i} -o ${i%%.fasta}_compleasm  # run the pipeline
done

####Prokka
## prokka v1.14.6

###
prokka --outdir Epi300_RC_hifiasm_prokka --usegenus --genus enterobacterales --species escherichia_coli --strain Epi300 --prefix Epi300_RC Epi300_RC_100x_hifiasm.bp.hap1.p.fasta && \
prokka --outdir Epi300_RC_flye_prokka --usegenus --genus enterobacterales --species escherichia_coli --strain Epi300 --prefix Epi300_RC Epi300_RC_100x_flye.fasta



######to assess the coverage etc
### samtools v 1.14
### minimap v 2.24


GENOME=Epi300_RC_100x_flye.fasta
BAM_FILE_1=Epi300_RC_100x_flye_minimap2.bam
ONT_READS=Epi300_RC_100x.fastq.gz
~/minimap2-2.24_x64-linux/minimap2 -a -x map-hifi -t 8 $GENOME $ONT_READS --secondary=no \
| samtools view -hF 256  - | samtools sort -@ 2 -m 2G -o $BAM_FILE_1 -T tmp.ali && \
samtools index $BAM_FILE_1 

#####



