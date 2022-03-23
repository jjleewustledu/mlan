classdef Test_SessionData < matlab.unittest.TestCase
    %% line1
    %  line2
    %  
    %  Created 22-Feb-2022 09:39:36 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/test/+mlan_unittest.
    %  Developed on Matlab 9.11.0.1837725 (R2021b) Update 2 for MACI64.  Copyright 2022 John J. Lee.
    
    properties
        sesFolder = 'ses-E03140'
        tracerFolder = 'HO_DT20190530111122.000000-Converted-NAC'
        testObj
    end
    
    methods (Test)
        function test_afun(this)
            import mlan.*
            this.assumeEqual(1,1);
            this.verifyEqual(1,1);
            this.assertEqual(1,1);
        end
    end
    
    methods (TestClassSetup)
        function setupSessionData(this)
            import mlan.*
            this.testObj_ = ...
                SessionData.create(fullfile('CCIR_00993', this.sesFolder, this.tracerFolder));
        end
    end
    
    methods (TestMethodSetup)
        function setupSessionDataTest(this)
            this.testObj = this.testObj_;
            this.addTeardown(@this.cleanTestMethod)
        end
    end
    
    properties (Access = private)
        testObj_
    end
    
    methods (Access = private)
        function cleanTestMethod(this)
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
