    #  Workflow for Nmix models
    #  Josh Nowak and Leah Swartz
    #  02/2017
################################################################################
    #  Packages
    require(R2jags)
    require(readr)
    require(tidyr)
    require(dplyr)
################################################################################
    #  Set working directory
    setwd("C:/Users/josh.nowak/Documents/GitHub/Leah_frogs")

    #  Source helper functions
    source("helpers/Nmix_utility_funs.R")

    #  Load observation data
    raw_dat <- read_csv("C:/Users/josh.nowak/Documents/Leah_frogs/data.csv")
    
    #  Load covariate data
    cov_dat <- read_csv(
      "C:/Users/josh.nowak/Documents/Leah_frogs/BR_site_covariates.csv"
      ) %>%
      mutate(
        site = site_dic$site_num[match(SiteName, site_dic$site_nm)]
      )
    
    #  Load dics
    load("data/site_dic.RData")
################################################################################
    #  Morph observation data
    y_obs <- morph_data(raw_dat, site_dic) %>%
      left_join(., cov_dat, by = "")
################################################################################
    #  Call model on grouped data, species by year
    #  Remove species grouping if using multi-species model
    #  This example call shows how to use a single covariate
    fit1 <- y_obs %>%
      filter(site != 22) %>%
      group_by(sp, year) %>%
      do(fit = 
        call_jags(
          x = .,
          covs = "n_trap",
          model.file = "models/Nmix_cN_trapD.txt",
          n.chains = 3,
          n.iter = 500,
          n.burnin = 100, 
          n.thin = 1
        )
      )

    #  Example call without covariates
    fit2 <- y_obs %>%
      group_by(sp, year) %>%
      do(fit = 
        try(call_jags(
          x = .,
          covs = NULL,
          model.file = "models/Nmix_cN_cD.txt",
          n.chains = 3,
          n.iter = 500,
          n.burnin = 100, 
          n.thin = 1
        ))
      )
      
    #  Example call with covariate and random effect
    
    #  This won't work for now because site names will end up being NA due to 
    #   errors in the data
    
    fit3 <- y_obs %>%
      group_by(sp, year) %>%
      do(fit = 
        try(call_jags(
          x = .,
          covs = "n_trap",
          model.file = "models/Nmix_sN_trapD.txt",
          n.chains = 3,
          n.iter = 500,
          n.burnin = 100, 
          n.thin = 1
        ))
      )
      
    #  
################################################################################
    #  TODO
    #   multi-species, optional
    #   random effect on site
    #   accommodate primary and secondary occassions
    #   add covariates
