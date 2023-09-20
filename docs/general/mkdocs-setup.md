# MKDOCS Install & Configuration

This site uses MKDocs for the publishing of the "GitHub Pages" site

You MUST install both MKDocs and the Material Theme.

Here is how you setup your machine to edit the documentation hosted on the Github Pages Site. Details of these steps are below.

**Outline of the steps you will take**

1. Install MKdocs
2. Install the MKdocs Theme (Material)
3. Get a Personal Access Token from GitHub
4. Clone this repository
5. Make your changes (Feel free to reach out to Dave Krier or Kyle Dawson for help on how to use MKDocs)
6. Deploy your changes

## Install MKDocs

[Here is the installation documentation for MKDocs](https://www.mkdocs.org/user-guide/installation/)

Install the MKDocs theme
Install guidance is on the Material theme page.

[Material Theme - Quick Start](https://squidfunk.github.io/mkdocs-material/getting-started/)

## Material Theme Documentation

```
pip3 install mkdocs-material
```

You can check the version of Material you currently have installed with this command. 

```
python3 -m pip list
```

If you have any issues with the pip install, you may need to perform an uninstall and reinstall. 

```
pip3 uninstall  mkdocs-material
pip3 install  mkdocs-material

pip3 uninstall mkdocs
pip3 install mkdocs
```
 

[Link to the Material Theme Documentation](https://squidfunk.github.io/mkdocs-material/reference/admonitions/)

## You need a "Personal Access Token" from Github. (This is super simple).

Why do I need this? You need this because you need to be able to push changes back into the github repository.

Here is a Github doc page you can look at for help if the steps below do not make sense.

1. Login to Github.
2. Click on your user icon in the upper right hand corner
3. Select Settings --> Developer Settings --> Personal Access Tokens
4. Generate a new token with only these prevliages
	- Repo:Status
	- Repo-Deployment
	- Public-Repo
	- Take note of the access key (It's the only time you will see it)

!!! important 

	You will use this Access Token as your password when using the gh-deploy mkdocs command. 

## Clone this repo in Github.

I assume you will all know how to do that!!

## MKDocs User Guide - Modifying the site

[MKDocs Documentation](https://www.mkdocs.org/user-guide/writing-your-docs/#writing-your-docs)

Deploying your changes.

1. Navigate to your cloned repo directory in a terminal window.

	*You must be inside the /daffydoc directory to run the following commands.*

2. Build the files using the build command
	
```
mkdocs build
```
	
3. Deploy the newly built files to the Github Pages site 

!!! note inline end

	This is where you will use the access token from Github. Use the access 	token instead of your password. 
		
```
mkdocs gh-deploy
```
	