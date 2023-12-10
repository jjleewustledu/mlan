classdef QuadraticAerobicGlycolysisKit2 < handle & mlpet.AbstractAerobicGlycolysisKit2
    %% QUADRATICAEROBICGLYCOLYSISKIT is a factory implementing quadratic parameterization of kinetic rates using
    %  emissions.  See also papers by Videen, Herscovitch.  This implementation supports CCIR_0993.
    %  
    %  Created 04-Apr-2023 12:25:50 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.14.0.2206163 (R2023a) for MACI64.  Copyright 2023 John J. Lee.
    
    properties (Dependent)
        atlasTag
        blurTag
        scanFolder % e.g., resampling_restricted
        scanPath
        registry
        regionTag
        subjectFolder % e.g., sub-108293
        subjectPath
        tags
    end 

    methods % GET
        function g = get.atlasTag(~)
            g = mlan.Ccir993Registry.instance.atlasTag;
        end
        function g = get.blurTag(~)
            g = mlan.Ccir993Registry.instance.blurTag;
        end
        function g = get.scanFolder(this)
            g = this.immediator.scanFolder;
        end  
        function g = get.scanPath(this)
            g = this.immediator.scanPath;
        end  
        function g = get.registry(this)
            g = mlan.Ccir993Registry.instance();
        end
        function g = get.regionTag(this)
            g = this.immediator.regionTag;
        end
        function g = get.subjectFolder(this)
            g = this.immediator.subjectFolder;
        end
        function g = get.subjectPath(this)
            g = this.immediator.subjectPath;
        end
        function g = get.tags(this)
            g = strcat(this.blurTag, this.regionTag);
        end
    end

    methods (Static)
        function these = construct(varargin)
            %% CONSTRUCT
            %  e.g.:  construct('cbv', 'subjectsExpr', 'sub-S58163*', 'Nthreads', 1, 'region', 'wholebrain', 'aifMethods', 'idif')
            %  e.g.:  construct('cbv', 'debug', true)
            %  @param required metric is char, e.g., cbv, cbf, cmro2, cmrglc.
            %  @param subjectsExpr is text, e.g., 'sub-S58163*'.
            %  @param region is char, e.g., wholebrain, voxels.
            %  @param debug is logical.
            %  @param Nthreads is numeric|char.
            
            import mlan.*
            import mlan.QuadraticAerobicGlycolysisKit2.*

            % global
            setenv('SUBJECTS_DIR', fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00993', 'derivatives'))
            setenv('PROJECTS_DIR', getenv('SINGULARITY_HOME'))
            setenv('DEBUG', '')
            setenv('NOPLOT', '')
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired( ip, 'metric', @istext)
            addParameter(ip, 'subjectsExpr', 'sub-S03292-N12', @istext)
            addParameter(ip, 'region', 'voxels', @istext)
            addParameter(ip, 'debug', ~isempty(getenv('DEBUG')), @islogical)
            addParameter(ip, 'Nthreads', 1, @(x) isnumeric(x) || istext(x))
            addParameter(ip, 'Nimages', inf, @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            if istext(ipr.Nthreads)
                ipr.Nthreads = str2double(ipr.Nthreads);
            end
            
            % construct            
            pwd1 = pushd(getenv('SUBJECTS_DIR'));
            theData = QuadraticAerobicGlycolysisKit2.constructData( ...
                'subjectsExpr', ipr.subjectsExpr, ...
                'tracer', tracer, ...
                'metric', metric, ...
                'region', region); 
            these = cell(size(theData));
            if ipr.Nthreads > 1                
                parfor (p = 1:length(theData), ipr.Nthreads)
                    try
                        these{p} = mlkinetics.QuadraticKit(theData(p));
                        these{p}.call(ipr.metric)
                    catch ME
                        handwarning(ME)
                    end
                end
            elseif ipr.Nthreads == 1
                for p = 1:min(length(theData), ipr.Nimages)
                    try
                        these{p} = mlkinetics.QuadraticKit(theData(p));
                        these{p}.call(ipr.metric) % RAM ~ 3.3 GB
                    catch ME
                        handwarning(ME)
                    end
                end
            end            
            popd(pwd1);
        end
        function dat = constructData(varargin)
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'subjectsExpr', 'sub-*', @istext)
            addParameter(ip, 'sessionsExpr', 'ses-*/pet', @istext)
            addParameter(ip, 'tracer', '', @istext)
            addParameter(ip, 'metric', '', @istext)
            addParameter(ip, 'region', 'voxels', @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;

            idx = 1;
            setenv('SUBJECTS_DIR', fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00993', 'derivatives'))
            scans = glob(fullfile( ...
                getenv('SUBJECTS_DIR'), ipr.subjectsExpr, ipr.sessionsExpr, ...
                sprintf('*_trc-%s_proc-dyn*_pet_%s.nii.gz', ...
                ipr.tracer, mlan.Ccir993Registry.instance().atlasTag)))';
            for s = scans
                dat_ = mlan.Ccir993Mediator(s{1}); %#ok<AGROW>
                dat_.metric = ipr.metric;
                dat_.regionTag = ipr.region;
                dat(idx) = dat_; %#ok<AGROW> 
                idx = idx + 1;
            end            
        end
    end

    %% PROTECTED

    methods (Access = {?mlpet.AbstractAerobicGlycolysisKit2, ?mlan.QuadraticAerobicGlycolysisKit})
        function this = QuadraticAerobicGlycolysisKit2(varargin)
            %% QUADRATICAEROBICGLYCOLYSISKIT 
            %  Args:
            %      immediator (ImagingMediator): session-specific objects
            %      aifMethods: containers.Map
            
            this = this@mlpet.AbstractAerobicGlycolysisKit2(varargin{:})
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
