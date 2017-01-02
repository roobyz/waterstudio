# ###################################################################################
# Include desired R packages

# Update the following list of packages to set your default installation
pkgs <- c("caret"
         ,"caTools"
         ,"Ckmeans.1d.dp"
         ,"crayon"
         ,"cvAUC"
         ,"data.table"
         ,"DBI"
         ,"devtools"
         ,"DiagrammeR"
         ,"digest"
         ,"dplyr"
         ,"e1071"
         ,"evaluate"
         ,"feather"
         ,"flam"
         ,"forecast"
         ,"foreign"
         ,"formatR"
         ,"ggplot2"
         ,"highr"
         ,"htmltools"
         ,"IRdisplay"
         ,"knitr"
         ,"lubridate"
         ,"markdown"
         ,"MonetDBLite"
         ,"parallel"
         ,"plotly"
         ,"profvis"
         ,"pbdZMQ"
         ,"randomforest"
         ,"ranger"
         ,"rmarkdown"
         ,"readr"
         ,"readxl"
         ,"repr"
         ,"reshape2"
         ,"R.utils"
         ,"stringr"
         ,"superheat"
         ,"tidyr"
         ,"uuid"
         ,"vcd"
         ,"xgboost"
         ,"yaml")

for (pkg in pkgs) {
    if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
}

# Install Native R kernel for Jupyter
devtools::install_github('IRkernel/IRkernel')

# Register the kernel in the current R installation
IRkernel::installspec(user = FALSE)

#          ,"crisp" "TBD"
