## Changelog
- Modified `WhiskerTrackerParallel.m` to handle longer data sets.
- Added a loader for `tif` data.

## Requirements
- MATLAB
- Parallel Toolbox
- Image Processing Toolbox

## Whisker Tracking Using The Radon Transform

WhiskerTrackerParallel.m tracks the approximate movement of the mouse's whiskers by quantifying the average whisker angle via a Radon transform of an image of the whiskers (Fig. 1). A detailed explanation of the Radon transform can be found here: https://link.springer.com/article/10.1007%2Fs10827-009-0159-1

| ![](whiskerPad.png) |
|:--:|
| *Figure 1: Still-shot of mouse's whiskers during acquisition* |

The camera used to track the animal's whiskers is a Basler acA640-120gm CCD with an Edmund Optics 18 mm fixed focal length lens (part no. 54857). For our specific set-up, the whiskers are illuminated by a 660 nm (red) light underneath the mouse's head. We thus utilize a 660 nm bandpass filter mounted on the lens to maintain a constant and even illumination of the individual whiskers. The camera is triggered at 150 Hz and the data is saved via a LabVIEW acquisition program.

In the Github folder, you will find Example_WhiskerCam.bin, which is a single 1 minute trial from the Basler camera outputed from LabVIEW. The Matlab code WhiskerTrackExample1.m is a demonstration code written to utilize the core WhiskerTrackerParallel.m and ReadBinFileU8MatrixGradient.m functions and generate a figures to visualize the sample data. Before running WhiskerTrackingExample1.m, you need to verify that the computer you are using has a compatible CUDA-enabled Nvidia graphics card. While GPU computation is not necessary, it significantly speeds up the computation time of the radon transform. A list of compatible GPUs can be found at: https://developer.nvidia.com/cuda-gpus. To enable GPU computation using the gpuArray function, the Parallel Computing Toolbox must be downloaded from Mathworks as a Matlab add-on. More information can be found here: https://www.mathworks.com/products/parallel-computing.html.

Once you have verified that your computer has a compatible GPU and the Parallel Processing Toolbox is installed:
1) Run setup.m to add dependencies to the MATLAB path
2) Open WhiskerTrackingExample1.m in Matlab
3) Click play.

The figure generated from WhiskerTrackingExample.m contains 3 subplots:  

**1) Whisker angle vs. time.**    
A lightly-smoothed (low-pass filtered) version of the animal's whisker angle is plotted over time. When presenting a representative figure of the whisker angle over time, we typically mean-subtract the resting angle to align at zero degrees and invert the entire signal so that protraction is visualized as a positive change in angle.

**2) Whisker acceleration vs. time.**  
The second derivative of the whisker angle is taken to obtain the acceleration vs. time. Since the animal's resting whisker angle can slightly drift throughout imaging, it is insufficient to simply draw an angle-based threshold for whisking events. For this reason, we focus only on the acceleration.

**3) Setting the whisking threshold.**  
To draw a threshold (i.e. a line that is flagged as a "whisk" if a discrete point in time crosses that line) we take the absolute value of the acceleration, as both protraction and retraction of the whiskers count as whisking. To better separate the larger accelerations from the smaller "noise" values (such as very small movements due to respiration) we square the signal and even add a multiplicative gain. Once this is done, a threshold line can be set to filter the data so that any value that exceeds that threshold can be flagged as a whisking event. Once whisking events are flagged, they can be linked together (x whisking events happening in t seconds can be consider one single whisking event) and used to extract or exclude data such as neural activity or changes in blood volume/flow from the corresponding time indices.
