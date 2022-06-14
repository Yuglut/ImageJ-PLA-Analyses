This ImageJ script analyses PLA images in an automated way. 
When running, the user is prompted to select the folder in which files 
to analyse are present and their extension. Results will be stored 
where the output variable references to.
- BioFormats plugin is necessary to open the images.
- The script relies on the 'Analyse particles' function implemented in 
  ImageJ. Nuclei are counted on the channel 0 of each image while PLA 
  dots are counted on channel 1. These channels may need to be adapted 
  to the user's needs.
