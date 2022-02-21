classdef (Sealed) Ccir993Registry < handle & mlnipet.StudyRegistry
	%% STUDYREGISTRY 

	%  $Revision$
 	%  was created 15-Oct-2015 16:31:41
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
    properties
        ignoredExperiments = {}
        referenceTracer = 'HO'
        tracerList = {'oc' 'oo' 'ho'}
        umapType = 'deep'
    end
    
    properties (Dependent)
        projectsDir
        subjectsDir	
        subjectsJson
    end
    
    methods (Static)
        function this = instance(varargin)
            %% INSTANCE
            %  @param optional qualifier is char \in {'initialize' ''}
            
            ip = inputParser;
            addOptional(ip, 'qualifier', '', @ischar)
            parse(ip, varargin{:})
            
            persistent uniqueInstance
            if (strcmp(ip.Results.qualifier, 'initialize'))
                uniqueInstance = [];
            end          
            if (isempty(uniqueInstance))
                this = mlan.Ccir993Registry();
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end  
    
    methods
        
        %% GET
        
        function g = get.projectsDir(~)
            g = getenv('PROJECTS_DIR');
        end 
        function     set.projectsDir(~, s)
            assert(isfolder(s));
            setenv('PROJECTS_DIR', s);
        end  
        function g = get.subjectsDir(~)
            g = getenv('SUBJECTS_DIR');
        end        
        function     set.subjectsDir(~, s)
            assert(isfolder(s));
            setenv('SUBJECTS_DIR', s);
        end
        function g = get.subjectsJson(~)
            g = jsondecode( ...
                fileread(fullfile(getenv('SUBJECTS_DIR'), 'constructed_20191108.json')));
        end
    end
    
    %% PRIVATE
    
	methods (Access = private)		  
 		function this = Ccir993Registry(varargin)
            this = this@mlnipet.StudyRegistry(varargin{:});
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

