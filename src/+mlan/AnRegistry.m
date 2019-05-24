classdef AnRegistry < handle & mlnipet.Resources
	%% ANREGISTRY 

	%  $Revision$
 	%  was created 15-Oct-2015 16:31:41
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
    properties 
        noclobber = true
        umapType = 'pseudoct'
    end
    
    properties (Dependent)
        rawdataDir
        projectsDir
        subjectsDir
        YeoDir
    end
    
    methods 
        
        %% GET
        
        function x = get.rawdataDir(~)
            x = fullfile(getenv('PPG'), 'rawdata', '');
        end   
        function g = get.projectsDir(~)
            g = getenv('PROJECTS_DIR');
        end        
        function     set.projectsDir(~, s)
            assert(isdir(s));
            setenv('PROJECTS_DIR', s);
        end
        function g = get.subjectsDir(~)
            g = getenv('SUBJECTS_DIR');
        end        
        function     set.subjectsDir(~, s)
            assert(isdir(s));
            setenv('SUBJECTS_DIR', s);
        end
        function g = get.YeoDir(this)
            g = this.subjectsDir;
        end   
    end
    
    methods (Static)
        function this = instance(qualifier)
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                if (strcmp(qualifier, 'initialize'))
                    uniqueInstance = [];
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlan.AnRegistry();
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end  
    
    %% PROTECTED
    
	methods (Access = protected)		  
 		function this = AnRegistry(varargin)
            this = this@mlnipet.Resources(varargin{:});
            setenv('CCIR_RAD_MEASUREMENTS_DIR',  ...
                   fullfile(getenv('HOME'), 'Documents', 'private', ''));
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

