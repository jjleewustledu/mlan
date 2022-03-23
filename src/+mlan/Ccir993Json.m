classdef Ccir993Json < mlpipeline.CcirJson
    %% CCIR993JSON manages *.json and *.mat data repositories for CNDA-related data such as subjects, experiments, aliases.
    %  
    %  Created 18-Jan-2022 14:25:55 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.11.0.1837725 (R2021b) Update 2 for MACI64.  Copyright 2022 John J. Lee.
    
    methods (Static)        
        function S = loadConstructed()
            import mlan.Ccir993Json;
            S = jsondecode(fileread(fullfile(Ccir993Json.projectPath, Ccir993Json.filenameConstructed)));
        end
    end

    properties (Constant)
        filenameConstructed = 'constructed_20191108.json'      
        projectPath = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00993', '')
    end

    properties (Dependent)
        xidToSubFolder
    end

    methods

        %% GET

        function g = get.xidToSubFolder(this)
            g = this.xidToSubFolder_;
        end

        %%

        function this = Ccir993Json(varargin)
            this = this@mlpipeline.CcirJson(varargin{:});
            %this.S_ = mlan.Ccir993Json.loadConstructed();   
            this.xidToSubFolder_ = this.buildXidToSubfolder();
        end
    end

    %% PROTECTED

    methods (Access = protected)
        function m = buildXidToSubfolder(this)
            S = struct(this);
            xids = fields(S);
            m = containers.Map;
            for i = 1:length(xids)                
                sid_ = S.(xids{i}).sid;
                ss = strsplit(sid_, '_');
                m(xids{i}) = strcat('sub-', ss{2});
            end
            m('x0993_011') = m('x993_011'); % KLUDGE for inconsistency of CNDA data entry 
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
