classdef Ccir993Session < handle & mlpipeline.SessionData2
    %% line1
    %  line2
    %  
    %  Created 04-Apr-2023 16:46:19 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.14.0.2206163 (R2023a) for MACI64.  Copyright 2023 John J. Lee.
    
    properties
        defects = {}
    end

    methods
        function this = Ccir993Session(varargin)
            this = this@mlpipeline.SessionData2(varargin{:});
            this.registry_ = mlsiemens.VisionRegistry.instance();
        end
    end

    %% PROTECTED

    methods (Access = ?mlpipeline.SessionData2)
        function buildRadmeasurements(this)
            %this.radMeasurements_ = mlpet.CCIRRadMeasurements.createFromSession( ...
            %    this.mediator_);
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
