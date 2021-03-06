classdef (Sealed) StudyRegistry < handle & mlnipet.StudyRegistry
	%% STUDYREGISTRY 

	%  $Revision$
 	%  was created 15-Oct-2015 16:31:41
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
    properties
        ignoredExperiments = {}
        tracerList = {'oc' 'oo' 'ho'}
    end
    
    properties (Dependent)
        subjectsJson
    end
    
    methods (Static)
        function sub  = subjectID_to_sub(sid)
            assert(ischar(sid));
            ss = strsplit(sid, '_');
            sub = ['sub-' ss{end}];
        end
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
                this = mlan.StudyRegistry();
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end  
    
    methods
        
        %% GET        
        
        function g = get.subjectsJson(~)
            g = jsondecode( ...
                fileread(fullfile(getenv('SUBJECTS_DIR'), 'constructed_20191108.json')));
        end
    end
    
    %% PRIVATE
    
	methods (Access = private)		  
 		function this = StudyRegistry(varargin)
            this = this@mlnipet.StudyRegistry(varargin{:});
            setenv('CCIR_RAD_MEASUREMENTS_DIR',  ...
                   fullfile(getenv('HOME'), 'Documents', 'private', ''));               
            this.referenceTracer = 'HO';
            this.umapType = 'pseudoct';
 		end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

