classdef Test_Ccir993 < matlab.unittest.TestCase
    %% line1
    %  line2
    %  
    %  Created 30-Jun-2022 13:50:54 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/test/+mlan_unittest.
    %  Developed on Matlab 9.12.0.1956245 (R2022a) Update 2 for MACI64.  Copyright 2022 John J. Lee.
    
    properties
        prj_dir
        ses_dir
        sub_dir
        testObj
    end
    
    methods (Test)
        function test_afun(this)
            import mlan.*
            this.assumeEqual(1,1);
            this.verifyEqual(1,1);
            this.assertEqual(1,1);
        end
        function test_call_20200110(this)
            this.sub_dir = fullfile(this.prj_dir, 'derivatives', 'resolve', 'sub-S05516', '');
            this.ses_dir = fullfile(this.prj_dir, 'derivatives', 'nipet', 'ses-E19850', '');
            this.testObj_ = mlan.Ccir993( ...
                'subject_dir', this.sub_dir, ...
                'session_dir', this.ses_dir);

            pwd0 = pushd(this.sub_dir);
            call_metab(this.testObj);
            popd(pwd0);
        end
        function test_call_20191008(this)
            this.sub_dir = fullfile(this.prj_dir, 'derivatives', 'resolve', 'sub-S02951', '');
            this.ses_dir = fullfile(this.prj_dir, 'derivatives', 'nipet', 'ses-E06418', '');
            this.testObj_ = mlan.Ccir993( ...
                'subject_dir', this.sub_dir, ...
                'session_dir', this.ses_dir);

            pwd0 = pushd(this.sub_dir);
            call_metab(this.testObj);
            popd(pwd0);
        end
        function test_call_cmro2(this)
            pwd0 = pushd(this.sub_dir);
            mlan.QuadraticAerobicGlycolysisKit.construct( ...
                'cmro2', ...
                'subjectsExpr', basename(this.sub_dir));
            popd(pwd0);
        end
        function test_registry(this)
            this.verifyNotEmpty(mlan.Ccir993Registry.instance())
        end
    end
    
    methods (TestClassSetup)
        function setupCcir993(this)
            this.prj_dir = '/data/anlab/jjlee/Singularity/CCIR_00993';
            this.sub_dir = fullfile(this.prj_dir, 'derivatives', 'resolve', 'sub-S02951', '');
            this.ses_dir = fullfile(this.prj_dir, 'derivatives', 'nipet', 'ses-E06418', '');
%            this.sub_dir = fullfile(this.prj_dir, 'derivatives', 'resolve', 'sub-S05516', '');
%            this.ses_dir = fullfile(this.prj_dir, 'derivatives', 'nipet', 'ses-E19850', '');
%             this.testObj_ = mlan.Ccir993( ...
%                 'subject_dir', this.sub_dir, ...
%                 'session_dir', this.ses_dir);
        end
    end
    
    methods (TestMethodSetup)
        function setupCcir993Test(this)
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
