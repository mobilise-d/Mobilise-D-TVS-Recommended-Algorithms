Algorithm implemented on a pre-processed vertical acceleration signal recorded on lower back. This signal is first detrended and then low-pass filtered (FIR, fc=3.2 Hz). The resulting signal is numerically integrated (cumtrapz) and differentiated using a Gaussian continuous wavelet transformation (CWT, scale 9, gauss2). The initial contact (IC) events are identified as the positive maximal peaks between successive zero-crossings.

The algorithm is implemented in the main function StepDetection.m. The script example\_GSD\_SD.m contains an exemplary application of the algorithm, using input data in the standardized format adopted by MobiliseD project [4].  The algorithm requires also the start and end of each gait sequence, in the format provided by the Gait Sequence detection algorithm. 

Note that this algorithm is referred as **ICDA** in the validation study [3].

References:

[1] McCamley, J., Donati, M., Grimpampi, E., & Mazzà, C. (2012). An enhanced estimate of initial contact and final contact instants of time using lower trunk inertial sensor data. *Gait & posture*, *36*(2), 316-318.

[1] Paraschiv-Ionescu, A, Soltani A, and Aminian K. "Real-world speed estimation using single trunk IMU: methodological challenges for impaired gait patterns." 2020 42nd Annual International Conference of the IEEE Engineering in Medicine & Biology Society (EMBC). IEEE, 2020.

` `[3] Micó-Amigo, M. E., Bonci, T., Paraschiv-Ionescu, A., Ullrich, M., Kirk, C., Soltani, A., ... & Del Din, S. (2022). Assessing real-world gait with digital technology? Validation, insights and recommendations from the Mobilise-D consortium.

[4] Palmerini, L., et al. "Mobility recorded by wearable devices and gold standards: the Mobilise-D procedure for data standardization." *Scientific Data* (2022).
