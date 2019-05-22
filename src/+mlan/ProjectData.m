classdef ProjectData < mlpipeline.ProjectData
	%% PROJECTDATA  

	%  $Revision$
 	%  was created 08-May-2019 19:15:29 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
 	%% It was developed on Matlab 9.5.0.1067069 (R2018b) Update 4 for MACI64.  Copyright 2019 John Joowon Lee.
 	
	properties (Dependent)
        jsonDir
 	end

	methods 
        
        %% GET
        
        function g = get.jsonDir(~)
            g = getenv('SUBJECTS_DIR');
        end
        
        %%
        
        function g = getProjectFolder(varargin)
            g = 'CCIR_00993';
        end
        function g = getProjectPath(this, s)
            g = fullfile(this.projectsDir, this.getProjectFolder(s), '');
        end
        function p = session2project(varargin)
            %% e.g.:  {'CNDA_E1234','ses-E1234'} -> 'CCIR_00123'
            
            p = 'CCIR_00993';
        end
		  
 		function this = ProjectData(varargin)
 			%% PROJECTDATA
 			%  @param .

 			this = this@mlpipeline.ProjectData(varargin{:});
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

