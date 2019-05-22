classdef StudyData < mlpipeline.StudyData
	%% STUDYDATA  

	%  $Revision$
 	%  was created 16-May-2019 18:10:15 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
 	%% It was developed on Matlab 9.5.0.1067069 (R2018b) Update 4 for MACI64.  Copyright 2019 John Joowon Lee.
 	
	methods 		  
 		function this = StudyData(varargin)
 			this = this@mlpipeline.StudyData(mlan.AnRegistry.instance(), varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

