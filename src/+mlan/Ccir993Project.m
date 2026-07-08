classdef Ccir993Project < handle & mlpipeline.ProjectData2
    %% line1
    %  line2
    %  
    %  Created 04-Apr-2023 16:45:32 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.14.0.2206163 (R2023a) for MACI64.  Copyright 2023 John J. Lee.
    
    methods
        function this = Ccir993Project(varargin)
            this = this@mlpipeline.ProjectData2(varargin{:});
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
