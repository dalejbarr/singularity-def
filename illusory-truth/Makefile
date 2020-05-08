INFERENCE=FALSE
RECIPE=FALSE
OUT=analysis.Rmd
OUTFILE=analysis.html
INFILE=NULL

analysis : 
	Rscript -e "library('truthiness'); reproduce_analysis(path = '$(SUBDIR)', recipe = $(RECIPE), outfile = '$(OUTFILE)')"

fake_data : 
	Rscript -e "library('truthiness'); set.seed(62); simulate_resp_files(80, path = 'all_null_raw', overwrite = TRUE); preprocess('all_null_raw', 'all_null', TRUE)"
	Rscript -e "library('truthiness'); set.seed(62); simulate_resp_files(80, phase_eff = c(.2, .2, .2, .2), path = 'main_effect_raw', overwrite = TRUE); preprocess('main_effect_raw', 'main_effect', TRUE)"
	Rscript -e "library('truthiness'); set.seed(62); simulate_resp_files(80, phase_eff = c(.8, .6, .2, 0), path = 'interaction_raw', overwrite = TRUE); preprocess('interaction_raw', 'interaction', TRUE)"
	Rscript -e 'library("truthiness"); reproduce_analysis("all_null", outfile = "analysis_all_null.html", recipe = TRUE)'
	Rscript -e 'library("truthiness"); reproduce_analysis("main_effect", outfile = "analysis_main_effect.html", recipe = TRUE)'
	Rscript -e 'library("truthiness"); reproduce_analysis("interaction", outfile = "analysis_interaction.html", recipe = TRUE)'

draft :
	Rscript -e "rmarkdown::draft('$(OUT)', 'illusory-truth-analysis', 'truthiness', FALSE, FALSE)" && echo "wrote R Markdown script to $(OUT)"

render :
	Rscript -e "library('truthiness'); reproduce_analysis(path = '$(SUBDIR)', recipe = $(RECIPE), infile = '$(INFILE)', outfile = '$(OUTFILE)')"
