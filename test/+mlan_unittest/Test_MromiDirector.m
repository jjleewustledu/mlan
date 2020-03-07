classdef Test_MromiDirector < matlab.unittest.TestCase
	%% TEST_MROMIDIRECTOR 

	%  Usage:  >> results = run(mlan_unittest.Test_MromiDirector)
 	%          >> result  = run(mlan_unittest.Test_MromiDirector, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 05-Jan-2017 13:47:42
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlan/test/+mlan_unittest.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64.
 	

	properties
 		registry
        sessd
        studyd
 		testObj
 	end

	methods (Test)
        function test_setup(this)
            this.verifyClass(this.testObj, 'mlan.MromiDirector');
            this.verifyClass(this.testObj.sessionData, 'mlraichle.SynthSessionData');
        end
        function test_constructOefAtlas(this)
            oef = this.testObj.constructOefAtlas('typ', 'mlfourd.ImagingContext');
            oef.view;
        end
        function test_constructOefMap(this)
            oef = this.testObj.constructOefMap('typ', 'mlfourd.ImagingContext');
            oef.view;
        end
        function test_constructPetObsMap(this)
            this.sessd.tracer = 'HO';
            this.sessd.snumber = 1;
            this.sessd.attenuationCorrected = true;
            petObs = this.testObj.constructPetObsMap('sessionData', this.sessd);
            petObs.view;
        end
        function test_constructCbfMap(this)
            this.testObj = this.testObj.constructCbfMap;
            this.testObj.product.view;
        end
        function test_constructCbvMap(this)
            cbv = this.testObj.constructCbvMap('typ', 'mlfourd.ImagingContext');
            cbv.view;
        end
	end

 	methods (TestClassSetup)
		function setupMromiDirector(this)
            import mlderdeyn.*;
            this.studyd = StudyDataSingleton.instance;
            this.sessd = SessionData( ...
                'studyData', this.studyd, ...
                'sessionPath', fullfile(this.studyd.subjectsDir, 'mm01-007_p7267_2008jun16', ''));
 			%import mlan.*;
            %this.studyd = mlraichle.SynthStudyData;
            %this.sessd = mlraichle.SynthSessionData( ...
            %    'studyData', this.studyd, ...
            %    'sessionPath', fullfile(getenv('PPG'), 'jjleeSynth', 'HYGLY09', ''), ...
            %    'snumber', 1);
 			this.testObj_ = MromiDirector('sessionData', this.sessd);
 		end
	end

 	methods (TestMethodSetup)
		function setupMromiDirectorTest(this)
 			this.testObj = this.testObj_;
 			this.addTeardown(@this.cleanFiles);
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanFiles(this)
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

