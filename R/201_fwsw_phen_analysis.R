#Author: Sarah P. Flanagan
#Last updated: 9 June 2016
#Date: 9 June 2016
#Purpose: Analyze Population genetics data--with freshwater populations

rm(list=ls())

library(vegan)
library(ggplot2)
library(gdata);library(matrixcalc)

setwd("E:/ubuntushare/popgen/fwsw_results/")
source("../scripts/plotting_functions.R")
source("../scripts/phenotype_functions.R")

pop.list<-c("TXSP","TXCC","TXFW","TXCB","LAFW","ALST","ALFW","FLSG","FLKB",
	"FLFD","FLSI","FLAB","FLPB","FLHB","FLCC","FLLG")
pop.labs<-c("TXSP","TXCC","TXFW","TXCB","LAFW","ALST","ALFW","FLSG","FLKB",
            "FLFD","FLSI","FLAB","FLPB","FLHB","FLCC","FLFW")
fw.list<-c("TXFW","LAFW","ALFW","FLLG")
sw.list<-c("TXSP","TXCC","TXCB","ALST","FLSG","FLKB",
	"FLFD","FLSI","FLAB","FLPB","FLHB","FLCC")
npops<-16

###***************************GENERATE THE FILES**************************###
raw.pheno<-read.table("../sw_results/popgen.pheno.txt", sep="\t", header=T)
	raw.pheno$PopID<-gsub("(\\w{4})\\w+","\\1",raw.pheno$ID)
	raw.pheno<-raw.pheno[raw.pheno$PopID %in% pop.list,]
	raw.pheno$sex<-gsub("\\w{4}(\\w)\\w+","\\1",raw.pheno$ID)
	raw.pheno$TailLength<-raw.pheno$std.length-raw.pheno$SVL
	raw.pheno$HeadLength<-raw.pheno$HeadLength-raw.pheno$SnoutLength

fem.pheno<-raw.pheno[raw.pheno$sex %in% c("F","D"),-8]
	fem.pheno<-fem.pheno[,c(11,1,10,2,12,4,5,6,7,8,9)]
	fem.pheno<-fem.pheno[order(match(fem.pheno$PopID,pop.list)),]
	write.table(fem.pheno,"fem.pheno.txt",sep='\t',row.names=F,col.names=T,
		quote=F)
	
mal.pheno<-raw.pheno[raw.pheno$sex %in% c("P","N"),-8]
	mal.pheno<-mal.pheno[,c(11,1,10,2,12,4,5,6,7)]
	mal.pheno<-mal.pheno[order(match(mal.pheno$PopID,pop.list)),]
	write.table(mal.pheno,"mal.pheno.txt",sep='\t',row.names=F,col.names=T,
		quote=F)
###*****************************READ THE FILES*****************************###
fem.pheno<-read.table("fem.pheno.txt",header=T)
	fem.pheno<-fem.pheno[!is.na(fem.pheno$BandNum),]
mal.pheno<-read.table("mal.pheno.txt",header=T)


##############################################################################
#****************************************************************************#
###################################PCA########################################
#****************************************************************************#
##############################################################################
fem.pheno$PopID<-factor(fem.pheno$PopID)
fem.pheno<-fem.pheno[!is.na(fem.pheno$BandNum),]
mal.pheno$PopID<-factor(mal.pheno$PopID)
bands.pcdat<-fem.pheno[!is.na(fem.pheno$BandNum),
	c("PopID","ID","MBandArea","BandNum")]
#pca per pop
band.pca<-rda(bands.pcdat[,3:4])
fem.pheno.pca<-rda(fem.pheno[,4:9])
mal.pheno.pca<-rda(mal.pheno[,4:9])

pop.pchs<-c(0,1,3,5,4,15,8,17,18,19,21,22,23,24,25,13)
fem.pop<-bands.pcdat$PopID
fem.colors<-as.character(fem.pop)
fem.pch<-as.character(fem.pop)
fw.fem.col<-as.character(fem.pop[fem.pop %in% fw.list])
mal.pop<-mal.pheno$PopID
mal.colors<-as.character(mal.pop)
mal.pch<-as.character(mal.pop)
fw.mal.col<-as.character(mal.pop[mal.pop %in% fw.list])
for(i in 1:length(pop.list)){
  fem.pch[fem.pch==pop.list[i]]<-pop.pchs[i]
  mal.pch[mal.pch==pop.list[i]]<-pop.pchs[i]
	if(pop.list[i] %in% fw.list){
	  fem.colors[fem.colors==pop.list[i]]<-"cornflowerblue"
	  mal.colors[mal.colors==pop.list[i]]<-"cornflowerblue"
		fw.fem.col[fw.fem.col==pop.list[i]]<-"cornflowerblue"
		fw.mal.col[fw.mal.col==pop.list[i]]<-"cornflowerblue"
	}else{
	  fem.colors[fem.colors==pop.list[i]]<-"black"
	  mal.colors[mal.colors==pop.list[i]]<-"black"
	}
}
fem.pch<-as.numeric(fem.pch)
mal.pch<-as.numeric(mal.pch)

fw.fem.rows<-which(fem.pheno$PopID %in% fw.list)
fw.mal.rows<-which(mal.pheno$PopID %in% fw.list)

###************************************PLOT********************************###
png("FWSWPhenotypePCA.png",height=8,width=10,units="in",res=300)
pdf("FWSWPhenotypePCA.pdf",height=8,width=10)
par(mfrow=c(2,3),oma=c(2,2,2,2),mar=c(2,2,2,2),lwd=1.3)
mp<-plot(mal.pheno.pca,type="n",xlim=c(-3,3),ylim=c(-8.2,4)
	,xlab="",ylab="",las=1,cex.axis=1.5)
points(mal.pheno.pca,col=alpha(mal.colors,0.5),cex=1.5,pch=mal.pch)
mtext("PC1 (95.27%)",1,line=2)
mtext("PC2 (4.11%)",2,line=2.5)
legend("top",bty='n',c("Male Body Traits"),cex=1.5)

fp<-plot(fem.pheno.pca,type="n",xlab="",ylab="",las=1,cex.axis=1.5,ylim=c(-4,12),
	xlim=c(-3,3))
points(fem.pheno.pca,col=alpha(fem.colors,0.5),cex=1.5,pch=fem.pch)
mtext("PC1 (90.95%)",1,line=2)
mtext("PC2 (7.73%)",2,line=2.5)
legend("top",bty='n',c("Female Body Traits"),cex=1.5)

bp<-plot(band.pca,type="n",xlab="",ylab="",las=1,cex.axis=1.5,xlim=c(-2,2),ylim=c(-3,1))
points(band.pca,pch=fem.pch,col=alpha(fem.colors,0.5),cex=1.5)
mtext("PC1 (98.38%)",1,line=2)
mtext("PC2 (1.62%)",2,line=2.5)
legend("top",bty='n',c("Female Band Traits"),cex=1.5)


plot(mp$sites[fw.mal.rows,],type="n",
     xlim=c(-3,3),ylim=c(-8.2,4),xlab="",ylab="",las=1,cex.axis=1.5)
abline(h=0,lty=3)
abline(v=0,lty=3)
points(mp$sites[fw.mal.rows,],xlim=c(-0.1,0.1),ylim=c(-.2,.2),
	col=alpha(fw.mal.col,0.5),cex=1.5,pch=mal.pch[fw.mal.rows])
mtext("PC1 (95.27%)",1,line=2)
mtext("PC2 (4.11%)",2,line=2.5)


plot(fp$sites[fw.fem.rows,],type="n",xlab="",ylab="",las=1,
	cex.axis=1.5,ylim=c(-4,12),xlim=c(-3,3))
abline(h=0,lty=3)
abline(v=0,lty=3)
points(fp$sites[fw.fem.rows,],
	col=alpha(fw.fem.col,0.5),cex=1.5,pch=fem.pch[fw.fem.rows])
mtext("PC1 (90.95%)",1,line=2)
mtext("PC2 (7.73%)",2,line=2.5)


plot(bp$sites[fw.fem.rows,],type="n",xlab="",ylab="",las=1,
	cex.axis=1.5,xlim=c(-2,2),ylim=c(-3,1))
points(bp$sites[fw.fem.rows,],
	pch=fem.pch[fw.fem.rows],col=alpha(fw.fem.col,0.5),cex=1.5)
mtext("PC1 (98.38%)",1,line=2)
mtext("PC2 (1.62%)",2,line=2.5)
abline(h=0,lty=3)
abline(v=0,lty=3)

par(fig = c(0, 1, 0, 1), oma=c(2,1,0,1), mar = c(0, 0, 0, 0), new = TRUE,
	cex=1)
plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
legend("top", pop.labs, 
	col=c("black","black","cornflowerblue","black","cornflowerblue","black","cornflowerblue",
	      rep("black",8),"cornflowerblue"),
	pt.cex=1,bty='n',pch=pop.pchs, ncol=8)
dev.off()
###********************************END PLOT********************************###

####extract eigenvalue
band.eig<-band.pca$CA$eig

#extract PC scores
band.u<-data.frame(bands.pcdat[,1:2],"BandPC1"=band.pca$CA$u[,1],stringsAsFactors=F)
band.u.sep<-split(band.u, band.u[,1])
band.u.new<-rbind(band.u.sep$TXSP,band.u.sep$TXCC,band.u.sep$TXCB,
	band.u.sep$ALST,band.u.sep$FLSG,band.u.sep$FLKB,
	band.u.sep$FLFD,band.u.sep$FLSI,band.u.sep$FLAB,
	band.u.sep$FLPB,band.u.sep$FLHB,band.u.sep$FLCC)

fem.pheno.eig<-fem.pheno.pca$CA$eig

#extract PC scores
fem.pheno.u<-data.frame(fem.pheno[,1:2],
	"FemBodyPC1"=fem.pheno.pca$CA$u[,1],stringsAsFactors=F)
fem.u.sep<-split(fem.pheno.u, fem.pheno.u[,1])
fem.u.new<-rbind(fem.u.sep$TXSP,fem.u.sep$TXCC,fem.u.sep$TXCB,
	fem.u.sep$ALST,fem.u.sep$FLSG,fem.u.sep$FLKB,
	fem.u.sep$FLFD,fem.u.sep$FLSI,fem.u.sep$FLAB,
	fem.u.sep$FLPB,fem.u.sep$FLHB,fem.u.sep$FLCC)

mal.pheno.eig<-mal.pheno.pca$CA$eig

#extract PC scores
mal.u<-data.frame(mal.pheno[,1:2],"MalBodyPC1"=mal.pheno.pca$CA$u[,1],
	stringsAsFactors=F)
mal.u.sep<-split(mal.u, mal.u[,1])
mal.u.new<-rbind(mal.u.sep$TXSP,mal.u.sep$TXCC,mal.u.sep$TXCB,
	mal.u.sep$ALST,mal.u.sep$FLSG,mal.u.sep$FLKB,
	mal.u.sep$FLFD,mal.u.sep$FLSI,mal.u.sep$FLAB,
	mal.u.sep$FLPB,mal.u.sep$FLHB,mal.u.sep$FLCC)



##############################################################################
#****************************************************************************#
################################P-MATRIX######################################
#****************************************************************************#
##############################################################################


#females
pops.fem.uns.dat<-split(fem.pheno, fem.pheno$PopID)
pmat.fem.uns.pops<-calc.pmat(pops.fem.uns.dat,4,11)
pmat.fem.uns.body.pops<-calc.pmat(pops.fem.uns.dat,4,9)
pmat.fem.uns.band.pops<-calc.pmat(pops.fem.uns.dat,10,11)

#males
pops.mal.uns.dat<-split(mal.pheno, mal.pheno$PopID)
pmat.mal.uns.pops<-calc.pmat(pops.mal.uns.dat,4,9)

#write pmatrices to file
#following format of presentation in Bertram et al 2011
#variance on diagonal, covariance lower, correlations upper, 
#with p1,p2,and p3 to right
setwd("pmatrix")
for(i in 1:length(pmat.fem.uns.pops)){
	dat<-pmat.fem.uns.pops[[i]]
	dat[upper.tri(dat)]<-
		as.numeric(cor(pmat.fem.uns.pops[[i]])[
		upper.tri(cor(pmat.fem.uns.pops[[i]]))])
	dat<-as.matrix(
		cbind(dat,eigen(pmat.fem.uns.pops[[i]])$vectors[,1:3]))
	colnames(dat)<-c(colnames(fem.pheno)[4:11],
		"p1","p2","p3")
	rownames(dat)<-colnames(fem.pheno)[4:11]
	write.table(dat, 
		paste("pop.",names(pmat.fem.uns.pops)[i], ".pmat_unstd.txt", sep=""), 
		sep='\t',
		eol='\n', row.names=T, col.names=T, quote=F)

}

for(i in 1:length(pmat.mal.uns.pops)){
	dat<-pmat.mal.uns.pops[[i]]
	dat[upper.tri(dat)]<-
		as.numeric(cor(pmat.mal.uns.pops[[i]])[
		upper.tri(cor(pmat.mal.uns.pops[[i]]))])
	dat<-as.matrix(
		cbind(dat,eigen(pmat.mal.uns.pops[[i]])$vectors[,1:3]))
	colnames(dat)<-c(colnames(mal.pheno)[4:9],
		"p1","p2","p3")
	rownames(dat)<-colnames(mal.pheno)[4:9]
	write.table(dat, 
		paste("pop.",names(pmat.mal.uns.pops)[i], 
			".male.pmat_unstd.txt", sep=""), 
		sep='\t',
		eol='\n', row.names=T, col.names=T, quote=F)

}

###****************************MULTIPLE SUBSPACES**************************###
h.fem<-calc.h(pmat.fem.uns.pops)
h.mal<-calc.h(pmat.mal.uns.pops)

h.fem.ang<-data.frame(FemAngle1=do.call("rbind",
	lapply(pmat.fem.uns.pops,pop.h.angle,H=h.fem,h.eig=1)),
	FemAngle2=do.call("rbind",
	lapply(pmat.fem.uns.pops,pop.h.angle,H=h.fem,h.eig=2)),
	FemAngle3=do.call("rbind",
	lapply(pmat.fem.uns.pops,pop.h.angle,H=h.fem,h.eig=3)))
rownames(h.fem.ang)<-names(pmat.fem.uns.pops)
h.fem.ang<-h.fem.ang[match(pop.list,rownames(h.fem.ang)),]
write.csv(h.fem.ang,"CommonSubspaceAngles_Fem.csv")

h.mal.ang<-data.frame(MalAngle1=do.call("rbind",
	lapply(pmat.mal.uns.pops,pop.h.angle,H=h.mal,h.eig=1)),
	MalAngle2=do.call("rbind",
	lapply(pmat.mal.uns.pops,pop.h.angle,H=h.mal,h.eig=2)),
	MalAngle3=do.call("rbind",
	lapply(pmat.mal.uns.pops,pop.h.angle,H=h.mal,h.eig=3)))
rownames(h.mal.ang)<-names(pmat.mal.uns.pops)
h.mal.ang<-h.mal.ang[match(pop.list,rownames(h.mal.ang)),]
write.csv(h.mal.ang,"CommonSubspaceAngles_Mal.csv")

write.csv(h.fem,"CommonSubspaceFemales.csv")
write.csv(h.mal,"CommonSubspaceMales.csv")

write.csv(cbind(eigen(h.fem)$values,eigen(h.fem)$vectors),
	"HfemalesEigenvectors.csv")
write.csv(cbind(eigen(h.mal)$values,eigen(h.mal)$vectors),
	"HmalesEigenvectors.csv")
###*******************************TENSORS*********************************###
#Adapted from Aguirre et al. 2013 supplemental material
f.n.traits<-8
m.n.traits<-6
pop.names<-names(pmat.fem.uns.pops)
fem.tensor<-covtensor(pmat.fem.uns.pops)
mal.tensor<-covtensor(pmat.mal.uns.pops)
#eigenvalues for the nonzero eigentensors
fem.tensor$s.alpha[,1:fem.tensor$nonzero]
fem.tensor$tensor.summary[
	1:((ncol(fem.tensor$tensor.summary)-2)*fem.tensor$nonzero),]
#plot coordinates of female p matrix in the space of e1 and e2 
plot(fem.tensor$p.coord[,1], ylim=c(-50,100), xaxt="n", las=1,
	xlab="Population", ylab="alpha")
axis(1, at=seq(1,16,1), labels=F)
text(x=seq(1,16,1), labels=pop.names, par("usr")[1]-230,
	srt=-45, xpd=TRUE)
lines(fem.tensor$p.coord[,1], lty=2)
points(fem.tensor$p.coord[,2], pch=19)
lines(fem.tensor$p.coord[,2], lty=1)
points(fem.tensor$p.coord[,3], pch=15)
lines(fem.tensor$p.coord[,3],lty=4)
legend("bottomright", pch=c(1,19,15),lty=c(2,1,4), c("e1","e2","e3")) 
#trait combinations for e1, e2, and e3
round(fem.tensor$tensor.summary[1:(f.n.traits*3),
	2:dim(fem.tensor$tensor.summary)[2]], 3)

#determine which eigenvector explains the most variation in eigentensors
e1.max<-max.eig.val(fem.tensor$tensor.summary$eT.val[1:f.n.traits])
e2.max<-max.eig.val(fem.tensor$tensor.summary$eT.val[(f.n.traits+1):(2*f.n.traits)])
e3.max<-max.eig.val(fem.tensor$tensor.summary$eT.val[((f.n.traits*2)+1):(3*f.n.traits)])


#project eigentensors on the observed array
f.e1.L <- c(as.numeric(fem.tensor$tensor.summary[1,
	3:dim(fem.tensor$tensor.summary)[2]]))
f.e2.L <- c(as.numeric(fem.tensor$tensor.summary[(f.n.traits+1),
	3:dim(fem.tensor$tensor.summary)[2]]))
f.e3.L <- c(as.numeric(fem.tensor$tensor.summary[((f.n.traits*2)+1),
	3:dim(fem.tensor$tensor.summary)[2]]))

m.e1.L <- c(as.numeric(mal.tensor$tensor.summary[1,
	3:dim(mal.tensor$tensor.summary)[2]]))
m.e2.L <- c(as.numeric(mal.tensor$tensor.summary[(m.n.traits+1),
	3:dim(mal.tensor$tensor.summary)[2]]))
m.e3.L <- c(as.numeric(mal.tensor$tensor.summary[((m.n.traits*2)+1),
	3:dim(mal.tensor$tensor.summary)[2]]))


#variance along e1 and e2
f.e11.proj <- lapply(pmat.fem.uns.pops, proj, b = f.e1.L)
f.e21.proj <- lapply(pmat.fem.uns.pops, proj, b = f.e2.L)
f.e31.proj <- lapply(pmat.fem.uns.pops, proj, b = f.e3.L)

m.e11.proj <- lapply(pmat.mal.uns.pops, proj, b = m.e1.L)
m.e21.proj <- lapply(pmat.mal.uns.pops, proj, b = m.e2.L)
m.e31.proj <- lapply(pmat.mal.uns.pops, proj, b = m.e3.L)

###Write info to files
write.csv(fem.tensor$s.mat,"FemaleSmatrix.csv")
write.csv(mal.tensor$s.mat,"MaleSmatrix.csv")

write.csv(fem.tensor$tensor.summary,"FemaleTensorSummary.csv")
write.csv(mal.tensor$tensor.summary,"MaleTensorSummary.csv")
#******************************PLOT PMATRIX**********************************#
jpeg("FWSWPmatrix_analyses.jpeg", width=14, height=14, units="in", res=300)
pdf("FWSWPmatrix_analyses.pdf",width=14,height=14)
par(mfrow=c(2,2),lwd=1.3,cex=1.3,oma=c(2,2,2,2))

#common subspace females
par(mar=c(3,5,2,1))
plot(x=seq(1,npops,1),h.fem.ang[,1],col="red",
	 xaxt="n", las=1,ylim=c(0,0.4),xlab="Population", ylab="angle")
axis(1, at=seq(1,npops,1), labels=F)
text(x=seq(1,npops,1), labels=pop.list, par("usr")[1]-0.45,
	srt=-45, xpd=TRUE,
	col=c("black","black","dark green","black","dark green","black",
		"dark green",rep("black",8),"dark green"))
lines(x=seq(1,npops,1),h.fem.ang[,1], lty=2,col="red")
points(x=seq(1,npops,1),h.fem.ang[,2], pch=19,col="red")
lines(x=seq(1,npops,1),h.fem.ang[,2], lty=1,col="red")
points(x=seq(1,npops,1),h.fem.ang[,3], pch=15,col="red")
lines(x=seq(1,npops,1),h.fem.ang[,3],lty=4,col="red")
legend("topright", pch=c(1,19,15), lty=c(2,1,4), c(expression(bolditalic(h)[1]),
	expression(bolditalic(h)[2]),expression(bolditalic(h)[3])),col="red",
	ncol=3)
mtext("Females",3,line=1.5,cex=1.3)
text(x=1,y=0.4, "A", font=2)

#common subspace males
par(mar=c(3,5,2,1))
plot(x=seq(1,npops,1),h.mal.ang[,1],col="blue",
	 xaxt="n", las=1,ylim=c(0,1.2),xlab="Population", ylab="angle")
axis(1, at=seq(1,npops,1), labels=F)
text(x=seq(1,npops,1), labels=pop.list, par("usr")[1]-0.55,
	srt=-45, xpd=TRUE,
	col=c("black","black","dark green","black","dark green","black",
		"dark green",rep("black",8),"dark green"))
lines(x=seq(1,npops,1),h.mal.ang[,1], lty=2,col="blue")
points(x=seq(1,npops,1),h.mal.ang[,2], pch=19,col="blue")
lines(x=seq(1,npops,1),h.mal.ang[,2], lty=1,col="blue")
points(x=seq(1,npops,1),h.mal.ang[,3], pch=15,col="blue")
lines(x=seq(1,npops,1),h.mal.ang[,3],lty=4,col="blue")
legend("topright", pch=c(1,19,15), lty=c(2,1,4), c(expression(bolditalic(h)[1]),
	expression(bolditalic(h)[2]),expression(bolditalic(h)[3])),col="blue",
	ncol=3)
mtext("Males",3,line=1.5,cex=1.3)
text(x=1,y=1, "B", font=2)

#plot the variance in each population in the direction of e11,e21, and e31
par(mar=c(3,5,2,1))
f.e11.proj<-f.e11.proj[match(pop.list,names(f.e11.proj))]
f.e21.proj<-f.e21.proj[match(pop.list,names(f.e21.proj))]
f.e31.proj<-f.e31.proj[match(pop.list,names(f.e31.proj))]
plot(x=seq(1,npops,1),f.e11.proj, col="red",
	xaxt="n", las=1,ylim=c(0,100),xlab="", ylab="lambda")
axis(1, at=seq(1,npops,1), labels=F)
text(x=seq(1,npops,1), labels=pop.list, par("usr")[1]-12,
	srt=-45, xpd=TRUE,
	col=c("black","black","dark green","black","dark green","black",
		"dark green",rep("black",8),"dark green"))
lines(x=seq(1,npops,1),f.e11.proj, lty=2,col="red")
points(x=seq(1,npops,1),f.e21.proj, pch=19,col="red")
lines(x=seq(1,npops,1),f.e21.proj, lty=1,col="red")
points(x=seq(1,npops,1),f.e31.proj, pch=15,col="red")
lines(x=seq(1,npops,1),f.e31.proj,lty=4,col="red")
legend("topright", pch=c(1,19,15), lty=c(2,1,4),
	 c(expression(bolditalic(e)[11]),expression(bolditalic(e)[21]),
	expression(bolditalic(e)[31])),col="red")

text(x=1,y=100, "C", font=2)

par(mar=c(3,5,2,1))
m.e11.proj<-m.e11.proj[match(pop.list,names(m.e11.proj))]
m.e21.proj<-m.e21.proj[match(pop.list,names(m.e21.proj))]
m.e31.proj<-m.e31.proj[match(pop.list,names(m.e31.proj))]
plot(x=seq(1,npops,1),m.e11.proj,col="blue",
	 xaxt="n", las=1,ylim=c(0,100),xlab="Population", ylab="lambda")
axis(1, at=seq(1,npops,1), labels=F)
text(x=seq(1,npops,1), labels=pop.list, par("usr")[1]-12,
	srt=-45, xpd=TRUE,
	col=c("black","black","dark green","black","dark green","black",
		"dark green",rep("black",8),"dark green"))
lines(x=seq(1,npops,1),m.e11.proj, lty=2,col="blue")
points(x=seq(1,npops,1),m.e21.proj, pch=19,col="blue")
lines(x=seq(1,npops,1),m.e21.proj, lty=1,col="blue")
points(x=seq(1,npops,1),m.e31.proj, pch=15,col="blue")
lines(x=seq(1,npops,1),m.e31.proj,lty=4,col="blue")
legend("topright", pch=c(1,19,15), lty=c(2,1,4), 
	 c(expression(bolditalic(e)[11]),expression(bolditalic(e)[21]),
	expression(bolditalic(e)[31])),col="blue")
text(x=1,y=100, "D", font=2)
mtext("Population",1,outer=T,cex=1.3)
dev.off()


#**************************SUPPLEMENTAL FIGURES*****************************#
#summary plots
jpeg("Subspace_eigenvalues.jpeg", width=7, height=7, units="in", res=300)
pdf("Subspace_eigenvalues.pdf", width=7, height=7)
par(lwd=1.3,cex=1.3,oma=c(2,2,2,2))
#common subspace
par(mar=c(3,5,2,1))
plot(seq(1,8,1),eigen(h.fem)$values,pch=25,col="red",bg="red",xaxt='n',
	yaxt='n',xlab="",ylab="")
axis(1,at=seq(1.1,8.1,1),labels=c(expression(bolditalic(h)[1]),
	expression(bolditalic(h)[2]),expression(bolditalic(h)[3]),
	expression(bolditalic(h)[4]),expression(bolditalic(h)[5]),
	expression(bolditalic(h)[6]),expression(bolditalic(h)[7]),
	expression(bolditalic(h)[8])))
mtext(expression(Eigenvectors~of~bold(H)),1,line=2,cex=1.3)
axis(2,las=1)
mtext(expression(Eigenvalues~of~bold(H)),2,line=2,cex=1.3)
points(seq(1.2,6.2,1),eigen(h.mal)$values,pch=15,col="blue")
legend("top",c("Female","Male"),pch=c(25,15),
	col=c("red","blue"),pt.bg=c("red","blue"))
dev.off()

jpeg("Eigentensor_alphas.jpeg", width=7, height=7, units="in", res=300)
pdf("Eigentensor_alphas.pdf", width=7, height=7)
par(lwd=1.3,cex=1.3,oma=c(2,2,2,2))
#plot eigenvalues of non-zero eigentensors for S
par(mar=c(3,5,2,1))
plot(fem.tensor$s.alpha[,1:fem.tensor$nonzero], ylab="alpha",
	xlab="", xaxt="n", las=1,pch=25,col="red",bg="red")#3 until it levels off.
axis(1, at=seq(1.1,fem.tensor$nonzero+0.1,1), 
	labels=c(expression(bolditalic(E)[1]),
	expression(bolditalic(E)[2]),expression(bolditalic(E)[3]),
	expression(bolditalic(E)[4]),expression(bolditalic(E)[5]),
	expression(bolditalic(E)[6]),expression(bolditalic(E)[7]),
	expression(bolditalic(E)[8]),expression(bolditalic(E)[9]),
	expression(bolditalic(E)[10]),expression(bolditalic(E)[11]),
	expression(bolditalic(E)[12]),expression(bolditalic(E)[13]),
	expression(bolditalic(E)[14]),expression(bolditalic(E)[15])))
points(seq(1.2,mal.tensor$nonzero+0.2,1),
	mal.tensor$s.alpha[,1:mal.tensor$nonzero],pch=15,col="blue")
legend("top", ,c("Female","Male"),pch=c(25,15),
	col=c("red","blue"),pt.bg=c("red","blue"))
mtext("Eigentensors of fourth-order covariance tensor",1,line=2,cex=1.3)
text(x=11,y=395, "B", font=2)
dev.off()

fc1<-fem.tensor$p.coord[,1][match(pop.list,names(fem.tensor$p.coord[,1]))]
fc2<-fem.tensor$p.coord[,2][match(pop.list,names(fem.tensor$p.coord[,2]))]
fc3<-fem.tensor$p.coord[,3][match(pop.list,names(fem.tensor$p.coord[,3]))]
jpeg("FemaleCoordinatesInEspace.jpeg",height=7,width=21,units="in",res=300)
pdf("FemaleCoordinatesInEspace.pdf",height=7,width=21)
par(mfrow=c(1,3),oma=c(3,2,1,1),mar=c(4,2,2,2),cex=1.3,lwd=1.3)
plot(fc1,pch=6,xaxt='n',ylab="Coordinates",xlab="")
axis(1, at=seq(1,npops,1), labels=F)
text(x=seq(1,npops,1), labels=pop.list, par("usr")[1]-4,
	srt=-45, xpd=TRUE)
text(x=1,y=70,"E1")
plot(fc2,pch=6,xaxt='n',ylab="Coordinates",xlab="")
axis(1, at=seq(1,npops,1), labels=F)
text(x=seq(1,npops,1), labels=pop.list, par("usr")[1]-45,
	srt=-45, xpd=TRUE)
text(x=1,y=15,"E2")
plot(fc3,pch=6,xaxt='n',ylab="Coordinates",xlab="")
axis(1, at=seq(1,npops,1), labels=F)
text(x=seq(1,npops,1), labels=pop.list, par("usr")[1]-35,
	srt=-45, xpd=TRUE)
text(x=1,y=-0.25,"E3")
dev.off()



mc1<-mal.tensor$p.coord[,1][match(pop.order,names(mal.tensor$p.coord[,1]))]
mc2<-mal.tensor$p.coord[,2][match(pop.order,names(mal.tensor$p.coord[,2]))]
mc3<-mal.tensor$p.coord[,3][match(pop.order,names(mal.tensor$p.coord[,3]))]
jpeg("MaleCoordinatesInEspace.jpeg",height=7,width=21,units="in",res=300)
pdf("MaleCoordinatesInEspace.pdf",height=7,width=21)
par(mfrow=c(1,3),oma=c(3,2,1,1),mar=c(4,2,2,2),cex=1.3,lwd=1.3)
plot(mc1,xaxt='n',ylab="Coordinates",xlab="")
axis(1, at=seq(1,12,1), labels=F)
text(x=seq(1,12,1), labels=pop.order, par("usr")[1]-85,
	srt=-45, xpd=TRUE)
text(x=12,y=-15,"E1")
plot(mc2,xaxt='n',ylab="Coordinates",xlab="")
axis(1, at=seq(1,12,1), labels=F)
text(x=seq(1,12,1), labels=pop.order, par("usr")[1]-14,
	srt=-45, xpd=TRUE)
text(x=12,y=6,"E2")
plot(mc3,xaxt='n',ylab="Coordinates",xlab="")
axis(1, at=seq(1,12,1), labels=F)
text(x=seq(1,12,1), labels=pop.order, par("usr")[1]-0.25,
	srt=-45, xpd=TRUE)
text(x=12,y=11.5,"E3")
dev.off()

##############################################################################
#****************************************************************************#
####################################PST-FST###################################
#****************************************************************************#
##############################################################################

setwd("pst-fst")
#*******************************PST COMPARISONS******************************#
fem.psts<-apply(fem.pheno[,4:11],2,function(x){
	pst<-pairwise.pst(data.frame(fem.pheno[,3],x),pop.list)
	return(pst)
})
for(i in 1:length(fem.psts)){
	write.table(fem.psts[[i]],paste(names(fem.psts)[i],".fem.pst.txt",sep=""),
		sep='\t',quote=F)
}
mal.psts<-apply(mal.pheno[,4:9],2,function(x){
	pst<-pairwise.pst(data.frame(mal.pheno[,3],x),pop.list)
	return(pst)
})
for(i in 1:length(mal.psts)){
	write.table(mal.psts[[i]],paste(names(mal.psts)[i],".mal.pst.txt",sep=""),
		sep='\t',quote=F)
}

fem.fst.upst<-all.traits.pst.mantel(fem.unstd.new,pwise.fst.sub,1)
mal.fst.upst<-all.traits.pst.mantel(mal.unstd.new,pwise.fst.sub,1)

fem.upst.dist<-all.traits.pst.mantel(fem.unstd.new,dist,1)
mal.upst.dist<-all.traits.pst.mantel(mal.unstd.new,dist,1)

fem.pst.fst.loc<-fst.pst.byloc(sub.ped,fem.unstd.new,pop.list,1)
fpf<-data.frame(SVL.Obs=fem.pst.fst.loc[[1]],SVL.P=fem.pst.fst.loc[[2]],
	TailLength.Obs=fem.pst.fst.loc[[3]],TailLength.P=fem.pst.fst.loc[[4]],
	BodyDepth.Obs=fem.pst.fst.loc[[5]],BodyDepth.P=fem.pst.fst.loc[[6]],
	SnoutLength.Obs=fem.pst.fst.loc[[7]],SnoutLength.P=fem.pst.fst.loc[[8]],
	SnoutDepth.Obs=fem.pst.fst.loc[[9]],SnoutDepth.P=fem.pst.fst.loc[[10]],
	HeadLength.Obs=fem.pst.fst.loc[[11]],HeadLength.P=fem.pst.fst.loc[[12]],
	BandArea.Obs=fem.pst.fst.loc[[13]],BandArea.P=fem.pst.fst.loc[[14]],
	BandNum.Obs=fem.pst.fst.loc[[15]],BandNum.P=fem.pst.fst.loc[[16]])
row.names(fpf)<-sub.map$V2
mal.pst.fst.loc<-fst.pst.byloc(sub.ped,mal.unstd.new,pop.list,1)
mpf<-data.frame(SVL.Obs=mal.pst.fst.loc[[1]],SVL.P=mal.pst.fst.loc[[2]],
	TailLength.Obs=mal.pst.fst.loc[[3]],TailLength.P=mal.pst.fst.loc[[4]],
	BodyDepth.Obs=mal.pst.fst.loc[[5]],BodyDepth.P=mal.pst.fst.loc[[6]],
	SnoutLength.Obs=mal.pst.fst.loc[[7]],SnoutLength.P=mal.pst.fst.loc[[8]],
	SnoutDepth.Obs=mal.pst.fst.loc[[9]],SnoutDepth.P=mal.pst.fst.loc[[10]],
	HeadLength.Obs=mal.pst.fst.loc[[11]],HeadLength.P=mal.pst.fst.loc[[12]])
row.names(mpf)<-sub.map$V2

fpf.sig<-fpf[fpf$SVL.P <= 0.05 | fpf$TailLength.P <= 0.05 | 
	fpf$BodyDepth.P <= 0.05 | fpf$SnoutLength.P <= 0.05 | 
	fpf$SnoutDepth.P <= 0.05 | fpf$HeadLength.P <= 0.05 | 
	fpf$BandArea.P <= 0.05 | fpf$BandNum.P <= 0.05,]
mpf.sig<-mpf[mpf$SVL.P <= 0.05 | mpf$TailLength.P <= 0.05 | 
	mpf$BodyDepth.P <= 0.05 | mpf$SnoutLength.P <= 0.05 | 
	mpf$SnoutDepth.P <= 0.05 | mpf$HeadLength.P <= 0.05,]


svl.sig<-rownames(fpf)[rownames(fpf[fpf$SVL.P <= 0.05,]) %in%
	rownames(mpf[mpf$SVL.P <= 0.05,])]
write.table(svl.sig,"pstfst/SVL_pstfst.txt",col.names=F,row.names=F,quote=F)
write.table(gsub("(\\d+)_\\d+","\\1",svl.sig),
	"pstfst/SVL_radloc.txt",col.names=F,row.names=F,quote=F)
svl.5kb<-all.map[all.map$V2 %in% svl.sig,c(1,4)]
svl.5kb$start<-svl.5kb$V4-2500
svl.5kb$stop<-svl.5kb$V4+2500
write.table(create.extract.sh(svl.5kb[,-2]),
	"pstfst/SVL_extract.sh",col.names=F, row.names=F,
	quote=F,eol='\n')

tail.sig<-rownames(fpf)[rownames(fpf[fpf$TailLength.P <= 0.05,]) %in%
	rownames(mpf[mpf$TailLength.P <= 0.05,])]
write.table(tail.sig,"pstfst/TailLength_pstfst.txt",col.names=F,row.names=F,quote=F)
write.table(gsub("(\\d+)_\\d+","\\1",tail.sig),
	"pstfst/TailLength_radloc.txt",col.names=F,row.names=F,quote=F)
tail.5kb<-all.map[all.map$V2 %in% tail.sig,c(1,4)]
tail.5kb$start<-tail.5kb$V4-2500
tail.5kb$stop<-tail.5kb$V4+2500
write.table(create.extract.sh(tail.5kb[,-2]),
	"pstfst/TailLength_extract.sh",col.names=F, row.names=F,
	quote=F,eol='\n')

body.sig<-rownames(fpf)[rownames(fpf[fpf$BodyDepth.P <= 0.05,]) %in%
	rownames(mpf[mpf$BodyDepth.P <= 0.05,])]
write.table(body.sig,"pstfst/BodyDepth_pstfst.txt",col.names=F,row.names=F,quote=F)
write.table(gsub("(\\d+)_\\d+","\\1",body.sig),
	"pstfst/TailLength_radloc.txt",col.names=F,row.names=F,quote=F)
body.5kb<-all.map[all.map$V2 %in% body.sig,c(1,4)]
body.5kb$start<-body.5kb$V4-2500
body.5kb$stop<-body.5kb$V4+2500
write.table(create.extract.sh(body.5kb[,-2]),
	"pstfst/BodyDepth_extract.sh",col.names=F, row.names=F,
	quote=F,eol='\n')

sntl.sig<-rownames(fpf)[rownames(fpf[fpf$SnoutLength.P <= 0.05,]) %in%
	rownames(mpf[mpf$SnoutLength.P <= 0.05,])]
write.table(sntl.sig,"pstfst/SnoutLength_pstfst.txt",col.names=F,row.names=F,quote=F)
write.table(gsub("(\\d+)_\\d+","\\1",sntl.sig),
	"pstfst/SnoutLength_radloc.txt",col.names=F,row.names=F,quote=F)
sntl.5kb<-all.map[all.map$V2 %in% sntl.sig,c(1,4)]
sntl.5kb$start<-sntl.5kb$V4-2500
sntl.5kb$stop<-sntl.5kb$V4+2500
write.table(create.extract.sh(sntl.5kb[,-2]),
	"pstfst/SnoutLength_extract.sh",col.names=F, row.names=F,
	quote=F,eol='\n')

head.sig<-rownames(fpf)[rownames(fpf[fpf$HeadLength.P <= 0.05,]) %in%
	rownames(mpf[mpf$HeadLength.P <= 0.05,])]
write.table(head.sig,"pstfst/HeadLength_pstfst.txt",col.names=F,row.names=F,quote=F)
write.table(gsub("(\\d+)_\\d+)","\\1",head.sig),
	"pstfst/HeadLength_radloc.txt",col.names=F,row.names=F,quote=F)
head.5kb<-all.map[all.map$V2 %in% head.sig,c(1,4)]
head.5kb$start<-head.5kb$V4-2500
head.5kb$stop<-head.5kb$V4+2500
write.table(create.extract.sh(head.5kb[,-2]),
	"pstfst/HeadLength_extract.sh",col.names=F, row.names=F,
	quote=F,eol='\n')

sntd.sig<-rownames(fpf)[rownames(fpf[fpf$SnoutDepth.P <= 0.05,]) %in%
	rownames(mpf[mpf$SnoutDepth.P <= 0.05,])]
write.table(sntd.sig,"pstfst/SnoutDepth_pstfst.txt",col.names=F,row.names=F,quote=F)
write.table(gsub("(\\d+)_\\d+","\\1",sntd.sig),
	"pstfst/SnoutDepth_radloc.txt",col.names=F,row.names=F,quote=F)
sntd.5kb<-all.map[all.map$V2 %in% sntd.sig,c(1,4)]
sntd.5kb$start<-sntd.5kb$V4-2500
sntd.5kb$stop<-sntd.5kb$V4+2500
write.table(create.extract.sh(sntd.5kb[,-2]),
	"pstfst/SnoutDepth_extract.sh",col.names=F, row.names=F,
	quote=F,eol='\n')

band.sig<-rownames(fpf[fpf$BandArea.P <= 0.05 | 
	fpf$BandNum.P <=0.05,])
write.table(band.sig,"pstfst/Bands_pstfst.txt",col.names=F,row.names=F,quote=F)
write.table(gsub("(\\d+)_\\d+","\\1",band.sig),
	"pstfst/Bands_radloc.txt",col.names=F,row.names=F,quote=F)
band.5kb<-all.map[all.map$V2 %in% band.sig,c(1,4)]
band.5kb$start<-band.5kb$V4-2500
band.5kb$stop<-band.5kb$V4+2500
write.table(create.extract.sh(band.5kb[,-2]),
	"pstfst/Bands_extract.sh",col.names=F, row.names=F,
	quote=F,eol='\n')

sig.all<-rownames(fpf)[rownames(fpf) %in% svl.sig & 
	rownames(fpf) %in% tail.sig & rownames(fpf) %in% body.sig & 
	rownames(fpf) %in% sntd.sig & rownames(fpf) %in% sntl.sig & 
	rownames(fpf) %in% head.sig & rownames(fpf) %in% band.sig] # "7875_9"   "24777_60" "5317_10" 

#WRITE TO FILE, after other files have been written
svl.sig<-read.table("pstfst/SVL_pstfst.txt")
tail.sig<-read.table("pstfst/TailLength_pstfst.txt")
body.sig<-read.table("pstfst/BodyDepth_pstfst.txt")
sntl.sig<-read.table("pstfst/SnoutLength_pstfst.txt")
head.sig<-read.table("pstfst/HeadLength_pstfst.txt")
sntd.sig<-read.table("pstfst/SnoutDepth_pstfst.txt")
band.sig<-read.table("pstfst/Bands_pstfst.txt")

svl.sig<-all.map[all.map$V2 %in% svl.sig$V1,]
colnames(svl.sig)<-c("scaffold","SNP","Dist","BP")
svl.sig$locus<-gsub("(\\d+)_\\d+","\\1",svl.sig$SNP)
tail.sig<-all.map[all.map$V2 %in% tail.sig$V1,]
colnames(tail.sig)<-c("scaffold","SNP","Dist","BP")
tail.sig$locus<-gsub("(\\d+)_\\d+","\\1",tail.sig$SNP)
body.sig<-all.map[all.map$V2 %in% body.sig$V1,]
colnames(body.sig)<-c("scaffold","SNP","Dist","BP")
body.sig$locus<-gsub("(\\d+)_\\d+","\\1",body.sig$SNP)
sntl.sig<-all.map[all.map$V2 %in% sntl.sig$V1,]
colnames(sntl.sig)<-c("scaffold","SNP","Dist","BP")
sntl.sig$locus<-gsub("(\\d+)_\\d+","\\1",sntl.sig$SNP)
head.sig<-all.map[all.map$V2 %in% head.sig$V1,]
colnames(head.sig)<-c("scaffold","SNP","Dist","BP")
head.sig$locus<-gsub("(\\d+)_\\d+","\\1",head.sig$SNP)
sntd.sig<-all.map[all.map$V2 %in% sntd.sig$V1,]
colnames(sntd.sig)<-c("scaffold","SNP","Dist","BP")
sntd.sig$locus<-gsub("(\\d+)_\\d+","\\1",sntd.sig$SNP)
band.sig<-all.map[all.map$V2 %in% band.sig$V1,]
colnames(band.sig)<-c("scaffold","SNP","Dist","BP")
band.sig$locus<-gsub("(\\d+)_\\d+","\\1",band.sig$SNP)

tags<-read.table("stacks/batch_1.catalog.tags.tsv",sep='\t',header=F)
seqs<-tags[,c("V3","V10")]
svl.sig<-merge(svl.sig,seqs, by.x="locus",by.y="V3")
svl.sig$Trait<-"SVL"
tail.sig<-merge(tail.sig,seqs, by.x="locus",by.y="V3")
tail.sig$Trait<-"Tail Length"
body.sig<-merge(body.sig,seqs, by.x="locus",by.y="V3")
body.sig$Trait<-"Body Depth"
sntl.sig<-merge(sntl.sig,seqs, by.x="locus",by.y="V3")
sntl.sig$Trait<-"Snout Length"
head.sig<-merge(head.sig,seqs, by.x="locus",by.y="V3")
head.sig$Trait<-"Head Length"
sntd.sig<-merge(sntd.sig,seqs, by.x="locus",by.y="V3")
sntd.sig$Trait<-"Snout Depth"
band.sig<-merge(band.sig,seqs, by.x="locus",by.y="V3")
band.sig$Trait<-"Bands"
pstfst.sig<-data.frame(rbind(svl.sig,tail.sig,body.sig,sntl.sig,head.sig,
	sntd.sig,band.sig))
write.csv(pstfst.sig,"pstfst/pstfst_loci_summary.csv")


chroms<-levels(factor(c(as.character(svl.5kb$V1),as.character(body.5kb$V1),
	as.character(sntl.5kb$V1),as.character(sntd.5kb$V1),
	as.character(tail.5kb$V1),as.character(head.5kb$V1),
	as.character(band.5kb$V1))))
write.table(chroms,"pstfst/pstfst.sig_scaffolds.txt",col.names=F,row.names=F,
	quote=F)

sig.fst.ibd<-ibd.by.loc[ibd.by.loc$P <= 0.05,]
length(rownames(sig.fst.ibd)[rownames(sig.fst.ibd) %in% rownames(svl.sig)])
length(rownames(sig.fst.ibd)[rownames(sig.fst.ibd) %in% rownames(tail.sig)])
length(rownames(sig.fst.ibd)[rownames(sig.fst.ibd) %in% rownames(body.sig)])
length(rownames(sig.fst.ibd)[rownames(sig.fst.ibd) %in% rownames(sntl.sig)])
length(rownames(sig.fst.ibd)[rownames(sig.fst.ibd) %in% rownames(sntd.sig)])
length(rownames(sig.fst.ibd)[rownames(sig.fst.ibd) %in% rownames(head.sig)])
length(rownames(sig.fst.ibd)[rownames(sig.fst.ibd) %in% rownames(band.sig)])

length(outliers$SNP[outliers$SNP %in% svl.sig$SNP])
length(outliers$SNP[outliers$SNP %in% tail.sig$SNP])
length(outliers$SNP[outliers$SNP %in% body.sig$SNP])
length(outliers$SNP[outliers$SNP %in% sntl.sig$SNP])
length(outliers$SNP[outliers$SNP %in% sntd.sig$SNP])
length(outliers$SNP[outliers$SNP %in% head.sig$SNP])
length(outliers$SNP[outliers$SNP %in% band.sig$SNP])

#merge with outlier and BF analyses
pstfst.sig$analysis<-pstfst.sig$Trait
pst.out.bf<-data.frame(rbind(pstfst.sig[,c("locus","scaffold","BP","analysis")],
	outliers))
#***************PST PCA*****************#
fem.pheno$PopID<-factor(fem.pheno$PopID)
mal.pheno$PopID<-factor(mal.pheno$PopID)
bands.pcdat<-fem.pheno[,c(1,2,9,10)]
#pca per pop
band.pca<-rda(bands.pcdat[,3:4])
fem.pheno.pca<-rda(fem.pheno[,3:8])
mal.pheno.pca<-rda(mal.pheno[,3:8])


fem.pop<-bands.pcdat$PopID
fem.colors<-as.character(fem.pop)
fem.colors[fem.colors=="TXSP"]<-rainbow(12)[1]
fem.colors[fem.colors=="TXCC"]<-rainbow(12)[2]
fem.colors[fem.colors=="TXCB"]<-rainbow(12)[3]
fem.colors[fem.colors=="ALST"]<-rainbow(12)[4]
fem.colors[fem.colors=="FLSG"]<-rainbow(12)[5]
fem.colors[fem.colors=="FLKB"]<-rainbow(12)[6]
fem.colors[fem.colors=="FLFD"]<-rainbow(12)[7]
fem.colors[fem.colors=="FLSI"]<-rainbow(12)[8]
fem.colors[fem.colors=="FLAB"]<-rainbow(12)[9]
fem.colors[fem.colors=="FLPB"]<-rainbow(12)[10]
fem.colors[fem.colors=="FLHB"]<-rainbow(12)[11]
fem.colors[fem.colors=="FLCC"]<-rainbow(12)[12]

mal.pop<-mal.pheno$PopID
mal.colors<-as.character(mal.pop)
mal.colors[mal.colors=="TXSP"]<-rainbow(12)[1]
mal.colors[mal.colors=="TXCC"]<-rainbow(12)[2]
mal.colors[mal.colors=="TXCB"]<-rainbow(12)[3]
mal.colors[mal.colors=="ALST"]<-rainbow(12)[4]
mal.colors[mal.colors=="FLSG"]<-rainbow(12)[5]
mal.colors[mal.colors=="FLKB"]<-rainbow(12)[6]
mal.colors[mal.colors=="FLFD"]<-rainbow(12)[7]
mal.colors[mal.colors=="FLSI"]<-rainbow(12)[8]
mal.colors[mal.colors=="FLAB"]<-rainbow(12)[9]
mal.colors[mal.colors=="FLPB"]<-rainbow(12)[10]
mal.colors[mal.colors=="FLHB"]<-rainbow(12)[11]
mal.colors[mal.colors=="FLCC"]<-rainbow(12)[12]

png("PhenotypePCA.png",height=4,width=10,units="in",res=300)
pdf("PhenotypePCA.pdf",height=4,width=10)
par(mfrow=c(1,3),oma=c(2,2,2,2),mar=c(2,2,2,2),lwd=1.3)
plot(mal.pheno.pca,type="n",xlim=c(-3,3),ylim=c(-8.2,4)
	,xlab="",ylab="",las=1,cex.axis=1.5)
points(mal.pheno.pca,col=alpha(mal.colors,0.5),cex=1.5,pch=19)
mtext("PC1 (95.75%)",1,line=2)
mtext("PC2 (3.77%)",2,line=2.5)
legend("top",bty='n',c("Male Body Traits"),cex=1.5)

plot(fem.pheno.pca,type="n",xlab="",ylab="",las=1,cex.axis=1.5,ylim=c(-4,12),
	xlim=c(-3,3))
points(fem.pheno.pca,col=alpha(fem.colors,0.5),cex=1.5,pch=19)
mtext("PC1 (91.39%)",1,line=2)
mtext("PC2 (7.54%)",2,line=2.5)
legend("top",bty='n',c("Female Body Traits"),cex=1.5)

plot(band.pca,type="n",xlab="",ylab="",las=1,cex.axis=1.5,xlim=c(-2,2))
points(band.pca,pch=19,col=alpha(fem.colors,0.5),cex=1.5)
mtext("PC1 (98.23%)",1,line=2)
mtext("PC2 (1.77%)",2,line=2.5)
legend("top",bty='n',c("Female Band Traits"),cex=1.5)

par(fig = c(0, 1, 0, 1), oma=c(2,1,0,1), mar = c(0, 0, 0, 0), new = TRUE,
	cex=1)
plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
legend("top", pop.list, pch=19, pt.cex=1,bty='n',
	col=alpha(rainbow(12), 0.5), ncol=12)
dev.off()

#extract eigenvalue
band.eig<-band.pca$CA$eig

#extract PC scores
band.u<-data.frame(bands.pcdat[,1:2],"BandPC1"=band.pca$CA$u[,1],stringsAsFactors=F)
band.u.sep<-split(band.u, band.u[,1])
band.u.new<-rbind(band.u.sep$TXSP,band.u.sep$TXCC,band.u.sep$TXCB,
	band.u.sep$ALST,band.u.sep$FLSG,band.u.sep$FLKB,
	band.u.sep$FLFD,band.u.sep$FLSI,band.u.sep$FLAB,
	band.u.sep$FLPB,band.u.sep$FLHB,band.u.sep$FLCC)

fem.pheno.eig<-fem.pheno.pca$CA$eig

#extract PC scores
fem.pheno.u<-data.frame(fem.pheno[,1:2],
	"FemBodyPC1"=fem.pheno.pca$CA$u[,1],stringsAsFactors=F)
fem.u.sep<-split(fem.pheno.u, fem.pheno.u[,1])
fem.u.new<-rbind(fem.u.sep$TXSP,fem.u.sep$TXCC,fem.u.sep$TXCB,
	fem.u.sep$ALST,fem.u.sep$FLSG,fem.u.sep$FLKB,
	fem.u.sep$FLFD,fem.u.sep$FLSI,fem.u.sep$FLAB,
	fem.u.sep$FLPB,fem.u.sep$FLHB,fem.u.sep$FLCC)

mal.pheno.eig<-mal.pheno.pca$CA$eig

#extract PC scores
mal.u<-data.frame(mal.pheno[,1:2],"MalBodyPC1"=mal.pheno.pca$CA$u[,1],
	stringsAsFactors=F)
mal.u.sep<-split(mal.u, mal.u[,1])
mal.u.new<-rbind(mal.u.sep$TXSP,mal.u.sep$TXCC,mal.u.sep$TXCB,
	mal.u.sep$ALST,mal.u.sep$FLSG,mal.u.sep$FLKB,
	mal.u.sep$FLFD,mal.u.sep$FLSI,mal.u.sep$FLAB,
	mal.u.sep$FLPB,mal.u.sep$FLHB,mal.u.sep$FLCC)

band.pst<-pairwise.pst(band.u.new[,c(1,3)],pop.order)
fem.pst<-pairwise.pst(fem.u.new[,c(1,3)],pop.order)
mal.pst<-pairwise.pst(mal.u.new[,c(1,3)],pop.order)

mantel.rtest(as.dist(t(band.pst)),as.dist(t(dist)), nrepet=9999)
mantel.rtest(as.dist(t(fem.pst)),as.dist(t(dist)), nrepet=9999)
mantel.rtest(as.dist(t(mal.pst)),as.dist(t(dist)), nrepet=9999)


mantel.rtest(as.dist(t(band.pst)),as.dist(t(pwise.fst.sub)), nrepet=9999)
mantel.rtest(as.dist(t(fem.pst)),as.dist(t(pwise.fst.sub)), nrepet=9999)
mantel.rtest(as.dist(t(mal.pst)),as.dist(t(pwise.fst.sub)), nrepet=9999)

env.dat<-read.table("bayenv2//env_data_bayenv_raw.txt")
env.u<-rda(t(env.dat))$CA$u
env.u.new<-env.u[match(pop.order,rownames(env.u)),1]
env.dist<-dist(env.u.new)

###************************************PLOT********************************###
jpeg("Fig5.pst.fst.dist.jpeg",height=7,width=7, units="in", res=300)
pdf("pst.fst.dist.pdf",height=7,width=7)
par(las=1, oma=c(1,1,2.5,1), mar=c(3,3,1,3))
plot(dist[upper.tri(dist)], pwise.fst.sub[upper.tri(pwise.fst.sub)], pch=19,
	ylim=c(0,1),xlab="",ylab="")
points(dist[upper.tri(dist)],band.pst[upper.tri(band.pst)], pch=6,col="darkgreen")
points(dist[upper.tri(dist)],fem.pst[upper.tri(fem.pst)],pch=4,col="red")
points(dist[upper.tri(dist)],mal.pst[upper.tri(mal.pst)],pch=5,col="blue")
#points(dist[upper.tri(dist)],env.dist[lower.tri(env.dist)],pch=15,col="purple")
axis(4)
mtext("Distance (miles)",1, outer=T, line=-0.5)
mtext(expression(Smoothed~Pairwise~italic(F)[ST]),2, las=0, outer=T, line=-0.5)
mtext(expression(Pairwise~italic(P)[ST]),4, outer=T, las=0,line=-0.5)
par(fig = c(0, 1, 0, 1), oma=c(2,1,0,1), mar = c(0, 0, 0, 0), new = TRUE,
	cex=1)
plot(0, 0, type = "n", bty = "n", xaxt = "n", yaxt = "n")
legend("top", ncol=2, col=c("black","blue","red","darkgreen"),pch=c(19,5,4,6),
	c(expression(italic(F)[ST]),expression(Male~PCA~italic(P)[ST]), 
		expression(Female~PCA~italic(P)[ST]), 
		expression(Female~Bands~PCA~italic(P)[ST])),bty="n")

dev.off()


##############################################################################
#****************************************************************************#
#################################T-TESTS####################################
#****************************************************************************#
##############################################################################
fem.pheno$PopType[fem.pheno$PopID %in% fw.list]<-"FW"
fem.pheno$PopType[fem.pheno$PopID %in% sw.list]<-"SW"
mal.pheno$PopType[mal.pheno$PopID %in% fw.list]<-"FW"
mal.pheno$PopType[mal.pheno$PopID %in% sw.list]<-"SW"

t.test(mal.pheno$SVL ~ mal.pheno$PopType)
boxplot(fem.pheno$SVL ~ fem.pheno$PopType)
t.test(fem.pheno$TailLength ~ fem.pheno$PopType)
