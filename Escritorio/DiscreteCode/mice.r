args<-commandArgs(TRUE)
#install.packages("mice", repos="http://cran.rstudio.com/")
read1<-function(dir, path){
  data<- read.csv(paste(dir, path, sep=""), header = FALSE, stringsAsFactors=FALSE, na.strings = "NaN", sep = ",")
  data<-matrix(unlist(data), ncol = ncol(data))
  data[is.nan(data)]<-NA
  
  return(data)
}

write1<-function(path, method, data){
  write(t(data), path, ncolumns = ncol(data), sep = ",")
}

mice1<-function(dir, path, part, data, k){
  
  suppressPackageStartupMessages(library(mice))
  
  set.seed(k)
  
  class<-data[,length(data[1,])]
  
  data<-data[,-length(data[1,])]
  
  malas<-c()
  values<-c()
  for(i in 1:length(data[1,])){
    print(values)
    print(i)
    if(2 > length(levels(factor(data[,i]))))
    {
      malas[length(malas)+1]<-i
      if(is.nan(levels(factor(data[,i]))[1]))
        values[length(values)+1]<-0
      else
        values[length(values)+1]<-as.integer(levels(factor(data[,i]))[1])
    }
  }
  
  print(malas)
  if(length(malas)>0)
    data<-data[,-malas]
  
  x<-length(data[,1])
  
  data<-matrix(as.numeric(data), nrow = x)
  
  if(any(is.na(data))){
    imp <- complete(mice(data, print = FALSE, seed = k))
    data<-matrix(unlist(imp), ncol = ncol(imp))
  }
  
  for(i in malas){
    if(i<2){
      data <- cbind(rep(0, length(data[1,])), data)
    }
    else{
      if(i>=length(data[1,])+length(malas)){
        data <- cbind(data[,1:length(data[1,])], rep(0, length(data[1,])))
      }
      else{
        data <- cbind(data[,1:i-1], rep(values[1], length(data[,1])), data[,(i):length(data[1,])])
        values<-values[-1]
      }
    }
  }
  
  return(cbind(data, class))
}

i<-3;j<-0;k<-13;p<-4;lim<-844;dir<-"/home/unai/Escritorio/DiscreteCode/Data/"


i <- strtoi(args[1])
j <- strtoi(args[2])
k <- strtoi(args[3])
p <- strtoi(args[4])
lim <- strtoi(args[5])
dir <- args[6]

options(warn=-1)

path<-paste(i,"-",j, "-", k, "-", p, ".data", sep = "")

data<-read1(dir, path)
data1<-data[1:lim,]
data1<-mice1(dir, path, p, data[1:lim,], k)
data2<-data[(lim+1):length(data[,1]),]
data2<-mice1(dir, path, p, data[(lim+1):length(data[,1]),], k)

write1(paste(dir, i,"-",j, "-", k, "-", p, "-6", ".data", sep = ""), p, rbind(data1, data2))

