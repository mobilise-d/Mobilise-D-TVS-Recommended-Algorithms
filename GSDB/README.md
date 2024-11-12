The Gait Sequence Detection toolbox contains code (MATLAB, R2018b) for detection of gait (walking) sequences using body acceleration recorded with a triaxial accelerometer worn/fixed on the lower back (close to body center of mass).

The algorithm was developed and validated using data recorded in patients with impaired mobility (Parkinson’s disease, multiple sclerosis, hip fracture, post-stroke and cerebral palsy). 

The algorithm detects the gait sequences based on identified steps. First, the norm of triaxial acceleration signal is detrended and low-pass filtered (FIR, fc=3.2Hz). In order to enhance the step-related features (peaks in acceleration signal) the obtained signal is further processed using continuous wavelet transform, Savitzky-Golay filters and Gaussian-weighted moving average filters [2]. The ‘active’ periods, potentially corresponding to locomotion, are roughly detected and the statistical distribution of the amplitude of the peaks in these active periods is used to derive an adaptive (data-driven) threshold for detection of step-related peaks. Consecutive steps are associated to gait sequences [1, 2]. 

The gait sequence detection algorithm is implemented in the main function GSD\_LowerBackAcc.m.  The script example\_GSD.m contains an exemplary application of the algorithm, using input data in the standardized format adopted by MobiliseD project [4].  However, the algorithm can be applied for any data in the specified format (see Input/Output description).

Note that this algorithm is referred as **GSDB** in the validation study [3].

References:

[1] Paraschiv-Ionescu, A, et al. "Locomotion and cadence detection using a single trunk-fixed accelerometer: validity for children with cerebral palsy in daily life-like conditions." *Journal of neuroengineering and rehabilitation* 16.1 (2019): 1-11.

[2] Paraschiv-Ionescu, A, Soltani A, and Aminian K. "Real-world speed estimation using single trunk IMU: methodological challenges for impaired gait patterns." 2020 42nd Annual International Conference of the IEEE Engineering in Medicine & Biology Society (EMBC). IEEE, 2020.

[3] Micó-Amigo, M. E., Bonci, T., Paraschiv-Ionescu, A., Ullrich, M., Kirk, C., Soltani, A., ... & Del Din, S. (2022). Assessing real-world gait with digital technology? Validation, insights and recommendations from the Mobilise-D consortium.

[4] Palmerini, L., et al. "Mobility recorded by wearable devices and gold standards: the Mobilise-D procedure for data standardization." *Scientific Data* (2022).
