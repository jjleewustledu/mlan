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
        function test_create_cmro2(this)
            fqfn = fullfile(this.ses_dir, 'pet', 'sub-S03292-N12_ses-20191031104058_trc-ho_proc-dyn-r2-op-frame55_pet.nii.gz');            
            mlkinetics.KineticsKit.create_cmro2( ...
                ["ccir993", "nifti", "mmr", "15o"], ...
                fqfn, ...
                ["timedispersed", "twilite", "wmparc"])
        end
        function test_BidsKit(this)
            fqfn = fullfile(this.ses_dir, 'pet', 'sub-S03292-N12_ses-20191031104058_trc-ho_proc-dyn-r2-op-frame55_pet.nii.gz');
            bk = mlkinetics.BidsKit(proto_bids_med=mlan.Ccir993Mediator(fqfn));
            disp(bk.make_bids_med())
        end
        function test_registry(this)
            this.verifyNotEmpty(mlan.Ccir993Registry.instance())
        end
    end
    
    methods (TestClassSetup)
        function setupCcir993(this)
            this.prj_dir = fullfile(getenv('SINGULARITY_HOME'), 'CCIR_00993');
            this.sub_dir = fullfile(this.prj_dir, 'derivatives', 'sub-S03292-N12');
            this.ses_dir = fullfile(this.sub_dir, 'ses-20191031');
        end
    end
    
    methods (TestMethodSetup)
        function setupCcir993Test(this)
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
