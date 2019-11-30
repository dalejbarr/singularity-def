talklab-tidy/talklab-tidy.sif : talklab-base/talklab-base.sif talklab-tidy/talklab-tidy.def
	cd talklab-tidy && singularity build talklab-tidy.sif talklab-tidy.def && cd ..

talklab-base/talklab-base.sif : talklab-base/talklab-base.def talklab-base/dotemacs
	cd talklab-base && singularity build talklab-base.sif talklab-base.def && cd ..

illusory-truth/illusory-truth.sif : talklab-tidy/talklab-tidy.sif illusory-truth/illusory-truth.def \
                                    illusory-truth/power_clmm.R
