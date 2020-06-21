
Thu Jan 24 18:47:08 PST 2002

This binary version of the runica() function of Makeig et al.  contained
in the EEG/ICA Toolbox runs 12x faster than the Matlab version. It uses
the logistic infomax ICA algorithm of Bell and Sejnowski, with natural
gradient and extended ICA extensions.  It was programmed for unsupervised
usage by Scott Makeig at CNL, Salk Institute, La Jolla CA. Sigurd Enghoff
translated it into C++ code and compiled it for multiple platforms. J-R
Duann has improved the PCA dimension-reduction and has compiled the
linux and free_bsd versions.

To use the function, call with a ".sc" file argument. For individual
Copy and modify the sample script "ica.sc".

                % ica < myversion.sc 

Ica creates two files, "xxx.wts" and "xxx.sph" containing weights and
sphere matrices such that

                >> ICA_activations = wts * sph * data; 

The "xxx" stem in the output files may be specified within the input .sc
parameter file. See the sample .sc file for arguments, and the EEG/ICA
toolbox tutorial for more details.

ica_bsd   - FreeBSD Unix
ica_linux - linux version (tested under Red Hat)
ica_sgi   - SGI (older version, PCA not optimized)
ica_sun   - Sun OS (older version, PCA not optimized)
ica.exe   - PC version (older version, PCA not optimized, stable?)

Scott Makeig
Jan. 26, 2002
