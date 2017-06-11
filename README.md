## Supplementary Information

This repository holds the additional source code used in image processing (MATLAB file `image_analysis.mat`) and BONCAT fluorescent activity modeling (`boncat_activity_model.Rmd` and `boncat_activity_evaluation.Rmd`) for the following pucliation: Pasulka et al. 2017. *Applications of BONCAT and nanoSIMS for measuring viral production and virus-host interactions in the ocean* (NOTE: full citation, doi and link to follow after publication). 

### Instructions for running the RMarkdown files:

For the easiest way to run the two [R Markdown](http://rmarkdown.rstudio.com/) (.Rmd) files that produce the figures and HTML reports, please follow the instructions below.

### What is R Markdown?

[R Markdown](http://rmarkdown.rstudio.com/) is a so-called "literate programming" format that enables easy creation of dynamic documents with the [R](http://www.r-project.org/) language. HTML reports (such as those provided in the journal's SI for this publication **NOTE: can we provide this to the journal?**) can be generated from R Markdown files using [knitr](http://yihui.name/knitr/) and [pandoc](http://johnmacfarlane.net/pandoc/), which can be installed automatically within [RStudio](http://www.rstudio.com/), and are fully integrated into this cross-platform IDE. All software used for these reports (R, RStudio, etc.) is freely available and completely open-source. 

### How can I run this code?

The quickest and easiest way is to use RStudio.

 1. Download and install [R](http://cran.rstudio.com/) for your operating system
 1. Download and install [RStudio](http://www.rstudio.com/products/rstudio/download/) for your operating system
 1. Download a [zip file of this repository](https://github.com/apasulka/Viral-BONCAT/archive/master.zip) and unpack it in an easy to find directory on your computer
 1. Start RStudio and select File --> New Project from the menu, select the "Existing Directory" option and browse to the repository folder from the zip file in the "Project working directory" field, then select "Create Project"
 1. Install the required libraries by running the following command in the **Console** in RStudio: `install.packages(c("tidyverse", "knitr", "lans2r"))` or by installing them manually in the RStudio's **Packages** manager.
 1. Open any of the R Markdown (.Rmd) files in the file browser.
 1. To generate the HTML report ("knit HTML"), select File --> Knit from the menu. The HTML report will be displayed upon successful completion (some might take a few minutes because of the complex figures) and is saved as a standalone file in the same directory (these are the files made available in the journal's SI **NOTE: can we provide this to the journal?**). All generated figures are saved as PDFs and PNGs in the plot/ sub-directory.
 
### What can I do with this code?

We hope that this code, or any part of it, might prove useful to other members of the scientific community interested in the subject matter. All code is completely open-access and can be modified and repurposed in every way. If significant portions are reused in a scientific publication, please consider citing our work. Please make sure to cite this work if re-using any of our data (anything in the `data` directory).

### References and additional software used in data processing

The following are the differnt outside software packages used with links to their websites and installation instructions.

 - Mapping and ROI identification in raw NanoSIMS data: [Look at NanoSIMS ](http://nanosims.geo.uu.nl/nanosims-wiki/doku.php/nanosims:lans) (Polerecky et al. 2012)
 - Processing, calibration and visualization of LANS data in R: [lans2r](https://github.com/KopfLab/lans2r#lans2r) 
 - General R data and plotting tools: [tidyverse](http://tidyverse.org/) 
 - RMarkdown report generation: [knitr](https://yihui.name/knitr/) 

#### Troubleshooting notes

The R Markdown files in this repository make use of various R modules for data processing, plotting and modelling. If the knitting of an RMarkdown file fails because of a missing package, please install it manually, an error will indicate which package is missing. 
 
