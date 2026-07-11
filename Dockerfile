# Use rocker/rstudio as the base image
FROM rocker/rstudio:latest

# Set the working directory to /home/rstudio
WORKDIR /home/rstudio

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install additional system dependencies if needed
RUN apt-get update && apt-get install -y libglpk-dev libxml2-dev libcurl4-openssl-dev libssl-dev libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libfribidi-dev libpng-dev libtiff5-dev libjpeg-dev zlib1g-dev libbz2-dev liblzma-dev libgit2-dev libncurses-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install BiocManager for initial commit
RUN R -e "install.packages(c('BiocManager'), repos='https://cloud.r-project.org/')"

# Install R packages required for methylation-array analysis
RUN R -e "BiocManager::install(c('readxl', 'ggplot2', 'plotly', 'patchwork', 'Rtsne', 'matrixStats', 'dplyr', 'sesame', 'DT'))"
RUN R -e "BiocManager::install(c('sesameData','knowYourCG'))"
RUN R -e "BiocManager::install(c('rmarkdown', 'pals'))"
RUN apt-get update && apt-get install -y cmake
RUN R -e "BiocManager::install(c('dendextend','VIM'))"
RUN R -e "BiocManager::install(c('circlize','ComplexHeatmap'))"
RUN R -e "BiocManager::install(c('shiny', 'ggrepel', 'org.Hs.eg.db', 'org.Mm.eg.db', 'org.Rn.eg.db', 'msigdbr', 'clusterProfiler', 'enrichplot', 'ReactomePA'))"
RUN R -e "BiocManager::install(c('limma', 'sva', 'RPMM','remotes','minfi'))"
RUN R -e "BiocManager::install('AnnotationHub')"
RUN R -e "BiocManager::install('DNAcopy')"
RUN R -e "install.packages('tinytex')"
RUN R -e "tinytex::install_tinytex()"

# Expose the default RStudio port
EXPOSE 8787

# Set the default command
CMD ["/init"]

