classdef Ccir993Subject < handle & mlpipeline.SubjectData2
    %% line1
    %  line2
    %  
    %  Created 04-Apr-2023 16:47:31 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.14.0.2206163 (R2023a) for MACI64.  Copyright 2023 John J. Lee.
    
    properties
        defects = {}
    end

    methods
        function this = Ccir993Subject(varargin)
            this = this@mlpipeline.SubjectData2(varargin{:});
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
