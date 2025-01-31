setwd("~/Projects/popgen/fwsw_results/")
#setwd("~/sf_ubuntushare/popgen/fwsw_results/")
library(fields)
library(MASS)

initial_runs<-FALSE
subset<-FALSE
recomb_runs<-FALSE
selection<-FALSE
two_nes<-FALSE


## ---- runDMC
run.dmc<-function(F_estimate,out_name,positions, sampleSizes,selSite=NA,nselsites=50,rec =2.17*10^-8,
                  Ne = 8.3*10^6,selPops = c(3,5,7,16),numBins = 1000,numPops = 16,
                  sels = c(1e-4, 1e-3, 0.01, seq(0.02, 0.14, by = 0.01), seq(0.15, 0.3, by = 0.05), 
                           seq(0.4, 0.6, by = 0.1)),
                  times = c(0, 5, 25, 50, 100, 500, 1000, 1e4, 1e6),
                  migs = c(10^-(seq(5, 1, by = -2)), 0.5, 1),mod4_sets=list(c(3,5,7),16),
                  mod1=TRUE,mod2=TRUE,mod3=TRUE,mod4=TRUE,mod5=TRUE,complike=TRUE,
                  neutral_det_name="dmc/det_FOmegas_neutral_p4LG4.RDS",
                  neutral_inv_name="dmc/inv_FOmegas_neutral_p4LG4.RDS"){
  #make all the parameters global
  F_estimate<<-F_estimate
  positions<<-positions
  sampleSizes<<-sampleSizes
  Ne<<-Ne
  rec<<-rec
  selPops<<-selPops
  numBins<<-numBins
  numPops<<-numPops
  sels<<-sels
  times<<-times
  migs<<-migs
  neutral_det_name<<-neutral_det_name
  neutral_inv_name<<-neutral_inv_name
  print(paste(neutral_det_name,neutral_inv_name,sep=","))
  #set up parameters
  M <<- numPops
  Tmatrix <<- matrix(data = rep(-1 / M, (M - 1) * M), nrow = M - 1, ncol = M)
  diag(Tmatrix) = (M - 1) / M 
  gs<<-c(1/(2*Ne), 10^-(4:1))
  sampleErrorMatrix <<- diag(1/sampleSizes, nrow = numPops, ncol = numPops)
  if(is.na(selSite[1])) selSite=seq(min(positions), max(positions), length.out = nselsites)
  selSite<<-selSite
  sources <<- selPops
  sets<<-mod4_sets
  #save params
  params<-list(F_estimate,out_name,positions, sampleSizes,selSite,rec,
               Ne,selPops,numBins,numPops,sels,times,gs,migs,mod4_sets)
  names(params)<-c("F_estimate","out_name","positions", "sampleSizes","selSite","rec",
                   "Ne","selPops","numBins","numPops","sels","times","gs","migs","mod4_sets")
  print(params)
  ############### calculate F(S) ###############
  source("../programs/dmc-master/genSelMatrices_individualModes.R")
  
  ############### model 1 ###############
  if(mod1==TRUE){
    FOmegas_ind = lapply(sels, function(sel) {
      calcFOmegas_indSweeps(sel)
    })
    
    saveRDS(FOmegas_ind, paste("dmc/FOmegas_ind_",out_name,".RDS",sep=""))
    #model 1 determinant
    det_FOmegas_ind = lapply(FOmegas_ind, function(sel) {
      lapply(sel, function(dist) {
        det(dist)
      })
    })
    saveRDS(det_FOmegas_ind, paste("dmc/det_FOmegas_ind_",out_name,".RDS",sep=""))
    #model 1 inverse
    inv_FOmegas_ind = lapply(FOmegas_ind, function(sel) {
      lapply(sel, function(dist) {
        ginv(dist)
      })
    })
    saveRDS(inv_FOmegas_ind, paste("dmc/inv_FOmegas_ind_",out_name,".RDS",sep=""))
  }
  ############### model 2 ###############
  if(mod2==TRUE){
    FOmegas_mig = lapply(sels ,function(sel) {
      lapply(migs, function(mig) {
        lapply(sources, function(my.source) {
          calcFOmegas_mig(sel, mig, my.source)
        })
      })
    })
    
    saveRDS(FOmegas_mig, paste("dmc/FOmegas_mig_",out_name,".RDS",sep=""))
    #determinant
    det_FOmegas_mig = lapply(FOmegas_mig, function(sel) {
      lapply(sel, function(mig) {
        lapply(mig, function(source) {
          lapply(source, function(dist) {
            det(dist)
          })
        })
      })
    })
    saveRDS(det_FOmegas_mig, paste("dmc/det_FOmegas_mig_",out_name,".RDS",sep=""))
    #inverse
    inv_FOmegas_mig = lapply(FOmegas_mig, function(sel) {
      lapply(sel, function(mig) {
        lapply(mig, function(source) {
          lapply(source, function(dist) {
            ginv(dist)
          })
        })
      })
    })
    saveRDS(inv_FOmegas_mig, paste("dmc/inv_FOmegas_mig_",out_name,".RDS",sep=""))
  }
  ############### model 3 ###############
  if(mod3==TRUE)
  {
    FOmegas_sv = lapply(sels, function(sel) {
      lapply(gs, function(g) {
        lapply(times, function(time) {
          lapply(sources, function(my.source) {
            calcFOmegas_stdVar.source(sel, g, time, my.source)
          })
        })
      })
    })
    
    saveRDS(FOmegas_sv, paste("dmc/FOmegas_sv_",out_name,".RDS",sep=""))
    #determinant
    det_FOmegas_sv = lapply(FOmegas_sv, function(sel) {
      lapply(sel, function(g) {
        lapply(g, function(time) {
          lapply(time, function(my.source) {
            lapply(my.source, function(dist) {
              det(dist)
            })
          })
        })
      })
    })
    saveRDS(det_FOmegas_sv, paste("dmc/det_FOmegas_sv_",out_name,".RDS",sep=""))
    #inverse
    inv_FOmegas_sv = lapply(FOmegas_sv, function(sel) {
      lapply(sel, function(g) {
        lapply(g, function(time) {
          lapply(time, function(my.source) {
            lapply(my.source, function(dist) {
              ginv(dist)
            })
          })
        })
      })
    })
    saveRDS(inv_FOmegas_sv, paste("dmc/inv_FOmegas_sv_",out_name,".RDS",sep=""))
  }
  ############### model 4 ###############
  if(mod4==TRUE){
    
    source("../programs/dmc-master/genSelMatrices_multipleModes.R")
    
    my.modes_migInd=c("mig","ind")
    
    #the parameters time and g are not involved in the migration model so we only loop over
    ## the first element of these vectors
    FOmegas_mixed_migInd = lapply(sels ,function(sel) {
      lapply(gs[1], function(g) {
        lapply(times[1], function(time) {
          lapply(migs, function(mig) {
            lapply(sources, function(my.source) {
              calcFOmegas_mixed(sel, g, time, mig, my.source, my.modes_migInd)
            })
          })
        })
      })
    })
    
    saveRDS(FOmegas_mixed_migInd, paste("dmc/FOmegas_mixed_migInd_",out_name,".RDS",sep=""))
    
    detFOmegas_mixed_migInd = lapply(FOmegas_mixed_migInd, function(sel) {
      lapply(sel, function(g) {
        lapply(g, function(time) {
          lapply(time, function(mig) {
            lapply(mig, function(source) {
              lapply(source, function(dist) {
                det(dist)
              })
            })  
          })
        })
      })
    })
    saveRDS(detFOmegas_mixed_migInd, paste("dmc/det_FOmegas_mixed_migInd_",out_name,".RDS",sep=""))
    
    invFOmegas_mixed_migInd = lapply(FOmegas_mixed_migInd, function(sel) {
      lapply(sel, function(g) {
        lapply(g, function(time) {
          lapply(time, function(mig) {
            lapply(mig, function(source) {
              lapply(source, function(dist) {
                ginv(dist)
              })
            })  
          })
        })
      })
    })
    saveRDS(invFOmegas_mixed_migInd, paste("dmc/inv_FOmegas_mixed_migInd_",out_name,".RDS",sep=""))
  }
  ############### model 5 ###############
  if(mod5==TRUE){
    my.modes_svInd = c("sv", "ind")
    
    #the parameter mig is not involved in the standing variant model so we only loop over
    ## the first element of this vector
    FOmegas_mixed_svInd = lapply(sels ,function(sel) {
      lapply(gs, function(g) {
        lapply(times, function(time) {
          lapply(migs[1], function(mig) {
            lapply(sources, function(my.source) {
              calcFOmegas_mixed(sel, g, time, mig, my.source, my.modes_svInd)
            })
          })
        })
      })
    })
    
    saveRDS(FOmegas_mixed_svInd, paste("dmc/FOmegas_mixed_svInd_",out_name,".RDS",sep=""))
    
    detFOmegas_mixed_svInd = lapply(FOmegas_mixed_svInd, function(sel) {
      lapply(sel, function(g) {
        lapply(g, function(time) {
          lapply(time, function(mig) {
            lapply(mig, function(source) {
              lapply(source, function(dist) {
                det(dist)
              })
            })  
          })
        })
      })
    })
    saveRDS(detFOmegas_mixed_svInd, paste("dmc/det_FOmegas_mixed_svInd_",out_name,".RDS",sep=""))
    
    invFOmegas_mixed_svInd = lapply(FOmegas_mixed_svInd, function(sel) {
      lapply(sel, function(g) {
        lapply(g, function(time) {
          lapply(time, function(mig) {
            lapply(mig, function(source) {
              lapply(source, function(dist) {
                ginv(dist)
              })
            })  
          })
        })
      })
    })
    saveRDS(invFOmegas_mixed_svInd, paste("dmc/inv_FOmegas_mixed_svInd_",out_name,".RDS",sep=""))
  }
  ############### calculate composite likelihoods ###############
  if(complike==TRUE){
    #randomize allele freqs
    freqs_notRand = readRDS("dmc/selectedRegionAlleleFreqs_p4LG4.RDS")
    randFreqs = apply(freqs_notRand, 2, function(my.freqs) {
      if(runif(1) < 0.5) {
        my.freqs = 1 - my.freqs
      }
      my.freqs
    })
    saveRDS(randFreqs, paste("dmc/selectedRegionAlleleFreqsRand_",out_name,".RDS",sep=""))
    freqs<<-randFreqs
    
    #calc the likelihoods
    source("../programs/dmc-master/calcCompositeLike.R")
    
    ## Neutral model
    
    det_FOmegas_neutral = readRDS(neutral_det_name)
    inv_FOmegas_neutral = readRDS(neutral_inv_name)
    compLikelihood_neutral = lapply(1 : length(selSite), function(j) {
      calcCompLikelihood_neutral(j, det_FOmegas_neutral, inv_FOmegas_neutral)
    })
    saveRDS(compLikelihood_neutral, paste("dmc/compLikelihood_neutral_",out_name,".RDS",sep=""))
    
    ## Model 1
    det_FOmegas_ind = readRDS(paste("dmc/det_FOmegas_ind_",out_name,".RDS",sep=""))
    inv_FOmegas_ind = readRDS(paste("dmc/inv_FOmegas_ind_",out_name,".RDS",sep=""))
    compLikelihood_ind = lapply(1 : length(selSite), function(j) {
      lapply(1 : length(sels), function(sel) calcCompLikelihood_1par(j, det_FOmegas_ind,
                                                                     inv_FOmegas_ind, sel))
    })
    saveRDS(compLikelihood_ind, paste("dmc/compLikelihood_ind_",out_name,".RDS",sep=""))
    
    ## Model 2
    det_FOmegas_mig = readRDS(paste("dmc/det_FOmegas_mig_",out_name,".RDS",sep=""))
    inv_FOmegas_mig = readRDS(paste("dmc/inv_FOmegas_mig_",out_name,".RDS",sep=""))
    compLikelihood_mig = lapply(1 : length(selSite), function(j) {
      lapply(1 : length(sels), function(sel) {
        lapply(1 : length(migs), function(mig) {
          lapply(1 : length(sources), function(my.source) {
            calcCompLikelihood_3par(j, det_FOmegas_mig, inv_FOmegas_mig, sel, mig,
                                    my.source)
          })
        })
      })
    })
    saveRDS(compLikelihood_mig, paste("dmc/compLikelihood_mig_",out_name,".RDS",sep=""))
    
    ## Model 3
    det_FOmegas_sv = readRDS(paste("dmc/det_FOmegas_sv_",out_name,".RDS",sep=""))
    inv_FOmegas_sv = readRDS(paste("dmc/inv_FOmegas_sv_",out_name,".RDS",sep=""))
    compLikelihood_sv = lapply(1 : length(selSite), function(j) {
      lapply(1 : length(sels), function(sel) {
        lapply(1 : length(gs), function(g) {
          lapply(1 : length(times), function(t) {
            lapply(1: length(sources), function(my.source) {
              calcCompLikelihood_4par(j, det_FOmegas_sv, inv_FOmegas_sv, sel, g, t,
                                      my.source)
            })
          })
        })
      })
    })
    saveRDS(compLikelihood_sv, paste("dmc/compLikelihood_sv_",out_name,".RDS",sep=""))
    
    ## Model 4
    det_FOmegas_mixed_migInd = readRDS(paste("dmc/det_FOmegas_mixed_migInd_",out_name,".RDS",sep=""))
    inv_FOmegas_mixed_migInd = readRDS(paste("dmc/inv_FOmegas_mixed_migInd_",out_name,".RDS",sep=""))
    
    # same trick as above (the parameters time and g are not involved in the migration
    ## model so we only loop over the first element of these vectors)
    # now save lists for each proposed selected site (may want to do this for other 
    ## models/more elegantly depending on density of parameter space)
    for(j in 1 : length(selSite)) {
      compLikelihood_mixed_migInd = lapply(1 : length(sels), function(sel) {
        lapply(1 : length(gs[1]), function(g) {
          lapply(1 : length(times[1]), function(t) {
            lapply(1 : length(migs), function (mig) {
              lapply(1: length(sources), function(my.source) {
                calcCompLikelihood_5par(j, det_FOmegas_mixed_migInd,
                                        inv_FOmegas_mixed_migInd, sel, g, t, mig,
                                        my.source)
              })
            })
          })
        })
      })
      saveRDS(compLikelihood_mixed_migInd,
              paste("dmc/compLikelihood_mixed_migInd_",out_name,"_selSite", j, ".RDS",
                    sep = ""))
    }
    
    ## Model 5
    det_FOmegas_mixed_svInd = readRDS(paste("dmc/det_FOmegas_mixed_svInd_",out_name,".RDS",sep=""))
    inv_FOmegas_mixed_svInd = readRDS(paste("dmc/inv_FOmegas_mixed_svInd_",out_name,".RDS",sep=""))
    
    #same trick as above (the parameter mig is not involved in the migration model so we
    ##only loop over the first element of this vector)
    # now save lists for each proposed selected site (may want to do this for other
    ## models/more elegantly depending on density of parameter space)
    for(j in 1 : length(selSite)) {
      compLikelihood_mixed_svInd = lapply(1 : length(sels), function(sel) {
        lapply(1 : length(gs), function(g) {
          lapply(1 : length(times), function(t) {
            lapply(1 : length(migs[1]), function (mig) {
              lapply(1: length(sources), function(my.source) {
                calcCompLikelihood_5par(j, det_FOmegas_mixed_svInd,
                                        inv_FOmegas_mixed_svInd, sel, g, t, mig,
                                        my.source)
              })
            })
          })
        })
      })
      saveRDS(compLikelihood_mixed_svInd,
              paste("dmc/compLikelihood_mixed_svInd_",out_name,"_selSite", j, ".RDS",
                    sep = ""))
    }
    
    #combine models 4 and 5 output
    
    ## Model 4
    compLikelihood_mixed_migInd_all = lapply(1: length(selSite), function(i) {
      readRDS(paste("dmc/compLikelihood_mixed_migInd_",out_name,"_selSite", i, ".RDS",
                    sep = ""))
    })
    
    saveRDS(compLikelihood_mixed_migInd_all, paste("dmc/compLikelihood_mixed_migInd_",out_name,".RDS",sep=""))
    
    ## Model 5
    compLikelihood_mixed_svInd_all = lapply(1: length(selSite), function(i) {
      readRDS(paste("dmc/compLikelihood_mixed_svInd_",out_name,"_selSite", i, ".RDS",
                    sep = ""))
    })
    
    saveRDS(compLikelihood_mixed_svInd_all, paste("dmc/compLikelihood_mixed_svInd_",out_name,".RDS",sep=""))
  }
  return(params)
}              
## ---- end-runDMC

## ---- setParameters
############### Set parameters ###############
positions<-readRDS("dmc/selectedRegionPositions_p4LG4.RDS")
F_estimate<-readRDS("dmc/neutralF_p4LG4_50.RDS")
sampleSizes<-readRDS("dmc/sampleSizes.RDS")

numPops = 16
numPops <- 16
selPops <- c(3,5,7,16)
numBins <- 1000

selSite = positions[seq(1, length(positions), length.out = 50)]
sels = c(1e-4, 1e-3, 0.01, seq(0.02, 0.14, by = 0.01), seq(0.15, 0.3, by = 0.05), 
         seq(0.4, 0.6, by = 0.1))
times = c(0, 5, 25, 50, 100, 500, 1000, 1e4, 1e6)
migs = c(10^-(seq(5, 1, by = -2)), 0.5, 1)
mod4_sets=list(c(3,5,7),16)
## ---- end-setParameters

if(initial_runs==TRUE){
## ---- dmcNe
############### Run the program ###############
Nes <- c(8.3*10^3,8.3*10^4,8.3*10^5,8.3*10^6)
rs<-c(2.17*10^-8,2*10^-7,6*10^-6,5.6*10^-6)

dmc.out<-lapply(rs,function(r){
  rec<-r
  rname<-gsub("(\\d).*(\\d)$","\\1_\\2",as.character(r))
  lapply(Nes, function(ne){
    out_name<-paste("p4LG4_",ne,"_",rname,sep="")
    dir<-getwd()
    print(paste("running",out_name,"in",dir,sep=" "))
    p<-run.dmc(F_estimate = F_estimate,out_name = out_name,positions = positions,sampleSizes = sampleSizes,
               selSite=selSite,rec =rec,
               Ne = ne,selPops = selPops,numBins = numBins,numPops = numPops,
               sels = sels, times = times,
               migs = migs,mod4_sets=mod4_sets,
               neutral_det_name="dmc/det_FOmegas_neutral_p4LG4_50.RDS", 
               neutral_inv_name = "dmc/inv_FOmegas_neutral_p4LG4_50.RDS")
    return(p)
  })
})
print("Done running dmc")
## ---- end-dmcNe
} else
{
  if(subset==TRUE){
    ## ---- dmcSubset
    positions<-readRDS("dmc/selectedRegionPositions_p4LG4_subset.RDS")
    F_estimate<-readRDS("dmc/neutralF_p4LG4_subset.RDS")
    sampleSizes<-readRDS("dmc/sampleSizes.RDS")
    selSite = positions[seq(1, length(positions[positions<12000000]), length.out = 100)]
    p<-run.dmc(F_estimate = F_estimate,out_name = "p4LG4_100000_2_8_sub",positions = positions,sampleSizes = sampleSizes,
               selSite=selSite,rec =2*10^-8,Ne = 100000,
               selPops = selPops,numBins = numBins,numPops = numPops,
               sels = sels, times = times,
               migs = migs,mod4_sets=mod4_sets,
               neutral_det_name="dmc/det_FOmegas_neutral_p4LG4_subset.RDS", 
               neutral_inv_name = "dmc/inv_FOmegas_neutral_p4LG4_subset.RDS",
               mod1=FALSE,mod2=FALSE,mod3=FALSE,mod4=FALSE,mod5=FALSE)
    ## ---- end-dmcSubset
  }else if(two_nes==TRUE){
    ## ---- dmcTwoNes
    selSite = positions[seq(1, length(positions[positions<12000000]), length.out = 100)]
    F_estimate<-readRDS("dmc/neutralF_p4LG4_100.RDS")
    p<-run.dmc(F_estimate = F_estimate,out_name = "p4LG4_100000_2_8",positions = positions,sampleSizes = sampleSizes,
               selSite=selSite,rec =2*10^-8,Ne = 100000,
               selPops = selPops,numBins = numBins,numPops = numPops,
               sels = sels, times = times,
               migs = migs,mod4_sets=mod4_sets,
               neutral_det_name="dmc/det_FOmegas_neutral_p4LG4_100.RDS", 
               neutral_inv_name = "dmc/inv_FOmegas_neutral_p4LG4_100.RDS")
    p<-run.dmc(F_estimate = F_estimate,out_name = "p4LG4_1000000_2_8",positions = positions,sampleSizes = sampleSizes,
               selSite=selSite,rec =2*10^-8,Ne = 1000000,
               selPops = selPops,numBins = numBins,numPops = numPops,
               sels = sels, times = times,
               migs = migs,mod4_sets=mod4_sets,
               neutral_det_name="dmc/det_FOmegas_neutral_p4LG4_100.RDS", 
               neutral_inv_name = "dmc/inv_FOmegas_neutral_p4LG4_100.RDS")
    ## ---- end-dmcTwoNes
  }else if(recomb_runs==TRUE){
    ## ---- dmcRecomb
    selSite = positions[seq(1, length(positions), length.out = 100)]
    p<-run.dmc(F_estimate = F_estimate,out_name = "p4LG4_100000_2_9",positions = positions,sampleSizes = sampleSizes,
               selSite=selSite,rec =2*10^-9,Ne = 100000,
               selPops = selPops,numBins = numBins,numPops = numPops,
               sels = sels, times = times,
               migs = migs,mod4_sets=mod4_sets,
               neutral_det_name="dmc/det_FOmegas_neutral_p4LG4_50.RDS", 
               neutral_inv_name = "dmc/inv_FOmegas_neutral_p4LG4_50.RDS")
    p<-run.dmc(F_estimate = F_estimate,out_name = "p4LG4_100000_2_10",positions = positions,sampleSizes = sampleSizes,
               selSite=selSite,rec =2*10^-10,Ne = 100000,
               selPops = selPops,numBins = numBins,numPops = numPops,
               sels = sels, times = times,
               migs = migs,mod4_sets=mod4_sets,
               neutral_det_name="dmc/det_FOmegas_neutral_p4LG4_50.RDS", 
               neutral_inv_name = "dmc/inv_FOmegas_neutral_p4LG4_50.RDS")
    ## ---- end-dmcRecomb
  }else if(selection==TRUE){
    ## ---- dmcSelection
    sels = c(9e-4,7.5e-4,5e-4, 2.5e-4,1e-4)
    p<-run.dmc(F_estimate = F_estimate,out_name = "p4LG4_100000_2_9_sels",
               positions = positions,sampleSizes = sampleSizes,
               selSite=selSite,rec =2*10^-9,Ne = 100000,
               selPops = selPops,numBins = numBins,numPops = numPops,
               sels = sels, times = times,
               migs = migs,mod4_sets=mod4_sets,
               neutral_det_name="dmc/det_FOmegas_neutral_p4LG4_50.RDS", 
               neutral_inv_name = "dmc/inv_FOmegas_neutral_p4LG4_50.RDS")
    ## ---- end-dmcSelection
  } else{
  ## ---- dmcForReal
    selSite = positions[seq(1, length(positions[positions<10000000]), length.out = 100)]
    allFreqs<-readRDS("dmc/neutralAlleleFreqs_p4LG4.RDS")
    #calculate the neutral F matrix
    sampleSizes<-readRDS("dmc/sampleSizes.RDS")
    neutralF_filename<-"dmc/neutralF_p4LG4_100_10MB" #for 50 positions
    source("../programs/dmc-master/calcNeutralF.R")
    F_estimate<-readRDS("dmc/neutralF_p4LG4_100_10MB.RDS")
    
    #calculate the determinant and inverse of the neutral F matrix
    M <- numPops
    Tmatrix <- matrix(data = rep(-1 / M, (M - 1) * M), nrow = M - 1, ncol = M)
    diag(Tmatrix) = (M - 1) / M 
    sampleErrorMatrix = diag(1/sampleSizes, nrow = numPops, ncol = numPops)
    det_FOmegas_neutral = det(Tmatrix %*% (F_estimate + sampleErrorMatrix) %*% t(Tmatrix))
    saveRDS(det_FOmegas_neutral, "dmc/det_FOmegas_neutral_p4LG4_100_10MB.RDS")
    
    inv_FOmegas_neutral = ginv(Tmatrix %*% (F_estimate + sampleErrorMatrix) %*% t(Tmatrix))
    saveRDS(inv_FOmegas_neutral, "dmc/inv_FOmegas_neutral_p4LG4_100_10MB.RDS")
    sels = c(1e-4, 1e-3, 0.01, seq(0.02, 0.14, by = 0.01), seq(0.15, 0.3, by = 0.05), 
             seq(0.4, 0.6, by = 0.1))
    p<-run.dmc(F_estimate = F_estimate,out_name = "p4LG4_100000_2_9_forReal",
               positions = positions,sampleSizes = sampleSizes,
               selSite=selSite,rec =2*10^-9,Ne = 100000,
               selPops = selPops,numBins = numBins,numPops = numPops,
               sels = sels, times = times,
               migs = migs,mod4_sets=mod4_sets,
               neutral_det_name="dmc/det_FOmegas_neutral_p4LG4_100_10MB.RDS", 
               neutral_inv_name = "dmc/inv_FOmegas_neutral_p4LG4_100_10MB.RDS")

    print("Done running dmc")
  ## ---- end-dmcForReal
  }
}
