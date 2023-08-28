# Neuronal population dynamics during the maintenance and manipulation of information in working memory

Materials created during the group's project of NMA2023. Authors: Eléonore Houdoyer, Sofia Raak, Iakov Kharitonov, Ladislas Nalborczyk, Jiaxin Wang. Mentoring: Taha Solakoglu and Maciek Szul.

## Abstract (to be updated)

Working memory enables animals to maintain a stable and coherent representation of the external world. However, how working memory is encoded in the brain remains poorly understood. One key question is how a population of neurons with fluctuating activity successfully maintains a stable representation of a phenomenon, and how these representations are affected by previous experience or prior knowledge. Based on previous experimental and modelling work, we suggest that representational stability is achieved through population dynamics where the dynamical activity of neuronal populations rather than individual neurons can generate stable activity motifs in the working memory neural landscape. To study the dynamics of working memory, we designed a simple recurrent neural network model of working memory and trained it to perform a delayed matching task. We performed joint analysis of the artificial network's activity and intracranial single-neuron spike-train recordings from rhesus monkey prefrontal cortex to achieve a mechanistic understanding of the latent dynamics governing working memory in vivo and in silico. We then trained an identical network for a shorter duration to perform with lower accuracy in the delayed matching task to investigate the effects of reduced training of the task on the network dynamics in working memory. We hypothesise that 1) specific memories are transiently encoded at the individual-neuron level but sustainedly encoded by population dynamics throughout the entire trial, 2) the level of prior exposure to the task will change the memory neural landscape, and 3) activity-silent periods will be observed in both recurrent neural networks and monkeys. Our work will contribute to the understanding of the interplay between population dynamics and prior learning in the context of working memory. Future research should examine how lower-scale (e.g., short-term synaptic plasticity) or structural (e.g., connectivity) features affect population dynamics during working memory tasks.

## Code

__importing_analysing_monkeys_data.ipynb__ imports monkey spike train data, applies smoothing and averaging, computes PCA, plots distance between trajectories in latent space, applies temporal decoding, finds neurons shared between trials.

__RNN_Delay_Task.ipynb__ defines and trains a RNN model on Delayed Match-to-Category task.

__Monkey_Data_Preprocessing_Meyer_2011.ipynb__ imports monkey spike train data, applies smoothing and finds neurons shared between trials as in __importing_analysing_monkeys_data.ipynb__.

__Dimensionality_Reduction_Analysis.ipynb__ analyses the activity of the hiddent units of the RNN in PCA space.

__RNN_Decoding.ipynb__ applies temporal decoding to the hidden units of the RNN.

## References

Chaisangmongkon, W., Swaminathan, S. K., Freedman, D. J., & Wang, X.-J. (2017). Computing by Robust Transience: How the Fronto-Parietal Network Performs Sequential, Category-Based Decisions. Neuron, 93(6), 1504-1517.e4. https://doi.org/10.1016/j.neuron.2017.03.002

Ehrlich, D. B., Stone, J. T., Brandfonbrener, D., Atanasov, A., & Murray, J. D. (2021). PsychRNN: An Accessible and Flexible Python Package for Training Recurrent Neural Network Models on Cognitive Tasks. ENeuro, 8(1). https://doi.org/10.1523/ENEURO.0427-20.2020

King, J.-R., & Dehaene, S. (2014). Characterizing the dynamics of mental representations: The temporal generalization method. Trends in Cognitive Sciences, 18(4), 203–210. https://doi.org/10.1016/j.tics.2014.01.002

Kobak, D., Brendel, W., Constantinidis, C., Feierstein, C. E., Kepecs, A., Mainen, Z. F., Romo, R., Qi, X.-L., Uchida, N., & Machens, C. K. (2016). Demixed principal component analysis of neural population data. eLife, 5. http://dx.doi.org/10.7554/eLife.10989

Mante, V., Sussillo, D., Shenoy, K. V., & Newsome, W. T. (2013). Context-dependent computation by recurrent dynamics in prefrontal cortex. Nature, 503(7474), 78–84. https://doi.org/10.1038/nature12742

Masse, N. Y., Yang, G. R., Song, H. F., Wang, X.-J., & Freedman, D. J. (2019). Circuit mechanisms for the maintenance and manipulation of information in working memory. Nature Neuroscience, 22(7), Article 7. https://doi.org/10.1038/s41593-019-0414-3

Meyer, T., Qi, X.-L., Stanford, T. R., & Constantinidis, C. (2011). Stimulus Selectivity in Dorsal and Ventral Prefrontal Cortex after Training in Working Memory Tasks. Journal of Neuroscience, 31(17), 6266–6276. https://doi.org/10.1523/JNEUROSCI.6798-10.2011

Mongillo, G., Barak, O., & Tsodyks, M. (2008). Synaptic Theory of Working Memory. Science, 319(5869), 1543–1546. https://doi.org/10.1126/science.1150769

Spaak, E., Watanabe, K., Funahashi, S., & Stokes, M. G. (2017). Stable and Dynamic Coding for Working Memory in Primate Prefrontal Cortex. The Journal of Neuroscience, 37(27), 6503–6516. https://doi.org/10.1523/JNEUROSCI.3364-16.2017

Stokes, M. G., Kusunoki, M., Sigala, N., Nili, H., Gaffan, D., & Duncan, J. (2013). Dynamic Coding for Cognitive Control in Prefrontal Cortex. Neuron, 78(2), 364–375. https://doi.org/10.1016/j.neuron.2013.01.039

Stokes, M. G. (2015). ‘Activity-silent’ working memory in prefrontal cortex: A dynamic coding framework. Trends in Cognitive Sciences, 19(7), 394–405. https://doi.org/10.1016/j.tics.2015.05.004

Vyas, S., Golub, M. D., Sussillo, D., & Shenoy, K. V. (2020). Computation Through Neural Population Dynamics. Annual Review of Neuroscience, 43(1), 249–275. https://doi.org/10.1146/annurev-neuro-092619-094115
