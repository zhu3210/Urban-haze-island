#raed data
city<- read.csv("C:\\Users\\ZL\\Desktop\\0606\\new\\data.csv")
city0=city
#--------------------------------------data processing--------------------------------------------#
###################################################################################################
#First,  find cities whose difference in PM2.5 concentration between the 1 km buffer and 
#the 30 km buffer was smaller than 2 ¦Ìg/m3
name0=list()#store cities with no UHI 
name1=list()#store cities with UHI
for( i in 2:346){
  a=city0[1,i]-city0[30,i]
  if(a<2){
    name0=append(name0,colnames(city0)[i])
  }
  else{name1=append(name1,colnames(city0)[i])}
}
city1=city[,unlist(name0)]
city2=city[,unlist(name1)]

#draw scatter diagram 
l=length(city1)
jpeg(file="class1.png", bg="transparent",width=4800,height=4800,quality = 100,res=300)
par(mfrow=c(9,9))
for(i in 1:l){
  plot(1:50,city1[,i],ylab=name0[i],xlab = 'Distance',ylim = c(min(city1[,i])-5,max(city1[,i])+5))
} 
dev.off()
##################################################################################################
#Second, we adopted an iterative approach to find the maximum distance that could be used 
#to fit the curve. And find the cities that can not be fitted
name_cannot=list()#cities that can be fitted
name_can=list()#cities that can not be fitted
cityf=city2
l=length(cityf)
for(i in 1:l){
  res=list()
  for(j in 10:50){#begin from 10km buffer
    aa=cityf[1:j,i]
    bb=1:j
    try({md <- nls(aa~SSfpl(bb, A, B, xmid, scal))
    a1=coef(md)[[1]]
    a2=coef(md)[[2]]
    if(a2-a1<0){j=0}
    }
    ,silent = T)
    if(j==0){res=append(res,summary(md)$sigma)}
    else {res=append(res,0)}
  }
  a=0
  for(k in 1:41){
  if(res[k]==0){a=a+1}}
  
  if(a==41){name_cannot=append(name_cannot,colnames(cityf)[i])}
  else{name_can=append(name_can,colnames(cityf)[i])}
}
city_cannot=list()
city_cannot=city[,unlist(name_cannot)]
city_can=list()
city_can=city[,unlist(name_can)]

#record the final distence that could be used to fit
dis=list()
l=length(city_can)
for(i in 1:l){
  res=list()
  for(j in 10:50){
    aa=city_can[1:j,i]
    bb=1:j
    try({md <- nls(aa~SSfpl(bb, A, B, xmid, scal))
    a1=coef(md)[[1]]
    a2=coef(md)[[2]]
    if(a2-a1<0){j=0}
    }
    ,silent = T)
    if(j==0){res=append(res,summary(md)$sigma)}
    else {res=append(res,0)}
  }
  for(k in seq(41,1)){
    if(res[k]!=0){dis=append(dis,k+9)
    break}
  }
  }

#draw the pic

windowsFonts(A = windowsFont("Times New Roman"))
l=length(city_can)
jpeg(file="class300.png",width=2400,height=2400,quality = 100,res=300)
par(mfrow=c(4,4))
for(i in 1:l){
  k=dis[[i]]
  aa=city_can[1:k,i]
  bb=1:k
  md <- nls(aa~SSfpl(bb, A, B, xmid, scal))
  plot(bb,city_can[,i],ylab='',xlab = 'Distance(km)',cex.axis=1,cex.lab=1,family="A",mgp=c(3,0.7,0))
  mtext(expression(PM[2.5](ug/m^3)), side = 2, line = 2,family="A",cex=1)
  mtext(colnames(city_can[i]), side = 3, line = 1,family="A",cex=1)
  #plot(bb,aa,ylab = colnames(cityf[i]),xlab = 'distance(km)',cex.axis=2,cex.lab=2)
  
  lines(bb,predict(md),col='red')
  if(i%%16==0){
    dev.off()
    jpeg(file=paste('class30',as.character(i/16),'.png',sep = ''),width=2400,height=2400,quality = 100,res=300)
    par(mfrow=c(4,4))
  }
}
dev.off()
reslut<-cbind(name_can,ran,resd,ma,mi,mi0);reslut
write.csv(name_can,file = 'C:\\Users\\ZL\\Desktop\\0606\\new\\1222select.csv')
#exclude the cities that cannot be properly fitted
name_can1=read.csv("C:\\Users\\ZL\\Desktop\\0606\\new\\select.csv",header = F)
city_can=city_can[,unlist(name_can1$V1)]
dis = dis[unlist(name_can1$V1)]

#Calculate the final UHI parameters
name <- list()#the name of the city
ran <- list()#the extent of the UHI
resd<- list()#the residual of the fitting
ma <- list()#the maximum of the PM2.5
mi0 <- list()#the background value of UHI
windowsFonts(A = windowsFont("Times New Roman"))
l=length(city_can)
jpeg(file="class40.png",width=2400,height=3000,quality = 100,res=300)
par(mfrow=c(5,4))
for(i in 1:l){
  k=dis[[i]]
  aa=city_can[1:k,i]
  bb=1:k
  md <- nls(aa~SSfpl(bb, A, B, xmid, scal))
  md2 <- lm(aa~bb)
  a1=coef(md)[[1]]
  a2=coef(md)[[2]]
  a3=coef(md)[[3]]
  a4=coef(md)[[4]]
  x <- seq(0,50,0.01)
  plot(bb,aa,ylab='',xlab = 'Distance(km)',cex.axis=1,cex.lab=1,family="A",mgp=c(3,0.7,0))
  mtext(expression(PM[2.5](ug/m^3)), side = 2, line = 2,family="A",cex=1)
  mtext(colnames(city_can[i]), side = 3, line = 1,family="A",cex=1)
  #plot(bb,aa,ylab = colnames(cityf[i]),xlab = 'distance(km)',cex.axis=2,cex.lab=2)
  lines(bb,predict(md),col='red')
  if(i%%20==0){
    dev.off()
    jpeg(file=paste('class4',as.character(i/20),'.png',sep = ''),width=2400,height=3000,quality = 100,res=300)
    par(mfrow=c(5,4))
  }
  ep1 <- expression(a1+(a2-a1)/(1+exp((a3-x)/a4)))
  dep <- D(D(ep1,'x'),'x')
  md11<- which.max(eval(dep))
  md1 <- md11/100
  ran <- append(ran,md1)
  name <- append(name,colnames(city_can[i]))
  resd <- append(resd,summary(md)$sigma)
  ma <- append(ma,max(city_can[,i]))
  mi0 <- append(mi0,a2)
  }
dev.off()
reslut<-cbind(name,ran,resd,ma,mi0);reslut
write.csv(reslut,file = 'C:\\Users\\ZL\\Desktop\\0606\\new\\result218.csv')





