# Dependency management for JupyterLab projects
When using JupyterLab, we sometimes need to install and use different/specific packages on a per-project basis. We need to do this both for Python and for R projects.

# Python dependency management

It is possible to use different Python packages and different versions of packages for different JupyterLab projects, and automatically keep track of which versions of which packages were used in the project at any given time. This is achieved by creating a Python virtual environment for each project, and creating a new Jupyter kernel that utilizes the virtual environment. 

("project" should be taken to mean a folder that is probably version controlled as a single GIT repository, or "repo" for short, and that contains one or more Jupyter notebooks with Python code)

**TL;DR:** 
- Use the Python virtual environment tool `pipenv` when installing Python packages in your project folder. In addition to automatically creating a new environment per project, `pipenv` has the benefit of automatic and explicit tracking of installed packages (+dependencies) in text files that can be version controlled using GIT.
- Use the command line tool `pipenv-kernel` to bake the project's virtual environment into a "kernel", which you then select for running the project's notebook(s).

## pipenv

To install `pipenv` into JupyterLab, open a terminal window and type `pip install pipenv`.

To install a package using pipenv (and automatically initialize the virtual environment for this folder if it does not exist), simply open a terminal window, navigate to your project folder (`cd <project-folder`) and execute the command

`pipenv install <package-name>`

The package is downloaded from a private Python Package Index running on Dapla (The `dapla-pypiserver` GitHub repository contains further documentation on this: https://github.com/statisticsnorway/dapla-pypiserver).

All installed packages, their exact dependencies and the python version will automatically be listed in two files called `Pipfile` and `Pipfile.lock`. These should be version controlled using GIT, to ensure reproducibility of your Python environment. If there are `Pipfile`s present in the current folder, you can use the `pipenv install` command to create a virtual environment fulfilling all the dependencies, or make sure the existing virtual environment fulfills the requirements of the `Pipfile`s. If there is a virtual environment generated for your current folder, you can run the command `pipenv --venv` to see the full path to the virtual environment binaries and libraries.

See the `pipenv` documentation for explanation of other available functionality (https://docs.pipenv.org/).

## Requesting new Python packages and package versions

If a Python package you need, or a specific version you need, is not available using `pipenv install`, it is because it is not installed on the Dapla PyPiServer which `pipenv` retrieves packages from. You can request to have it added to the "whitelist" by making a pull request to the `Packages.txt` file in the Dapla PyPiServer GIT repository (https://github.com/statisticsnorway/dapla-pypiserver).

## pipenv-kernel

In order to run a notebook using the pipenv virtual environment, we need to create and select a new Jupyter kernel that utilizes the virtual environment's Python executable and libraries. `pipenv-kernel` is a command line tool that makes it easy to create, activate and delete virtual environments and kernels that utilize a `pipenv` virtual environment.

### Create

Whether you have already created a `pipenv` virtual environment for the current project or not, you can run

`pipenv-kernel create <new-kernel-name> <template-kernel-path>` 

to create a new kernel that uses the current project's pipenv virtual environment, and bases the kernel config on the kernel at the given path.

Use the command `pipenv-kernel create` without arguments to get a list of existing kernels and their paths, that can be passed as the `<template-kernel-path>` argument.

### Activate

`pipenv-kernel activate <pipenv-kernel-name>`

If the `Pipfile` and `Pipfile.lock` are present, and the kernel is installed, then activate the pipenv.

### Delete

#### Delete All

`pipenv-kernel delete-all <pipenv-kernel-name>`

Delete named kernel, pipenv associated to this folder, pipfiles in this folder, and misc kernel generation data stored in this folder.

#### Delete Kernel

`pipenv-kernel delete-kernel <pipenv-kernel-name>`

Delete the named kernel only, not the pipenv or pipfiles.

#### Delete Pipenv

`pipenv-kernel delete-pipenv (--hard)`

Delete pipenv files associated to current project (`pipenv --venv` to display path) from the user home folder. This part can easily be re-generated from the `Pipfile` and `Pipfile.lock` located in the project folder, which are not deleted by default.
The `--hard` option deletes `Pipfile` and `Pipfile.lock` from project folder too, so that all dependency tracking is lost.

### Enabling Spark in a custom kernel

If you want to be able to run Spark code using a pipenv-kernel setup, you must use one of the Spark kernels as your template kernel, AND you must run `pipenv install ssb-ipython-kernels` in your project folder. As of 20/04/2021 you might have to `pipenv install jwt` too, but this should not be necessary in the future.

# R dependency management

## Virtual environments

To create a virtual environment for your project, run these from an R session/notebook inside the project folder:

`library(renv)`

`renv::init()`

A folder called `renv` containing your virtual environment with its own library should now have been created next to the notebook from which you ran the `renv::init()` command. You can now install, uninstall and load packages as usual. The function used to save a list of your dependencies into a lockfile is `renv::snapshot()`*, and to restore the environment from this lockfile, use `renv::restore()`. Read the complete [renv documentation here](https://rstudio.github.io/renv/articles/renv.html). 

---
***NOTE!**

`renv::snapshot()` does not currently manage to extract dependencies from `.ipynb` files (only `.R` and `.Rmd`). The lockfile produced by `renv::snapshot()` will therefore not be sufficient to reproduce your virtual environment in itself if you only load the packages into your notebook directly. One way to solve this is to create a `dependencies.R` file for your project (or perhaps one for each notebook) where you install and load all the packages needed in your project notebook(s), and then at the beginning of your notebook load and resolve packages using this line:

`source(here::here('dependencies.R'))`

An example `dependencies.R`

```
# Initialize the virtual environment
library(renv)
renv::init()

# All package installation and loading goes here
install.packages("lattice", repos='https://cran.uib.no')  # we specify the uib mirror of cran, which has been whitelisted for egress
library(lattice)

# Save the dependencies above into renv.lock
renv::snapshot()

```

With this setup, you do not need to load or initialize `renv` in your notebook directly: The `source` function call is the only thing you need in your notebook related to package management. 

---

## Restoring a renv virtual environment from a lockfile

As explained, using the `renv::snapshot()` function will generate a `renv.lock` file which will describe your project's dependencies. In order to restore the virtual environment from a `renv.lock` file you need to use the function `renv::restore()`.

If you have an accurate `renv.lock` file from which you can `renv::restore()`, you do not need to run `source(here::here('dependencies.R'))` at the beginning of your notebook. In other words, if you used a `dependencies.R` file to load packages initially, you can now replace

`source(here::here('dependencies.R'))`

with

`renv::restore()`

when your dependencies have been locked.

## Installing and loading packages, as usual

Package management inside a `renv` environment works as usual, except for the fact that `snapshot` does not capture usage in notebooks.

To list all locally installed packages in all available libraries, use

`installed.packages()`

When installing a new package from CRAN (the R package index on the internet) that is not present in any of your local libraries, use

`install.packages("packagename", repos='https://cran.uib.no')`

In the "repos" parameter we specify to use a particular mirror of CRAN that has been whitelisted for egress.

Running this function on an already installed package will not do anything.

When loading an already downloaded/installed package from one of your registered R libraries (folders on your machine already containing downloaded packages) into an R session, use this function:

`library(package)`
