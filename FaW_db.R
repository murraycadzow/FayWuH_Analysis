library(dplyr)
window=30000
setwd("/run/user/1000/gvfs/smb-share:server=biocldap,share=scratch/merrimanlab/murray/working_dir/Phase3_selection_results/FayWuH/")

pops = c("ACB", "ASW", "AXIOM","BEB", "CDX","CEU","CHB","CHS", "CLM", "ESN", "FIN","GBR", "GIH", "GWD", "IBS", "ITU", "JPT", "KHV", "LWK", "MSL", "MXL","OMNI", "PEL", "PJL", "PUR", "STU", "TSI","YRI")

get_faw = function(faw, pop){
  a= read.table(faw, header=TRUE, skip=5, stringsAsFactors = FALSE)
  names(a)=c("RefStart","Refend","RefMid","Start","End","Midpoint","NumSites","Missing","S","Eta","Eta_E","Pi","FuLi_D","FuLi_F","FayWu_H")
  b=a[a$FayWu_H != "NaN",]
  b$POP=as.factor(pop)
  return(b[,c("Start","End", "NumSites","FayWu_H","POP")])
}


# create the db
library(RMySQL)
drv = dbDriver("MySQL")
db = dbConnect(drv, user="murray", host="127.0.0.1", dbname="selection")
dbGetQuery(db, "CREATE TABLE `faywuh`(`chrom` int(31),`chrom_start` int(10),`chrom_end` int(10), `S` int(10), `Eta` int(10),`Eta_E` int(10), `Pi` float, `FuLi_D` float, `FuLi_F` float, `FayWu_H` float, `Population` varchar(20) );")


#load in each population
for( POP in pops){
  print(POP)

  FWH=data.frame()
  for( i in 1:22){
    temp = read.table(file = paste0(POP,i,".faw"), header=FALSE, skip=5, stringsAsFactors = FALSE)
    names(temp)=c("RefStart","Refend","RefMid","chrom_start","chrom_end","Midpoint","NumSites","Missing","S","Eta","Eta_E","Pi","FuLi_D","FuLi_F","FayWu_H")
    temp$chrom = i
    temp$Population = POP
    FWH=rbind(FWH,temp)
    rm(temp)
  }

  FWH=FWH[FWH$FayWu_H != "NaN",]
  dbWriteTable(db, 'faywuh', FWH %>% select( chrom,chrom_start,chrom_end,S,Eta,Eta_E,Pi,FuLi_D,FuLi_F,FayWu_H,Population), row.names=FALSE, append=TRUE)
  
  #write.table(FWH[,c("CHROM", "Start", "End", "S","Eta","Eta_E","Pi","FuLi_D","FuLi_F","FayWu_H","Pop" )], file=paste0("~/",POP,"_FaW.txt"), row.names=FALSE, col.names=TRUE, sep="\t", quote=FALSE)
}






dbGetQuery(db, "CREATE TABLE `FayWuH`(`chrom` int(31),`chrom_start` int(10),`chrom_end` int(10), `S` int(10), `Eta` int(10),`Eta_E` int(10), `Pi` float, `FuLi_D` float, `FuLiF` float, `FayWu_H` float, `Population` varchar(20) );")
for(POP in c("AXIOM","OMNI","CEU","CHB","CHS","GBR","YRI")){
  dbGetQuery(db,paste0("load data infile '/home/murraycadzow/",POP,"_FaW.txt' into table FayWuH fields terminated by '\t' lines terminated by '\n' ignore 1 rows;"))
}







##mysql
#CREATE TABLE `omni_ihs`(`chrom` int(31),`chrom_start` int(10),`chrom_end` int(10),`marker` varchar(40), `iHS` float, `iHS_rank` int(10),`neglogPvalue` float,`Population` varchar(20) );

#load data infile '/home/murraycadzow/axiom_ihs.txt' into table axiom_ihs fields terminated by '\t' lines terminated by "\n" ignore 1 rows;
