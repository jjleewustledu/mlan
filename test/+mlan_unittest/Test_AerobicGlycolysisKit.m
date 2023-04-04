classdef Test_AerobicGlycolysisKit < matlab.unittest.TestCase
    %% line1
    %  line2
    %  
    %  Created 01-Jul-2022 21:26:53 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlan/test/+mlan_unittest.
    %  Developed on Matlab 9.12.0.1975300 (R2022a) Update 3 for MACI64.  Copyright 2022 John J. Lee.
    
    properties
        ho_dyn_fqfn
        immediator
        oc_avgt_fqfn
        petPath
        sessionPath
        subjectPath
        testObj
    end
    
    methods (Test)
        function test_afun(this)
            import mlan.*
            this.assumeEqual(1,1);
            this.verifyEqual(1,1);
            this.assertEqual(1,1);
        end
        function test_construct(this)
            these = mlvg.QuadraticAerobicGlycolysisKit.construct('cbf', subjectsExpr='sub-S03292-N12', Nimages=1);
            disp(these)
        end
        function test_construct_cbf_legacy(this)
            pwd0 = pushd(this.subjectPath);
            mlan.QuadraticAerobicGlycolysisKit.construct( ...
                'cbf', ...
                'subjectsExpr', 'sub-S05512');
            popd(pwd0);
        end
        function test_flirt_dyn(this)
            pwd0 = pushd(fullfile(this.petPath));
            bb = mlvg.Ccir1211Bids();
            t1w = glob('sub-*-MPRAGE_T1_SAGITTAL-*_orient-rpi_T1w.nii.gz');
            t1w = t1w{1};
            for t = {'oc', 'oo', 'ho'}
                for g = glob(sprintf('sub*_trc-%s*_pet.nii.gz', t{1}))'
                    med = mlvg.Ccir1211Mediator(g{1});
                    bb.flirt_dyn_to_t1w(g{1}, t1w, taus=med.taus);
                end
            end
            
            popd(pwd0)
        end
    end
    
    methods (TestClassSetup)
        function setupAerobicGlycolysisKit(this)
            setenv('SUBJECTS_DIR', '~/Singularity/CCIR_00993/derivatives')
            import mlvg.*
            this.subjectPath = fullfile(getenv('HOME'), 'Singularity/CCIR_00993/derivatives/sub-S03292-N12');
            this.sessionPath = fullfile(this.subjectPath, 'ses-20191031');
            this.petPath = fullfile(this.sessionPath, 'pet');
            this.testObj_ = []; % must call abstract factory's construct*() methods.

%            import mlan.*
%            this.sessionPath = '/data/anlab/jjlee/Singularity/CCIR_00993/derivatives/nipet/ses-E19850';
%            this.subjectPath = '/data/anlab/jjlee/Singularity/CCIR_00993/derivatives/resolve/sub-S05516';
%            this.testObj_ = AerobicGlycolysisKit();
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
