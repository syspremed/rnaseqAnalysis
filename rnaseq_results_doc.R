#Author - Yatish B. Patil 
# This script is used for the RNASeq QC report for red counts, phred quality score, mapping percentage and RNA species.
rm(list=ls())
source("http://bioconductor.org/biocLite.R")
# library
require(ggplot2)
require(reshape)
require(scales)
  
  ###### Creating folder structure as main, scripts and output 

  mainDir = "/Users/ypatil/Dropbox (SPM)/Yatish/Analysis/SPRECMED/Internal/COLON/Human/RNASeq/Mayo/neil_ihrke/data/set_1/89_samples/QC/"
  scrDir = "/Users/ypatil/Dropbox (SPM)/Yatish/Analysis/SPRECMED/Internal/COLON/Human/RNASeq/Mayo/neil_ihrke/data/set_1/89_samples/QC/scripts/"
  dataDir = "/Users/ypatil/Dropbox (SPM)/Yatish/Analysis/SPRECMED/Internal/COLON/Human/RNASeq/Mayo/neil_ihrke/data/set_1/89_samples/QC/data/"
  oDir = "/Users/ypatil/Dropbox (SPM)/Yatish/Analysis/SPRECMED/Internal/COLON/Human/RNASeq/Mayo/neil_ihrke/data/set_1/89_samples/QC/output/"
  outDir <- paste0(oDir,Sys.Date(),"_QC_RNASeq_Mayo_Neil_Ihrke_Human_BC_89_samples/")
  dir.create(outDir, showWarnings = FALSE)
  
  #######################
  
  #fastqc_avg_BC_samples.txt
  #rna_species_BC_samples.txt
  #rnaseq_genome_mapping_percentage_BC.txt
  #rnaseq_transcriptome_mapping_percentage_BC.txt
  #sorted_fastq_read_counts_BC_samples.txt
  
  fastqReadFile = paste0(dataDir,"sorted_fastq_read_counts_BC_samples.txt")
  
  rd = read.delim(fastqReadFile,header = FALSE,sep = " ");dim(rd)
  #rd$V1 = NULL
  colnames(rd) = c("Samples","Counts")
  rownames(rd) = rd$Samples
  r1pos = grep("R1",rownames(rd))
  r1 = rd[r1pos,]
  
  #samples = as.data.frame(sapply(strsplit(rownames(r1), split= "\\_"), function(x) x[2]))
  samples = as.data.frame(rownames(r1))
  r2pos = grep("R2",rownames(rd))
  r2 = rd[r2pos,]
  
  fq_read_count = cbind(samples,r1$Counts,r2$Counts)
  
  colnames(fq_read_count) = c("Samples","R1","R2")
  fq_read_count$Samples = gsub("_R1","",fq_read_count$Samples)
  # Grouped Bar plot
  fq_read_count$Samples =  reorder(fq_read_count$Samples, fq_read_count$R1)
  fq_read_count$Samples = factor(fq_read_count$Samples, levels=rev(levels(fq_read_count$Samples)))
  
  fq_read_count[order(fq_read_count$R1),]
  
  read_count_dat = melt(fq_read_count)
  colnames(read_count_dat) = c("Samples","Paired_Reads","Read_Counts")
  

g1 =   ggplot(read_count_dat, aes(x=Samples,y=Read_Counts,fill=Paired_Reads)) + 
    geom_bar(position = "dodge",stat="identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("Statistics of Quality Reads") +
    theme(plot.title = element_text(color = "orange",lineheight=.8, face="bold",hjust = 0.5))
  #dev.off()
  
  ### 2. fastqc quality Q30 - fastqc value
  q30File = paste0(dataDir,"fastqc_avg_BC_samples.txt")
  q30 = read.delim(q30File,header = FALSE,sep = " ",row.names = 1);dim(q30)
  #samples = as.data.frame(sapply(strsplit(rownames(q30), split= "-"), function(x) x[1]))
  
  q30Dat = cbind(rownames(q30),q30)
  colnames(q30Dat) = c("Samples","Q30_Value")
  rownames(q30Dat) = NULL
  
  q30Dat$Samples =  reorder(q30Dat$Samples, q30Dat$Q30_Value)
  q30Dat$Samples = factor(q30Dat$Samples, levels=rev(levels(q30Dat$Samples)))
  

g2 =  ggplot(q30Dat, aes(x=Samples,y=Q30_Value,group = 1)) + 
    geom_line(color = "red",size = 0.5) +
    theme(axis.text.x = element_text(angle = 0, hjust = 1, size = 20, vjust=1, margin=margin(2,0,0,0)),
        #axis.text.y = element_text(hjust = 1.5, size = 20, vjust=1, margin=margin(2,0,0,0)),
        axis.text.y = element_blank(),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size = 30),legend.key.size = unit(2,"cm"),
        legend.title = element_text(size = 30),legend.text = element_text(size = 15))+
    labs(title="Read Quality-Q30 using FastQC")+
    theme(plot.title = element_text(color = "orange",lineheight=.8, face="bold",hjust = 0.5,size = 30))+
    coord_flip()
  
  #dev.off()
  
  
  ### 3. Mapping Quality - to transcriptome and genome
  trFile = paste0(dataDir,"rnaseq_transcriptome_mapping_percentage_BC.txt")
  tr = read.delim(trFile,header=FALSE,sep=" ",row.names = 1);dim(tr)
  
  gmFile = paste0(dataDir,"rnaseq_genome_mapping_percentage_BC.txt")
  gm = read.delim(gmFile,header=FALSE,sep="\t",row.names = 1);dim(gm)
  
  samples = as.data.frame(sapply(strsplit(rownames(tr), split= "\\/"), function(x) x[1]))
  
  tr_gm = as.data.frame(cbind(samples,tr$V2,gm$V2));dim(tr_gm)
  
  colnames(tr_gm) =c ("Samples","Transcriptome","Genome")
  mapping_count <- tr_gm
  
  mapping_count_datFile = paste0(outDir,Sys.Date(),"_mapping_perc_transcriptome_genome_human_89_BC_Mayo.txt",sep="")
  write.table(mapping_count,mapping_count_datFile,sep = "\t",row.names = FALSE)
  # Grouped Bar plot
  mapping_count$Samples =  reorder(mapping_count$Samples, mapping_count$Transcriptome)
  mapping_count$Samples = factor(mapping_count$Samples, levels=rev(levels(mapping_count$Samples)))
  mapping_count[order(mapping_count[,2],mapping_count[,3],decreasing=TRUE),]
  
  mapping_count_dat = melt(mapping_count)
  colnames(mapping_count_dat) = c("Samples","Transcriptome_Genome","Mapping_Percentage")
  
  
  #ggsave(mapping_count_datFile, device = "pdf", width = 10, height = 10)
g3 = ggplot(mapping_count_dat, aes(x=Samples,y=Mapping_Percentage,fill=Transcriptome_Genome)) + 
    geom_bar(position = "dodge",stat="identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1,size = 20)) +
    theme(axis.text.y = element_text(size = 20)) +
    ggtitle("Mapping Percentage from SAMTools - Flagstat") +
    theme(plot.title = element_text(color = "orange",lineheight=.8, face="bold",hjust = 0.5))
  #dev.off()
  
  
  # 4. RNA Species quality
  rnaFile = paste0(dataDir,"rna_species_BC_samples.txt")
  rnaCount = read.delim(rnaFile,header=FALSE,sep="\t",row.names = 1)
  samples = as.data.frame(sapply(strsplit(rownames(rnaCount), split= "\\/"), function(x) x[1]))
  rnaCount1 = cbind(samples,rnaCount$V2,rnaCount$V3,rnaCount$V4,rnaCount$V5,rnaCount$V6)
  colnames(rnaCount1) = c("Samples","Ribosomal","Coding","UTR","Intronic","Intergenic")
  
  rnaCount_dat = melt(rnaCount1)
  colnames(rnaCount_dat) = c("Samples","RNA_Species","Percentage")
  
  g4 = ggplot(rnaCount_dat, aes(x=Samples,y=Percentage,fill=RNA_Species)) + 
    geom_bar(position = "fill",stat="identity") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    ggtitle("RNA Quality and Species Information from Picard") +
    scale_y_continuous(labels = percent_format())+ 
    theme(axis.text.x = element_text(size = 20)) + 
    theme(axis.text.y = element_text(size = 20)) +
    theme(plot.title = element_text(color = "orange",lineheight=.8, face="bold",hjust = 0.5))
  
  plots = list(g1,g2,g3,g4)
  pdf(paste0(outDir,Sys.Date(),"QC_report_RNASeq_Neil_Ihrke_Mayo_Human_PanNet_89_BC_samples",".pdf"),width=30,height=10)
  
  lapply(plots, eval)
  
  dev.off()
  
