# our R base image
FROM r-base

# install MARSS packages
# first, we create a script files and then we run the script file.

RUN echo 'dotR <- file.path(Sys.getenv("HOME"), ".R"); if (!file.exists(dotR)) dir.create(dotR); M <- file.path(dotR, "Makevars"); if (!file.exists(M)) file.create(M); cat("\nCXXFLAGS += -Wno-ignored-attributes -Wno-deprecated-declarations", file = M, sep = "\n", append = TRUE); install.packages(c("rstan","data.table","doMC"), repos = "https://cloud.r-project.org/", dependencies=TRUE)' > /tmp/packages.R \
	      && Rscript /tmp/packages.R

# create an R user
ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
    && chown -R user:user $HOME

WORKDIR $HOME
USER user

# set the command
CMD ["R"]