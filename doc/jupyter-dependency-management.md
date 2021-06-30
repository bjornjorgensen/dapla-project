# Python dependency management for JupyterLab projects

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

## Enabling Spark in a custom kernel

If you want to be able to run Spark code using a pipenv-kernel setup, you must use one of the Spark kernels as your template kernel, AND you must run `pipenv install ssb-ipython-kernels` in your project folder. As of 20/04/2021 you might have to `pipenv install jwt` too, but this should not be necessary in the future.


