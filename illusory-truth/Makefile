INFERENCE=FALSE
RECIPE=FALSE
OUT=analysis.Rmd
OUTFILE=analysis.html
MODFITS=NULL
INFILE=NULL

analysis : 
	Rscript -e "library('truthiness'); reproduce_analysis(recipe = $(RECIPE), outfile = '$(OUTFILE)', modfits = $(MODFITS))"

fake_data : 
	Rscript -e "library('truthiness'); set.seed(62); simulate_resp_files(80, path = 'all_null_raw', overwrite = TRUE); preprocess('all_null_raw', 'all_null')"
	Rscript -e "library('truthiness'); set.seed(62); simulate_resp_files(80, phase_eff = c(.2, .2, .2, .2), path = 'main_effect_raw', overwrite = TRUE); preprocess('main_effect_raw', 'main_effect')"
	Rscript -e "library('truthiness'); set.seed(62); simulate_resp_files(80, phase_eff = c(.8, .6, .2, 0), path = 'interaction_raw', overwrite = TRUE); preprocess('interaction_raw', 'interaction')"
	Rscript -e 'library("truthiness"); reproduce_analysis_sim("all_null", outfile = "analysis_all_null.html", recipe = TRUE)'
	Rscript -e 'library("truthiness"); reproduce_analysis_sim("main_effect", outfile = "analysis_main_effect.html", recipe = TRUE)'
	Rscript -e 'library("truthiness"); reproduce_analysis_sim("interaction", outfile = "analysis_interaction.html", recipe = TRUE)'

draft :
	Rscript -e "rmarkdown::draft('$(OUT)', 'illusory-truth-analysis', 'truthiness', FALSE, FALSE)" && echo "wrote R Markdown script to $(OUT)"

render :
	Rscript -e "library('truthiness'); reproduce_analysis(recipe = $(RECIPE), infile = '$(INFILE)', outfile = '$(OUTFILE)', modfits = $(MODFITS))"
