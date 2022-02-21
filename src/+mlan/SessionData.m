classdef SessionData < mlnipet.MetabolicSessionData
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
    
    properties
        registry
        tracers = {'ho' 'oo' 'oc'}
    end
    
    methods (Static)
        function this = create(varargin)
            % @param folders ~ <project folder>/<session folder>/<scan folder>, in getenv('SINGULARITY_HOME')
            % @param ignoreFinishMark is logical, default := false
            
            ip = inputParser;
            addRequired(ip, 'folders', @(x) isfolder(fullfile(getenv('SINGULARITY_HOME'), x)))
            addParameter(ip, 'ignoreFinishMark', false, @islogical);
            parse(ip, varargin{:});
            ipr = adjustIpr(ip.Results);
    
            this = mlan.SessionData( ...
                'studyData', mlan.Ccir993Registry.instance(), ...
                'projectData', mlan.ProjectData('projectFolder', ipr.prjfold), ...
                'subjectData', mlan.SubjectData(), ...
                'sessionFolder', ipr.sesfold, ...
                'scanFolder', ipr.scnfold);
            this.ignoreFinishMark = ipr.ignoreFinishMark;            
            
            function ipr = adjustIpr(ipr)
                ss = strsplit(ipr.folders, filesep);
                assert(3 == length(ss));
                ipr.prjfold = ss{1};
                ipr.sesfold = ss{2};
                ipr.scnfold = ss{3};
            end
        end
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
        
        function getStudyCensus(~)
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
        function obj  = visitMapOnAtl(this, map, varargin)
            fqfn = fullfile(this.vLocation, ...
                sprintf('%s_on_%s%s%s', map, this.studyAtlas.fileprefix, this.atlasTag, this.filetypeExt));
            obj  = this.fqfilenameObject(fqfn, varargin{:});
        end
                
        %%
        
      	function this = SessionData(varargin)
 			this = this@mlnipet.MetabolicSessionData(varargin{:}); 
            if isempty(this.studyData_)
                this.studyData_ = mlan.StudyData();
            end
            this.ReferenceTracer = 'HO';
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

