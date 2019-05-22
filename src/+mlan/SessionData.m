classdef SessionData < mlnipet.CommonSessionData
	%% SESSIONDATA  

	%  $Revision$
 	%  was created 15-Feb-2016 01:51:37
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlan/src/+mlan.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.    
    
    properties (Constant)
        STUDY_CENSUS_XLSX_FN = ''
    end
    
    methods (Static)
        function sessd = struct2sessionData(sessObj)
            if (isa(sessObj, 'mlan.SessionData'))
                sessd = sessObj;
                return
            end
            
            assert(isfield(sessObj, 'projectFolder'));
            assert(isfield(sessObj, 'sessionFolder'));
            assert(isfield(sessObj, 'sessionDate'));
            assert(isfield(sessObj, 'parcellation'));
            studyd = mlan.StudyData;
            sessp = fullfile(studyd.projectsDir, sessObj.projectFolder, sessObj.sessionFolder, '');
            sessd = mlan.SessionData('studyData', studyd, 'sessionPath', sessp, ...
                                     'tracer', 'HO', 'ac', true, 'sessionDate', sessObj.sessionDate);  
            if ( isfield(sessObj, 'parcellation') && ...
                ~isempty(sessObj.parcellation))
                sessd.parcellation = sessObj.parcellation;
            end
        end
    end

    methods
        
        %% GET, SET
        
        function g    = getStudyCensus(this)
            error('mlan:NotImplementedError', 'SessionData.studyCensus');
        end 
                
        %% Metabolism
              
        function obj  = cbfOnAtl(this, varargin)
            obj = this.visitMapOnAtl('cbf', varargin{:});
        end
        function obj  = cbvOnAtl(this, varargin)
            obj = this.visitMapOnAtl('cbv', varargin{:});
        end
        function obj  = oefOnAtl(this, varargin)
            obj = this.visitMapOnAtl('oef', varargin{:});
        end
        function obj  = cmro2OnAtl(this, varargin)
            obj = this.visitMapOnAtl('cmro', varargin{:});
        end
        function obj  = ogiOnAtl(this, varargin)
            obj = this.visitMapOnAtl('ogi', varargin{:});
        end
        function obj  = agiOnAtl(this, varargin)
            % dag := cmrglc - cmro2/6 \approx aerobic glycolysis
            
            obj = this.visitMapOnAtl('agi', varargin{:});
        end
                
        %%
        
      	function this = SessionData(varargin)
 			this = this@mlnipet.CommonSessionData(varargin{:});
            if (isempty(this.subjectData_))
                this.subjectData_ = mlan.SubjectData();
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

