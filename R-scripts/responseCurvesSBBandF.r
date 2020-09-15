plot_annualindic <- function(sces=sces,
                        explicit_pops= explicit_pops,
                        indic="F"){



    # look at annual indics such as the TACs...
    res <- NULL
    for(sce in sces) {
       print(paste("sce ", sce))
       lst <- get(paste("lst_annualindic_", sce, sep = ''), env = .GlobalEnv)
       for(simu in 1: length(lst)) {
          print(paste("sim ", simu))
          # merge all infos
          annual_indics <- lst[[simu]] 
          colnames(annual_indics)    <-  c("tstep", "stk", "multi", "multi2", "Fbar", "totland_kg", "totdisc_kg", "SSB_kg", "tac", paste0("N",0:10), paste0("F",0:10), paste0("W",0:10), paste0("M",0:10))

          annual_indics <- annual_indics [, 1:9]   # FOR NOW...
          res <- rbind (res, cbind(annual_indics, sce=sce, simu=paste(simu, sep="_")))
       }
    }
    
  
  
   outcome_firsty <- res[res$tstep==8761,]  
   outcome_lasty <- res[res$tstep==35065,]  
   outcome <- merge(outcome_firsty, outcome_lasty, by.x=c('stk', 'sce', 'simu'), by.y=c('stk', 'sce', 'simu'))
   outcome$"F/Finit" <- outcome$Fbar.y/outcome$Fbar.x
   outcome$"SSB/SSBinit" <- outcome$SSB_kg.y/outcome$SSB_kg.x
   outcome$"TLand/TLandinit" <- outcome$totland_kg.y/outcome$totland_kg.x
   outcome$"TDisc/TDiscinit" <- outcome$totdisc_kg.y/outcome$totdisc_kg.x
   outcome$"Tac/Tacinit" <- outcome$tac.y/outcome$tac.x
   
   

   outcome$sce <- factor(outcome$sce)
   outcome$sce <- factor(outcome$sce, levels=sces, labels=  sces)


   # put in long format
   df1 <- cbind.data.frame(outcome[,c('stk','sce','simu','F/Finit')], indicator="F/Finit")
   df2 <- cbind.data.frame(outcome[,c('stk','sce','simu','SSB/SSBinit')] , indicator="SSB/SSBinit")
   df3 <- cbind.data.frame(outcome[,c('stk','sce','simu','TLand/TLandinit')] , indicator="TLand/TLandinit")
   df4 <- cbind.data.frame(outcome[,c('stk','sce','simu','TDisc/TDiscinit')] , indicator="TDisc/TDiscinit")
   df5 <- cbind.data.frame(outcome[,c('stk','sce','simu','Tac/Tacinit')] , indicator="Tac/Tacinit")
   colnames(df1) <- colnames(df2) <- colnames(df3) <- colnames(df4) <- colnames(df5) <- c('stk','sce','simu','value','indicator')
   out <- rbind.data.frame(df1,df2, df3, df4, df5)
   


 # SSB, F and whatever  
 library(ggplot2)
   pops <- gsub("pop.","", explicit_pops)
   p <- ggplot(out[out$stk==pops & (out$indicator %in% indic),], aes(x=sce, y=value))  + geom_boxplot(position="dodge", aes(fill=indicator, outlier.shape="*"))  +
             labs(x = "Scenario", y = "Value")  + facet_wrap( ~ stk+indicator, ncol=2, scales="fixed")  #   + ylim(0, 1)
 print(
       p   + 
       theme_bw()+
        theme(axis.text.x = element_text(angle = 45, hjust = 1), strip.text.x =element_text(size =10),  panel.grid.major = element_line(colour = grey(0.4),linetype =3 ),
        strip.background = element_blank(),
        panel.border = element_rect(colour = "black")) +
        geom_abline(intercept=0, slope=0, color="grey", lty=2)  + geom_boxplot(outlier.shape=NA)
       )

 

# if necessary to add a second y-axis, play with the below:

# adding the relative humidity data, transformed to match roughly the range of the temperature
#  p <- p + geom_line(aes(y = rel_hum/5, colour = "Humidity"))
  
#  # now adding the secondary axis, following the example in the help file ?scale_y_continuous
#  # and, very important, reverting the above transformation
#  p <- p + scale_y_continuous(sec.axis = sec_axis(~.*5, name = "Relative humidity [%]"))

 
 
 
return()
} 
 
 

 