classdef QuadraticAerobicGlycolysisKit2 < handle & mlpet.AbstractAerobicGlycolysisKit2
    %% QUADRATICAEROBICGLYCOLYSISKIT is a factory implementing quadratic parameterization of kinetic rates using
    %  emissions.  See also papers by Videen, Herscovitch.  This implementation supports CCIR_0993.
    %  
    %  Created 04-Apr-2023 12:25:50 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.14.0.2206163 (R2023a) for MACI64.  Copyright 2023 John J. Lee.
    
    methods (Static)
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
