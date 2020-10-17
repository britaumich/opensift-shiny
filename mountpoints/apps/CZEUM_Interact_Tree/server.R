#CZEUM Interactive Phylogeny
#Anne Bonds

#Load requigrey packages
library(ape)
library(dplyr)
library(DT)
library(ggplot2)
library(ggtree)
library(plotly)
library(phytools)
library(RMariaDB)
library(tidytree) 
library(tibble)
library(treeio)
#library(shiny)
#library(shinythemes)



# Define server logic requigrey to make tree
#server <- function(input, output) {
shinyServer(function(input, output) {  
  # Set working directory and read tree into the app
#setwd("C:/Users/abond/Desktop/CZEUM/Interact_Tree")
tree <- treeio::read.newick("RAxML_bipartitions_CZEUM.tre")

# Reroot tree on outgroup (Rozella)
tree1 <- root(tree, node=979)

#Make information table
if (file.exists('/etc/env.R')) { source('/etc/env.R') }
host1<-Sys.getenv("HOSTDB")
user1<-Sys.getenv("USERDB")
password1<-Sys.getenv("PASSWORDDB")
dbname1<-Sys.getenv("DBNAMEDB")
#user1<-"appdevch_invento"
#password1<-"N(_KgT1?)m[5"
#dbname1<-"appdevch_czeum"
#host1<-"whe02.lsa.umich.edu"

con <- dbConnect(RMariaDB::MariaDB(), 
                   host = host1,
                   user = user1, 
                   password = password1, 
                   dbname = dbname1)
  
  CZEUM_data <- dbSendQuery(con, "SELECT `id`, `Isolate_ID`, `Genus`, `species`, `Family`, `Order_1`, `Phylum`, `Medium`, `18S_rDNA`, `28S_rDNA`, `ITS_rDNA`, `Substrate_Host`, `CollectionDate`, `Collector`, `Country`, `State`, `City`, `Location`, `Type`, `image` FROM `czeum_data`
")
  
  data <- dbFetch(CZEUM_data)
  
  new_labels <- read.csv("new_labels.csv") 
  websites <-c(new_labels$Hyperlinks)
  Link <- paste0("<a href=\"",websites,"\" target=\"_blank\">", websites,"</a>")
  new_labels_links <- data.frame(new_labels, websites, Link)
  
  join <- left_join(new_labels_links, data, by = c("id" = "Isolate_ID")) 


  ranges <- reactiveValues(x = NULL, y = NULL)
  
  # Plot phylogenetic tree and apply new labels
  make_tree <- reactive({
    ggtree(tree1) %<+% join +
      geom_tiplab(aes(label=Isolate, color=Availability), size=input$text) + 
      scale_color_manual(values = c("blue", "red"), guide = FALSE) +
      theme(legend.position = "top") +
      
      #Families
      geom_strip('WJD117_Rhizophydium__O__', 'JEL0385_Rhizophydium__D__', label = "Terramycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('ARG013_Rhizophydium____', 'JEL0294_Rhizophydium_globosum_D__', label = "Rhizophydiaceae", offset = -.17, fontsize = input$text) +
      geom_strip('ARG031___D__', 'ARG027___D__', label = "Pateramycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('ARG069_Globomyces_pollinis_pini___', 'JEL0886___O__', label = "Globomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0223_Operculomyces_laminatus_O_T_', 'JEL0223_Operculomyces_laminatus_O_T_', label = "Operculomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('PL163L_Coralloidiomyces_digitatus__T_', 'PL163L_Coralloidiomyces_digitatus__T_', label = "Coralloidiomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0171_Uebelmesseromyces_harderi_D_T_', 'JEL0171_Uebelmesseromyces_harderi_D_T_', label = "Uebelmesseromycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('PL074_Kappamyces__D__', 'JA56___O__', label = "Kappamycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('UM1568___O__', 'JEL0952_Rhizophydium__O__', label = "Alphamycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('ARG033___D__', 'JEL0845___O__', label = "Angulomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0317_Aquamyces_chlorogonii_D__', 'ARG018_Aquamyces_chlorogonii_D_T_', label = "Aquamycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('ARG071_Protrudomyces_lateralis__T_', 'JEL0578_Rhizophydium__O__', label = "Protrudomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('WJD193_Paranamyces_uniporus_O__', 'PL157_Paranamyces_uniporus__T_', label = "Halomycetaceae I", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0957___O__', 'UM1559_Rhizophydium__O__', label = "Gorgonomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0197_Batrachochytrium_dendrobatidis__T_', 'JEL0405___O__', label = "Batrachochytriaceae", offset = -.17, fontsize = input$text) +
      geom_strip('Barr303_Ulkenomyces_aestuarii__T_', 'ATCC26191_Paludomyces_mangrovei_D_T_', label = "Halomycetaceae II", offset = -.17, fontsize = input$text) +
      geom_strip('ATCC22918_Rhizoclosmatium_globosum___', 'JEL0794_Rhopalophlyctis_sarcoptoides_D__', label = "Chytriomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0186_Asterophlyctis_michiganensis__T_', 'JEL0524_Wheelerophlyctis_interior_O__', label = "Asterophyctaceae", offset = -.17, fontsize = input$text) +
      geom_strip('ARG113_Delfinachytrium_mesopotamicum_D_T_', 'JEL0047_Phlyctochytrium_planicorne___', label = "Chytridiaceae", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0613_Geranomyces_variabilis_O__', 'JEL0741_Powellomyces__O__', label = "Powellomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0350_Brevicalcar_kilaueaense_O__', 'JEL0568_Kochiomyces_dichotomus___', label = "Spizellomycetaceae", offset = -.17, fontsize = input$text) +
      geom_strip('JEL0916_Quaeritorhiza_haematococci_O_T_', 'JEL0916_Quaeritorhiza_haematococci_O_T_', label = "Quaeritorhizaceae incertae sedis", offset = -.17, fontsize = input$text) +
      
      #Orders
      geom_strip('WJD117_Rhizophydium__O__', 'ATCC26191_Paludomyces_mangrovei_D_T_', label = "Rhizophydiales", offset = -.05, fontsize = input$text) +
      geom_strip('ATCC22918_Rhizoclosmatium_globosum___', 'JEL0047_Phlyctochytrium_planicorne___', label = "Chytridiales", offset = -.05, fontsize = input$text) +
      geom_strip('DUH9362_Synchytrium_decipiens_D__', 'DUH9363_Synchytrium_macrosporum_D__', label = "Synchytriales", offset = -.05, fontsize = input$text) +
      geom_strip('CALU_X_10_Mesochytrium_penetrans_D_T_', 'CALU_X_10_Mesochytrium_penetrans_D_T_', label = "Mesochytriales", offset = -.05, fontsize = input$text) +
      geom_strip('JEL0613_Geranomyces_variabilis_O__', 'JEL0568_Kochiomyces_dichotomus___', label = "Spizellomycetales", offset = -.05, fontsize = input$text) +
      geom_strip('Barr429_Arizonaphlyctis_lemmonensis__T_', 'JEL0342_Catenomyces_persicinus_D__', label = "Rhizophlyctidales", offset = -.05, fontsize = input$text) +
      geom_strip('JEL0374_Lobulomyces_poculatus___', 'KS027_Cyclopsomyces_plurioperculatus_D_T_', label = "Lobulomycetales", offset = -.05, fontsize = input$text) +
      geom_strip('JH_SA_Nowakowskiella__D__', 'JEL0125_Nephrochytrium__D__', label = "Cladochytriales", offset = -.05, fontsize = input$text) +
      geom_strip('JEL0570_Arkaya____', 'JEL0444_Neokarlingia____', label = "Polychytriales", offset = -.05, fontsize = input$text) +
      geom_strip('KS098_Zygophlyctis_asterionellae_D_T_', 'KS099_Zygophlyctis_melosirae_D__', label = "Zygophlyctidales", offset = -.05, fontsize = input$text) +
      geom_strip('KS097_Zygorhizidium_willei_D__', 'KS097_Zygorhizidium_willei_D__', label = "Zygorhizidiales", offset = -.05, fontsize = input$text) +
      
      #Highlights
      geom_highlight(node = 1331, fill = "grey", alpha = 0.3, extend = 0.175) +
      #geom_highlight(node = 1104, fill = "white") +
      geom_highlight(node = 1330, fill = "grey", alpha = 0.3, extend = 0.229) +
      #geom_highlight(node = 212, fill = "white") +
      geom_highlight(node = 917, fill = "grey", alpha = 0.3, extend = 0.22) +
      #geom_highlight(node = 728, fill = "white") +
      geom_highlight(node = 1562, fill = "grey", alpha = 0.3, extend = 0.4125) +
      #geom_highlight(node = 932, fill = "white") +
      geom_highlight(node = 1038, fill = "grey", alpha = 0.3, extend = 0.28) +
      #geom_highlight(node = 1018, fill = "white") +
      geom_highlight(node = 936, fill = "grey", alpha = 0.3, extend = 0.415) +
      #geom_highlight(node = 42, fill = "white") +
      theme_tree2() +
      geom_point() +
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = TRUE)
  })
  
  # Allow users to zoom in on tree 
  observeEvent(input$plot_dblclick, {
    brush <- input$plot_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
    } 
    else {
      ranges$x <- NULL
      ranges$y <- NULL
    }
  })

  
  output$treeDisplay <- renderPlot(make_tree())
  
  #Render table
  output$info <- renderDataTable(
    nearPoints(make_tree()$data %>% select(x, y, node, Isolate, Family, Order_1, Country, State, Link), input$plot_click, threshold = 15, maxpoints = 1), 
    escape = FALSE, 
    options = list(dom = 't', columnDefs = list(list(targets = c(0, 1, 2, 3, 4, 5, 6, 7, 8), searchable = FALSE)))
    
    )
})

# Run the application
#shinyServer(ui, server)
