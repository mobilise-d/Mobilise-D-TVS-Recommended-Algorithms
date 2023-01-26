This toolbox contains code (MATLAB, R2018b) for step/stride length estimation using a biomechanical model of body center of mass (CoM) during locomotion (walking) [1].  

The method includes:

\- Correction of sensor orientation using inertial sensor fusion algorithm and principal component analysis [2,3]

\- Implementation of the inverted pendulum model [1]

\- Double integration of the acceleration in the vertical axis

\- Detrending and removal of integration drift: high pass filtering of vertical acceleration (fc=0.1Hz) and integrated vertical acceleration (fc=1Hz)

\- Correction factors ‘K’ optimized and tuned by training on reference data from clinical cohorts [3]. The K factors suggested by the validation study [3] can be downloaded by the algorithm from the following models (provided in the folder Library\TrainedModels): 

**‘ICICLE\_ALL’:**  the value of correction factor (K=4.99) was obtained from data recorded in lab (GAITRite system), in healthy adults and patients with Parkinson’s disease.

**‘MS-ALL’**: the value of correction factor (K=4.739) was obtained from data recorded in real-life-like context, in healthy adults and patients with multiple sclerosis. 

` `**‘MS-MS’**: the value of correction factor (K=4.587) was obtained from data recorded in real-life-like context, in patients with multiple sclerosis. 



The algorithm is implemented in the main function STRIDELEN.m. The script example\_GSD\_SD\_CAD\_SL.m contains an exemplary application of the algorithm (includes all algorithms necessary to provide the inputs for STRIDELEN.m).  The input data should be provided in the standardized format adopted by MobiliseD project [4].  The algorithm requires: the start and end of each gait sequence, in the format provided by the Gait Sequence detection algorithm; the vector including the timing of ICs;  the model name (to be selected between **‘ICICLE\_ALL’, ‘MS-ALL’, ‘MS-MS’);**  and information from the structure infoForAlgo (the necessary variable for the biomechanical model is the SensorHeight (corresponds to the distance, in cm, from ground to the sensor located on subject’s lower back; this info should be collected at each monitoring session).

Note that the output is the StrideLength (2\*StepLength).

References:

[1] Zijlstra, W., & Hof, A. L. (2003). Assessment of spatio-temporal gait parameters from trunk accelerations during human walking. Gait & posture, 18(2), 1-10.

[2] Madgwick, S. (2010). An efficient orientation filter for inertial and inertial/magnetic sensor arrays. Report x-io and University of Bristol (UK), 25, 113-118. (Open source code: https://x-io.co.uk/open-source-imu-and-ahrs-algorithms/)

[3] Soltani, A., et al. "Algorithms for walking speed estimation using a lower-back-worn inertial sensor: A cross-validation on speed ranges." IEEE TNSRE 29 (2021): 1955-1964.

[4] Micó-Amigo, M. E., Bonci, T., Paraschiv-Ionescu, A., Ullrich, M., Kirk, C., Soltani, A., ... & Del Din, S. (2022). Assessing real-world gait with digital technology? Validation, insights and recommendations from the Mobilise-D consortium.

[5] Palmerini, L., et al. "Mobility recorded by wearable devices and gold standards: the Mobilise-D procedure for data standardization." *Scientific Data* (2022).
