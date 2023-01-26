The Cadence Detection toolbox contains code (MATLAB, R2018b) for estimating the cadence during each detected gait sequence.   The method is based on steps detection and demarcation. Step duration is defined as the period between two consecutive feet initial contacts (consecutive heel strikes from left and right foot). Then, the *instantaneous cadence* is estimated as the inverse function of the step duration (in minute unit to have steps/min unit for the cadence). Eventually, for each algorithm, the *mean value of the cadence* over each gait sequence is computed. The algorithm provides the *instantaneous cadence* at every second during the gait sequence.

For detection of steps two algorithms are available. Both use the tri-axial acceleration norm after pre-processing to filter the noise and enhance the step-related pattern. 

Pre-Processing includes: detrending, low-pass filtering (FIR, fc=3.2 Hz), smoothing using Savitsky-Golay filter (order=7, frame length =21) and Gaussian smoothing, and continuous wavelet transform (CWT, scale 10, ‘gaus2’) to enhance the relevant steps-related features (peaks) in acceleration signal.

Steps detection and demarcation (and subsequently the cadence) can be performed by selecting one of the two implemented algorithms: 

With the algorithm **‘HKLee\_imp’** (implemented by function HKLee\_improved.m), the pre-processed signal is further processed using morphological filters, according to methods described in  [1,2]. Finally, the timing of steps, used to estimate step frequency, are detected as maxima between successive zero-crossings.

With the algorithm **‘Shin\_imp’** (implemented by function Shin\_improved.m), the timing of steps, used to estimate step frequency, are identified as the zero-crossing on the positive slopes of pre-processed signal [1, 3]. 

The cadence detection algorithm is implemented in the main function CADENCE.m. The script example\_GSD\_CAD.m contains an exemplary application of the algorithm, using input data in the standardized format adopted by MobiliseD project [4].  The algorithm requires also the start and end of each gait sequence, in the format provided by the Gait Sequence detection algorithm. 

Note that in the validation study [3] cadence estimation using **‘HKLee\_imp’** is referred as **CADB**, and using **‘Shin\_imp’** as **CADc**. 

References:

[1] Paraschiv-Ionescu, A, Soltani A, and Aminian K. "Real-world speed estimation using single trunk IMU: methodological challenges for impaired gait patterns." 2020 42nd Annual International Conference of the IEEE Engineering in Medicine & Biology Society (EMBC). IEEE, 2020.

[2] Lee, H-K., et al. "Computational methods to detect step events for normal and pathological gait evaluation using accelerometer." Electronics letters 46.17 (2010): 1185-1187.

[3] [1] Shin, Seung Hyuck, and Chan Gook Park. "Adaptive step length estimation algorithm using optimal parameters and movement status awareness”. Medical engineering & physics 33.9 (2011): 1064-1071.

[4] Micó-Amigo, M. E., Bonci, T., Paraschiv-Ionescu, A., Ullrich, M., Kirk, C., Soltani, A., ... & Del Din, S. (2022). Assessing real-world gait with digital technology? Validation, insights and recommendations from the Mobilise-D consortium.

[5] Palmerini, L., et al. "Mobility recorded by wearable devices and gold standards: the Mobilise-D procedure for data standardization." *Scientific Data* (2022).
