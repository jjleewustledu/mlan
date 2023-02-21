classdef Test_AerobicGlycolysisKit < matlab.unittest.TestCase
    %% line1
    %  line2
    %  
    %  Created 01-Jul-2022 21:26:53 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/test/+mlan_unittest.
    %  Developed on Matlab 9.12.0.1975300 (R2022a) Update 3 for MACI64.  Copyright 2022 John J. Lee.
    
    properties
        sessionPath
        testObj
    end
    
    methods (Test)
        function test_afun(this)
            import mlan.*
            this.assumeEqual(1,1);
            this.verifyEqual(1,1);
            this.assertEqual(1,1);
        end
        function test_construct_cbf(this)
            pwd0 = pushd(this.subjectPath);
            mlan.QuadraticAerobicGlycolysisKit.construct( ...
                'cbf', ...
                'subjectsExpr', 'sub-S05512');
            popd(pwd0);
        end
    end
    
    methods (TestClassSetup)
        function setupAerobicGlycolysisKit(this)
            import mlan.*
            this.sessionPath = '/data/anlab/jjlee/Singularity/CCIR_00993/derivatives/nipet/ses-E19850';
            this.subjectPath = '/data/anlab/jjlee/Singularity/CCIR_00993/derivatives/resolve/sub-S05516';
            this.testObj_ = AerobicGlycolysisKit();
        end
    end
    
    methods (TestMethodSetup)
        function setupAerobicGlycolysisKitTest(this)
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
