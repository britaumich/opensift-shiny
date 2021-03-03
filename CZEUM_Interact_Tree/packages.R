using<-function(...) {
    libs<-unlist(list(...))
    req<-unlist(lapply(libs,require,character.only=TRUE))
    need<-libs[req==FALSE]
    if(length(need)>0){ 
        install.packages(need, lib="/usr/local/lib/R/library")
        lapply(need,require,character.only=TRUE)
    }
}
using ("withr","fastmap","xtable","mime","magrittr","promises","later","Rcpp","httpuv","rlang","htmltools","R6","digest","jsonlite"
,"sourcetools","ape","crayon","dplyr","vctrs","generics","glue")
using ("lifecycle","tibble","ellipsis","pillar","pkgconfig","tidyselect","purrr","DT","htmlwidgets","gtable","ggplot2"
,"scales","munsell","colorspace")
using ("tidyr",
"tidytree",
"lazyeval",
"plotly",
"data.table",
"httr",
"viridisLite",
"phytools",
"maps",
"coda",
"combinat",
"clusterGeneration",
"expm",
"gtools",
"mnormt",
"tmvnsim",
"numDeriv",
"phangorn",
"fastmatch",
"igraph")
using ("quadprog",
"plotrix",
"scatterplot3d",
"RMariaDB",
"DBI",
"bit64",
"bit",
"hms",
"labeling",
"crosstalk",
"farver")

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("ggtree")

using ("shiny", "shinythemes")