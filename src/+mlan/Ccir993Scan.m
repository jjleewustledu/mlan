classdef Ccir993Scan < mlpipeline.ScanData2 & handle
    %% line1
    %  line2
    %  
    %  Created 22-Feb-2023 18:45:54 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/src/+mlan.
    %  Developed on Matlab 9.13.0.2126072 (R2022b) Update 3 for MACI64.  Copyright 2023 John J. Lee.

    properties
    end
    
    methods
        function this = Ccir993Scan(varargin)
            this = this@mlpipeline.ScanData2(varargin{:});
        end
        function t = taus(this, trc)
            arguments
                this mlan.Ccir993Scan
                trc {mustBeTextScalar} = this.tracer
            end

            %% KLUDGE for integrating Ccir993
            dt_ = this.datetime_bids_filename();
            assert(~isnat(dt_))
            ddt = seconds(60);
            targ = datetime(2019,10,31,9,57,23, TimeZone="local"); % co1
            if isbetween(dt_, targ-ddt, targ+ddt)
                t = [12+3, 3, 3, 3, 3, 3, 3, 3, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 10, 10, 11, 11, 12, 13, 14, 15, 16, 18, 19, 22, 24, 28, 33, 39, 49, 64, 49, 120];
                return
            end
            targ = datetime(2019,10,31,11,2,9, TimeZone="local"); % co2
            if isbetween(dt_, targ-ddt, targ+ddt)
                t = [3, 3, 3, 3, 3, 3, 3, 3, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 10, 10, 11, 11, 12, 13, 14, 15, 16, 18, 19, 22, 24, 28, 33, 39, 49, 64, 49, 120];
                return
            end
            targ = datetime(2019,10,31,10,18,51, TimeZone="local"); % oo1
            if isbetween(dt_, targ-ddt, targ+ddt)
                t = [12+2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 10, 10, 15, 366];
                return
            end
            targ = datetime(2019,10,31,11,24,9, TimeZone="local"); % oo2
            if isbetween(dt_, targ-ddt, targ+ddt)
                t = [54+2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 10, 10, 15, 366];
                return
            end
            targ = datetime(2019,10,31,10,40,58, TimeZone="local"); % ho1
            if isbetween(dt_, targ-ddt, targ+ddt)
                t = [39+2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7];
                return
            end
            targ = datetime(2019,10,31,11,46,17, TimeZone="local"); % ho2
            if isbetween(dt_, targ-ddt, targ+ddt)
                t = [2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4];
                return
            end
        end
    end
    
    methods (Static)
        function t = consoleTaus(~)
            t = nan;
        end
    end

    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
